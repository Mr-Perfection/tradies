module PostsHelper
	def time_ago_or_at(created_at)
		current = Time.now
		elapsed = (current - created_at).to_i
		# puts("time elapsed #{elapsed}")
		# check if elapsed is after 24 hours
		if (elapsed > 86400)
			return created_at.strftime("on %m/%d/%Y")
		else
			return time_ago_in_words(created_at) + " ago"
		end
	end	
end
