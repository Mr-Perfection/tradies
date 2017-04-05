class UpgradesController < ApplicationController
	before_action :logged_in_user, only: [:payment_success, :buy]
# GET /posts/buy/[:upgrade_name]
	def buy
		@upgrade = Upgrade.find(params[:id])
		redirect_uri = url_for(:controller => 'upgrades', :action => 'payment_success', :id => @upgrade.id, :host => request.host_with_port)
		begin
		  @checkout = @upgrade.create_checkout(redirect_uri)
		  # puts "this is checkout for buy"
		  # puts @checkout	
		rescue Exception => e
		  flash[:danger] = e.message
		  redirect_to root_path
		end
	end
	# GET /posts/payment_success/1
	def payment_success
		upgrade = Upgrade.find(params[:id])
		if !params[:checkout_id]
		  return redirect_to upgrades_path, alert: "Something went wrong... Please, report this to contact@Tradies.us regarding upgrades."
		end
		if (params['error'] && params['error_description'])
		  return redirect_to upgrades_path, alert: "Error - #{params['error_description']}"
		end
		
		new_post_limit = current_user.posts_limit + upgrade.posts #set the new posts_limit	
		count = upgrade.count + 1
		flash[:success] = "Thanks for the payment! You should receive a confirmation email shortly, and you can now post up to #{new_post_limit} posts!"
		current_user.update_columns(posts_limit: new_post_limit) #set :posts_limit to new limit
		upgrade.update_columns(count: count) #count + 1.
		redirect_to root_path
	end

	private

	def logged_in_user
    	redirect_to(login_path) unless logged_in?
  	end
end
