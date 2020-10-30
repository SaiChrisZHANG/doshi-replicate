* formatting the dataset from straightly merging
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

clear
cd "F:/Stephen/separate"

*===============================================================================
* Clean the merged dataset
*===============================================================================
use full_data_raw

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

* generate MElag Lev LevLag
gen Lev = ltq_f/(ltq_f+ME)
gen Lev_intpl = ltq_f_intpl/(ltq_f_intpl+ME)

preserve
keep cusip yyyymm ME Lev Lev_intpl
rename yyyymm Lag1
rename ME MElag
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
label variable Lev "Leverage, linear interpolating"

* reassign the at/BE/ME data in Fama-French fashion ============================
* generate atdec BEdec medec
preserve
tempfile data_dec
keep at BE ME gvkey compustat_dt
duplicates drop gvkey compustat_dt, force
rename at atdec
rename BE BEdec
rename ME MEdec
gen DecDate = 100*year(compustat_dt)+month(compustat_dt)
drop compustat_dt
save `data_dec', replace
restore

merge m:1 gvkey DecDate using `data_dec'
drop if _merge==2
drop _merge

* generate atFq4 BEFq4 meFq4
preserve
tempfile data_fq4
keep at BE ME gvkey datafqtr
duplicates drop gvkey datafqtr, force
rename at atfq4
rename BE BEfq4
rename ME MEfq4
rename datafqtr Fq4Date
save `data_fq4', replace
restore

merge m:1 gvkey Fq4Date using `data_fq4'
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
* ---------------------------------------- from here save as data_full_final.dta
merge m:1 yyyymm using "F:/Stephen/french_website/french_fama", keepusing(rfFFWebsite)
drop if _merge==2
drop _merge
replace rfFFWebsite = rfFFWebsite/100 /*from percentage to number*/
gen RetExcess = RET - rfFFWebsite

* generate ME decile ===========================================================
* drop financial firms, based on https://www.osha.gov/pls/imis/sic_manual.html
destring sic, replace
drop if inrange(sic,6000,6999)

* drop missings
drop if mi(at) | mi(BE) | mi(ME) | mi(Lev) | mi(RET)

* drop data before July 1971, since then, there're at leat 123 firms per month
keep if yyyymm>=197107

* generate DECILE of monthly adjusted portfolio, the size decile markers
gen DECILE = .

forvalues i = 1/9{
    local j=10*`i'
    bys datadate: egen ME_p`j' = pctile(ME) if exchcd == 1, p(`j')
    sort datadate ME_p`j'
    by datadate: replace ME_p`j' = ME_p`j'[_n-1] if ME_p`j' == .
    replace DECILE = `i' if ME <= ME_p`j' & DECILE == .
    drop ME_p`j'
}

bys datadate: egen ME_p90 = pctile(ME) if exchcd == 1, p(90)
sort datadate ME_p90
by datadate: replace ME_p90 = ME_p90[_n-1] if ME_p90 == .
replace DECILE = 10 if ME > ME_p90 & DECILE == .
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

* ==============================================================================
* Generate variables used for Merton estimation
* ==============================================================================
* generate Debt
gen Debt = ltq_f

* Equity
gen Equity = ME

* merge with volatility calculated with daily returns
* -----volatility: annualized volatility of past two years' daily returns of any given month
merge 1:1 cusip8 yyyymm using "F:/Stephen/auxilary data/monthly_volatility.dta", keepusing(EquityVolatility)
drop if _merge==2
drop _merge

clear