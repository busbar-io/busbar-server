module Configurations
  extend Mixlib::Config

  Dotenv::Railtie.load if Rails.env.test? || Rails.env.development?

  class SharedConfigFetcher
    def self.cluster_name
      ENV.fetch('CLUSTER_NAME')
    end

    def self.private_domain_name
      ENV.fetch('PRIVATE_DOMAIN_NAME')
    end

    def self.public_domain_name
      ENV.fetch('PUBLIC_DOMAIN_NAME')
    end
  end

  config_context :cluster do
    default :name, SharedConfigFetcher.cluster_name
  end

  config_context :interfaces do
    config_context :private do
      default :domain_name, SharedConfigFetcher.private_domain_name
    end

    config_context :public do
      default :domain_name, SharedConfigFetcher.public_domain_name
    end

    default :ssl_certificate, ENV.fetch('SSL_CERTIFICATE', nil)
  end

  config_context :dns do
    config_context :private do
      default :domain_name, SharedConfigFetcher.private_domain_name
      default :provider, ENV.fetch('PRIVATE_DNS_PROVIDER', 'route53')
    end

    config_context :public do
      default :domain_name, SharedConfigFetcher.public_domain_name
      default :provider, ENV.fetch('PUBLIC_DNS_PROVIDER', 'route53')
    end
  end

  config_context :elastic_search do
    default :url, ENV.fetch('ELASTIC_SEARCH_URL',
                            "http://logger.#{SharedConfigFetcher.cluster_name}."\
                            "#{SharedConfigFetcher.private_domain_name}")
  end

  config_context :mongoid do
    default :uri, ENV.fetch('MONGODB_URL',
                            "mongodb://127.0.0.1:27017/busbar_#{Configurations.env}")
  end

  config_context :databases do
    default :destruction_wait, ENV.fetch('DB_DESTRUCTION_WAIT', 5).to_i
  end

  config_context :environments do
    default :default_name, ENV.fetch('DEFAULT_ENV', 'develop')
  end

  config_context :manifest do
    default :unavailable_percentage, ENV.fetch('UNAVAILABLE_PERCENTAGE', 8).to_i
  end

  config_context :log do
    default :ttl, ENV.fetch('LOG_TTL',  7 * 24 * 60 * 60).to_i

    config_context :components do
      default :size, ENV.fetch('DEFAULT_COMPONENT_LOG_SIZE', 100).to_i
    end
  end

  config_context :redis do
    default :url, ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379')
  end

  config_context :slug_builder do
    default :base_path, ENV.fetch('SLUG_PATH', Dir.tmpdir)
  end

  config_context :docker do
    default :private_registry_url, ENV.fetch('DOCKER_REGISTRY_URL', '127.0.0.1:5000')
    default :base_images_registry_url, ENV.fetch('BASE_IMAGES_REGISTRY_URL', 'busbario')
  end

  config_context :java do
    default :base64_maven_settings, ENV.fetch('BASE64_MAVEN_SETTINGS')
  end

  config_context :git do
    default :deployment_key_file, ENV.fetch('DEPLOYMENT_KEY_FILE_PATH', 'config/deploy.pem')
    default :deployment_key, ENV.fetch('DEPLOYMENT_KEY',
                                       "Please Set DEPLOYMENT_KEY Environment Variable on Busbar\n")
  end

  config_context :hooks do
    default :url, ENV.fetch('HOOKS_URL', nil)
  end

  config_context :kubernetes do
    default :label_prefix, ENV.fetch('KUBERNETES_LABEL_PREFIX', 'busbar.io')
  end

  config_context :sidekiq do
    default :password, ENV.fetch('SIDEKIQ_PASSWORD', 'admin')
  end

  config_context :locks do
    prefix = ENV.fetch('LOCK_PREFIX') do
      Rails.env == 'production' ? 'busbar' : ['busbar', Rails.env].join('_')
    end

    default :prefix, prefix

    default :default_timeout, ENV.fetch('LOCK_TIMEOUT', 20).to_i.minutes
  end

  config_context :buildpacks do
    config_context :ruby do
      default :latest_version,     ENV.fetch('BUSBAR_BUILDPACKS_RUBY_LATEST_VERSION', '2.3.4')
      default :supported_versions, ENV.fetch('BUSBAR_BUILDPACKS_RUBY_SUPPORTED_VERSIONS',
                                             '2.2.0,2.2.2,2.2.3,2.2.4,2.3.0,2.3.1,2.3.4').split(',')
    end
  end

  config_context :aws do
    default :access_key_id,      ENV.fetch('AWS_ACCESS_KEY_ID', nil)
    default :secret_access_key,  ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    default :ssl_certificate_id, ENV.fetch('AWS_SSL_CERTIFICATE_ID', nil)
    default :region, ENV.fetch('AWS_REGION', nil)
  end

  config_context :dnsimple do
    default :access_token, ENV.fetch('DNSIMPLE_ACCESS_TOKEN', nil)
    default :account_id,   ENV.fetch('DNSIMPLE_ACCOUNT_ID', 0)
  end

  config_context :apps do
    default :node_selector, ENV.fetch('APPS_NODE_SELECTOR', nil)
  end
end
