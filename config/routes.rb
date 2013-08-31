Folio::Application.routes.draw do
  devise_for :users, :path_names => {:sign_up => "register"}
  devise_scope :user do
    constraints(Subdomain) do
      get "/login" => "devise/sessions#new"
    end
  end
  get 'accounts/check_subdomain' => 'accounts#check_subdomain', :as => :check_subdomain
  
  #Restricted to subdomain
  constraints(Subdomain) do    
    resources :accounts, :only => [:show, :edit, :index]
    resources :expenses
    resources :invoices do
      collection do
        get 'active'
        get 'draft'
        get 'due'
      end
    end
    get '/dashboard' => 'accounts#dashboard', :as => :dashboard
    root :to => "accounts#dashboard"
  end
  
  resources :accounts, :only => [:new, :create] , :constraints => { :subdomain => /www/ }
  
end
