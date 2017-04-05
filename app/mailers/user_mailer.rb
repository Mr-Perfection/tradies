class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #

  #notify the user that recieves in-app reply from others
  def new_reply_from_user(to_id, from_id, subject)
    @user = User.find(to_id)
    @sender = User.find(from_id)
    subj = "Tradies new reply: " + subject
    @subject = subject
    # puts "yoloo"
    # puts to
    # puts to.name
    mail to: @user.email, subject: subj
  end

  #notify the user that recieves in-app message from others
  def new_message_from_user(to_id, from_id, subject)
    @user = User.find(to_id)
    @sender = User.find(from_id)
    subj = "Tradies new message: " + subject
    # puts "yoloo"
    # puts to
    # puts to.name
    mail to: @user.email, subject: subj
  end
  def account_activation(user_id, activation_token)
    @user = User.find(user_id)
    @activation_token = activation_token
    mail to: @user.email, subject: "Tradies: Account Activation"
  end
  def review_activation(reviewer_id , reviewee_id, review_id, post_id, activation_token)
    @reviewer = User.find(reviewer_id)
    @reviewee = User.find(reviewee_id)
    @review = Review.find(review_id)
    @activation_token = activation_token
    # puts "#{@activation_token} is present"
    @post = Post.find(post_id)
    mail to: @reviewer.email, subject: "Tradies: Leave a review for #{@reviewee.name}"
  end
  #send email that there is interested user for your post.
  # def interested_user_notification(post_id)
  #   @post = Post.find(post_id)
  #   @user = post.user
  #   mail to: @post.user_email, subject: "Tradies: Someone is interested in your #{post.subject} post on Tradies!"
  # end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user_id, token)
    @user = User.find(user_id)
    puts "#{@user} exists?"
    puts "#{token} exists?"
    @reset_token = token
    mail to: @user.email, subject: "Tradies: Password Reset"
  end
end
