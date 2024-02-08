*Set working directory
clear
cd "${user}"

*First Question: Does fracking lead to increased population? 
use "Data\Intermediate\Circles_with_CountyPopulation", clear 

drop if circle_id == .

merge 1:1 circle_id year using "Data\Analysis\CBC_Shale_Combined_Panel_17_5_buffer.dta"
drop if _merge == 1
drop _merge 

replace Min_snow = 0 if Min_snow == .

*Define treatment by first year in which wells were completed
gen wells_year = .
replace wells_year = year if shale_wells_num > 0
bysort circle_id: egen first_well_year = min(wells_year)
replace first_well_year = 0 if first_well_year == .

gen ihs_shalewells = asinh(shale_wells_num)
gen ihs_cumshalewells = asinh(cum_shalewells)

rename inumber_seen_per_counter_w i_number_pc_w
rename itotal_species_manual i_species

*Setup 
set seed 39627236
estimate drop _all 

gen ihs_population = asinh(panel_population)

csdid ihs_population, ivar(circle_id) time(year) gvar(first_well_year) notyet
	estat simple, estore("panel_population")
	
didregress (ihs_population total_effort_counters Min_temp Max_temp Max_wind Max_snow) (ihs_cumshalewells, continuous), group(circle_id) time(year) vce(cluster circle_id)
	
sum panel_population if year == 2000 & first_well_year != 0


********************************************************************************
*Do wind turbines lead to increased population 
 use "Data\Intermediate\Circles_with_CountyPopulation", clear 

drop if circle_id == .

merge 1:1 circle_id year using "Data\Analysis\CBC_Wind_Combined_Panel.dta"
*merge 1:1 circle_id year using "Data\Analysis\CBC_Wind_Combined_Panel_13_5_buffer.dta"
drop if _merge == 1
drop _merge 

replace Min_snow = 0 if Min_snow == .

*Define treatment by first year in which turbines were built (0 if never treated)
gen turbines_year = .
replace turbines_year = year if num_turbines > 0
bysort circle_id: egen first_turbine_year = min(turbines_year)
replace first_turbine_year = 0 if first_turbine_year == .

*Cumulative turbines 
bysort circle_id (year) : gen cum_turbines = sum(num_turbines)
gen ihs_num_turbines = asinh(num_turbines)
gen ihs_cumturbines = asinh(cum_turbines)

rename inumber_seen_per_counter_w i_number_pc_w
rename itotal_species_manual i_species

*Setup 
set seed 39627236
estimate drop _all 

gen ihs_population = asinh(panel_population)

csdid ihs_population, ivar(circle_id) time(year) gvar(first_turbine_year) notyet
	estat simple, estore("panel_population")
	
didregress (ihs_population total_effort_counters Min_temp Max_temp Max_wind Max_snow) (ihs_cumturbines, continuous), group(circle_id) time(year) vce(cluster circle_id)	
	
	
sum panel_population if year == 2000 & first_turbine_year != 0	

********************************************************************************
*Does increased population affect bird populations and species diversity 
use "Data\Intermediate\Circles_with_CountyPopulation", clear 

drop if circle_id == .

merge 1:1 circle_id year using "Data\Analysis\CBC_Shale_Combined_Panel.dta"
drop if _merge == 1
drop _merge 

replace Min_snow = 0 if Min_snow == .

*Define treatment by first year in which wells were completed
gen wells_year = .
replace wells_year = year if shale_wells_num > 0
bysort circle_id: egen first_well_year = min(wells_year)
replace first_well_year = 0 if first_well_year == .

rename inumber_seen_per_counter_w i_number_pc_w
rename itotal_species_manual i_species

*Setup 
set seed 39627236
estimate drop _all 

gen ihs_population = asinh(panel_population)

didregress (inumber_seen_w total_effort_counters Min_temp Max_temp Max_wind Max_snow) (ihs_population, continuous), group(circle_id) time(year) vce(cluster circle_id)

sum number_seen_w if year == 2000 
	