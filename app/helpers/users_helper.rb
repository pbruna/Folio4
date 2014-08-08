module UsersHelper
  
  def display_user_avatar(user)
    content_tag(:img, nil,:src => user.avatar.url(:thumb))
  end
  
end
