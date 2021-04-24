* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer
* This script merge price information of bonds, historical amount 
* outstanding information and bond issuer firm information in Compustat.

global mergentdir = "F:/Stephen/mergent"
global mergedir = `"${mergentdir}/merged_with_TRACE"'
global pricedir = `"${mergentdir}/output"'
global fpricedir = `"${mergentdir}/output/filtered version"'

*===============================================================================
* Merge
*===============================================================================
*++++++++++++++++++++++++++++++++++++++
* Merging strategy:
* Step 1: merge ${mergentdir}/mergent_amtinfo.dta to price information 
*         in ${pricedir} and ${fpricedir}
* Step 2: generate the value information of bonds
* Step 3: merge the value information back to firm information

* Different spcifications will be tested:
*++++ 1. merge largest daily trade's price t
*++++++++++++++++++++++++++++++++++++++