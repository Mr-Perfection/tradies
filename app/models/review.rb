class Review < ApplicationRecord
  
  default_scope { order(created_at: :desc) }
	belongs_to :reviewee, class_name: "User"
  belongs_to :reviewer, class_name: "User"
  belongs_to :post
	attr_accessor :activation_token

	before_create :create_activation_digest
  validates :reviewer_id, presence: true
  validates :reviewee_id, presence: true
	# validates :satisfied, 	presence: true
	# validates :reviewee_review, 	presence: true
 #  	validates :comment,   presence: true

  def user_name
    reviewee.name
  end
  def user
    reviewee
  end
  def user_id
    reviewee.id
  end
  def reviewer_name
    reviewer.name
  end
  
  
  
  def reviewer_up_votes
    reviewer.upvotes_size
  end
  def reviewer_down_votes
    reviewer.downvotes_size
  end

  	# Sends activation email.
	def send_review_activation_email(reviewer, reviewee, post)
		UserMailer.review_activation(reviewer.id, reviewee.id, self.id, post.id, activation_token).deliver_later(wait_until: 1.minute.from_now)
	end
  	# Returns the hash digest of the given string.
 	def self.digest(string)
    	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    	BCrypt::Password.create(string, cost: cost)
  	end
  	# Returns a random token.
	def self.new_token
		SecureRandom.urlsafe_base64
	end
  
  	# Activates an account.
	def activate
		update_columns(activated: true, activated_at: Time.zone.now)
	end
  	
  	# returns true if the given token matches the digest (activation_digest)
  def authenticated?(attribute, token)
      digest = self.send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)        #renew the remember_digest with new password
  end
  def activation_expired?
    return self.activated_at < 7.days.ago if self.activated_at.present?
    return true
  end
	private
  def create_activation_digest
    self.activation_token = Review.new_token
    self.activation_digest = Review.digest(activation_token)
  end
  	#creates and assigns the activation token and digest.
    
    
end
