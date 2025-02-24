class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :vacancies
  has_many :sections, dependent: :destroy
  has_many :cards, through: :sections
  belongs_to :company, optional: true
  has_one_attached :avatar
  after_create :create_default_section

  def create_default_section
    sections.create!(
      title: "Место работы",
      position: 1
    ).tap do |section|
      section.cards.create!(
        card_type: "job",
        position: "My Position"
      )
    end
  end
end
