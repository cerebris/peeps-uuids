require 'test_helper'

class ContactResourceTest < ActiveSupport::TestCase
  def test_full_name
    context = {}
    contact_resource = ContactResource.new(Contact.new(first_name: "Joe", last_name: "Smith"), context)
    assert_equal "Joe Smith", contact_resource.full_name
  end

  def test_email_not_visible_to_guest
    context = { guest: true }
    contact_resource = ContactResource.new(Contact.new(first_name: "Joe", last_name: "Smith", email: "joe@example.com"), context)
    refute_includes contact_resource.fetchable_fields, :email
  end

  def test_email_visible_to_non_guests
    context = { guest: false }
    contact_resource = ContactResource.new(Contact.new(first_name: "Joe", last_name: "Smith", email: "joe@example.com"), context)
    assert_includes contact_resource.fetchable_fields, :email
  end
end
