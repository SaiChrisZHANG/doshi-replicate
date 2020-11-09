* codes used to produce the analysis
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* ==============================================================================
* Table 1: Returns by portfolios
* ==============================================================================
* Table 1.1.1 ------------------------------------------------------------------
** 5-by-5: Doshi et al 2012
** VALUE weighted returns cross-sectionally, average across time series
** yearly adjusted portfolios
**** double sorting
preserve
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RET*ME), missing
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_w = total(ME), missing
gen RET_11A = port_11A_ws/port_11A_w
gen RETex_11A = RET_11A - rfFFWebsite
duplicates drop datadate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portRET_11A = mean(RET_11A)
bys QUINTILEjun FF_port_quintile: egen portRETex_11A = mean(RETex_11A)
keep QUINTILEjun FF_port_quintile portRET_11A RET_11A portRETex_11A RETex_11A datadate
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1A.dta", replace
restore

**** sort by ME
preserve
bys datadate QUINTILEjun: egen port_11B_ws_me = total(RET*ME), missing
bys datadate QUINTILEjun: egen port_11B_w_me = total(ME), missing
gen RET_11B_me = port_11B_ws_me/port_11B_w_me
gen RETex_11B_me = RET_11B_me - rfFFWebsite
duplicates drop datadate QUINTILEjun, force

bys QUINTILEjun: egen portRET_11B_me = mean(RET_11B_me)
bys QUINTILEjun: egen portRETex_11B_me = mean(RETex_11B_me)
keep QUINTILEjun portRET_11B_me RET_11B_me portRETex_11B_me RETex_11B_me datadate
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RET*ME), missing
bys datadate QUINTILEdec_BtM: egen port_11B_w_btm = total(ME), missing
gen RET_11B_btm = port_11B_ws_btm/port_11B_w_btm
gen RETex_11B_btm = RET_11B_btm - rfFFWebsite
duplicates drop datadate QUINTILEdec_BtM, force

