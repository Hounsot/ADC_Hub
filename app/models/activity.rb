class Activity < ApplicationRecord
  belongs_to :actor, polymorphic: true, optional: true  # Who performed the action
  belongs_to :subject, polymorphic: true, optional: true, dependent: :destroy_async # What was acted upon

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
