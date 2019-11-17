# Author: noraj

# Official verified image
FROM ruby:2.5.7-alpine3.10

# date
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime

# copy files
COPY ./website/ /usr/src/app/

WORKDIR /usr/src/app

## INSTALL ##
# Print out ruby version for debugging
RUN ruby -v
# Bundler is not installed with the image
RUN gem install bundler --no-document
# install nproc (coreutils) for bundle -j
# install git for building the gemfile
# install make, gcc for building gem native extension (commonmarker)
# libc-dev for musl-dev dependency (stdlib.h) needed by gcc
# install g++ and libstdc++ for building eventmachine
RUN apk --no-cache add coreutils git build-base libstdc++ libffi-dev
# Install sqlite
RUN apk --no-cache add sqlite sqlite-dev sqlite-libs sqlite-static
# Install gem dependencies into ./vendor/ruby
RUN bundle install -j $(nproc) --path vendor

## BUILD ##

# drop privileges
RUN adduser -s /bin/true -u 1337 -D -H noraj
USER noraj


EXPOSE 9999

CMD bundle exec ruby ./webserver.rb
