class UsersController < ApplicationController
  require 'will_paginate/array'
  before_action :set_user,              only: [:edit, :update, :destroy, :oauth]
  before_action :set_user_in_posts,     only: [:posts]
  before_action :logged_in_user,        only: [:edit, :update, :index, :show]
  before_action :correct_user,          only: [:edit, :update, :oauth, :posts]
  before_action :not_found,             only: [:index]
  # before_action :admin_user,            only: [ :index]
  before_action :admin_or_correct_user, only: [:destroy]
  before_action :beautiful_search_url
  def index
    return redirect_to user_path(current_user) if !current_user.admin   #return if it is not admin
    @users = User.where(activated: true).paginate(page: params[:page], per_page: 15)
    @inactive_users = User.where(activated: false).paginate(page: params[:page], per_page: 15)
    # @user = User.find(params[:id])
  end

  def posts
    session[:sell_for_you] = 1
    buyer_user_posts = Post.where(sold_user_id: current_user.id)
    # array of post_ids for interested posts
    interested_post_ids = current_user.interested_users_lists.pluck(:post_id)
    interested_user_posts = []
    interested_post_ids.each { |x| 
      x = Post.find(x)
      interested_user_posts.push(x) if (x.sold == false)
    }
    # puts("interested posts.. #{interested_user_posts}") 
    buyer_user_posts_sold = buyer_user_posts.where(sold: true)
    buyer_user_posts_not_sold = buyer_user_posts.where(sold: false)
    
    @interested_user_posts_size = interested_user_posts.size
    # puts("interested posts size.. #{@interested_user_posts_size}")
    @bought_user_posts_size = buyer_user_posts_sold.size
    @user_posts_size = @user.posts_size
    @redirect_uri = url_for(:controller => 'users', :action => 'oauth', :id => current_user.id, :host => request.host_with_port)
    @interested_user_posts = interested_user_posts.paginate(page: params[:page], per_page: 3) 
    @bought_user_posts = buyer_user_posts_sold.paginate(page: params[:page], per_page: 3) 
    @user_posts = @user.posts.paginate(page: params[:page], per_page: 3)
    @post = @user.posts.includes(:post_attachments).build
  end

  def new
  	@user = User.new
    @user.description = "Hello, I am new to Tradies!:)"
  end


  def show
  	@user = User.includes(:reviews, posts: [:post_attachments]).find(params[:id])
    redirect_to root_path unless @user.activated?
    user_posts = @user.posts
    if user_posts.blank?
      @sold_user_posts_size = 0
      @available_user_posts_size = 0
    else
      sold_posts = user_posts.where(sold: true)
      available_posts = user_posts.where(sold: false)
      @sold_user_posts_size = sold_posts.length
      @sold_user_posts = sold_posts.paginate(page: params[:page], per_page: 3)
      @available_user_posts_size = available_posts.length
      @available_user_posts = available_posts.paginate(page: params[:page], per_page: 3)
    end
    
    # reviews = Review.where(seller_id: @user.id)
    reviews = @user.reviews
    if reviews.blank?
      @avg_rating = 0
      @reviews_size = 0
    else
      @reviews_size = @user.reviews_count
      @reviews = reviews.paginate(page: params[:page], per_page: 5) 
    end
  end

  def edit 
    # @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to home_path
    else
      render 'new'
    end
  end

  def destroy
    @user.destroy
    if current_user.admin
      flash[:success] = "User deleted"
      redirect_to users_path
    else
      flash[:info] = "I am very sad to see you leave. Join us at any time!"
      redirect_to login_path
    end
  end 

  def update
    # @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # GET /users/oauth/1
  def oauth
    if !params[:code]
      return redirect_to('/')
    end
    redirect_uri = url_for(:controller => 'users', :action => 'oauth', :id => params[:id], :host => request.host_with_port)
    @user = User.find(params[:id])
    begin
      @user.request_wepay_access_token(params[:code], redirect_uri)
    rescue Exception => e
      error = e.message
    end

    if error
      flash[:danger] = error
      redirect_to @user
    else
      flash[:success] = "Hurray! We successfully connected you to WePay!"
      redirect_to "/users/posts/#{@user.id}"
    end
  end


  private 
  def not_found
    render :text => 'Not Found', :status => '404' unless current_user.admin
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end
  def set_user_in_posts
    @user = User.includes(:posts).find(params[:id])
  end
	def user_params
		params.require(:user).permit(:first_name, :last_name, :email, :password, :description,
	                               :password_confirmation)
	end

  # Confirms the correct user.
  def correct_user
    
    redirect_to(login_path) unless current_user?(@user)
  end
  def admin_user
    redirect_to(login_path) unless current_user.admin?
  end
  def admin_or_correct_user
    @user = User.find(params[:id])
    redirect_to(login_path) unless current_user.admin? || current_user?(@user)
  end
  def logged_in_user
    redirect_to(login_path) unless logged_in?
  end
end
