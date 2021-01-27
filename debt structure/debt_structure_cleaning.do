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
keep gvkey compustat_dt yyyymm at lseq BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM

* merge with debt data
merge m:1 gvkey compustat_dt using "F:/Stephen/separate/raw/compustat_debt.dta"
drop if _merge==2
drop _merge

* keep variables of interest
replace ltq = ltmibq if mi(ltq)
drop ltmibq

global debt_info = "apq dd1q dlcq dlttq lctq lltq ltq npq txdbclq xintq dltisy dltry intpny"
global other_info = "gvkey compustat_dt yyyymm DecDate at lseq BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM"
keep $debt_info $other_info

* generate percentage
gen dlcq_perc = dlcq/lctq
label variable dlcq_perc "Debt in Current Liabilities in %"

gen dlttq_perc = dlttq/lltq
label variable dlttq_perc "Debt in Long-term Liabilities in %"

gen lctq_perc = lctq/ltq
label variable lctq_perc "Current Liabilities in Total in %"

gen lltq_perc = lltq/ltq
label variable lltq_perc "Long-Term Liabilities in Total in %"

gen ltq_perc = ltq/lseq
label variable ltq_perc "Liabilities in Asset in %"

* save to another file for further analysis
save "F:/Stephen/analysis/debt structure/debt_btm.dta", replace

*===============================================================================
* graphic analysis: a quarterly graphic analysis
*===============================================================================
* keep the firms in highest BtM portfolios and firms in the lowest BtM portfolios, sorted by December BtM
keep if QUINTILEdec_BtM==1 | QUINTILEdec_BtM==5

* since the portfolios are updated annually, the analysis would be done quarterly
duplicates drop gvkey compustat_dt, force

* Mean of firms in highest BtM portfolios versus lowest BtM portfolios
preserve

* generate variables for figures
foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    bys compustat_dt QUINTILEdec_BtM: egen `var'_mean = mean(`var')
    bys compustat_dt QUINTILEdec_BtM: egen `var'_se = sd(`var')
    gen `var'_l = `var'_mean - 1.96*`var'_se
    gen `var'_r = `var'_mean + 1.96*`var'_se
}
bys compustat_dt QUINTILEdec_BtM: egen n_obs = count(gvkey)

* keep a date by portfolio data set for figures
duplicates drop compustat_dt QUINTILEdec_BtM, force
keep compustat_dt QUINTILEdec_BtM n_obs *_mean *_l *_r

* draw graphs
twoway line apq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(apq_mean), lw(thin) lc(navy) || 
line apq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(apq_mean)

twoway rspike ltq_perc_l ltq_perc_r compustat_dt if QUINTILEdec_BtM==1, lwidth(thin) lcolor(navy) || ///
scatter ltq_perc_mean compustat_dt if QUINTILEdec_BtM==1, mcolor(navy) msymbol(circle) msize(small) || ///
rspike ltq_perc_l ltq_perc_r compustat_dt if QUINTILEdec_BtM==5, lwidth(thin) lcolor(dkorange) || ///
scatter ltq_perc_mean compustat_dt if QUINTILEdec_BtM==1, mcolor(dkorange) msymbol(circle) msize(small) ///
xlabel(1 "-6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "5" 13 "6") ///
xtitle("14-day periods before and after appeal court decision") ytitle("Period fixed effect") ///
title("Aggregate Lower Court Grant Rate (by Judge)", size(medlarge)) yline(0, lcolor(black)) xline(7, lcolor(black)) ///
legend(order(2 "Reversed cases" 4 "Affirmed cases")) note("(With appeal decision year fixed effect)")
