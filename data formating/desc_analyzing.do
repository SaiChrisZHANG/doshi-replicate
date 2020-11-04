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
bys datadate QUINTILEjun FF_port_quintile: egen portret_11A = total(RET*ME)/total(ME)
bys datadate 