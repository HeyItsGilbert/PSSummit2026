# MkDocs - Static Site Generator (Python)
# Serves on port 8000 (mapped to 4001 in compose)
FROM python:3.12-slim

RUN pip install --no-cache-dir mkdocs mkdocs-material

WORKDIR /site

# Scaffold a new MkDocs project
RUN mkdocs new .

# Copy sample content from the build context (demoCode/)
COPY docs/index.md docs/index.md
COPY docs/getting-started.md docs/getting-started.md
COPY docs/showcase.md docs/showcase.md
COPY blog/morning-coffee.md docs/morning-coffee.md
COPY images/ docs/images/

# Write mkdocs.yml with Material theme and navigation
RUN cat > mkdocs.yml <<'MKDOCS'
site_name: PowerShell Automation Hub
theme:
  name: material
  palette:
    scheme: default
    primary: blue
    accent: light-blue
  features:
    - navigation.instant
    - navigation.sections

nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Showcase: showcase.md
  - Morning Coffee: morning-coffee.md

markdown_extensions:
  - tables
  - footnotes
  - pymdownx.highlight
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.tasklist:
      custom_checkbox: true
  - pymdownx.arithmatex:
      generic: true
  - admonition
  - attr_list
  - def_list
MKDOCS

EXPOSE 8000

CMD ["mkdocs", "serve", "--dev-addr", "0.0.0.0:8000"]
