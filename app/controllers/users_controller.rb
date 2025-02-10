class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show ]  # We use this for the show action

  def show
  end
  def index
    @users = User.all.order(:id)
  end

  def upload_avatar
    # For updating the avatar, use the currently logged-in user.
    @user = current_user

    if @user.update(user_avatar_params)
      redirect_to @user, notice: "Profile picture updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:name, :surname, :email, :avatar)
  end

  def user_avatar_params
    params.require(:user).permit(:avatar)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
