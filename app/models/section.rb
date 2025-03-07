class Section < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy
  accepts_nested_attributes_for :cards, allow_destroy: true

  validates :title, presence: true
  after_create :create_section_activity
  before_destroy :cleanup_activities

  def create_section_activity
    Activity.create!(
      action: "section_created",
      actor: self.user,
      subject: self
    )
  end

  private

  def cleanup_activities
    Activity.where(subject_type: "Section", subject_id: self.id).destroy_all
  end
end
