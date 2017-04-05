class StaticPagesController < ApplicationController
  # before_action :only_three_interested_posts, only: [:home]
  before_action :logged_in_user, only: [:change_location]
  before_action :beautiful_search_url

  # def finished_tutorial
  #   cookies.delete :main_tutorial
  #   redirect_to root_path
  # end
  def autocomplete
    render json: Post.search(params[:query], {
      fields: ["subject^5"],
      match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 5}
    }).map(&:subject)
  end
  def TermsOfUse 
  end
  def PrivacyPolicy
  end
  def prohibited
  end
  def no_thanks
    cookies.delete(:sell_for_you_after_registered)
    return redirect_to home_path
  end
  def landing
    cookies[:sell_for_you_after_registered] = 1
    redirect_to home_path if logged_in?
    session[:sell_for_you] = 1
    @posts = Post.includes(:post_attachments, :categories).where(sold: false).first(12)
    @user = User.new
    @user.description = "Hello, I am new to Tradies!:)"
  end
  def home
    set_welcome_alert
    posts = Post.includes(:post_attachments, :categories)
    # save_previous_page
    # puts "#{params[:query]} is the query..."
    if params[:query].present?
      search_term = params[:query]
      puts "search term is:#{search_term}"
      queried_posts = posts.search(search_term).records.where(sold: false)
      
      # @posts_count = queried_posts.size
      featured_posts = queried_posts.where(tradies: true)
      @featured_posts_size = featured_posts.size
      @featured_posts = featured_posts.paginate(page: params[:page], per_page: 25)
      @posts = queried_posts.where(tradies: false).paginate(page: params[:page], per_page: 25)
      # puts "posts are #{@posts.inspect}"
      # paginate(page: params[:page])
      if queried_posts.blank?
        return flash[:alert] = "Items not found! Try different search terms."
      end
    else
      # @posts_count = posts.size
      featured_posts = posts.where(tradies: true)
      @featured_posts_size = featured_posts.size
      @featured_posts = featured_posts.paginate(page: params[:page], per_page: 25)
      @posts = posts.where(tradies: false).paginate(page: params[:page], per_page: 25)
      if posts.blank?
        return flash[:alert] = "No one has posted any items yet... Be the first one to post!"
      end
    end
  end

  def upgrades
    #stripe subscriptions API
    #https://www.sitepoint.com/stripe-subscriptions-rails/
  end

  private
    
    def only_three_interested_posts
      #admin can do what they want. Skip it if user is admin.
      if current_user.present? && current_user.admin == false
        interested_posts = Post.where(interested_user_id: current_user.id).where(sold: false)
        if interested_posts.size >= 3
          flash[:danger] = "Only maximum of 3 interested posts are allowed with your account. Please, complete your trades with the sellers."
          redirect_to "/users/posts/#{current_user.id}"
        end
      end
    end
    def logged_in_user
      redirect_to(login_path) unless logged_in?
    end
end
