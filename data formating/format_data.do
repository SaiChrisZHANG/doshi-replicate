* Format merged dataset
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* This script cleans the data set for further analysis, the

/*
Variables:
'PERMNO': Perm number from CRSP, use cusip instead
'yyyymm': Four digit year(yyyy) + two digit month format of date (mm)
'RET': Stock return
'BE': Book equity, from fiscal year end in the previous calendar year (t-1). Held constant from July of year t to June of t+1 year 
'at': Book assets, same as BE for prepartion
'me': Market equity
'meLag': Lagged market equity, one lag needed to compute value-weighting
'PRC': Price from Crsp, use absolute when computing market equity
'mejun': Market equity in the June and held as it is from July to June of the following year 
'medec': Market equity in December, held as it is from July to June, for example 199212 market equity is held same from 199307 to 199406
'DECILE': Size decile portfolio already computed
'DecDate': December date that needs to be used to assign medec and others such as BE and AT
'ltq_f': Total Liabilities, held constant over a quarter
'rfFFWebsite': risk-free rate from Kenneth French's Website
'RetExcess': Excess Stock Return, RET - rfFFWebsite
'Lev': Leverage measured as ltq_f/(ltq_f + me)
'EXCHCD': Exchange id from Crsp to decide whether the firm is listed on NYSE or not
'Equity: Market equity
'LevLag': Lagged Leverage, one lag neeeded to compute the adjusted returns

Used in Merton estimation ------------------------------------------------------
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

