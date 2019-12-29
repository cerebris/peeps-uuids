class ContactResource < JSONAPI::Resource
  caching

  attributes :first_name, :last_name, :full_name, :nick_name, :email, :twitter

  has_many :phone_numbers

  def full_name
    "#{@model.first_name} #{@model.last_name}"
  end

  def fetchable_fields
    if context.fetch(:guest, true)
      super - [:email]
    else
      super
    end
  end

  def self.creatable_fields(context)
    fields = super  + [:id]
    if context.fetch(:guest, true)
      fields - [:email]
    else
      fields
    end
  end
end
