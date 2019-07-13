class ContactResource < JSONAPI::Resource
  caching

  attributes :first_name, :last_name, :email, :twitter
  has_many :phone_numbers

  def self.creatable_fields(context)
    super + [:id]
  end
end
