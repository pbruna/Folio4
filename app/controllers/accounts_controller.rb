class AccountsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:new, :create, :check_subdomain]
  before_action :validate_owner!, :only => ['edit', 'update']
  respond_to :html, :xml, :json

  def dashboard

  end
  
  def check_invoice_number_availability
    valid = current_account.check_invoice_number_availability(params[:value],params[:taxed])
    respond_to do |format| 
      format.html {render :json => ""}
      format.json {render :json => {value: params[:value].to_i, valid: valid, message: "Número ya en uso"}}
    end 
  end

  def new
    @account = Account.new
    @account.users.build
  end

  def show
    @account = current_account
  end

  def edit
    @account = current_account
  end

  def update
    @account = Account.find(current_account)
    if @account.update_attributes(account_params)
      flash[:notice] = "Información actualizada correctamente."
      redirect_to account_url(@account, :subdomain => @account.subdomain)
    else
      render :action => "edit"
    end
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      AccountMailer.delay.register_welcome(@account.owner.id)
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
      params.require(:account).permit(:name, :city, :phone, :rut, :address, :subdomain, :country, :industry, :value, users_attributes: [:email, :password])
    end

    def subdomain_params
      params.require(:name)
    end

end
