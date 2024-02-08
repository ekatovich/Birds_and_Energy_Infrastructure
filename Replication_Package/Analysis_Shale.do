*Set working directory
clear
cd "${user}"

********************************************************************************
*Characteristics 

*By Distance Buffer
local buffers "12_5 13_5 17_5 22_5"
foreach b of local buffers {
	
	use "Data\Analysis\CBC_Shale_Combined_Characteristics_`b'_Panel.dta", clear

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
rename ihs_num_shortmigration_w ihs_num_shortmig_w
rename ihs_num_longermigration_w ihs_num_longermig_w
rename num_shortmigration_w num_shortmig_w
rename num_longermigration_w num_longermig_w

gen ihs_shalewells = asinh(shale_wells_num)
gen ihs_cumshalewells = asinh(cum_shalewells)	

*Create lat/long grid squares 
gen lat_round = round(latitude, 0.5)
gen lon_round = round(longitude, 0.5)
egen grid_id = group(lat_round lon_round)

*Setup 
set seed 39627236
estimate drop _all 

*Number seen (land)
local outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w"
foreach j of local outcomes {
	csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad, ivar(circle_id) time(year) gvar(first_well_year) notyet 
	csdid_estat simple, estore("`j'_l")
	csdid_estat event, estore("e_`j'_l")
}

*Species (land)
local outcomes "ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach j of local outcomes {
	csdid2 `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad, ivar(circle_id) time(year) gvar(first_well_year) notyet
	estat simple, estore("`j'_l")
}

