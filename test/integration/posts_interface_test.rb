require 'test_helper'

class PostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  test "post interface" do
    log_in_as(@user)
    get user_posts_path
    assert_select 'div.pagination'
    # Invalid submission
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This post really ties the room together"
    assert_difference 'Post.count', 1 do
      post posts_path, params: { post: { subject: "Homie", price: 4, content: "This post really ties the room together", city: "Torrance", state: "CA" } }
    end
    assert_redirected_to user_posts_path
    follow_redirect!
    assert_match "Homie", response.body
    #Delete post
    assert_select 'a', text: 'delete'
    first_post = @user.posts.paginate(page: 1).first
    assert_difference 'Post.count', -1 do
      delete post_path(first_post)
    end
    # Visit different user (no delete links)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
end
