* Your original string variable: dateofchallengeremoval (str12)

gen month = ""
gen year  = ""

* ---------------------------------------------------------
* 0. Normalize formats like "24 - Mar" → "24-Mar"
* ---------------------------------------------------------
replace dateofchallengeremoval = subinstr(dateofchallengeremoval, " ", "", .)
replace dateofchallengeremoval = subinstr(dateofchallengeremoval, "--", "-", .)
replace dateofchallengeremoval = subinstr(dateofchallengeremoval, "- -", "-", .)

* ---------------------------------------------------------
* 1. Handle DD-Mon format (e.g., "21-Nov")
* ---------------------------------------------------------
gen mon_abbrev = substr(dateofchallengeremoval, strpos(dateofchallengeremoval, "-") + 1, .) ///
    if regexm(dateofchallengeremoval, "^[0-9]{2}-[A-Za-z]{3}$")

gen yy = substr(dateofchallengeremoval, 1, 2) ///
    if regexm(dateofchallengeremoval, "^[0-9]{2}-[A-Za-z]{3}$")

replace year = "20" + yy if yy != ""

* ---------------------------------------------------------
* 2. Handle Mon-YY format (e.g., "Mar-24")
* ---------------------------------------------------------
replace mon_abbrev = substr(dateofchallengeremoval, 1, 3) ///
    if regexm(dateofchallengeremoval, "^[A-Za-z]{3}-[0-9]{2}$")

replace yy = substr(dateofchallengeremoval, 5, 2) ///
    if regexm(dateofchallengeremoval, "^[A-Za-z]{3}-[0-9]{2}$")

replace year = "20" + yy if regexm(dateofchallengeremoval, "^[A-Za-z]{3}-[0-9]{2}$")

* ---------------------------------------------------------
* 3. Convert month abbreviations to numeric
* ---------------------------------------------------------
replace month = "01" if mon_abbrev == "Jan"
replace month = "02" if mon_abbrev == "Feb"
replace month = "03" if mon_abbrev == "Mar"
replace month = "04" if mon_abbrev == "Apr"
replace month = "05" if mon_abbrev == "May"
replace month = "06" if mon_abbrev == "Jun"
replace month = "07" if mon_abbrev == "Jul"
replace month = "08" if mon_abbrev == "Aug"
replace month = "09" if mon_abbrev == "Sep"
replace month = "10" if mon_abbrev == "Oct"
replace month = "11" if mon_abbrev == "Nov"
replace month = "12" if mon_abbrev == "Dec"

* ---------------------------------------------------------
* 4. Handle season-year format (e.g., "Fall 2022")
* ---------------------------------------------------------
replace year = regexs(1) if regexm(dateofchallengeremoval, "([0-9]{4})")
replace month = "" if regexm(dateofchallengeremoval, "Fall|Spring|Summer|Winter")

* ---------------------------------------------------------
* 5. Clean up
* ---------------------------------------------------------
drop mon_abbrev yy

save "C:\Users\Yumna Hussain\The Brookings Institution\Book Bans\Main Output\finaldataset.dta",replace 
