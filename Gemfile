source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'sprockets', '~> 3.7.2'
gem 'mixlib-config', '2.2.18', require: 'mixlib/config'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'puma'
gem 'sidekiq'
gem 'mongoid'
gem 'aasm', '~> 4.9.0'
gem 'virtus'
gem 'foreman'
gem 'rake'
gem 'fog-aws'
gem 'aws-sdk'
gem 'ec2-metadata'
gem 'dnsimple'
gem 'sinatra', require: false
gem 'redis-namespace'
gem 'pry-rails'
gem 'java-properties'
gem 'elasticsearch'
gem 'rack-cors', require: 'rack/cors'

gem "actionview", ">= 4.2.11.1"
gem "nokogiri", ">= 1.8.5"
gem "activejob", ">= 4.2.11"
gem "rack", ">= 1.6.11"
gem "loofah", ">= 2.3.1"

group :development, :test do
  gem 'dotenv-rails'
  gem 'spring-commands-rspec'
  gem 'rspec-rails'
  gem 'rspec-context-private'
  gem 'jazz_fingers'
end

group :development do
  gem 'spring', '2.0.2'
  gem 'rubocop', '~> 0.49.0', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'timecop'
  gem 'webmock'
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'codecov', require: false
end

group :production do
  gem 'rails_12factor'
end
