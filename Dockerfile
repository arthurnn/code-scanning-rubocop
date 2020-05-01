FROM ruby:2.7.1

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY . .
RUN gem install code-scanning-rubocop

ARG GITHUB_WORKSPACE

ENTRYPOINT ["/entrypoint.sh"]