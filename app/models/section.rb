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
      cards_attributes.each do |card_id, card_attrs|
        card = self.cards.find_by(id: card_id)
        card.update(card_attrs) if card.present?
      end

      # Reorder all cards to ensure continuous positions
      self.cards.order(:position).each.with_index(1) do |card, index|
        card.update_column(:position, index)
      end

      true
    end
  rescue => e
    Rails.logger.error("Error batch saving cards: #{e.message}")
    false
  end

  private

  def cleanup_activities
    Activity.where(subject_type: "Section", subject_id: self.id).destroy_all
  end
end
