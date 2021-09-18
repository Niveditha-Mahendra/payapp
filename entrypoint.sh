#!/bin/sh

bundle exec rake assets:precompile

RAILS_SERVE_STATIC_FILES=true RAILS_ENV=production RAILS_LOG_TO_STDOUT=true bundle exec rails server -b 0.0.0.0 -p 8080
