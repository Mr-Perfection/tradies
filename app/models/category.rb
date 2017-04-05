class Category < ApplicationRecord
	has_many :categorizations
	has_many :posts,  through: :categorizations
	 after_commit :reindex_posts

	def reindex_posts
		posts.each do |post|
		  post.reindex
		end
	end
end
