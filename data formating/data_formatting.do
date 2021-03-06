* formatting the dataset from straightly merging
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

qui log using "F:/Stephen/analysis/logfile/data_cleaning.smcl", replace

clear
cd "F:/Stephen/separate"

*===============================================================================
* Clean the merged dataset
*===============================================================================
use full_data_raw
destring gvkey, replace

* keep NYSE/AMEX/Nasdaq
keep if exchcd == 1 | exchcd == 2 | exchcd == 3

drop tic ajpq datacqtr cshiq dd1q dvpq ibq lltq npq pstkrq teqq txdiq exchg crsp_dt costat permno primexch vol

gen yyyymm = 100*year(datadate) + month(datadate)

gen DecDate = 100*(year(datadate)-1)+12 if month(datadate)<=12 & month(datadate)>=7
replace DecDate = 100*(year(datadate)-2)+12 if month(datadate)<=6 & month(datadate)>=1

gen Fq4Date = string(year(datadate)-1)+"Q4" if month(datadate)<=12 & month(datadate)>=7
replace Fq4Date = string(year(datadate)-2)+"Q4" if month(datadate)<=6 & month(datadate)>=1

gen JunDate = 100*(year(datadate))+6 if month(datadate)<=12 & month(datadate)>=7
replace JunDate = 100*(year(datadate)-1)+6 if month(datadate)<=6 & month(datadate)>=1

* jump: identify firms that out of the dataset at a point and back in later
sort cusip datadate
by cusip: gen jump = datadate - datadate[_n-1]
replace jump = . if jump <=366
by cusip: replace jump = jump[_n-1] if jump==.
replace jump = 0 if jump==.

* rename and label variables
rename ret RET
label variable RET "monthly return"
rename retx RETx
label variable RETx "monthly return without dividends"
rename atq at
label variable at "book assets"
rename prc PRC
replace PRC = abs(PRC) if PRC<0
* CRSP use the negative of average of bid and ask price to impute missing close prices. 

label variable PRC "end-of-month price"
rename ltq ltq_f
label variable ltq_f "book liabilities"

label define share_code 1 "NYSE" 2 "AMEX" 3 "NASDAQ"
label values exchcd share_code

* impute missing values ========================================================
* missing compustat items: replace missings with most recent data
merge m:1 gvkey compustat_dt using "F:/Stephen/auxilary data/liabilities.dta"
drop if _merge==2
drop _merge
replace at= at_m if at==.
replace lseq=at if lseq==.
replace ltq_f=ltq_m if ltq_f==.
drop at_m ltq_m

* deferred tax and investment tax credits (if applicable)
replace txditcq = txdbq if mi(txditcq)
replace txditcq = 0 if mi(txditcq)

* impute debt data with linear interpolatg according to date (CRSP)
sort cusip compustat_dt datadate
foreach var in dlcq dlttq ltq_f{
    gen `var'_aux = `var'
    by cusip compustat_dt: replace `var'_aux=. if _n>1
    by cusip: ipolate `var'_aux datadate, gen(`var'_intpl)
    drop `var'_aux
}

* keep the last non-missing value constant through the following periods without valid values
sort cusip jump datadate
foreach var in at ceqq cshoq dlcq dlttq ltq_f lseq pstkq{
    by cusip jump: replace `var' = `var'[_n-1] if `var'==.
}

* drop 338 0-common-share obs
replace cshoq =. if cshoq==0

* generate variables of interest ===============================================
* BE: following Fama and French (1992), use common equity + balance sheet deferred tax and investment tax credit (if applicable)
gen BE = ceqq + txditcq
label variable BE "book equity"

* ME: the price in the end of month t-1 * the common share in the end of last quarter * adjustment factor of compustat
gen Lag1 = yyyymm-1
replace Lag1 = (year(datadate)-1)*100 + 12 if month(datadate)==1

preserve
keep cusip yyyymm PRC
rename yyyymm Lag1
rename PRC prc_lag
tempfile lag_prc
save `lag_prc', replace
restore

