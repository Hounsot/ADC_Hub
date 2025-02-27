class Vacancy < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  validates :title, :employment_type, presence: true
  after_create :create_vacancy_activity

  private

  def create_vacancy_activity
    Activity.create!(
      action: "vacancy_created",
      actor: self.user,
      subject: self
    )
  end
end
