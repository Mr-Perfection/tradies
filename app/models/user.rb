class User < ApplicationRecord
	
	default_scope -> { order(created_at: :desc) }
	has_many :reviews, class_name:  "Review",
                       foreign_key: "reviewee_id",
                       dependent: :destroy #reviews are dependent on Sellers. Reviews will stay when Buyers are gone.
	has_many :posts , dependent: :destroy
	has_many :interested_users, dependent: :destroy
	has_many :interested_users_lists, through: :interested_users
	attr_accessor :remember_token, :activation_token, :reset_token
	before_save   :downcase_email
	before_create :create_activation_digest
	validates :first_name, presence: true, 
						length: { maximum: 50 }
	validates :last_name, presence: true, 
						length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 60 },
						format: { with: VALID_EMAIL_REGEX },
						uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: { minimum: 8 }
	validates :description, allow_nil: true, length: { maximum: 140 }

	acts_as_messageable
	
	def name
		name = first_name + " " + last_name
		return name.titleize
	end	
	def mailboxer_email(object)
	  email
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

	#total number of posts
	def posts_size
		posts.size
	end
	#total number of reviews
	def reviews_count
		reviews.size
	end
	
	#total number of upvotes
	def upvotes_size
		reviews.where(satisfied: true).size
	end

	#total number of downvotes
	def downvotes_size
		reviews.where(satisfied: false).size
	end
	# Remembers a user in the database for use in persistent sessions.
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# returns true if the given token matches the digest (remember_digest, activation_digest)
    def authenticated?(attribute, token)
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)        #renew the remember_digest with new password
    end

	# Forgets a user.
	def forget
		update_attribute(:remember_digest, nil)
	end

	# Activates an account.
	def activate
		update_columns(activated: true, activated_at: Time.zone.now)
	end

	# Sends activation email.
	def send_activation_email
		UserMailer.account_activation(self.id, self.activation_token).deliver_later
	end

	def send_new_message(to, subject)
		UserMailer.new_message_from_user(to.id, self.id, subject).deliver_later(wait_until: 2.minutes.from_now)
	end
	def send_new_reply(to, subject)
		UserMailer.new_reply_from_user(to.id, self.id, subject).deliver_later(wait_until: 3.minutes.from_now)
	end

	# Sets the password reset attributes.
	def create_reset_digest
		self.reset_token = User.new_token
		# update_attribute(:reset_digest,  User.digest(reset_token))
		# update_attribute(:reset_sent_at, Time.zone.now)
		update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
	end

	# Sends password reset email.
	def send_password_reset_email
		UserMailer.password_reset(id, self.reset_token).deliver_later
  	end

  	# Returns true if a password reset has expired.
	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	# get the authorization url for this user. This url will let the user
	# register or login to WePay to approve our app.

	# returns a url
	def wepay_authorization_url(redirect_uri)
	  WEPAY.oauth2_authorize_url(redirect_uri, self.email, self.name)
	end

	# takes a code returned by wepay oauth2 authorization and makes an api call to generate oauth2 token for this user.
	def request_wepay_access_token(code, redirect_uri)
	  response = WEPAY.oauth2_token(code, redirect_uri)
	  if response['error']
	    raise "Error - "+ response['error_description']
	  elsif !response['access_token']
	    raise "Error requesting access from WePay"
	  else
	  	puts "need to get access token"
	  	puts response['access_token']
	    # self.wepay_access_token = response['access_token']
	    # self.save
	    self.update_columns(wepay_access_token: response['access_token'])

		#create WePay account
	    self.create_wepay_account
	  end
	end

	def has_wepay_access_token?
	  !self.wepay_access_token.nil?
	end
	def has_wepay_account?
  		self.wepay_account_id != 0 && !self.wepay_account_id.nil?
	end

	# makes an api call to WePay to check if current access token for user is still valid
	def has_valid_wepay_access_token?
	  if self.wepay_access_token.nil?
	    return false
	  end
	  response = WEPAY.call("/user", self.wepay_access_token)
	  response && response["user_id"] ? true : false
	end

	# creates a WePay account for this user with the user's name
	def create_wepay_account
	  if self.has_wepay_access_token? && !self.has_wepay_account?
	    params = { :name => self.name, :description => "Selling goods on Tradies " }			
	    response = WEPAY.call("/account/create", self.wepay_access_token, params)

	    if response["account_id"]
	    	puts "need to get account_id"
	  		# puts response['account_id']
	      # self.wepay_account_id = response["account_id"]
	      return self.update_columns(wepay_account_id: response['account_id'])
	    else
	      raise "Error - " + response["error_description"]
	    end

	  end		
	  raise "Error - cannot create WePay account"
	end
	



	#before filters
    private

   #  def posts_limit
   #  return if posts.blank?
   #  	errors.add( :posts, "You have reached the post limit(max: 5 posts)") if posts.size > 5
  	# end
    
    #convert email to all lowercase letters
    def downcase_email
        # self.email = email.downcase
        email.downcase!
    end
    
    #creates and assigns the activation token and digest.
    def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end

end
