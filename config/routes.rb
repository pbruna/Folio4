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
    get 'contacts/new_from_modal' => 'contacts#new_from_modal', :as => :new_contact_from_modal
    get 'invoices/:id/activate_from_modal' => 'invoices#activate_from_modal', :as => :activate_invoice_from_modal
    patch 'invoices/:id/change_status' => 'invoices#change_status', :as => :change_invoice_status
    patch 'invoices/:id/cancel' => 'invoices#cancel', :as => :cancel_invoice
    patch 'invoices/:id/patch' => "invoices#pay", :as => :pay_invoice
    get 'accounts/check_invoice_number_availability' => 'accounts#check_invoice_number_availability', as: :check_invoice_number_availability
    resources :accounts, :only => [:show, :edit, :index, :update, :check_invoice_number_availability] do

    end
    resources :expenses
    resources :users
    resources :contacts
    resources :companies do
      resources :invoices
      resources :expenses
      resources :contacts
    end
    resources :invoices do
      get :autocomplete_company_name, :on => :collection
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
