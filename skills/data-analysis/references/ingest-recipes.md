# Ingest Recipes — Non-Tabular Sources

Use these recipes when the input to `/data-analysis` is a PDF, scraped HTML page, government portal URL, or similar non-tabular source. Extract into a tidy dataset before Phase 1 of the main workflow.

## Detection cues

- File extension: `.pdf`, `.html`, `.htm`, `.xml`
- URL points to a portal: FRED, BLS, Census, Eurostat, World Bank, IMF, IPUMS
- Description mentions "scrape", "extract from", "table on page X", or "OCR"

## R recipes

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

## Python recipes

| Source | Package | Pattern |
|---|---|---|
| PDF text | `pdfplumber` | `pdfplumber.open(path).pages[0].extract_text()` |
| PDF tables | `camelot` | `camelot.read_pdf(path, pages='3')` |
| Scanned PDFs | `pytesseract`, `Pillow` | `pytesseract.image_to_string(Image.open(...))` |
| HTML tables | `pandas` | `pd.read_html(url)[0]` |
| Generic scrape | `bs4`, `httpx` | `BeautifulSoup(httpx.get(url).text, "html.parser")` |
| FRED | `fredapi` | `Fred(api_key).get_series("UNRATE")` |
| Census / ACS | `census` | `Census(api_key).acs5.state(...)` |

## Output requirements

1. Save the ingest script separately at `scripts/ingest/[name]_ingest.R` (or `.py`) — distinct from the analysis script so the slow extraction step does not rerun every analysis.
2. Save the cleaned intermediate to `data/processed/[name].csv` or `.parquet`.
3. Save a short extraction memo to `quality_reports/ingest_[name].md`: source URL/file, date pulled, page range or CSS selectors, row count, dropped rows and reason.
4. Phase 1 of the main analysis reads from `data/processed/` — not the raw source.

## When to ask

If the source is ambiguous (which table, which page, which date range), ask once with AskUserQuestion before extracting. Do not guess on legal or government documents — the wrong table is worse than no table.
