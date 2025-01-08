*==============================================================================*

clear all
set more off
set type double

cap log close
log using "log\Step7_Comparsion.smcl", replace

/* Factors */
import delimited "input\F-F_Research_Data_Factors.CSV", varnames(4) clear
drop if _n >= 1178
drop mktrf rf
destring smb hml, replace
rename v1 datex
gen year = substr(datex, 1, 4)
gen month = substr(datex, 5, 6)
destring year month, replace
gen date = ym(year, month)
format date %tm

keep date smb hml
replace smb = smb/100
replace hml = hml/100
rename smb FF_SMB
rename hml FF_HML
order date, first
rename date ldate

merge 1:1 ldate using "dta\Step6_FF3.dta", keep(3) nogen

gen FF_SMB_cumulativexx = ln(1+FF_SMB)
gen FF_SMB_cumulativex = sum(FF_SMB_cumulativexx)
gen FF_SMB_cumulative = exp(FF_SMB_cumulativex)-1
drop FF_SMB_cumulativexx FF_SMB_cumulativex

gen SMB_cumulativexx = ln(1+SMB)
gen SMB_cumulativex = sum(SMB_cumulativexx)
gen SMB_cumulative = exp(SMB_cumulativex)-1
drop SMB_cumulativexx SMB_cumulativex

gen FF_HML_cumulativexx = ln(1+FF_HML)
gen FF_HML_cumulativex = sum(FF_HML_cumulativexx)
gen FF_HML_cumulative = exp(FF_HML_cumulativex)-1
drop FF_HML_cumulativexx FF_HML_cumulativex

gen HML_cumulativexx = ln(1+HML)
gen HML_cumulativex = sum(HML_cumulativexx)
gen HML_cumulative = exp(HML_cumulativex)-1
drop HML_cumulativexx HML_cumulativex

#delimit ;
graph twoway (line FF_SMB ldate, lcolor(red) lwidth(thin) lpattern(dash))
			 (line SMB ldate, lcolor(blue) lwidth(thin)),
			 graphregion(color(white) ilwidth(none))			 
			 ylabel(-0.2(0.1)0.2, format(%7.2f))
			 xtitle("")
			 ytitle("SMB")
			 title("SMB")
			 xsize(10)
			 ysize(5)
			 legend(label(1 "FF") label(2 "Replication") region(style(none)) position(6))
;
#delimit cr
graph export "output\SMB.pdf", replace

#delimit ;
graph twoway (line FF_SMB_cumulative ldate, lcolor(red) lwidth(thin) lpattern(dash))
			 (line SMB_cumulative ldate, lcolor(blue) lwidth(thin)),
			 graphregion(color(white) ilwidth(none))
			 xlabel(30(80)767, format(%tm))
			 ylabel(1(0.5)4, format(%7.2f))
			 xtitle("")
			 ytitle("SMB_cumulative")
			 title("SMB_cumulative")
			 xsize(10)
			 ysize(5)
			 legend(label(1 "FF") label(2 "Replication") region(style(none)) position(6))
;
#delimit cr
graph export "output\SMB_cumulative.pdf", replace

#delimit ;
graph twoway (line FF_HML ldate, lcolor(red) lwidth(thin) lpattern(dash))
			 (line HML ldate, lcolor(blue) lwidth(thin)),
			 graphregion(color(white) ilwidth(none))			
			 ylabel(-0.2(0.1)0.2, format(%7.2f))
			 xtitle("")
			 ytitle("HML")
			 title("HML")
			 xsize(10)
			 ysize(5)
			 legend(label(1 "FF") label(2 "Replication") region(style(none)) position(6))
;
#delimit cr
graph export "output\HML.pdf", replace

#delimit ;
graph twoway (line FF_HML_cumulative ldate, lcolor(red) lwidth(thin) lpattern(dash))
			 (line HML_cumulative ldate, lcolor(blue) lwidth(thin)),
			 graphregion(color(white) ilwidth(none))
			 xlabel(30(80)767, format(%tm))
			 ylabel(0(2)12, format(%7.2f))
			 xtitle("")
			 ytitle("HML_cumulative")
			 title("HML_cumulative")
			 xsize(10)
			 ysize(5)
			 legend(label(1 "FF") label(2 "Replication") region(style(none)) position(6))
;
#delimit cr
graph export "output\HML_cumulative.pdf", replace

/* Number of firms */
import excel "input\F-F_Research_Data_Firms.xlsx", sheet("Sheet1") firstrow clear

rename date datex
tostring datex, replace
gen year = substr(datex, 1, 4)
gen month = substr(datex, 5, 6)
destring year month, replace
gen date = ym(year, month)
format date %tm
order date, first
drop datex
rename date ldate

merge 1:1 ldate using "dta\Step6_FF3.dta", keep(3) nogen

#delimit ;
graph twoway (line FF_total ldate, lcolor(red) lwidth(thin) lpattern(dash))
			 (line total_firms ldate, lcolor(blue) lwidth(thin)),
			 graphregion(color(white) ilwidth(none))
			 xlabel(50(80)780, format(%tm))
			 ylabel(0(1000)7000, format(%7.0f))
			 xtitle("")
			 ytitle("Number of Firms")
			 title("Number of Firms")
			 xsize(10)
			 ysize(5)
			 legend(label(1 "FF") label(2 "Replication") region(style(none)) position(6))
;
#delimit cr
graph export "output\Number of Firms.pdf", replace

log close

*==============================================================================*