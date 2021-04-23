* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer
* This script merge price information of bonds, historical amount 
* outstanding information and bond issuer firm information in Compustat.

global mergedir = `"${mergentdir}/merged_with_TRACE"'
global pricedir = `"${mergentdir}/output"'
global fpricedir = `"${mergentdir}/output/filtered version"'

*===============================================================================
* Merge
*===============================================================================
*++++++++++++++++++++++++++++++++++++++
* Merging strategy:
*
*
*
*++++++++++++++++++++++++++++++++++++++