# MkDocs - Serve-only container
# The site is scaffolded locally by psake and mounted at /site
FROM python:3.12-slim

RUN pip install --no-cache-dir mkdocs mkdocs-material

WORKDIR /site

EXPOSE 8000

CMD ["mkdocs", "serve", "--dev-addr", "0.0.0.0:8000"]
