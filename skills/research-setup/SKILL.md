---
name: research-setup
description: Interactive setup wizard that configures a new project for the social-science-research plugin. Asks the user questions about their field, institution, journals, datasets, key researchers, and R color palette, then writes the answers into references/domain-profile.md, rules/r-code-conventions.md, and CLAUDE.md. Make sure to use this skill first whenever a user is starting fresh or wants to configure the plugin. Triggers include: "set up my project", "configure the plugin", "run setup", "initialize this project", "I just installed the plugin", "set my field", "set my institution", "configure my domain profile", or any request to personalize the plugin for a specific research context.
argument-hint: "(no arguments needed)"
allowed-tools: ["Read", "Write", "Edit", "Glob", "AskUserQuestion"]
---

# Research Setup Wizard

You are running an interactive setup wizard. Your job is to walk the user through a series of questions using interactive selection menus (AskUserQuestion) wherever possible, collect their answers, and then write those answers into the project config files.

**Key rule:** Use AskUserQuestion for EVERY question where you can offer meaningful preset options. Only fall back to free-text conversation for truly open-ended questions (name, project title, custom entries). The user should be selecting from menus, not typing paragraphs.

After all answers are collected, write all files in one pass. Confirm what was written at the end.

---

## Step 0: Check Existing Config

Before asking anything, read these files silently:
- `CLAUDE.md`
- `references/domain-profile.md`
- `rules/r-code-conventions.md`

If any file already has real content (not just placeholder brackets), tell the user: *"I found existing config in [file]. I'll show you what's there and you can confirm or update each section."* Then proceed, pre-filling your questions with the current values.

---

## Step 1: Field & Identity

Use AskUserQuestion to ask up to 4 questions at once:

**Question 1 — Field** (single select):
- header: "Field"
- question: "What is your field or subfield?"
- options (pick the 4 most common; user can always select "Other"):
  - label: "Economics", description: "Labor, public, development, health, applied micro, etc."
  - label: "Political Science", description: "American politics, comparative, IR, political economy"
  - label: "Sociology", description: "Stratification, organizations, demography, culture"
  - label: "Public Health", description: "Epidemiology, health policy, biostatistics"

**Question 2 — Institution** (single select):
- header: "Institution"
- question: "What is your institution?"
- options (pick 4 well-known research universities; user selects "Other" to type their own):
  - label: "Duke University", description: "Durham, NC"
  - label: "Harvard University", description: "Cambridge, MA"
  - label: "Stanford University", description: "Stanford, CA"
  - label: "UC Berkeley", description: "Berkeley, CA"

**Question 3 — Analysis language** (single select):
- header: "Language"
- question: "What is your primary analysis language?"
- options:
  - label: "R (Recommended)", description: "Full support: coding conventions, figure themes, R reviewer agent"
  - label: "Python", description: "Supported: analysis scripts, figures, diagnostics"
  - label: "Both", description: "R for figures and tables, Python for data processing"

Wait for answers before proceeding. Store the field and institution — you'll use them to customize the next questions.

---

## Step 2: Name & Project Title

Use AskUserQuestion:

**Question 1 — Name** (single select with "Other" as the expected path):
- header: "Author"
- question: "What is your name (for paper authorship)?"
- options:
  - label: "Skip for now", description: "You can add your name to CLAUDE.md later"
  - label: "Enter name", description: "Type your full name as it appears on publications"

**Question 2 — Project title** (single select):
- header: "Project"
- question: "Do you have a working title for your current project?"
- options:
  - label: "Skip for now", description: "You can add a project title to CLAUDE.md later"
  - label: "Enter title", description: "Type your working project title"

If the user selects "Enter name" or "Enter title", they will type it via the "Other" option. If they select "Skip", move on.

---

## Step 3: Journals

Based on the field selected in Step 1, offer field-specific journal presets using AskUserQuestion with multiSelect: true.

**Question 1 — Primary journals** (multi-select):
- header: "Top journals"
- question: "Select your top journals (pick all that apply, or select Other to add your own):"
- Offer the top 4 journals for the user's field. Examples by field:
  - **Economics:** "American Economic Review", "Quarterly Journal of Economics", "Econometrica", "Journal of Political Economy"
  - **Political Science:** "American Political Science Review", "American Journal of Political Science", "Journal of Politics", "Comparative Political Studies"
  - **Sociology:** "American Sociological Review", "American Journal of Sociology", "Social Forces", "Demography"
  - **Public Health:** "New England Journal of Medicine", "The Lancet", "JAMA", "American Journal of Epidemiology"
  - For other fields: offer 4 best-guess top journals

