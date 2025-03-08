class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity

  def create
    @user_reaction = @activity.user_reaction(current_user)
    if @user_reaction&.emoji_type == reaction_params[:emoji_type]
      @user_reaction.destroy
    else
      if @user_reaction
        @user_reaction.update(emoji_type: reaction_params[:emoji_type])
      else
        @activity.reactions.create(user: current_user, emoji_type: reaction_params[:emoji_type])
      end
    end
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: activities_path }
    end
  end

  private

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end

  def reaction_params
    params.require(:reaction).permit(:emoji_type)
  end
end
