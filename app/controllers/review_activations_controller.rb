class ReviewActivationsController < ApplicationController
	before_action :logged_in_user	

	def edit
		review = Review.find(params[:review_id])
		if current_user.id != review.reviewer_id
			flash[:danger] = "Unauthorized access."
			return redirect_to home_url
		end
		if review && !review.activated? && review.authenticated?(:activation, params[:id])
		  review.activate
		  flash[:info] = "You have only 7 days left from #{review.activated_at} to leave a review."
		  redirect_to edit_user_review_url(review, user_id: review.reviewee)
		else
		  flash[:danger] = "Invalid activation link or already activated."
		  redirect_to root_url
		end
	end
 private
 	def logged_in_user
 		flash[:danger] = "Please, log in before you leave a review."
		redirect_to(login_path) unless logged_in? 
	end
end
