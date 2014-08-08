class ContactsController < ApplicationController
  
  def index
    if params[:company_id]
      @company = current_account.companies.find(params[:company_id])
      @contacts = @company.contacts
    else
      @contacts = current_account.contacts
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @contacts }
    end
    
  end

  def create
    @contact = current_account.contacts.new(contact_params)
    @company = @contact.company

    respond_to do |format|
      if @contact.save
        format.html {redirect_to company_path(@contact.company), notice: "Contacto guardado correctamente."}
        format.js
      else
        format.html {render action: "new"}
        format.js
      end
    end
  end

  def edit
    @contact = current_account.contacts.find(params[:id])
    @company = @contact.company
    respond_to do |format|
      format.html {render :template => "contacts/edit_from_modal", layout: false}
      format.js {render :template => "edit_from_modal", layout: false}
    end
  end
  
  def update
    @contact = current_account.contacts.find(params[:id])
    @company = @contact.company
    respond_to do |format|
      if @contact.update_attributes(contact_params)
        format.js
      else
        format.js
      end
    end
  end
  
  def destroy
    @contact = current_account.contacts.find(params[:id])
    @company = @contact.company
    respond_to do |format|
      if @contact.destroy
        format.js
      else
        format.js
      end
    end
  end

  def new_from_modal
    @company = current_account.companies.find(params[:company_id])
    @contact = @company.contacts.new

    respond_to do |format|
      format.html {render layout: false}
      format.js {render :template => "new_from_modal", layout: false}
    end

  end
  
  private
    def contact_params
      params.require(:contact).permit(:name, :email, :company_id, :phone, :mobile_phone, :title, :description)
    end
end