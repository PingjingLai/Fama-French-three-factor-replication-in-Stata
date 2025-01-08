*==============================================================================*

clear all
set more off
set type double

cap log close
log using "log\Step3_Compustat_CRSP.smcl", replace

/* Load CRSP Monthly Stock */

u "dta\Step2_CRSP.dta", clear

/* Merge Compustat */

#delimit ;
merge 1:1 permno ldate using "dta\Step1_Compustat.dta", 
	keepusing(gvkey linktype fyear datadate ldate be) 
	update replace
;
#delimit cr
	
drop if _merge==2
drop _merge

/* Construct variables */

sort permco ldate

gen meDec = .
gen meJun = .

gen month = month(date)
gen year = year(date)

gen dateDec = ym(year-1, 12)
gen dateJun = ym(year, 6)

drop month year

by permco: replace meDec = me[_n-7] if ldate[_n-7]==dateDec
by permco: replace meJun = me[_n-1] if ldate[_n-1]==dateJun

gen be_meDec = be/meDec

drop dateDec dateJun

/* Construct delisting adjusted return */

gen daret = ret if ret<. & dlret==.
replace daret = dlret if ret==. & dlret<.
replace daret = (1+ret)*(1+dlret)-1 if ret<. & dlret<.

gen daretx = retx if retx<. & dlretx==.
replace daretx = dlretx if retx==. & dlretx<.
replace daretx = (1+retx)*(1+dlretx)-1 if retx<. & dlretx<.

drop dlretx dlret

/* Label variables */

label var me		"Market equity ($ million)"
label var meDec		"Market equity on December of t-1 ($ million)"
label var meJun		"Market equity on June of t ($ million)"
label var be_meDec	"Book equity to Market equity on December of t-1"

label var daret		"Delisting adjusted return"
label var daretx	"Delisting adjusted return without dividends"

/* Save data */

compress

sort permco ldate

save "dta\Step3_Compustat_CRSP.dta", replace

log close

*==============================================================================*