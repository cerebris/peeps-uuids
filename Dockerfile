FROM ruby:2.6.5-slim

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev && \
    apt-get clean

# Enabling app reloading based off of https://stackoverflow.com/questions/37699573/rails-app-in-docker-container-doesnt-reload-in-development
# Sets the path where the app is going to be installed
ARG RAILS_ROOT=/app
ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

# https://www.postgresql.org/docs/current/libpq-connect.html
ENV PG_GSSENCMODE=prefer

# This will be the de-facto directory where all the contents are going to be stored.
WORKDIR $RAILS_ROOT

RUN gem install bundler -v 2.1.2 --no-document && \
    gem install foreman --no-document

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./

RUN bundle config --global frozen 1 && \
    bundle install --without development:test:assets --verbose --jobs 20 --retry 5 --path=vendor/bundle && \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    rm -rf vendor/bundle/ruby/2.6.0/cache/*.gem && \
    find vendor/bundle/ruby/2.6.0/gems/ -name "*.c" -delete && \
    find vendor/bundle/ruby/2.6.0/gems/ -name "*.o" -delete && \
    # Creates the rails and pids directories and all the parents (if they don't exist)
    mkdir -p $RAILS_ROOT/tmp/pids

# Copy the main application.
COPY . ./
