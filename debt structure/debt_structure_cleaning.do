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


* Quarterly Study ==============================================================
*===============================================================================
*===============================================================================
* Process debt information
*===============================================================================
use "${inputdir}/compustat_debt.dta", clear

* clean duplicates
destring gvkey, replace
rename datadate compustat_dt

duplicates tag gvkey compustat_dt, g(dup)
drop if dup==1 & mi(datacqtr)
duplicates report gvkey compustat_dt /*should be none*/
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

global debt_info = "apq dlcq dlttq lctq lltq ltq xintq"
global other_info = "gvkey compustat_dt yyyymm at lseq BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM"
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
twoway line apq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(apq_mean), lw(thin) lc(navy) || line apq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(apq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/apq_1.gph", replace)
twoway line dlcq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_mean), lw(thin) lc(navy) || line dlcq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_1.gph", replace)
twoway line dlttq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_mean), lw(thin) lc(navy) || line dlttq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_1.gph", replace)
twoway line lctq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_mean), lw(thin) lc(navy) || line lctq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_1.gph", replace)
twoway line lltq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_mean), lw(thin) lc(navy) || line lltq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_1.gph", replace)
twoway line ltq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_mean), lw(thin) lc(navy) || line ltq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_1.gph", replace)
twoway line xintq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(xintq_mean), lw(thin) lc(navy) || line xintq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(xintq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/xintq_1.gph", replace)
twoway line lseq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lseq_mean), lw(thin) lc(navy) || line lseq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lseq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lseq_1.gph", replace)
twoway line dlcq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_perc_mean), lw(thin) lc(navy) || line dlcq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_perc_1.gph", replace)
twoway line dlttq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_perc_mean), lw(thin) lc(navy) || line dlttq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_perc_1.gph", replace)
twoway line lctq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_perc_mean), lw(thin) lc(navy) || line lctq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_perc_1.gph", replace)
twoway line lltq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_perc_mean), lw(thin) lc(navy) || line lltq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_perc_1.gph", replace)
twoway line ltq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_perc_mean), lw(thin) lc(navy) || line ltq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_perc_1.gph", replace)

* draw graphs: median
twoway line apq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(apq_med), lw(thin) lc(navy) || line apq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(apq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/apq_2.gph", replace)
twoway line dlcq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_med), lw(thin) lc(navy) || line dlcq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_2.gph", replace)
twoway line dlttq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_med), lw(thin) lc(navy) || line dlttq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_2.gph", replace)
twoway line lctq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_med), lw(thin) lc(navy) || line lctq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_2.gph", replace)
twoway line lltq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_med), lw(thin) lc(navy) || line lltq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_2.gph", replace)
twoway line ltq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_med), lw(thin) lc(navy) || line ltq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_2.gph", replace)
twoway line xintq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(xintq_med), lw(thin) lc(navy) || line xintq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(xintq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/xintq_2.gph", replace)
twoway line lseq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lseq_med), lw(thin) lc(navy) || line lseq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lseq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lseq_2.gph", replace)
twoway line dlcq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_perc_med), lw(thin) lc(navy) || line dlcq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_perc_2.gph", replace)
twoway line dlttq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_perc_med), lw(thin) lc(navy) || line dlttq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_perc_2.gph", replace)
twoway line lctq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_perc_med), lw(thin) lc(navy) || line lctq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_perc_2.gph", replace)
twoway line lltq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_perc_med), lw(thin) lc(navy) || line lltq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_perc_2.gph", replace)
twoway line ltq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_perc_med), lw(thin) lc(navy) || line ltq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_perc_2.gph", replace)

restore

* produce the final output: average versus median in the same figure
cd "${figdir}/1port"

