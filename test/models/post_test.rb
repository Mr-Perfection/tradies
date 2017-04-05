require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # This code is not idiomatically correct.
    @post = Post.new(subject: "Macbook Pro on sale!", price: 200, city: "Fremont", state: "California", content: "Lorem ipsum", user_id: @user.id)
  end

  test "should be valid" do
    assert @post.valid?
  end

  test "user id should be present" do
    @post.user_id = nil
    assert_not @post.valid?
  end

  test "subject should be present" do
    @post.subject = "   "
    assert_not @post.valid?
  end

  test "price should be present" do
    @post.price = nil
    assert_not @post.valid?
  end

  test "content should be present" do
    @post.content = "   "
    assert_not @post.valid?
  end

  test "content should be at most 140 characters" do
    @post.content = "a" * 141
    assert_not @post.valid?
  end

  test "order should be most recent first" do
    assert_equal posts(:most_recent), Post.first
  end
end
