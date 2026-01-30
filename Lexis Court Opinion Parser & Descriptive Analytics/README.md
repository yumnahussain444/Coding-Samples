# Lexis Court Opinion Parser & Descriptive Analytics 

This repository builds an analysis-ready dataset from a directory of LexisNexis-exported court case `.txt` files and produces descriptive summaries and figures for three tasks:

1. **Case distribution over time** (counts by year and  moving average)
2. **Top judges (Florida Supreme Court)** by number of unique cases
3. **Opinion-length distributions** for **state courts of last resort** (summary tables and figures)

The workflow is designed to be tolerant to messy/near-JSON Lexis exports, including bracket characters inside quoted strings, inconsistent encodings, and irregular field formatting.

---

## Project Structure

- **Input**
  - A folder of `.txt` case files (Lexis export format), recursively scanned.

- **Outputs (written to `OUT_DIR`)**
  - `cases_clean.tsv` / `cases_clean.csv` / `cases_clean.parquet`  
    A cleaned “core” dataset with standardized metadata and best-available opinion text.
  - `T1_cases_by_year.csv`  
    Yearly case counts, shares, and a 3-year moving average.
  - `fl_supreme_top5_judges_by_cases.csv`  
    Top 5 judges by number of unique FL Supreme Court cases (based on parsed judge tokens).
  - `opinion_length_summary_by_last_resort_state.csv`  
    State-by-state opinion length summary statistics for courts of last resort.
  - `opinion_length_bins_by_last_resort_state_counts.csv`  
    Binned opinion length counts by state.
  - `opinion_length_bins_by_last_resort_state_shares.csv`  
    Binned opinion length shares by state.
  - `figures/`
    - `cases_by_year.png`, `cases_by_year.pdf`
    - `opinion_length_heatmap_last_resort_states.png`
    - `opinion_length_ranked_median_iqr_top15.png`

---

## What the Parser Extracts

For each `.txt` file, the parser attempts to extract and standardize:

- `doc_id` (file stem)
- `case_name` and `short_case_name`
- `docket_number`
- `court_name` (light normalization for spacing/artifacts)
- `decided_date` and `year` (best-effort date parsing + fallback year scan)
- `citations` (deduplicated, split into clean citation strings)
- `publication_status` (inferred as Published/Unpublished when possible)
- `disposition` (simple pattern detection: Affirmed/Reversed/Vacated/Remanded/etc.)
- `jurisdiction` (federal vs state; derived from court name)
- `court_level` (e.g., `state_supreme`, `federal_appellate`; derived from court name)
- `state` (derived when possible for state courts)
- `text` (best-available opinion text from structured fields or a fallback scan)

The reader is encoding-tolerant (tries UTF-8 with replacement, then uses charset detection).

---

## Environment / Dependencies

This notebook is intended for Google Colab.

Installed packages:
- `pandas`, `pyarrow`
- `charset-normalizer`
- `python-dateutil`
- `tqdm`
- `matplotlib`

---

## Quality Checks

During parsing, the notebook prints a quick QC view of “suspicious” rows where:
- opinion text is empty, or
- opinion text appears to still be raw structured content

Rows that fail parsing are still retained with an `_error` field so failures are auditable.

---

## Data Source

Input files are LexisNexis-exported case `.txt` documents located locally (Google Drive).  
This repository does not distribute the raw Lexis files; it generates cleaned derivatives and summary statistics.

---

## Author

Yumna Hussain (19 Oct 2025)

