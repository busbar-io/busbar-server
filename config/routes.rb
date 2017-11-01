require 'sidekiq/web'

Rails.application.routes.draw do
  CRUD_ACTIONS = %w(index create show update destroy).freeze

  get '/health' => 'health#check', as: 'health_check'

  resources :apps, only: CRUD_ACTIONS do
    resources :environments, param: :name do
      match '/settings/bulk', to: 'settings/bulk#update', as: 'bulk_settings', via: %i(put patch)

      resources :settings,    only: %i(index show update destroy)
      resources :deployments, only: %i(create)
      match '/publish', controller: 'publish', action: 'update', via: %i(put patch)
      match '/resize', controller: 'resize', action: 'update', via: %i(put patch)
      post '/clone', controller: 'environment_clone', action: 'create'

      match '/builds/latest', controller: 'builds', action: 'latest', via: :get

      resources :components, param: :type, only: %i(index show update) do
        get '/log', controller: 'components/logs', action: 'show'

        match '/scale', controller: 'scale', action: 'update', via: %i(put patch)
        get '/scale', controller: 'scale', action: 'show'

        match '/resize', controller: 'components/resize', action: 'update', via: %i(put patch)
      end
    end
  end

  resources :databases, only: %w(index create show destroy)

  mount Sidekiq::Web, at: '/sidekiq'
end
