require File.expand_path('../boot', __FILE__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require File.expand_path('../configurations', __FILE__)

module Busbar
  class Application < Rails::Application
    config.time_zone = 'UTC'

    config.i18n.default_locale = :en

		# config.middleware.insert_before 0, "Rack::Cors", :debug => true, :logger => (-> { Rails.logger }) do
		config.middleware.insert_before 0, "Rack::Cors", :debug => false, :logger => (-> { Rails.logger }) do
			allow do
				origins '*'

				resource '/scale',
					:headers => :any,
					:methods => [:get, :post, :delete, :put, :patch, :options, :head],
					:max_age => 0

				resource '*',
					:headers => :any,
					:methods => [:get, :post, :delete, :put, :patch, :options, :head],
					:max_age => 0
			end
		end

    %w(lib/mixins
       app/factories
       app/repositories
       app/buildpacks
       app/jobs
       app/services
       app/services/interfaces).each do |path|
      config.eager_load_paths << [Rails.root, path].join('/')
    end

    config.use_standard_json_time_format = true
  end
end
