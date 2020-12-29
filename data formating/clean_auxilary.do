* Fama-French data clean
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* This script cleans the dataset downloaded from Kenneth French's website for further analysis, the data will be formatted according to the matlab/python codes that run the main analysis.

*===============================================================================
* Import and clean dataset
*===============================================================================
* risk free rate
import delimited "F:\Stephen\french_website\ffRf.csv", encoding(ISO-8859-2) 
rename rf rfFFWebsite
rename date yyyymm
drop smb hml
rename mktrf risk_premium
save french_fama, replace
clear

* size portfolio breakpoints
import delimited "F:\Stephen\french_website\breakpoints_ME.csv", encoding(ISO-8859-2)
drop num
rename date yyyymm
drop p_5 p_15 p_25 p_35 p_45 p_55 p_65 p_75 p_85 p_95
save ME_breakpoints, replace
clear

* Book-to-Market ratio portfolio breakpoints
import delimited "F:\Stephen\french_website\breakpoints_BE-ME.csv", encoding(ISO-8859-2)
drop num_neg num_pos
drop p_5 p_15 p_25 p_35 p_45 p_55 p_65 p_75 p_85 p_95
replace year=year*100+6
rename year yyyymm
save BtM_breakpoints, replace
clear

*===============================================================================
* merge them all together
*===============================================================================
cd F:/Stephen/french_website
use french_fama

* merge with ME_breakpoints
keep if round(yyyymm/100)>=1961
merge 1:1 yyyymm using ME_breakpoints
drop if _merge==2
drop _merge

* rename variables
forvalues i=1/10{
local j=`i'*10
rename p_`j' ME_p`j'
}

* merge with BtM_breakpoints
merge 1:1 yyyymm using BtM_breakpoints, nogen
drop if round(yyyymm/100)<1960
sort yyyymm
forvalues i=1/10{
local j=`i'*10
replace p_`j'=p_`j'[_n-1] if p_`j'==.
rename p_`j' BtM_p`j'
}
keep if round(yyyymm/100)>=1961
save, replace

* ==============================================================================
* equity volatility
* ==============================================================================
use "F:\Stephen\auxilary data\dailty_return.dta" 
rename CUSIP cusip8
drop PERMNO

gen YMD = string(year(date)-2) + "/" + string(month(date)) + "/" + string(day(date))
gen date_low = date(YMD,"YMD")
* 62774 missings, due to Fed 29
replace YMD = string(year(date)-2) + "/" + string(month(date)) + "/" + string(day(date)-1) if mi(date_low)
replace date_low = date(YMD,"YMD") if mi(date_low)
format date_low %td
drop YMD

rangestat (sd) RET, interval(date, date_low, date) by(cusip8)
gen EquityVolatility = RET_sd*sqrt(252)

keep date cusip8 EquityVolatility
gen yyyymm = year(date)*100 + month(date)
sort cusip8 yyyymm date
by cusip8 yyyymm: keep if _n=_N

* change yyyymm (merging key) s.t. month t's volatility is merged with month t+1's return
replace yyyymm = yyyymm+1
replace yyyymm = (year(date)+1)*100 + 1 if month(date)==12
gen Lag1 = yyyymm

save monthly_volatility, replace
*