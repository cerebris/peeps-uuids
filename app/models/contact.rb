class Contact < ApplicationRecord
  has_many :phone_numbers

  ### Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
end
