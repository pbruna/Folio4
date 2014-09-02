module CommentsHelper
  
  def comment_default_subscribers_list(comment)
    # El compat es para eliminar nil's del array
    names = comment.last_commentable_subscribers.map {|user| user.full_name unless user.nil?}.compact
    return "nadie" if names.empty?
    last_name = names.pop
    return last_name if names.empty?
    "#{names.join(", ")} y #{last_name}"
  end
  
  def last_comment_subscribers(comment)
    comment.last_commentable_subscribers.map {|user| user.id}
  end
  
  def is_selected?(last_subscribers, subscriber_id)
    last_subscribers.include? subscriber_id
  end
  
  def comment_object_path(commentable)
    object_type = commentable.class.to_s.downcase
    object_id = commentable.id
    send("#{object_type}_path", object_id)
  end
  
  def organization_type(subscriber)
    return "account" if subscriber.class.to_s.downcase == "user"
    return "company" if subscriber.class.to_s.downcase == "contact"
  end
  
  def get_organization_id(object,subscriber)
    org_type = organization_type(subscriber)
    return object.account_id if org_type == "account"
    object.company_id
  end
  
end
