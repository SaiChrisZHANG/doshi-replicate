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
* Merging face value
*===============================================================================
* This only requires merging the mergent historical amount oustanding data
*++++++++++++++++++++++++++++++++++++++
* Merging strategy:
* merge firm id to ${mergentdir}/mergent_amtinfo.dta, to build a base data set for further merging
* For each hist_effective_dt in mergent_amtinfo.dta, all months before the next hist_effective_dt will be extracted from firm data
*
* This data set will be used to merge with firm information, with bond price information and other data sets 
*++++++++++++++++++++++++++++++++++++++
* generate an intermediary data set, containing only gvkey cusip6 and datadate from full_data.dta
use `"${analysisdir}/full_data.dta"', clear
* generate firm CUSIP ids
gen ISSUER_CUSIP = substr(cusip,1,6)
keep gvkey ISSUER_CUSIP datadate yyyymm
save `"${analysisdir}/full_id.dta"', replace

* first merge gvkey to cusip
drop datadate yyyymm
duplicates drop gvkey, force
duplicates tag ISSUER_CUSIP, gen(dup)
qui{
    levelsof gvkey if dup>0, l(gvkey_dup)
    drop dup
}
tempfile idlist
save `idlist', replace

use `"${mergentdir}/mergent_amtinfo.dta"', clear
sort ISSUE_ID hist_effective_dt
gen dt_begin = hist_effective_dt + 1
by ISSUE_ID: gen dt_end = hist_effective_dt[_n+1]
format dt_begin dt_end %td

* merge gvkey ids first: ISSUER_CUSIP is NOT uniquely defined in firm data
merge m:m ISSUER_CUSIP using `idlist'
keep if _merge == 3
* only 64982 observations kept
drop _merge

qui{
    gen cusipdup_tag = 0
    foreach var of local gvkey_dup{
        qui replace cusipdup_tag = 1 if (gvkey == `var')
    }
}

* do the range merge: for each month from dt_begin to dt_end, find all firm id
rangejoin datadate dt_begin dt_end using `"${analysisdir}/full_id.dta"', by(gvkey) keepusing(yyyymm)
drop if mi(datadate)
save`"${analysisdir}/full_bond.dta"', replace
* 1687637 observations. For each firm (gvkey), in each month (datadate), the information of each bond (ISSUE_ID)
* uniquely defined by ISSUE_ID by datadate

*===============================================================================
* Generate Value information
*===============================================================================
*++++++++++++++++++++++++++++++++++++++
* Merging strategy:
* Step 1: merge ${mergentdir}/mergent_amtinfo.dta to price information 
*         in ${pricedir} and ${fpricedir}
* Step 2: generate the value information of bonds

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

* Step 2: Generate monthly bond value ==========================================
use `"${bonddir}/bond_value_f.dta"', clear
foreach pr in latest largest avg avg_w{
    gen value_f_`pr' = hist_amt_out*price_`pr'*10
    * price is a percent (/100), principal is 1000.
}
* generate a year-month 6 digit indicator for merge
gen yyyymm = year(trd_exctn_dt)*100 + month(trd_exctn_dt)
* keep the latest transaction day of the month
sort ISSUE_ID yyyymm trd_exctn_dt
by ISSUE_ID yyyymm: keep if _n==_N
merge m:m ISSUER_CUSIP using `idlist'
keep if _merge == 3
save `"${bonddir}/bond_value_f.dta"', replace

use `"${bonddir}/bond_value.dta"', clear
foreach pr in latest largest avg avg_w{
    gen value_`pr' = hist_amt_out*price_`pr'*10
}
gen yyyymm = year(trd_exctn_dt)*100 + month(trd_exctn_dt)
sort ISSUE_ID yyyymm trd_exctn_dt
by ISSUE_ID yyyymm: keep if _n==_N
merge m:m ISSUER_CUSIP using `idlist'
keep if _merge == 3
save `"${bonddir}/bond_value.dta"', replace
clear

*===============================================================================
* Step 3: Merge bond value (value & face value) to firm data
*===============================================================================
use `"${analysisdir}/full_bond.dta"', clear
keep ISSUE_ID ISSUER_CUSIP hist_amt_out CURRENCY DROP gvkey datadate yyyymm
gen face_value = hist_amt_out * 1000

* merge filtered market values
merge 1:1 ISSUE_ID yyyymm using `"${bonddir}/bond_value_f.dta"', keepusing(value_f_latest value_f_largest value_f_avg value_f_avg_w)
rename _merge mergewith_MV_f
label define mergewith_MV 1 "Only face value" 2 "Only market value" 3 "Both", replace
label values mergewith_MV_f mergewith_MV
* merge unfiltered market values
merge 1:1 ISSUE_ID yyyymm using `"${bonddir}/bond_value.dta"', keepusing(value_latest value_largest value_avg value_avg_w)
rename _merge mergewith_MV
label values mergewith_MV mergewith_MV

save 

*************************
* RE DO! from here below*
*************************
* do the range merge: for each month from datadate_lag to datadate, find all bond value information
*** filtered value
rangejoin trd_exctn_dt datadate_lag datadate using `"${bonddir}/bond_value_f.dta"', by(ISSUER_CUSIP) keepusing(ISSUE_ID CONVERTIBLE COUPON PRINCIPAL_AMT OFFERING_AMT MATURITY quant_total price_* yield_* value_* *_abn)
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

preserve
* for each bond, in each month, keep the value information of the largest transaction
sort gvkey ISSUE_ID datadate quant_total
by gvkey ISSUE_ID datadate: keep if _n==_N
* 383311 gvkey-by-datadate-by-ISSUE_ID 
sort gvkey datadate ISSUE_ID
drop trd_exctn_dt
save `"${bonddir}/bondv_f_mth_largest.dta"', replace
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
rangejoin trd_exctn_dt datadate_lag datadate using `"${bonddir}/bond_value.dta"', by(ISSUER_CUSIP) keepusing(ISSUE_ID CONVERTIBLE COUPON PRINCIPAL_AMT OFFERING_AMT MATURITY quant_total price_* yield_* value_*)
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

preserve
* for each bond, in each month, keep the latest value information
sort gvkey ISSUE_ID datadate quant_total
by gvkey ISSUE_ID datadate: keep if _n==_N
* 414570 gvkey-by-datadate-by-ISSUE_ID 
sort gvkey datadate ISSUE_ID
drop trd_exctn_dt
save `"${bonddir}/bondv_mth_largest.dta"', replace
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

*===============================================================================
* Merge them back to firm information
*===============================================================================
use `"${analysisdir}/full_data.dta"', clear
drop if datadate < 15522
* 560958 gvkey-by-datadate observations left
merge 1:m gvkey datadate using `"${bonddir}/bondv_f_mth_latest.dta"'
keep if _merge==3
drop _merge

* generate 
gen dlcq_perc = dlcq/lctq
label variable dlcq_perc "Debt in Current Liabilities in %"

gen dlttq_perc = dlttq/lltq
label variable dlttq_perc "Debt in Long-term Liabilities in %"

gen lctq_perc = lctq/ltq
label variable lctq_perc "Current Liabilities in Total in %"

gen lltq_perc = lltq/ltq
label variable lltq_perc "Long-Term Liabilities in Total in %"

gen ltq_perc = ltq/lseq
label variable ltq_perc "Liabilities in Asset in %"

