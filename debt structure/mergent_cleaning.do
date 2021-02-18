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

* mergent_hist_amt
*+++++++++++++++++++++++++++++++++++++++++++++++
* Note:
* There could be multiple transactions happened on the same day for one issue, 
* TRANSACTION_ID marks the order of them, namely, transactions with a bigger
* TRANSACTION_ID happens later
*+++++++++++++++++++++++++++++++++++++++++++++++

import sas TRANSACTION_ID ISSUE_ID EFFECTIVE_DATE AMOUNT_OUTSTANDING using "mergent_hist_amt.sas7bdat"

* keep the final amount for each issue on each effective date
sort ISSUE_ID EFFECTIVE_DATE TRANSACTION_ID
by ISSUE_ID EFFECTIVE_DATE: keep if _n == _N
* 10733 obs dropped

use mergent_issue, clear

duplicates report ISSUE_ID
duplicates report COMPLETE_CUSIP
* should be uniquely defined

merge 1:m ISSUE