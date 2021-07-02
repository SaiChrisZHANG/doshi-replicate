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
keep gvkey ISSUER_CUSIP
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
joinby ISSUER_CUSIP using `idlist', unmatched(none)
* only 65845 observations kept

qui{
    gen cusipdup_tag = 0
    foreach var of local gvkey_dup{
        qui replace cusipdup_tag = 1 if (gvkey == `var')
    }
}

* do the range merge: for each month from dt_begin to dt_end, find all firm id
rangejoin datadate dt_begin dt_end using `"${analysisdir}/full_id.dta"', by(gvkey) keepusing(yyyymm)
drop if mi(datadate)
save `"${analysisdir}/full_bond.dta"', replace
* 1700432 observations. For each firm (gvkey), in each month (datadate), the information of each bond (ISSUE_ID)
* uniquely defined by ISSUE_ID by gvkey by datadate

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
joinby ISSUER_CUSIP using `idlist', unmatched(none)
* 467316 observations, uniquely defined by gvkey-yyyymm-ISSUE_ID
save `"${bonddir}/bond_value_f.dta"', replace

use `"${bonddir}/bond_value.dta"', clear
foreach pr in latest largest avg avg_w{
    gen value_`pr' = hist_amt_out*price_`pr'*10
}
gen yyyymm = year(trd_exctn_dt)*100 + month(trd_exctn_dt)
sort ISSUE_ID yyyymm trd_exctn_dt
by ISSUE_ID yyyymm: keep if _n==_N
joinby ISSUER_CUSIP using `idlist', unmatched(none)
* 518675 observations, uniquely defined by gvkey-yyyymm-ISSUE_ID
save `"${bonddir}/bond_value.dta"', replace
clear

* clean WRDS bond return data, for calibration
use `"${mergentdir}/wrds_bond_return.dta"', clear
keep DATE ISSUE_ID CUSIP CONV PRINCIPAL_AMT AMOUNT_OUTSTANDING PRICE_EOM TMT
gen ISSUER_CUSIP = substr(CUSIP,1,6)
gen yyyymm = year(DATE)*100+month(DATE)
joinby ISSUER_CUSIP using `idlist', unmatched(none)
* 434910 observations, uniquely defined by gvkey-yyyymm-ISSUE_ID
drop if mi(AMOUNT_OUTSTANDING)
* 156 observations dropped
gen value_wrds = AMOUNT_OUTSTANDING*PRICE_EOM*PRINCIPAL_AMT/100
save `"${bonddir}/bond_value_wrds.dta"', replace

*===============================================================================
* Step 3: Merge bond value (value & face value) to firm data
*===============================================================================

use `"${analysisdir}/full_bond.dta"', clear
keep ISSUE_ID ISSUER_CUSIP hist_amt_out CURRENCY DROP MATURITY CONVERTIBLE gvkey datadate yyyymm
gen value_face = hist_amt_out * 1000

* merge filtered market values
merge 1:1 gvkey ISSUE_ID yyyymm using `"${bonddir}/bond_value_f.dta"', keepusing(value_f_latest value_f_largest value_f_avg value_f_avg_w gvkey)
rename _merge mergewith_MV_f
label define mergewith_MV 1 "Only face value" 2 "Only market value" 3 "Both", replace
label values mergewith_MV_f mergewith_MV
* merge unfiltered market values
merge 1:1 gvkey ISSUE_ID yyyymm using `"${bonddir}/bond_value.dta"', keepusing(value_latest value_largest value_avg value_avg_w gvkey)
rename _merge mergewith_MV
label values mergewith_MV mergewith_MV
* merge WRDS values
merge 1:1 gvkey ISSUE_ID yyyymm using `"${bonddir}/bond_value_wrds.dta"', keepusing(value_wrds TMT)
rename _merge mergewith_WRDS
label define mergewith_WRDS 1 "No WRDS bond return data" 3 "WRDS bond return data", replace
label values mergewith_WRDS mergewith_WRDS
* merge currency information: exchange rate are retrieved from Factset
merge m:1 CURRENCY yyyymm using `"${analysisdir}/currency.dta"', keepusing(Mid)
drop if _merge==2
drop _merge

