require "test_helper"

class DeviseAuthFlowsTest < ActionDispatch::IntegrationTest
  test "sign in form uses a full-page request" do
    get new_user_session_path

    assert_response :success
    assert_select "form.auth-form[data-turbo=false]"
  end

  test "sign up form uses a full-page request" do
    get new_user_registration_path

    assert_response :success
    assert_select "form.auth-form[data-turbo=false]"
  end
end
