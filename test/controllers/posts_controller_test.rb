require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  def setup
  	@user       = users(:michael)
  	@post 		= posts(:orange)
  	@other_user = users(:archer)
  end
  test "should get show" do
    log_in_as(@user)
    get post_path(@post)
    assert_response :success
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Post.count' do
      post posts_path, params: { post: { subject: "Homie", price: 4, content: "Lorem ipsum", city: "Torrance", state: "CA" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Post.count' do
      delete post_path(@post)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong post" do
    log_in_as(users(:michael))
    post = posts(:ants)
    assert_no_difference 'Post.count' do
      delete post_path(post)
    end
    assert_redirected_to root_url
  end
  
end
