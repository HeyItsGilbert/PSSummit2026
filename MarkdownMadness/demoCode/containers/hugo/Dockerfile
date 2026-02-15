# Hugo - Static Site Generator (Go)
# Serves on port 1313 (mapped to 4002 in compose)
FROM hugomods/hugo:exts

WORKDIR /site

# Scaffold a new Hugo site
RUN hugo new site . --force

# Install the hugo-book theme via git
RUN git clone --depth 1 https://github.com/alex-shpak/hugo-book.git themes/hugo-book

# Copy sample content from the build context (demoCode/)
COPY docs/index.md content/_index.md
COPY docs/getting-started.md content/docs/getting-started.md
COPY docs/showcase.md content/docs/showcase.md
COPY blog/morning-coffee.md content/posts/morning-coffee.md
COPY images/ static/images/

# Write hugo.toml configuration
RUN cat > hugo.toml <<'HUGO'
baseURL = 'http://localhost:1313/'
languageCode = 'en-us'
title = 'PowerShell Automation Hub'
theme = 'hugo-book'

[params]
  BookMenuBundle = '/menu'
  BookSection = 'docs'
  BookToC = true

[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true
  [markup.highlight]
    style = 'monokai'
    lineNos = false
HUGO

EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0"]
