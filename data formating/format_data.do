* Format merged dataset
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* This script cleans the data set for further analysis, the data will be formatted according to the matlab/python codes that run the main analysis.

*===============================================================================
* Clean variables: direct analysis
*===============================================================================

* load dataset
clear
cd "F:/Stephen"
use full_data 
* merge the share adjustment factor
merge m:1 gvkey compustat_dt using "F:/Stephen/auxilary data/share_adjust.dta"
drop if _merge==2
drop _merge

* drop unused variables of interest
drop cshiq dd1q crsp_dt vol lltq ibq npq pstkrq teqq txdbq txdiq txditcq costat dvpq fyearq fqtr

* date variables
gen yyyymm = 100*year(datadate)+month(datadate)

gen DecDate = 100*(year(datadate)-1)+12 if month(datadate)<=12 & month(datadate)>=7
replace DecDate = 100*(year(datadate)-2)+12 if month(datadate)<=6 & month(datadate)>=1
* merge by compustat_dt

gen Fq4Date = string(year(datadate)-1)+"Q4" if month(datadate)<=12 & month(datadate)>=7
replace Fq4Date = string(year(datadate)-2)+"Q4" if month(datadate)<=6 & month(datadate)>=1
* merge by year(compustat_dt)+substr(datafqtr,5,6), see gvkey==64418 for the most dramatic example

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

/*
Variables:
'PERMNO': Perm number from CRSP
'yyyymm': Four digit year(yyyy) + two digit month format of date (mm)
'RET': Stock return
'BE': Book equity, from fiscal year end in the previous calendar year (t-1). Held constant from July of year t to June of t+1 year 
'at': Book assets, same as BE for prepartion
'PRC': Price from Crsp, use absolute when computing market equity
'ltq_f': Total Liabilities, held constant over a quarter
'exchg': Exchange id from Compustat to decide whether the firm is listed on NYSE or not 
'Equity: Market equity

'DECILE': Size decile portfolio already computed
'rfFFWebsite': risk-free rate from Kenneth French's Website

'me': Market equity
'meLag': Lagged market equity, one lag needed to compute value-weighting
'mejun': Market equity in the June and held as it is from July to June of the following year 
'medec': Market equity in December, held as it is from July to June, for example 199212 market equity is held same from 199307 to 199406

'DecDate': December date that needs to be used to assign medec and others such as BE and AT
'RetExcess': Excess Stock Return, RET - rfFFWebsite
'Lev': Leverage measured as ltq_f/(ltq_f + me)
'LevLag': Lagged Leverage, one lag neeeded to compute the adjusted returns
*/

*===============================================================================
* Clean variables: used for Merton estimation
*===============================================================================
/*
'AssetValue': The unlevered equity value obtained from the Merton model, baseline specification of Table 4
'AssetValueLag': Lagged unlevered equity value, one lag
'AssetVolatility': The unlevered equity volatility obtained from the Merton model, baseline specification of Table 4 
'dlcq': debt in current liabilities used to compute total debt, which is used as face value of debt in one of the specification of Merton model 
'dlttq': Long term debt used to compute total debt, which is used as face value of debt in one of the specification of Merton model
'Debt': Total Liabilities, same as d.ltq_f

Not know yet -------------------------------------------------------------------
'EquityVolatility': Annualized stock volatility 
'rf338': risk-free rate (annualized) for debt maturity 3.38 years used only in the estimation of merton model, need to change for other assumptions of debt maturity
*/

clear
cd "F:/Stephen"
