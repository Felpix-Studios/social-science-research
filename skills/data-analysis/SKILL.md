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


## Phase 0: Choose Language

Determine language from `$ARGUMENTS` or ask the user:
- User mentions `tidyverse`, `fixest`, `lm`, `.R` context → **R track**
- User mentions `pandas`, `statsmodels`, `sklearn`, `.py` or `.ipynb` context → **Python track**
- Dataset is `.csv`/`.parquet` with no language cue → use AskUserQuestion with a single-select menu:
  - header: "Language"
  - question: "Which language should I use for this analysis?"
  - options:
    - label: "R (Recommended)", description: "tidyverse, fixest, ggplot2 — full plugin support with coding conventions and R reviewer"
    - label: "Python", description: "pandas, statsmodels — supported for analysis scripts and figures"
    - label: "Both", description: "R for figures and tables, Python for data processing"


## Phase 0.5: Ingest Non-Tabular Inputs

If `$ARGUMENTS` points to a PDF, scraped HTML page, government portal URL, or other non-tabular source, extract it into a tidy dataset before Phase 1. Skip this phase when the input is already a flat file (`.csv`, `.parquet`, `.dta`, `.rds`, `.feather`, `.json`).

### Detection cues
- File extension: `.pdf`, `.html`, `.htm`, `.xml`
- URL points to a portal: FRED, BLS, Census, Eurostat, World Bank, IMF, IPUMS
- Description mentions "scrape", "extract from", "table on page X", or "OCR"

### R recipes
| Source | Package | Pattern |
|---|---|---|
| PDF tables | `tabulizer`, `pdftools` | `tabulizer::extract_tables("file.pdf", pages = 3)` |
| Scanned PDFs (OCR) | `tesseract` | `tesseract::ocr("file.png")` |
| HTML tables | `rvest` | `read_html(url) %>% html_table()` |
| Generic scrape | `rvest`, `httr2` | `read_html(url) %>% html_elements(".css-selector")` |
| FRED | `fredr` | `fredr(series_id = "UNRATE")` |
| BLS | `blsAPI` | `blsAPI(payload)` |
| Census / ACS | `tidycensus` | `get_acs(geography, variables, year)` |
| World Bank | `WDI` | `WDI(indicator = "NY.GDP.MKTP.CD", country = "all")` |

### Python recipes
| Source | Package | Pattern |
|---|---|---|
| PDF text | `pdfplumber` | `pdfplumber.open(path).pages[0].extract_text()` |
| PDF tables | `camelot` | `camelot.read_pdf(path, pages='3')` |
| Scanned PDFs | `pytesseract`, `Pillow` | `pytesseract.image_to_string(Image.open(...))` |
| HTML tables | `pandas` | `pd.read_html(url)[0]` |
| Generic scrape | `bs4`, `httpx` | `BeautifulSoup(httpx.get(url).text, "html.parser")` |
| FRED | `fredapi` | `Fred(api_key).get_series("UNRATE")` |
| Census / ACS | `census` | `Census(api_key).acs5.state(...)` |

### Output requirements
1. Save the ingest script separately at `scripts/ingest/[name]_ingest.R` (or `.py`) — distinct from the analysis script so the slow extraction step does not rerun every analysis.
2. Save the cleaned intermediate to `data/processed/[name].csv` or `.parquet`.
3. Save a short extraction memo to `quality_reports/ingest_[name].md`: source URL/file, date pulled, page range or CSS selectors, row count, dropped rows and reason.
4. Phase 1 reads from `data/processed/` — not the raw source.

### When to ask
If the source is ambiguous (which table, which page, which date range), ask once with AskUserQuestion before extracting. Do not guess on legal or government documents — the wrong table is worse than no table.


## R Track

### Constraints
- Follow `rules/r-code-conventions.md` for all standards
- Save scripts to `scripts/R/` with descriptive names
- Save all outputs (figures, tables, RDS) to `output/`
- Use `saveRDS()` for every computed object
- Run `r-reviewer` on the generated script before presenting results

