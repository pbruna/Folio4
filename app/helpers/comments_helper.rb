module CommentsHelper
  
  def comment_default_suscribers_list(comment)
    names = comment.last_commentable_suscribers.map {|user| user.full_name}
    last_name = names.pop
    "#{names.join(", ")} y #{last_name}"
  end
  
end
