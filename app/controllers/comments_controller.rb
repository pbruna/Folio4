class CommentsController < ApplicationController
  
  def create
    @comment = Comment.new(comment_params)
    @comment_new = @comment.commentable.comments.build(author_id: current_user.id, author_type: current_user.class.to_s)
    respond_to do |format|
      if @comment.save
        flash.now[:notice] = "Comentario agregado."
        format.html {redirect_to @comment}
        format.js { render 'show' }
      else
        flash.now[:error] = "No se pudo agregar el comentario"
        format.html { redirect_to @comment }
        format.js { render 'create_error' }
      end
    end    
  end
  
  
  private
  
  def comment_params
    params.require(:comment).permit(:message, :author_id, :author_type, :commentable_id, 
                                    :commentable_type, :notify_account_users, :private,
                                    subscribers_ids: [account: [], company: [] ])
  end
  
end
