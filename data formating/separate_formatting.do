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

drop tic ajpq datacqtr cshiq dd1q dvpq ibq lltq npq pstkrq teqq txdbq txdiq txditcq exchg crsp_dt costat permno primexch vol _merge

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
rename ret RET_wD
label variable RET_wD "monthly return with dividend"
rename retx RET
label variable RET "monthly return (price)"
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
* missing returns
sort cusip jump datadate
by cusip jump: replace RET=(PRC-PRC[_n-1])/PRC[_n-1] if mi(RET)

* missing compustat items: replace missings with most recent data
merge m:1 gvkey compustat_dt using "F:/Stephen/auxilary data/liabilities.dta"
drop if _merge==2
drop _merge
replace at= at_m if at==.
replace lseq=at if lseq==.
replace ltq_f=ltq_m if ltq_f==.
drop at_m ltq_m

* impute missing values
sort cusip jump datadate
foreach var in at ceqq cshoq dlcq dlttq lseq ltq_f pstkq{
by cusip jump: replace `var' = `var'[_n-1] if `var'==.
}

replace ltq_f = lseq-ceqq if ltq_f==.
replace ceqq = lseq-ltq_f if ceqq==.

* drop 338 0-common-share obs
replace cshoq =. if cshoq==0

* generate variables of interest ===============================================
* BE
gen BE = ceqq-pstkq
replace BE = ceqq if BE==.
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

*---------------------------------------- form here, stored as data_analysis.dta
* transform CAD to USD
gen comp_ym = year(compustat_dt)*100 + month(compustat_dt)
merge m:1 comp_ym curcdq using "F:/Stephen/auxilary data/cad_usd.dta"
drop if _merge==2
drop _merge comp_ym
label variable cad_usd "CAD per USD"

foreach var in at ceqq dlcq dlttq lseq ltq_f pstkq BE{
replace `var' = `var'*cad_usd if curcdq=="CAD"
}

drop cad_usd curcdq

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

* generate MElag Lev LevLag
gen Lev = ltq_f/(ltq_f+ME)
sort cusip jump datadate
by cusip jump: gen MElag = ME[_n-1]
by cusip jump: gen LevLag = Lev[_n-1]

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

* generate ME decile ===========================================================
* drop financial firms, based on https://www.osha.gov/pls/imis/sic_manual.html
destring sic, replace
drop if inrange(sic,6000,6999)

* drop missings
drop if mi(at) | mi(BE) | mi(ME) | mi(Lev) | mi(RET)

* drop data before July 1971, since then, there're at leat 123 firms per month
keep if yyyymm>=197107

* generate DECILE, the size decile markers
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

* ==============================================================================
* Generate variables used for Merton estimation
* ==============================================================================
* generate Debt
gen Debt = ltq_f

* Equity
gen Equity = ME

* merge with monthly volatility calculated with daily returns
merge 1:1 cusip8 yyyymm using "F:/Stephen/auxilary data/monthly_volatility.dta", keepusing(volatility_m n_day)
drop if _merge==2
drop _merge

* --------------------from here, save as F:/Stephen/separate/data_full_final.dta
