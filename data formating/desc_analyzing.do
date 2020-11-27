* codes used to produce the analysis
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* ==============================================================================
* Table 1: Returns by portfolios (Panel A, B)
* ==============================================================================
* Table 1.1.1 ------------------------------------------------------------------
** 5-by-5: Doshi et al 2012
** VALUE weighted returns cross-sectionally, average across time series
** yearly adjusted portfolios
**** double sorting
preserve
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RET*MElag), missing
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_w = total(MElag), missing
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
bys datadate QUINTILEjun: egen port_11B_ws_me = total(RET*MElag), missing
bys datadate QUINTILEjun: egen port_11B_w_me = total(MElag), missing
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
bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RET*MElag), missing
bys datadate QUINTILEdec_BtM: egen port_11B_w_btm = total(MElag), missing
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
** the portfolios are adjusted yearly
** the leverages are monthly updated

preserve 
bys datadate QUINTILEjun FF_port_quintile: egen Lev_12A = mean(Lev)
bys datadate QUINTILEjun FF_port_quintile: egen Levipl_12A = mean(Lev_intpl)
duplicates drop datadate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portLev_12A = mean(Lev_12A)
bys QUINTILEjun FF_port_quintile: egen portLevipl_12A = mean(Levipl_12A)
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

* ==============================================================================
* Table 3: Unlevered Return: the simple way (Panel A, B)
* ==============================================================================
** 5-by-5: Doshi et al 2012
* Table 3.1 --------------------------------------------------------------------
** mean unlevered excess returns + risk-free rate cross-sectionally, average across time series
** R_A = R_E*(1-Lev(t-1))
** for portfolio formed in July t, take leverage in December t-1

preserve
gen RETul = RetExcess*(1-Levdec) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-Levdec_intpl) + rfFFWebsite

bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RETul*MElag), missing
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_w = total(MElag), missing
gen RETul_11A = port_11A_ws/port_11A_w
drop port_11A_ws

bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RETul_intpl*MElag), missing
gen RETul_intpl_11A = port_11A_ws/port_11A_w
duplicates drop datadate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portRETul_11A = mean(RETul_11A)
bys QUINTILEjun FF_port_quintile: egen portRETul_intpl_11A = mean(RETul_intpl_11A)
keep QUINTILEjun FF_port_quintile portRETul_11A RETul_11A portRETul_intpl_11A RETul_intpl_11A datadate
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table3/table3_1A.dta", replace
restore

**** sort by ME
preserve
gen RETul = RetExcess*(1-Levdec) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-Levdec_intpl) + rfFFWebsite

bys datadate QUINTILEjun: egen port_11B_ws_me = total(RETul*MElag), missing
bys datadate QUINTILEjun: egen port_11B_w_me = total(MElag), missing
gen RETul_11B_me = port_11B_ws_me/port_11B_w_me
drop port_11B_ws_me

bys datadate QUINTILEjun: egen port_11B_ws_me = total(RETul_intpl*MElag), missing
gen RETul_intpl_11B_me = port_11B_ws_me/port_11B_w_me
duplicates drop datadate QUINTILEjun, force

bys QUINTILEjun: egen portRETul_11B_me = mean(RETul_11B_me)
bys QUINTILEjun: egen portRETul_intpl_11B_me = mean(RETul_intpl_11B_me)
keep QUINTILEjun portRETul_11B_me RETul_11B_me portRETul_intpl_11B_me RETul_intpl_11B_me datadate
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table3/table3_1B1.dta", replace
restore

**** sort by BTM
preserve
gen RETul = RetExcess*(1-Levdec) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-Levdec_intpl) + rfFFWebsite

bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RETul*MElag), missing
bys datadate QUINTILEdec_BtM: egen port_11B_w_btm = total(MElag), missing
gen RETul_11B_btm = port_11B_ws_btm/port_11B_w_btm
drop port_11B_ws_btm

bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RETul_intpl*MElag), missing
gen RETul_intpl_11B_btm = port_11B_ws_btm/port_11B_w_btm
duplicates drop datadate QUINTILEdec_BtM, force

bys QUINTILEdec_BtM: egen portRETul_11B_btm = mean(RETul_11B_btm)
bys QUINTILEdec_BtM: egen portRETul_intpl_11B_btm = mean(RETul_intpl_11B_btm)
keep QUINTILEdec_BtM portRETul_11B_btm RETul_11B_btm portRETul_intpl_11B_btm RETul_intpl_11B_btm datadate
drop if mi(QUINTILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table3/table3_1B2.dta", replace
restore

** 5-by-5: Doshi et al 2012
* Table 3.2.2 --------------------------------------------------------------------
** mean unlevered excess returns + risk-free rate cross-sectionally, average across time series
** R_A = R_E*(1-Lev(t-1))
** for portfolio formed in Month t, take leverage in Month t-1

preserve
gen RETul = RetExcess*(1-LevLag) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-LevLag_intpl) + rfFFWebsite

bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RETul*MElag), missing
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_w = total(MElag), missing
gen RETul_11A = port_11A_ws/port_11A_w
drop port_11A_ws

bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RETul_intpl*MElag), missing
gen RETul_intpl_11A = port_11A_ws/port_11A_w
duplicates drop datadate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portRETul_11A = mean(RETul_11A)
bys QUINTILEjun FF_port_quintile: egen portRETul_intpl_11A = mean(RETul_intpl_11A)
keep QUINTILEjun FF_port_quintile portRETul_11A RETul_11A portRETul_intpl_11A RETul_intpl_11A datadate
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table3/table3_2A.dta", replace
restore

**** sort by ME
preserve
gen RETul = RetExcess*(1-LevLag) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-LevLag_intpl) + rfFFWebsite

bys datadate QUINTILEjun: egen port_11B_ws_me = total(RETul*MElag), missing
bys datadate QUINTILEjun: egen port_11B_w_me = total(MElag), missing
gen RETul_11B_me = port_11B_ws_me/port_11B_w_me
drop port_11B_ws_me

bys datadate QUINTILEjun: egen port_11B_ws_me = total(RETul_intpl*MElag), missing
gen RETul_intpl_11B_me = port_11B_ws_me/port_11B_w_me
duplicates drop datadate QUINTILEjun, force

bys QUINTILEjun: egen portRETul_11B_me = mean(RETul_11B_me)
bys QUINTILEjun: egen portRETul_intpl_11B_me = mean(RETul_intpl_11B_me)
keep QUINTILEjun portRETul_11B_me RETul_11B_me portRETul_intpl_11B_me RETul_intpl_11B_me datadate
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table3/table3_2B1.dta", replace
restore

**** sort by BTM
preserve
gen RETul = RetExcess*(1-LevLag) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-LevLag_intpl) + rfFFWebsite

bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RETul*MElag), missing
bys datadate QUINTILEdec_BtM: egen port_11B_w_btm = total(MElag), missing
gen RETul_11B_btm = port_11B_ws_btm/port_11B_w_btm
drop port_11B_ws_btm

bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RETul_intpl*MElag), missing
gen RETul_intpl_11B_btm = port_11B_ws_btm/port_11B_w_btm
duplicates drop datadate QUINTILEdec_BtM, force

bys QUINTILEdec_BtM: egen portRETul_11B_btm = mean(RETul_11B_btm)
bys QUINTILEdec_BtM: egen portRETul_intpl_11B_btm = mean(RETul_intpl_11B_btm)
keep QUINTILEdec_BtM portRETul_11B_btm RETul_11B_btm portRETul_intpl_11B_btm RETul_intpl_11B_btm datadate
drop if mi(QUINTILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table3/table3_2B2.dta", replace
restore
