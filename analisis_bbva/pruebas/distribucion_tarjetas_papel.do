*******************************************************
* BBVA - Tabla introductoria para usuarios de estado de cuenta en papel
* Periodos desde t=6 (abril 2024), porque antes la variable de papel
* no tiene buena calidad para BBVA.
*
* Tabla:
*   Periodo
*   Papel + estado anterior
*   Papel + ECE
*   Total papel
*   % de papel con ECE
*******************************************************

version 18
set more off

*------------------------------------------------------*
* 1) Define aquí los nombres de variables
*------------------------------------------------------*
* Usa la variable de papel que vayas a usar en BBVA
local papervar edocta_papel
* Si prefieres la versión corregida, cambia por:
* local papervar edocta_papel_fix

* Usa la variable de tratamiento/ECE que estés usando
local ecevar edoctanvo
* Si prefieres la versión corregida, cambia por:
* local ecevar edoctanvo_fix

* Identificador de BBVA (si tu base tiene varios emisores)
local bbva_filt inst==40012

* Ventana para la tabla introductoria
local pmin 6
local pmax 13

*------------------------------------------------------*
* 2) Crear frame auxiliar
*------------------------------------------------------*
cap frame drop _bbva_papel
frame put periodo `papervar' `ecevar' inst ///
    if `bbva_filt' & inrange(periodo,`pmin',`pmax'), into(_bbva_papel)

frame change _bbva_papel

*------------------------------------------------------*
* 3) Construir componentes de la tabla
*------------------------------------------------------*
gen byte papel_old   = (`papervar'==1 & `ecevar'==0) if inrange(periodo,`pmin',`pmax')
gen byte papel_ece   = (`papervar'==1 & `ecevar'==1) if inrange(periodo,`pmin',`pmax')
gen byte papel_total = (`papervar'==1)               if inrange(periodo,`pmin',`pmax')

collapse (sum) papel_old papel_ece papel_total, by(periodo)

gen pct_papel_ece = 100*papel_ece/papel_total if papel_total>0

*------------------------------------------------------*
* 4) Etiquetas bonitas
*------------------------------------------------------*
capture decode periodo, gen(periodo_lbl)
if _rc {
    tostring periodo, gen(periodo_lbl)
}

label var periodo_lbl   "Periodo"
label var papel_old     "Papel + estado anterior"
label var papel_ece     "Papel + ECE"
label var papel_total   "Total papel"
label var pct_papel_ece "% papel con ECE"

format papel_old papel_ece papel_total %15.0fc
format pct_papel_ece %9.2f

order periodo_lbl papel_old papel_ece papel_total pct_papel_ece

list periodo_lbl papel_old papel_ece papel_total pct_papel_ece, noobs sep(0)

*------------------------------------------------------*
* 5) Exportar
*------------------------------------------------------*
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Tables"
cap mkdir "`outdir'"

export excel periodo_lbl papel_old papel_ece papel_total pct_papel_ece ///
    using "`outdir'\bbva_tabla_intro_papel.xlsx", ///
    firstrow(varlabels) replace

frame change default
*******************************************************






* Cohortes agrupadas para BBVA
* - incluye 7 dentro de 8
* - incluye 11 dentro de 12

capture drop first_trat_grp
gen byte first_trat_grp = first_trat

replace first_trat_grp = 8  if first_trat == 7
replace first_trat_grp = 12 if first_trat == 11

label define lbl_first_trat_grp ///
    8  "Junio 2024" ///
    9  "Julio 2024" ///
    10 "Agosto 2024" ///
    12 "Octubre 2024" ///
    13 "Noviembre 2024", replace
label values first_trat_grp lbl_first_trat_grp


tab first_trat_grp if papel_may2024_any==1 & bpanel_alt==1 & periodo==6























