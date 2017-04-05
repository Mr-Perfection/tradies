class MessagesController < ApplicationController
  before_action :logged_in_user
  before_action :check_recipient_session, only: [:create]
  before_action :recipient_present, only: [:new]
  def new
    @message_title = "Message " + @chosen_recipient.name
    # puts "message title:"
    # puts @message_title
    # puts @chosen_recipient.email
  end
  def create
    chosen_recipient = User.find(session[:message_recipient])
    conversation = current_user.send_message(chosen_recipient, params[:message][:body], params[:message][:subject]).conversation
    puts "whats inside? "
    puts conversation
    puts chosen_recipient.name
    current_user.send_new_message(chosen_recipient, params[:message][:subject])
    flash[:success] = "Message has been sent!"
    session.delete(:message_recipient)
    redirect_to conversation_path(conversation)
  end
  private
  def logged_in_user
      redirect_to(login_path) unless logged_in?
  end
  def check_recipient_session
      redirect_to conversations_path if session[:message_recipient].nil?
  end
  def recipient_present
      post = Post.find(params[:id])
      @chosen_recipient = post.owner
      if @chosen_recipient.present? && post.check_interested_user(current_user)
        @message_objective = "Interested in your " + post.subject
        save_recipient(@chosen_recipient.id) 
      else
        redirect_to request.referrer || root_url
      end
  end
end
