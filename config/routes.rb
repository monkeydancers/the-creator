TheCreator::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resource :welcome

  resource :configure do 
    get :class_info
    post :new_class
    resources :classes, controller:'gameobject_classes'
    resources :properties, controller:'gameobject_class_properties'
  end

  resource :create do 
    get :structure
    get :identifier

    post :remove
    post :property, to: 'creates#save_property'
    get :property, to: 'creates#load_property'
  end

  resources :rules do 

  end

end
