class InterestedUser < ApplicationRecord
	belongs_to :user
	belongs_to :interested_users_list
end