*Continuous DID
*With land 
local cont_outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach k of local cont_outcomes {
    didregress (`k' total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad) (ihs_cumshalewells, continuous), group(circle_id) time(year) vce(cluster circle_id)
	est store `k'
}

*Continuous DID with state-year FEs
egen state_id = group(state)
egen state_year = group(state_id year)

*With land 
local cont_outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach k of local cont_outcomes {
    didregress (`k' total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad i.state_year) (ihs_cumshalewells, continuous), group(circle_id) time(year) vce(cluster circle_id)
	est store `k'_sy
}

*Try quasi-poisson
xtset circle_id year

*Quasi-poisson (with land)
local cont_outcomes "num_tot_w num_grassland_w num_woodland_w num_wetland_w num_otherhabitat_w num_urban_w num_nonurban_w num_resident_w num_shortmig_w num_longermig_w spec_tot spec_grassland spec_woodland spec_wetland spec_otherhabitat spec_urban spec_nonurban spec_resident spec_shortmigration spec_longermigration" 
foreach k of local cont_outcomes {
    xtpoisson `k' ihs_cumshalewells total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad i.year, fe vce(robust)
	est store `k'_p
}

*Random effects with grid clusters
local cont_outcomes "num_tot_w num_grassland_w num_woodland_w num_wetland_w num_otherhabitat_w num_urban_w num_nonurban_w num_resident_w num_shortmig_w num_longermig_w spec_tot spec_grassland spec_woodland spec_wetland spec_otherhabitat spec_urban spec_nonurban spec_resident spec_shortmigration spec_longermigration" 
foreach k of local cont_outcomes {
    xtpoisson `k' ihs_cumshalewells total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad, re vce(cluster grid_id)
	est store `k'_pc
}

*DID FEs with grid clusters
local cont_outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach k of local cont_outcomes {
    didregress (`k' total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad) (ihs_cumshalewells, continuous), group(circle_id) time(year) vce(cluster grid_id)
	est store `k'_g
}


graph drop _all 

*Number seen (land)
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_num_tot_w_l, aseq("{bf:Total}") \ ihs_num_grassland_w_l, aseq("Grassland/Shrubland") \  ihs_num_woodland_w_l, aseq("Woodland") \ ihs_num_wetland_w_l, aseq("Wetland") \ ihs_num_otherhabitat_w_l, aseq("Other Habitats") \ ihs_num_urban_w_l, aseq("Urban") \ ihs_num_nonurban_w_l, aseq("Non-Urban") \ihs_num_resident_w_l, aseq("Non-Migrants") \ ihs_num_shortmig_w_l, aseq("Short/Irruptive Migrants") \ ihs_num_longermig_w_l, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Birds Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_characteristics_shale_l") xscale(r(-.8 .4)) xlabel(-.8 (.2) .4)

*Species (land)
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_spec_tot_l, aseq("{bf:Total}") \ ihs_spec_grassland_l, aseq("Grassland/Shrubland") \  ihs_spec_woodland_l, aseq("Woodland") \ ihs_spec_wetland_l, aseq("Wetland") \ ihs_spec_otherhabitat_l, aseq("Other Habitats") \ ihs_spec_urban_l, aseq("Urban") \ ihs_spec_nonurban_l, aseq("Non-Urban") \ihs_spec_resident_l, aseq("Non-Migrants") \ ihs_spec_shortmig_l, aseq("Short/Irruptive Migrants") \ ihs_spec_longermig_l, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Species Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale_l") xscale(r(-.05 .05)) xlabel(-.3 (.1) .2)

*Continuous DID: Number seen (land)
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_num_tot_w, aseq("{bf:Total}") \ ihs_num_grassland_w, aseq("Grassland/Shrubland") \  ihs_num_woodland_w, aseq("Woodland") \ ihs_num_wetland_w, aseq("Wetland") \ ihs_num_otherhabitat_w, aseq("Other Habitats") \ ihs_num_urban_w, aseq("Urban") \ ihs_num_nonurban_w, aseq("Non-Urban") \ihs_num_resident_w, aseq("Non-Migrants") \ ihs_num_shortmig_w, aseq("Short/Irruptive Migrants") \ ihs_num_longermig_w, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Birds Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_characteristics_shale_d")

*Continuous DID: Species (land)
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_spec_tot, aseq("{bf:Total}") \ ihs_spec_grassland, aseq("Grassland/Shrubland") \  ihs_spec_woodland, aseq("Woodland") \ ihs_spec_wetland, aseq("Wetland") \ ihs_spec_otherhabitat, aseq("Other Habitats") \ ihs_spec_urban, aseq("Urban") \ ihs_spec_nonurban, aseq("Non-Urban") \ihs_spec_resident, aseq("Non-Migrants") \ ihs_spec_shortmig, aseq("Short/Irruptive Migrants") \ ihs_spec_longermig, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Species Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale_d")

*Poisson: Number seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (num_tot_w_p, aseq("{bf:Total}") \ num_grassland_w_p, aseq("Grassland/Shrubland") \  num_woodland_w_p, aseq("Woodland") \ num_wetland_w_p, aseq("Wetland") \ num_otherhabitat_w_p, aseq("Other Habitats") \ num_urban_w_p, aseq("Urban") \ num_nonurban_w_p, aseq("Non-Urban") \ num_resident_w_p, aseq("Non-Migrants") \ num_shortmig_w_p, aseq("Short/Irruptive Migrants") \ num_longermig_w_p, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Birds Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_characteristics_shale_p") 

*Poisson: Species
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (spec_tot_p, aseq("{bf:Total}") \ spec_grassland_p, aseq("Grassland/Shrubland") \ spec_woodland_p, aseq("Woodland") \ spec_wetland_p, aseq("Wetland") \ spec_otherhabitat_p, aseq("Other Habitats") \ spec_urban_p, aseq("Urban") \ spec_nonurban_p, aseq("Non-Urban") \ spec_resident_p, aseq("Non-Migrants") \ spec_shortmigration_p, aseq("Short/Irruptive Migrants") \ spec_longermigration_p, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Species Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale_p") 

*Poisson REs with grid clusters: Number seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (num_tot_w_pc, aseq("{bf:Total}") \ num_grassland_w_pc, aseq("Grassland/Shrubland") \  num_woodland_w_pc, aseq("Woodland") \ num_wetland_w_pc, aseq("Wetland") \ num_otherhabitat_w_pc, aseq("Other Habitats") \ num_urban_w_pc, aseq("Urban") \ num_nonurban_w_pc, aseq("Non-Urban") \ num_resident_w_pc, aseq("Non-Migrants") \ num_shortmig_w_pc, aseq("Short/Irruptive Migrants") \ num_longermig_w_pc, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Birds Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_chars_shale_pc") 

*Poisson REs with grid clusters: Species
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (spec_tot_pc, aseq("{bf:Total}") \ spec_grassland_pc, aseq("Grassland/Shrubland") \ spec_woodland_pc, aseq("Woodland") \ spec_wetland_pc, aseq("Wetland") \ spec_otherhabitat_pc, aseq("Other Habitats") \ spec_urban_pc, aseq("Urban") \ spec_nonurban_pc, aseq("Non-Urban") \ spec_resident_pc, aseq("Non-Migrants") \ spec_shortmigration_pc, aseq("Short/Irruptive Migrants") \ spec_longermigration_pc, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Species Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale_pc") 

*Continuous DID with Grid clusters and FE: Number seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_num_tot_w_g, aseq("{bf:Total}") \ ihs_num_grassland_w_g, aseq("Grassland/Shrubland") \  ihs_num_woodland_w_g, aseq("Woodland") \ ihs_num_wetland_w_g, aseq("Wetland") \ ihs_num_otherhabitat_w_g, aseq("Other Habitats") \ ihs_num_urban_w_g, aseq("Urban") \ ihs_num_nonurban_w_g, aseq("Non-Urban") \ ihs_num_resident_w_g, aseq("Non-Migrants") \ ihs_num_shortmig_w_g, aseq("Short/Irruptive Migrants") \ ihs_num_longermig_w_g, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Birds Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_chars_shale_g") 

*Continuous DID with Grid clusters and FE: Species
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_spec_tot_g, aseq("{bf:Total}") \ ihs_spec_grassland_g, aseq("Grassland/Shrubland") \ ihs_spec_woodland_g, aseq("Woodland") \ ihs_spec_wetland_g, aseq("Wetland") \ ihs_spec_otherhabitat_g, aseq("Other Habitats") \ ihs_spec_urban_g, aseq("Urban") \ ihs_spec_nonurban_g, aseq("Non-Urban") \ ihs_spec_resident_g, aseq("Non-Migrants") \ ihs_spec_shortmig_g, aseq("Short/Irruptive Migrants") \ ihs_spec_longermig_g, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Species Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale_g") 

*Continuous DID with State-Year FE: Number seen 
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_num_tot_w_sy, aseq("{bf:Total}") \ ihs_num_grassland_w_sy, aseq("Grassland/Shrubland") \  ihs_num_woodland_w_sy, aseq("Woodland") \ ihs_num_wetland_w_sy, aseq("Wetland") \ ihs_num_otherhabitat_w_sy, aseq("Other Habitats") \ ihs_num_urban_w_sy, aseq("Urban") \ ihs_num_nonurban_w_sy, aseq("Non-Urban") \ ihs_num_resident_w_sy, aseq("Non-Migrants") \ ihs_num_shortmig_w_sy, aseq("Short/Irruptive Migrants") \ ihs_num_longermig_w_sy, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Birds Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_chars_shale_sy") 

*Continuous DID with State-Year FE: Species
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_spec_tot_sy, aseq("{bf:Total}") \ ihs_spec_grassland_sy, aseq("Grassland/Shrubland") \ ihs_spec_woodland_sy, aseq("Woodland") \ ihs_spec_wetland_sy, aseq("Wetland") \ ihs_spec_otherhabitat_sy, aseq("Other Habitats") \ ihs_spec_urban_sy, aseq("Urban") \ ihs_spec_nonurban_sy, aseq("Non-Urban") \ ihs_spec_resident_sy, aseq("Non-Migrants") \ ihs_spec_shortmig_sy, aseq("Short/Irruptive Migrants") \ ihs_spec_longermig_sy, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Species Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale_sy") 

*All including land use controls: 
*CSDID: 
grc1leg2 num_seen_characteristics_shale_l species_seen_char_shale_l

*Continuous DID:
grc1leg2 num_seen_characteristics_shale_d species_seen_char_shale_d

*Poisson (untransformed)
grc1leg2 num_seen_characteristics_shale_p species_seen_char_shale_p

*Poisson (untransformed) with random effects and grid clusters
grc1leg2 num_seen_chars_shale_pc species_seen_char_shale_pc

*DID with FEs and grid clusters
grc1leg2 num_seen_chars_shale_g species_seen_char_shale_g

*DID with state-year FEs
grc1leg2 num_seen_chars_shale_sy species_seen_char_shale_sy

*********************************************
*Plot dynamics to check pretrends: population 
graph drop _all 

	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color cranberry
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_ihs_num_shortmig_w_l, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp15 Tp14 Tp13 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Short/Irruptive Migrants", size(medsmall)) name("g_ihs_num_shortmig_w_l") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 

	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color cranberry
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_ihs_num_grassland_w_l, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp15 Tp14 Tp13 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Grassland/Shrubland", size(medsmall)) name("g_ihs_num_grassland_w_l") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 

	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color cranberry
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_ihs_num_nonurban_w_l, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp15 Tp14 Tp13 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Non-Urban", size(medsmall)) name("g_ihs_num_nonurban_w_l") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 

	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color cranberry
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_ihs_num_longermig_w_l, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp15 Tp14 Tp13 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Medium-to-Long Migrants", size(medsmall)) name("g_ihs_num_longermig_w_l") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 

grc1leg2 g_ihs_num_grassland_w_l g_ihs_num_nonurban_w_l g_ihs_num_shortmig_w_l g_ihs_num_longermig_w_l
	
*******************************************
*Plot dynamics to check pretrends: species 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color cranberry
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_ihs_spec_tot_l, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp15 Tp14 Tp13 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Number of Species Reported", size(medsmall)) name("g_ihs_spec_tot_l") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) yscale(r(-.2 .3)) ylabel(-.2 (.1) .3)

grc1leg2 num_seen_characteristics_shale species_seen_char_shale
}


********************************************************************************
*Correlated spatial random effects 

use "Data\Analysis\CBC_Shale_Combined_Characteristics_17_5_Panel.dta", clear

drop if state == "AK" | state == "HI"

replace Min_snow = 0 if Min_snow == .

rename ihs_num_longermigration_w_pc ihs_num_longmig_w_pc
rename ihs_spec_shortmigration ihs_spec_shortmig
rename ihs_spec_longermigration ihs_spec_longermig
rename ihs_spec_shortmigration_pc ihs_spec_shortmig_pc
rename ihs_spec_longermigration_pc ihs_spec_longermig_pc
rename ihs_num_shortmigration_w ihs_num_shortmig_w
rename ihs_num_longermigration_w ihs_num_longermig_w
rename num_shortmigration_w num_shortmig_w
rename num_longermigration_w num_longermig_w

gen ihs_shalewells = asinh(shale_wells_num)
gen ihs_cumshalewells = asinh(cum_shalewells)	

*Reduce sample size 
drop if year < 2010

drop if state == "AL" | state == "AZ" | state == "CT" | state == "DC"  | state == "DE"  | state == "FL" | state == "GA" | state == "IA" | state =="ID" | state == "IL" | state == "KS" | state == "MA" | state =="MD" | state == "ME" | state == "MN" | state == "MO" | state == "NC" | state == "NE" | state =="NH" | state == "NJ" | state == "NV" | state == "NY" | state =="OR" | state =="RI" | state == "SC" | state == "SD" | state == "VT" | state == "WA" | state == "WI" 

tsset circle_id year
tsfill, full

keep state ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig ihs_cumshalewells circle_id year latitude longitude total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad

bysort circle_id: egen missing_lat = max(latitude)
bysort circle_id: egen missing_lon = max(longitude)
replace longitude = missing_lon if longitude == .
replace latitude = missing_lat if latitude == .
drop missing_lat missing_lon 

drop if circle_id == .
drop if year == . 

*Fill in missing values 
local fill "latitude longitude Min_temp Max_temp Max_wind Max_snow total_effort_counters ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig ag_land_share past_land_share dev_share_broad ihs_cumshalewells"
foreach b of local fill {
    gsort circle_id year 
	by circle_id: gen tofill=sum(!missing(`b'))>=1
	gen wanted= `b'
	bys circle_id (year): replace wanted= wanted[_n-1] if missing(wanted) & tofill
	gsort circle_id -year
	by circle_id: replace wanted= wanted[_n-1] if missing(wanted)
	replace `b' = wanted if `b' == .
	drop wanted tofill
}

sort circle_id year 

local missings "latitude longitude Min_temp Max_temp Max_wind Max_snow total_effort_counters ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig ag_land_share past_land_share dev_share_broad ihs_cumshalewells"
foreach k of local missings {
    drop if `k' == .
}

spbalance, balance

xtset circle_id year
spset circle_id
spset, modify coord(longitude latitude) 
spset, modify coordsys(latlong, kilometers)
capture spmatrix drop Idist
spmatrix create idistance Idist if year == 2010

estimates drop _all 
graph drop _all 

local outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmig_w ihs_num_longermig_w ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach j of local outcomes {
    spxtregress `j' ihs_cumshalewells total_effort_counters Min_temp Max_temp Max_wind Max_snow ag_land_share past_land_share dev_share_broad i.year, re dvarlag(Idist) errorlag(Idist)
	est store `j'_sr
}

*Correlated Spatial Random Effects (Number Counted)
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_num_tot_w_sr, aseq("{bf:Total}") \ ihs_num_grassland_w_sr, aseq("Grassland/Shrubland") \  ihs_num_woodland_w_sr, aseq("Woodland") \ ihs_num_wetland_w_sr, aseq("Wetland") \ ihs_num_otherhabitat_w_sr, aseq("Other Habitats") \ ihs_num_urban_w_sr, aseq("Urban") \ ihs_num_nonurban_w_sr, aseq("Non-Urban") \ ihs_num_resident_w_sr, aseq("Non-Migrants") \ ihs_num_shortmig_w_sr, aseq("Short/Irruptive Migrants") \ ihs_num_longermig_w_sr, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Birds Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_chars_shale_sr") 

*Correlated Spatial Random Effects (Species Counted)
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_spec_tot_sr, aseq("{bf:Total}") \ ihs_spec_grassland_sr, aseq("Grassland/Shrubland") \ ihs_spec_woodland_sr, aseq("Woodland") \ ihs_spec_wetland_sr, aseq("Wetland") \ ihs_spec_otherhabitat_sr, aseq("Other Habitats") \ ihs_spec_urban_sr, aseq("Urban") \ ihs_spec_nonurban_sr, aseq("Non-Urban") \ ihs_spec_resident_sr, aseq("Non-Migrants") \ ihs_spec_shortmig_sr, aseq("Short/Irruptive Migrants") \ ihs_spec_longermig_sr, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(small)) title("Species Reported", size(medsmall)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) keep(ihs_cumshalewells) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale_sr") 

grc1leg2 num_seen_chars_shale_sr species_seen_char_shale_sr


********************************************************************************
*By Voronoi tesselation 
use "Data\Analysis\CBC_Shale_Combined_Characteristics_Panel.dta", clear

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

*Setup 
set seed 39627236
estimate drop _all 

*Number seen 
local outcomes "ihs_num_tot_w ihs_num_grassland_w ihs_num_woodland_w ihs_num_wetland_w ihs_num_otherhabitat_w ihs_num_urban_w ihs_num_nonurban_w ihs_num_resident_w ihs_num_shortmigration_w ihs_num_longermigration_w"
foreach j of local outcomes {
	csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(first_well_year) notyet
	csdid_estat simple, estore("`j'")
	csdid_estat event, estore("e_`j'")
}

*Species 
local outcomes "ihs_spec_tot ihs_spec_grassland ihs_spec_woodland ihs_spec_wetland ihs_spec_otherhabitat ihs_spec_urban ihs_spec_nonurban ihs_spec_resident ihs_spec_shortmig ihs_spec_longermig"
foreach j of local outcomes {
	csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(first_well_year) notyet
	csdid_estat simple, estore("`j'")
	csdid_estat event, estore("e_`j'")
}


graph drop _all 

*Number seen
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_num_tot_w, aseq("{bf:Total}") \ ihs_num_grassland_w, aseq("Grassland/Shrubland") \  ihs_num_woodland_w, aseq("Woodland") \ ihs_num_wetland_w, aseq("Wetland") \ ihs_num_otherhabitat_w, aseq("Other Habitats") \ ihs_num_urban_w, aseq("Urban") \ ihs_num_nonurban_w, aseq("Non-Urban") \ihs_num_resident_w, aseq("Non-Migrants") \ ihs_num_shortmigration_w, aseq("Short/Irruptive Migrants") \ ihs_num_longermigration_w, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(vsmall)) title("Birds Reported", size(medium)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.4 *.7)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_characteristics_shale") xscale(r(-.8 .2)) xlabel(-.8 (.2) .2)
graph export "Output\Results_Number_Characteristics_Shale.pdf", replace 

*Species
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (ihs_spec_tot, aseq("{bf:Total}") \ ihs_spec_grassland, aseq("Grassland/Shrubland") \  ihs_spec_woodland, aseq("Woodland") \ ihs_spec_wetland, aseq("Wetland") \ ihs_spec_otherhabitat, aseq("Other Habitats") \ ihs_spec_urban, aseq("Urban") \ ihs_spec_nonurban, aseq("Non-Urban") \ihs_spec_resident, aseq("Non-Migrants") \ ihs_spec_shortmig, aseq("Short/Irruptive Migrants") \ ihs_spec_longermig, aseq("Moderate/Long Migrants")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(vsmall)) title("Species Reported", size(medium)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.4 *.7)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_char_shale") xscale(r(-.3 .2)) xlabel(-.3 (.1) .2)
graph export "Output\Results_Species_Characteristics_Shale.pdf", replace 

*********************************************
*Plot dynamics to check pretrends: population 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color blue
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_ihs_num_tot_w, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Number of Birds Reported", size(medsmall)) name("g_ihs_num_tot_w") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 

*Plot dynamics to check pretrends: species 
	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color blue
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_ihs_spec_tot, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Number of Species Reported", size(medsmall)) name("g_ihs_spec_tot") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 

grc1leg2 num_seen_characteristics_shale species_seen_char_shale
graph export "Output\Results_Number_and_Species_Characteristics_Shale.pdf", replace 

grc1leg2 g_ihs_num_tot_w g_ihs_spec_tot
graph export "Output\Results_Number_and_Species_Characteristics_Shale_Event.pdf", replace 


*******************************************************
*Distance buffers 
local buffers "12_5 13_5 17_5 22_5"
foreach b of local buffers {
	
	use "Data\Analysis\CBC_Shale_Combined_Panel_`b'_buffer.dta", clear 

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

	rename inumber_seen_per_counter_w i_number_pc_w
	rename itotal_species_manual i_species

	*Create outcome = presence of turbines 
	gen wells_present = 0
	replace wells_present = 1 if cum_shalewells > 0

	*Setup 
	set seed 39627236
	estimate drop _all 

	*Number seen 
	local outcomes "inumber_seen_w iAccipitriformes_num iAnseriformes_num iCharadriiformes_num iColumbiformes_num iFalconiformes_num iPasseriformes_num iPelecaniformes_num iPiciformes_num iStrigiformes_num"
	foreach j of local outcomes {
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(first_well_year) notyet
		csdid_estat simple, estore("`j'")
		csdid_estat event, estore("e_`j'")
	}

	*Species 
	local outcomes "i_species iAccipitriformes_species iAnseriformes_species iCharadriiformes_species iColumbiformes_species iFalconiformes_species iPasseriformes_species iPelecaniformes_species iPiciformes_species iStrigiformes_species"
	foreach j of local outcomes {
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(first_well_year) notyet
		csdid_estat simple, estore("`j'")
		csdid_estat event, estore("e_`j'")
	}


	graph drop _all 

	*Number (controlling for counter)
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color cranberry 
	grstyle set symbol, n(1)
	grstyle set compact
	coefplot (inumber_seen_w, aseq("{bf:Total}") \  iAccipitriformes_num, aseq("Accipitriformes") \ iAnseriformes_num, aseq("Anseriformes") \ iCharadriiformes_num, aseq("Charadriiformes") \ iColumbiformes_num, aseq("Columbiformes") \ iFalconiformes_num, aseq("Falconiformes") \iPasseriformes_num, aseq("Passeriformes") \ iPelecaniformes_num, aseq("Pelecaniformes") \ iPiciformes_num, aseq("Piciformes") \ iStrigiformes_num, aseq("Strigiformes")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(vsmall)) title("Birds Reported", size(medium)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_shale") xscale(r(-.6 .4)) xlabel(-.6 (.1) .4)
	graph export "Output\Results_Number_Shale`b'.pdf", replace 

	*Species
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color cranberry
	grstyle set symbol, n(1)
	grstyle set compact
	coefplot (i_species, aseq("{bf:Total}") \ iAccipitriformes_species, aseq("Accipitriformes") \ iAnseriformes_species, aseq("Anseriformes") \ iCharadriiformes_species, aseq("Charadriiformes") \ iColumbiformes_species, aseq("Columbiformes") \ iFalconiformes_species, aseq("Falconiformes") \ iPasseriformes_species, aseq("Passeriformes") \ iPelecaniformes_species, aseq("Pelecaniformes") \ iPiciformes_species, aseq("Piciformes") \ iStrigiformes_species, aseq("Strigiformes")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(vsmall)) title("Species Reported", size(medium)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_shale") xscale(r(-.3 .2)) xlabel(-.3 (0.1) .2)
	graph export "Output\Results_Species_Shale`b'.pdf", replace 
	
*Plot dynamics to check pretrends: population 
		grstyle init
		grstyle init
		grstyle set plain, nogrid noextend
		grstyle set legend 6, nobox
		grstyle set color cranberry
		grstyle set symbol, n(4)
		grstyle set compact
		coefplot e_inumber_seen_w, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp13 Tp14 Tp15 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Number of Birds Reported", size(medsmall)) name("g_inumber_seen_w") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) yscale(r(-.6 .4)) ylabel(-.6 (.1) .4)
	*yscale(r(-.8 .3)) ylabel(-.8 (.2) .4)

*Plot dynamics to check pretrends: species 
		grstyle init
		grstyle init
		grstyle set plain, nogrid noextend
		grstyle set legend 6, nobox
		grstyle set color cranberry
		grstyle set symbol, n(4)
		grstyle set compact
		coefplot e_i_species, vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp13 Tp14 Tp15 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("Number of Species Reported", size(medsmall)) name("g_i_species") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) yscale(r(-.2 .3)) ylabel(-.2 (.1) .3)

	grc1leg2 num_seen_shale species_seen_shale
	graph export "Output\Results_Number_and_Species_Shale`b'.pdf", replace 
}


*********************************************************************************
*Voronoi Tesselations 

*CS Estimator  (Shale)
use "Data\Analysis\CBC_Shale_Combined_Panel_withLand.dta", clear 

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

rename inumber_seen_per_counter_w i_number_pc_w
rename itotal_species_manual i_species

*Create outcome = presence of turbines 
gen wells_present = 0
replace wells_present = 1 if cum_shalewells > 0

*Setup 
set seed 39627236
estimate drop _all 

*Number seen 
local outcomes "inumber_seen_w iAccipitriformes_num iAnseriformes_num iCharadriiformes_num iColumbiformes_num iFalconiformes_num iPasseriformes_num iPelecaniformes_num iPiciformes_num iStrigiformes_num"
foreach j of local outcomes {
	csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(first_well_year) notyet
	*estat simple, estore("`j'")
	csdid_estat simple, estore("`j'")
	csdid_estat event, estore("e_`j'")
}

*Species 
local outcomes "i_species iAccipitriformes_species iAnseriformes_species iCharadriiformes_species iColumbiformes_species iFalconiformes_species iPasseriformes_species iPelecaniformes_species iPiciformes_species iStrigiformes_species"
foreach j of local outcomes {
	csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(first_well_year) notyet
	csdid_estat simple, estore("`j'")
	csdid_estat event, estore("e_`j'")
}

graph drop _all 

*Number (controlling for counter)
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry 
grstyle set symbol, n(1)
grstyle set compact
coefplot (inumber_seen_w, aseq("{bf:Total}") \  iAccipitriformes_num, aseq("Accipitriformes") \ iAnseriformes_num, aseq("Anseriformes") \ iCharadriiformes_num, aseq("Charadriiformes") \ iColumbiformes_num, aseq("Columbiformes") \ iFalconiformes_num, aseq("Falconiformes") \iPasseriformes_num, aseq("Passeriformes") \ iPelecaniformes_num, aseq("Pelecaniformes") \ iPiciformes_num, aseq("Piciformes") \ iStrigiformes_num, aseq("Strigiformes")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(vsmall)) title("Birds Reported", size(medium)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("num_seen_shale") xscale(r(-.3 .4)) xlabel(-.3 (.1) .4)
graph export "Output\Results_Number_Shale.pdf", replace 

*Species
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color cranberry
grstyle set symbol, n(1)
grstyle set compact
coefplot (i_species, aseq("{bf:Total}") \ iAccipitriformes_species, aseq("Accipitriformes") \ iAnseriformes_species, aseq("Anseriformes") \ iCharadriiformes_species, aseq("Charadriiformes") \ iColumbiformes_species, aseq("Columbiformes") \ iFalconiformes_species, aseq("Falconiformes") \ iPasseriformes_species, aseq("Passeriformes") \ iPelecaniformes_species, aseq("Pelecaniformes") \ iPiciformes_species, aseq("Piciformes") \ iStrigiformes_species, aseq("Strigiformes")), graphregion(fcolor(white)) xtitle("Coefficient Estimate", size(small)) xline(0, lcolor(black) lwidth(thin) lpattern(dash)) xlabel(,labsize(small) angle(horizontal)) ylabel(,labsize(vsmall)) title("Species Reported", size(medium)) swapnames nolabels levels(95 90) ciopts(lwidth(3 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) name("species_seen_shale") xscale(r(-.3 .2)) xlabel(-.3 (0.1) .2)
graph export "Output\Results_Species_Shale.pdf", replace 

*********************************************
*Plot dynamics to check pretrends: population 
local outcomes "inumber_seen_w iAccipitriformes_num iAnseriformes_num iCharadriiformes_num iColumbiformes_num iFalconiformes_num iPasseriformes_num iPelecaniformes_num iPiciformes_num iStrigiformes_num"
foreach j of local outcomes {

	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color blue
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_`j', vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("`j'", size(medsmall)) name("g_`j'") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 
*yscale(r(-.8 .3)) ylabel(-.8 (.2) .4)
}

*Plot dynamics to check pretrends: species 
local outcomes "i_species iAccipitriformes_species iAnseriformes_species iCharadriiformes_species iColumbiformes_species iFalconiformes_species iPasseriformes_species iPelecaniformes_species iPiciformes_species iStrigiformes_species"
foreach j of local outcomes {

	grstyle init
	grstyle init
	grstyle set plain, nogrid noextend
	grstyle set legend 6, nobox
	grstyle set color blue
	grstyle set symbol, n(4)
	grstyle set compact
	coefplot e_`j', vertical coeflabels(Tm5 = "-5" Tm4= "-4" Tm3="-3" Tm2="-2" Tm1="-1" Tp0="0" Tp1="1" Tp2="2" Tp3="3" Tp4="4" Tp5="5" Tp6="6" Tp7 = "7" Tp8 = "8" Tp9 = "9" Tp10 = "10" Tp11 = "11" Tp12 = "12" Tp13 = "13" Tp14 = "14" Tp15 = "15", notick labsize(medsmall)) drop(Pre_avg Post_avg Tm6 Tm7 Tm8 Tm9 Tm10 Tm11 Tm12 Tm12 Tm13 Tm14 Tm15 Tm16 Tm17 Tm18 Tm19 Tm20 Tp16 Tp17 Tp18 Tp19 Tp20) yline(0) xline(6, lcolor(black) lwidth(thin) lpattern(dash)) graphregion(fcolor(white)) xtitle("Years from First Shale Well Completion", size(small)) ytitle("ATT Estimate") xlabel(,labsize(small) angle(vertical)) nolabels title("`j'", size(medsmall)) name("g_`j'") xlabel(,labsize(small) angle(horizontal)) levels(95 90) ciopts(lwidth(2 ..) lcolor(*.3 *.55)) legend(order(1 "95% Confidence Interval" 2 "90% Confidence Interval") rows(1)) msymbol(d) mcolor(white) 
*yscale(r(-.8 .3)) ylabel(-.8 (.2) .4)
}

grc1leg2 num_seen_shale species_seen_shale

grc1leg2 g_inumber_seen_w g_i_species


*Descriptive statistics 
local outcomes "num_tot_w num_grassland_w num_woodland_w num_wetland_w num_otherhabitat_w num_urban_w num_nonurban_w num_resident_w num_shortmigration_w num_longermigration_w spec_tot spec_grassland spec_woodland spec_wetland spec_otherhabitat spec_urban spec_nonurban spec_resident spec_shortmigration spec_longermigration"
foreach b of local outcomes {
    sum `b' if year == 2000 & first_well_year != 0
}


********************************************************************************
*Shale placebo test 
use "Data\Analysis\CBC_Shale_Combined_Characteristics_17_5_Panel.dta", clear

replace Min_snow = 0 if Min_snow == .

*Define treatment by first year in which wells were completed
gen wells_year = .
replace wells_year = year if shale_wells_num > 0
bysort circle_id: egen first_well_year = min(wells_year)
replace first_well_year = 0 if first_well_year == .

gen ihs_shalewells = asinh(shale_wells_num)
gen ihs_cumshalewells = asinh(cum_shalewells)	

*Setup 
estimate drop _all 

local outcomes "ihs_num_tot_w"
foreach j of local outcomes {
	csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(first_well_year) notyet
	csdid_estat simple, estore("`j'_real")
}

forval i = 6/100 {
	
	capture drop random placebo_treated placebo_year_treat_tmp placebo_treated_year
	bysort circle_id: gen random = runiform()

	*Approximately 4% of units are treated. 
	gen placebo_treated = 0
	replace placebo_treated = 1 if random >= 0.961

	bysort circle_id: gen placebo_year_treat_tmp = runiformint(2000, 2020)
	replace placebo_year_treat_tmp = 0 if placebo_treated != 1
	bysort circle_id: egen placebo_treated_year = max(placebo_year_treat_tmp)

	local outcomes "ihs_num_tot_w"
	foreach j of local outcomes {
		csdid `j' total_effort_counters Min_temp Max_temp Max_wind Max_snow, ivar(circle_id) time(year) gvar(placebo_treated_year) notyet
		csdid_estat simple, estore("`j'_`i'")
	}

}

estimates save "Output/Output_Shale_Placebo_Estimates", replace 


*Placebo Test
grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color black black black black black black black black black black black black black black black black black black black black black black black
grstyle set symbol, n(1)
grstyle set compact
coefplot ihs_num_tot_w_real ihs_num_tot_w_95 ihs_num_tot_w_43 ihs_num_tot_w_82 ihs_num_tot_w_2 ihs_num_tot_w_86 ihs_num_tot_w_97 ihs_num_tot_w_13 ihs_num_tot_w_81 ihs_num_tot_w_79 ihs_num_tot_w_61 ihs_num_tot_w_52 ihs_num_tot_w_64 ihs_num_tot_w_12 ihs_num_tot_w_56 ihs_num_tot_w_18 ihs_num_tot_w_67 ihs_num_tot_w_37 ihs_num_tot_w_73 ihs_num_tot_w_35 ihs_num_tot_w_1 ihs_num_tot_w_84 ihs_num_tot_w_51 ihs_num_tot_w_69 ihs_num_tot_w_91 ihs_num_tot_w_68 ihs_num_tot_w_32 ihs_num_tot_w_17 ihs_num_tot_w_36 ihs_num_tot_w_71 ihs_num_tot_w_93 ihs_num_tot_w_62 ihs_num_tot_w_44 ihs_num_tot_w_16 ihs_num_tot_w_49 ihs_num_tot_w_74 ihs_num_tot_w_89 ihs_num_tot_w_24 ihs_num_tot_w_96 ihs_num_tot_w_42 ihs_num_tot_w_57 ihs_num_tot_w_33 ihs_num_tot_w_59 ihs_num_tot_w_41 ihs_num_tot_w_60 ihs_num_tot_w_47 ihs_num_tot_w_8 ihs_num_tot_w_21 ihs_num_tot_w_27 ihs_num_tot_w_78 ihs_num_tot_w_63 ihs_num_tot_w_31 ihs_num_tot_w_26 ihs_num_tot_w_20 ihs_num_tot_w_14 ihs_num_tot_w_99 ihs_num_tot_w_87 ihs_num_tot_w_46 ihs_num_tot_w_34 ihs_num_tot_w_100 ihs_num_tot_w_38 ihs_num_tot_w_23 ihs_num_tot_w_92 ihs_num_tot_w_55 ihs_num_tot_w_75 ihs_num_tot_w_10 ihs_num_tot_w_30 ihs_num_tot_w_54 ihs_num_tot_w_11 ihs_num_tot_w_77 ihs_num_tot_w_76 ihs_num_tot_w_48 ihs_num_tot_w_15 ihs_num_tot_w_28 ihs_num_tot_w_6 ihs_num_tot_w_70 ihs_num_tot_w_25 ihs_num_tot_w_90 ihs_num_tot_w_50 ihs_num_tot_w_39 ihs_num_tot_w_22 ihs_num_tot_w_3 ihs_num_tot_w_45 ihs_num_tot_w_9 ihs_num_tot_w_85 ihs_num_tot_w_53 ihs_num_tot_w_7 ihs_num_tot_w_66 ihs_num_tot_w_65 ihs_num_tot_w_72 ihs_num_tot_w_40 ihs_num_tot_w_88 ihs_num_tot_w_83 ihs_num_tot_w_4 ihs_num_tot_w_80 ihs_num_tot_w_5 ihs_num_tot_w_19 ihs_num_tot_w_29 ihs_num_tot_w_98 ihs_num_tot_w_94 ihs_num_tot_w_58, vertical sort(1, descending) yline(0) ytitle("ATT Estimate with 95% CI") xtitle("Iterations") legend(off) levels(90) ciopts(lwidth(1 ..) lcolor(*.3)) msize(.5) mcolor(gs7) xlabel("") yscale(r(-0.3 .1)) ylabel(-.3 (.05) .1)

********************************************************************************
*Breeding Bird Surveys 
use "Data\Analysis\BreedingSurvey_Shale_5_Panel.dta", clear

*Define treatment by first year in which wells were completed
gen wells_year = .
replace wells_year = year if shale_wells_num > 0
bysort unique_route_id: egen first_well_year = min(wells_year)
replace first_well_year = 0 if first_well_year == .

gen ihs_shalewells = asinh(shale_wells_num)
gen ihs_cumshalewells = asinh(cum_shalewells)
gen ihs_number_seen = asinh(number_seen)
gen ihs_species_seen = asinh(species_counter)	

egen unique_id = group(unique_route_id)

*Setup 
set seed 39627236
estimate drop _all 

*Number seen 
local outcomes "ihs_number_seen ihs_species_seen"
foreach j of local outcomes {
	csdid `j', ivar(unique_id) time(year) gvar(first_well_year) notyet
	csdid_estat simple, estore("`j'")
}

*10km buffer
use "Data\Analysis\BreedingSurvey_Shale_10_Panel.dta", clear

*Define treatment by first year in which wells were completed
gen wells_year = .
replace wells_year = year if shale_wells_num > 0
bysort unique_route_id: egen first_well_year = min(wells_year)
replace first_well_year = 0 if first_well_year == .

gen ihs_shalewells = asinh(shale_wells_num)
gen ihs_cumshalewells = asinh(cum_shalewells)
gen ihs_number_seen = asinh(number_seen)
gen ihs_species_seen = asinh(species_counter)	

egen unique_id = group(unique_route_id)

*Setup 
set seed 39627236
estimate drop _all 

*Number seen 
local outcomes "ihs_number_seen ihs_species_seen"
foreach j of local outcomes {
	csdid `j', ivar(unique_id) time(year) gvar(first_well_year) notyet
	csdid_estat simple, estore("`j'")
}

*Continuous treatment 	
local outcomes "ihs_number_seen ihs_species_seen"
foreach k of local outcomes {
    didregress (`k') (ihs_cumshalewells, continuous), group(unique_id) time(year) vce(cluster unique_id)
	est store `k'
}
