*Set working directory
clear
cd "${user}\Data"

*First, collapse wind and polygon data to circle year level 
use "Intermediate\CBC_circles_shale.dta", clear

*Drop duplicates 
duplicates drop circle_id field_id year shale_wells_num production_kbblpd, force 

collapse (sum) shale_wells_num production_kbblpd cum_shalewells, by(circle_id year)

sort circle_id year 

merge 1:1 circle_id year using "Analysis\CBC_CircleLevel_Panel"

sort circle_id year 

local shale "shale_wells_num production_kbblpd cum_shalewells"
foreach k of local shale {
	replace `k' = 0 if _merge == 2
}

drop if _merge == 1

sort circle_id year 
drop _merge 

/*
*Compute cumulative number of turbines 
local vars "num_turbines cumulative_capacity_mw turbine_capacity turbine_hubheight turbine_rotorsweptarea turbine_rotordiameter turbine_totalheight"
foreach i of local vars {
	bysort circle_id (year) : gen c_`i' = sum(`i')
}
*/

order circle_id circle circle_name year shale_wells_num production_kbblpd cum_shalewells latitude longitude state

save "Analysis\CBC_Shale_Combined_Panel.dta", replace 

********************************************************
*Repeat for characteristics groups 

*First, collapse wind and polygon data to circle year level 
use "Intermediate\CBC_circles_shale.dta", clear

*Drop duplicates 
duplicates drop circle_id field_id year shale_wells_num production_kbblpd, force 

collapse (sum) shale_wells_num production_kbblpd cum_shalewells, by(circle_id year)

sort circle_id year 

merge 1:1 circle_id year using "Analysis\CBC_CircleLevel_Panel_Characteristics"

sort circle_id year 

local shale "shale_wells_num production_kbblpd cum_shalewells"
foreach k of local shale {
	replace `k' = 0 if _merge == 2
}

drop if _merge == 1

sort circle_id year 
drop _merge 

/*
*Compute cumulative number of turbines 
local vars "num_turbines cumulative_capacity_mw turbine_capacity turbine_hubheight turbine_rotorsweptarea turbine_rotordiameter turbine_totalheight"
foreach i of local vars {
	bysort circle_id (year) : gen c_`i' = sum(`i')
}
*/

order circle_id circle circle_name year shale_wells_num production_kbblpd cum_shalewells latitude longitude state

save "Analysis\CBC_Shale_Combined_Characteristics_Panel.dta", replace

********************************************************************************
*Repeat for circles with buffer 
*First, collapse wind and polygon data to circle year level 
local buffers "12_5 13_5 14_5 17_5 22_5"
foreach b of local buffers {
	
	use "Intermediate\CBC_circles_shale_`b'_buffer.dta", clear

	drop circle_id_y circle_y circle_name_y state_y
	rename circle_id_x circle_id
	rename circle_x circle
	rename circle_name_x circle_name
	rename state_x state

	*Drop duplicates 
	duplicates drop circle_id field_id year shale_wells_num production_kbblpd, force 

	collapse (sum) shale_wells_num production_kbblpd cum_shalewells, by(circle_id year)

	sort circle_id year 

	merge 1:1 circle_id year using "Analysis\CBC_CircleLevel_Panel"

	sort circle_id year 

		local shale "shale_wells_num production_kbblpd cum_shalewells"
		foreach k of local shale {
			replace `k' = 0 if _merge == 2
		}

	drop if _merge == 1

	sort circle_id year 
	drop _merge 

	/*
	*Compute cumulative number of turbines 
	local vars "num_turbines cumulative_capacity_mw turbine_capacity turbine_hubheight turbine_rotorsweptarea turbine_rotordiameter turbine_totalheight"
	foreach i of local vars {
		bysort circle_id (year) : gen c_`i' = sum(`i')
	}
	*/

	order circle_id circle circle_name year shale_wells_num production_kbblpd cum_shalewells latitude longitude state

	save "Analysis\CBC_Shale_Combined_Panel_`b'_buffer.dta", replace 
	
}


********************************************************************************
*Repeat for circles with buffer and CHARACTERISTICS
*First, collapse wind and polygon data to circle year level 
local buffers "12_5 13_5 17_5 22_5"
foreach b of local buffers {
	
	*First, collapse wind and polygon data to circle year level 
	use "Intermediate\CBC_circles_shale_`b'_buffer.dta", clear
	
	drop circle_id_y circle_y circle_name_y state_y
	rename circle_id_x circle_id
	rename circle_x circle
	rename circle_name_x circle_name
	rename state_x state

	*Drop duplicates 
	duplicates drop circle_id field_id year shale_wells_num production_kbblpd, force 

	collapse (sum) shale_wells_num production_kbblpd cum_shalewells, by(circle_id year)

	sort circle_id year 

	merge 1:1 circle_id year using "Analysis\CBC_CircleLevel_Panel_Characteristics"

	sort circle_id year 

	local shale "shale_wells_num production_kbblpd cum_shalewells"
	foreach k of local shale {
		replace `k' = 0 if _merge == 2
	}

	drop if _merge == 1

	sort circle_id year 
	drop _merge 

	/*
	*Compute cumulative number of turbines 
	local vars "num_turbines cumulative_capacity_mw turbine_capacity turbine_hubheight turbine_rotorsweptarea turbine_rotordiameter turbine_totalheight"
	foreach i of local vars {
		bysort circle_id (year) : gen c_`i' = sum(`i')
	}
	*/

	order circle_id circle circle_name year shale_wells_num production_kbblpd cum_shalewells latitude longitude state

	save "Analysis\CBC_Shale_Combined_Characteristics_`b'_Panel.dta", replace
	
}


********************************************************************************
*Repeat for Breeding Bird Surveys

*Repeat for characteristics panel 
local buffers "5 10"
foreach b of local buffers {
	
	*First, collapse wind and polygon data to circle year level 
	use "Intermediate\BreedingBirds_`b'km_Shale.dta", clear
	
	drop unique_route_id_y routename_y state_name_y
	rename unique_route_id_x unique_route_id
	rename routename_x routename
	rename state_name_x state_name

	*Drop duplicates 
	duplicates drop unique_route_id field_id year shale_wells_num production_kbblpd, force 

	collapse (sum) shale_wells_num production_kbblpd cum_shalewells, by(unique_route_id year)

	sort unique_route_id year 

	drop if year < 2000

	merge 1:1 unique_route_id year using "Raw\North American Breeding Bird Survey\BreedingBirdSurvey_USLower48_2000_2020_withRouteInfo"

	sort unique_route_id year 

	local shale "shale_wells_num production_kbblpd cum_shalewells"
	foreach k of local shale {
		replace `k' = 0 if _merge == 2
	}

	drop if _merge == 1

	sort unique_route_id year 
	drop _merge 

	save "Analysis\BreedingSurvey_Shale_`b'_Panel.dta", replace 
	
}



