**Question 2 — Secondary journals** (multi-select):
- header: "Secondary"
- question: "Select secondary or subfield journals (pick all that apply):"
- Offer 4 secondary journals appropriate to the user's field. Examples:
  - **Economics:** "Journal of Labor Economics", "Journal of Public Economics", "Journal of Development Economics", "Review of Economics and Statistics"
  - **Political Science:** "Political Research Quarterly", "Political Behavior", "Legislative Studies Quarterly", "World Politics"
  - **Sociology:** "Social Science Research", "Sociological Methods & Research", "Annual Review of Sociology", "Journal of Marriage and Family"
  - **Public Health:** "Epidemiology", "Health Affairs", "BMJ", "Preventive Medicine"

Wait for answers. The user can multi-select presets AND add custom journals via "Other."

---

## Step 4: Datasets

Based on the user's field, offer dataset presets using AskUserQuestion with multiSelect: true.

**Question 1 — Common datasets** (multi-select):
- header: "Datasets"
- question: "Which datasets do you commonly use or plan to use? (Select all that apply)"
- Offer the top 4 datasets for the user's field. Examples by field:
  - **Economics:** "Current Population Survey (CPS)", "American Community Survey (ACS)", "Panel Study of Income Dynamics (PSID)", "National Longitudinal Survey of Youth (NLSY)"
  - **Political Science:** "American National Election Studies (ANES)", "Cooperative Election Study (CES)", "Varieties of Democracy (V-Dem)", "Correlates of War (COW)"
  - **Sociology:** "General Social Survey (GSS)", "Panel Study of Income Dynamics (PSID)", "National Longitudinal Survey of Youth (NLSY)", "American Community Survey (ACS)"
  - **Public Health:** "National Health Interview Survey (NHIS)", "Medical Expenditure Panel Survey (MEPS)", "Behavioral Risk Factor Surveillance System (BRFSS)", "National Health and Nutrition Examination Survey (NHANES)"

**Question 2 — Additional data sources** (multi-select):
- header: "More data"
- question: "Any additional data sources? (Select all that apply, or Other to add custom)"
- Offer 4 cross-disciplinary datasets:
  - label: "World Bank Open Data", description: "International development indicators"
  - label: "IPUMS", description: "Harmonized census and survey microdata"
  - label: "Bureau of Labor Statistics", description: "Employment, wages, prices"
  - label: "Census Bureau", description: "ACS, decennial census, economic census"

---

## Step 5: Key Researchers

Use AskUserQuestion:

**Question 1 — Researchers** (single select):
- header: "Researchers"
- question: "Do you want to add key researchers for targeted literature searches?"
- options:
  - label: "Skip for now", description: "You can add researchers to references/domain-profile.md later"
  - label: "Add researchers", description: "I'll list some prominent names in your field"

If the user selects "Add researchers", then ask them conversationally to list names, institutions, and Google Scholar URLs. Do NOT try to guess researcher names — the user knows who matters for their work.

---

## Step 6: R Color Palette

Use AskUserQuestion to offer institutional color presets based on the institution selected in Step 1.

**Question 1 — Color palette** (single select with previews):
- header: "Colors"
- question: "Which color palette should R figures use?"
- If the institution is known, offer its colors as the first (recommended) option. Include previews showing the hex codes.
- options (customize based on institution; here are examples):
  - label: "[Institution] Colors (Recommended)", description: "Official brand colors", preview: "Primary: #012169 (Duke Blue)\nSecondary: #F2A900 (Duke Gold)"
  - label: "Custom colors", description: "Enter your own hex codes"
  - label: "Skip for now", description: "Keep default colors, customize later in rules/r-code-conventions.md"

**Common institutional colors to offer** (use these if the institution matches):
- Duke: primary #012169, secondary #F2A900
- Harvard: primary #A51C30, secondary #1E1E1E
- Stanford: primary #8C1515, secondary #007C92
- UC Berkeley: primary #003262, secondary #FDB515
- MIT: primary #750014, secondary #8A8B8C
- Columbia: primary #B9D9EB, secondary #1D4F91
- Yale: primary #00356B, secondary #ADB0B8
- Princeton: primary #E77500, secondary #000000
- UChicago: primary #800000, secondary #767676
- Penn: primary #011F5B, secondary #990000

If the user's institution is not in this list and they don't select "Custom colors" or "Skip", ask them conversationally for their hex codes, or suggest they search "[institution] brand colors."

If the user selects "Custom colors", ask conversationally for primary and secondary hex codes.

---

## Step 7: Write Config Files

Once you have all answers, write or update the following files:

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

## Step 8: Confirm

After writing all files, report back:

```
Setup complete. Here's what was configured:

- references/domain-profile.md — field, [N] primary journals, [N] secondary journals[, N datasets][, N researchers]
- rules/r-code-conventions.md — institutional colors ([primary], [secondary])
- CLAUDE.md — project name and institution

You can update any of these manually at any time:
- Add more datasets → references/domain-profile.md
- Add key researchers → references/domain-profile.md
- Adjust R colors or theme → rules/r-code-conventions.md

Run /new-project to start developing your research question.
```

If the user skipped any section, note it in the summary and remind them where to add it later.
