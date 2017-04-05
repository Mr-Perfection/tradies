class AccountActivationsController < ApplicationController
 def edit
	user = User.find_by(email: params[:email])
	if user && !user.activated? && user.authenticated?(:activation, params[:id])
	  user.activate
	  # log_in user
	  flash[:success] = "Account activated! Please log in with your ID and password."
	  redirect_to login_url
	else
	  flash[:danger] = "Invalid activation link or already activated."
	  redirect_to root_url
	end
 end
end
