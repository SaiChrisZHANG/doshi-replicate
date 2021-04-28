* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer
* This script merge price information of bonds, historical amount 
* outstanding information and bond issuer firm information in Compustat.

global mergentdir = "F:/Stephen/mergent"
global mergedir = `"${mergentdir}/merged_with_TRACE"'
global pricedir = `"${mergentdir}/output"'
global fpricedir = `"${mergentdir}/output/filtered version"'
global outdir = `"F:/Stephen/analysis/debt structure/bond debt"'

*===============================================================================
* Merging price
*===============================================================================
*++++++++++++++++++++++++++++++++++++++
* Merging strategy:
* Step 1: merge ${mergentdir}/mergent_amtinfo.dta to price information 
*         in ${pricedir} and ${fpricedir}
* Step 2: generate the value information of bonds
* Step 3: merge the value information back to firm information

* Different spcifications will be tested:
*++++ 1. three types of daily price information: the largest, the latest, the average
*++++ 2. merge the price information, then keep the largest, the latest
*++++++++++++++++++++++++++++++++++++++

* Step 1: Merge price with amount outstanding =================================
* filtered version: prices of bigger transactions (quantity>100000)
use `"${mergentdir}/mergent_amtinfo.dta"', clear
* 1437798 observations uniquely defined by ISSUE_IDXhist_effective_dt

global issue_vars1 = "ISSUE_ID ISSUER_CUSIP COMPLETE_CUSIP hist_effective_dt"
global issue_vars2 = "CONVERTIBLE ACTIVE_ISSUE hist_amt_out PRINCIPAL_AMT OFFERING_YIELD COUPON"
keep $issue_vars1 $issue_vars2

* filtered: price information of big transactions (>100000) only
preserve
merge 1:m ISSUE_ID hist_effective_dt using `"${fpricedir}/latest.dta"', keepusing(trd_exctn_dt price_latest yield_latest mean_abn seq_abn)
* 197924 ISSUE_ID-by-hist_effective_dt matched
keep if _merge==3
drop _merge

* merge with the largest transaction's price on a trading day
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${fpricedir}/largest.dta"', keepusing(price_largest yield_largest) nogen
* merge with the average (value-weighted/equal-weighted) transaction day price
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${fpricedir}/average.dta"', keepusing(price_avg yield_avg price_avg_w yield_avg_w) nogen

sort ISSUE_ID hist_effective_dt trd_exctn_dt 
save `"${outdir}/bond_value_f.dta"', replace
restore

* unfiltered: price information of all transactions
merge 1:m ISSUE_ID hist_effective_dt using `"${pricedir}/latest.dta"', keepusing(trd_exctn_dt price_latest yield_latest)
* 212207 ISSUE_ID-by-hist_effective_dt matched
keep if _merge==3
drop _merge

* merge with the largest transaction's price on a trading day
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${pricedir}/largest.dta"', keepusing(price_largest yield_largest) nogen
* merge with the average (value-weighted/equal-weighted) transaction day price
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${pricedir}/average.dta"', keepusing(price_avg yield_avg price_avg_w yield_avg_w) nogen

sort ISSUE_ID hist_effective_dt trd_exctn_dt
save `"${outdir}/bond_value.dta"', replace

* Step 2: generate bond value ==================================================
use `"${outdir}/bond_value_f.dta"', clear

foreach pr in "latest largest avg avg_w"{
    gen value_`pr' = hist_amt_out*price_`pr'
}