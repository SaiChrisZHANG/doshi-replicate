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
* Merging
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

* filtered version: prices of bigger transactions (quantity>100000)
use `"${mergentdir}/mergent_amtinfo.dta"', clear
* 1437798 observations uniquely defined by ISSUE_IDXhist_effective_dt

global issue_vars1 = "ISSUE_ID ISSUER_CUSIP COMPLETE_CUSIP hist_effective_dt"
global issue_vars2 = "CONVERTIBLE ACTIVE_ISSUE hist_amt_out PRINCIPAL_AMT OFFERING_YIELD COUPON"
keep $issue_vars1 $issue_vars2

merge 1:m ISSUE_ID hist_effective_dt using `"${fpricedir}/latest.dta"', keepusing(trd_exctn_dt price_latest yield_latest mean_abn seq_abn)
* 197924 ISSUE_ID-by-hist_effective_dt matched
keep if _merge==3
drop _merge
save `"${outdir}/value_filtered.dta"', replace

preserve
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${fpricedir}/largest.dta"', keepusing(price_largest yield_largest)
* 197924 ISSUE_ID-by-hist_effective_dt matched
keep if _merge==3
drop _merge
save `"${outdir}/value_f_largest.dta"', replace
restore