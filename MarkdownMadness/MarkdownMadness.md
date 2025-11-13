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

# First: A Warning

<div class="callout primary">

### 💡 Heads up!

This is talk is mostly about markdown...

But anything goes when it comes to static generation!

</div>

---

<!-- _class: no_background --->

# What is Markdown?

A lightweight markup language for easily formatting text.

---

<span class="center">

![you think thats ppt your reading?](image.png)
</span>

<!--
This is actually marp!
-->

---
<!--
header: "..............................................................................................................................................................................now footer"
footer: "............................Give Gilbert 5 stars!"
-->

# Flavor Examples

- ~~Strikethroughs~~
- Footnotes [^1]
- ^Superscript
- Tables
- Math
- Mermaid
- [x] Task List

<span class="small">
[^1]: "Now look at the header"
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

# Static Sites

Static sites are:

1. Typically generated with a CLI tool
2. Output as HTML.
3. Dynamic sites changes

---

# Static Site Generators

1. Jekyll
2. MkDocs
3. Hugo
4. Docusaurus
5. Astro

---

# Hello world time!

```md
# Hello

Hello world!
```

---
<!-- _class: title -->

## <span class="black-text">THANK</span> <span class="purple-text">YOU!</span>

Feedback is a gift. Please review this session via the mobile app.
