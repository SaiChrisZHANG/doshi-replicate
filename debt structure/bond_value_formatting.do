* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer
* This script merge price information of bonds, historical amount 
* outstanding information and bond issuer firm information in Compustat.

global mergentdir = "F:/Stephen/mergent"
global mergedir = `"${mergentdir}/merged_with_TRACE"'
global pricedir = `"${mergentdir}/output"'
global fpricedir = `"${mergentdir}/output/filtered version"'

global analysisdir = `"F:/Stephen/analysis"'
global bonddir = `"${analysisdir}/debt structure/bond debt"'

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
*++++ 1. three types of daily price information: the largest, the latest, the average (equal-weighted/value-weighted)
*++++ 2. merge the price information, then keep the latest, the average
*++++++++++++++++++++++++++++++++++++++

* Step 1: Merge price with amount outstanding =================================
* filtered version: prices of bigger transactions (quantity>100000)
use `"${mergentdir}/mergent_amtinfo.dta"', clear
* 1437798 observations uniquely defined by ISSUE_IDXhist_effective_dt

global issue_vars1 = "ISSUE_ID ISSUER_CUSIP COMPLETE_CUSIP hist_effective_dt MATURITY"
global issue_vars2 = "CONVERTIBLE ACTIVE_ISSUE hist_amt_out PRINCIPAL_AMT OFFERING_YIELD OFFERING_AMT COUPON"
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
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${fpricedir}/average.dta"', keepusing(quant_avg price_avg yield_avg price_avg_w yield_avg_w) nogen
rename quant_avg quant_total

sort ISSUE_ID hist_effective_dt trd_exctn_dt 
save `"${bonddir}/bond_value_f.dta"', replace
restore

* unfiltered: price information of all transactions
merge 1:m ISSUE_ID hist_effective_dt using `"${pricedir}/latest.dta"', keepusing(trd_exctn_dt price_latest yield_latest)
* 212207 ISSUE_ID-by-hist_effective_dt matched
keep if _merge==3
drop _merge

* merge with the largest transaction's price on a trading day
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${pricedir}/largest.dta"', keepusing(price_largest yield_largest) nogen
* merge with the average (value-weighted/equal-weighted) transaction day price
merge 1:1 ISSUE_ID hist_effective_dt trd_exctn_dt using `"${pricedir}/average.dta"', keepusing(quant_avg price_avg yield_avg price_avg_w yield_avg_w) nogen
rename quant_avg quant_total

sort ISSUE_ID hist_effective_dt trd_exctn_dt
save `"${bonddir}/bond_value.dta"', replace

* Step 2: Generate bond value ==================================================
use `"${bonddir}/bond_value_f.dta"', clear
foreach pr in latest largest avg avg_w{
    gen value_`pr' = hist_amt_out*price_`pr'/100
}
save, replace

use `"${bonddir}/bond_value.dta"', clear
foreach pr in latest largest avg avg_w{
    gen value_`pr' = hist_amt_out*price_`pr'/100
}
save, replace
clear

* Step 3: Merge the bond value to firm information =============================
* to save memory, used a sub set of only gvkey + datadate + cusip6

use `"${analysisdir}/full_data.dta"', clear
keep gvkey datadate cusip
* generate firm CUSIP ids
gen ISSUER_CUSIP = substr(cusip,1,6)
drop cusip
* generate the month beginning date
egen datadate_lag = eomd(datadate), f(%td) lag(1)
replace datadate_lag= datadate_lag+1

* drop information before July 1, 2002
drop if datadate < 15522

tempfile fullid
save `fullid', replace

* do the range merge: for each month from datadate_lag to datadate, find all bond value information
*** filtered value
rangejoin trd_exctn_dt datadate_lag datadate using `"${bonddir}/bond_value_f.dta"', by(ISSUER_CUSIP) keepusing(ISSUE_ID CONVERTIBLE COUPON PRINCIPAL_AMT MATURITY price_* yield_* value_* *_abn)
drop if mi(ISSUE_ID)

preserve
* for each bond, in each month, keep the latest value information
sort gvkey ISSUE_ID datadate trd_exctn_dt
by gvkey ISSUE_ID datadate: keep if _n==_N
* 383311 gvkey-by-datadate-by-ISSUE_ID 
sort gvkey datadate ISSUE_ID
drop trd_exctn_dt
save `"${bonddir}/bondv_f_mth_latest.dta"', replace
restore

* for each month, calculate the equal-weighted average
foreach var in price yield value{
    foreach spec in latest largest avg avg_w{
        bys gvkey ISSUE_ID datadate: egen `var'_`spec'_mean = mean(`var'_`spec')
    }
}
* drop trading-date level bond information
drop trd_exctn_dt price_latest yield_latest mean_abn seq_abn price_largest yield_largest price_avg yield_avg price_avg_w yield_avg_w value_latest value_largest value_avg value_avg_w
duplicates drop gvkey ISSUE_ID datadate, force
save `"${bonddir}/bondv_f_mth_mean.dta"', replace
clear

use `fullid', clear
* do the range merge: for each month from datadate_lag to datadate, find all bond value information
*** filtered value
rangejoin trd_exctn_dt datadate_lag datadate using `"${bonddir}/bond_value.dta"', by(ISSUER_CUSIP) keepusing(ISSUE_ID CONVERTIBLE COUPON PRINCIPAL_AMT MATURITY price_* yield_* value_*)
drop if mi(ISSUE_ID)

preserve
* for each bond, in each month, keep the latest value information
sort gvkey ISSUE_ID datadate trd_exctn_dt
by gvkey ISSUE_ID datadate: keep if _n==_N
* 414570 gvkey-by-datadate-by-ISSUE_ID 
sort gvkey datadate ISSUE_ID
drop trd_exctn_dt
save `"${bonddir}/bondv_mth_latest.dta"', replace
restore

* for each month, calculate the equal-weighted average
foreach var in price yield value{
    foreach spec in latest largest avg avg_w{
        bys gvkey ISSUE_ID datadate: egen `var'_`spec'_mean = mean(`var'_`spec')
    }
}
* drop trading-date level bond information
drop trd_exctn_dt price_latest yield_latest price_largest yield_largest price_avg yield_avg price_avg_w yield_avg_w value_latest value_largest value_avg value_avg_w
duplicates drop gvkey ISSUE_ID datadate, force
sort gvkey datadate ISSUE_ID
save `"${bonddir}/bondv_mth_mean.dta"', replace
clear