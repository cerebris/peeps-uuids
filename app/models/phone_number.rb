class PhoneNumber < ApplicationRecord
  belongs_to :contact, optional: true
  validates :phone_number, format: { with: /(?:\+?\d{1,3}\s*-?)?\(?(?:\d{3})?\)?[- ]?\d{3}[- ]?\d{4}\z/, message: "bad format" }
end
