*==============================================================================*

clear all
set more off
set type double

cap log close
log using "log\Step6_FF3.smcl", replace

/* Load Sort */

u "dta\Step5_Sort.dta", clear

keep if inlist(shrcd,10,11)
keep if linktype == "LU" | linktype == "LC"
keep if nonmissport == 1

/* Weighted portfolio return */

gen daret_meJun = daret*meJun
bys ldate sizeport btmport: egen daret_meJun_port = total(daret_meJun)
bys ldate sizeport btmport: egen meJun_port = total(meJun)
gen daret_port = daret_meJun_port / meJun_port

drop daret_meJun daret_meJun_port meJun_port

/* Number of firms */

bys ldate sizeport btmport: egen n_firms = count(permco)
gen port = sizeport + btmport

/* Save data */

keep ldate sizeport btmport daret_port n_firms port
sort ldate port

tempfile Portfolio
save `Portfolio'

/* Tranform the data format */

foreach var in BH SH BM SM BL SL {
	u `Portfolio', clear
	keep if port == "`var'"
	rename daret_port `var'_daret_port
	rename n_firms `var'_n_firms
	duplicates drop ldate port, force
	save `var', replace
}

u BH, clear

foreach var in SH BM SM BL SL {
	merge 1:1 ldate using `var'.dta, nogen
	erase `var'.dta
}

erase BH.dta

/* HML */

gen H = (BH_daret_port + SH_daret_port)/2
gen L = (SL_daret_port + BL_daret_port)/2
gen HML = H - L
drop H L

/* SMB */

gen B = (BL_daret_port + BM_daret_port + BH_daret_port)/3
gen S = (SL_daret_port + SM_daret_port + SH_daret_port)/3
gen SMB = S - B
drop B S
drop *port

/* Total firms */

gen total_firms = (BL_n_firms + BM_n_firms + BH_n_firms + SL_n_firms + SM_n_firms + SH_n_firms)
drop *_n_firms

/* Label variables */

label var HML 		     "HML factor"
label var SMB 		     "SMB factor"
label var total_firms    "Number of firms each month"

/* Save data */

compress

sort ldate

save "dta\Step6_FF3.dta", replace

log close

*==============================================================================*