module SessionsHelper
   #save unread messages
    def save_unread_messages(query)
        session[:unread_messages] = query
    end
    def count_unread_messages
        return (session[:unread_messages].present? && session[:unread_messages] != 0  ? session[:unread_messages] : "")
    end
    #session search query
    def save_location_query(query)
        cookies.permanent[:location_query] = query
    end
    def set_welcome_alert
        session[:welcome_from_tradies] = 1
    end
    # session for recipient
    def save_recipient(id)
        session[:message_recipient] = id
    end
    
    # get the previous url 
    def save_previous_page
        session[:return_to] = request.fullpath
    end
    # logs in with the given user
    def log_in(user)
        session[:user_id] = user.id
    end
    #remember user in a persistent session
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id    #store the user id into cookies
        cookies.permanent[:remember_token] = user.remember_token     #store the token into cookies
    end
    
    # returns true if the given user is the current user
    def current_user?(user)
        user == current_user
    end

    # Returns the user corresponding to the remember token cookie.
    def current_user
        if (user_id = session[:user_id])    #if session exists then asssign user id.
            @current_user ||= User.find_by(id: user_id)     #assign to current user with found user with user_id
        elsif (user_id = cookies.signed[:user_id])        #if session exists then asssign user id. 
            user = User.find_by(id: user_id)        #assign user matched with user id
            if user && user.authenticated?(:remember, cookies[:remember_token])    #check if user exists and user authenticated with the cookies remember token
                log_in user     #log in as user
                @current_user = user        #store user into current user variable
            end
        end
    end
    
    
    
    # Returns true if the user is logged in, false otherwise.
    def logged_in?
        !current_user.nil?
    end
    
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end
    
    # def log_out
    #     forget(current_user)
    #     session.delete(:user_id) #delte the session
    #     @current_user = nil #set the variable to nil value
    # end
     # Logs out the current user.
	def log_out
        forget(current_user)
		session.delete(:user_id)
		@current_user = nil
	end
    
    # redirects to stored location (or to the default) for friendly forwarding (when user first tried to have access to forbidden urls
    # such as /edit or /update, it will store that url and after login redirect back to it or go to default url)
    def redirect_back_or(default)
        redirect_to(session[:forwarding_url] || default)
        session.delete(:forwarding_url)     #delete what is stored.
    end
    
    # stores the URL trying to be accessed
    # puts the requested URL in the session variable with the key :fowarding_url only for a GET request
    # including if request.get? prevents storing the forwaring URL if a user submits a form when not logged in (or cleared cookies).
    def store_location
        session[:forwarding_url] = request.original_url if request.get?
    end
end
