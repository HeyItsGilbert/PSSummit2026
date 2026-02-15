# Jekyll - Static Site Generator (Ruby)
# Serves on port 4000
FROM ruby:3.3-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential git && \
    rm -rf /var/lib/apt/lists/*

RUN gem install jekyll bundler

WORKDIR /site

# Scaffold a new Jekyll site
RUN jekyll new . --force

# Copy sample content from the build context (demoCode/)
COPY docs/index.md index.md
COPY docs/getting-started.md getting-started.md
COPY docs/showcase.md showcase.md
COPY blog/morning-coffee.md _posts/2026-02-15-morning-coffee.md
COPY images/ images/

# Add Jekyll front matter (layout) to the doc pages.
# The original front matter is preserved; we inject 'layout:' after the opening '---'.
RUN sed -i '0,/^---$/!{0,/^---$/s/^---$/layout: page\n---/}' \
      index.md getting-started.md showcase.md && \
    sed -i '0,/^---$/!{0,/^---$/s/^---$/layout: post\n---/}' \
      _posts/2026-02-15-morning-coffee.md

RUN bundle install

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
