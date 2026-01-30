**This is a file to sanity check the number dropping process. All the genres whichwere dropped have been calculated. Once you run this file 1578 genres must remain in your unique genres after drop csv. 

*======================================================
* DROP GENRES IN TXT FILE FROM unique_genres.dta
*======================================================

clear all
set more off
version 17

*------------------------------------------------------*
* Paths
*------------------------------------------------------*
local base "C:\Users\Yumna Hussain\The Brookings Institution\Book Bans\Main Output"
local f_unique    "`base'\unique_genres.dta"
local f_drop_tags "`base'\genres_to_drop.txt"

*10284 Unique Genres
*After we drop with book counts 1,2,3 we have 3750 genres left (6534 dropped)
*1134 genres were assigned to our dataset (2616 remain)
*of the remaining 2616 - 444 were added to our main dataset and 2176 were dropped. 
*1577 remain 


tempfile dropterms

*------------------------------------------------------*
* 1) Build dropterms dataset from text file
*    (expects ONE TAG PER LINE)
*------------------------------------------------------*
preserve
    import delimited using "`f_drop_tags'", ///
        varnames(nonames) clear stringcols(1) encoding(UTF-8)

    rename v1 genre
    replace genre = ustrlower(ustrtrim(genre))
    drop if missing(genre)

    duplicates drop genre, force
    gen byte drop_me = 1

    save `dropterms', replace
restore

*------------------------------------------------------*
* 2) Load your unique_genres dataset and clean genre
*------------------------------------------------------*
use "`f_unique'", clear
replace genre = ustrlower(ustrtrim(genre))
drop if missing(genre)

*------------------------------------------------------*
* 3) Merge + drop matches
*------------------------------------------------------*
merge m:1 genre using `dropterms', keep(master match)

* how many will be dropped?
count if _merge == 3
local n_drop = r(N)
di as result "Dropping `n_drop' tags based on drop_genres_tag.txt"

* drop them
drop if _merge == 3
drop _merge drop_me

*------------------------------------------------------*
* 4) What's left?
*------------------------------------------------------*
count
gsort -book_count
list genre book_count in 1/50

* Optional: save output
save "`base'\unique_genres_after_drop.dta", replace
export delimited using "`base'\unique_genres_after_drop.csv", replace
