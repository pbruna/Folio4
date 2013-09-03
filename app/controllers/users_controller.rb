class UsersController < ApplicationController
  before_action :validate_owner!, :only => ['create', 'new']

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    validate_owner_or_same_user!
  end

  def update
    validate_owner_or_same_user!
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:notice] = "Usuario actualizado correctamente."
      redirect_to account_url(current_account, :subdomain => current_account.subdomain)
    else
      render :action => "edit"
    end
  end

  def create
    @user = User.new(user_params)
    @user.account_id = current_account.id
    if @user.save
      #AccountMailer.register_welcome(@account.owner.id).deliver
      flash[:notice] = "Usuario creado correctamente"
      redirect_to account_path(current_account)
    else
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def validate_owner_or_same_user!
      @user = User.find(params[:id])
      return if current_user.owner?
      return if current_user.id == @user.id
      flash[:alert] = "Sólo el dueño de la cuenta o el mismo usuario pueden realizar esta operación."
      redirect_to request.referer || account_path(current_account)
    end


end
