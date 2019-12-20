require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase
  def test_valid
    assert phone_numbers(:fred_tester_home).valid?
    refute PhoneNumber.new.valid?
  end

  def test_phone_number_format
    pn = phone_numbers(:fred_tester_home)
    assert pn.valid?
    pn.phone_number = "603"
    refute pn.valid?
    assert_equal "bad format", pn.errors.messages[:phone_number][0]
    pn.phone_number = "(603) 555-1212"
    assert pn.valid?
  end

  # Test public model methods and additional validations
end
