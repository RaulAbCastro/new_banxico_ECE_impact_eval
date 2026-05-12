

*jun23
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-JUN2023-051225bim.csv"
keep if inst==40012|inst==40072 
gen periodo=1

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jun23.dta", replace

*ago23
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-AGO2023-051225bim.csv"  
keep if inst==40012|inst==40072 
gen periodo=2

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\ago23.dta", replace


*oct23
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-OCT2023-051225bim.csv"
keep if inst==40012|inst==40072 
gen periodo=3

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\oct23.dta", replace


*dic23
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-DIC2023-301025bim.csv" 
keep if inst==40012|inst==40072 
gen periodo=4

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\dic23.dta", replace


*feb24
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-FEB2024-301025bim.csv"
keep if inst==40012|inst==40072 
gen periodo=5

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\feb24.dta", replace

*abr2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-ABR2024-301025bim.csv"
keep if inst==40012|inst==40072 
gen periodo=6

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\abr24.dta", replace


*May2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-MAY2024-140126.csv"
keep if inst==40012|inst==40072 
gen periodo=7

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\may24.dta", replace


*jun2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-JUN2024-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=8

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jun24.dta", replace


*jul2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-JUL2024-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=9

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jul24.dta", replace

*ago2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-AGO2024-140126.csv"
keep if inst==40012|inst==40072 
gen periodo=10

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\ago24.dta", replace


*sep2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-SEP2024-140126.csv"
keep if inst==40012|inst==40072 
gen periodo=11

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\sep24.dta", replace


*oct2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-OCT2024-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=12

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\oct24.dta", replace


*nov2024
clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-NOV2024-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=13

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\nov24.dta", replace

*dic2024

clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-DIC2024-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=14

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\dic24.dta", replace

*Ene2025

clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-ENE2025-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=15

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\ene25.dta", replace

*feb2025

clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-FEB2025-140126.csv"
keep if inst==40012|inst==40072 
gen periodo=16

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\feb25.dta", replace


*Mar2025

clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-MAR2025-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=17

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\mar25.dta", replace


*abr2025

clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-ABR2025-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=18

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\abr25.dta", replace

*may2025

clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-MAY2025-140126.csv" 
keep if inst==40012|inst==40072 
gen periodo=19

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\may25.dta", replace

*june2025

clear all
import delimited "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\RIBTC_Mensual\TC-JUN2025-140126.csv"
keep if inst==40012|inst==40072 
gen periodo=20

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jun25.dta", replace


***, delimiter(",") 
******************************************************************
*************

clear all
use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jun23.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\ago23.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\oct23.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\dic23.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\feb24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\abr24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\may24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jun24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jul24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\ago24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\sep24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\oct24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\nov24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\dic24.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\ene25.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\feb25.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\mar25.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\abr25.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\may25.dta"
append using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\jun25.dta"

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\panelexp.dta", replace


