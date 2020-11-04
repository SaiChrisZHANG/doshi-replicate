* codes used to produce the analysis
* Author: Sai Zhang (saizhang@london.edu)
* This project is prepared for the project of Prof. Stephen Schaefer

* ==============================================================================
* Table 1: Returns by portfolios
* ==============================================================================

* Table 1.1 A ------------------------------------------------------------------
** 5-by-5
** value weighted returns cross-sectionally, average across time series
** yearly adjusted portfolios
**** double sorting
preserve
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_ws = total(RET*ME), missing
bys datadate QUINTILEjun FF_port_quintile: egen port_11A_w = total(ME), missing
gen RET_11A = port_11A_ws/port_11A_w
duplicates drop datadate QUITILEjun FF_port_quintile, force

bys QUINTILEjun FF_port_quintile: egen portRET_11A = mean(RET_11A)
duplicates drop QUITILEjun FF_port_quintile, force

keep QUINTILEjun FF_port_quintile portRET_11A
drop if mi(QUINTILEjun) | mi(FF_port_quintile)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1A.dta", replace
restore

**** sort by ME
preserve
bys datadate QUINTILEjun: egen port_11A_ws_me = total(RET*ME), missing
bys datadate QUINTILEjun: egen port_11A_w_me = total(ME), missing
gen RET_11A_me = port_11A_ws_me/port_11A_w_me
duplicates drop datadate QUITILEjun, force

bys QUINTILEjun: egen portRET_11A = mean(RET_11A)
duplicates drop QUITILEjun, force

keep QUINTILEjun portRET_11A
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1A.dta", replace
restore

**** sort by BTM
preserve
bys datadate QU: egen port_11A_ws_me = total(RET*ME), missing
bys datadate QUINTILEjun: egen port_11A_w_me = total(ME), missing
gen RET_11A_me = port_11A_ws_me/port_11A_w_me
duplicates drop datadate QUITILEjun, force

bys QUINTILEjun: egen portRET_11A = mean(RET_11A)
duplicates drop QUITILEjun, force

keep QUINTILEjun portRET_11A
drop if mi(QUINTILEjun)
save "F:/Stephen/analysis/descriptive study/Table1/table1_1A.dta", replace
restore 
