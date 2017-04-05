class ConversationsController < ApplicationController
  before_action :logged_in_user
  before_action :beautiful_search_url
  before_action :get_mailbox
  before_action :get_conversation, except: [:index, :empty_trash]
  before_action :get_box, only: [:index]
  
  def index
    session.delete(:unread_messages)
    save_unread_messages(current_user.mailbox.inbox({:read => false}).count)
    if @box.eql? "inbox"
      conversations = @mailbox.inbox
    elsif @box.eql? "sent"
      conversations = @mailbox.sentbox
    else
      conversations = @mailbox.trash
    end
    # puts "yolo sent::::::::"
    # puts conversations
    @conversations = conversations.paginate(page: params[:page], per_page: 10)
  end

  def show
    @conversation.mark_as_read(current_user)
    save_unread_messages(current_user.mailbox.inbox({:read => false}).count)
  end

  def mark_as_read
    # @conversation.mark_as_read(current_user)
    # save_unread_messages(current_user.mailbox.inbox({:read => false}).count)
    # flash[:success] = 'The conversation was marked as read.'
    # redirect_to conversations_path
  end

  def reply
    # send reply notification via email
    if @conversation.last_message.sender != current_user
      current_user.send_new_reply(@conversation.last_message.sender, @conversation.subject) 
    end
    current_user.reply_to_conversation(@conversation, params[:body])
    flash[:success] = 'Reply sent'
    redirect_to conversation_path(@conversation)
  end

  def destroy
    @conversation.move_to_trash(current_user)
    flash[:success] = 'The conversation was moved to trash.'
    redirect_to conversations_path
  end

  def restore
    @conversation.untrash(current_user)
    flash[:success] = 'The conversation was restored.'
    redirect_to conversations_path
  end

  def empty_trash
    @mailbox.trash.each do |conversation|
      conversation.receipts_for(current_user).update_all(deleted: true)
    end
    flash[:success] = 'Your trash was cleaned!'
    redirect_to conversations_path
  end

  
  private
  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def get_conversation
    @conversation ||= @mailbox.conversations.find(params[:id])
  end

  def get_box
    if params[:box].blank? or !["inbox","sent","trash", "read"].include?(params[:box])
      params[:box] = 'inbox'
    end
    @box = params[:box]
  end
  def logged_in_user
      redirect_to(login_path) unless logged_in?
  end
end
