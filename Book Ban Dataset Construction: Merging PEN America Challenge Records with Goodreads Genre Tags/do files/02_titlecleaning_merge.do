/**********************************************************************
3) DUPLICATION MANAGEMENT, TITLE STANDARDIZATION, MERGE
*********************************************************************/

* =================== GOOD READS ===================
use "${OUT_DIR}\goodreads_combined.dta", clear

*Convert to numeric
capture confirm numeric variable ratings_count
if _rc destring ratings_count, replace ignore(",")

duplicates tag title, gen(dup_title)
* Tag titles that appear more than once
bys title: gen byte is_dup = (_N > 1)

bysort title (ratings_count): gen int dup_rank = cond(missing(ratings_count), ., _N - _n + 1) if is_dup

*how many in each dup group?
bys title: gen int dup_size = _N if is_dup
list title ratings_count dup_rank if is_dup, sepby(title) noobs

drop if !missing(title) & ustrregexm(title, "[^\u0000-\u007F]")
*(247,600 observations deleted)

keep if dup_rank == 1 | missing(dup_rank)
*(570,898 observations deleted)

*These had wierd duplicates but doesn't matter because they aren't in PEN AMERICA
drop if title == "The Stars' Tennis Balls"
drop if title == "The Things"
drop if title == "Wonder Woman #0 (The New 52)"
drop if title == "Wonder Woman #1 (The New 52)"
drop if title == "The Stars' Tennis Balls"

save "${OUT_DIR}\goodreads_combined_noduplicates.dta", replace
use "${OUT_DIR}\goodreads_combined_noduplicates.dta", clear

capture drop title_consistent
gen strL __t = title

* Unicode cleanup
replace __t = ustrnormalize(__t, "nfc")
replace __t = subinstr(__t, uchar(160), " ", .)
replace __t = ustrregexra(__t, "\p{Cf}", "")              

* remove anything inside (...) or [...]
replace __t = ustrregexra(__t, "\s*[\(\[].*?[\)\]]", "")

* remove punctuation entirely
replace __t = ustrregexra(__t, "[[:punct:]]+", "")

* remove ALL whitespace
replace __t = ustrregexra(__t, "[[:space:]]+", "")

* lowercase
replace __t = ustrlower(__t)

* fixed-width key for merges (merge cannot use strL)
gen str2045 title_consistent = __t
drop __t

drop if genres == "{}"
*(302,576 observations deleted)

*removing duplicates from the title_consistent aspect
capture confirm numeric variable ratings_count
if _rc destring ratings_count, replace ignore(",")

* Keep the highest-rated row per title_consistent
bysort title_consistent (ratings_count): keep if _n == _N
*(177,997 observations deleted)

save "${OUT_DIR}\goodreads_combined_title_consistent_stripped.dta", replace


* =================== PEN AMERICA ===================
use "${OUT_DIR}\combined_penamerica_unstripped.dta", clear

capture drop title_consistent
gen strL __t = title

replace __t = ustrnormalize(__t, "nfc")
replace __t = subinstr(__t, uchar(160), " ", .)
replace __t = ustrregexra(__t, "\p{Cf}", "")
replace __t = ustrregexra(__t, "\s*[\(\[].*?[\)\]]", "")
replace __t = ustrregexra(__t, "[[:punct:]]+", "")
replace __t = ustrregexra(__t, "[[:space:]]+", "")
replace __t = ustrlower(__t)

gen str2045 title_consistent = __t
drop __t

save "${OUT_DIR}\combined_penamerica_stripped.dta", replace


clear all

* =================== MERGE ===================
local GR "C:\Users\Yumna Hussain\The Brookings Institution\Book Bans\Main Output\goodreads_combined_title_consistent_stripped.dta"
local PEN "C:\Users\Yumna Hussain\The Brookings Institution\Book Bans\Main Output\combined_penamerica_stripped.dta"

*master - goodreads
use `"`GR'"', clear
drop if missing(title_consistent)
isid title_consistent   // should pass (1 per title_consistent)

* 1:m merge: attach many PEN rows
merge 1:m title_consistent using ///
    "${OUT_DIR}\combined_penamerica_stripped.dta", ///
    gen(_m)   // keep all by default; creates _m = 1(master),2(using),3(match)


* ---- save each slice ----
preserve
    keep if _m==1
    save "${OUT_DIR}\goodread_unmatched.dta", replace
restore

preserve
    keep if _m==3
    save "${OUT_DIR}\goodread_penamerica_matched.dta", replace
restore

preserve
    keep if _m==2   // using-only = PEN unmatched
    export delimited using ///
        "${OUT_DIR}\penamerica_unmatched.csv", ///
        replace quote
restore

*Any book titles that were banned in 10+ districts had their genres manually entered. The rest we left behind (1797/5715)
*The document with only 1797 is saved as penamerica_unmatched_duplicatteordered.csv
