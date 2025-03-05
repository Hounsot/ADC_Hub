class Section < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy

  validates :title, presence: true

  before_destroy :cleanup_activities

  def create_section_activity
    Activity.create!(
      action: "section_created",
      actor: self.user,
      subject: self
    )
  end

  # Save all cards in this section in a single transaction
  def batch_save_cards(cards_attributes)
    transaction do
      Rails.logger.info("Starting batch save for cards: #{cards_attributes.keys.join(', ')}")

      cards_attributes.each do |card_id, card_attrs|
        Rails.logger.info("Processing card #{card_id} with attributes: #{card_attrs.inspect}")
        card = self.cards.find_by(id: card_id)

        if card.present?
          begin
            # Convert the attributes to a simple hash with indifferent access
            attrs = {}

            # Handle different parameter formats
            if card_attrs.is_a?(ActionController::Parameters)
              attrs = card_attrs.permit(:title, :content, :url).to_h
            else
              # For regular hash, only copy permitted attributes
              attrs = {}.with_indifferent_access
              attrs[:title] = card_attrs[:title] || card_attrs["title"] if card_attrs.key?(:title) || card_attrs.key?("title")
              attrs[:content] = card_attrs[:content] || card_attrs["content"] if card_attrs.key?(:content) || card_attrs.key?("content")
              attrs[:url] = card_attrs[:url] || card_attrs["url"] if card_attrs.key?(:url) || card_attrs.key?("url")
            end

            # Only update with attributes that are present
            update_attrs = attrs.select { |_, v| v.present? }

            if update_attrs.present?
              Rails.logger.info("Updating card #{card_id} with: #{update_attrs.inspect}")
              card.update!(update_attrs) # Use update! to raise exceptions
            else
              Rails.logger.info("No attributes to update for card #{card_id}")
            end

            # If this is a temporary card (position = -1), mark it for proper positioning
            if card.position == -1
              card.update!(position: 0) # We'll reorder all cards below
            end
          rescue => e
            Rails.logger.error("Error updating card #{card_id}: #{e.message}")
            Rails.logger.error(e.backtrace.join("\n"))
            raise e # re-raise to roll back the transaction
          end
        else
          Rails.logger.warn("Card #{card_id} not found in section #{self.id}")
        end
      end

      # Also update any temporary cards not explicitly included in the cards_attributes
      # This ensures all temporary cards get proper positions when saving all
      self.cards.where(position: -1).update_all(position: 0)

      # Reorder all cards to ensure continuous positions
      self.cards.order(:position).each.with_index(1) do |card, index|
        card.update_column(:position, index)
      end

      return true
    end
  rescue => e
    Rails.logger.error("Error batch saving cards: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    false
  end

  private

  def cleanup_activities
    Activity.where(subject_type: "Section", subject_id: self.id).destroy_all
  end
end
