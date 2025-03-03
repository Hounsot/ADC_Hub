# app/controllers/activities_controller.rb
class ActivitiesController < ApplicationController
  def index
    @activities = Activity.recent.includes(:actor, :subject).page(params[:page]).per(20)

    if request.xhr?
      begin
        # Render each activity with its appropriate partial
        html = @activities.map do |activity|
          render_to_string(
            partial: "activities/types/#{activity.action}",
            locals: { activity: activity }
          )
        end.join

        render plain: html
      rescue => e
        Rails.logger.error("Error in infinite scroll: #{e.message}")
        render plain: "", status: :ok  # Return empty but don't 500
      end
    end
  end
end
