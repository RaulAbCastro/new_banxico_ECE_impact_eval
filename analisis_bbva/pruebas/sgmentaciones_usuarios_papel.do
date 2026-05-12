*******************************************************
* BBVA - Tabla de reducción por cohorte al imponer
* criterio de elegibilidad adicional
*
* Columnas:
*   1) Cohorte
*   2) N con filtros base:
*        - papel_may2024_any==1
*        - bpanel_alt==1
*   3) N con filtros base + elegibilidad:
*        - eleg_bbva_base==1
*   4) % de reducción
*******************************************************

version 18
set more off

*------------------------------------------------------*
* 1) Ajusta aquí si cambiaste el nombre de la variable
*    de elegibilidad
*------------------------------------------------------*
local eligvar eleg_bbva_base

*------------------------------------------------------*
* 2) Crear frame auxiliar con una sola observación por tarjeta
*    usando periodo 6 como ancla
*------------------------------------------------------*
cap frame drop _bbva_cohort_red
frame put first_trat_grp papel_may2024_any bpanel_alt `eligvar' periodo ///
    if periodo==6, into(_bbva_cohort_red)

frame change _bbva_cohort_red

*------------------------------------------------------*
* 3) Generar indicadores de conteo
*------------------------------------------------------*
gen byte n_base = (papel_may2024_any==1 & bpanel_alt==1 & !missing(first_trat_grp))
gen byte n_eleg = (papel_may2024_any==1 & bpanel_alt==1 & `eligvar'==1 & !missing(first_trat_grp))

*------------------------------------------------------*
* 4) Colapsar por cohorte
*------------------------------------------------------*
collapse (sum) n_base n_eleg, by(first_trat_grp)

*------------------------------------------------------*
* 5) Etiqueta de cohorte en texto
*------------------------------------------------------*
capture decode first_trat_grp, gen(cohorte)
if _rc {
    tostring first_trat_grp, gen(cohorte)
}

*------------------------------------------------------*
* 6) % de reducción
*------------------------------------------------------*
gen pct_reduccion = 100*(n_base - n_eleg)/n_base if n_base>0

*------------------------------------------------------*
* 7) Ordenar cohortes
*------------------------------------------------------*
sort first_trat_grp

*------------------------------------------------------*
* 8) Agregar fila de total
*------------------------------------------------------*
quietly count
local N = r(N)
set obs `=`N'+1'

replace cohorte = "Total" in `=`N'+1'
quietly summarize n_base in 1/`N'
replace n_base = r(sum) in `=`N'+1'
quietly summarize n_eleg in 1/`N'
replace n_eleg = r(sum) in `=`N'+1'
replace pct_reduccion = 100*(n_base - n_eleg)/n_base in `=`N'+1' if n_base[`=`N'+1']>0

*------------------------------------------------------*
* 9) Etiquetas y formato
*------------------------------------------------------*
label var cohorte       "Primer periodo tratado"
label var n_base        "Numero de tarjetas (papel + panel balanceado)"
label var n_eleg        "Numero de tarjetas (con criterio de elegibilidad)"
label var pct_reduccion "% de reducción"

format n_base n_eleg %15.0fc
format pct_reduccion %9.2f

order cohorte n_base n_eleg pct_reduccion

list cohorte n_base n_eleg pct_reduccion, noobs sep(0)

*------------------------------------------------------*
* 10) Exportar a Excel
*------------------------------------------------------*
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Tables"
cap mkdir "`outdir'"

export excel cohorte n_base n_eleg pct_reduccion ///
    using "`outdir'\bbva_reduccion_cohortes_elegibilidad.xlsx", ///
    firstrow(varlabels) replace

frame change default
*******************************************************





*******************************************************
* BBVA - Soporte de segmentos pretratamiento por cohorte
* Revisión en t=6 dentro del universo elegible
*******************************************************

version 18
set more off

*------------------------------------------------------*
* 1) Filtro base
*------------------------------------------------------*
local filt periodo==6 & eleg_bbva_base==1 & inlist(first_trat_grp,8,9,10,12,13)

*------------------------------------------------------*
* 2) Tabulados simples por cohorte
*------------------------------------------------------*
display "========================================"
display "Distribucion de clase por cohorte"
tab first_trat_grp seg_clase_t6 if `filt', row missing

display "========================================"
display "Distribucion de cuartiles de limite de credito por cohorte"
tab first_trat_grp seg_limcred_q_t6 if `filt', row missing

display "========================================"
display "Distribucion de cuartiles de razon de uso por cohorte"
tab first_trat_grp seg_ruso_q_t6 if `filt', row missing

display "========================================"
display "Distribucion de totalero pretratamiento por cohorte"
tab first_trat_grp seg_totalero_pre6 if `filt', row missing

*------------------------------------------------------*
* 3) Tabulados con conteos absolutos
*------------------------------------------------------*
display "========================================"
display "Conteos absolutos: clase por cohorte"
tab first_trat_grp seg_clase_t6 if `filt', missing

display "========================================"
display "Conteos absolutos: cuartiles de limite por cohorte"
tab first_trat_grp seg_limcred_q_t6 if `filt', missing

display "========================================"
display "Conteos absolutos: cuartiles de uso por cohorte"
tab first_trat_grp seg_ruso_q_t6 if `filt', missing

display "========================================"
display "Conteos absolutos: totalero pretratamiento por cohorte"
tab first_trat_grp seg_totalero_pre6 if `filt', missing

*------------------------------------------------------*
* 4) Tamaño total por cohorte en la muestra elegible
*------------------------------------------------------*
display "========================================"
display "Numero total de tarjetas por cohorte en t=6"
tab first_trat_grp if `filt', missing
*******************************************************

























