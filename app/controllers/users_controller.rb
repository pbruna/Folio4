class UsersController < ApplicationController
  before_action :validate_owner!, :only => ['create', 'new', 'destroy']

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
    @user = current_account.users.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:notice] = "Usuario actualizado correctamente."
      redirect_to user_path(@user)
    else
      render 'edit'
    end
  end

  def create
    @user = User.new_from_owner(current_account.id, user_params)
    if @user.save
      UserMailer.delay.welcome_email(@user.id)
      flash[:notice] = "Usuario creado correctamente"
      redirect_to user_path(@user)
    else
      render 'new'
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.deactivate!
      flash[:notice] = "Usuario desactivado correctamente."
      redirect_to account_path(current_account)
    else
      flash[:alert] = "No es posible desactivar al dueño de la cuenta."
      redirect_to account_path(current_account)
    end
  end

  private

    def user_params
      params.require(:user).permit(:avatar, :name, :email, :password, :password_confirmation, :active)
    end

    def validate_owner_or_same_user!
      @user = User.find(params[:id])
      return if current_user.owner?
      return if current_user.id == @user.id
      flash[:alert] = "Sólo el dueño de la cuenta o el mismo usuario pueden realizar esta operación."
      redirect_to request.referer || account_path(current_account)
    end


end
