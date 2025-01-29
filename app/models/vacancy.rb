class Vacancy < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  validates :title, :employment_type, presence: true
end
