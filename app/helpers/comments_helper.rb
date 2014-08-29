module CommentsHelper
  
  def comment_default_subscribers_list(comment)
    names = comment.last_commentable_subscribers.map {|user| user.full_name}
    last_name = names.pop
    "#{names.join(", ")} y #{last_name}"
  end
  
  def is_selected?(comment, subscriber_id)
    subscribers_ids = comment.last_commentable_subscribers.map {|user| user.id}
    subscribers_ids.include? subscriber_id
  end
  
end
