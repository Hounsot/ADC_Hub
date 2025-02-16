class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_card, only: [ :edit, :update, :destroy, :update_size ]

  def new
    @card = @user.cards.new
  end

  def create
    @card = @user.cards.build(card_params)
    respond_to do |format|
      if @card.save
        format.html { redirect_to @user, notice: "Card created!" }

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
        format.html { redirect_to @user, alert: "Error creating card" }
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
      redirect_to @user, notice: "Card updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card = @user.cards.find(params[:id])
    @card.destroy
    redirect_to @user, notice: "Card deleted."
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_card
    @card = @user.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:card_type)
  end
end
