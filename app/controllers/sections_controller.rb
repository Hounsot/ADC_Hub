class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section, only: [ :update, :batch_update ]
  before_action :authorize_user!, only: [ :update, :batch_update ]
  include ActionView::RecordIdentifier

  def update
  end

  # Batch update all cards in a section along with the section itself
  def batch_update
    # First update the section attributes if any are provided
    section_updated = true
    if section_params.present?
      section_updated = @section.update(section_params)
      Rails.logger.info("Section update result: #{section_updated}")
    end

    # Then batch update all the cards
    cards_updated = true
    if params[:cards].present?
      begin
        Rails.logger.info("Card params format: #{params[:cards].class.name}, Contains keys: #{params[:cards].keys}")
        cards_updated = @section.batch_save_cards(params[:cards])
        Rails.logger.info("Batch saved cards result: #{cards_updated}")
      rescue => e
        cards_updated = false
        Rails.logger.error("Error in batch_update: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end

    # Process any temporary image blobs for this section
    if session[:temp_image_blobs] && session[:temp_image_blobs][@section.id.to_s].present?
      begin
        Rails.logger.info("Processing #{session[:temp_image_blobs][@section.id.to_s].count} temporary image blobs")

        # Create a new card for each temporary blob
        session[:temp_image_blobs][@section.id.to_s].each do |blob_id|
          begin
            # Find the blob
            blob = ActiveStorage::Blob.find_signed(blob_id)

            if blob
              # Create a new card with this image
              card = @section.cards.build(
                card_type: "image",
                user: current_user,
                position: (@section.cards.maximum(:position) || 0) + 1
              )

              # Attach the image
              card.image.attach(blob)

              # Save the card
              if card.save
                Rails.logger.info("Created new card from temporary blob: #{card.id}")
              else
                Rails.logger.error("Failed to save card from blob: #{card.errors.full_messages}")
              end
            else
              Rails.logger.error("Could not find blob with ID: #{blob_id}")
            end
          rescue => e
            Rails.logger.error("Error processing blob #{blob_id}: #{e.message}")
          end
        end

        # Clear the temporary blobs for this section
        session[:temp_image_blobs][@section.id.to_s] = []
      rescue => e
        Rails.logger.error("Error processing temporary blobs: #{e.message}")
      end
    end

    # Return appropriate response
    if section_updated && cards_updated
      render turbo_stream: turbo_stream.replace("section_#{@section.id}",
        partial: "sections/section",
        locals: { section: @section, user: @section.user })
    else
      error_message = []
      error_message << "Failed to update section" unless section_updated
      error_message << "Failed to update cards" unless cards_updated

      render json: { error: error_message.join(". ") }, status: :unprocessable_entity
    end
  end

  def destroy
    @section = Section.find(params[:id])
    @section.destroy

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.remove("section_#{@section.id}"),
          turbo_stream.remove("section_create_button_#{@section.position}")
        ]
      }
    end
  end

  def create
    @section = Section.new(title: "Новая секция")
    @section.user = current_user
    @section.position = current_user.sections.count + 1

    respond_to do |format|
      if @section.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append("sections-container", partial: "sections/section", locals: { section: @section }),
            turbo_stream.append("sections-container", partial: "sections/section_create_button", locals: { user: current_user, position: @section.position + 1 })
          ]
        }
      else
        format.turbo_stream {
          # Just refresh the container if something goes wrong
          render turbo_stream: turbo_stream.replace(
            "sections-container",
            partial: "sections/sections_container",
            locals: { user: current_user }
          )
        }
      end
    end
  end

  def move_up
    @section = Section.find(params[:id])

    if current_user == @section.user && @section.position > 1
      # Find the section above this one
      @section_above = current_user.sections.find_by(position: @section.position - 1)

      # Store original positions before changing them
      current_position = @section.position
      above_position = @section_above.position

      # Swap positions
      if @section_above
        Section.transaction do
          # Swap the positions directly
          @section.update_column(:position, above_position)
          @section_above.update_column(:position, current_position)
        end
      end

      respond_to do |format|
        format.html { redirect_to user_path(current_user) }
        format.turbo_stream
      end
    else
      head :forbidden
    end
  end

  def move_down
    @section = Section.find(params[:id])

    if current_user == @section.user && @section.position < current_user.sections.count
      # Find the section below this one
      @section_below = current_user.sections.find_by(position: @section.position + 1)

      # Store original positions before changing them
      current_position = @section.position
      below_position = @section_below.position

      # Swap positions
      if @section_below
        Section.transaction do
          # Swap the positions directly
          @section.update_column(:position, below_position)
          @section_below.update_column(:position, current_position)
        end
      end

      respond_to do |format|
        format.html { redirect_to user_path(current_user) }
        format.turbo_stream
      end
    else
      head :forbidden
    end
  end

  def publish
    @section = Section.find(params[:id])

    if current_user == @section.user
      @section.update(published: true)
      @section.create_section_activity # Создаем активность при публикации

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "section_#{@section.id}",
            partial: "sections/section",
            locals: { section: @section }
          )
        }
      end
    else
      head :forbidden
    end
  end

  private

  def set_section
    @section = Section.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:title, :position)
  end

  def authorize_user!
    unless current_user == @section.user
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.json { render json: { error: "Not authorized" }, status: :forbidden }
      end
    end
  end
end
