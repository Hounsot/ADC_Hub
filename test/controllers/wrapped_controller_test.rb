require "test_helper"

class WrappedControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get wrapped_show_url
    assert_response :success
  end

  test "should get generate" do
    get wrapped_generate_url
    assert_response :success
  end
end
