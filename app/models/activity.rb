class Activity < ApplicationRecord
  belongs_to :actor, polymorphic: true, optional: true  # Who performed the action
  belongs_to :subject, polymorphic: true, optional: true, dependent: :destroy_async # What was acted upon

  has_many :reactions, dependent: :destroy

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }

  # Helper methods to get reaction counts by type
  def heart_count
    reactions.hearts.count
  end

  def thumbs_up_count
    reactions.thumbs_up.count
  end

  def mind_blown_count
    reactions.mind_blown.count
  end

  def star_struck_count
    reactions.star_struck.count
  end

  # Get the reaction of a specific user for this activity (if any)
  def user_reaction(user)
    reactions.find_by(user: user)
  end

  # Check if a user has reacted with a specific emoji
  def user_reacted_with?(user, emoji_type)
    reactions.exists?(user: user, emoji_type: emoji_type)
  end
end