* cleaning and aggregate bonds for each firm
drop if mi(datadate)
* 104256 obs dropped 

drop if CONVERTIBLE=="Y"
* 291633 obs dropped

* drop the bond that has non-zero value information even after maturity (ISSUE_ID==103507)
gen days_to_mature = MATURITY-datadate
drop if days_to_mature<0 & value_face>0
* 55 observations deleted

* generate the maturity structure indicator
gen matured_1yrless = 1 if days_to_mature < 365 & !mi(days_to_mature)
gen matured_1to2yr = 1 if inrange(days_to_mature,365,730) & !mi(days_to_mature)
gen matured_3to5yr = 1 if inrange(days_to_mature,731,1825) & !mi(days_to_mature)
gen matured_5to10yr = 1 if inrange(days_to_mature,1826,3650) & !mi(days_to_mature)
gen matured_10yrmore = 1 if days_to_mature > 3650 & !mi(days_to_mature)

* for 707+164 observations, bonds matured in the middle of the month, impute 0s with face values
sort gvkey ISSUE_ID datadate
replace value_face = value_face[_n-1] if days_to_mature<0 & !mi(value_f_latest) & value_f_latest>0
replace value_face = value_face[_n-1] if days_to_mature<0 & !mi(value_latest) & value_latest>0 & value_face==0

