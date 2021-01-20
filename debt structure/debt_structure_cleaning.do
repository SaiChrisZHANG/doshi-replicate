* Check the debt structure of high versus low BTM
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* This script examine the debt structure of high/low BTM firms (constructed in data_formatting.do)
*===============================================================================
* Merge the debt data to the firms of high/low BTM
*===============================================================================

* open the formatted data:
use "F:\Stephen\analysis\full_data.dta", clear
keep gvkey compustat_dt yyyymm DecDate BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM
* save to another file for further analysis
save "F:/Stephen/analysis/debt structure/debt_btm.dta", replace

* keep the firms in highest BtM portfolios and firms in the lowest BtM portfolios
keep if QUINTILEdec_BtM==1 