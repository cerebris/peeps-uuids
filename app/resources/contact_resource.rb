class ContactResource < JSONAPI::Resource
  caching

  attributes :first_name, :last_name, :email, :twitter
  has_many :phone_numbers

  filter(
    :last_name,
    apply: ->(records, values, _options) {
      records.where(last_name: values).distinct
    }
  )

  def self.creatable_fields(context)
    super + [:id]
  end
end
