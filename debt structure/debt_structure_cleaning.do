* Check the debt structure of high versus low BTM
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* This script examine the debt structure of high/low BTM firms (constructed in data_formatting.do)

*===============================================================================
* Process debt information
*===============================================================================
use "F:/Stephen/separate/raw/compustat_debt.dta", clear

* clean duplicates
destring gvkey, replace
rename datdate compustat_dt

duplicates tag gvkey datadate, g(dup)
drop if dup==1 & mi(datacqtr)
duplicates report gkvey datadate /*should be none*/
drop dup
save, replace

*===============================================================================
* Merge the debt data to the firms of high/low BTM
*===============================================================================
* open the formatted data:
use "F:\Stephen\analysis\full_data.dta", clear
keep gvkey compustat_dt yyyymm DecDate BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM

* merge with debt data
merge m:1 gvkey compustat_dt using "F:/Stephen/separate/raw/compustat_debt.dta"
drop if _merge==2
drop _merge

* keep variables of interest
replace ltq = ltmibq if mi(ltq)
drop ltmibq

global debt_info = "apq dd1q dlcq dlttq lctq lltq ltq npq txdbclq xintq dltisy dltry intpny xinty"
global other_info = "gvkey compustat_dt yyyymm DecDate at lseq BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM"
keep $debt_info $other_info

* generate percentage
gen dlcq_perc = dlcq/lctq
label variable dlcq_perc "Debt in Current Liabilities in %"

gen dlttq_perc = dlttq/lltq
label variable dlttq_perc "Debt in Long-term Liabilities in %"

gen lctq_perc = lctq/ ltq
label variable lctq_perc "Current Liabilities in Total in %"

gen lltq_perc = lltq/ ltq
label variable lltq_perc "Long-Term Liabilities in Total in %"

* save to another file for further analysis
save "F:/Stephen/analysis/debt structure/debt_btm.dta", replace

* keep the firms in highest BtM portfolios and firms in the lowest BtM portfolios, sorted by December BtM
keep if QUINTILEdec_BtM==1 | QUINTILEdec_BtM==5
*===============================================================================
* produce analysis: a monthly graphic analysis
*===============================================================================
* Mean of firms in highest BtM portfolios versus lowest BtM portfolios 
preserve


* merge with debt data