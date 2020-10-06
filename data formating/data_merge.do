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

merge 1:m cusip crsp_dt using crsp_monthly, keepusing(datadate cshtrm prccm trt1m exchg sic)
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
drop linktype ggroup gind gsector
save "F:/Stephen/part1.dta", replace

*===============================================================================
* clean data from CRSP and Compustat, separately, to get 2020 data
*===============================================================================

cd "F:/Stephen/separate"

* clean data from CRSP and Compustat, separately, Compustat data are updated to Sep 2020, CRSP data are updated to Jun 2020.

* clean Compustat data ================
clear
use compustat_big
duplicates tag cusip datadate, gen(dup_cusip)
drop if mi(cusip)
drop if dup_cusip==1 & mi(datacqtr)
drop dup_cusip
duplicates report cusip datadate /*should be non-duplicates*/

gen yr = year(datadate)
gen mth = month(datadate)
rename datadate compustat_dt
gen crsp_mth = mth+1
replace crsp_mth=1 if crsp_mth==13
gen crsp_qr = ceil(crsp_mth/3)
gen crsp_yr = yr
replace crsp_yr = yr+1 if mth==12
gen crsp_dt = crsp_yr*100+crsp_mth
drop yr mth crsp_mth crsp_qr crsp_yr

save, replace

* clean CRSP data =====================
clear
use crsp_big
duplicates drop cusip datadate, force
keep if shrcd == 10 | shrcd==11
* following information listed on Kenneth French's website, limit to common shares, other information saved in crsp_other.dta

* keep if exchcd == 1 | exchcd == 2 | exchcd == 3
* limit to NYSE, AMEX, Nasdaq
rename cusip cusip8

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
clear
use compustat_big
*gen cusip8 = substr(cusip,1,8)

merge 1:m cusip8 crsp_dt using crsp_big, keepusing(datadate prc vol ret retx crsp_dt)
keep if _merge==3 & year(datadate)==2020

drop _merge ajexq ajpq cusip8 merge_compustat_crsp tic
destring gvkey, replace
save "F:/Stephen/part2.dta", replace

*===============================================================================
* Put part 1 (data before 2020) and part 2 (data in 2020) together
*===============================================================================
clear
use "F:/Stephen/part1.dta", replace
append using "F:/Stephen/part2.dta"
sort cusip datadate
save full_data, replace
clear