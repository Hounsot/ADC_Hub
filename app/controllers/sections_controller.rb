class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section, only: [ :update, :batch_update ]
  before_action :authorize_user!, only: [ :update, :batch_update ]

  def update
  end

  # Batch update all cards in a section along with the section itself
  def batch_update
    # First update the section attributes if any are provided
    section_updated = true
    if section_params.present?
      section_updated = @section.update(section_params)
    end

    # Then batch update all the cards
    cards_updated = true
    if params[:cards].present?
      cards_updated = @section.batch_save_cards(params[:cards])
    end

    respond_to do |format|
      if section_updated && cards_updated
        format.html { redirect_to user_path(@section.user), notice: "Section and cards updated successfully." }
        format.json { render json: { success: true, message: "Section and cards updated successfully." } }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@section),
            partial: "sections/section",
            locals: { section: @section }
          )
        end
      else
        format.html { redirect_to user_path(@section.user), alert: "Error updating section or cards." }
        format.json { render json: { success: false, error: "Error updating section or cards." }, status: :unprocessable_entity }
      end
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
