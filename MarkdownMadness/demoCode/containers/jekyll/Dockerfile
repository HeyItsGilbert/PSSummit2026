# Jekyll - Serve-only container
# The site is scaffolded locally by psake and mounted at /site
FROM ruby:3.3-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential git && \
    rm -rf /var/lib/apt/lists/*

RUN gem install jekyll bundler

WORKDIR /site

EXPOSE 4000

CMD ["sh", "-c", "bundle install && bundle exec jekyll serve --host 0.0.0.0"]
