*Set working directory
clear
cd "${user}"

*********************************************************************************
*Import shale data 

use "Data\Analysis\CBC_Shale_Combined_Panel_17_5_buffer.dta", clear 

gen has_wells = 0
replace has_wells = 1 if cum_shalewells > 0

gen total_counter = 1

*Collapse to year level 
collapse (sum) has_wells total_counter, by(year)

gen wells_share = (has_wells / total_counter)*100

save "Data\Analysis\Wells_Descriptives_17_5.dta", replace 


*********************************************************************************
*Import wind data 

use "Data\Analysis\CBC_Wind_Combined_Panel_17_5_buffer.dta", clear

*Create outcome = presence of turbines 
bysort circle_id (year) : gen cum_turbines = sum(num_turbines)

gen turbines_present = 0
replace turbines_present = 1 if cum_turbines > 0

gen total_counter = 1

*Collapse to year level 
collapse (sum) turbines_present total_counter, by(year)

gen turbine_share = (turbines_present / total_counter)*100

save "Data\Analysis\Turbines_Descriptives_17_5.dta", replace 

*********************************************************************************
*Repeat for 12.5 regions 

use "Data\Analysis\CBC_Shale_Combined_Panel_12_5_buffer.dta", clear 

gen has_wells_12_5 = 0
replace has_wells_12_5 = 1 if cum_shalewells > 0

gen total_counter = 1

collapse (sum) has_wells_12_5 total_counter, by(year)

gen wells_share_12_5 = (has_wells_12_5 / total_counter)*100

save "Data\Analysis\Wells_Descriptives_12_5.dta", replace 

use "Data\Analysis\CBC_Wind_Combined_Panel_12_5_buffer.dta", clear

bysort circle_id (year) : gen cum_turbines = sum(num_turbines)

gen turbines_present_12_5 = 0
replace turbines_present_12_5 = 1 if cum_turbines > 0

gen total_counter = 1

collapse (sum) turbines_present_12_5 total_counter, by(year)

gen turbine_share_12_5 = (turbines_present_12_5 / total_counter)*100

save "Data\Analysis\Turbines_Descriptives_12_5.dta", replace 



*********************************************************************************
*Repeat for Voronoi regions 

use "Data\Analysis\CBC_Shale_Combined_Panel.dta", clear 

gen has_wells_voronoi = 0
replace has_wells_voronoi = 1 if cum_shalewells > 0

gen total_counter = 1

collapse (sum) has_wells_voronoi total_counter, by(year)

gen wells_share_voronoi = (has_wells_voronoi / total_counter)*100

save "Data\Analysis\Wells_Descriptives.dta", replace 

use "Data\Analysis\CBC_Wind_Combined_Panel.dta", clear

bysort circle_id (year) : gen cum_turbines = sum(num_turbines)

gen turbines_present_voronoi = 0
replace turbines_present_voronoi = 1 if cum_turbines > 0

gen total_counter = 1

collapse (sum) turbines_present_voronoi total_counter, by(year)

gen turbine_share_voronoi = (turbines_present_voronoi / total_counter)*100

save "Data\Analysis\Turbines_Descriptives.dta", replace 


*********************************************************************************
*Merge shale and turbines descriptives 
use "Data\Analysis\Turbines_Descriptives_17_5.dta", clear 
merge 1:1 year using "Data\Analysis\Wells_Descriptives_17_5.dta"
drop _merge 
merge 1:1 year using "Data\Analysis\Turbines_Descriptives.dta"
drop _merge 
merge 1:1 year using "Data\Analysis\Wells_Descriptives.dta"
drop _merge 
merge 1:1 year using "Data\Analysis\Turbines_Descriptives_12_5.dta"
drop _merge 
merge 1:1 year using "Data\Analysis\Wells_Descriptives_12_5.dta"
drop _merge 

order turbines_present_12_5 turbines_present turbines_present_voronoi turbine_share_12_5 turbine_share turbine_share_voronoi has_wells_12_5 has_wells has_wells_voronoi wells_share_12_5 wells_share wells_share_voronoi

grstyle init
grstyle set plain, noextend
grstyle set legend 6, nobox
grstyle set color cranberry blue
grstyle set symbol, n(1)
grstyle set compact
twoway line wells_share year || line turbine_share year, title("Percent of Bird Circles Treated") xtitle("Year") ytitle("% Treated") yscale(r(0 5)) ylabel(0 (1) 15, labsize(small) angle(horizontal)) xlabel(,labsize(small) angle(horizontal)) legend(order(1 "Shale Wells" 2 "Wind Turbines") rows(1))


grstyle init
grstyle set plain, noextend
grstyle set legend 6, nobox
grstyle set color cranberry blue cranberry blue cranberry blue
grstyle set lpattern dash dash solid solid shortdash shortdash
grstyle set symbol, n(1)
grstyle set compact
twoway line wells_share_voronoi year || line turbine_share_voronoi year || line wells_share year || line turbine_share year || line wells_share_12_5 year || line turbine_share_12_5 year, title("{bf: C. Percent of Bird Circles Treated}") xtitle("Year") ytitle("% Treated") yscale(r(0 25)) ylabel(0 (5) 25, labsize(small) angle(horizontal)) xlabel(,labsize(small) angle(horizontal)) legend(order(1 "Shale Wells (Voronoi Region)" 2 "Wind Turbines (Voronoi Region)" 3 "Shale Wells (5km Buffer)" 4 "Wind Turbines (5km Buffer)" 5 "Shale Wells (No Buffer)" 6 "Wind Turbines (No Buffer)") rows(3))
