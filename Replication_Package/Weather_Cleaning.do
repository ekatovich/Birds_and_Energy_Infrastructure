*Set working directory
clear
cd "${user}\Data"

********************************************************************************
*Import and Clean Species Data
*First, 101-105 counts
import excel "Raw\US-101-105-CBC_Weather_Report_SQL.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr

order circle circle_name year 

save "Intermediate\Weather_2000_to_2004", replace 

********************************************************************************
*106-110 counts 
clear
import excel "Raw\US-106-110-CBC_Weather_Report_SQL.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr

order circle circle_name year 

save "Intermediate\Weather_2005_to_2009", replace 

********************************************************************************
*111-115 counts 
clear
import excel "Raw\US-111-115-CBC_Weather_Report_SQL.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr

order circle circle_name year 

save "Intermediate\Weather_2010_to_2014", replace 

********************************************************************************
*116-119 counts 
clear
import excel "Raw\US-116-119-CBC_Weather_Report_SQL.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr

order circle circle_name year 

save "Intermediate\Weather_2015_to_2018", replace 

********************************************************************************
*120 counts 
clear
import excel "Raw\US-120-CBC_Weather_Report_SQL.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr

order circle circle_name year 

save "Intermediate\Weather_2019", replace 

********************************************************************************
*121 counts 
clear
import excel "Raw\US-121-CBC_Weather_Report_SQL.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
gen year = Count_yr + 1899
drop Count_yr

order circle circle_name year 

save "Intermediate\Weather_2020", replace 

********************************************************************************
*Append into weather panel 
use "Intermediate\Weather_2000_to_2004", clear
append using "Intermediate\Weather_2005_to_2009", force 
append using "Intermediate\Weather_2010_to_2014", force 
append using "Intermediate\Weather_2015_to_2018", force 
append using "Intermediate\Weather_2019", force 
append using "Intermediate\Weather_2020", force 

sort circle year

save "Intermediate\Weather_Panel", replace 