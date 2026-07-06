---
name: data-analysis
description: "End-to-end data analysis in R or Python — exploration through regression to publication-ready tables and figures. Use when running empirical analysis, writing analysis code, or producing output from data."
when_to_use: "analyze data, run regression, write R code, write Python code, I have a dataset, help with regression, DiD, RDD, event study, IV regression, fit a model, produce a table, make a figure, explore data, dataset path, empirical estimation"
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task", "AskUserQuestion"]
---

# Data Analysis Workflow

Run an end-to-end data analysis in R or Python: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path (e.g., `data/county_panel.csv`) or a description of the analysis goal (e.g., "regress wages on education with state fixed effects using CPS data").

Before making analysis changes, read `${CLAUDE_PLUGIN_ROOT}/rules/orchestrator-protocol.md`, `${CLAUDE_PLUGIN_ROOT}/rules/analysis-verification.md`, and `${CLAUDE_PLUGIN_ROOT}/rules/quality-gates.md`; for replication or extension requests, also read `${CLAUDE_PLUGIN_ROOT}/rules/replication-protocol.md`.


## Phase 0: Choose Language

R is the default. If ambiguous, use AskUserQuestion to pick R (Recommended — tidyverse/fixest/ggplot2, full plugin support including r-reviewer) or Python (pandas/statsmodels). Pick R when the project has existing `.R` code; Python when it has existing `.py` or `.ipynb`.


## Phase 0.5: Ingest Non-Tabular Inputs

If `$ARGUMENTS` points to a PDF, HTML page, government portal URL, or other non-tabular source, Read `${CLAUDE_SKILL_DIR}/references/ingest-recipes.md` and follow it before Phase 1. Skip this phase for flat files (`.csv`, `.parquet`, `.dta`, `.rds`, `.feather`, `.json`).


## R Track

### Constraints
- Follow `${CLAUDE_PLUGIN_ROOT}/rules/r-code-conventions.md` for all standards
- Save scripts to `scripts/R/` with descriptive names
- Save all outputs (figures, tables, RDS) to `output/`
- Use `saveRDS()` for every computed object
- Run `r-reviewer` on the generated script before presenting results

### Phase 1: Setup and Data Loading
1. Create R script with proper header (title, author, purpose, inputs, outputs) — Read `${CLAUDE_SKILL_DIR}/templates/analysis-script.R` and adapt
2. Load required packages at top (`library()`, never `require()`)
3. Set seed once at top: `set.seed(42)`
4. Create output directories: `dir.create("output/analysis", recursive = TRUE, showWarnings = FALSE)`
5. Load and inspect the dataset

### Phase 2: Exploratory Data Analysis
- `summary()`, missingness rates, variable types
- Histograms for key continuous variables
- Scatter plots, correlation matrices
- Panel trends, pre-treatment comparisons if applicable
- Save all diagnostic figures to `output/diagnostics/`

### Phase 3: Main Analysis
- Panel data: use `fixest`; cross-section: use `lm`/`glm`
- Cluster SEs at the appropriate level (document why)
- Multiple specifications: start simple, progressively add controls
- Report standardized effects alongside raw coefficients

### Phase 3.5: Identification Diagnostics

Mandatory for any analysis with a causal interpretation. Detect the design from the analysis goal and the model call (`feols(... | id + t)` with treatment-timing → DiD; `rdrobust` → RDD; `feols(y ~ ... | 0 | endog ~ instr)` → IV; `tidysynth` → synthetic control; random assignment → RCT; `MatchIt`/`cobalt` → matching). Read `${CLAUDE_SKILL_DIR}/references/identification-r.md` and run the block matching the detected design. Ask once with AskUserQuestion only if the design is genuinely ambiguous. Skip this phase for purely descriptive analyses.

### Phase 4: Publication-Ready Output
**Tables:** `modelsummary` (preferred) or `stargazer` — export `.tex` and `.html`
**Figures:** `ggplot2` with project theme; explicit `ggsave(width = X, height = Y)`; save as `.pdf` and `.png`; add `bg = "transparent"` only if output is for Beamer slides

