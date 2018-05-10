#
# Dockerfile - Build and Setup Busbar Container - based on https://github.com/docker-library/ruby/blob/a6918175fd506b46bf2d8f899f4faa40e72296fb/2.3/jessie/onbuild/Dockerfile
#

# Base Image
FROM busbario/busbar-base:1.9.0

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app
