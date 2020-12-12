FROM ruby:2.7

RUN apt-get update && apt-get install -y default-libmysqlclient-dev libmariadbclient-dev

COPY Gemfile .

RUN bundle install

COPY app.rb .

CMD bundle exec ruby app.rb
