# Astro Starlight - Serve-only container
# The site is scaffolded locally by psake and mounted at /site
FROM node:22-slim

WORKDIR /site

EXPOSE 4321

CMD ["sh", "-c", "npm install && npm run dev -- --host 0.0.0.0"]
