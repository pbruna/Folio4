module CommentsHelper
  
  def comment_default_subscribers_list(comment)
    names = comment.last_commentable_subscribers.map {|user| user.full_name}
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
  
  def comment_object_path(comment)
    object_type = comment.commentable.class.to_s.downcase
    object_id = comment.commentable.id
    send("#{object_type}_path", object_id)
  end
  
end
