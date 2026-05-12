*******************************************************
* Versión simple y funcional (sin comillas en listas)
*******************************************************
clear all
set more off
#delimit cr

* Rutas
local inpath  "//bmstatadgasf2/Datos_STATA_DGASF/BASESFUENTE/BANXICO/RIBTC/RIBTC_Mensual"
local outpath "//bmstatadgasf2/Datos_STATA_DGASF/BASESFUENTE/BANXICO/RIBTC/CarlosArturo/2024/bases"

* CSV en orden (SIN comillas)
local csvs ///
TC-JUN2023-051225bim.csv ///
TC-AGO2023-051225bim.csv ///
TC-OCT2023-051225bim.csv ///
TC-DIC2023-301025bim.csv ///
TC-FEB2024-301025bim.csv ///
TC-ABR2024-301025bim.csv ///
TC-MAY2024-140126.csv ///
TC-JUN2024-140126.csv ///
TC-JUL2024-140126.csv ///
TC-AGO2024-140126.csv ///
TC-SEP2024-140126.csv ///
TC-OCT2024-140126.csv ///
TC-NOV2024-140126.csv ///
TC-DIC2024-140126.csv ///
TC-ENE2025-140126.csv ///
TC-FEB2025-140126.csv ///
TC-MAR2025-140126.csv ///
TC-ABR2025-140126.csv ///
TC-MAY2025-140126.csv ///
TC-JUN2025-140126.csv

* Nombres de salida .dta en orden (SIN comillas)
local dta ///
jun23 ago23 oct23 dic23 feb24 abr24 may24 jun24 jul24 ago24 ///
sep24 oct24 nov24 dic24 ene25 feb25 mar25 abr25 may25 jun25

* Validación de longitud de listas
local n_csv : word count `csvs'
local n_dta : word count `dta'
if (`n_csv' != `n_dta') {
    di as error "No coincide número de CSV (`n_csv') y DTA (`n_dta')."
    exit 198
}

*******************************************************
* 1) Crear .dta por periodo
*******************************************************
forvalues i = 1/`n_csv' {
    local f : word `i' of `csvs'
    local o : word `i' of `dta'

    capture confirm file "`inpath'/`f'"
    if _rc {
        di as error "No existe archivo: `inpath'/`f'"
        exit 601
    }

    di as txt "Procesando `i'/`n_csv' -> `f'"
    import delimited using "`inpath'/`f'", clear

    * Compatibilidad mínima por si viene INST en mayúscula
    capture confirm variable inst
    if _rc {
        capture confirm variable INST
        if !_rc {
            rename INST inst
        }
    }

    * Si inst viene string, convertir
    capture confirm numeric variable inst
    if _rc {
        destring inst, replace force
    }

    keep if inst==40012 | inst==40072
    gen int periodo = `i'

    save "`outpath'/`o'.dta", replace
}

*******************************************************
* 2) Append de todos los .dta y guardar panel
*******************************************************
clear all
local first : word 1 of `dta'
use "`outpath'/`first'.dta", clear

forvalues i = 2/`n_dta' {
    local o : word `i' of `dta'
    append using "`outpath'/`o'.dta"
}

save "`outpath'/panelexp.dta", replace
di as result "Listo: `outpath'/panelexp.dta"

