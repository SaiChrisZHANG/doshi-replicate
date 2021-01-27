* Check the debt structure of high versus low BTM
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* This script examine the debt structure of high/low BTM firms (constructed in data_formatting.do)

*===============================================================================
* Define data folders
*===============================================================================
global inputdir F:/Stephen/separate/raw
global outputdir F:/Stephen/analysis
* define folder to store graphs
global figdir ${outputdir}/debt structure/debt descriptive

*===============================================================================
* Process debt information
*===============================================================================
use "${inputdir}/compustat_debt.dta", clear

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
use "${outputdir}/full_data.dta", clear
keep gvkey compustat_dt yyyymm at lseq BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM

* merge with debt data
merge m:1 gvkey compustat_dt using "${inputdir}/compustat_debt.dta"
drop if _merge==2
drop _merge

* keep variables of interest
replace ltq = ltmibq if mi(ltq)
drop ltmibq

global debt_info = "apq dd1q dlcq dlttq lctq lltq ltq xintq"
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
save "${outputdir}/debt structure/debt_btm.dta", replace

*===============================================================================
* graphic analysis: a quarterly graphic analysis
*===============================================================================
* since the portfolios are updated annually, the analysis would be done quarterly
duplicates drop gvkey compustat_dt, force

* BtM 5 versus BtM 1 ===========================================================
* Mean of firms in highest BtM portfolios versus lowest BtM portfolios
preserve
keep if QUINTILEdec_BtM==1 | QUINTILEdec_BtM==5

* generate variables for figures
foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    bys compustat_dt QUINTILEdec_BtM: egen `var'_mean = mean(`var')
    bys compustat_dt QUINTILEdec_BtM: egen `var'_med = median(`var')
    *bys compustat_dt QUINTILEdec_BtM: egen `var'_se = sd(`var')
    *gen `var'_l = `var'_mean - 1.96*`var'_se
    *gen `var'_r = `var'_mean + 1.96*`var'_se
}
bys compustat_dt QUINTILEdec_BtM: egen n_obs = count(gvkey)

* keep a date by portfolio data set for figures
duplicates drop compustat_dt QUINTILEdec_BtM, force
keep compustat_dt QUINTILEdec_BtM n_obs *_mean *_med

* draw graphs: mean
twoway line apq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(apq_mean), lw(thin) lc(navy) || line apq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(apq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/apq_1.gph", replace)
twoway line dd1q_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dd1q_mean), lw(thin) lc(navy) || line dd1q_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dd1q_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt due in 1 Year (quarterly, in M$)", size(medsmall)) title("Long-term Debt Due in 1 Year: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dd1q_1.gph", replace)
twoway line dlcq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_mean), lw(thin) lc(navy) || line dlcq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlcq_1.gph", replace)
twoway line dlttq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_mean), lw(thin) lc(navy) || line dlttq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlttq_1.gph", replace)
twoway line lctq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_mean), lw(thin) lc(navy) || line lctq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lctq_1.gph", replace)
twoway line lltq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_mean), lw(thin) lc(navy) || line lltq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lltq_1.gph", replace)
twoway line ltq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_mean), lw(thin) lc(navy) || line ltq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/ltq_1.gph", replace)
twoway line xintq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(xintq_mean), lw(thin) lc(navy) || line xintq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(xintq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/xintq_1.gph", replace)
twoway line lseq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lseq_mean), lw(thin) lc(navy) || line lseq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lseq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lseq_1.gph", replace)
twoway line dlcq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_perc_mean), lw(thin) lc(navy) || line dlcq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlcq_perc_1.gph", replace)
twoway line dlttq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_perc_mean), lw(thin) lc(navy) || line dlttq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlttq_perc_1.gph", replace)
twoway line lctq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_perc_mean), lw(thin) lc(navy) || line lctq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lctq_perc_1.gph", replace)
twoway line lltq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_perc_mean), lw(thin) lc(navy) || line lltq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lltq_perc_1.gph", replace)
twoway line ltq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_perc_mean), lw(thin) lc(navy) || line ltq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Average",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/ltq_perc_1.gph", replace)

* draw graphs: median
twoway line apq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(apq_med), lw(thin) lc(navy) || line apq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(apq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/apq_2.gph", replace)
twoway line dd1q_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dd1q_med), lw(thin) lc(navy) || line dd1q_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dd1q_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt due in 1 Year (quarterly, in M$)", size(medsmall)) title("Long-term Debt Due in 1 Year: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dd1q_2.gph", replace)
twoway line dlcq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_med), lw(thin) lc(navy) || line dlcq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlcq_2.gph", replace)
twoway line dlttq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_med), lw(thin) lc(navy) || line dlttq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlttq_2.gph", replace)
twoway line lctq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_med), lw(thin) lc(navy) || line lctq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lctq_2.gph", replace)
twoway line lltq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_med), lw(thin) lc(navy) || line lltq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lltq_2.gph", replace)
twoway line ltq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_med), lw(thin) lc(navy) || line ltq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/ltq_1.gph", replace)
twoway line xintq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(xintq_med), lw(thin) lc(navy) || line xintq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(xintq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/xintq_2.gph", replace)
twoway line lseq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lseq_med), lw(thin) lc(navy) || line lseq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lseq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lseq_2.gph", replace)
twoway line dlcq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_perc_med), lw(thin) lc(navy) || line dlcq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlcq_perc_2.gph", replace)
twoway line dlttq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_perc_med), lw(thin) lc(navy) || line dlttq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/dlttq_perc_2.gph", replace)
twoway line lctq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_perc_med), lw(thin) lc(navy) || line lctq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lctq_perc_2.gph", replace)
twoway line lltq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_perc_med), lw(thin) lc(navy) || line lltq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/lltq_perc_2.gph", replace)
twoway line ltq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_perc_med), lw(thin) lc(navy) || line ltq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Median",size(medlarge)) legend(order(1 "Lowest BtM portfolio" 2 "Highest BtM portfolio")) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/ltq_perc_2.gph", replace)

restore


* generate a "smoother" version of BtM portfolios
gen BtM_big=1 if QUINTILEdec_BtM==4 | QUINTILEdec_BtM==5
replace BtM_big=0 if QUINTILEdec_BtM==1 | QUINTILEdec_BtM==2