merge 1:1 cusip Lag1 using `lag_prc'
drop if _merge==2
drop _merge

gen ME = cshoq*prc_lag
label variable ME "market equity"

gen BtM = BE/ME
label variable BtM "book to market"

* generate MElag Lev LevLag
gen Lev = ltq_f/(ltq_f+ME)
gen Lev_intpl = ltq_f_intpl/(ltq_f_intpl+ME)

preserve
keep cusip yyyymm ME BtM Lev Lev_intpl
rename yyyymm Lag1
rename ME MElag
rename BtM BtMlag
rename Lev LevLag
rename Lev_intpl LevLag_intpl
tempfile lag_me
save `lag_me', replace
restore

merge 1:1 cusip Lag1 using `lag_me'
drop if _merge==2
drop _merge

drop curcdq

label variable Lev "Leverage"
label variable Lev_intpl "Leverage, linear interpolating"

* reassign the at/BE/ME data in Fama-French fashion ============================
* generate atdec BEdec medec Levdec
preserve
tempfile data_dec
keep at BE ME Lev Lev_intpl gvkey compustat_dt
duplicates drop gvkey compustat_dt, force
rename at atdec
rename BE BEdec
rename ME MEdec
rename Lev Levdec
rename Lev_intpl Levdec_intpl

gen BtMdec = BEdec/MEdec

gen DecDate = 100*year(compustat_dt)+month(compustat_dt)
drop compustat_dt
save `data_dec', replace
restore

merge m:1 gvkey DecDate using `data_dec'
drop if _merge==2
drop _merge

* generate MEjun
preserve
tempfile ME_june
keep ME gvkey compustat_dt
duplicates drop gvkey compustat_dt, force
rename ME MEjun
gen JunDate = 100*year(compustat_dt)+month(compustat_dt)
drop compustat_dt
save `ME_june', replace
restore

merge m:1 gvkey JunDate using `ME_june'
drop if _merge==2
drop _merge

* merge with Fama-French risk free rate ========================================
merge m:1 yyyymm using "F:/Stephen/french_website/french_fama.dta", keepusing(rfFFWebsite)
drop if _merge==2
drop _merge
replace rfFFWebsite = rfFFWebsite/100
gen RetExcess = RET - rfFFWebsite

* drop financial firms, based on https://www.osha.gov/pls/imis/sic_manual.html
destring sic, replace
drop if inrange(sic,6000,6999)

* drop 135190 missings
drop if mi(at) | mi(BE) | mi(ME) | mi(Lev) | mi(RET)

* drop data before July 1971, since then, there're at leat 123 firms per month
keep if yyyymm>=197107

* generate ME decile ===========================================================
* generate DECILE of monthly adjusted portfolio, the size decile markers
gen DECILE = .

forvalues i = 1/9{
    local j=10*`i'
    bys datadate: egen ME_p`j' = pctile(MElag) if exchcd == 1, p(`j')
    sort datadate ME_p`j'
    by datadate: replace ME_p`j' = ME_p`j'[_n-1] if ME_p`j' == .
    replace DECILE = `i' if MElag <= ME_p`j' & DECILE == .
    drop ME_p`j'
}

bys datadate: egen ME_p90 = pctile(MElag) if exchcd == 1, p(90)
sort datadate ME_p90
by datadate: replace ME_p90 = ME_p90[_n-1] if ME_p90 == .
replace DECILE = 10 if MElag > ME_p90 & DECILE == .
drop ME_p90

rename DECILE DECILEmth

* generate DECILE of June-adjusted portfolio:
* the size of firm in June of year t, holding from July of year t to June of year t+1
preserve
tempfile decile_jun

keep cusip JunDate MEjun exchcd
keep if !mi(MEjun)
duplicates drop cusip JunDate, force

gen DECILEjun = .

forvalues i = 1/9{
    local j = 10*`i'
    bys JunDate: egen ME_p`j' = pctile(MEjun) if exchcd == 1, p(`j')
    sort JunDate ME_p`j'
    by JunDate: replace ME_p`j' = ME_p`j'[_n-1] if ME_p`j' == .
    replace DECILEjun = `i' if MEjun <= ME_p`j' & DECILEjun == .
    drop ME_p`j'
}

bys JunDate: egen ME_p90 = pctile(MEjun) if exchcd == 1, p(90)
sort JunDate ME_p90
by JunDate: replace ME_p90 = ME_p90[_n-1] if ME_p90 == .
replace DECILEjun = 10 if MEjun > ME_p90 & DECILEjun == .
drop ME_p90

keep cusip JunDate DECILEjun
save `decile_jun', replace
restore

