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

* add the offering amount as the first historical amount +++++++++++++++++++++++
**** NOTE: if there are any historical data on the offering date, then don't add the offering amount
preserve
tempfile offering_amount
duplicates drop ISSUE_ID, force
replace hist_amt_out = OFFERING_AMT
replace hist_effective_dt = OFFERING_DATE
replace hist_effective_dt = DELIVERY_DATE if mi(hist_effective_dt) & !mi(DELIVERY_DATE)
drop current
* generate a tag for these information
gen offering = 1
save `offering_amount', replace

restore
append using `offering_amount'

* add the maturity date and 0 as the maturity information ++++++++++++++++++++++
preserve
tempfile maturity
drop if MATURITY == hist_effective_dt
duplicates drop ISSUE_ID, force
replace hist_amt_out = 0
replace hist_effective_dt = MATURITY
drop _merge latest first
* generate a tage for maturity
gen maturity = 1
save `maturity', replace

restore
append using `maturity'

* generate a tag +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
gen dt_type = .
replace dt_type = 1 if first == 1
replace dt_type = 2 if latest == 0
replace dt_type = 3 if latest == 1
replace dt_type = 4 if maturity == 1

label define date_type_l 1 "Offering date" 2 "Historical date" 3 "Latest date" 4 "Maturity date"
label values dt_type date_type_l

* drop the intermediary columns
drop _merge latest first maturity

* tag the duplicated date information
duplicates tag ISSUE_ID hist_effective_dt, gen(date_dup)
sort ISSUER_ID ISSUE_ID dt_type hist_effective_dt

* use the following codes to keep the 


save mergent_amtinfo, replace

*===============================================================================
* cleaning TRACE data
*===============================================================================
clear

* Clean TRACE data
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*++++ link to data: 
*++++ TRACE enhanced (https://wrds-web.wharton.upenn.edu/wrds//ds/trace/trace_enhanced/index.cfm)
*++++ TRACE - Bond Trades (BTDS) (https://wrds-web.wharton.upenn.edu/wrds//ds/trace/trade/index.cfm)
*++++
*++++ TRACE enhanced covers more detailed bond information, from Jul 1st, 2002 to Mar 31st, 2020
*++++ TRACE-Bond Trades (BTDS) covers longer time series
*++++ 
*++++ The final data set is:
*++++          - TRACE enhanced: Jul/1/2002 to Mar/31/2020
*++++          - TRACE-Bond Trades (BTDS): Apr/1/2020 to Sep/30/2020
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Notes: 
*++++ The purpose of TRACE data is to price the bond value with the nearest large trasaction,
*++++ to achieve this, the merge is done as:
*++++    - for each firm, when the portfolio is adjusted (annually/quarterly)
*++++    - select all bonds that still have positive amount outstanding from FISD mergent
*++++    - for these bonds, select the information of the large transaction as the pricing information of the bond
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

cd "F:/Stephen/TRACE"

