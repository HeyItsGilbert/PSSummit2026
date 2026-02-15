# Docusaurus - Serve-only container
# The site is scaffolded locally by psake and mounted at /site
FROM node:22-slim

WORKDIR /site

EXPOSE 3000

CMD ["sh", "-c", "npm install && npx docusaurus start --host 0.0.0.0"]
