require 'simplecov'

SimpleCov.start do
  add_filter 'vendor'
  add_filter 'spec'
  add_filter 'config'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  Sidekiq::Testing.fake!

  config.before(:each) do
    Timecop.freeze(Time.new(2015, 1, 1, 0, 0, 0, '+00:00'))
  end

  config.after(:each) do
    Timecop.return
  end

  %i(integration request).each do |type|
    config.after(:each, type: type) do
      Mongoid.default_client.collections.reject { |c| c.name.start_with?('system.') }.each(&:drop)
    end
  end

  # Establish a fake connection to MongoDB, so it is not necessary to run mongod for unit tests
  config.before(:each, type: :unit) do
    fake_client = instance_double(Mongo::Client)
    allow(Mongo::Client).to receive(:new).and_return(fake_client)

    fake_database = instance_double(Mongo::Database, name: 'test')
    allow(fake_client).to receive(:database).and_return(fake_database)
    allow(fake_client).to receive(:with).and_return(fake_database)
    allow(fake_client).to receive(:close)

    fake_collection = instance_double(Mongo::Collection)
    allow(fake_database).to receive(:[]).and_return(fake_collection)

    fake_view = instance_double(Mongo::Collection::View)
    allow(fake_collection).to receive(:find).and_return(fake_view)

    fake_document = {}
    allow(fake_view).to receive(:limit).and_return([fake_document])
  end

  config.after(:each, type: :unit) do
    Mongoid::Clients.disconnect
    Mongoid::Clients.clear
  end
end
