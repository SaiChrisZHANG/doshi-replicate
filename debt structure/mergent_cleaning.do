* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer
* This script merge and generate the 

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

clear
cd "F:/Stephen/mergent"

*===============================================================================
* Merge the two data sets
*===============================================================================

* mergent_hist_amt =============================================================
*+++++++++++++++++++++++++++++++++++++++++++++++
* Note:
* There could be multiple transactions happened on the same day for one issue, 
* TRANSACTION_ID marks the order of them, namely, transactions with a bigger
* TRANSACTION_ID happens later
*+++++++++++++++++++++++++++++++++++++++++++++++

* import SAS format data, downloaded from WRDS
import sas TRANSACTION_ID ISSUE_ID EFFECTIVE_DATE AMOUNT_OUTSTANDING using "mergent_hist_amt.sas7bdat"

* keep the final amount for each issue on each effective date
sort ISSUE_ID EFFECTIVE_DATE TRANSACTION_ID
by ISSUE_ID EFFECTIVE_DATE: keep if _n == _N
* 10733 obs dropped

rename AMOUNT_OUTSTANDING hist_amt_out
rename EFFECTIVE_DATE hist_effective_dt
save mergent_hist_amt.dta, replace

* mergent_issue ================================================================
use mergent_issue, clear
keep ISSUE_ID ISSUER_ID ISSUER_CUSIP COMPLETE_CUSIP MATURITY CONVERTIBLE OFFERING_AMT OFFERING_DATE OFFERING_PRICE OFFERING_YIELD DELIVERY_DATE ACTIVE_ISSUE BOND_TYPE EFFECTIVE_DATE AMOUNT_OUTSTANDING

duplicates report ISSUE_ID
duplicates report COMPLETE_CUSIP
* should be uniquely defined

* do the merge
merge 1:m ISSUE_ID using mergent_hist_amt, keepusing(hist_effective_dt hist_amt_out)
format hist_effective_dt %td

* append the EFFECTIVE_DATE and AMOUNT_OUTSTANDING information of the mergent_issue data set
* to the historical oustanding amount columns
preserve
tempfile recent_amt_out

keep if _merge==3
duplicates drop ISSUE_ID, force
replace hist_amt_out = AMOUNT_OUTSTANDING
replace hist_effective_dt = EFFECTIVE_DATE
* generate a tag for these information
gen latest = 1

save `recent_amt_out', replace
restore

append using `recent_amt_out'
replace latest = 0 if latest==. & _merge==3

duplicates tag ISSUE_ID hist_effective_dt, gen(dup)
drop if dup==1 & latest==0
drop dup

replace hist_effective_dt = EFFECTIVE_DATE if _merge==1
replace hist_amt_out = AMOUNT_OUTSTANDING if _merge==1
replace latest = 0 if latest==. & _merge==1

rename _merge source
label define data_source 1 "mergent_issue" 3 "mergent_hist_amt"
label values source data_source
