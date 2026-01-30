# United States Securities and Exchange Commission Filing Pipeline: Ten-Q Text Metrics and Diluted Earnings-Per-Share Extraction (Second Quarter 2020)

**Author:** Yumna Hussain (yumnahussain444@gmail.com)  
**Date:** 2025-12-31

This repository builds a pipeline that identifies each firm’s most recent Ten-Q quarterly report from a provided list of firm identifiers, downloads the filing from the United States Securities and Exchange Commission public filing archive, computes basic text metrics from the filing, and extracts quarterly diluted earnings-per-share values from the structured financial data included with the filing.

The workflow is designed for Google Colaboratory and follows the United States Securities and Exchange Commission request guidance by setting a descriptive user agent and using retry logic for temporary rate limiting or server errors.

---

## What this pipeline produces

For each firm identifier in the input list (when a matching Ten-Q filing is found), the pipeline outputs:

- `word_count`: number of word tokens after converting filing markup to plain text  
- `sentence_count`: number of sentences estimated using a sentence segmentation tool  
- `eps_current_q`: diluted earnings-per-share for the most recent quarter available in the structured data  
- `eps_previous_q`: diluted earnings-per-share for the previous quarter available in the structured data  
- `filing_date`: filing date recorded in the master index file  
- `filing_url`: direct link to the filing text file in the public archive

Output file:
- `edgar_q2_2020_10q_metrics.csv`

---

## Inputs

This notebook expects the following files on Google Drive:

- `CIK_list.txt`  
  A text file containing firm identifiers. The notebook extracts numeric tokens, normalizes them, and removes duplicates while preserving order.

- `form.idx` (or `form.idx.gz`)  
  The master index file that lists filings, including form type, company name, firm identifier, filing date, and archive path.

Paths used in the notebook:
- `CIK_LIST_PATH = /content/drive/MyDrive/NYU_Datatask/CIK_list.txt`
- `MASTER_IDX_PATH = /content/drive/MyDrive/NYU_Datatask/form.idx`

---

## Step-by-step workflow

### 1) Read and normalize the firm identifier list
- Extract numeric tokens from the text file
- Normalize formatting so identifiers are consistent
- Remove duplicates while preserving the original order

### 2) Parse the master index file
- Robustly parses the fixed-width master index table
- Produces a dataset with:
  - firm identifier
  - company name
  - form type
  - filing date
  - filing archive path

### 3) Select the most recent Ten-Q filing per firm
- Filters to filings whose form type begins with Ten-Q
- Prefers the standard Ten-Q filing over amended versions
- Keeps the most recent filing date per firm

### 4) Download filing text from the public archive
- Builds a direct filing link from the archive path
- Uses retry logic for temporary blocking, rate limiting, or server hiccups
- Adds a short pause between requests to reduce the chance of rate limiting

### 5) Compute text metrics (natural language processing)
This repository includes lightweight natural language processing for measuring filing length:

- Converts filing markup to plain text using an HTML parser
- Normalizes whitespace
- Computes:
  - word count using a word-token regular expression
  - sentence count using a sentence segmentation library

This is descriptive text processing and does not involve model training.

### 6) Extract diluted earnings-per-share from structured financial data
- Uses the filing directory listing to locate the most likely structured data instance document
- Excludes common non-instance documents such as linkbases, schema files, stylesheets, and summaries
- Chooses the largest remaining structured data document as the best candidate
- Parses the structured data and extracts values for diluted earnings-per-share
- Restricts to quarterly reporting periods by keeping periods whose start and end dates imply roughly a quarter
- Returns the two most recent quarterly diluted earnings-per-share values

---

## Output columns

The output comma-separated file includes:

| Column | Description |
|---|---|
| `CIK` | Firm identifier from the input list |
| `filing_date` | Filing date from the master index |
| `word_count` | Total word tokens after converting markup to plain text |
| `sentence_count` | Total sentences from sentence segmentation |
| `eps_current_q` | Most recent quarterly diluted earnings-per-share found |
| `eps_previous_q` | Previous quarter diluted earnings-per-share found |
| `filing_url` | Link to the filing text file |


---

## Data

This repository does not redistribute filing documents. It downloads public filings and saves derived metrics and links.


