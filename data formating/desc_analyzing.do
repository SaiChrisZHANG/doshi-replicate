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
duplicates drop datadate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portRET_11A = mean(RET_11A)
keep QUINTILEjun FF_port_quintile portRET_11A RET_11A datadate
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1A.dta", replace
restore

**** sort by ME
preserve
bys datadate QUINTILEjun: egen port_11B_ws_me = total(RET*ME), missing
bys datadate QUINTILEjun: egen port_11B_w_me = total(ME), missing
gen RET_11B_me = port_11B_ws_me/port_11B_w_me
duplicates drop datadate QUINTILEjun, force

bys QUINTILEjun: egen portRET_11B_me = mean(RET_11B_me)
keep QUINTILEjun portRET_11B_me RET_11B_me datadate
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RET*ME), missing
bys datadate QUINTILEdec_BtM: egen port_11B_w_btm = total(ME), missing
gen RET_11B_btm = port_11B_ws_btm/port_11B_w_btm
duplicates drop datadate QUINTILEdec_BtM, force

bys QUINTILEdec_BtM: egen portRET_11B_btm = mean(RET_11B_btm)
keep QUINTILEdec_BtM portRET_11B_btm RET_11B_btm datadate
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
duplicates drop datadate DECILEjun FF_port_decile, force

bys DECILEjun FF_port_decile: egen portRET_12A = mean(RET_12A)
keep DECILEjun FF_port_decile portRET_12A RET_12A datadate
drop if mi(DECILEjun) | mi(FF_port_decile)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2A.dta", replace
restore

**** sort by ME
preserve
bys datadate DECILEjun: egen RET_12B_me = mean(RET)
duplicates drop datadate DECILEjun, force

bys DECILEjun: egen portRET_12B_me = mean(RET_12B_me)
keep DECILEjun portRET_12B_me RET_12B_me datadate
drop if mi(DECILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate DECILEdec_BtM: egen RET_12B_btm = mean(RET)
duplicates drop datadate DECILEdec_BtM, force

bys DECILEdec_BtM: egen portRET_12B_btm = mean(RET_12B_btm)
keep DECILEdec_BtM portRET_12B_btm RET_12B_btm datadate
drop if mi(DECILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2B2.dta", replace
restore

* Table 1.2.1 ------------------------------------------------------------------
** 5-by-5: Doshi et al 2012
** VALUE weighted returns cross-sectionally, average across time series
** yearly adjusted portfolios
**** double sorting
preserve
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RET*ME), missing
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_w = total(ME), missing
gen RET_11A = port_11A_ws/port_11A_w
duplicates drop datadate QUINTILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portRET_11A = mean(RET_11A)
keep QUINTILEjun FF_port_quintile portRET_11A RET_11A datadate
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1A.dta", replace
restore

**** sort by ME
preserve
bys datadate QUINTILEjun: egen port_11B_ws_me = total(RET*ME), missing
bys datadate QUINTILEjun: egen port_11B_w_me = total(ME), missing
gen RET_11B_me = port_11B_ws_me/port_11B_w_me
duplicates drop datadate QUINTILEjun, force

bys QUINTILEjun: egen portRET_11B_me = mean(RET_11B_me)
keep QUINTILEjun portRET_11B_me RET_11B_me datadate
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate QUINTILEdec_BtM: egen port_11B_ws_btm = total(RET*ME), missing
bys datadate QUINTILEdec_BtM: egen port_11B_w_btm = total(ME), missing
gen RET_11B_btm = port_11B_ws_btm/port_11B_w_btm
duplicates drop datadate QUINTILEdec_BtM, force

bys QUINTILEdec_BtM: egen portRET_11B_btm = mean(RET_11B_btm)
keep QUINTILEdec_BtM portRET_11B_btm RET_11B_btm datadate
drop if mi(QUINTILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1B2.dta", replace
restore

* Table 1.2.2 ------------------------------------------------------------------
** 10-by-10: Fama and French 1992
** EQUAL weighted returns cross-sectionally, average across time series
** yearly adjusted portfolios
**** double sorting
preserve
bys datadate DECILEjun FF_port_decile: egen RET_12A = mean(RET)
duplicates drop datadate DECILEjun FF_port_decile, force

bys DECILEjun FF_port_decile: egen portRET_12A = mean(RET_12A)
keep DECILEjun FF_port_decile portRET_12A RET_12A datadate
drop if mi(DECILEjun) | mi(FF_port_decile)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2A.dta", replace
restore

**** sort by ME
preserve
bys datadate DECILEjun: egen RET_12B_me = mean(RET)
duplicates drop datadate DECILEjun, force

bys DECILEjun: egen portRET_12B_me = mean(RET_12B_me)
keep DECILEjun portRET_12B_me RET_12B_me datadate
drop if mi(DECILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2B1.dta", replace
restore

**** sort by BTM
preserve
bys datadate DECILEdec_BtM: egen RET_12B_btm = mean(RET)
duplicates drop datadate DECILEdec_BtM, force

bys DECILEdec_BtM: egen portRET_12B_btm = mean(RET_12B_btm)
keep DECILEdec_BtM portRET_12B_btm RET_12B_btm datadate
drop if mi(DECILEdec_BtM)
save "F:/Stephen/analysis/descriptive study/Table1/table1_2B2.dta", replace
restore