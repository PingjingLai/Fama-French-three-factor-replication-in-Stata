*==============================================================================*

clear all
set more off
set type double

cap log close
log using "log\Step4_Breakpoints.smcl", replace

/* Load Merged Compustat&CRSP */

u "dta\Step3_Compustat_CRSP.dta", clear

/* NYSE Breakpoints */

gen month = month(date)
keep if month == 7 /* The month for each portfolio starts */

keep if exchcd == 1 & inlist(shrcd,10,11)
keep if linktype == "LU" | linktype == "LC"

bys ldate: egen meJun_50 = pctile(meJun), p(50)

foreach i of numlist 30 70 {
	bys ldate: egen be_meDec_`i' = pctile(be_meDec), p(`i')
}

/* Save data */

keep date ldate meJun_* be_meDec_*
duplicates drop
save "dta\Breakpoints.dta", replace

/* Load Merged Compustat&CRSP */

u "dta\Step3_Compustat_CRSP.dta", clear

gen month = month(date)
keep if month == 7 /* The month for each portfolio starts */

/* Expand to monthly sample */

sort permco ldate
by permco: gen byte obs = min(ldate[_n+1]-ldate,12)

expand obs

sort permco ldate
by permco ldate: replace ldate = ldate+_n-1

drop obs

/* Sample criteria */

keep if inrange(ldate,tm(1963m7),tm(2023m12))
keep date ldate permco meJun meDec be_meDec

merge n:1 date using "dta\Breakpoints.dta", nogen
drop date
erase "dta\Breakpoints.dta"

/* Label variables */

label var meJun_50		"Market equity 50% breakpint"
label var be_meDec_30	"Book equity to Market equity 30% breakpint"
label var be_meDec_70	"Book equity to Market equity 70% breakpint"

/* Save data */

compress

sort permco ldate

save "dta\Step4_Breakpoints.dta", replace

log close

*==============================================================================*