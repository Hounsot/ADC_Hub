class Section < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy

  validates :title, presence: true
  after_create :create_section_activity

  private

  def create_section_activity
    Activity.create!(
      action: "section_created",
      actor: self.user,
      subject: self
    )
  end
end
