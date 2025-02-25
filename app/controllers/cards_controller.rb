class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_section
  before_action :set_card, only: [ :edit, :update, :destroy, :update_size ]

  def new
    @card = @section.cards.new
  end

  def create
    @card = @section.cards.build(card_params)

    # Set the position to be the last in this section
    @card.position = (@section.cards.maximum(:position) || 0) + 1

    if @card.card_type == "text" && @card.content.blank?
      @card.content = "Нажмите для редактирования"
    end

    respond_to do |format|
      if @card.save
        # Reorder all cards in this section to ensure continuous positions
        @section.cards.order(:position).each.with_index(1) do |card, index|
          card.update_column(:position, index)
        end

        format.html { redirect_to @section.user, notice: "Card created!" }

        # If you want to use Turbo (Rails 7+ or 8+), you can render a turbo_stream
        format.turbo_stream
        # Or if you're using a Stimulus fetch approach, you might return partial HTML:
        format.json do
          # We'll render the newly created card partial as HTML
          card_html = render_to_string(
            partial: "cards/#{@card.card_type}_card",
            locals: { card: @card },
            formats: [ :html ]
          )
          render json: { html: card_html }
        end
      else
        format.html { redirect_to @section.user, alert: "Error creating card" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
        format.json { render json: { error: @card.errors.full_messages }, status: :unprocessable_entity }
      end
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
            turbo_stream.remove("card_#{@card.id}"),
            turbo_stream.append(@section, partial: "sections/add_card_button", locals: { section: @section })
          ]
        else
          render turbo_stream: turbo_stream.remove("card_#{@card.id}")
        end
      end
      format.html { redirect_to user_path(@section.user), notice: "Card deleted successfully." }
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
    params.require(:card).permit(:card_type, :image, :size, :title, :content)
  end
end
