---
marp: true
theme: summit-2026
paginate: false
---
<!-- _class: title -->
# <span class="black-text">Markdown Madness</span>

## <span class="purple-text">Static Sites for Fun & Profit</span>

<span class="name">Gilbert Sanchez</span>
<span class="handle">@HeyItsGilbert</span>

<!---

10:30a Thursday

Description:
You already write Markdown. README.md, meeting notes, maybe even your grocery list. But what if that Markdown could become a blog, a polished docs site, a personal resume, or even a link-in-bio page? Turns out, it can - and the tools are way cooler (and easier) than you think.

In this session, we'll go on a whirlwind tour of static site generators: Jekyll, MkDocs, Hugo, Docusaurus, plus some delightful "non-docs" options like jsonresume and littlelink.io. We'll talk about what each is good at, how to pick the right one, and how to actually get it online without sacrificing weekends to YAML. Along the way, we'll also cover Markdown/MDX tricks and VS Code extensions to keep things sane.

Whether you're looking to document your project, polish your personal brand, or just hack together something fun, you'll leave knowing how to take plain Markdown and ship it as something awesome.

Key Take-Aways from your session:
- Learn the strengths and tradeoffs of popular static site generators (Jekyll, MkDocs, Hugo, Docusaurus, etc.).
- Discover "non-docs" generators like jsonresume and littlelink.io.
- Understand Markdown vs. MDX and when each makes sense.
- Use VS Code tools to lint, edit, and manage Markdown like a pro.
- Deploy your site easily (GitHub Actions, Netlify, containers) without breaking a sweat.

--->
---
<!-- class: centered -->

# Agenda

- Slides
- 10m Break
- Demos
- Q&A

<!--

- Slides (~25m)
  - Markup Languages
  - Markdown Flavors
  - Static Sites
  - Tools
- 10m Break
- Demos
- Q&A

I can fill 90m+ on this topic, but beyond just Q&A I want to step through real
requests.
-->

---

<!-- _class: sponsors -->
<!-- _paginate: skip -->

# Thanks!

---

# Hey! It's Gilbert

<!-- Author slide -->

- Staff Software Development Engineer
- ADHD 🌶️🧠
- [Links.GilbertSanchez.com](https://links.gilbertsanchez.com)

![bg right](image-2.png)

<!--
Formerly known as Senor Systems Engineer at Meta

Audience Poll: Who has a blog?

My history as a "webmaster"
-->

---

<!-- _class: big-statement -->

# But First... A Warning

### _This talk is mostly about markdown... but anything goes when it comes to static generation!_

---
<!-- transition: fade -->
<!-- _class: big-statement --->

# What is Markdown?

### _A lightweight **markup** language for easily formatting text._

---

# What is Markdown?

A lightweight **markup** language for easily formatting text.

- Markdown (md)
- Asciidoc (adoc)
- reStructuredText (reST)

---
<!-- _class: big-statement -->

![you think thats ppt you're watching?](morpheus.gif)

_You think this is PowerPoint you're watching?_

<!--
This is actually marp!
-->

---

# Flavor Examples

- ~~Strikethroughs~~
- Footnotes [^1]
- ^Superscript
- Tables
- Math
- Mermaid
- [x] Task List

<span class="small">
[^1]: Give 5 stars
</span>

<!--
Flavors

- GitHub Flavored
- ExtraMark
- etc.

-->

---

<!--
header: ''
_footer: 'https://xkcd.com/927/'
-->

![bg contain](image.png)

---

# Hello world time!

<div class="columns">
<div>

```md
# Hello

Hello world!

## Turtles

I *like* them!
```

</div>
<div style="border-left: 4px solid var(--primary-color); padding-left: 1.5rem;">

<h1 style="font-size: 2rem; margin: 0.2em 0; color: var(--primary-color);">Hello</h1>
<p style="font-size: 1.75rem; margin: 0.2em 0;">Hello world!</p>
<h2 style="font-size: 1.85rem; margin: 0.4em 0 0.2em; color: var(--secondary-color);">Turtles</h2>
<p style="font-size: 1.75rem; margin: 0.2em 0;">I <em>like</em> them!</p>

</div>
</div>

---

# Front Matter

Front matter is YAML provides metadata or configuration.

```markdown
---
title: Hello
---
# Hello

Hello world!
```

<!--
There is also back matter at the bottom.
-->

---

# Static Sites

Static sites are:

1. CLI-generated
2. Output as HTML
3. No runtime server.

---

# Static Site Generators

| Name | Lang | Good For |
|--|--|--|
| Jekyll | Ruby | Docs, blogs. |
| MkDocs | Python | Docs |
| Hugo | Golang | Docs, Blogs, and more. |
| Docusaurus | React | Docs |

---

# Tools

- markdownlint: Markdown best practices.
- Vale: Prose syntax.

---

# VSCode Extensions

- GitHub Markdown Preview
- markdownlint
- Reflow Markdown
- Markdown All in One

---

<!-- _class: no-bg -->

# FrontMatter CMS

VSCode Extension to punches above it's weight class.

![screenshot of frontmatter CMS](image-1.png)

---

<!--

Goal: 25m - ~11a

--->

# Deploying Services

- GitHub Pages
- Netlify
- Cloudflare
- Vercel
- So many more...

---

<!-- _class: big-statement -->
# Break Time  - 10m

```powershell
Start-Sleep -Minutes 10
```

---

<!-- _class: big-statement -->
# Demo Time

---
<!-- _class: title -->
# <span class="gradient-text">THANK YOU</span>

## <span class="primary">Feedback</span> is a <span class="quaternary">gift</span>

<p class="name">Please review this session via the mobile app</p>
<p class="handle">Questions? Find me @heyitsgilbert</p>
