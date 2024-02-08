*Set working directory
clear
cd "${user}"

*********************************************************************************
*First, analyze SHALE
use "Data\Intermediate\CBC_Circles_in_ImportantAreas", clear 

duplicates drop circle_id, force 

keep circle_id 

gen in_important_bird_area = 1

merge 1:m circle_id using "Data\Analysis\CBC_Shale_Combined_Characteristics_17_5_Panel.dta"
drop _merge 
replace in_important_bird_area = 0 if in_important_bird_area == .

sort state circle_name year 

drop if state == "AK" | state == "HI" | state == "DC"

*Standard cleaning: 
replace Min_snow = 0 if Min_snow == .

*Define treatment by first year in which wells were completed
gen wells_year = .
replace wells_year = year if shale_wells_num > 0
bysort circle_id: egen first_well_year = min(wells_year)
replace first_well_year = 0 if first_well_year == .

*Identify states with some shale wells 
bysort state: gen state_wells = sum(shale_wells_num)
gen some_state_wells = 0
replace some_state_wells = 1 if state_wells > 0

rename ihs_num_longermigration_w_pc ihs_num_longmig_w_pc
rename ihs_spec_shortmigration ihs_spec_shortmig
rename ihs_spec_longermigration ihs_spec_longermig
rename ihs_spec_shortmigration_pc ihs_spec_shortmig_pc
rename ihs_spec_longermigration_pc ihs_spec_longermig_pc

gen ihs_shalewells = asinh(shale_wells_num)
gen ihs_cumshalewells = asinh(cum_shalewells)	

*Setup 
set seed 39627236
estimate drop _all 

*Number seen 
local outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmigration_w ihs_num_longermigration_w"
foreach j of local outcomes {
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 1, ivar(circle_id) time(year) gvar(first_well_year) notyet
		csdid_estat simple, estore("`j'1")
		
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 0, ivar(circle_id) time(year) gvar(first_well_year) notyet
		csdid_estat simple, estore("`j'2")
}

*Species 
local outcomes "ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach j of local outcomes {
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 1, ivar(circle_id) time(year) gvar(first_well_year) notyet
		csdid_estat simple, estore("`j'1")
		
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 0, ivar(circle_id) time(year) gvar(first_well_year) notyet
		csdid_estat simple, estore("`j'2")
}


graph drop _all 

*Number Seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot ihs_num_tot_w1 ihs_num_tot_w2, bylabel(Total) || ihs_num_grassland_w1 ihs_num_grassland_w2, bylabel(Grassland) || ihs_num_woodland_w1 ihs_num_woodland_w2, bylabel(Woodland) || ihs_num_wetland_w1 ihs_num_wetland_w2, bylabel(Wetland) || ihs_num_otherhabitat_w1 ihs_num_otherhabitat_w2, bylabel(Other Habitat) || ihs_num_urban_w1 ihs_num_urban_w2, bylabel(Urban) || ihs_num_nonurban_w1 ihs_num_nonurban_w2, bylabel(Non-Urban) || ihs_num_resident_w1 ihs_num_resident_w2, bylabel(Non-Migrants) || ihs_num_shortmigration_w1 ihs_num_shortmigration_w2, bylabel(Short/Irruptive Migrants) || ihs_num_longermigration_w1 ihs_num_longermigration_w2, bylabel(Moderate/Long Migrants) ||, byopts(compact cols(1)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) xscale(r(-1.25 .5)) xlabel(-1.25 (.25) .5) subtitle(, bcolor(white)) plotregion(color(none)) bycoefs ciopts(lwidth(2.5 ..) lcolor(*.55)) msymbol(d) mcolor(white) name("shale_importantareas_num") title("Birds Reported") legend(order(1 "Inside Important Bird Area" 3 "Outside Important Bird Area")) levels(95) xtitle("Coefficient Estimate")

*Species Seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot ihs_spec_tot1 ihs_spec_tot2, bylabel(Total) || ihs_spec_grassland1 ihs_spec_grassland2, bylabel(Grassland) || ihs_spec_woodland1 ihs_spec_woodland2, bylabel(Woodland) || ihs_spec_wetland1 ihs_spec_wetland2, bylabel(Wetland) || ihs_spec_otherhabitat1 ihs_spec_otherhabitat2, bylabel(Other Habitat) || ihs_spec_urban1 ihs_spec_urban2, bylabel(Urban) || ihs_spec_nonurban1 ihs_spec_nonurban2, bylabel(Non-Urban) || ihs_spec_resident1 ihs_spec_resident2, bylabel(Non-Migrants) || ihs_spec_shortmig1 ihs_spec_shortmig2, bylabel(Short/Irruptive Migrants) || ihs_spec_longermig1 ihs_spec_longermig2, bylabel(Moderate/Long Migrants) ||, byopts(compact cols(1)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) xscale(r(-0.5 .3)) xlabel(-0.5 (.1) .3) subtitle(, bcolor(white)) plotregion(color(none)) bycoefs ciopts(lwidth(2.5 ..) lcolor(*.55)) msymbol(d) mcolor(white) title("Species Reported") name("shale_importantareas_spec") legend(order(1 "Inside Important Bird Area" 3 "Outside Important Bird Area")) levels(95) xtitle("Coefficient Estimate")

grc1leg2 shale_importantareas_num shale_importantareas_spec


*********************************************************************************
*Next, analyze wind 
use "Data\Intermediate\CBC_Circles_in_ImportantAreas", clear 

