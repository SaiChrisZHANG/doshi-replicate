* codes used to produce the analysis, monthly adjusted portfolios, for reference's sake
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* ==============================================================================
* Table 1: Returns by portfolios
* ==============================================================================
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
* Table 3.2 --------------------------------------------------------------------
** mean unlevered excess returns cross-sectionally, average across time series
** monthly adjusted portfolios
preserve
gen RETul = RetExcess*(1-Lev)
gen RETul_intpl = RetExcess*(1-Lev_intpl)

bys datadate QUINTILEmth mth_port_quintile: egen port_11A_ws = total(RETul*ME), missing
bys datadate QUINTILEmth mth_port_quintile: egen port_11A_w = total(ME), missing
gen RETul_11A = port_11A_ws/port_11A_w
drop port_11A_ws

bys datadate QUINTILEmth mth_port_quintile: egen port_11A_ws = total(RETul_intpl*ME), missing
gen RETul_intpl_11A = port_11A_ws/port_11A_w
duplicates drop datadate QUINTILEmth mth_port_quintile, force

bys QUINTILEmth mth_port_quintile: egen portRETul_11A = mean(RETul_11A)
bys QUINTILEmth mth_port_quintile: egen portRETul_intpl_11A = mean(RETul_intpl_11A)
keep QUINTILEmth mth_port_quintile portRETul_11A RETul_11A portRETul_intpl_11A RETul_intpl_11A datadate
drop if mi(QUINTILEmth) | mi(mth_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table3/table2_1A.dta", replace
restore

**** sort by ME
preserve
gen RETul = RetExcess*(1-Lev)
gen RETul_intpl = RetExcess*(1-Lev_intpl)

bys datadate QUINTILEmth: egen port_11B_ws_me = total(RETul*ME), missing
bys datadate QUINTILEmth: egen port_11B_w_me = total(ME), missing
gen RETul_11B_me = port_11B_ws_me/port_11B_w_me
drop port_11B_ws_me

bys datadate QUINTILEmth: egen port_11B_ws_me = total(RETul_intpl*ME), missing
gen RETul_intpl_11B_me = port_11B_ws_me/port_11B_w_me
duplicates drop datadate QUINTILEmth, force

bys QUINTILEmth: egen portRETul_11B_me = mean(RETul_11B_me)
bys QUINTILEmth: egen portRETul_intpl_11B_me = mean(RETul_intpl_11B_me)
keep QUINTILEmth portRETul_11B_me RETul_11B_me portRETul_intpl_11B_me RETul_intpl_11B_me datadate
drop if mi(QUINTILEmth)
save "F:/Stephen/analysis/descriptive study/Table3/table2_1B1.dta", replace
restore

**** sort by BTM
preserve
gen RETul = RetExcess*(1-Lev)
gen RETul_intpl = RetExcess*(1-Lev_intpl)

bys datadate QUINTILEmth_BtM: egen port_11B_ws_btm = total(RETul*ME), missing
bys datadate QUINTILEmth_BtM: egen port_11B_w_btm = total(ME), missing
gen RETul_11B_btm = port_11B_ws_btm/port_11B_w_btm
drop port_11B_ws_btm

bys datadate QUINTILEmth_BtM: egen port_11B_ws_btm = total(RETul_intpl*ME), missing
gen RETul_intpl_11B_btm = port_11B_ws_btm/port_11B_w_btm
duplicates drop datadate QUINTILEmth_BtM, force

bys QUINTILEmth_BtM: egen portRETul_11B_btm = mean(RETul_11B_btm)
bys QUINTILEmth_BtM: egen portRETul_intpl_11B_btm = mean(RETul_intpl_11B_btm)
keep QUINTILEmth_BtM portRETul_11B_btm RETul_11B_btm portRETul_intpl_11B_btm RETul_intpl_11B_btm datadate
drop if mi(QUINTILEmth_BtM)
save "F:/Stephen/analysis/descriptive study/Table3/table2_1B2.dta", replace
restore

* Table 3.4 --------------------------------------------------------------------
** mean unlevered returns + risk-free rate cross-sectionally, average across time series
** monthly adjusted portfolios
preserve
gen RETul = RetExcess*(1-Lev) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-Lev_intpl) + rfFFWebsite

bys datadate QUINTILEmth mth_port_quintile: egen port_11A_ws = total(RETul*ME), missing
bys datadate QUINTILEmth mth_port_quintile: egen port_11A_w = total(ME), missing
gen RETul_11A = port_11A_ws/port_11A_w
drop port_11A_ws

bys datadate QUINTILEmth mth_port_quintile: egen port_11A_ws = total(RETul_intpl*ME), missing
gen RETul_intpl_11A = port_11A_ws/port_11A_w
duplicates drop datadate QUINTILEmth mth_port_quintile, force

bys QUINTILEmth mth_port_quintile: egen portRETul_11A = mean(RETul_11A)
bys QUINTILEmth mth_port_quintile: egen portRETul_intpl_11A = mean(RETul_intpl_11A)
keep QUINTILEmth mth_port_quintile portRETul_11A RETul_11A portRETul_intpl_11A RETul_intpl_11A datadate
drop if mi(QUINTILEmth) | mi(mth_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table3/table4_1A.dta", replace
restore

**** sort by ME
preserve
gen RETul = RetExcess*(1-Lev) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-Lev_intpl) + rfFFWebsite

bys datadate QUINTILEmth: egen port_11B_ws_me = total(RETul*ME), missing
bys datadate QUINTILEmth: egen port_11B_w_me = total(ME), missing
gen RETul_11B_me = port_11B_ws_me/port_11B_w_me
drop port_11B_ws_me

bys datadate QUINTILEmth: egen port_11B_ws_me = total(RETul_intpl*ME), missing
gen RETul_intpl_11B_me = port_11B_ws_me/port_11B_w_me
duplicates drop datadate QUINTILEmth, force

bys QUINTILEmth: egen portRETul_11B_me = mean(RETul_11B_me)
bys QUINTILEmth: egen portRETul_intpl_11B_me = mean(RETul_intpl_11B_me)
keep QUINTILEmth portRETul_11B_me RETul_11B_me portRETul_intpl_11B_me RETul_intpl_11B_me datadate
drop if mi(QUINTILEmth)
save "F:/Stephen/analysis/descriptive study/Table3/table4_1B1.dta", replace
restore

**** sort by BTM
preserve
gen RETul = RetExcess*(1-Lev) + rfFFWebsite
gen RETul_intpl = RetExcess*(1-Lev_intpl) + rfFFWebsite

bys datadate QUINTILEmth_BtM: egen port_11B_ws_btm = total(RETul*ME), missing
bys datadate QUINTILEmth_BtM: egen port_11B_w_btm = total(ME), missing
gen RETul_11B_btm = port_11B_ws_btm/port_11B_w_btm
drop port_11B_ws_btm

bys datadate QUINTILEmth_BtM: egen port_11B_ws_btm = total(RETul_intpl*ME), missing
gen RETul_intpl_11B_btm = port_11B_ws_btm/port_11B_w_btm
duplicates drop datadate QUINTILEmth_BtM, force

bys QUINTILEmth_BtM: egen portRETul_11B_btm = mean(RETul_11B_btm)
bys QUINTILEmth_BtM: egen portRETul_intpl_11B_btm = mean(RETul_intpl_11B_btm)
keep QUINTILEmth_BtM portRETul_11B_btm RETul_11B_btm portRETul_intpl_11B_btm RETul_intpl_11B_btm datadate
drop if mi(QUINTILEmth_BtM)
save "F:/Stephen/analysis/descriptive study/Table3/table4_1B2.dta", replace
restore