merge m:1 cusip JunDate using `decile_jun'
drop _merge

* Generate Book-To-Market Ratio and Decile======================================
* generate DECILE of monthly-adjusted Portfolio, BTM is calcuated with lag 1 month equity and book value
gen DECILEmth_BtM = .

forvalues i = 1/9{
    local j=10*`i'
    bys datadate: egen BtM_p`j' = pctile(BtMlag) if exchcd == 1, p(`j')
    sort datadate BtM_p`j'
    by datadate: replace BtM_p`j' = BtM_p`j'[_n-1] if BtM_p`j' == .
    replace DECILEmth_BtM = `i' if BtMlag <= BtM_p`j' & DECILEmth_BtM == .
    drop BtM_p`j'
}

bys datadate: egen BtM_p90 = pctile(BtMlag) if exchcd == 1, p(90)
sort datadate BtM_p90
by datadate: replace BtM_p90 = BtM_p90[_n-1] if BtM_p90 == .
replace DECILEmth_BtM = 10 if BtMlag > BtM_p90 & DECILEmth_BtM == .
drop BtM_p90

* generate DECILE of June-adjusted Portfolio, BTM is calcuated with December(t-1) equity and book value
preserve
tempfile decile_dec

keep cusip DecDate BtMdec exchcd
keep if !mi(BtMdec)
duplicates drop cusip DecDate, force

gen DECILEdec_BtM = .
forvalues i = 1/9{
    local j = 10*`i'
    bys DecDate: egen BtM_p`j' = pctile(BtMdec) if exchcd == 1, p(`j')
    sort DecDate BtM_p`j'
    by DecDate: replace BtM_p`j' = BtM_p`j'[_n-1] if BtM_p`j' == .
    replace DECILEdec_BtM = `i' if BtMdec <= BtM_p`j' & DECILEdec_BtM == .
    drop BtM_p`j'
}

bys DecDate: egen BtM_p90 = pctile(BtMdec) if exchcd == 1, p(90)
sort DecDate BtM_p90
by DecDate: replace BtM_p90 = BtM_p90[_n-1] if BtM_p90 == .
replace DECILEdec_BtM = 10 if BtMdec > BtM_p90 & DECILEdec_BtM == .
drop BtM_p90

keep cusip DecDate DECILEdec_BtM
save `decile_dec', replace
restore

merge m:1 cusip DecDate using `decile_dec'
drop _merge

* ==============================================================================
* Generate double-sorting portfolio marker
* ==============================================================================
* 10-by-10 =====================================================================
* Fama-French style: June(t) ME breakpoints by December(t-1) BTM breakpoints for returns from July(t) to June(t+1)
*** DECILEjun-by-FF_port_decile
preserve
tempfile decile_ff

keep cusip DecDate DECILEjun BtMdec exchcd
keep if !mi(BtMdec) & !mi(DECILEjun)
duplicates drop cusip DecDate DECILEjun, force

gen FF_port_decile = .

forvalues i = 1/9{
    local j = 10*`i'
    bys DecDate DECILEjun: egen BtM_p`j' = pctile(BtMdec) if exchcd == 1, p(`j')
    sort DecDate DECILEjun BtM_p`j'
    by DecDate DECILEjun: replace BtM_p`j' = BtM_p`j'[_n-1] if BtM_p`j' == .
    replace FF_port_decile = `i' if BtMdec <= BtM_p`j' & FF_port_decile == .
    drop BtM_p`j'
}

bys DecDate DECILEjun: egen BtM_p90 = pctile(BtMdec) if exchcd == 1, p(90)
sort DecDate DECILEjun BtM_p90
by DecDate DECILEjun: replace BtM_p90 = BtM_p90[_n-1] if BtM_p90 == .
replace FF_port_decile = 10 if BtMdec > BtM_p90 & FF_port_decile == .
drop BtM_p90

keep cusip DecDate DECILEjun FF_port_decile
save `decile_ff', replace
restore

