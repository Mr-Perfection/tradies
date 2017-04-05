class PostsController < ApplicationController
	ActionView::Helpers::SanitizeHelper
	before_action :beautiful_search_url
	before_action :logged_in_user, except: [:show]
	impressionist action: [:show]
	before_action :set_post, only: [ :not_interested, :interested, :post_attachments]
	before_action :interested_user, only: [:payment_success, :buy] #set posts are inside this action.
	before_action :correct_user,   only: [:edit, :destroy, :update, :mark_as_sold, :post_attachments] #set posts are inside this action and sold post limit is inside this.
	# before_action :set_post_limit,   only: [:create] 
	# before_action :sold_post_limit,  only: [:update, :destroy] #sold posts cannot be updated nor destroyed
	def show
		@post = Post.includes(:post_attachments).find(params[:id])
		# impressionist(@post, "one more view added!")
		@user = @post.owner	
		# get the reviews
		reviews = @user.reviews
		@reviews_size = reviews.size

		# get a collection of [:id, :name]
		@categories = @post.categories_ids_names	
		# save_recipient(@user)
		if @post.post_attachments.any?
			@post_images = Array.new
			@post_attachments = @post.post_attachments.all
			@post_attachments.each do |p|
				@post_images.push(view_context.image_path(p.avatar))
			end
		end
	end

	def create
		#need to use count to see how many attachments there are.
		posts_size = current_user.posts_size
		# if posts_size >= posts_limit #only if the posts size is less than limit (default: 4).
		# 	flash[:danger] = "You have reached the maximum post limit! Do not attempt to do this..."
		# 	return redirect_to root_path
		# end

		# count the post attachments
		count = 0
		# puts current_user.id
		@post = current_user.posts.build(post_params)
		@post.subject = strip_tags(@post.subject)
		@post.content = strip_tags(@post.content)
		@post.email_address = strip_tags(@post.email_address)
		@post.condition = strip_tags(@post.condition)
		@post.street_address = strip_tags(@post.street_address)
		@post.city = strip_tags(@post.city)
		@post.state = strip_tags(@post.state)
		@post.zip = strip_tags(@post.zip)
	    if @post.save
	      params[:post_attachments]['avatar'].each do |a|
      		if count >= 8
      			@post.destroy
      			flash[:danger] = "Image attachments are limited to 8 images!"
			    @post_attachment = @post.post_attachments.build
		        @user_posts = []
		        @interested_user_posts = []
		        @bought_user_posts = []
		        render 'users/posts'
      			return
      		else
      			@post_attachment = @post.post_attachments.create!(:avatar => a, :post_id => @post.id)
      		end
      		count += 1 #increments count
          end
          if @post.user_admin
          	@post.update_columns(tradies: true)
          end
       	  flash[:success] = "Post was successfully created!"
	      redirect_to @post
	    else
	   	  flash[:danger] = "Something went wrong. Please, check the error messages."
	      @post_attachment = @post.post_attachments.build
	      @user_posts = []
	      @interested_user_posts = []
	      @bought_user_posts = []
	      redirect_to home_path
    	end
	end

	# PATCH/PUT /posts/1
  	def edit
  	end
  	def post_attachments
  		@post_attachments = @post.post_attachments
  	end
  	def update
  		@post.subject = strip_tags(@post.subject)
		@post.content = strip_tags(@post.content)
		@post.email_address = strip_tags(@post.email_address)
		@post.condition = strip_tags(@post.condition)
		@post.street_address = strip_tags(@post.street_address)
		@post.city = strip_tags(@post.city)
		@post.state = strip_tags(@post.state)
		@post.zip = strip_tags(@post.zip)
  		if @post.update_attributes(post_params)
	      flash[:success] = "Post updated!"
	      redirect_to @post
	    else
	      redirect_to @post
	    end	
  	end

	def destroy
		@post.destroy
    	flash[:success] = "Post deleted!"
    	redirect_to "/users/posts/#{current_user.id}"
	end

	# GET /posts/mark-as-sold/1
	def mark_as_sold
		@post.update_columns(sold: true)
		redirect_to "/users/posts/#{current_user.id}"
	end
	# GET /posts/buy/1
	def buy
		redirect_uri = url_for(:controller => 'posts', :action => 'payment_success', :id => @post, :host => request.host_with_port)
		@user = @post.owner
		begin
		  @checkout = @post.create_checkout(redirect_uri)
		  # puts @checkout	
		rescue Exception => e
		  flash[:danger] = e.message
		  redirect_to @post
		end
	end

	# GET /posts/payment_success/1
	def payment_success
		# @post = Post.find(params[:id])
		@user = @post.owner
		if !params[:checkout_id]
		  return redirect_to @user, alert: "Error - Checkout ID is expected"
		end
		if (params['error'] && params['error_description'])
		  return redirect_to @user, alert: "Error - #{params['error_description']}"
		end
		flash[:success] = "Thanks for the payment! You should receive a confirmation email shortly."
		flash[:info] = "Please, check your email to leave a review about the seller."
		# hold: true, bought_by: @user (user_id)
		@post.update_columns(sold: true, sold_user_id: current_user.id) #set :sold to be true.
		# create reviews for seller and buyer
		review_buyer = @user.reviews.create(satisfied: true, reviewer_id: current_user.id, post_id: @post.id, comment: "#{@user.name} has successfully sold an item to #{current_user.name}.") #create a review on a seller for the buyer as a reviwer.	
		review_seller = current_user.reviews.create(satisfied: true, reviewer_id: @user.id, post_id: @post.id, comment: "#{current_user.name} has successfully purchased an item from #{@user.name}.") #create a review on a buyer for the seller as a reviwer.	
		review_buyer.send_review_activation_email(current_user, @user, @post) #send email to seller
		review_seller.send_review_activation_email(@user, current_user, @post) #send email to buyer
		return redirect_to home_path
	end

	def not_interested
		#param[:id] is not for posts. It is for current_user
		@post.delete_interested_user(current_user)
		@post.save
		flash[:success] = "You have successfully changed your mind on #{@post.user_name}'s #{@post.subject}."
		# if @post.interested #if initially interested
		# 	if @post.update_columns(interested: false, interested_user_id: nil)
		# 		flash[:success] = "You have successfully changed your mind on #{@post.user_name}'s #{@post.subject}."
	 #      	else
	 #      		flash[:danger] = "Uh-Oh! Something went wrong.."
	 #      		# #{@post.user_name}'s #{@post.subject}.
	 #      	end
	 #    else
	 #    	flash[:info] = "You already said not interested in #{@post.user_name}'s #{@post.subject}."
		# end	
		redirect_to "/users/posts/#{current_user.id}"#go to user#posts to show the Posts that interest you
	end

	
	def interested
		@post.add_interested_user(current_user)
		redirect_to "/users/posts/#{current_user.id}"#go to user#posts to show the Posts that interest you
	end
	#before filters
	private
	def strip_tags(text)
		ActionController::Base.helpers.strip_tags(text)
	end	
	# Use callbacks to share common setup or constraints between actions.
	def set_post
	  @post = Post.find(params[:id])
	end
	def post_params
      params.require(:post).permit(:subject, :price, :street_address, :city, :state, :condition, :payment_method, :is_firm, :phone_number, :email_address, 
      	:content, post_attachments_attributes: [:id, :post_id, :avatar], category_ids: [])
    end
    def correct_user
      @post = Post.find(params[:id])
      redirect_to(home_path) unless current_user?(@post.owner)
    end
    def logged_in_user
    	redirect_to(login_path) unless logged_in?
  	end
  	def only_seller_and_interested_user #check if current user is the intersted user and if it is already sold, redirect.
  		@post = Post.find(params[:id])
    	redirect_to(@post) unless (@post.check_interested_user(current_user) || @post.user_id == current_user.id)
  	end
  	def interested_user #check if current user is the intersted user and if it is already sold, redirect.
  		@post = Post.find(params[:id])
  		redirect_to(@post) unless (@post.sold == false)
    	redirect_to(login_path) unless (@post.check_interested_user(current_user))
  	end
end