gr combine apq_1.gph apq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Accounts Payable: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/apq.gph", replace)
gr combine dlcq_1.gph dlcq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Debt in Current Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlcq.gph", replace)
gr combine dlttq_1.gph dlttq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Debt: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlttq.gph", replace)
gr combine lctq_1.gph lctq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Current Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lctq.gph", replace)
gr combine lltq_1.gph lltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lltq.gph", replace)
gr combine ltq_1.gph ltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Total Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/ltq.gph", replace)
gr combine xintq_1.gph xintq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Interest and Related Expense: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/xintq.gph", replace)
gr combine lseq_1.gph lseq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Liabilities and Equity: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lseq.gph", replace)
gr combine dlcq_perc_1.gph dlcq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Current Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlcq_perc.gph", replace)
gr combine dlttq_perc_1.gph dlttq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Long-term Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlttq_perc.gph", replace)
gr combine lctq_perc_1.gph lctq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Current Liabilities in Total: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lctq_perc.gph", replace)
gr combine lltq_perc_1.gph lltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Long-term Liabilities in Total: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lltq_perc.gph", replace)
gr combine ltq_perc_1.gph ltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Liabilities in Assets: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/ltq_perc.gph", replace)

foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    gr use "${figdir}/1port/`var'.gph"
    gr export "${figdir}/1port/`var'.png", wid(1200) hei(500)
}

* BtM 5/4 versus BtM 1/2 =======================================================
* Mean of firms in 2 higher BtM portfolios versus 2 lower BtM portfolios
preserve
* generate a "smoother" version of BtM portfolios
gen BtM_big=1 if QUINTILEdec_BtM==4 | QUINTILEdec_BtM==5
replace BtM_big=0 if QUINTILEdec_BtM==1 | QUINTILEdec_BtM==2

keep if !mi(BtM_big)

* generate variables for figures
foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    bys compustat_dt BtM_big: egen `var'_mean = mean(`var')
    bys compustat_dt BtM_big: egen `var'_med = median(`var')
    *bys compustat_dt QUINTILEdec_BtM: egen `var'_se = sd(`var')
    *gen `var'_l = `var'_mean - 1.96*`var'_se
    *gen `var'_r = `var'_mean + 1.96*`var'_se
}
bys compustat_dt BtM_big: egen n_obs = count(gvkey)

* keep a date by portfolio data set for figures
duplicates drop compustat_dt BtM_big, force
keep compustat_dt BtM_big n_obs *_mean *_med

