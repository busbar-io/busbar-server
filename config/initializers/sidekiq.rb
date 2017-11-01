require 'sidekiq/web'

redis_url = Configurations.redis.url

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ['admin', Configurations.sidekiq.password]
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: 'busbar' }
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: 'busbar' }
end
