* Cleaning Compustat and CRSP datasets
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* This script merge CRSP data and Compustat data together. 
** CRSP data contains monthly closing prices and return information.
** Compustat data contains quarterly firm balance sheet information.
** for data before 2020, I downloaded data from the data set named CRSP Compustat Merged (CCM)
** for data after 2020, I downloaded data from CRSP and Compustat webpages separately

*===============================================================================
* clean data from CRSP Compustat merged (CCM) to get 2019 and before data
*===============================================================================
* CCM provides data from Jan 1961 to Dec 2019.

cd "F:/Stephen/CMM"

*clean compustat data =================
clear
use compustat
duplicates tag gvkey datadate, generate(dup)
drop if dup>0 & mi(datacqtr)
drop dup

duplicates tag gvkey datadate, generate(dup)
drop if dup>0 & linktype == "LU"
drop dup
save, replace

gen yr = year(datadate)
gen mth = month(datadate)
rename datadate compustat_dt
gen crsp_mth = mth+1
replace crsp_mth=1 if crsp_mth==13
gen crsp_qr = ceil(crsp_mth/3)
gen crsp_yr = yr
replace crsp_yr = yr+1 if mth==12
gen crsp_dt = crsp_yr*100+crsp_mth
drop yr mth crsp_mth crsp_yr

save, replace

* clean CRSP data =====================
clear
use crsp_monthly
gen yr = year(datadate)
gen qr = quarter(datadate)
gen mth = 1 if qr == 1
replace mth = 4 if qr == 2
replace mth = 7 if qr == 3
replace mth = 10 if qr == 4
gen crsp_dt = yr*100+mth
drop yr qr mth
save, replace

* merge them together =================
** compustat.dta is uniquely identified by cusipXcrsp_dt, crsp_dt indicates the subsequent month of compustat reporting month (data reported in June 2016 are marked as July 2016 by crsp_dt).
** crsp_monthly.dta is uniquely identified by cusipXdatadate, crsp_dt indicates the quarters in crsp_monthly.dta

clear
use compustat

merge 1:m cusip crsp_dt using crsp_monthly, keepusing(datadate ajexm ajpm cshoq cshtrm curcdm navm prccm trfm trt1m rawpm rawxm exchg fyrc idbflag naics sic dvpspm dvpsxm dvrate)
keep if _merge==3
drop _merge
label variable crsp_dt "compustat_dt + 1 month"
save merged, replace

sort cusip datadate
by cusip: gen retx = (prccm-prccm[_n-1])/prccm[_n-1]
rename cshtrm vol
rename prccm prc
rename trt1m ret
replace ret = ret/100
drop linktype ggroup gind gsector ajexm ajpm navm curcdm trfm rawpm rawxm fyrc idbflag naics dvpspm dvpsxm dvrate
save "F:/Stephen/part1.dta", replace