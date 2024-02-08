clear 
import delimited "${user}\Data\Analysis\News_Coverage.csv"


grstyle init
grstyle set plain, nogrid noextend
grstyle set legend 6, nobox
grstyle set color blue cranberry 
grstyle set symbol, n(1)
grstyle set compact
twoway line wind shale year, xtitle("Year") ytitle("Number of News Stories") title("{bf: D. US News Coverage of Wind and Shale Effects on Birds}")  xscale(r(2000 2022)) xlabel(2000 (2) 2022)