### Phase 5: Save and Review
1. `saveRDS()` for all key objects
2. Dispatch the `r-reviewer` agent via Task:
   ```
   Task prompt: "Review the R script at scripts/R/[script_name].R against
   ${CLAUDE_PLUGIN_ROOT}/rules/r-code-conventions.md. Save your report to
   quality_reports/[script_name]_r_review.md. Follow the r-reviewer agent instructions."
   ```
3. Address Critical and High issues before presenting results


## Python Track

### Constraints
- Save scripts to `scripts/python/` with descriptive names
- Save all outputs (figures, tables, pickles) to `output/`
- Use `joblib.dump()` for model objects; `.to_parquet()` for DataFrames
- Use `pathlib.Path` for all file paths — never hardcode absolute paths
- Set random seeds at the top of the script

### Phase 1: Setup and Data Loading
1. Create Python script with header — Read `${CLAUDE_SKILL_DIR}/templates/analysis-script.py` and adapt
2. Import all packages at the top of the file
3. Set seeds: `np.random.seed(42)` and `random.seed(42)`
4. Create output directories: `Path("output/analysis").mkdir(parents=True, exist_ok=True)`
5. Load and inspect the dataset with `pandas`

### Phase 2: Exploratory Data Analysis
- `df.describe()`, `df.isnull().sum()`, `df.dtypes`
- Histograms and distributions with `matplotlib`/`seaborn`
- Scatter plots and correlation matrices
- Save diagnostic figures to `output/diagnostics/`
- Save summary stats: `df.describe().to_csv("output/diagnostics/summary_stats.csv")`

### Phase 3: Main Analysis
- Cross-section OLS: `smf.ols("y ~ x", data=df).fit(cov_type="HC3")`
- Panel data: `PanelOLS` from `linearmodels` with cluster-robust SEs
- Multiple specifications: build incrementally
- Document SE choice with a comment

### Phase 3.5: Identification Diagnostics

Mandatory for any analysis with a causal interpretation. Detect the design from the analysis goal and the model call (`PanelOLS(..., entity_effects=True, time_effects=True)` with treatment timing → DiD; `rdrobust` port → RDD; `IV2SLS` → IV; `pysyncon` → synthetic control; experiment → RCT; `causalinference` → matching). Read `${CLAUDE_SKILL_DIR}/references/identification-py.md` and run the block matching the detected design. Skip this phase for purely descriptive analyses.

### Phase 4: Publication-Ready Output
**Tables:** Format with `pandas` and export via `.to_latex()` or `stargazer` (Python port)
**Figures:** `matplotlib`/`seaborn`; explicit `fig.savefig(path, dpi=300, bbox_inches="tight")`; save as `.pdf` and `.png`

### Phase 5: Save and Review
1. `joblib.dump(model, "output/model.pkl")` for fitted models
2. `df_results.to_parquet("output/results.parquet")` for DataFrames
3. Review manually against the checklist below before presenting

### Python Quality Checklist
```
[ ] All imports at top
[ ] Random seeds set (numpy + stdlib)
[ ] All paths use pathlib.Path — no hardcoded strings
[ ] Output directories created with mkdir(exist_ok=True)
[ ] Figures saved with explicit dpi=300, bbox_inches="tight"
[ ] Model objects saved with joblib.dump()
[ ] DataFrames saved as parquet
[ ] Comments explain WHY, not WHAT
```


## Shared Principles

- **Reproduce, don't guess.** If the user specifies a regression, run exactly that.
- **Show your work.** Compute summary statistics before jumping to regression.
- **Check for issues.** Look for multicollinearity, outliers, perfect prediction, missing data.
- **Use relative paths.** All paths relative to repository root.
- **No hardcoded values.** Use variables for sample restrictions, date ranges, thresholds.
