*Import wind turbine registry 
clear 
import delimited "${user}\Data\Raw\Wind_Turbines\uswtdb_v4_3_20220114.csv"

*Keep key variables 
keep t_state t_county p_year p_tnum p_cap t_model t_cap t_hh t_rd t_rsa t_ttlh xlong ylat

*Rename key variables
rename t_state turbine_state
rename t_county turbine_county
rename p_year year_operational
rename p_tnum num_turbines
rename p_cap cumulative_capacity_mw
rename t_model turbine_model
rename t_cap turbine_capacity
rename t_hh turbine_hubheight
rename t_rd turbine_rotordiameter
rename t_rsa turbine_rotorsweptarea
rename t_ttlh turbine_totalheight
rename xlong longitude
rename ylat latitude

gen period = ""
replace period = "Pre-2000" if year_operational < 2000
replace period = "2000-2005" if year_operational >= 2000 & year_operational < 2006
replace period = "2006-2010" if year_operational >= 2006 & year_operational < 2011
replace period = "2011-2015" if year_operational >= 2011 & year_operational < 2016
replace period = "2016-2020" if year_operational >= 2016 & year_operational < 2021

drop if year_operational > 2020

*Keep lower 48 states 
drop if turbine_state == "HI" | turbine_state == "AK" | turbine_state == "PR" | turbine_state == "GU"

save "${user}\Data\Intermediate\Wind_Turbine_Registry_USGS", replace 

drop if year_operational < 2000

*Output data as .csv
export delimited using "${user}\Data\Intermediate\Wind_Turbine_Registry_USGS.csv", replace