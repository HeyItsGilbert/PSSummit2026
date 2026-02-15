# Astro Starlight - Static Site Generator (Node.js)
# Serves on port 4321 (mapped to 4004 in compose)
FROM node:22-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /site

# Scaffold a new Astro Starlight project
RUN npx --yes create-astro@latest site --template starlight --yes --no-git --install

WORKDIR /site/site

# Copy sample content from the build context (demoCode/)
# index.md becomes index.mdx for Starlight compatibility
COPY docs/index.md src/content/docs/index.mdx
COPY docs/getting-started.md src/content/docs/getting-started.md
COPY docs/showcase.md src/content/docs/showcase.md

# Create blog subdirectory for the blog post
RUN mkdir -p src/content/docs/blog
COPY blog/morning-coffee.md src/content/docs/blog/morning-coffee.md

COPY images/ public/images/

# Update the Starlight sidebar config in astro.config.mjs to reflect our content
RUN cat > astro.config.mjs <<'ASTRO'
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  integrations: [
    starlight({
      title: 'PowerShell Automation Hub',
      sidebar: [
        { label: 'Home', link: '/' },
        { label: 'Getting Started', link: '/getting-started/' },
        { label: 'Showcase', link: '/showcase/' },
        {
          label: 'Blog',
          items: [
            { label: 'Morning Coffee', link: '/blog/morning-coffee/' },
          ],
        },
      ],
    }),
  ],
});
ASTRO

RUN npm install

EXPOSE 4321

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
