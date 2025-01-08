*==============================================================================*

clear all
set more off
set type double

cap log close
log using "log\Step5_Sort.smcl", replace

/* Load Merged Compustat&CRSP */

u "dta\Step3_Compustat_CRSP.dta", clear
drop meJun meDec be_meDec

/* Merge NYSE Breakpoints */

merge 1:1 permco ldate using "dta\Step4_Breakpoints.dta", keep(1 3) nogen

/* Sort */

gen sizeport = "S" if meJun < meJun_50 & meJun != . & be_meDec !=.
replace sizeport = "B" if meJun > meJun_50 & meJun != . & be_meDec !=.
gen btmport = "L" if be_meDec <= be_meDec_30 & be_meDec != . & meJun != .
replace btmport = "M" if be_meDec > be_meDec_30 & be_meDec <= be_meDec_70 & be_meDec != . & meJun != .
replace btmport = "H" if be_meDec > be_meDec_70 & be_meDec != . & meJun != .
gen nonmissport = 1 if sizeport != "" & btmport != ""
replace nonmissport = 0 if nonmissport == .

/* Label variables */

label var sizeport        "Size portfolio"
label var btmport		  "Book to market equity portfolio"
label var nonmissport     "Portfolio in sample"

/* Save data */

compress

sort permco ldate

save "dta\Step5_Sort.dta", replace

log close

*==============================================================================*