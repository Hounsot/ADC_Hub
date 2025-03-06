class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section, only: [ :update ]
  before_action :authorize_user!, only: [ :update ]

  def update
    @section = Section.find(params[:id])
    @section.update(section_params)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "section_#{@section.id}",
          partial: "sections/section",
          locals: { section: @section }
        )
      }
    end
  end

  def edit
    @section = Section.find(params[:id])
    # Можно через обычное рендер:
    respond_to do |format|
      format.html # отрендерит app/views/sections/edit.html.erb
      format.turbo_stream # отрендерит app/views/sections/edit.turbo_stream.erb (если есть)
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
    params.require(:section).permit(:title, :position, cards_attributes: [ :id, :title, :content, :url, :size, :position, :_destroy ])
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
