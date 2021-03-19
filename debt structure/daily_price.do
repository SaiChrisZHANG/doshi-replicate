* This script is called by "mergent_cleaning.do" to generate daily price information
* process 2020 data first ======================================================
use `"${mergedir}/merged_20.dta"', clear

* the latest transaction
sort ISSUE_ID hist_effective_dt trd_exctn_dt trd_exctn_tm
**** the latest one transaction
preserve
by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n==_N
keep $varlist
rename entrd_vol_qt quant_latest
rename rptd_pr price_latest
rename yld_pt yield_latest
save `"${pricedir}/latest.dta"', replace
restore
**** the latest 5 transaction
preserve
by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n>_N-5
keep $varlist
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen quant_latest5 = total(entrd_vol_qt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_latest5 = mean(rptd_pr)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_latest5 = mean(yld_pt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_latest5_w = total(rptd_pr*entrd_vol_qt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_latest5_w = total(yld_pt*entrd_vol_qt)
duplicates drop ISSUE_ID hist_effective_dt trd_exctn_dt, force
replace price_latest5_w = price_latest5_w/quant_latest5
replace yield_latest5_w = yield_latest5_w/quant_latest5
drop entrd_vol_qt rptd_pr yld_pt
save `"${pricedir}/latest5.dta"', replace
restore

* the largest transaction
sort ISSUE_ID hist_effective_dt trd_exctn_dt entrd_vol_qt
**** the largest transaction
preserve
by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n==_N
keep $varlist
rename entrd_vol_qt quant_largest
rename rptd_pr price_largest
rename yld_pt yield_largest
save `"${pricedir}/largest.dta"', replace
restore
**** the largest 5 transaction
preserve
by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n>_N-5
keep $varlist
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen quant_largest5 = total(entrd_vol_qt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_largest5 = mean(rptd_pr)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_largest5 = mean(yld_pt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_largest5_w = total(rptd_pr*entrd_vol_qt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_largest5_w = total(yld_pt*entrd_vol_qt)
duplicates drop ISSUE_ID hist_effective_dt trd_exctn_dt, force
replace price_largest5_w = price_largest5_w/quant_largest5
replace yield_largest5_w = yield_largest5_w/quant_largest5
drop entrd_vol_qt rptd_pr yld_pt
save `"${pricedir}/largest5.dta"', replace
restore

* all transactions
keep $varlist
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen quant_avg = total(entrd_vol_qt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_avg = mean(rptd_pr)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_avg = mean(yld_pt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_avg_w = total(rptd_pr*entrd_vol_qt)
by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_avg_w = total(yld_pt*entrd_vol_qt)
duplicates drop ISSUE_ID hist_effective_dt trd_exctn_dt, force
replace price_avg_w = price_avg_w/quant_avg
replace yield_avg_w = yield_avg_w/quant_avg
drop entrd_vol_qt rptd_pr yld_pt
save `"${pricedir}/average.dta"', replace
clear

* process 2003-2019 data =======================================================
forvalues i = 3/19{
    local j = 2000+`i'
    display "Processing `j' data:"
    use `"${mergedir}/merged_`i'.dta"', clear

    qui{
        * the latest transaction
        sort ISSUE_ID hist_effective_dt trd_exctn_dt trd_exctn_tm
        **** the latest one transaction
        preserve
        by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n==_N
        keep $varlist
        rename entrd_vol_qt quant_latest
        rename rptd_pr price_latest
        rename yld_pt yield_latest
        append using `"${pricedir}/latest.dta"'
        save `"${pricedir}/latest.dta"', replace
        restore
        **** the latest 5 transaction
        preserve
        by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n>_N-5
        keep $varlist
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen quant_latest5 = total(entrd_vol_qt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_latest5 = mean(rptd_pr)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_latest5 = mean(yld_pt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_latest5_w = total(rptd_pr*entrd_vol_qt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_latest5_w = total(yld_pt*entrd_vol_qt)
        duplicates drop ISSUE_ID hist_effective_dt trd_exctn_dt, force
        replace price_latest5_w = price_latest5_w/quant_latest5
        replace yield_latest5_w = yield_latest5_w/quant_latest5
        drop entrd_vol_qt rptd_pr yld_pt
        append using `"${pricedir}/latest5.dta"'
        save `"${pricedir}/latest5.dta"', replace
        restore

        * the largest transaction
        sort ISSUE_ID hist_effective_dt trd_exctn_dt entrd_vol_qt
        **** the largest transaction
        preserve
        by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n==_N
        keep $varlist
        rename entrd_vol_qt quant_largest
        rename rptd_pr price_largest
        rename yld_pt yield_largest
        append using `"${pricedir}/largest.dta"'
        save `"${pricedir}/largest.dta"', replace
        restore
        **** the largest 5 transaction
        preserve
        by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n>_N-5
        keep $varlist
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen quant_largest5 = total(entrd_vol_qt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_largest5 = mean(rptd_pr)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_largest5 = mean(yld_pt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_largest5_w = total(rptd_pr*entrd_vol_qt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_largest5_w = total(yld_pt*entrd_vol_qt)
        duplicates drop ISSUE_ID hist_effective_dt trd_exctn_dt, force
        replace price_largest5_w = price_largest5_w/quant_largest5
        replace yield_largest5_w = yield_largest5_w/quant_largest5
        drop entrd_vol_qt rptd_pr yld_pt
        append using `"${pricedir}/largest5.dta"'
        save `"${pricedir}/largest5.dta"', replace
        restore

        * all transactions
        keep $varlist
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen quant_avg = total(entrd_vol_qt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_avg = mean(rptd_pr)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_avg = mean(yld_pt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_avg_w = total(rptd_pr*entrd_vol_qt)
        by ISSUE_ID hist_effective_dt trd_exctn_dt: egen yield_avg_w = total(yld_pt*entrd_vol_qt)
        duplicates drop ISSUE_ID hist_effective_dt trd_exctn_dt, force
        replace price_avg_w = price_avg_w/quant_avg
        replace yield_avg_w = yield_avg_w/quant_avg
        drop entrd_vol_qt rptd_pr yld_pt
        append using `"${pricedir}/average.dta"'
        save `"${pricedir}/average.dta"', replace
    }

    clear
    display "Finish!"
}
