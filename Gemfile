source 'https://rubygems.org'

gem 'rails', '4.2.5.2'
gem 'mixlib-config', require: 'mixlib/config'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'puma'
gem 'sidekiq'
gem 'mongoid'
gem 'aasm'
gem 'virtus'
gem 'foreman'
gem 'rake'
gem 'fog-aws'
gem 'aws-sdk'
gem 'ec2-metadata'
gem 'dnsimple'
gem 'sinatra', require: false
gem 'redis-namespace'
gem 'jazz_fingers'
gem 'pry-rails'
gem 'java-properties'
gem 'elasticsearch'

group :development, :test do
  gem 'dotenv-rails'
  gem 'spring-commands-rspec'
  gem 'rspec-rails'
  gem 'rspec-context-private'
end

group :development do
  gem 'spring'
  gem 'rubocop', require: false
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
