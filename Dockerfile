FROM ruby:2.6.3
# uses Debian jessie

# Install apt based dependencies required to run Rails as 
# well as RubyGems. As the Ruby image itself is based on a 
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  nodejs

# The base container already has RubyGems and Bundler installed, but not Rails
RUN gem install rails -v 5.2.3

# Copy the Gemfile and install the project's dependencies
RUN mkdir -p home/gemfiles 
WORKDIR home/gemfiles
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
RUN mkdir -p /home/peeps-uuids
WORKDIR /home/peeps-uuids

# Expose port 3000 to the Docker host, so we can access it 
# from the outside.
EXPOSE 3000

# The main command to run when the container starts. Also 
# tell the Rails dev server to bind to all interfaces by 
# default.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
