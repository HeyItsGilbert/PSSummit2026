---
marp: true
theme: summit-2026
paginate: true
---
<!-- _class: title -->
# <span class="black-text">Markdown Madness</span>

## <span class="purple-text">Static Sites for Fun & Profit</span>

<span class="name">Gilbert Sanchez</span>
<span class="handle">@HeyItsGilbert</span>

<!---

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

## Agenda

- Slides
  - Markup Languages
  - Markdown Flavors
  - Static Sites
  - Tools
- 10m Break
- Demos
- Q&A

---
<!-- _class: no_background --->

# Hey! It's Gilbert

<!-- Author slide -->

- Staff Software Development Engineer @ Tesla <span class="small">
Formerly known as Senor Systems Engineer at Meta
</span>
- 🌶️🧠 ADHD
- [Links.GilbertSanchez.com](https://links.gilbertsanchez.com)

![bg right](image-2.png)

<!--
Audience Poll: Who has a blog?

My history as a "webmaster"
-->

---

# First: A Warning

<div class="callout primary">
This is talk is mostly about markdown...

But anything goes when it comes to static generation!
</div>

---
<!-- transition: fade -->
<!-- _class: no_background --->

# What is Markdown?

A lightweight **markup** language for easily formatting text.

---

<!-- _class: no_background --->

# What is Markdown?

A lightweight **markup** language for easily formatting text.

- Markdown (md)
- Asciidoc (adoc)
- reStructuredText (reST)

---

<span class="center">

![you think thats ppt your reading?](image.png)
</span>

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

---

<!--
header: ''
footer: ''
-->

<span class="center">

![Obligatory XKCD: Standards](image-1.png)
</span>

<!--
Flavors

- GitHub Flavored
- ExtraMark
- etc.

-->
---

# Hello world time!

```md
# Hello

Hello world!

## Turtles

I *like* them!
```

---

# Front Matter

Front matter is YAML (usually) at the top of the document that provides metadata or configuration.

```markdown
---
title: Hello
---
# Hello

Hello world!
```

---

# Static Sites

Static sites are:

1. Typically generated with a CLI tool
2. Output as HTML.
3. Dynamic sites changes

---

# Static Site Generators

| Name | Lang | Good For |
|--|--|--|
| Jekyll | Ruby | Simple docs, blogs. |
| MkDocs | Python | Documentation sites. |
| Hugo | Golang | Docs, Blogs, and more. |
| Docusaurus | React | Documentation sites. |
| Astro | Javascript | Docs, Blogs, and more. |

<!---

Target: ~ 3:45p

--->

---

# Tools

- markdownlint: Lint that offers best practices.
- Vale: Prose syntax.

---

# VSCode Extensions

- GitHub Markdown Preview
- markdownlint
- Reflow Markdown
- Markdown All in One

---

# Break Time  - 10m

```powershell
$returnBy = (Get-Date).AddMinutes(10)
```

---

# Demo Time

---

# Deploying

- GitHub Pages
- Netlify

---
<!-- _class: title -->

## <span class="black-text">THANK</span> <span class="purple-text">YOU!</span>

Feedback is a gift. Please review this session via the mobile app.
