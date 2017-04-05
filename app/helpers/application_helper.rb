module ApplicationHelper
	def page_header(text)
	    content_for(:page_header) { text.to_s }
	end
    
    def mailbox_section(title, current_box, opts = {})
    end
    # def tradies_app_fee(price)
    #     app_fee = price * 0.0025
    #     if price > 0 && price < 100
    #       app_fee = price * 0.015
    #     elsif price >= 100 && price < 1000
    #       app_fee = price * 0.01
    #     elsif price >= 1000 && price < 10000
    #       app_fee = price * 0.005
    #     elsif price >= 10000
    #       app_fee = price * 0.0025
    #     end
    #     return app_fee
    # end
	  # def gravatar_for(user, size = 30, title = user.name)
	  #   image_tag gravatar_image_url(user.email, size: size), title: title, class: 'img-rounded'
	  # end
	# Returns the full title on a per-page basis.
    def full_title(page_title = '')
        base_title = "Tradies"
        if page_title.empty?
            base_title
        else
            page_title + " | " + base_title
        end
    end
end
