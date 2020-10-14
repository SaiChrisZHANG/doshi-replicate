* formatting the dataset from sraightly merging
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

clear
cd "F:/Stephen/separate"

*===============================================================================
* Clean the merged dataset
*===============================================================================
use merged

* keep NYSE/AMEX/Nasdaq
keep if exchcd == 1 | exchcd == 2 | exchcd == 3

drop tic ajpq datacqtr cshiq dd1q dvpq ibq lltq npq pstkrq teqq txdbq txdiq txditcq costat permno primexch _merge

gen yyyymm = 100*year(datadate) + month(datadate)

gen DecDate = 100*(year(datadate)-1)+12 if month(datadate)<=12 & month(datadate)>=7
replace DecDate = 100*(year(datadate)-2)+12 if month(datadate)<=6 & month(datadate)>=1

gen Fq4Date = string(year(datadate)-1)+"Q4" if month(datadate)<=12 & month(datadate)>=7
replace Fq4Date = string(year(datadate)-2)+"Q4" if month(datadate)<=6 & month(datadate)>=1

gen JunDate = 100*(year(datadate)-1)+6 if month(datadate)<=12 & month(datadate)>=7
replace JunDate = 100*(year(datadate)-2)+6 if month(datadate)<=6 & month(datadate)>=1