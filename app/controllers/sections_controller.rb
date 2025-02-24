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
      respond_to do |format|
        format.html { redirect_to user_path(@section.user), notice: "Section was successfully deleted." }
        format.turbo_stream { render turbo_stream: turbo_stream.remove("section_#{@section.id}") }
      end
    else
      head :forbidden
    end
  end

  def create
    @section = current_user.sections.new(section_params)

    if @section.save
      # Reorder all sections to ensure continuous positions
      current_user.sections
                 .order(:position)
                 .each.with_index(1) do |section, index|
        section.update_column(:position, index)
      end

      respond_to do |format|
        format.html { redirect_to user_path(@section.user) }
        format.turbo_stream {
          Rails.logger.info "Rendering turbo stream for section #{@section.id}"
          render turbo_stream: [
            turbo_stream.before("section_create_button_#{@section.position}",
              partial: "sections/section",
              locals: { section: @section }
            )
          ]
        }
        format.json {
          Rails.logger.info "Rendering JSON for section #{@section.id}"
          render json: {
            success: true,
            message: "Section created successfully"
          }
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to user_path(@section.user), alert: "Error creating section" }
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("flash", "Error creating section")
        }
        format.json { render json: { error: @section.errors.full_messages }, status: :unprocessable_entity }
      end
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
