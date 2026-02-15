# Hugo - Serve-only container
# The site is scaffolded locally by psake and mounted at /site
FROM hugomods/hugo:exts

WORKDIR /site

EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0"]