* draw graphs: mean
twoway line apq_mean compustat_dt if BtM_big==0 & !mi(apq_mean), lw(thin) lc(navy) || line apq_mean compustat_dt if BtM_big==1 & !mi(apq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/apq_1.gph", replace)
twoway line dlcq_mean compustat_dt if BtM_big==0 & !mi(dlcq_mean), lw(thin) lc(navy) || line dlcq_mean compustat_dt if BtM_big==1 & !mi(dlcq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_1.gph", replace)
twoway line dlttq_mean compustat_dt if BtM_big==0 & !mi(dlttq_mean), lw(thin) lc(navy) || line dlttq_mean compustat_dt if BtM_big==1 & !mi(dlttq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_1.gph", replace)
twoway line lctq_mean compustat_dt if BtM_big==0 & !mi(lctq_mean), lw(thin) lc(navy) || line lctq_mean compustat_dt if BtM_big==1 & !mi(lctq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_1.gph", replace)
twoway line lltq_mean compustat_dt if BtM_big==0 & !mi(lltq_mean), lw(thin) lc(navy) || line lltq_mean compustat_dt if BtM_big==1 & !mi(lltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_1.gph", replace)
twoway line ltq_mean compustat_dt if BtM_big==0 & !mi(ltq_mean), lw(thin) lc(navy) || line ltq_mean compustat_dt if BtM_big==1 & !mi(ltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_1.gph", replace)
twoway line xintq_mean compustat_dt if BtM_big==0 & !mi(xintq_mean), lw(thin) lc(navy) || line xintq_mean compustat_dt if BtM_big==1 & !mi(xintq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/xintq_1.gph", replace)
twoway line lseq_mean compustat_dt if BtM_big==0 & !mi(lseq_mean), lw(thin) lc(navy) || line lseq_mean compustat_dt if BtM_big==1 & !mi(lseq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lseq_1.gph", replace)
twoway line dlcq_perc_mean compustat_dt if BtM_big==0 & !mi(dlcq_perc_mean), lw(thin) lc(navy) || line dlcq_perc_mean compustat_dt if BtM_big==1 & !mi(dlcq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_perc_1.gph", replace)
twoway line dlttq_perc_mean compustat_dt if BtM_big==0 & !mi(dlttq_perc_mean), lw(thin) lc(navy) || line dlttq_perc_mean compustat_dt if BtM_big==1 & !mi(dlttq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_perc_1.gph", replace)
twoway line lctq_perc_mean compustat_dt if BtM_big==0 & !mi(lctq_perc_mean), lw(thin) lc(navy) || line lctq_perc_mean compustat_dt if BtM_big==1 & !mi(lctq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_perc_1.gph", replace)
twoway line lltq_perc_mean compustat_dt if BtM_big==0 & !mi(lltq_perc_mean), lw(thin) lc(navy) || line lltq_perc_mean compustat_dt if BtM_big==1 & !mi(lltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_perc_1.gph", replace)
twoway line ltq_perc_mean compustat_dt if BtM_big==0 & !mi(ltq_perc_mean), lw(thin) lc(navy) || line ltq_perc_mean compustat_dt if BtM_big==1 & !mi(ltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_perc_1.gph", replace)

* draw graphs: median
twoway line apq_med compustat_dt if BtM_big==0 & !mi(apq_med), lw(thin) lc(navy) || line apq_med compustat_dt if BtM_big==1 & !mi(apq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/apq_2.gph", replace)
twoway line dlcq_med compustat_dt if BtM_big==0 & !mi(dlcq_med), lw(thin) lc(navy) || line dlcq_med compustat_dt if BtM_big==1 & !mi(dlcq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_2.gph", replace)
twoway line dlttq_med compustat_dt if BtM_big==0 & !mi(dlttq_med), lw(thin) lc(navy) || line dlttq_med compustat_dt if BtM_big==1 & !mi(dlttq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_2.gph", replace)
twoway line lctq_med compustat_dt if BtM_big==0 & !mi(lctq_med), lw(thin) lc(navy) || line lctq_med compustat_dt if BtM_big==1 & !mi(lctq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_2.gph", replace)
twoway line lltq_med compustat_dt if BtM_big==0 & !mi(lltq_med), lw(thin) lc(navy) || line lltq_med compustat_dt if BtM_big==1 & !mi(lltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_2.gph", replace)
twoway line ltq_med compustat_dt if BtM_big==0 & !mi(ltq_med), lw(thin) lc(navy) || line ltq_med compustat_dt if BtM_big==1 & !mi(ltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_2.gph", replace)
twoway line xintq_med compustat_dt if BtM_big==0 & !mi(xintq_med), lw(thin) lc(navy) || line xintq_med compustat_dt if BtM_big==1 & !mi(xintq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/xintq_2.gph", replace)
twoway line lseq_med compustat_dt if BtM_big==0 & !mi(lseq_med), lw(thin) lc(navy) || line lseq_med compustat_dt if BtM_big==1 & !mi(lseq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lseq_2.gph", replace)
twoway line dlcq_perc_med compustat_dt if BtM_big==0 & !mi(dlcq_perc_med), lw(thin) lc(navy) || line dlcq_perc_med compustat_dt if BtM_big==1 & !mi(dlcq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_perc_2.gph", replace)
twoway line dlttq_perc_med compustat_dt if BtM_big==0 & !mi(dlttq_perc_med), lw(thin) lc(navy) || line dlttq_perc_med compustat_dt if BtM_big==1 & !mi(dlttq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_perc_2.gph", replace)
twoway line lctq_perc_med compustat_dt if BtM_big==0 & !mi(lctq_perc_med), lw(thin) lc(navy) || line lctq_perc_med compustat_dt if BtM_big==1 & !mi(lctq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_perc_2.gph", replace)
twoway line lltq_perc_med compustat_dt if BtM_big==0 & !mi(lltq_perc_med), lw(thin) lc(navy) || line lltq_perc_med compustat_dt if BtM_big==1 & !mi(lltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_perc_2.gph", replace)
twoway line ltq_perc_med compustat_dt if BtM_big==0 & !mi(ltq_perc_med), lw(thin) lc(navy) || line ltq_perc_med compustat_dt if BtM_big==1 & !mi(ltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_perc_2.gph", replace)

restore

* produce the final output: average versus median in the same figure
cd "${figdir}/2port"

gr combine apq_1.gph apq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Accounts Payable: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/apq.gph", replace)
gr combine dlcq_1.gph dlcq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Debt in Current Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlcq.gph", replace)
gr combine dlttq_1.gph dlttq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Debt: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlttq.gph", replace)
gr combine lctq_1.gph lctq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Current Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lctq.gph", replace)
gr combine lltq_1.gph lltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lltq.gph", replace)
gr combine ltq_1.gph ltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Total Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/ltq.gph", replace)
gr combine xintq_1.gph xintq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Interest and Related Expense: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/xintq.gph", replace)
gr combine lseq_1.gph lseq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Liabilities and Equity: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lseq.gph", replace)
gr combine dlcq_perc_1.gph dlcq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Current Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlcq_perc.gph", replace)
gr combine dlttq_perc_1.gph dlttq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Long-term Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlttq_perc.gph", replace)
gr combine lctq_perc_1.gph lctq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Current Liabilities in Total: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lctq_perc.gph", replace)
gr combine lltq_perc_1.gph lltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Long-term Liabilities in Total: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lltq_perc.gph", replace)
gr combine ltq_perc_1.gph ltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Liabilities in Assets: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/ltq_perc.gph", replace)

foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    gr use "${figdir}/2port/`var'.gph"
    gr export "${figdir}/2port/`var'.png", wid(1200) hei(500)
}

* Annual Study ==================---============================================
*===============================================================================
*===============================================================================
* Process debt information
*===============================================================================
use "${inputdir}/compustat_debt_annual.dta", clear

* clean duplicates
destring gvkey, replace
rename datadate compustat_dt

duplicates tag gvkey compustat_dt, g(dup)
drop if dup==1 & indfmt=="FS"
duplicates report gvkey compustat_dt /*should be none*/
drop dup fyear indfmt consol popsrc datafmt curcd costat
save, replace

*===============================================================================
* Merge the debt data to the firms of high/low BTM
*===============================================================================
* open the formatted data:
use "${outputdir}/full_data.dta", clear
keep gvkey compustat_dt yyyymm BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM

* merge with debt data
merge m:1 gvkey compustat_dt using "${inputdir}/compustat_debt_annual.dta"
keep if merge==3
drop _merge

* keep variables of interest

global debt_info = "cld2 cld3 cld4 cld5 dclo dcvt dd dd1 dd2 dd3 dd4 dd5 dltis dltr dm dn dxd2 dxd3 dxd4 dxd5"
global other_info = "gvkey compustat_dt yyyymm BtM BtMdec DECILEmth_BtM DECILEdec_BtM QUINTILEdec_BtM QUINTILEmth_BtM"
keep $debt_info $other_info

* save to another file for further analysis
save "${outputdir}/debt structure/debt_btm_annual.dta", replace

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
twoway line apq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(apq_mean), lw(thin) lc(navy) || line apq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(apq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/apq_1.gph", replace)
twoway line dlcq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_mean), lw(thin) lc(navy) || line dlcq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_1.gph", replace)
twoway line dlttq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_mean), lw(thin) lc(navy) || line dlttq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_1.gph", replace)
twoway line lctq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_mean), lw(thin) lc(navy) || line lctq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_1.gph", replace)
twoway line lltq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_mean), lw(thin) lc(navy) || line lltq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_1.gph", replace)
twoway line ltq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_mean), lw(thin) lc(navy) || line ltq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_1.gph", replace)
twoway line xintq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(xintq_mean), lw(thin) lc(navy) || line xintq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(xintq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/xintq_1.gph", replace)
twoway line lseq_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lseq_mean), lw(thin) lc(navy) || line lseq_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lseq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lseq_1.gph", replace)
twoway line dlcq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_perc_mean), lw(thin) lc(navy) || line dlcq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_perc_1.gph", replace)
twoway line dlttq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_perc_mean), lw(thin) lc(navy) || line dlttq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_perc_1.gph", replace)
twoway line lctq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_perc_mean), lw(thin) lc(navy) || line lctq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_perc_1.gph", replace)
twoway line lltq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_perc_mean), lw(thin) lc(navy) || line lltq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_perc_1.gph", replace)
twoway line ltq_perc_mean compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_perc_mean), lw(thin) lc(navy) || line ltq_perc_mean compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Average",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_perc_1.gph", replace)

* draw graphs: median
twoway line apq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(apq_med), lw(thin) lc(navy) || line apq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(apq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/apq_2.gph", replace)
twoway line dlcq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_med), lw(thin) lc(navy) || line dlcq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_2.gph", replace)
twoway line dlttq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_med), lw(thin) lc(navy) || line dlttq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_2.gph", replace)
twoway line lctq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_med), lw(thin) lc(navy) || line lctq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_2.gph", replace)
twoway line lltq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_med), lw(thin) lc(navy) || line lltq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_2.gph", replace)
twoway line ltq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_med), lw(thin) lc(navy) || line ltq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_2.gph", replace)
twoway line xintq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(xintq_med), lw(thin) lc(navy) || line xintq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(xintq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/xintq_2.gph", replace)
twoway line lseq_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lseq_med), lw(thin) lc(navy) || line lseq_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lseq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lseq_2.gph", replace)
twoway line dlcq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlcq_perc_med), lw(thin) lc(navy) || line dlcq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlcq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlcq_perc_2.gph", replace)
twoway line dlttq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(dlttq_perc_med), lw(thin) lc(navy) || line dlttq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(dlttq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/dlttq_perc_2.gph", replace)
twoway line lctq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lctq_perc_med), lw(thin) lc(navy) || line lctq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lctq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lctq_perc_2.gph", replace)
twoway line lltq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(lltq_perc_med), lw(thin) lc(navy) || line lltq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(lltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/lltq_perc_2.gph", replace)
twoway line ltq_perc_med compustat_dt if QUINTILEdec_BtM==1 & !mi(ltq_perc_med), lw(thin) lc(navy) || line ltq_perc_med compustat_dt if QUINTILEdec_BtM==5 & !mi(ltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Median",size(medlarge)) legend(order(1 "Firms in the lowest BtM portfolio" 2 "Firms in highest BtM portfolio") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/1port/ltq_perc_2.gph", replace)

restore

* produce the final output: average versus median in the same figure
cd "${figdir}/1port"

gr combine apq_1.gph apq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Accounts Payable: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/apq.gph", replace)
gr combine dlcq_1.gph dlcq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Debt in Current Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlcq.gph", replace)
gr combine dlttq_1.gph dlttq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Debt: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlttq.gph", replace)
gr combine lctq_1.gph lctq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Current Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lctq.gph", replace)
gr combine lltq_1.gph lltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lltq.gph", replace)
gr combine ltq_1.gph ltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Total Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/ltq.gph", replace)
gr combine xintq_1.gph xintq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Interest and Related Expense: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/xintq.gph", replace)
gr combine lseq_1.gph lseq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Liabilities and Equity: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lseq.gph", replace)
gr combine dlcq_perc_1.gph dlcq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Current Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlcq_perc.gph", replace)
gr combine dlttq_perc_1.gph dlttq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Long-term Liabilities: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/dlttq_perc.gph", replace)
gr combine lctq_perc_1.gph lctq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Current Liabilities in Total: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lctq_perc.gph", replace)
gr combine lltq_perc_1.gph lltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Long-term Liabilities in Total: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/lltq_perc.gph", replace)
gr combine ltq_perc_1.gph ltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Liabilities in Assets: Firms in the Highest versus Lowest BtM Quintile") saving("${figdir}/1port/ltq_perc.gph", replace)

foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    gr use "${figdir}/1port/`var'.gph"
    gr export "${figdir}/1port/`var'.png", wid(1200) hei(500)
}

* BtM 5/4 versus BtM 1/2 =======================================================
* Mean of firms in 2 higher BtM portfolios versus 2 lower BtM portfolios
preserve
* generate a "smoother" version of BtM portfolios
gen BtM_big=1 if QUINTILEdec_BtM==4 | QUINTILEdec_BtM==5
replace BtM_big=0 if QUINTILEdec_BtM==1 | QUINTILEdec_BtM==2

keep if !mi(BtM_big)

* generate variables for figures
foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    bys compustat_dt BtM_big: egen `var'_mean = mean(`var')
    bys compustat_dt BtM_big: egen `var'_med = median(`var')
    *bys compustat_dt QUINTILEdec_BtM: egen `var'_se = sd(`var')
    *gen `var'_l = `var'_mean - 1.96*`var'_se
    *gen `var'_r = `var'_mean + 1.96*`var'_se
}
bys compustat_dt BtM_big: egen n_obs = count(gvkey)

* keep a date by portfolio data set for figures
duplicates drop compustat_dt BtM_big, force
keep compustat_dt BtM_big n_obs *_mean *_med

* draw graphs: mean
twoway line apq_mean compustat_dt if BtM_big==0 & !mi(apq_mean), lw(thin) lc(navy) || line apq_mean compustat_dt if BtM_big==1 & !mi(apq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/apq_1.gph", replace)
twoway line dlcq_mean compustat_dt if BtM_big==0 & !mi(dlcq_mean), lw(thin) lc(navy) || line dlcq_mean compustat_dt if BtM_big==1 & !mi(dlcq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_1.gph", replace)
twoway line dlttq_mean compustat_dt if BtM_big==0 & !mi(dlttq_mean), lw(thin) lc(navy) || line dlttq_mean compustat_dt if BtM_big==1 & !mi(dlttq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_1.gph", replace)
twoway line lctq_mean compustat_dt if BtM_big==0 & !mi(lctq_mean), lw(thin) lc(navy) || line lctq_mean compustat_dt if BtM_big==1 & !mi(lctq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_1.gph", replace)
twoway line lltq_mean compustat_dt if BtM_big==0 & !mi(lltq_mean), lw(thin) lc(navy) || line lltq_mean compustat_dt if BtM_big==1 & !mi(lltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_1.gph", replace)
twoway line ltq_mean compustat_dt if BtM_big==0 & !mi(ltq_mean), lw(thin) lc(navy) || line ltq_mean compustat_dt if BtM_big==1 & !mi(ltq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_1.gph", replace)
twoway line xintq_mean compustat_dt if BtM_big==0 & !mi(xintq_mean), lw(thin) lc(navy) || line xintq_mean compustat_dt if BtM_big==1 & !mi(xintq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/xintq_1.gph", replace)
twoway line lseq_mean compustat_dt if BtM_big==0 & !mi(lseq_mean), lw(thin) lc(navy) || line lseq_mean compustat_dt if BtM_big==1 & !mi(lseq_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lseq_1.gph", replace)
twoway line dlcq_perc_mean compustat_dt if BtM_big==0 & !mi(dlcq_perc_mean), lw(thin) lc(navy) || line dlcq_perc_mean compustat_dt if BtM_big==1 & !mi(dlcq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_perc_1.gph", replace)
twoway line dlttq_perc_mean compustat_dt if BtM_big==0 & !mi(dlttq_perc_mean), lw(thin) lc(navy) || line dlttq_perc_mean compustat_dt if BtM_big==1 & !mi(dlttq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_perc_1.gph", replace)
twoway line lctq_perc_mean compustat_dt if BtM_big==0 & !mi(lctq_perc_mean), lw(thin) lc(navy) || line lctq_perc_mean compustat_dt if BtM_big==1 & !mi(lctq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_perc_1.gph", replace)
twoway line lltq_perc_mean compustat_dt if BtM_big==0 & !mi(lltq_perc_mean), lw(thin) lc(navy) || line lltq_perc_mean compustat_dt if BtM_big==1 & !mi(lltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_perc_1.gph", replace)
twoway line ltq_perc_mean compustat_dt if BtM_big==0 & !mi(ltq_perc_mean), lw(thin) lc(navy) || line ltq_perc_mean compustat_dt if BtM_big==1 & !mi(ltq_perc_mean), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Average",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_perc_1.gph", replace)

* draw graphs: median
twoway line apq_med compustat_dt if BtM_big==0 & !mi(apq_med), lw(thin) lc(navy) || line apq_med compustat_dt if BtM_big==1 & !mi(apq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Accounts payable (quarterly, in M$)", size(medsmall)) title("Accounts Payable: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/apq_2.gph", replace)
twoway line dlcq_med compustat_dt if BtM_big==0 & !mi(dlcq_med), lw(thin) lc(navy) || line dlcq_med compustat_dt if BtM_big==1 & !mi(dlcq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Debt in current liabilities (quarterly, in M$)", size(medsmall)) title("Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_2.gph", replace)
twoway line dlttq_med compustat_dt if BtM_big==0 & !mi(dlttq_med), lw(thin) lc(navy) || line dlttq_med compustat_dt if BtM_big==1 & !mi(dlttq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term debt (quarterly, in M$)", size(medsmall)) title("Long-term Debt: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_2.gph", replace)
twoway line lctq_med compustat_dt if BtM_big==0 & !mi(lctq_med), lw(thin) lc(navy) || line lctq_med compustat_dt if BtM_big==1 & !mi(lctq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Current liabilities (quarterly, in M$)", size(medsmall)) title("Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_2.gph", replace)
twoway line lltq_med compustat_dt if BtM_big==0 & !mi(lltq_med), lw(thin) lc(navy) || line lltq_med compustat_dt if BtM_big==1 & !mi(lltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Long-term liabilities (quarterly, in M$)", size(medsmall)) title("Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_2.gph", replace)
twoway line ltq_med compustat_dt if BtM_big==0 & !mi(ltq_med), lw(thin) lc(navy) || line ltq_med compustat_dt if BtM_big==1 & !mi(ltq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Total liabilities (quarterly, in M$)", size(medsmall)) title("Total Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_2.gph", replace)
twoway line xintq_med compustat_dt if BtM_big==0 & !mi(xintq_med), lw(thin) lc(navy) || line xintq_med compustat_dt if BtM_big==1 & !mi(xintq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Interest and related expense (quarterly, in M$)", size(medsmall)) title("Interest and Related Expense: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/xintq_2.gph", replace)
twoway line lseq_med compustat_dt if BtM_big==0 & !mi(lseq_med), lw(thin) lc(navy) || line lseq_med compustat_dt if BtM_big==1 & !mi(lseq_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("Liabilities and equity (quarterly, in M$)", size(medsmall)) title("Liabilities and Equity: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lseq_2.gph", replace)
twoway line dlcq_perc_med compustat_dt if BtM_big==0 & !mi(dlcq_perc_med), lw(thin) lc(navy) || line dlcq_perc_med compustat_dt if BtM_big==1 & !mi(dlcq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in current liabilities (quarterly)", size(medsmall)) title("% Debt in Current Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlcq_perc_2.gph", replace)
twoway line dlttq_perc_med compustat_dt if BtM_big==0 & !mi(dlttq_perc_med), lw(thin) lc(navy) || line dlttq_perc_med compustat_dt if BtM_big==1 & !mi(dlttq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Debt in long-term liabilities (quarterly)", size(medsmall)) title("% Debt in Long-term Liabilities: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/dlttq_perc_2.gph", replace)
twoway line lctq_perc_med compustat_dt if BtM_big==0 & !mi(lctq_perc_med), lw(thin) lc(navy) || line lctq_perc_med compustat_dt if BtM_big==1 & !mi(lctq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Current liabilities in total (quarterly)", size(medsmall)) title("% Current Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lctq_perc_2.gph", replace)
twoway line lltq_perc_med compustat_dt if BtM_big==0 & !mi(lltq_perc_med), lw(thin) lc(navy) || line lltq_perc_med compustat_dt if BtM_big==1 & !mi(lltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Long-term liabilities in total (quarterly)", size(medsmall)) title("% Long-term Liabilities in Total: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/lltq_perc_2.gph", replace)
twoway line ltq_perc_med compustat_dt if BtM_big==0 & !mi(ltq_perc_med), lw(thin) lc(navy) || line ltq_perc_med compustat_dt if BtM_big==1 & !mi(ltq_perc_med), lw(thin) lc(dkorange) xlabel(#4, labs(small)) xtitle("Date", size(medsmall)) ytitle("% Liabilities in assets (quarterly)", size(medsmall)) title("% Liabilities in Assets: Median",size(medlarge)) legend(order(1 "Firms in 2 lower BtM portfolios" 2 "Firms in 2 higher BtM portfolios") size(small)) note("(BtM-sorted quintile portfolios are built following Fama and French (1992))") saving("${figdir}/2port/ltq_perc_2.gph", replace)

restore

* produce the final output: average versus median in the same figure
cd "${figdir}/2port"

gr combine apq_1.gph apq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Accounts Payable: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/apq.gph", replace)
gr combine dlcq_1.gph dlcq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Debt in Current Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlcq.gph", replace)
gr combine dlttq_1.gph dlttq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Debt: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlttq.gph", replace)
gr combine lctq_1.gph lctq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Current Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lctq.gph", replace)
gr combine lltq_1.gph lltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Long-term Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lltq.gph", replace)
gr combine ltq_1.gph ltq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Total Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/ltq.gph", replace)
gr combine xintq_1.gph xintq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Interest and Related Expense: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/xintq.gph", replace)
gr combine lseq_1.gph lseq_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("Liabilities and Equity: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lseq.gph", replace)
gr combine dlcq_perc_1.gph dlcq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Current Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlcq_perc.gph", replace)
gr combine dlttq_perc_1.gph dlttq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Debt in Long-term Liabilities: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/dlttq_perc.gph", replace)
gr combine lctq_perc_1.gph lctq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Current Liabilities in Total: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lctq_perc.gph", replace)
gr combine lltq_perc_1.gph lltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Long-term Liabilities in Total: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/lltq_perc.gph", replace)
gr combine ltq_perc_1.gph ltq_perc_2.gph, rows(1) cols(2) imargin(medlarge) xsize(12) ysize(5) title("% Liabilities in Assets: Firms in the Highest versus Lowest 2 BtM Quintiles") saving("${figdir}/2port/ltq_perc.gph", replace)

foreach var in $debt_info lseq dlcq_perc dlttq_perc lctq_perc lltq_perc ltq_perc{
    gr use "${figdir}/2port/`var'.gph"
    gr export "${figdir}/2port/`var'.png", wid(1200) hei(500)
}