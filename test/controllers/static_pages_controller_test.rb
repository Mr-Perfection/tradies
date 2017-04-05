require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = "Tradies"
  end

  test "should get root" do
    get root_path
    assert_response :success
  end
  
  test "should get home" do
    get home_path
    assert_select "title", "Home | #{@base_title}"
    assert_response :success
  end

  test "should get help" do
    get help_path
    assert_select "title", "Help | #{@base_title}"
    assert_response :success
  end

  test "should get contact" do
    get contact_path
    assert_select "title", "Contact | #{@base_title}"
    assert_response :success
  end

end
