# app/controllers/wrapped_controller.rb
class WrappedsController < ApplicationController
  before_action :authenticate_user!  # if you have Devise or any auth

  def show
    # Renders the "wrapped" page (perhaps with a button that triggers "generate")
  end

  def generate
    # Assume the user model has `portfolio_link` which points to the JSON
    portfolio_link = current_user.portfolio_link
    json_data = fetch_portfolio_json(portfolio_link)

    if json_data
      # Parse the JSON
      @insights = analyze_portfolio_data(json_data)
      # Render partial or JSON with the insights
      respond_to do |format|
        format.html { render :wrapped }  # Or some partial
        format.json { render json: { insights: @insights } }
      end
    else
      # Handle error
      flash[:alert] = "Could not fetch your portfolio data"
      redirect_to wrapped_path
    end
  end

  private

  # Simple net/http fetch. Alternatively, use httparty or faraday for a more robust approach
  def fetch_portfolio_json(url)
    require "net/http"
    require "json"
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    Rails.logger.error "Error fetching portfolio JSON: #{e.message}"
    nil
  end

  # This is a simple method that calculates your “wrapped” style metrics
  def analyze_portfolio_data(json)
    projects = json["projects"] || []

    total_projects = projects.size
    total_marks = projects.map { |p| p["totalMark"] }.compact
    average_mark = total_marks.any? ? (total_marks.sum.to_f / total_marks.size).round(2) : 0

    ratings = projects.map { |p| p["rating"] }.compact
    average_rating = ratings.any? ? (ratings.sum.to_f / ratings.size).round(2) : 0

    # Identify top collaborators
    # First, figure out how to identify the main user’s name? Possibly from your own DB or from the JSON
    main_user_identifier = current_user.email
    collaborators_count = Hash.new(0)
    projects.each do |p|
      (p["authors"] || []).each do |author|
        # skip if it's the current user
        next if author["name"] == main_user_identifier
        collaborators_count[author["name"]] += 1
      end
    end

    # Sort by occurrence
    top_collaborators = collaborators_count.sort_by { |_name, count| -count }.to_h

    # Example highest & lowest totalMark
    highest_mark_project = projects.max_by { |p| p["totalMark"] || 0 }
    lowest_mark_project  = projects.min_by { |p| p["totalMark"] || 9999 }

    # Return a structured hash for your view or JSON
    {
      total_projects: total_projects,
      average_mark: average_mark,
      average_rating: average_rating,
      top_collaborators: top_collaborators,
      highest_mark_project: highest_mark_project,
      lowest_mark_project: lowest_mark_project
    }
  end
end
