require "test_helper"

class FormsTest < CapybaraTest
  include TestSessionHelpers

  fixtures :cf0925s, :forms

  test "simple get all forms for user" do
    fill_in_login(users(:forms))
    visit forms_path
    assert_selector "tr.form-row", count: 1
  end
end
