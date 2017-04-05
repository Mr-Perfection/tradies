module ConversationsHelper
	def mailbox_section(title, current_box, opts = {})
		opts[:class] = opts.fetch(:class, '')
		opts[:class] += ' active' if title.downcase == current_box
		# content_tag(:span, "1", class: ["badge"])
		# content_tag :li, link_to(title.capitalize, conversations_path(box: title.downcase)), opts
		content_tag :li, class: opts[:class] + " mailbox_section" do
			link_to(conversations_path(box: title.downcase)) do
				# content_tag(:p) do 
					concat content_tag(:span, title.capitalize)
					concat content_tag(:em, "", :class => opts[:which])
				# end
			end

			# link_to(title.capitalize, conversations_path(box: title.downcase)) + 
			# content_tag(:em, "", :class => 'glyphicon glyphicon-envelope')
		end 
  	end
  	def active_page(active_page)
		@active == active_page ? "active" : ""
	end
  	
end