* generat market bond value for each firm
foreach var in f_latest f_largest f_avg f_avg_w latest largest avg avg_w wrds{
    *replace value_`var' = value_face if mi(value_`var')
    replace value_`var' = value_`var'/Mid if !mi(Mid)
    * total bond value
    bys gvkey datadate: egen bonddebt_`var' = total(value_`var')
    replace bonddebt_`var' = bonddebt_`var'/1000000
    
    * bond value by maturity group
    foreach matvar in 1yrless 1to2yr 3to5yr 5to10yr 10yrmore{
        gen value_`var'_`matvar' = value_`var' if matured_`matvar'==1
        bys gvkey datadate: egen bonddebt_`var'_`matvar' = total(value_`var'_`matvar'),missing
        replace bonddebt_`var'_`matvar' = bonddebt_`var'_`matvar'/1000000
        drop value_`var'_`matvar'
    }
    drop value_`var'
}
* bond face value for each firm
bys gvkey datadate: egen bonddebt_facevalue = total(value_face)
replace bonddebt_facevalue = bonddebt_facevalue/1000000
foreach matvar in 1yrless 1to2yr 3to5yr 5to10yr 10yrmore{
    gen value_face_`matvar' = value_face if matured_`matvar'==1
    bys gvkey datadate: egen bonddebt_face_`matvar' = total(value_face_`matvar'),missing
    replace bonddebt_face_`matvar' = bonddebt_face_`matvar'/1000000
    drop value_face_`matvar'
}

keep gvkey datadate bonddebt_*
duplicates drop gvkey datadate, force
* 222790 unique information left
save `"${analysisdir}/bond_debt.dta"', replace

*===============================================================================
* Merge them back to firm information
*===============================================================================
use `"${analysisdir}/full_data.dta"', clear

* merge extra annual debt information
merge m:1 gvkey compustat_dt using "F:/Stephen/separate/compustat_debt_annual.dta", keepusing(cdt_mth)
drop if _merge==2
drop _merge
sort gvkey datadate
by gvkey: replace cdt_mth = cdt_mth[_n-1] if cdt_mth==.
replace cdt_mth =. if mofd(compustat_dt)-cdt_mth>=12
merge m:1 gvkey cdt_mth using "F:/Stephen/separate/compustat_debt_annual.dta", keepusing(dclo dd1 dd2 dd3 dd4 dd5 dn)
drop if _merge==2
drop _merge

merge 1:1 gvkey datadate using `"${analysisdir}/bond_debt.dta"', nogen

* long-term debt out of total liability
gen perc_dlttq_ltq_f = dlttq/ltq_f
gen perc_dlttq_ltq_f_intpl = dlttq_intpl/ltq_f_intpl
label variable perc_dlttq_ltq_f "Long-term Debt in Liabilities in %"
label variable perc_dlttq_ltq_f_intpl "Long-term Debt in Liabilities in %"

* Long-term portion of bond out of long-term debt
gen perc_bond_FV_lt = (bonddebt_facevalue-bonddebt_face_1yrless)/dlttq
gen perc_bond_FV_lt_intpl = (bonddebt_facevalue-bonddebt_face_1yrless)/dlttq_intpl
label variable perc_bond_FV_lt "Bond (long-term) in Long-term Debt in %"
label variable perc_bond_FV_lt_intpl "Bond (long-term) in Long-term Debt in %"

* current portaion of bond out of current debt
gen perc_bond_FV_cur = bonddebt_face_1yrless/dlcq
gen perc_bond_FV_cur_intpl = bonddebt_face_1yrless/dlcq_intpl
label variable perc_bond_FV_cur "Bond (current) in Current Debt in %"
label variable perc_bond_FV_cur_intpl "Bond (current) in Current Debt in %"

* bond out of total liability
gen perc_bond_FV = bonddebt_facevalue/ltq_f
gen perc_bond_FV_intpl = bonddebt_facevalue/ltq_f_intpl
label variable perc_bond_FV "Bond in Liabilities in %"
label variable perc_bond_FV_intpl "Bond in Liabilities in %"

* capitalized leases out of total liability
gen perc_dclo = dclo/ltq_f
gen perc_dclo_intpl = dclo/ltq_f_intpl
label variable perc_dclo "Capitalized leases in Liabilities in %"
label variable perc_dclo_intpl "Capitalized leases in Liabilities in %"

* bond maturity structure
foreach var in 1yrless 1to2yr 3to5yr 5to10yr 10yrmore{
    replace bonddebt_face_`var' = 0 if mi(bonddebt_face_`var') & !mi(bonddebt_facevalue)
    gen bond_ratio_`var' = bonddebt_face_`var'/bonddebt_facevalue
}

* generate BtM quintile portfolio based summary statistics
global bondvar = "perc_bond_FV_lt perc_bond_FV_lt_intpl perc_bond_FV_cur perc_bond_FV_cur_intpl perc_bond_FV perc_bond_FV_intpl bond_ratio_1yrless bond_ratio_1to2yr bond_ratio_3to5yr bond_ratio_5to10yr bond_ratio_10yrmore"
foreach var in $bondvar ME Lev Lev_intpl perc_dclo perc_dclo_intpl{
    bys datadate QUINTILEmth_BtM: egen `var'_mean = mean(`var')
    bys datadate QUINTILEmth_BtM: egen `var'_med = median(`var')
}

preserve
duplicates drop datadate QUINTILEmth_BtM, force
twoway line perc_bond_FV_lt datadate if QUINTILEmth_BtM==1 & !mi(perc_bond_FV_lt), lw(thin) lc(navy) || ///
line perc_bond_FV_lt datadate if QUINTILEmth_BtM==2 & !mi(perc_bond_FV_lt), lw(thin) lc(dkorange)|| ///
line perc_bond_FV_lt datadate if QUINTILEmth_BtM==3 & !mi(perc_bond_FV_lt), lw(thin) lc(dkorange)|| ///
line perc_bond_FV_lt datadate if QUINTILEmth_BtM==4 & !mi(perc_bond_FV_lt), lw(thin) lc(dkorange)|| ///
line perc_bond_FV_lt datadate if QUINTILEmth_BtM==5 & !mi(perc_bond_FV_lt), lw(thin) lc(dkorange)|| ///
 xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Percentage of Bonds (Maturity > 1 Year) in Long-Term Debt (Monthly)", size(medsmall)) title("Percentage of Face Value: Average",size(medlarge)) legend(order(1 "BtM Quintile: 1" 2 "BtM Quintile: 2") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/apq_1.gph", replace)
