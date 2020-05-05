FROM ruby:2.7.1

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN gem install code-scanning-rubocop -v0.2.0

ARG GITHUB_WORKSPACE

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]