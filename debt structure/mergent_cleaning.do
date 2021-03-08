* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer
* This script merge and generate the bond amount outstanding information

*===============================================================================
* Merge the two data sets
*===============================================================================
clear

* Clean two Mergent FISD data sets: Mergent Issues and Mergent 
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*++++ link to data: 
*++++ Mergent issues (https://wrds-web.wharton.upenn.edu/wrds/ds/fisd/mergedissue/index_maturity.cfm?navId=274)
*++++ Mergent historical amount oustanding:
*++++          this data is retrieved from WRDS SAS studio using the following SAS codes:
*++++              PROC SQL;
*++++              CREATE TABLE WORK.query AS
*++++              SELECT TRANSACTION_ID , ISSUE_ID , ACTION_TYPE , EFFECTIVE_DATE , ACTION_PRICE , ACTION_AMOUNT , AMOUNT_OUTSTANDING FROM _TEMP0.fisd_amt_out_hist;
*++++              RUN;
*++++              QUIT;

*++++              PROC DATASETS NOLIST NODETAILS;
*++++              CONTENTS DATA=WORK.query OUT=WORK.details;
*++++              RUN;

*++++              PROC PRINT DATA=WORK.details;
*++++              RUN;
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Notes: 
*    - mergent_issue is uniquely defined by ISSUE_ID (also by 9-digit COMPLETE_CUSIP)
*    - mergent_hist_amt is uniquely defined by ISSUE_IDxTRANSACTION_ID
* The merge will between these two data set will be through ISSUE_ID
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

cd "F:/Stephen/mergent"

* mergent_hist_amt =============================================================
*+++++++++++++++++++++++++++++++++++++++++++++++
* Note:
* There could be multiple transactions happened on the same day for one issue, 
* TRANSACTION_ID marks the order of them, namely, transactions with a bigger
* TRANSACTION_ID happens later
*+++++++++++++++++++++++++++++++++++++++++++++++

* import SAS format data, downloaded from WRDS
import sas using "mergent_hist_amt.sas7bdat"

* keep the final amount for each issue on each effective date
sort ISSUE_ID EFFECTIVE_DATE TRANSACTION_ID
by ISSUE_ID EFFECTIVE_DATE: keep if _n == _N
* 10733 obs dropped

rename AMOUNT_OUTSTANDING hist_amt_out
rename EFFECTIVE_DATE hist_effective_dt
rename ACTION_TYPE hist_act_type
rename ACTION_PRICE hist_act_price
rename ACTION_AMOUNT hist_act_amt

save mergent_hist_amt.dta, replace

* mergent_issue ================================================================
*+++++++++++++++++++++++++++++++++++++++++++++++
* Note:
* The final product should, for each bond, contain:
*     - all historical data, both date and amount outstanding
*     - offering data, both date and amount offering
*     - maturity, when the amount would be zero
* notice that if there are duplicated data on the same day, always keep the later one
*+++++++++++++++++++++++++++++++++++++++++++++++

* action price information
import sas ISSUE_ID ACTION_TYPE ACTION_PRICE ACTION_AMOUNT using "fisd_amount_outstanding.sas7bdat"
tempfile action_price
save `action_price', replace

use mergent_issue, clear
keep ISSUE_ID ISSUER_ID ISSUER_CUSIP COMPLETE_CUSIP MATURITY CONVERTIBLE OFFERING_AMT OFFERING_DATE OFFERING_PRICE OFFERING_YIELD DELIVERY_DATE ACTIVE_ISSUE BOND_TYPE EFFECTIVE_DATE AMOUNT_OUTSTANDING
merge 1:1 ISSUE_ID using `action_price', nogen

duplicates report ISSUE_ID
duplicates report COMPLETE_CUSIP
* should be uniquely defined

* do the merge
merge 1:m ISSUE_ID using mergent_hist_amt, keepusing(hist_effective_dt hist_amt_out hist_act_type hist_act_price hist_act_amt)
format hist_effective_dt %td

* add the latest amount outstanding as the last historical amount ++++++++++++++
**** NOTE: append the EFFECTIVE_DATE and AMOUNT_OUTSTANDING information of the mergent_issue data set to the historical oustanding amount columns
****       if there are any duplicates (for 1656 bonds, the date of the latest historical data is the same with the date of the current data), only keep the current data
preserve
tempfile recent_amt_out
keep if _merge==3
duplicates drop ISSUE_ID, force
replace hist_amt_out = AMOUNT_OUTSTANDING
replace hist_effective_dt = EFFECTIVE_DATE
replace hist_act_type = ACTION_TYPE
replace hist_act_price = ACTION_PRICE
replace hist_act_amt = ACTION_AMOUNT
* generate a tag for these information
gen current = 1
save `recent_amt_out', replace

restore
append using `recent_amt_out'
replace current = 0 if current ==. & _merge==3

* the issues that doesn't have historical data in hist_amt_out
replace hist_effective_dt = EFFECTIVE_DATE if _merge==1
replace hist_amt_out = AMOUNT_OUTSTANDING if _merge==1
replace current = 1 if current ==. & _merge==1
drop _merge

* drop the bonds whose latest historical data (in mergent_hist_amt.dta) are on the same day with the current data (mergent_issue)
sort ISSUE_ID hist_effective_dt current
by ISSUE_ID hist_effective_dt: keep if _n == _N

drop if mi(hist_effective_dt)

* add the offering amount as the first historical amount +++++++++++++++++++++++
**** NOTE: if there are any historical data on the offering date, then don't add the offering amount
preserve
* keep the earliest
sort ISSUE_ID hist_effective_dt
by ISSUE_ID: keep if _n == 1
keep if OFFERING_DATE != hist_effective_dt
drop if OFFERING_DATE == .

* generate a tag for bonds that (weirdly) have a maturity later than the first effective date 
gen offering = .
replace offering = 1 if OFFERING_DATE > hist_effective_dt

replace hist_amt_out = OFFERING_AMT
replace hist_effective_dt = OFFERING_DATE
drop current

tempfile offering_amount
save `offering_amount', replace
restore
append using `offering_amount'

* add the maturity date and 0 as the maturity information ++++++++++++++++++++++
preserve
sort ISSUE_ID hist_effective_dt
by ISSUE_ID: keep if _n==_N

drop if MATURITY == hist_effective_dt
drop if mi(MATURITY)
gen maturity = .
replace maturity = 1 if MATURITY < hist_effective_dt

replace hist_amt_out = 0
replace hist_effective_dt = MATURITY

* generate a tag for maturity
tempfile maturity
drop current offering
save `maturity', replace

restore
append using `maturity'

* generate a tag +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
gen dt_type = .
replace dt_type = 1 if offering == 1
replace dt_type = 2 if current == 1
replace dt_type = 3 if maturity == 1

label define date_type_l 1 "LATE offering date" 2 "last documented update" 3 "EARLY maturity date"
label values dt_type date_type_l

* drop the intermediary columns
drop current offering maturity

* save the final ouput
save mergent_amtinfo, replace

* generate an intermediary data set to merge with TRACE
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*++++ Note: to save running time, drop all bonds with maturity before July 1, 2002
*++++       since TRACE only has data after that.
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* keep identifier
keep ISSUE_ID ISSUER_ID COMPLETE_CUSIP MATURITY hist_effective_dt hist_amt_out dt_type

* generate a new variable for merge: the date of last effetive date or 365 days before the curretn effective date
sort ISSUE_ID hist_effective_dt
by ISSUE_ID: gen lead_effective_dt = hist_effective_dt[_n+1]
replace lead_effective_dt = lead_effective_dt-1 if !mi(lead_effective_dt)
format %td lead_effective_dt
* replace lead_effective_dt if it's more than 730 days before the current effective date
replace lead_effective_dt = MATURITY if mi(lead_effective_dt) & MATUIRTY > hist_effective_dt

* drop information before July 1, 2002
drop if lead_effective_dt < 15522
* clean for merge
rename COMPLETE_CUSIP cusip_id

save mergent_issue_dt, replace

*===============================================================================
* merge with TRACE data
*===============================================================================
* TRACE data description
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*++++ link to data: 
*++++ TRACE enhanced (https://wrds-web.wharton.upenn.edu/wrds//ds/trace/trace_enhanced/index.cfm)
*++++ TRACE - Bond Trades (BTDS) (https://wrds-web.wharton.upenn.edu/wrds//ds/trace/trade/index.cfm)
*++++
*++++ TRACE enhanced covers more detailed bond information, from Jul 1st, 2002 to Mar 31st, 2020
*++++ TRACE-Bond Trades (BTDS) covers longer time series
*++++ 
*++++ The final data set is:
*++++          - TRACE enhanced: Jul/1/2002 to Jun/30/2020
*++++          - TRACE-Bond Trades (BTDS): Jul/1/2020 to Sep/30/2020
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Notes: 
*++++ The purpose of TRACE data is to price the bond value with the nearest large trasaction,
*++++ to achieve this, the merge is done as:
*++++    - for each firm, when the portfolio is adjusted (annually/quarterly)
*++++    - select all bonds that still have positive amount outstanding from FISD mergent
*++++    - for these bonds, select the information of the large transaction as the pricing information of the bond
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Merging strategy:
*++++ for each row in mergent_issue_dt.dta (an update of historical amount outstanding)
*++++ merge all data in TRACE for that bond, from the last one to that update 
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

* The merge will use one ssc commands "rangejoin", this command requires "rangestat"
ssc install rangestat
ssc install rangejoin

* first, merge with TRACE enhanced data (Jul. 2020 to Sep. 2020)
global tracedir = "F:/Stephen/TRACE"
global mergentdir = "F:/Stephen/mergent"

forvalues i = 3/20{
    local j = 2000+`i'
    display "Merging `j' data:"

    preserve
    * do the merge
    rangejoin trd_exctn_dt hist_effective_dt lead_effective_dt using `"${tracedir}/traceH_`i'.dta"', by(cusip_id) keepusing(trd_exctn_tm entrd_vol_qt rptd_pr yld_sign_cd yld_pt rpt_side_cd trc_st)

    * drop not merged
    drop if mi(trd_exctn_dt)
    
    * keep Trade report
    keep if trc_st == "T"
    drop trc_st

    * adjust yield, incorporating the negativity
    replace yld_pt = yld_pt*(-1) if yld_sign_cd =="-"
    drop yld_sign_cd

    save `"${mergentdir}/merged_with_TRACE/merged_`i'.dta"', replace
    restore
}

* then, merge with TRACE data
preserve
rangejoin trd_exctn_dt hist_effective_dt lead_effective_dt using `"${tracedir}/trace_20.dta"', by(cusip_id) keepusing(trd_exctn_tm ascii_rptd_vol_tx frmt_cd rptd_pr yld_sign_cd yld_pt side trc_st)
drop if mi(trd_exctn_dt)
* keep Trade report
keep if trc_st == "M"
drop trc_st
replace yld_pt = yld_pt*(-1) if yld_sign_cd=="-"
drop yld_sign_cd

* rename variables to match TRACE enhanced
rename side rpt_side_cd
rename ascii_rptd_vol_tx entrd_vol_qt
replace entrd_vol_qt = "1000000" if entrd_vol_qt=="1MM+"
replace entrd_vol_qt = "5000000" if entrd_vol_qt=="5MM+"
destring entrd_vol_qt, replace
save `"${mergentdir}/merged_with_TRACE/merged_20_extra.dta"', replace

* append this data set to the TRACE enhanced merged dataset
use `"${mergentdir}/merged_with_TRACE/merged_20.dta"', clear
append using `"${mergentdir}/merged_with_TRACE/merged_20_extra.dta"'
save, replace

restore
clear

*===============================================================================
* collect pricing information
*===============================================================================
*++++++++++++++++++++++++++++++++++++++
* Strategy:
*++++ Aggregate daily pricing information:
*++++    - price the latest trade
*++++    - price of the largest trade
*++++    - average/weighted average price of the last 5 trades
*++++    - average/weighted average price of the largest 5 trades
*++++    - average/weighted average price of all trades
*
*++++ All output data sets are uniquely defined by ISSUE_IDXhist_effective_dtXtrd_exctn_dt
*++++++++++++++++++++++++++++++++++++++
global mergedir = `"${mergentdir}/merged_with_TRACE"'
global pricedir = `"${mergentdir}/output"'
global varlist = "ISSUE_ID MATURITY cusip_id hist_effective_dt trd_exctn_dt entrd_vol_qt rptd_pr yld_pt"

* process 2020 data first ======================================================
use `"${mergedir}/merged_20.dta"', clear

* the latest transaction
preserve
sort ISSUE_ID hist_effective_dt trd_exctn_dt trd_exctn_tm
by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n==_N
keep $varlist
rename entrd_vol_qt quant_latest
rename rptd_pr price_latest
rename yld_pt yield_latest
save `"${pricedir}/latest.dta"', replace
restore

* the largest transaction
preserve
sort ISSUE_ID hist_effective_dt trd_exctn_dt entrd_vol_qt
by ISSUE_ID hist_effective_dt trd_exctn_dt: keep if _n==_N
keep $varlist
rename entrd_vol_qt quant_largest
rename rptd_pr price_largest
rename yld_pt yield_largest
save `"${pricedir}/largest.dta"', replace
restore


forvalues i = 3/19{
    local j = 2000+`i'
    display "Processing `j' data:"
    use `"${mergedir}/merged_`i'.dta"', clear

    * the latest/largest transaction on a given day
    sort ISSUE_ID hist_effective_dt trd_exctn_dt trd_exctn_tm
    by ISSUE_ID hist_effective_dt trd_exctn_dt: gen price_latest = rptd_pr[_N]
    by ISSUE_ID hist_effective_dt trd_exctn_dt: gen yield_latest = yld_pt[_N]
    by ISSUE_ID 
    

    sort ISSUE_ID hist_effective_dt trd_exctn_dt entrd_vol_qt
    by ISSUE_ID hist_effective_dt trd_exctn_dt: egen price_largest = rptd_pr[_N] 

    save `"${pricedir}/latest1.dta"', replace
    restore

    * the latest 5 transactions
    preserve
    append using `"${pricedir}/latest5.dta"'
    sort ISSUE_ID hist_effective_dt trd_exctn_dt
    by ISSUE_ID hist_effective_dt: keep if _n>=_N-4
    save `"${pricedir}/latest5.dta"', replace
    restore

    * the latest 10 transactions
    preserve
    append using `"${pricedir}/latest10.dta"'
    sort ISSUE_ID hist_effective_dt trd_exctn_dt
    by ISSUE_ID hist_effective_dt: keep if _n >= _N-9
    save `"${pricedir}/latest10.dta"', replace
    restore

    clear
    display "Finish!"
}

* Latest trade(s) ==============================================================
*++++++++++++++++++++++++++++++++++++++
* Strategy:
*++++ 2. pricing with highest volume trades:
*++++    - over the past 90 days 
*++++    - over the past 180 days
*++++    - over the past 365 days
*++++    Note:
*++++       - consider the shorter interval
*++++            - 30/90/180/365, OR
*++++            - the difference between two effective dates
*++++       - for each interval, calculate
*++++            - price of the largest quantity trade
*++++            - average price of the largest 5 quantity trades   
*++++++++++++++++++++++++++++++++++++++

use `"${mergedir}/merged_20_extra.dta"', clear
sort ISSUE_ID hist_effective_dt trd_exctn_dt

* daily pricing ================================================================
* average prices of daily transactions