class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, except: [ :index ]

  def show
    @sections = @user.sections.order(created_at: :desc)
    @section = @sections.first || @user.sections.create!(title: "My Projects") # fallback for new users
    end
  def index
    @users = User.all
  end
  def update
    if @user.update(user_params)
      @user.update(onboarding_completed: true)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "onboarding-popup",
              partial: "users/onboarding_success",
              locals: { user: @user }
            )
          ]
        end
        format.html do
          redirect_to user_path(@user), notice: "User profile updated!"
        end
      end
    else
      # Handle errors as usual...
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "onboarding-popup",
            partial: "users/onboarding_popup",
            locals: { user: @user }
          )
        end
        format.html do
          flash[:alert] = "Something went wrong."
          render :edit, status: :unprocessable_entity
        end
      end
    end
  end

  def update_name
    if @user.update(name: params[:user][:name])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("name-editor", partial: "users/name_editor", locals: { user: @user })
        end
        format.html { redirect_to @user, notice: "Name updated!" }
      end
    else
        Rails.logger.debug "User update errors: #{@user.errors.full_messages}"
        render :show, status: :unprocessable_entity
    end
  end

  def update_job
    if @user.update(position: params[:user][:position])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("job-edit", partial: "cards/job_card", locals: { user: @user })
        end
        format.html { redirect_to @user, notice: "Name updated!" }
      end
    else
        Rails.logger.debug "User update errors: #{@user.errors.full_messages}"
        render :show, status: :unprocessable_entity
    end
  end

  def update_bio
    if @user.update(user_params)
      redirect_to @user, notice: "Profile updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end


  def upload_avatar
    # For updating the avatar, use the currently logged-in user.
    @user = current_user

    if @user.update(user_params)
      redirect_to @user, notice: "Profile picture updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end
  def user_params
    params.require(:user).permit(:name, :surname, :email, :avatar, :portfolio_link, :onboarding_completed)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
