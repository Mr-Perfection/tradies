class ReviewsController < ApplicationController
  before_action :logged_in_and_allowed_user,  except: [:index]
  before_action :admin_user,                  only: [:index]  
  
  def index
    @reviews = Review.all
  end

  # GET /users/3/reviews/1
  def show
    @reviewer = User.find(@review.reviewer_id)
  end

  # /users/3/reviews/new/1
  def new
  end

  # GET /reviews/1/edit
  def edit
  end

  # user /reviews
  # user /reviews.json
  def create
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    if @review.update_attributes(review_params)
      flash[:success] = "Review is successfully created!"
      redirect_to user_review_path(user_id: @review.reviewee_id, id: @review.id)
    else
      flash[:success] = "Please, fill in the review form."
      render 'edit'
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    redirect_to user_path(@user)
  end

  private
    
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:satisfied, :comment) #only statisfied and comment are allowed for edit.
    end
    
     # Confirms the correct user.
    # def correct_user
    #   review = current_user.reviews.find_by(id: params[:id])
    #   redirect_to root_url if review.nil?
    # end
    
    def admin_user
      redirect_to(login_path) unless current_user.admin?
    end
    def logged_in_and_allowed_user
      return redirect_to home_url unless logged_in?
      @review = Review.find(params[:id])
      @user = User.find(params[:user_id]) #user id is from the post owner.
      # puts "#{@review.id} is review_id"
      # puts "#{@review.activation_expired?} is expired?"
      # puts "#{@review.activated_at} is expired?"
      # puts "#{@user.name} is user name"
      if @review.activation_expired?
        flash[:danger] = "Review expired. You can no longer leave or edit your review."
        return redirect_to home_url
      end
      if current_user.id != @review.reviewer_id
        flash[:danger] = "Unauthorized access."
        return redirect_to home_url 
      end
    end
end
