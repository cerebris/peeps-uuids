class PhoneNumberResource < JSONAPI::Resource
  attributes :name, :phone_number
  has_one :contact

  filter :contact
  
  def self.creatable_fields(context)
    super + [:id]
  end
end
