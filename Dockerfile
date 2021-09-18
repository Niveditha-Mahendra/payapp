FROM ruby:2.6.3

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \ 
    && apt install -y nodejs shared-mime-info && \
    npm install -g yarn && yarn add @rails/webpacker@next && bundle exec rails webpacker:install

ENV app /app
RUN mkdir $app
WORKDIR $app
ADD . $app

ENTRYPOINT ["./entrypoint.sh"]