bys QUINTILEdec_BtM: egen portRET_11B_btm = mean(RET_11B_btm)
bys QUINTILEdec_BtM: egen portRETex_11B_btm = mean(RETex_11B_btm)
keep QUINTILEdec_BtM portRET_11B_btm RET_11B_btm portRETex_11B_btm RETex_11B_btm datadate
drop if mi(QUINTILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1B2.dta", replace
restore

* Table 1.1.2 ------------------------------------------------------------------
** 10-by-10: Fama and French 1992
** EQUAL weighted returns cross-sectionally, average across time series
** yearly adjusted portfolios
**** double sorting
preserve
bys datadate DECILEjun FF_port_decile: egen RET_12A = mean(RET)
gen RETex_12A = RET_12A - rfFFWebsite
duplicates drop datadate DECILEjun FF_port_decile, force

bys DECILEjun FF_port_decile: egen portRET_12A = mean(RET_12A)
bys DECILEjun FF_port_decile: egen portRETex_12A = mean(RETex_12A)
keep DECILEjun FF_port_decile portRET_12A RET_12A portRETex_12A RETex_12A datadate
drop if mi(DECILEjun) | mi(FF_port_decile)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2A.dta", replace
restore

**** sort by ME
preserve
bys datadate DECILEjun: egen RET_12B_me = mean(RET)
gen RETex_12B_me = RET_12B_me - rfFFWebsite
duplicates drop datadate DECILEjun, force

bys DECILEjun: egen portRET_12B_me = mean(RET_12B_me)
bys DECILEjun: egen portRETex_12B_me = mean(RETex_12B_me)
keep DECILEjun portRET_12B_me RET_12B_me portRETex_12B_me RETex_12B_me datadate
drop if mi(DECILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate DECILEdec_BtM: egen RET_12B_btm = mean(RET)
gen RETex_12B_btm = RET_12B_btm - rfFFWebsite
duplicates drop datadate DECILEdec_BtM, force

bys DECILEdec_BtM: egen portRET_12B_btm = mean(RET_12B_btm)
bys DECILEdec_BtM: egen portRETex_12B_btm = mean(RETex_12B_btm)
keep DECILEdec_BtM portRET_12B_btm RET_12B_btm portRETex_12B_btm RETex_12B_btm datadate
drop if mi(DECILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2B2.dta", replace
restore

* Table 1.2.1 ------------------------------------------------------------------
** 5-by-5: Doshi et al 2012
** VALUE weighted returns cross-sectionally, average across time series
** monthly adjusted portfolios
**** double sorting
preserve
bys datadate QUINTILEmth mth_port_quintile: egen port_21A_ws = total(RET*ME), missing
bys datadate QUINTILEmth mth_port_quintile: egen port_21A_w = total(ME), missing
gen RET_21A = port_21A_ws/port_21A_w
gen RETex_21A = RET_21A - rfFFWebsite
duplicates drop datadate QUINTILEmth mth_port_quintile, force

bys QUINTILEmth mth_port_quintile: egen portRET_21A = mean(RET_21A)
bys QUINTILEmth mth_port_quintile: egen portRETex_21A = mean(RETex_21A)
keep QUINTILEmth mth_port_quintile portRET_21A RET_21A portRETex_21A RETex_21A datadate
drop if mi(QUINTILEmth) | mi(mth_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table1/table2_1A.dta", replace
restore

**** sort by ME
preserve
bys datadate QUINTILEmth: egen port_21B_ws_me = total(RET*ME), missing
bys datadate QUINTILEmth: egen port_21B_w_me = total(ME), missing
gen RET_21B_me = port_21B_ws_me/port_21B_w_me
gen RETex_21B_me = RET_21B_me - rfFFWebsite
duplicates drop datadate QUINTILEmth, force

bys QUINTILEmth: egen portRET_21B_me = mean(RET_21B_me)
bys QUINTILEmth: egen portRETex_21B_me = mean(RETex_21B_me)
keep QUINTILEmth portRET_21B_me RET_21B_me portRETex_21B_me RETex_21B_me datadate
drop if mi(QUINTILEmth)
save "F:/Stephen/analysis/descriptive study/Table1/table2_1B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate QUINTILEmth_BtM: egen port_21B_ws_btm = total(RET*ME), missing
bys datadate QUINTILEmth_BtM: egen port_21B_w_btm = total(ME), missing
gen RET_21B_btm = port_21B_ws_btm/port_21B_w_btm
gen RETex_21B_btm = RET_21B_btm - rfFFWebsite
duplicates drop datadate QUINTILEmth_BtM, force

bys QUINTILEmth_BtM: egen portRET_21B_btm = mean(RET_21B_btm)
bys QUINTILEmth_BtM: egen portRETex_21B_btm = mean(RETex_21B_btm)
keep QUINTILEmth_BtM portRET_21B_btm RET_21B_btm portRETex_21B_btm RETex_21B_btm datadate
drop if mi(QUINTILEmth_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table2_1B2.dta", replace
restore

* Table 1.2.2 ------------------------------------------------------------------
** 10-by-10: Fama and French 1992
** EQUAL weighted returns cross-sectionally, average across time series
** monthly adjusted portfolios
**** double sorting
preserve
bys datadate DECILEmth mth_port_decile: egen RET_22A = mean(RET)
gen RETex_22A = RET_22A - rfFFWebsite
duplicates drop datadate DECILEmth mth_port_decile, force

bys DECILEmth mth_port_decile: egen portRET_22A = mean(RET_22A)
bys DECILEmth mth_port_decile: egen portRETex_22A = mean(RETex_22A)
keep DECILEmth mth_port_decile portRET_22A RET_22A portRETex_22A RETex_22A datadate
drop if mi(DECILEmth) | mi(mth_port_decile)
save "F:/Stephen/analysis/descriptive study/Table1/table2_2A.dta", replace
restore

**** sort by ME
preserve
bys datadate DECILEmth: egen RET_22B_me = mean(RET)
gen RETex_22B_me = RET_22B_me - rfFFWebsite
duplicates drop datadate DECILEmth, force

bys DECILEmth: egen portRET_22B_me = mean(RET_22B_me)
bys DECILEmth: egen portRETex_22B_me = mean(RETex_22B_me)
keep DECILEmth portRET_22B_me RET_22B_me portRETex_22B_me RETex_22B_me datadate
drop if mi(DECILEmth)
save "F:/Stephen/analysis/descriptive study/Table1/table2_2B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate DECILEmth_BtM: egen RET_22B_btm = mean(RET)
gen RETex_22B_btm = RET_22B_btm - rfFFWebsite
duplicates drop datadate DECILEmth_BtM, force

bys DECILEmth_BtM: egen portRET_22B_btm = mean(RET_22B_btm)
bys DECILEmth_BtM: egen portRETex_22B_btm = mean(RETex_22B_btm)
keep DECILEmth_BtM portRET_22B_btm RET_22B_btm portRETex_22B_btm RETex_22B_btm datadate
drop if mi(DECILEmth_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table2_2B2.dta", replace
restore

* ==============================================================================
* Table 2: Leverage
* ==============================================================================
* Table 2.1 ------------------------------------------------------------------
** 5-by-5: Doshi et al 2012
** mean leverage cross-sectionally, average across time series
** for portfolio formed in July t, take leverage in December t-1

**** double sorting
preserve 
duplicates drop cusip DecDate, force 

bys DecDate QUINTILEjun FF_port_quintile: egen Lev_11A = mean(Levdec)
bys DecDate QUINTILEjun FF_port_quintile: egen Levipl_11A = mean(Levdec_intpl)
duplicates drop DecDate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portLev_11A = mean(Lev_11A)
bys QUINTILEjun FF_port_quintile: egen portLevipl_11A = mean(Levipl_11A)
keep QUINTILEjun FF_port_quintile Lev_11A Levipl_11A portLev_11A portLevipl_11A DecDate
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table2/table1_1A.dta", replace
restore

**** sort by ME
preserve
duplicates drop cusip DecDate, force
bys DecDate QUINTILEjun: egen Lev_11B_me = mean(Levdec)
bys DecDate QUINTILEjun: egen Levipl_11B_me = mean(Levdec_intpl)
duplicates drop DecDate QUINTILEjun, force

bys QUINTILEjun: egen portLev_11B_me = mean(Lev_11B_me)
bys QUINTILEjun: egen portLevipl_11B_me = mean(Levipl_11B_me)
keep QUINTILEjun Lev_11B_me Levipl_11B_me portLev_11B_me portLevipl_11B_me DecDate
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table2/table1_1B1.dta", replace
restore

**** sort by BTM
preserve
duplicates drop cusip DecDate, force
bys DecDate QUINTILEdec_BtM: egen Lev_11B_btm = mean(Levdec)
bys DecDate QUINTILEdec_BtM: egen Levipl_11B_btm = mean(Levdec_intpl)
duplicates drop DecDate QUINTILEdec_BtM, force

bys QUINTILEdec_BtM: egen portLev_11B_btm = mean(Lev_11B_btm)
bys QUINTILEdec_BtM: egen portLevipl_11B_btm = mean(Levipl_11B_btm)
keep QUINTILEdec_BtM Lev_11B_btm Levipl_11B_btm portLev_11B_btm portLevipl_11B_btm DecDate
drop if mi(QUINTILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table2/table1_1B2.dta", replace
restore

* Table 2.2 ------------------------------------------------------------------
** 5-by-5: Doshi et al 2012
** mean leverage cross-sectionally, average across time series
** for monthly portfolio, take leverage of the previous month
preserve 
bys datadate QUINTILEmth mth_port_quintile: egen Lev_12A = mean(Lev)
bys datadate QUINTILEmth mth_port_quintile: egen Levipl_12A = mean(Lev_intpl)
duplicates drop datadate QUINTILEmth mth_port_quintile, force

bys QUINTILEmth mth_port_quintile: egen portLev_12A = mean(Lev_12A)
bys QUINTILEmth mth_port_quintile: egen portLevipl_12A = mean(Levipl_12A)
keep QUINTILEmth mth_port_quintile Lev_12A Levipl_12A portLev_12A portLevipl_12A datadate
drop if mi(QUINTILEmth) | mi(mth_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table2/table1_2A.dta", replace
restore

**** sort by ME
preserve
bys datadate QUINTILEmth: egen Lev_12B_me = mean(Lev)
bys datadate QUINTILEmth: egen Levipl_12B_me = mean(Lev_intpl)
duplicates drop datadate QUINTILEmth, force

bys QUINTILEmth: egen portLev_12B_me = mean(Lev_12B_me)
bys QUINTILEmth: egen portLevipl_12B_me = mean(Levipl_12B_me)
keep QUINTILEmth Lev_12B_me Levipl_12B_me portLev_12B_me portLevipl_12B_me datadate
drop if mi(QUINTILEmth)
save "F:/Stephen/analysis/descriptive study/Table2/table1_2B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate QUINTILEmth_BtM: egen Lev_12B_btm = mean(Lev)
bys datadate QUINTILEmth_BtM: egen Levipl_12B_btm = mean(Lev_intpl)
duplicates drop datadate QUINTILEmth_BtM, force

bys QUINTILEmth_BtM: egen portLev_12B_btm = mean(Lev_12B_btm)
bys QUINTILEmth_BtM: egen portLevipl_12B_btm = mean(Levipl_12B_btm)
keep QUINTILEmth_BtM Lev_12B_btm Levipl_12B_btm portLev_12B_btm portLevipl_12B_btm datadate
drop if mi(QUINTILEmth_BtM)
save "F:/Stephen/analysis/descriptive study/Table2/table1_2B2.dta", replace
restore

* ==============================================================================
* Table 3: Unlevered Return: the simple way
* ==============================================================================
** 5-by-5: Doshi et al 2012
* Table 3.1 --------------------------------------------------------------------
** mean unlevered returns cross-sectionally, average across time series
** R_A = R_E*(1-Lev(t-1)), 
** for portfolio formed in July t, take leverage in December t-1

preserve
gen RETul = RetExcess*(1-Levdec)
gen RETul_intpl = RetExcess*(1-Levdec_intpl)

bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RETul*ME), missing
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_w = total(ME), missing
gen RETul_11A = port_11A_ws/port_11A_w
drop port_11A_ws

bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RETul_intpl*ME), missing
gen RETul_intpl_11A = port_11A_ws/port_11A_w
duplicates drop datadate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portRETul_11A = mean(RETul_11A)
bys QUINTILEjun FF_port_quintile: egen portRETul_intpl_11A = mean(RETul_intpl_11A)
keep QUINTILEjun FF_port_quintile portRETul_11A RETul_11A portRETul_intpl_11A RETul_intpl_11A datadate
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table3/table1_1A.dta", replace
restore

**** sort by ME
preserve
gen RETul = RetExcess*(1-Lev)
gen RETul_intpl = RetExcess*(1-Levdec_intpl)

bys datadate QUINTILEjun: egen port_11B_ws_me = total(RETul*ME), missing
bys datadate QUINTILEjun: egen port_11B_w_me = total(ME), missing
gen RETul_11B_me = port_11B_ws_me/port_11B_w_me
drop port_11B_ws_me

bys datadate QUINTILEjun: egen port_11B_ws_me = total(RETul_intpl*ME), missing
gen RETul_intpl_11B_me = port_11B_ws_me/port_11B_w_me
duplicates drop datadate QUINTILEjun, force

bys QUINTILEjun: egen portRETul_11B_me = mean(RETul_11B_me)
bys QUINTILEjun: egen portRETul_intpl_11B_me = mean(RETul_intpl_11B_me)
keep QUINTILEjun portRETul_11B_me RETul_11B_me portRETul_intpl_11B_me RETul_intpl_11B_me datadate
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table3/table1_1B1.dta", replace
restore

**** sort by BTM
preserve
gen RETul = RetExcess*(1-Lev)
gen RETul_intpl = RetExcess*(1-Levdec_intpl)

bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RETul*ME), missing
bys datadate QUINTILEdec_BtM: egen port_11B_w_btm = total(ME), missing
gen RETul_11B_btm = port_11B_ws_btm/port_11B_w_btm
drop port_11B_ws_btm

bys datadate QUINTILEjun: egen port_11B_ws_btm = total(RETul_intpl*ME), missing
gen RETul_intpl_11B_btm = port_11B_ws_btm/port_11B_w_btm
duplicates drop datadate QUINTILEdec_BtM, force

bys QUINTILEdec_BtM: egen portRET_11B_btm = mean(RET_11B_btm)
bys QUINTILEdec_BtM: egen portRETex_11B_btm = mean(RETex_11B_btm)
keep QUINTILEdec_BtM portRET_11B_btm RET_11B_btm portRETex_11B_btm RETex_11B_btm datadate
drop if mi(QUINTILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1B2.dta", replace
restore

* Table 3.2 --------------------------------------------------------------------
** mean unlevered returns cross-sectionally, average across time series
** monthly adjusted portfolios