duplicates drop circle_id, force 

keep circle_id 

gen in_important_bird_area = 1

merge 1:m circle_id using "Data\Analysis\CBC_wind_Combined_Characteristics_17_5_Panel.dta"
drop _merge 
replace in_important_bird_area = 0 if in_important_bird_area == .

sort state circle_name year 

drop if state == "AK" | state == "HI" | state == "DC"

replace Min_snow = 0 if Min_snow == .

*Define treatment by first year in which turbines were built (0 if never treated)
gen turbines_year = .
replace turbines_year = year if num_turbines > 0
bysort circle_id: egen first_turbine_year = min(turbines_year)
replace first_turbine_year = 0 if first_turbine_year == .

*Cumulative turbines 
bysort circle_id (year) : gen cum_turbines = sum(num_turbines)

*Identify states with some turbines 
bysort state: gen state_turbines = sum(num_turbines)
gen some_state_turbines = 0
replace some_state_turbines = 1 if state_turbines > 0

rename ihs_num_longermigration_w_pc ihs_num_longmig_w_pc
rename ihs_spec_shortmigration ihs_spec_shortmig
rename ihs_spec_longermigration ihs_spec_longermig
rename ihs_spec_shortmigration_pc ihs_spec_shortmig_pc
rename ihs_spec_longermigration_pc ihs_spec_longermig_pc

gen ihs_num_turbines = asinh(num_turbines)
gen ihs_cumturbines = asinh(cum_turbines)

*Setup 
set seed 39627236
estimate drop _all  

*Number seen 
local outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmigration_w ihs_num_longermigration_w"
foreach j of local outcomes {
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 1, ivar(circle_id) time(year) gvar(first_turbine_year) notyet
		csdid_estat simple, estore("`j'1")
		
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 0, ivar(circle_id) time(year) gvar(first_turbine_year) notyet
		csdid_estat simple, estore("`j'2")
}

*Species 
local outcomes "ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach j of local outcomes {
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 1, ivar(circle_id) time(year) gvar(first_turbine_year) notyet
		csdid_estat simple, estore("`j'1")
		
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow if in_important_bird_area == 0, ivar(circle_id) time(year) gvar(first_turbine_year) notyet
		csdid_estat simple, estore("`j'2")
}

graph drop _all 

*Number Seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color blue 
grstyle set symbol, n(1)
grstyle set compact
coefplot ihs_num_tot_w1 ihs_num_tot_w2, bylabel(Total) || ihs_num_grassland_w1 ihs_num_grassland_w2, bylabel(Grassland) || ihs_num_woodland_w1 ihs_num_woodland_w2, bylabel(Woodland) || ihs_num_wetland_w1 ihs_num_wetland_w2, bylabel(Wetland) || ihs_num_otherhabitat_w1 ihs_num_otherhabitat_w2, bylabel(Other Habitat) || ihs_num_urban_w1 ihs_num_urban_w2, bylabel(Urban) || ihs_num_nonurban_w1 ihs_num_nonurban_w2, bylabel(Non-Urban) || ihs_num_resident_w1 ihs_num_resident_w2, bylabel(Non-Migrants) || ihs_num_shortmigration_w1 ihs_num_shortmigration_w2, bylabel(Short/Irruptive Migrants) || ihs_num_longermigration_w1 ihs_num_longermigration_w2, bylabel(Moderate/Long Migrants) ||, byopts(compact cols(1)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) xscale(r(-1.25 .75)) xlabel(-1.25 (.25) .75) subtitle(, bcolor(white)) plotregion(color(none)) bycoefs ciopts(lwidth(2.5 ..) lcolor(*.55)) msymbol(d) mcolor(white) name("wind_importantareas_num") title("Birds Reported") legend(order(1 "Inside Important Bird Area" 3 "Outside Important Bird Area")) levels(95) xtitle("Coefficient Estimate")

*Species Seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color blue 
grstyle set symbol, n(1)
grstyle set compact
coefplot ihs_spec_tot1 ihs_spec_tot2, bylabel(Total) || ihs_spec_grassland1 ihs_spec_grassland2, bylabel(Grassland) || ihs_spec_woodland1 ihs_spec_woodland2, bylabel(Woodland) || ihs_spec_wetland1 ihs_spec_wetland2, bylabel(Wetland) || ihs_spec_otherhabitat1 ihs_spec_otherhabitat2, bylabel(Other Habitat) || ihs_spec_urban1 ihs_spec_urban2, bylabel(Urban) || ihs_spec_nonurban1 ihs_spec_nonurban2, bylabel(Non-Urban) || ihs_spec_resident1 ihs_spec_resident2, bylabel(Non-Migrants) || ihs_spec_shortmig1 ihs_spec_shortmig2, bylabel(Short/Irruptive Migrants) || ihs_spec_longermig1 ihs_spec_longermig2, bylabel(Moderate/Long Migrants) ||, byopts(compact cols(1)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) xscale(r(-0.5 .5)) xlabel(-0.5 (.1) .5) subtitle(, bcolor(white)) plotregion(color(none)) bycoefs ciopts(lwidth(2.5 ..) lcolor(*.55)) msymbol(d) mcolor(white) title("Species Reported") name("wind_importantareas_spec") legend(order(1 "Inside Important Bird Area" 3 "Outside Important Bird Area")) levels(95) xtitle("Coefficient Estimate")

grc1leg2 wind_importantareas_num wind_importantareas_spec






