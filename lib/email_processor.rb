class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    comment = Comment.new_from_email(@email)
    comment.save if comment
  end
end