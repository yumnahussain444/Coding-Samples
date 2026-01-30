*******************************************************
* Project: Goodreads x PEN America — Genre extraction
* Author: Fathima (Yumna Hussain)
* Notes: Clean, reproducible, no globals, consistent paths
* Date: 2025-12-16
*******************************************************

*======================================================
* SECTION 0: SESSION SETUP
*======================================================
clear all
set more off
version 17

*======================================================
* SECTION 1: DEFINE FILE PATHS
*======================================================
local base "C:\Users\Yumna Hussain\The Brookings Institution\Book Bans\Main Output"

local f_unmatched        "`base'\penamerica_unmatched_duplicateordered.csv"
local f_matched          "`base'\goodread_penamerica_matched.dta"
local f_combined         "`base'\goodread_penamerica_combined_mainfile.dta"
local f_final            "`base'\goodread_penamerica_with_genres.dta"
local f_drop_tags   "`base'\genres_to_drop.txt"
local f_unique    "`base'\unique_genres.dta"

*======================================================
* SECTION 2: BUILD COMBINED DATASET (UNMATCHED + MATCHED)
*======================================================
import delimited using "`f_unmatched'", varnames(1) stringcols(_all) encoding(UTF-8) clear
compress
capture drop _m
append using "`f_matched'", force
compress
save "`f_combined'", replace

*======================================================
* SECTION 3: EXTRACT GENRES FROM popular_shelves
*======================================================
use "`f_combined'", clear

* Clean popular_shelves JSON-like structure into delimited list
gen genres_list = ustrregexra(popular_shelves, `"'count': '[^']*', "', "", .)
replace genres_list = ustrregexra(genres_list, `"'name': '"', "", .)
replace genres_list = ustrregexra(genres_list, `"'\}"', "", .)
replace genres_list = ustrregexra(genres_list, `"\{"', "", .)
replace genres_list = ustrregexra(genres_list, `"\[|\]"', "", .)
replace genres_list = ustrregexra(genres_list, ", ", ";", .)
replace genres_list = strtrim(genres_list)

* Split into individual genre columns
split genres_list, parse(";") gen(genre)
compress

tempfile dropterms

*------------------------------------------------------------*
* 4A) Build dropterms dataset from text file (one tag per line)
*------------------------------------------------------------*
preserve
    import delimited using "`f_drop_tags'", ///
        varnames(nonames) clear stringcols(1) encoding(UTF-8)

    rename v1 tag
    replace tag = lower(strtrim(tag))
    drop if missing(tag)

    duplicates drop tag, force

    gen byte drop_me = 1

    * merge-safe key
    gen str200 tag_key = substr(tag, 1, 200)

    keep tag_key drop_me
    save `dropterms', replace
restore

*------------------------------------------------------------*
* 4B) Reshape long so we can drop tags ONE-BY-ONE (not whole books)
*------------------------------------------------------------*

* Create a unique id for each book-row so reshape never collapses duplicates
gen long uid = _n

* Convert wide genre1-genre# → long
reshape long genre, i(uid) j(genre_num)

* Clean tag text
replace genre = lower(strtrim(genre))
drop if missing(genre)

* Remove tags with digits (optional rule you already wanted)
drop if regexm(genre, "[0-9]")

*------------------------------------------------------------*
* 4C) Merge drop list and drop ONLY matching tags
*------------------------------------------------------------*
gen str200 tag_key = substr(genre, 1, 200)

merge m:1 tag_key using `dropterms', keep(master match) nogenerate

drop if drop_me == 1
drop drop_me tag_key

*------------------------------------------------------------*
* 4D) Re-pack tags so there are no gaps, then reshape wide again
*------------------------------------------------------------*
bys uid (genre_num): gen newj = _n
drop genre_num

reshape wide genre, i(uid) j(newj)

* Keep only first 20 genre columns
forvalues j = 21/300 {
    capture drop genre`j'
}

drop uid
compress

*======================================================
* SECTION 6: NORMALIZE GENRE TEXT
*======================================================

forvalues i = 1/20 {
    capture confirm variable genre`i'
    if !_rc {
        replace genre`i' = ustrlower(ustrtrim(genre`i'))
        
        * Fix common encoding issues
        replace genre`i' = subinstr(genre`i', "clàssics", "classics", .)
        replace genre`i' = subinstr(genre`i', "cómics", "comics", .)
        replace genre`i' = subinstr(genre`i', "Ãa-fiction", "ya-fiction", .)
    }
}


*--------------------------------------------------
* Get unique genre list with frequencies
*--------------------------------------------------

preserve
    keep book_id genre?*
    gen id = _n
    reshape long genre, i(id) j(position)
    drop if missing(genre) | genre == ""
    
    * Frequency table
    contract genre, freq(book_count)
    gsort -book_count
    
    * Export
    export delimited using "C:\Users\Yumna Hussain\The Brookings Institution\Book Bans\Main Output\unique_genres.csv", replace
    
    * Display top genres
    list in 1/30, sep(0)
    
    * Save for later use
    save "C:\Users\Yumna Hussain\The Brookings Institution\Book Bans\Main Output\unique_genres.dta", replace
restore