merge m:1 cusip DecDate DECILEjun using `decile_ff'
drop _merge

* Higher frequency style: use last month ME and BTM
*** DECILEmth-by-mth_port_decile
gen mth_port_decile = .

forvalues i = 1/9{
    local j=10*`i'
    bys datadate DECILEmth: egen BtM_p`j' = pctile(BtMlag) if exchcd == 1, p(`j')
    sort datadate DECILEmth BtM_p`j'
    by datadate DECILEmth: replace BtM_p`j' = BtM_p`j'[_n-1] if BtM_p`j' == .
    replace mth_port_decile = `i' if BtMlag <= BtM_p`j' & mth_port_decile == .
    drop BtM_p`j'
}

bys datadate DECILEmth: egen BtM_p90 = pctile(BtMlag) if exchcd == 1, p(90)
sort datadate DECILEmth BtM_p90
by datadate DECILEmth: replace BtM_p90 = BtM_p90[_n-1] if BtM_p90 == .
replace mth_port_decile = 10 if BtMlag > BtM_p90 & mth_port_decile == .
drop BtM_p90

* 5 by 5 =======================================================================
* Fama-French style: June(t) ME breakpoints by December(t-1) BTM breakpoints for returns from July(t) to June(t+1)
*** DECILEjun-by-FF_port_decile
gen QUINTILEjun = ceil(DECILEjun/2)
gen FF_port_quintile = ceil(FF_port_decile/2)
gen QUINTILEdec_BtM = ceil(DECILEdec_BtM/2)

* Higher frequency style: use last month ME and BTM
*** QUINTILEmth-by-mth_port_quintile
gen QUINTILEmth = ceil(DECILEmth/2)
gen mth_port_quintile = ceil(mth_port_decile/2)
gen QUINTILEmth_BtM = ceil(DECILEmth_BtM/2)

* Other variables --------------------------------------------------------------
* merge with market returns from Kennith French's website
merge m:1 yyyymm using "F:/Stephen/french_website/french_fama.dta", keepusing(Mkt_prem)
drop if _merge==2
drop _merge
replace Mkt_prem = Mkt_prem/100

* merge with volatility calculated with daily returns
* -----volatility: annualized volatility of past two years' daily returns of any given month
merge 1:1 cusip8 yyyymm using "F:/Stephen/auxilary data/monthly_volatility.dta", keepusing(EquityVolatility)
drop if _merge==2
drop _merge
rename EquityVolatility EquityVol

merge 1:1 cusip8 Lag1 using "F:/Stephen/auxilary data/monthly_volatility.dta", keepusing(EquityVolatility)
drop if _merge==2
drop _merge
rename EquityVolatility EquityVolLag

* final outputs
save "F:/Stephen/analysis/full_data.dta", replace

* ==============================================================================
* Generate variables used for Fama-French regression
* ==============================================================================
* generate Debt
gen Debt = ltq_f

* Equity
gen Equity = ME

global id_var = "gvkey exchcd yyyymm DecDate"
global prcret = "PRC RET RetExcess rfFFWebsite Mkt_prem"
global values = "at BE ME MElag MEjun atdec BEdec MEdec BtM BtMdec Debt Equity"
global levvol = "EquityVol EquityVolLag Lev Lev_intpl Levdec Levdec_intpl LevLag LevLag_intpl ltq_f ltq_f_intpl"
global bp_FF = "DECILEjun DECILEdec_BtM FF_port_decile"
global bp_mth = "DECILEmth DECILEmth_BtM mth_port_decile"

* convert the data set into .csv format, for MATLAB analysis
preserve
keep $id_var $prcret $values $levvol $bp_FF $bp_mth
export delimited using "F:\Stephen\analysis\FMreg.csv", replace
restore

clear