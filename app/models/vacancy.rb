class Vacancy < ApplicationRecord
  belongs_to :company
  belongs_to :user

  validates :title, :description, :employment_type, presence: true
end
