---
name: review-paper
description: Comprehensive manuscript review covering argument structure, econometric specification, citation completeness, and potential referee objections. Make sure to use this skill whenever the user wants substantive academic feedback on a paper — not just surface edits. Triggers include: "review my paper", "give me feedback on this draft", "what would a referee say", "anticipate referee objections", "act as a referee", "check my identification strategy", "is my argument convincing", "review this manuscript", "critique my paper", "will this pass review", or any request for deep critique of academic writing beyond typos and grammar.
argument-hint: "[paper filename in manuscripts/ or path to .tex/.pdf]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Manuscript Review

Produce a thorough, constructive review of an academic manuscript — the kind of report a top-journal referee would write.

**Input:** `$ARGUMENTS` — path to a paper (.tex, .pdf, or .qmd), or a filename in `manuscripts/` or `references/papers/`.

---

## Steps

1. **Locate and read the manuscript.** Check:
   - Direct path from `$ARGUMENTS`
   - `manuscripts/$ARGUMENTS`
   - `references/papers/$ARGUMENTS`
   - Glob for partial matches in `manuscripts/` and `references/papers/`

2. **Read the full paper** end-to-end. For long PDFs, read in chunks (5 pages at a time).

3. **Read `references/domain-profile.md`** for field and top journals — use these to calibrate the referee perspective (see Principles).

4. **Dispatch three reviewer agents in parallel** via Task (one message, three Task calls — see below):
   - `domain-reviewer` — substantive correctness through 5 lenses
   - `adversarial-reviewer` — hostile-referee attack on the paper
   - `fresh-eyes-reviewer` — first-time reader perspective

5. **Evaluate writing quality and presentation** (dimensions 5-6) — the skill handles these directly while the agents run.

6. **After all agents complete**, merge findings into the unified report:
   - `fresh-eyes-reviewer` output → "Fresh Eyes Read" section
   - `domain-reviewer` output → "Major Concerns" and "Minor Concerns" sections
   - `adversarial-reviewer` output → primary source for "Referee Objections" and any FATAL-severity entries in "Major Concerns"
   - Skill's own Dim 5-6 evaluation → "Writing Quality" and "Presentation" entries in concerns

7. **Produce the unified review report.**

8. **Save to** `quality_reports/paper_review_[sanitized_name].md`

---

## Step 4: Dispatch Three Reviewer Agents in Parallel

Send **one message with three Task calls** so the agents run concurrently. Each agent has a distinct job and they should not see each other's output.

### Task 1: `domain-reviewer`

```
Task prompt: "You are the domain-reviewer agent. Review the manuscript at [path].
Research question: [from spec if available].

Apply all 5 review lenses:
1. Assumption stress test
2. Derivation verification
3. Citation fidelity
4. Code-theory alignment
5. Backward logic check

Also check cross-document consistency.
Follow the domain-reviewer agent instructions and return your full substance review report."
```

### Task 2: `adversarial-reviewer`

```
Task prompt: "You are the adversarial-reviewer agent. Your job is to attack the
paper at [path] — find the strongest possible critique a hostile referee would make.
Research question: [from spec if available].
Target venue: [from domain-profile.md if set, else 'unspecified — use top field journal bar'].

Apply all 5 attack lenses:
1. Fatal flaw hunt
2. Over-claim detection
3. Alternative explanations (generate the 3 most plausible)
4. Identification weakest link
5. Rejection letter (two-paragraph desk-editor rejection)

Follow the adversarial-reviewer agent instructions and return your full adversarial report."
```

### Task 3: `fresh-eyes-reviewer`

```
Task prompt: "You are the fresh-eyes-reviewer agent. Read the paper at [path]
as a first-time reader with NO prior context. Do NOT read the project spec,
lit review, ideation file, or analysis scripts — read only the manuscript.

Execute all 5 passes:
1. Title + abstract only
2. Introduction only
3. Main result table/figure standalone
4. Full paper read
5. What stays with you

Follow the fresh-eyes-reviewer agent instructions and return your full fresh-eyes report."
```

Wait for all three to complete. Collect their outputs for the merge step.

---

## Steps 5-6: Evaluate Writing/Presentation, Then Merge

While the agents run, evaluate dimensions 5-6 directly (writing quality, presentation). Once all three agents return:

- **Fresh Eyes Read section** — paste the fresh-eyes summary (Passes 1-5 condensed + top 3 clarity issues).
- **Major Concerns** — combine `domain-reviewer` MAJOR/CRITICAL findings + `adversarial-reviewer` fatal flaws + your Dim 5-6 major findings.
- **Minor Concerns** — `domain-reviewer` MINOR findings + your Dim 5-6 minor findings.
- **Referee Objections** — primarily from `adversarial-reviewer`: fatal flaw, top over-claims, top alternative explanations, identification weakest link.
- **Rejection Letter Preview** — paste the adversarial-reviewer's two-paragraph rejection verbatim under a "What a desk editor might say" subheading.

