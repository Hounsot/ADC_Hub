class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section
  before_action :set_card, only: [ :edit, :update, :destroy, :update_size ]
  after_action :cleanup_temp_cards, only: [ :prepare_image ]

  def new
    @card = @section.cards.new(card_type: params[:card_type])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_card_form_#{@section.id}",
          partial: "cards/#{params[:card_type]}_form",
          locals: { section: @section, card: @card }
        )
      end
    end
  end

  # New action for handling image uploads
  def prepare_image
    @card = @section.cards.new(card_type: "image")

    Rails.logger.debug "prepare_image params: #{params.inspect}"

    if params[:image].present?
      # Set the current user as the card owner (required for validation)
      @card.user = current_user

      # Create a blob key for the image without saving the card
      blob = ActiveStorage::Blob.create_and_upload!(
        io: params[:image],
        filename: params[:image].original_filename,
        content_type: params[:image].content_type
      )

      # Store the blob key in the session for later retrieval
      session[:temp_image_blobs] ||= {}
      session[:temp_image_blobs][@section.id.to_s] ||= []
      session[:temp_image_blobs][@section.id.to_s] << blob.signed_id

      # Attach the blob to the card for preview purposes only (without saving)
      @card.image = blob

      begin
        respond_to do |format|
          format.json do
            form_html = render_to_string(
              partial: "cards/image_form",
              locals: { section: @section, card: @card, temp_blob_id: blob.signed_id },
              formats: [ :html ]
            )
            render json: { html: form_html, blob_id: blob.signed_id }
          end
        end
      rescue => e
        Rails.logger.error "Error in prepare_image: #{e.message}"
        render json: { error: "Error preparing image: #{e.message}" }, status: :unprocessable_entity
      end
    else
      render json: { error: "No image provided" }, status: :unprocessable_entity
    end
  end

  def create
    # Create a new card
    @card = @section.cards.build(card_params.except(:temp_blob_id, :image))
    @card.user = current_user
    @card.position = (@section.cards.maximum(:position) || 0) + 1

    # Handle image attachment from temporary blob if provided
    if params[:card][:temp_blob_id].present?
      begin
        # Find the blob by its signed ID
        blob = ActiveStorage::Blob.find_signed(params[:card][:temp_blob_id])

        if blob
          # Attach the blob to the new card
          @card.image.attach(blob.signed_id)

          # Remove this blob from the session to prevent reuse
          if session[:temp_image_blobs] && session[:temp_image_blobs][@section.id.to_s]
            session[:temp_image_blobs][@section.id.to_s].delete(params[:card][:temp_blob_id])
          end
        else
          Rails.logger.error "Could not find blob with ID: #{params[:card][:temp_blob_id]}"
        end
      rescue => e
        Rails.logger.error "Error attaching blob: #{e.message}"
      end
    # Handle direct image upload if provided
    elsif params[:card][:image].present?
      @card.image.attach(params[:card][:image])
    end

    case @card.card_type
    when "link"
      render turbo_stream: turbo_stream.replace(
        "new_link_card_form",
        partial: "cards/link_form",
        locals: { section: @section }
      ) and return unless params[:card][:url].present?
    when "text"
      @card.content = "Нажмите для редактирования" if @card.content.blank?
    end

    if @card.save
      # Create activity for this card
      Activity.create!(
        action: "card_created",
        actor: current_user,
        subject: @card
      )

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("section_cards_#{@section.id}", partial: "cards/#{@card.card_type}_card", locals: { card: @card }),
            turbo_stream.replace("new_card_form_#{@section.id}", partial: "cards/add_card", locals: { section: @section })
          ]
        end
        format.html { redirect_to user_path(@section.user) }
      end
    else
      Rails.logger.error "Card save errors: #{@card.errors.full_messages}"
      render turbo_stream: turbo_stream.replace(
        "new_#{@card.card_type}_card_form_#{@section.id}",
        partial: "cards/#{@card.card_type}_form",
        locals: { section: @section, card: @card }
      ), status: :unprocessable_entity
    end
  end

  def update_size
    new_size = params[:size] # expect "square" or "medium"
    card_type = @card.card_type # e.g. "image"
    partial_name = "cards/#{card_type}_card"

    if @card.update(size: new_size)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@card, partial: partial_name, locals: { card: @card })
        end
        format.html { redirect_to user_path(@card.user), notice: "Card size updated." }
      end
    else
      # Handle error (you can add error feedback here)
      redirect_to user_path(@card.user), alert: "There was a problem updating the card size."
    end
  end


  def edit
  end

  def update
    if @card.update(card_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @card,
            partial: "cards/#{@card.card_type}_card",
            locals: { card: @card }
          )
        end
        format.json { render json: { message: "Card updated successfully" } }
      end
    end
  end

  def destroy
    @card = @section.cards.find(params[:id])
    @card.destroy

    respond_to do |format|
      format.turbo_stream do
        if @section.cards.empty? && current_user == @section.user
          render turbo_stream: [
            turbo_stream.remove("card_#{@card.id}")
          ]
        else
          render turbo_stream: turbo_stream.remove("card_#{@card.id}")
        end
      end
      format.html { redirect_to user_path(@section.user), notice: "Card deleted successfully." }
    end
  end

  def index
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_card_form_#{@section.id}",
          partial: "cards/link_form",
          locals: { section: @section }
        )
      end
    end
  end

  private

  def set_section
    @section = Section.find(params[:section_id])
  end

  def set_card
    @card = @section.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:id, :card_type, :image, :size, :title, :content, :url)
  end

  # Clean up temporary cards
  def cleanup_temp_cards
    # Clean up temporary cards that are older than 24 hours
    # This prevents accumulation of abandoned temp cards
    section_id = @section.id if @section

    if section_id
      # Only clean up old temporary cards
      cutoff_time = 24.hours.ago
      temp_cards = Card.where(section_id: section_id, position: -1)
                       .where("created_at < ?", cutoff_time)

      if temp_cards.any?
        Rails.logger.info("Cleaning up #{temp_cards.count} old temporary cards")
        temp_cards.destroy_all
      end
    end
  end
end
