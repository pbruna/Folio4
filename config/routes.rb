Folio::Application.routes.draw do
  # Handle incoming email
  mount_griddler
  
  # Handle users authentication
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
    get 'accounts/check_invoice_number_availability' => 'accounts#check_invoice_number_availability', as: :check_invoice_number_availability
    get 'invoices/:id/activate_from_modal' => 'invoices#activate_from_modal', :as => :activate_invoice_from_modal
    patch 'invoices/:id/change_status' => 'invoices#change_status', :as => :change_invoice_status
    patch 'invoices/:id/cancel' => 'invoices#cancel', :as => :cancel_invoice
    patch 'invoices/:id/pay' => "invoices#pay", :as => :pay_invoice
    patch 'invoices/:id/activate' => "invoices#activate", :as => :activate_invoice
    get 'invoices/:id/clone' => "invoices#clone", :as => :clone_invoice
    get 'invoices/:id/attachments', to: redirect("/invoices/%{id}#invoice-attachments")
    get 'dtes/status/:invoice_id' => "dtes#status", as: :status
    resources :accounts, :only => [:show, :edit, :index, :update, :check_invoice_number_availability] do

    end
    resources :dtes
    resources :expenses
    resources :users
    resources :contacts
    resources :comments
    resources :attachments
    resources :companies do
      get 'invoices', :on => :member
      get 'contacts', :on => :member
      get 'expenses', :on => :member
    end
    resources :invoices do
      get :autocomplete_company_name, :on => :collection
      collection do
        get 'active'
        get 'draft'
        get 'due'
      end
    end
    resources :money_accounts
    get '/dashboard' => 'accounts#dashboard', :as => :dashboard
    root :to => "accounts#dashboard"
  end
  
  resources :accounts, :only => [:new, :create] , :constraints => { :subdomain => /(app|www|folio)/ }
  
end
