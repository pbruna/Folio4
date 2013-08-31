class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include UrlHelper
  before_action :authenticate_user!
  before_action :set_account
  protect_from_forgery with: :exception
  layout :layout_by_resource


  def current_account
    return if current_user.nil?
    current_user.account
  end

  protected
    def layout_by_resource
      if devise_controller? && resource_name == :user
        "sign_in_layout"
      elsif params[:controller] == "accounts" && !(%w(show edit dashboard).include? params[:action])
        "sign_in_layout"
      else
        "application"
      end
    end

    def set_account
      @current_account = current_account
    end

    def authenticate_user!(opts={})
      if user_signed_in? && request.subdomain != current_user.account_subdomain
        redirect_to root_url(:subdomain => current_user.account_subdomain) 
      end
      opts[:scope] = :user
      warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
    end

end
