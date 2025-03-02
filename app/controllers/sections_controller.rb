class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section, only: [ :update ]
  before_action :authorize_user!, only: [ :update ]

  def update
    if @section.update(section_params)
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { message: "Section updated successfully" } }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(
          "section_#{@section.id}_title",
          partial: "sections/section_title",
          locals: { section: @section }
        ) }
        format.json { render json: { errors: @section.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @section = Section.find(params[:id])

    if current_user == @section.user
      @section.destroy
      current_user.sections.where("position > ?", @section.position).
                   update_all("position = position - 1")
      respond_to do |format|
        format.html { redirect_to user_path(@section.user), notice: "Section was successfully deleted." }
        format.turbo_stream { render turbo_stream: turbo_stream.remove("section_#{@section.id}") }
      end
    else
      head :forbidden
    end
  end

  def create
    # Get the position from params
    position = params[:position].to_i

    # Make room for the new section by incrementing positions of existing sections
    current_user.sections.where("position >= ?", position).
                 update_all("position = position + 1")

    # Create the new section with the specified position
    @section = current_user.sections.create!(
      title: "Новая секция",
      position: position
    )

    respond_to do |format|
      format.html { redirect_to user_path(current_user) }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "section_create_button_#{position}",
            partial: "sections/section",
            locals: { section: @section }
          ),
          turbo_stream.after(
            "section_#{@section.id}",
            partial: "sections/section_create_button",
            locals: { user: current_user, position: position }
          )
        ]
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
