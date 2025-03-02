class Card < ApplicationRecord
  belongs_to :section
  has_one_attached :image
  before_destroy :cleanup_activities

  private

  def cleanup_activities
    Activity.where(subject_type: "Card", subject_id: self.id).destroy_all
  end
end
