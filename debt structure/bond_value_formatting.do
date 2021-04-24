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
*++++ 1. merge the price information, keep the latest
*++++ 2. merge the price information, keep the largest
*++++++++++++++++++++++++++++++++++++++

* filtered version: prices of bigger transactions (quantity>100000)
use `"${mergentdir}/mergent_amtinfo.dta"', clear

global issue_vars1 = "ISSUE_ID ISSUER_ID ISSUER_CUSIP COMPLETE_CUSIP hist_effective_dt"
global issue_vars2 = "BOND_TYPE hist_amt_out PRINCIPAL_AMT"

preserve

merge 1:m ISSUE_ID hist_effective_dt using `"${fpricedir}/latest.dta"', keepusing(trd_exctn_dt price_latest mean_abn seq_abn)
