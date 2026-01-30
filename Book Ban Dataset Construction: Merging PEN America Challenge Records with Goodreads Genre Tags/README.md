# Linking PEN America Banned Books to Goodreads Crowdsourced Genres: Title Cleaning, Merging, and Genre Classification

**Author:** Yumna Hussain  
**Contact:** yumnahussain444@gmail.com

## Overview

This repository contains Stata scripts that build an analysis-ready dataset by linking:

- **Goodreads crowdsourced genre and shelf tags** (derived from user-generated “popular shelves” metadata), and  
- **PEN America’s banned book dataset** (records of book challenges and removals by school district and state).

The pipeline:
1) imports and combines raw files from Goodreads and PEN America,  
2) standardizes book titles for matching,  
3) merges the two sources into a single file,  
4) extracts and cleans genre tags from Goodreads shelf text, and  
5) assigns rule-based genre category indicators for each book.

This repository does not distribute raw data files. It produces derived files intended for research use.

---

## Data sources

### Goodreads crowdsourced genres
The Goodreads input files provide book-level metadata and user-generated shelf tags (for example, “young-adult”, “mystery”, “romance”). These tags are crowdsourced and can be noisy (inconsistent spelling, duplicates, jokes, non-genre shelves).

### PEN America banned book dataset
The PEN America input files provide book challenge or removal records (title, author, state, district, challenge information, and timing fields).

---

## Natural language processing components 

This pipeline includes lightweight natural language processing techniques implemented in Stata. These steps are not machine learning model training; they are deterministic text processing and rule-based classification.

Key natural language processing features:
- **Unicode normalization and title standardization**
  - converts titles to a consistent form (lowercasing, removing punctuation, removing bracketed text, normalizing whitespace, removing non-printing characters)
- **Genre tag extraction from JSON-like shelf text**
  - cleans and tokenizes Goodreads “popular shelves” text into individual genre tag fields
- **Rule-based genre classification**
  - assigns genre categories using curated dictionaries (lists of tags mapped to categories)

---

## Script order and what each script does

### 00_global.do
Sets project-level paths for the Goodreads folder, the PEN America folder, and the output directory.  
You must edit these paths to match your local machine before running the pipeline.

### 01_individual_dataset_merge.do
**Goodreads:**
- imports Goodreads book metadata and Goodreads book genre or shelf metadata
- merges them into one Goodreads combined file

**PEN America:**
- imports multiple year files and appends them into one combined PEN America file
- keeps the core variables needed for merging and analysis
- saves a combined PEN America dataset

### 02_titlecleaning_merge.do
Performs title deduplication and title standardization separately for Goodreads and PEN America, then merges the datasets.

Core steps:
- removes obvious duplicates in Goodreads and keeps the preferred record
- creates a standardized title key (a “consistent title” string) using Unicode normalization and regular expressions
- merges Goodreads (one record per standardized title) to PEN America (potentially multiple challenge records per title)
- saves:
  - matched records (Goodreads linked to PEN America),
  - unmatched Goodreads records,
  - unmatched PEN America records exported for review and manual follow-up

### 03_genrecleaning.do
Extracts, cleans, and filters Goodreads genre tags.

Core steps:
- combines the matched dataset with a curated unmatched subset (for example, manually resolved titles)
- converts Goodreads shelf metadata into a semicolon-delimited tag list
- splits tags into separate genre fields
- drops unwanted tags using a maintained “genres to drop” text list
- normalizes common encoding issues
- exports a unique genre list with frequencies for audit and iterative refinement

### 04_genrecategorization.do
Creates genre category indicator variables using curated tag dictionaries.

Core steps:
- defines dictionaries for broad categories (for example, “fantasy”, “mystery”, “young adult”, “non-fiction”)
- scans across genre tag fields and flags category indicators
- saves the final dataset without date normalization applied

This step is rule-based classification, not machine learning.

### 05_date_organization.do
Cleans and standardizes the PEN America date field related to challenge or removal timing.

Core steps:
- parses inconsistent date formats
- extracts month and year
- handles season-coded values (for example, “Fall”, “Spring”) where applicable

### 06_sanitycheck_genres.do
Quality control script to verify the genre-dropping process.

Core steps:
- reads the maintained drop list and merges it against the unique genre list
- verifies how many tags are dropped
- exports the post-drop unique genre list for audit

---

## Notes and limitations

- Title-based merges can produce false matches when different books share the same cleaned title. If needed, author fields can be incorporated as an additional match check.
- Goodreads shelf tags are crowdsourced and contain noise; the drop list and dictionaries are meant to improve reliability and interpretability.
- Genre category indicators are rule-based and depend on the completeness of the dictionaries.

---

## Citation and use

If you use outputs from this repository, cite the original data providers:
- Goodreads (crowdsourced shelf and genre tags)
- PEN America (banned book dataset)

