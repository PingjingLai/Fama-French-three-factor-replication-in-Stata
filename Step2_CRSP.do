*==============================================================================*

clear all
set more off
set type double

cap log close
log using "log\Step2_CRSP.smcl", replace

/* Load CRSP Monthly Stock */

u "dta\CRSP Monthly Stock.dta", clear
rename *, lower
save "dta\CRSP Monthly Stock.dta", replace

#delimit ;
u permno permco date shrcd exchcd
	dlretx dlret prc ret shrout retx
	if inrange(exchcd,1,3)
	using "dta\CRSP Monthly Stock.dta", clear
;
#delimit cr

duplicates drop

/* Fix variables */

recode prc (-99999=.)	/* Missing code */

replace prc = abs(prc)

replace shrout = shrout/1e3

/* Construct variables */

gen int ldate = mofd(date)

gen meq = prc*shrout
sort date permco meq
by date permco: egen sum_meq = total(meq), missing /* A firm may have different permnos. 
As https://dx.doi.org/10.2139/ssrn.4629613 suggests, we use permco in the following replication */

replace meq = -99999 if meq == .

sort date permco meq
by date permco: keep if _n==_N
rename sum_meq me

drop meq

* Label variables */

format %tm ldate

label var ldate		"CRSP link date"
label var me		"Market equity ($ million)"

/* Save data */

compress

sort permco ldate

save "dta\Step2_CRSP.dta", replace

log close

*==============================================================================*