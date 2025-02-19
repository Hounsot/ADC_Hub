class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :vacancies
  has_many :cards, dependent: :destroy
  belongs_to :company, optional: true
  has_one_attached :avatar
  after_create :create_default_cards

  def create_default_cards
    cards.create!(
      card_type: "job",
      position: "Мое место работы"
    )
    cards.create!(
      card_type: "divider",
      title: "Мое место работы"
    )
  end
end
