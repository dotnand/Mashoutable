Mashoutable::Application.routes.draw do
  # 3rd party authentication providers (twitter, facebook, etc...)
  match '/auth/:provider/callback' => 'authorization#create'

  # mashouts
  match 'mashouts/preview'    => 'dashboard#preview_mashout', :via => :get,     :as => :mashout_preview
  match 'mashouts/create'     => 'dashboard#create_mashout',  :via => :post,    :as => :mashout_create

  # shoutouts
  match 'shoutouts/create'    => 'dashboard#create_shoutout', :via => :post,    :as => :shoutout_create
  
  # blastouts
  match 'blastouts/create'    => 'dashboard#create_blastout', :via => :post,    :as => :blastout_create
  
  # besties
  match 'besties/delete'      => 'dashboard#delete_bestie',   :via => :delete,  :as => :delete_bestie
  match 'besties/new'         => 'dashboard#create_bestie',   :via => :post,    :as => :create_bestie

  # videos  
  match 'videos/new'          => 'dashboard#create_video',    :via => :post,    :as => :create_video
  match 'videos/:guid'        => 'dashboard#delete_video',    :via => :delete,  :as => :delete_video
  match 'videos/(:guid)'      => 'dashboard#video_playback',  :via => :get,     :as => :video_playback
  match 'videos/:guid'        => 'dashboard#update_video',    :via => :post,    :as => :update_video

  # contact us & misc
  match 'contact-us/message'  => 'content#message',     :via => :post, :as => :contact_us_message
  match 'contact-us'          => 'content#contact_us',  :as => :contact_us
  match 'about-us'            => 'content#about_us',    :as => :about_us
  match 'blog'                => 'content#blog'
  
  # dashboard
  match 'dashboard'           => 'dashboard#index'
  match 'dashboard/tool'      => 'dashboard#tool'
  match 'dashboard/besties'   => 'dashboard#besties'
  match 'dashboard/videos'    => 'dashboard#videos'
  match 'dashboard/mashout'   => 'dashboard#mashout'
  match 'dashboard/blastout'  => 'dashboard#blastout'
  match 'dashboard/shoutout'  => 'dashboard#shoutout'
  match 'dashboard/pickout'   => 'dashboard#pickout'
  match 'dashboard/signout'   => 'dashboard#signout'
  match 'dashboard/trends'    => 'dashboard#trends',    :via => :get, :as => :trend_source
  match 'dashboard/targets'   => 'dashboard#targets',   :via => :get, :as => :target_source
  
  # root
  match '/'                   => 'content#home',        :as => :home
  
  root :to => "content#home"
end
