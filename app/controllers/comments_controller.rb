class CommentsController < ApplicationController
  
  def create
    @comment = Comment.new(comment_params)
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
    params.require(:comment).permit(:message, :author_id, :author_type, :commentable_id, :commentable_type, :notify_account_users)
  end
  
end
