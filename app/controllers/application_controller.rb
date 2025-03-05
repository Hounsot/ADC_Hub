class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Action to clean up unused blobs
  def cleanup_blob
    if params[:blob_id].present?
      begin
        # Find the blob by its signed ID
        blob = ActiveStorage::Blob.find_signed(params[:blob_id])

        if blob
          # Remove the blob from the session if it exists
          if session[:temp_image_blobs]
            session[:temp_image_blobs].each do |section_id, blobs|
              blobs.delete(params[:blob_id]) if blobs.include?(params[:blob_id])
            end
          end

          # Delete the blob
          blob.purge

          render json: { success: true }, status: :ok
        else
          render json: { error: "Blob not found" }, status: :not_found
        end
      rescue => e
        Rails.logger.error "Error cleaning up blob: #{e.message}"
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: "No blob ID provided" }, status: :bad_request
    end
  end
end
