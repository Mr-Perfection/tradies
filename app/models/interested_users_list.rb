class InterestedUsersList < ApplicationRecord
	# belongs_to :post
	# belongs_to :users
	belongs_to :post
	has_many :interested_users
	has_many :users, :through => :interested_users
	# accepts_nested_attributes_for :interested_users
	# belongs_to :interested_user, class_name: 'User'
end