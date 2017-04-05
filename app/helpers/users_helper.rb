module UsersHelper
# Returns the Gravatar for the given user.
  def gravatar_for(user, options = { size: 60, class: ""})
        gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
        size = options[:size].to_s
        klass = options[:class].to_s
        value = size + "x" + size
        gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?d=mm"
        image_tag(gravatar_url, alt: user.name, size: value, class: "gravatar img-rounded img-responsive #{klass}")
  end
  def gravatar_for_responsive(user, options = { size: 200, class: ""})
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    klass = options[:class].to_s
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?d=mm&s=200"
    image_tag(gravatar_url, alt: user.name, class: "gravatar img-rounded img-responsive #{klass}")
  end
  def gravatar_for_message(user, title = user.name)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?d=mm"
    # image_tag gravatar_image_url(user.email, size: size), title: title, class: 'img-rounded'
    image_tag(gravatar_url, title: title, class: "gravatar img-circular img-responsive")
  end

  def gravatar_for_team(email)
        gravatar_id = Digest::MD5::hexdigest(email)
        # size = options[:size]
        return gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=400?d=mm"
        # image_tag(gravatar_url, alt: "No Image found", size: "300x300", class: "gravatar img-circular")
  end
end
