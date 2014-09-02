class AttachmentsController < ApplicationController
  
  def index
    
  end
  
  def create
    @uuid = params.delete(:uuid)
    @attachment = current_account.attachments.new(attachment_params)
    respond_to do |format|
      @attachment.save
      format.html {redirect_to attachment_path}
      format.js 
    end
  end
  
  def destroy
    @attachment = current_account.attachments.includes(:attachable => [:attachments]).find(params[:id])
    @object_attachments = @attachment.attachable.attachments
    respond_to do |format|
      @attachment.destroy
      format.html {redirect_to attachments_path}
      format.js 
    end
  end
  
  
  private
  
  def attachment_params
    params.require(:attachment).permit(:resource, :author_id, :author_type, :attachable_type, :attachable_id)
  end
  
  
end
