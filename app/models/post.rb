Choices = YAML.load_file("#{Rails.root}/config/allowed-choices.yml")   #the allowed choices for cities and states.
class Post < ApplicationRecord
  searchkick callbacks: :async #Use background jobs for better performance
  # searchkick word_start: [:subject], callbacks: :async #Use background jobs for better performance
  # make your model impressible and get impressions.
  has_many :impressions, :as=>:impressionable
  # in order to implement sidekiq features, we need to get redis. Heroku redis add-on costs more.
  # decided to go with default callbacks because it is unnecessary to optimize search for now which costs more $$.
  # after_commit  :index_document,  on: [:create, :update]    #index the document when created or updated
  # after_commit  :delete_document, on: :destroy              #delete the document when destroyed
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id", touch: true
  has_many :post_attachments , dependent: :destroy
  accepts_nested_attributes_for :post_attachments
  has_one :interested_users_list, dependent: :destroy
  has_many :users, through: :interested_users_list
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  # after, on, and before filters

  after_create :create_interested_users_list
  # validate :post_attachments_counts_within_bounds, on: :create #maximum 8 post attachments
  validates_length_of :categorizations, maximum: 3 #maximum 3 categories
  #scoping
  default_scope -> { order(created_at: :desc) }
  scope :is_sold, -> { where(:sold => true) }
  scope :not_sold, -> { where(:sold => false) }

  # Validations
  validates :user_id, 	presence: true
  validates :price, 	presence: true, numericality: { :greater_than_or_equal_to => 0.99 }
  validates :subject, 	presence: true
  # validates :category,   presence: true
  # validates_inclusion_of :category, in: Choices['categories'] #check if user picked the correct categories.
  validates :city, 		presence: true
  validates_inclusion_of :city, in: Choices['cities'] #check if user picked the correct city.
  validates :state, 	presence: true
  validates_inclusion_of :state, in: Choices['states'] #check if user picked the correct state.
  validates :payment_method,   presence: true
  validates_inclusion_of :payment_method, in: Choices['payment_method'] #check if user picked the correct state.
  validates :condition,   presence: true
  validates_inclusion_of :condition, in: Choices['conditions'] #check if user picked the correct state.
  validates :content, 	presence: true, length: { maximum: 500, minimum: 25 }
  # geocoder
  geocoded_by :full_address # can also be an IP address
  after_validation :geocode


  def search_data
    # currently exclude state to be indexed. "Scale as you expand"
    attributes.except(:state, :content).merge(
      category_titles: categories.map(&:title)
    )
  end
  def full_address
    if zip.present?
      "United States, #{zip}, #{state}, #{city}, #{street_address}"
    else
      "United States, #{state}, #{city}, #{street_address}"
    end
  end
  def location
    [city, state].join(', ')
  end
  def feedbacks_count
  end
  def user
    owner
  end
  def user_admin
    owner.admin
  end
  def user_tradies
    owner.tradie
  end
  def user_id
    owner.id
  end
  def user_reviews
    owner.reviews
  end
  def user_up_votes
    owner.reviews.where(satisfied: true).size
  end
  def user_down_votes
    owner.reviews.where(satisfied: false).size
  end
  def user_email
    owner.email
  end
  def user_name
    owner.name
  end
  def user_first_name
    owner.first_name
  end
  def user_rating
    owner.average_rating
  end
  def first_post_attachment
    post_attachments.first
  end
  def user_created_at
    owner.created_at
  end
  def user_wepay_account_id
    owner.wepay_account_id
  end
  def user_wepay_access_token
    owner.wepay_access_token
  end
  def categories_ids_names
    categories.pluck(:title)
  end
  # Sends 'there is interested user' email.
  # def send_interested_user_email
  #   UserMailer.interested_user_notification(self.id).deliver_later(wait_until: 3.minutes.from_now)
  # end

  # creates a checkout object using WePay API for this user
  def create_checkout(redirect_uri)

    # if price is between $1 and $100, collect 1.5% +2.9% (wepay)
    # if price is between $100 and $1000, collect 1% +2.9% (wepay)
    # if price is between $1000 and $10,000, collect 0.5% +2.9% (wepay)
    # if price is over $10,000, collect 0.25% +2.9% (wepay)

    # app_fee = self.price * 0.01
    price = self.price
    app_fee = tradies_app_fee(price)
    params = {
      :account_id => self.user_wepay_account_id,
      :short_description => "item sold by #{self.user_name}",
      :type => :goods,
      # :auto_release => false,
      :currency => 'USD',
      :amount => price,
      :fee => {
          :app_fee => app_fee,
          :fee_payer => 'payee'
      },
      :hosted_checkout => {
          :mode  => 'iframe',
          :redirect_uri => redirect_uri
      }
    }
    response = WEPAY.call('/checkout/create', self.user_wepay_access_token, params)

    if !response
      raise "Error - no response from WePay"
    elsif response['error']
      raise "Error - " + response["error_description"]
    end
    # puts response
    return response
  end
  # count impressions
  def impression_count
    self.impressions.size
  end
  # count total interested users
  def interested_users_count
    self.users.size
  end
  def interested_users_with_words
    users_size = self.users.size
    words = ""
    if users_size < 2
      words = "user is"
    else
      words = "users are"
    end
    return "#{users_size} #{words}"
  end
  # interested user present?
  def interested_users_present
    self.users.present?
    # members.includes(:responses).where.not(responses: { id: nil })
  end
  # check interested user
  def check_interested_user(user)
    # puts "check this user:  #{user.id}"
   self.users.include? (user)
   # puts "check this user include:  #{self.interested_users_list.interested_users.include?(user)} "
  end
  # add interested user
  def add_interested_user(user)
    # puts "this is user id:  #{user.id} "
    # self.interested_users_list.users << user
   # interestedUser = self.interested_users_list.build(interested_user_id: user.id)
   # interestedUser.save!
   interestedUser = self.interested_users_list.interested_users.build(user_id: user.id)
   interestedUser.save!
   # interestedUser.save!
   # puts "this is #{interestedUser.user_id} "
  end
  # remove interested user
  def delete_interested_user(user)
    interested_user = self.interested_users_list.interested_users.where(user_id: user.id)
   self.interested_users_list.interested_users.delete(interested_user)
  end
   #before filters

private
  def post_attachments_counts_within_bounds
    return if post_attachments.blank?
    errors.add("Too many attachments") if post_attachments.size > 1
  end
  # def categorizations_count_within_bounds
  #   return if categories.blank?
  #   errors.add()
  # end
  def build_default_interested_users_list
    self.create_interested_users_list
    true
  end
  # def post_attachments_limit
  #   return if post_attachments.blank?
  #   errors.add( :post_attachments,"You have reached the image limit(max: 8 images)") if .post_attachments.length > 1
  # end
  def tradies_app_fee(price)
      app_fee = price * 0.0025
      if price > 0 && price < 100
        app_fee = price * 0.015
      elsif price >= 100 && price < 1000
        app_fee = price * 0.01
      elsif price >= 1000 && price < 10000
        app_fee = price * 0.005
      elsif price >= 10000
        app_fee = price * 0.0025
      end
      return app_fee
  end

end
