Mashoutable::Application.routes.draw do
  match '/auth/:provider/callback' => 'authorization#create'

  match 'mashout/preview'   => 'dashboard#preview_mashout', :via => :get,     :as => :mashout_preview
  match 'mashout/create'    => 'dashboard#create_mashout',  :via => :post,    :as => :mashout_create
  match 'shoutout/create'   => 'dashboard#create_shoutout', :via => :post,    :as => :shoutout_create
  match 'bestie/delete'     => 'dashboard#delete_bestie',   :via => :delete,  :as => :delete_bestie

  match 'contact-us/message' => 'content#message', :via => :post, :as => :contact_us_message
  
  match 'contact-us'          => 'content#contact_us', :as => :contact_us
  match 'about-us'            => 'content#about_us',   :as => :about_us
  match 'blog'                => 'content#blog'
  
  match 'dashboard'           => 'dashboard#index'
  match 'dashboard/tool'      => 'dashboard#tool'
  match 'dashboard/besties'   => 'dashboard#besties'
  match 'dashboard/mashout'   => 'dashboard#mashout'
  match 'dashboard/blastout'  => 'dashboard#blastout'
  match 'dashboard/shoutout'  => 'dashboard#shoutout'
  match 'dashboard/pickout'   => 'dashboard#pickout'
  match 'dashboard/signout'   => 'dashboard#signout'
  match 'dashboard/trends'    => 'dashboard#trends',    :via => :get, :as => :trend_source
  match 'dashboard/targets'   => 'dashboard#targets',   :via => :get, :as => :target_source
  
  match '/'                   => 'content#home',        :as => :home
  
  root :to => "content#home"

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
