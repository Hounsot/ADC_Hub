class Reaction < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  # Define constants for the reaction emoji types
  HEART = "❤️"
  THUMBS_UP = "👍"
  MIND_BLOWN = "🤯"
  STAR_STRUCK = "🤩"

  EMOJI_TYPES = [ HEART, THUMBS_UP, MIND_BLOWN, STAR_STRUCK ].freeze

  validates :emoji_type, presence: true, inclusion: { in: EMOJI_TYPES }

  # Ensure a user can only have one reaction per activity
  validates :user_id, uniqueness: { scope: :activity_id }

  # Helper scopes to find reactions by type
  scope :hearts, -> { where(emoji_type: HEART) }
  scope :thumbs_up, -> { where(emoji_type: THUMBS_UP) }
  scope :mind_blown, -> { where(emoji_type: MIND_BLOWN) }
  scope :star_struck, -> { where(emoji_type: STAR_STRUCK) }
end
