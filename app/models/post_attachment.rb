class PostAttachment < ApplicationRecord
	# before_save :images_limit #this will check how many images there are in the post and delete the post if it reaches 8.

	mount_uploader :avatar, AvatarUploader
	belongs_to :post
	validates_associated :post
	validate  :picture_size
	validates :avatar, presence: true
	default_scope -> { order(created_at: :desc) } 
	

	private
    def picture_size
      if avatar.size > 2.megabytes
        errors.add(:avatar, "should be less than 3MB")
      end
    end
end
