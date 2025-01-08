*==============================================================================*
 
clear all
set more off /* list the left results */
set type double /* which is more precise than the default float type */

local year = 2023

cap log close
log using "log\Step1_Compustat.smcl", replace

/* Load Compustat Annual */

u "dta\CRSP_Compustat Merged Annual.dta", clear
rename *, lower
save "dta\CRSP_Compustat Merged Annual.dta", replace

#delimit ;
u gvkey lpermno linktype linkenddt datadate fyear fyr pddur
	at lt ceq pstk pstkl pstkrv seq txditc
	if pddur==12
	using "dta\CRSP_Compustat Merged Annual", clear
;
#delimit cr

drop pddur

/* Fix variables */

replace linkenddt = mofd(linkenddt)
replace datadate = mofd(datadate)

recode txditc (.=0)

replace seq = ceq+pstk if seq==.
replace seq = at-lt if seq==.

drop at lt

/* Construct variables */

gen int ldate = datadate+6 /* Fully disgest the earnings annoucement */

gen preferred = pstkrv
replace preferred = pstkl if preferred==.
replace preferred = pstk if preferred==.

gen be = seq+txditc-preferred if fyear<1993 /* See https://dx.doi.org/10.2139/ssrn.4629613 */
replace be = seq-preferred if fyear>=1993
replace be = . if be<=0

drop preferred ceq pstk pstkl pstkrv seq txditc

/* Expand to monthly sample */

sort lpermno ldate
by lpermno: gen byte obs = min(ldate[_n+1]-ldate,12)

expand obs

sort lpermno ldate
by lpermno ldate: replace ldate = ldate+_n-1

drop obs

/* Sample criteria */

keep if be<.

keep if ldate<=linkenddt

keep if inrange(ldate,tm(1963m6),tm(`year'm12))

/* Label variables */

rename lpermno permno

format %tm linkenddt datadate ldate

label var ldate		"CRSP link date"
label var be		"Book equity ($ million)"

/* Save data */

compress

sort permno ldate

save "dta\Step1_Compustat.dta", replace

log close

*==============================================================================*