class Card < ApplicationRecord
  belongs_to :section
  belongs_to :user

  has_one_attached :image

  private
end
