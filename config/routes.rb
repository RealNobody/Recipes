Recipes::Application.routes.draw do
  get "measuring_unit/new"

  devise_for :users

  resources :users

  #match ":controller/page/:page", action: :page, via: :get

  resources :measuring_units do
    get 'page/:page', action: :page, on: :collection
    get 'item/new', action: :new_item, on: :collection
    get 'item/:id', action: :item, on: :collection
  end
  resources :measuring_units

  resources :measurement_conversions do
    get 'page/:page', action: :page, on: :collection
    get 'item/new', action: :new_item, on: :collection
    get 'item/:id', action: :item, on: :collection
  end
  resources :measurement_conversions

  resources :measurement_aliases do
    get 'page/:page', action: :page, on: :collection
    get 'item/new', action: :new_item, on: :collection
    get 'item/:id', action: :item, on: :collection
  end
  resources :measurement_aliases

  root to: 'static#index'

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
  # match ':controller(/:action(/:id))(.:format)'

  match ':action', :controller => "static"
end