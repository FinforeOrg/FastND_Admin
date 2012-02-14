FinforeAdmin::Application.routes.draw do

  resources :company_competitors

  resources :populate_feed_infos

  resources :feed_apis

  resources :feed_infos do
    collection do
      get :count_users
      get :count_tags
      get :search
      post :search
      get :prices
      post :prices
      get :destroy_ticker
      delete :destroy_ticker
    end
  
    member do
      get :tickers
      post :tickers
      get :users
      post :create_ticker
      get :tab_config
      get :populate_config
    end
  end

  resources :profile_categories

  resources :profiles do
    collection do
      get :count_suggestions
      get :count_users
      get :count_populates
    end
  end

  resources :users do
    collection do
      get :count_columns
      get :count_companies
      get :count_focuses
      get :autocomplete
      post :autocomplete
    end

    member do
      get :columns
      get :company_tabs
      get :update_public
    end
    
    resources :feed_accounts do
      collection do
        get :column_auth
        get :column_callback
      end
      resources :user_feeds
    end
    
    resources :user_company_tabs
    resources :user_columns
  end

  resources :user_sessions do
    get 'new_worker', :on => :collection
  end

  resources :dashboards do
    collection do
      get :chart_users
      get :chart_suggestion
      get :ip_info
    end
  end

#namespace :noticeboards do
#   resources :noticeboard_users do
#     member do
 #       get :update_status
  #      get :edit_role
   #     post :edit_role
  #  end
  # end
   # resources :noticeboard_comments
    #resources :noticeboard_posts
    #end

  #resources :noticeboard_role_users

  #resources :noticeboard_roles  

  root :to => "user_sessions#new"
  match "/login" => "user_sessions#new", :as => "login"
  match "/logout" => "user_sessions#destroy", :conditions => {:method => :get}, :as => "logout"
  match '/suggestions' => "feed_infos#index", :as => "suggestions"
  match '/company_tabs' => "company_competitors#index", :as => "company_tabs"
  match '/focuses' => "profile_categories#index", :conditions => {:method => [:get,:post]}, :as => "focuses"
  match '/suggestions/:action/:filter_by/in/:profile_ids/:keyword' => "feed_infos#search", :as => "info_search"
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
