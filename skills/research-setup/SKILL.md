---
name: research-setup
description: Interactive setup wizard that configures a new project for the social-science-research plugin. Asks the user questions about their field, institution, journals, datasets, key researchers, and R color palette, then writes the answers into references/domain-profile.md, rules/r-code-conventions.md, and CLAUDE.md. Make sure to use this skill first whenever a user is starting fresh or wants to configure the plugin. Triggers include: "set up my project", "configure the plugin", "run setup", "initialize this project", "I just installed the plugin", "set my field", "set my institution", "configure my domain profile", or any request to personalize the plugin for a specific research context.
argument-hint: "(no arguments needed)"
allowed-tools: ["Read", "Write", "Edit", "Glob"]
---

# Research Setup Wizard

You are running an interactive setup wizard. Your job is to ask the user a series of questions, collect their answers, and then write those answers into the project config files. Work through the sections below in order, asking each group of questions together so the user can answer them in one message. Do not ask one question at a time — group related questions.

After all answers are collected, write all files in one pass. Confirm what was written at the end.

---

## Step 0: Check Existing Config

Before asking anything, read these files silently:
- `CLAUDE.md`
- `references/domain-profile.md`
- `rules/r-code-conventions.md`

If any file already has real content (not just placeholder brackets), tell the user: *"I found existing config in [file]. I'll show you what's there and you can confirm or update each section."* Then proceed, pre-filling your questions with the current values.

---

## Step 1: Identity & Project

Ask:

> **Let's set up your research project. I'll ask a few questions in groups — answer however much you know, and skip anything that doesn't apply yet.**
>
> **About you and your project:**
> 1. What is your **name** (for paper authorship)?
> 2. What is your **institution** (university or organization)?
> 3. What is your **field or subfield**? *(e.g., Labor Economics, Public Health, Political Science, Sociology)*
> 4. What is the **working title** of your current project? *(or leave blank to fill in later)*

---

## Step 2: Journals

Ask:

> **Journals — your Librarian agents search these for literature reviews.**
>
> 5. List your **top 5 primary journals** (most prestigious / most relevant to your work). Include the journal URL if you know it.
> 6. List **3 secondary journals** (subfield or adjacent journals you also follow).
>
> *Example primary: American Economic Review — https://www.aeaweb.org/journals/aer*

---

## Step 3: Datasets

Ask:

> **Common Datasets — your Explorer agents check these first when hunting for data.**
>
> 7. List any **datasets commonly used in your field or project** (name, provider, public/restricted, URL if known). Add as many or as few as you like.
>
> *Example: CPS — Bureau of Labor Statistics — Public — https://www.bls.gov/cps/*
>
> *(Skip if you don't have datasets in mind yet — you can always add them to `references/domain-profile.md` later.)*

---

## Step 4: Key Researchers

Ask:

> **Key Researchers — Librarian agents use these for author-targeted searches.**
>
> 8. List any **prominent researchers** whose recent work is most relevant to your field. Include their institution and Google Scholar or SSRN profile URL if you have it.
>
> *Example: Raj Chetty — Harvard — https://scholar.harvard.edu/chetty*
>
> *(Optional — skip if you'd rather add these later.)*

---

## Step 5: R Color Palette

Ask:

> **R Visualization Colors — used by your r-reviewer agent and r-code-conventions rule.**
>
> 9. What is your **institution's primary color** (hex code)? *(e.g., #012169 for Duke blue)*
> 10. What is your **institution's secondary color** (hex code)? *(e.g., #f2a900 for Duke gold)*
>
> *(If you don't know your institution's hex codes, search "[institution name] brand colors" or brand.yourschool.edu. You can also skip and fill in later.)*

---

## Step 6: Write Config Files

Once you have the user's answers, write or update the following files:

### `references/domain-profile.md`

Replace all placeholder sections with the user's answers. Keep all comments (`<!-- ... -->`). Keep the Working Paper Repositories section unchanged (it's pre-filled). Only replace the sections covered by the user's answers; leave anything unanswered as the original placeholder.

Use this structure:

```markdown
# Domain Profile

<!-- Fill in this file for your field. It is read by the Librarian agent (lit-review)
     and the Explorer agent (data-finder) to focus their searches. -->

## Field

[user's field]

---

## Top 5 Journals

<!-- Librarian 1 searches these first. List in priority order. -->

- [journal 1 name] — [URL if provided]
- [journal 2 name] — [URL if provided]
[... etc]

## Secondary Journals

<!-- Librarian 2 searches these. Include subfield and adjacent journals. -->

- [journal 1]
- [journal 2]
- [journal 3]

---

## Working Paper Repositories

<!-- Pre-filled. Edit search URL patterns for your field's keywords. -->

- **NBER:** https://www.nber.org/papers — search: https://www.nber.org/search?q=[KEYWORDS]
- **SSRN:** https://www.ssrn.com — search: `site:ssrn.com [KEYWORDS]`
- **IZA:** https://www.iza.org/publications/dp — search: `site:iza.org dp [KEYWORDS]`
- **arXiv (if applicable):** https://arxiv.org/search/ — econ or stat sections

---

## Common Datasets

<!-- Explorer agent checks these first before doing a broader search.
     Add datasets commonly used in your field. -->

<!-- Format: - [Dataset Name] — [Provider] — [Public/Restricted] — [URL] -->

[user's datasets, one per line, or original placeholder if none provided]

---

## Key Researchers / Groups

<!-- Librarian uses these for author-based targeted searches.
     Add prominent researchers whose recent work is most relevant. -->

<!-- Format: - [Name] — [Institution] — [Google Scholar or SSRN URL] -->

[user's researchers, one per line, or original placeholder if none provided]
```

### `rules/r-code-conventions.md`

Edit only the Visual Identity section (Section 4). Replace whatever hex values are currently on the `primary_color` and `secondary_color` lines with the user's colors. If the user skipped colors, leave the existing values unchanged.

Find the lines that match this pattern (the hex value may differ):
```r
primary_color   <- "#______"   # ...
secondary_color <- "#______"   # ...
```

Replace those two lines with:
```r
primary_color   <- "[primary hex]"    # [institution name]
secondary_color <- "[secondary hex]"  # [institution name]
```

### `CLAUDE.md`

Update the project header. Replace the template placeholders:
- `[YOUR PROJECT NAME]` → user's project working title (or leave blank placeholder if skipped)
- `[YOUR INSTITUTION]` → user's institution

---

## Step 7: Confirm

After writing all files, report back:

```
Setup complete. Here's what was configured:

✓ references/domain-profile.md — field, [N] primary journals, [N] secondary journals[, N datasets][, N researchers]
✓ rules/r-code-conventions.md — institutional colors ([primary], [secondary])
✓ CLAUDE.md — project name and institution

You can update any of these manually at any time:
- Add more datasets → references/domain-profile.md
- Add key researchers → references/domain-profile.md
- Adjust R colors or theme → rules/r-code-conventions.md

Run /new-project to start developing your research question.
```

If the user skipped any section, note it in the summary and remind them where to add it later.
