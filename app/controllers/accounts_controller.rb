class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:new, :create]
  respond_to :html, :xml, :json
  
  def dashboard
    
  end
  
  def new
    @account = Account.new
    @account.users.build
  end
  
  def create
    @account = Account.new(account_params)
    if @account.save
      AccountMailer.register_welcome(@account.owner.id).deliver
      flash[:notice] = "Cuenta creada correctamente, bienvenido a Folio"
      sign_in(:user, @account.owner)
      redirect_to root_url(:subdomain => @account.subdomain)
    else
      render 'new'
    end
  end
  
  def check_subdomain
    subdomain_availability = Account.subdomain_available?(subdomain_params)
    respond_to do |format|
      format.json {render :json => subdomain_availability.to_json}
    end
  end
  
  private
  
  def account_params
    params.require(:account).permit(:name, :subdomain, users_attributes: [:email, :password])
  end
  
  def subdomain_params
    params.require(:name)
  end
  
end
