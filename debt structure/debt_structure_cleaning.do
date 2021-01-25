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

* keep the firms in highest BtM portfolios and firms in the lowest BtM portfolios
keep if QUINTILEdec_BtM==1 | QUINTILEdec_BtM==5

* merge with debt data
merge m:1 gvkey datadate using "F:/Stephen/separate/raw/compustat_debt.dta"
drop if _merge==2
drop _merge

* keep variables of interest
global debt_info = "apq dd1q dlcq dlttq lcoq lctq lltq loq ltmibq ltq txdbclq xintq dltisy dltry intpny xinty"
global indicator = "gvkey compustat_dt yyyymm DecDate BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM"
keep $debt_info $indicator

* save to another file for further analysis
save "F:/Stephen/analysis/debt structure/debt_btm.dta", replace


* merge with debt data
