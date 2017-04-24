class PhoneNumber < ApplicationRecord
  belongs_to :contact, optional: true
end
