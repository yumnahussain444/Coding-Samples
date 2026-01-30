/**********************************************************************
1) GOODREADS
**********************************************************************/
* Merging all the good read datasets
import delimited "${GR_DIR}\goodreads_books.csv", ///
    varnames(1) stringcols(_all) bindquote(strict) maxquotedrows(1000) clear

save "${OUT_DIR}\goodreads_books.dta", replace


import delimited "${GR_DIR}\goodreads_book_genres.csv", ///
    varnames(1) stringcols(_all) bindquote(strict) maxquotedrows(1000) clear

save "${OUT_DIR}\goodreads_book_genres.dta", replace


merge 1:1 book_id using "${OUT_DIR}\goodreads_books.dta"

save "${OUT_DIR}\goodreads_combined.dta", replace

/**********************************************************************
2) PEN AMERICA
*********************************************************************/

import delimited using "${PEN_DIR}\2021-22.csv", varnames(1) clear
    tab district if title == ""

save "${OUT_DIR}\2021-22.dta", replace


import delimited using "${PEN_DIR}\2022-23.csv", varnames(1) clear
    tab district if title == ""
    
save "${OUT_DIR}\2022-23.dta", replace


import delimited using "${PEN_DIR}\2023-24.csv", varnames(1) clear
    tab district if title == ""

save "${OUT_DIR}\2023-24.dta", replace


import delimited using "${PEN_DIR}\2024-25.csv", varnames(1) clear
    tab district if title == ""
    
save "${OUT_DIR}\2024-25.dta", replace


use "${OUT_DIR}\2021-22.dta", clear
append using "${OUT_DIR}\2022-23.dta"
append using "${OUT_DIR}\2023-24.dta"
append using "${OUT_DIR}\2024-25.dta"

keep title author secondaryauthors illustrators translators ///
 state district dateofchallengeremoval banstatus originofchallenge
drop if title ==""

save "${OUT_DIR}\combined_original.dta", replace
save "${OUT_DIR}\combined_penamerica_unstripped.dta", replace
