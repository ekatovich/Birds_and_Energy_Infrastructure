*Set working directory
clear
cd "${user}\Data"

********************************************************************************
*Import and Clean Effort data
*First, 101-104
clear
import excel "Raw\US-101-104-CBC_Effort_Report_SQL_updated-1.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

drop Count_yr 

order circle circle_name year

save "Intermediate\Effort_2000_to_2003", replace 

********************************************************************************
clear
import excel "Raw\US-105-106-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2004_to_2005", replace 

********************************************************************************
clear
import excel "Raw\US-107-108-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2006_to_2007", replace 

********************************************************************************
clear
import excel "Raw\US-109-110-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2008_to_2009", replace 

********************************************************************************
clear
import excel "Raw\US-111-112-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2010_to_2011", replace 

********************************************************************************
clear
import excel "Raw\US-113-114-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2012_to_2013", replace 

********************************************************************************
clear
import excel "Raw\US-115-116-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2014_to_2015", replace 


********************************************************************************
clear
import excel "Raw\US-117-118-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2016_to_2017", replace 

********************************************************************************
clear
import excel "Raw\US-119-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2018", replace 

********************************************************************************
clear
import excel "Raw\US-120-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2019", replace 


********************************************************************************
clear
import excel "Raw\US-121-CBC_Effort_Report_SQL_updated-1", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr
drop Country_code 
rename Field_counters num_counters_field
rename Feeder_counters num_counters_feeder
rename Min_parties min_parties
rename Max_parties max_parties
rename Feeder_hrs hrs_feeder
rename Nocturnal_hrs hrs_noctural
rename Nocturnal_distance dist_noctural

order circle circle_name year

save "Intermediate\Effort_2020", replace 

********************************************************************************
*Append all effort variables into panel 
use "Intermediate\Effort_2000_to_2003", clear 
append using "Intermediate\Effort_2004_to_2005", force 
append using "Intermediate\Effort_2006_to_2007", force 
append using "Intermediate\Effort_2008_to_2009", force 
append using "Intermediate\Effort_2010_to_2011", force 
append using "Intermediate\Effort_2012_to_2013", force 
append using "Intermediate\Effort_2014_to_2015", force 
append using "Intermediate\Effort_2016_to_2017", force 
append using "Intermediate\Effort_2018", force 
append using "Intermediate\Effort_2019", force 
append using "Intermediate\Effort_2020", force 

sort circle year

duplicates drop circle year, force 

save "Intermediate\Effort_Panel", replace 