---

## Review Dimensions

### 1. Argument Structure
- Is the research question clearly stated?
- Does the introduction motivate the question effectively?
- Is the logical flow sound (question → method → results → conclusion)?
- Are the conclusions supported by the evidence?
- Are limitations acknowledged?

### 2. Identification Strategy
- Is the causal claim credible?
- What are the key identifying assumptions? Are they stated explicitly?
- Are there threats to identification (omitted variables, reverse causality, measurement error)?
- Are robustness checks adequate?
- Is the estimator appropriate for the research design?

### 3. Econometric Specification
- Correct standard errors (clustered? robust? bootstrap?)?
- Appropriate functional form?
- Sample selection issues?
- Multiple testing concerns?
- Are point estimates economically meaningful (not just statistically significant)?

### 4. Literature Positioning
- Are the key papers cited?
- Is prior work characterized accurately?
- Is the contribution clearly differentiated from existing work?
- Any missing citations that a referee would flag?

### 5. Writing Quality
- Clarity and concision
- Academic tone
- Consistent notation throughout
- Abstract effectively summarizes the paper
- Tables and figures are self-contained (clear labels, notes, sources)

### 6. Presentation
- Are tables and figures well-designed?
- Is notation consistent throughout?
- Are there any typos, grammatical errors, or formatting issues?
- Is the paper the right length for the contribution?

---

## Output Format

```markdown
# Manuscript Review: [Paper Title]

**Date:** [YYYY-MM-DD]
**Reviewer:** review-paper skill (agents: domain-reviewer, adversarial-reviewer, fresh-eyes-reviewer)
**File:** [path to manuscript]

## Summary Assessment

**Overall recommendation:** [Strong Accept / Accept / Revise & Resubmit / Reject]

[2-3 paragraph summary: main contribution, strengths, and key concerns]

## Fresh Eyes Read

*How the paper lands on a first-time reader (from fresh-eyes-reviewer agent).*

**After title + abstract — one-sentence takeaway:** ...
**After intro — what reader expects:** ...
**Main display standalone?** [Yes / Partially / No — what's missing]
**What stays with the reader:** ...

### Top 3 Clarity Issues
1. [issue with location]
2. ...
3. ...

### Top 3 Things That Landed
1. ...
2. ...
3. ...

## Strengths

1. [Strength 1]
2. [Strength 2]
3. [Strength 3]

## Major Concerns

### MC1: [Title]
- **Source:** [domain-reviewer / adversarial-reviewer / skill (writing or presentation)]
- **Dimension:** [Identification / Econometrics / Argument / Literature / Writing / Presentation / Fatal Flaw]
- **Issue:** [Specific description]
- **Suggestion:** [How to address it]
- **Location:** [Section/page/table if applicable]

[Repeat for each major concern. FATAL-severity items from adversarial-reviewer go first.]

## Minor Concerns

### mc1: [Title]
- **Issue:** [Description]
- **Suggestion:** [Fix]

[Repeat]

## Referee Objections

*Primarily sourced from the adversarial-reviewer's attack lenses — these are the tough questions a hostile referee would raise.*

### RO1: [Question]
**Why it matters:** [Why this could be fatal]
**How to address it:** [Suggested response or additional analysis]

[Include: fatal flaw as RO1, top over-claims, top alternative explanations, identification weakest link. Target 4-6 objections total.]

## What a Desk Editor Might Say

*Two-paragraph rejection letter from the adversarial-reviewer. Read this before submission.*

[Paste adversarial-reviewer's rejection letter verbatim.]

## Specific Comments

[Line-by-line or section-by-section comments, if any]

## Summary Statistics

| Dimension | Rating (1-5) |
|-----------|-------------|
| Argument Structure | [N] |
| Identification | [N] |
| Econometrics | [N] |
| Literature | [N] |
| Writing | [N] |
| Presentation | [N] |
| First-read clarity | [N] |
| Adversarial robustness | [N] |
| **Overall** | **[N]** |
```

---

## Principles

- **Be constructive.** Every criticism should come with a suggestion.
- **Be specific.** Reference exact sections, equations, tables.
- **Calibrate to the field's top journals** (from `references/domain-profile.md`). An AER/QJE referee weights identification above all else; an APSR/AJPS referee weights theoretical framing and measurement validity; an ASR/AJS referee weights theoretical contribution. If no domain profile is set, flag the assumption you're making.
- **Distinguish fatal flaws from minor issues.** Not everything is equally important.
- **Acknowledge what's done well.** Good research deserves recognition.
- **Do NOT fabricate details.** If you can't read a section clearly, say so.
