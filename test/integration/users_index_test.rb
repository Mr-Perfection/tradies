require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @nonadmin = users(:archer)
  end

  test "index including pagination with admin access" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
  test "index including pagination with non-admin access" do
    log_in_as(@nonadmin)
    get users_path
    assert_redirected_to user_path(@nonadmin)
    # assert_select 'div.pagination'
    # User.paginate(page: 1).each do |user|
    #   assert_select 'a[href=?]', user_path(user), text: user.name
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
  end
end