### Phase 1: Setup and Data Loading
1. Create R script with proper header (title, author, purpose, inputs, outputs)
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

Run the design-specific diagnostics referees expect to see *for the design being claimed*. This phase is mandatory for any analysis with a causal interpretation. Detect the design from the analysis goal and the model call (`feols(... | id + t)` with treatment-timing → DiD; `rdrobust` → RDD; `feols(y ~ ... | 0 | endog ~ instr)` → IV). Ask once with AskUserQuestion only if the design is genuinely ambiguous.

Save every diagnostic figure to `output/diagnostics/` and every numerical result to RDS for `/quality-gate` and `/write-paper` to consume.

**DiD / event study:**
- Pre-trends event-study coefficients with 95% CI via `fixest::iplot()` (or `ggiplot::ggiplot()`)
- If staggered timing: re-estimate with `fixest::feols(y ~ sunab(g, t) | id + t)`, `did::att_gt()` (Callaway-Sant'Anna), or `DIDmultiplegt::did_multiplegt_dyn()` (de Chaisemartin); compare to TWFE headline
- `bacondecomp::bacon()` when TWFE is the headline estimate
- Placebo outcome and/or placebo period when available

**RDD:**
- `rddensity::rddensity(X, c = cutoff)` for the McCrary-type density discontinuity test — report t-stat and p-value
- `rdrobust::rdbwselect(y, x, c)` for optimal bandwidth; re-estimate at 0.5×, 1×, 2× the optimal
- Donut-hole sensitivity: drop observations within ε of the cutoff and re-estimate
- Covariate balance at the cutoff using `rdrobust::rdrobust(z, x, c)` for each covariate z

**IV:**
- `fixest::feols(y ~ controls | fe | endog ~ instr)` — report the effective F via `fitstat(., "ivf1")`; Olea-Pflueger via `ivDiag::ivDiag()`
- Anderson-Rubin weak-IV-robust CI when F < 100 — `ivDiag::AR_test()` or `ivmodel::AR.test()`
- Over-identification (Hansen J) via `fixest::wald()` when instruments > 1
- Report the reduced-form coefficient alongside the 2SLS estimate

**Synthetic control:**
- `tidysynth::generate_placebos()` for in-space placebo permutation; plot treatment-vs-donor effect paths
- Pre-period RMSPE for treated unit vs distribution across donors
- In-time placebo if a clear pre-treatment cutoff exists
- Donor weights table

**RCT / OLS with exogenous treatment:**
- Balance table on pre-treatment covariates via `modelsummary::datasummary_balance(~ treat, data = df)`
- Randomization inference via `ri2::conduct_ri()` for the primary outcome
- CONSORT-style attrition summary if attrition > 5%

**Matching / propensity score:**
- Pre/post balance with standardized mean differences via `cobalt::bal.tab()`
- Common support plot
- Sensitivity to caliper width

Detected design → run the corresponding block automatically. Multiple designs (e.g., DiD with IV robustness) → run all relevant blocks. The user does not need to ask for these; they are the default for any causal claim.

### Phase 4: Publication-Ready Output
**Tables:** `modelsummary` (preferred) or `stargazer` — export `.tex` and `.html`
**Figures:** `ggplot2` with project theme; explicit `ggsave(width = X, height = Y)`; save as `.pdf` and `.png`; add `bg = "transparent"` only if output is for Beamer slides

### Phase 5: Save and Review
1. `saveRDS()` for all key objects
2. Dispatch the `r-reviewer` agent via Task:
   ```
   Task prompt: "Review the R script at scripts/R/[script_name].R against
   rules/r-code-conventions.md. Save your report to
   quality_reports/[script_name]_r_review.md. Follow the r-reviewer agent instructions."
   ```
3. Address Critical and High issues before presenting results

### R Script Template
```r
# ============================================================
# [Descriptive Title]
# Author: [from project context]
# Purpose: [What this script does]
# Inputs:  [Data files]
# Outputs: [Figures, tables, RDS files]
# ============================================================

# 0. Setup ----
library(tidyverse)
library(fixest)
library(modelsummary)

set.seed(42)
dir.create("output/analysis", recursive = TRUE, showWarnings = FALSE)

# 1. Data Loading ----
# 2. Exploratory Analysis ----
# 3. Main Analysis ----
# 4. Tables and Figures ----
# 5. Export ----
```


## Python Track

### Constraints
- Save scripts to `scripts/python/` with descriptive names
- Save all outputs (figures, tables, pickles) to `output/`
- Use `joblib.dump()` for model objects; `.to_parquet()` for DataFrames
- Use `pathlib.Path` for all file paths — never hardcode absolute paths
- Set random seeds at the top of the script

### Phase 1: Setup and Data Loading
1. Create Python script with header (title, author, purpose, inputs, outputs)
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

Mirror of the R-track diagnostics with Python tooling. Mandatory for any analysis with a causal interpretation. Detect the design from the analysis goal and the model call (`PanelOLS(..., entity_effects=True, time_effects=True)` with treatment timing → DiD; `rdrobust` Python port → RDD; `IV2SLS` → IV). Ask once if ambiguous.

Save diagnostic figures to `output/diagnostics/` and numerical results to `.pkl` or `.parquet`.

**DiD / event study:**
- Event-study coefficients with 95% CI from `linearmodels.PanelOLS` interaction terms — plot leads and lags
- Staggered timing: `differences::ATTgt` (Callaway-Sant'Anna port) or `pyfixest` Sun-Abraham; compare to the TWFE headline
- Manual Goodman-Bacon decomposition when TWFE is headline
- Placebo outcome / placebo period

**RDD:**
- `rdrobust` Python port: `rdrobust.rddensity(X, c=cutoff)` — report McCrary-type t and p
- `rdrobust.rdbwselect(...)` for bandwidth; re-estimate at 0.5×, 1×, 2×
- Donut-hole sensitivity
- Covariate balance at cutoff

**IV:**
- `linearmodels.IV2SLS(...).fit()` — first-stage F via `results.first_stage` / `results.diagnostics`
- Anderson-Rubin weak-IV-robust CI when F < 100 (manual or via `linearmodels` Wald tools)
- Over-identification: Sargan/Hansen J from the results object
- Reduced form alongside 2SLS

**Synthetic control:**
- `pysyncon` for in-space placebo permutation
- Pre-period RMSPE comparison
- In-time placebo
- Donor weights

**RCT / OLS with exogenous treatment:**
- Balance table per covariate (t-tests via `scipy.stats.ttest_ind` or `stargazer`)
- Randomization inference via `numpy.random.permutation` loop
- Attrition summary if relevant

**Matching:**
- Standardized mean differences pre/post via `causalinference` or manual computation
- Common support plot
- Sensitivity to caliper

Detection rule and "no need to ask the user" rule match the R track.

### Phase 4: Publication-Ready Output
**Tables:** Format with `pandas` and export via `.to_latex()` or `stargazer` (Python port)
**Figures:** `matplotlib`/`seaborn`; explicit `fig.savefig(path, dpi=300, bbox_inches="tight")`; save as `.pdf` and `.png`

### Phase 5: Save and Review
1. `joblib.dump(model, "output/model.pkl")` for fitted models
2. `df_results.to_parquet("output/results.parquet")` for DataFrames
3. Review the script manually against the Python checklist below before presenting

### Python Script Template
```python
# ============================================================
# [Descriptive Title]
# Author: [from project context]
# Purpose: [What this script does]
# Inputs:  [Data files]
# Outputs: [Figures, tables, pickle/parquet files]
# ============================================================

import random
import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
from pathlib import Path

# Seeds
np.random.seed(42)
random.seed(42)

# Output directories
Path("output/analysis").mkdir(parents=True, exist_ok=True)
Path("output/figures").mkdir(parents=True, exist_ok=True)

# 1. Data Loading
# 2. Exploratory Analysis
# 3. Main Analysis
# 4. Tables and Figures
# 5. Export
```

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
