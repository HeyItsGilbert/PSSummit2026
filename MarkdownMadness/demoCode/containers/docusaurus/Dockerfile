# Docusaurus - Static Site Generator (React/Node.js)
# Serves on port 3000 (mapped to 4003 in compose)
FROM node:22-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /site

# Scaffold a new Docusaurus site
RUN npx --yes create-docusaurus@latest site classic --javascript

WORKDIR /site/site

# Copy sample content from the build context (demoCode/)
# docs/index.md goes to intro.md (the default landing doc)
COPY docs/index.md docs/intro.md
COPY docs/getting-started.md docs/getting-started.md
COPY docs/showcase.md docs/showcase.md
COPY blog/morning-coffee.md blog/2026-02-15-morning-coffee.md
COPY images/ static/img/

# Add sidebar_position to intro.md so Docusaurus uses it as the docs landing page
RUN sed -i 's/^---$/---\nsidebar_position: 0/' docs/intro.md && \
    sed -i '0,/sidebar_position: 0/!{s/sidebar_position: 0//}' docs/intro.md

# Remove the placeholder blog posts and docs that ship with the scaffold
RUN rm -f blog/2019-*md blog/2021-*md blog/2023-*md docs/tutorial-*/* 2>/dev/null; \
    rm -rf docs/tutorial-basics docs/tutorial-extras 2>/dev/null; true

RUN npm install

EXPOSE 3000

CMD ["npx", "docusaurus", "start", "--host", "0.0.0.0"]
