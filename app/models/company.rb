class Company < ApplicationRecord
  has_many :vacancies
  has_many :users
end
