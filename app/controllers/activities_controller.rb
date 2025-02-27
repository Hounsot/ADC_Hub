# app/controllers/activities_controller.rb
class ActivitiesController < ApplicationController
  def index
    @activities = Activity.recent.includes(:actor, :subject).page(params[:page]).per(20)
  end
end
