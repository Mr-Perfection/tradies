class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  rescue_from ActiveRecord::RecordNotFound do
    flash[:warning] = 'We cannot find what you are searching for...'
    redirect_back_or home_path
  end

  def redirect_back_or(path)
    redirect_to request.referer || path
  end

  private
    def beautiful_search_url
      if params[:location].present?
        if logged_in?
          current_user.update_columns(current_location: params[:location])
        else
          save_location_query(params[:location])
        end
        if params[:location] == "All Cities"
          if params[:q].present?
            if params[:category].present?
              return redirect_to search_url(query: params[:q] + " " + params[:category])
            else
              return redirect_to search_url(query: params[:q])
            end
          else
            if params[:category].present?
              return redirect_to search_url(query: params[:category])
            else
              return redirect_to home_url
            end
          end
        end
        # puts "inside location params #{params[:location].present?}"
        # puts "is there categories? #{params[:categories].present?}"
        if params[:category].present?
          # puts "the params[:category] is: #{params[:category].to_s}"
          if params[:location].present?
            params[:location].concat(" " + params[:category])
          else
            params[:location].concat(params[:category])
          end
          # puts "the params[:location] is: #{params[:location].to_s}"
        end
        # puts "the params[:location] is: #{params[:location].to_s}"
        if params[:q].present?
          redirect_to search_url(query: params[:q] + " " + params[:location])
        else
          redirect_to search_url(query: params[:location])
        end
      end
    end
    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
