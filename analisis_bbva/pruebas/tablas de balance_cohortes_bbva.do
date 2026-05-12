*******************************************************
* BBVA - Tablas de balance pairwise incondicionales en t=6
* Referencia: cohorte Noviembre 2024 (first_trat_grp==13)
* Comparaciones separadas para evitar bugs del loop
*******************************************************

version 18
set more off

*------------------------------------------------------*
* 1) Variables para balance
*------------------------------------------------------*
local vars_pre ///
    interesrev rpagomin_w totalero totalero_alt ruso ctar delinquent ///
    limcreditocorte saldototcorte compme edad ingresocliente mujeres

*------------------------------------------------------*
* 2) Nombres amigables
*------------------------------------------------------*
local pretty_interesrev      "Intereses cargados"
local pretty_rpagomin_w      "Razón de pago sobre el mínimo"
local pretty_totalero        "Totalero (sin cargo de interés revolvente)"
local pretty_totalero_alt    "Totalero (paga al menos el PNGI)"
local pretty_ruso            "Razón de uso"
local pretty_ctar            "Pago tardío"
local pretty_delinquent      "Impago"
local pretty_limcreditocorte "Límite de crédito"
local pretty_saldototcorte   "Saldo total"
local pretty_compme          "Compras a meses"
local pretty_edad            "Edad"
local pretty_ingresocliente  "Ingreso mensual"
local pretty_mujeres         "Género"

*------------------------------------------------------*
* 3) Ruta de salida
*------------------------------------------------------*
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Tables"
cap mkdir "`outdir'"

********************************************************************************
* A) JUNIO 2024 vs NOVIEMBRE 2024
********************************************************************************
capture drop _grp_bbva
gen byte _grp_bbva = .
replace _grp_bbva = 0 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==13 & eleg_bbva_base == 1
replace _grp_bbva = 1 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==8 & eleg_bbva_base == 1

cap frame drop _bbva_bal_jun_nov
frame create _bbva_bal_jun_nov ///
    str120 varlabel ///
    long N_ref N_cmp ///
    double mean_ref mean_cmp ///
    double diff_u p_u smd

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if _grp_bbva==0
    local mean_ref = r(mean)
    local N_ref    = r(N)
    local sd_ref   = r(sd)

    quietly summarize `y' if _grp_bbva==1
    local mean_cmp = r(mean)
    local N_cmp    = r(N)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    capture quietly ttest `y' if inlist(_grp_bbva,0,1), by(_grp_bbva)
    if _rc local p_u = .
    else   local p_u = r(p)

    frame post _bbva_bal_jun_nov ///
        ("`yl'") ///
        (`N_ref') (`N_cmp') ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`p_u') (`smd_')
}

frame change _bbva_bal_jun_nov
label var varlabel  "Variable"
label var mean_ref  "Promedio (Noviembre 2024)"
label var N_ref     "N (Noviembre 2024)"
label var mean_cmp  "Promedio (Junio 2024)"
label var N_cmp     "N (Junio 2024)"
label var diff_u    "Dif. incond. (Junio - Noviembre)"
label var p_u       "p-value"
label var smd       "SMD"

format mean_ref mean_cmp diff_u %12.4f
format p_u %9.4f
format smd %9.3f
order varlabel mean_ref N_ref mean_cmp N_cmp diff_u p_u smd
list, sep(0)
export excel using "`outdir'\bbva_balance_p6_jun_vs_nov.xlsx", firstrow(varlabels) replace
frame change default
drop _grp_bbva

********************************************************************************
* B) JULIO 2024 vs NOVIEMBRE 2024
********************************************************************************
capture drop _grp_bbva
gen byte _grp_bbva = .
replace _grp_bbva = 0 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==13 & eleg_bbva_base == 1
replace _grp_bbva = 1 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==9 & eleg_bbva_base == 1

cap frame drop _bbva_bal_jul_nov
frame create _bbva_bal_jul_nov ///
    str120 varlabel ///
    long N_ref N_cmp ///
    double mean_ref mean_cmp ///
    double diff_u p_u smd

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if _grp_bbva==0
    local mean_ref = r(mean)
    local N_ref    = r(N)
    local sd_ref   = r(sd)

    quietly summarize `y' if _grp_bbva==1
    local mean_cmp = r(mean)
    local N_cmp    = r(N)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    capture quietly ttest `y' if inlist(_grp_bbva,0,1), by(_grp_bbva)
    if _rc local p_u = .
    else   local p_u = r(p)

    frame post _bbva_bal_jul_nov ///
        ("`yl'") ///
        (`N_ref') (`N_cmp') ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`p_u') (`smd_')
}

frame change _bbva_bal_jul_nov
label var varlabel  "Variable"
label var mean_ref  "Promedio (Noviembre 2024)"
label var N_ref     "N (Noviembre 2024)"
label var mean_cmp  "Promedio (Julio 2024)"
label var N_cmp     "N (Julio 2024)"
label var diff_u    "Dif. incond. (Julio - Noviembre)"
label var p_u       "p-value"
label var smd       "SMD"

format mean_ref mean_cmp diff_u %12.4f
format p_u %9.4f
format smd %9.3f
order varlabel mean_ref N_ref mean_cmp N_cmp diff_u p_u smd
list, sep(0)
export excel using "`outdir'\bbva_balance_p6_jul_vs_nov.xlsx", firstrow(varlabels) replace
frame change default
drop _grp_bbva

********************************************************************************
* C) AGOSTO 2024 vs NOVIEMBRE 2024
********************************************************************************
capture drop _grp_bbva
gen byte _grp_bbva = .
replace _grp_bbva = 0 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==13 & eleg_bbva_base == 1
replace _grp_bbva = 1 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==10 & eleg_bbva_base == 1

cap frame drop _bbva_bal_ago_nov
frame create _bbva_bal_ago_nov ///
    str120 varlabel ///
    long N_ref N_cmp ///
    double mean_ref mean_cmp ///
    double diff_u p_u smd

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if _grp_bbva==0
    local mean_ref = r(mean)
    local N_ref    = r(N)
    local sd_ref   = r(sd)

    quietly summarize `y' if _grp_bbva==1
    local mean_cmp = r(mean)
    local N_cmp    = r(N)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    capture quietly ttest `y' if inlist(_grp_bbva,0,1), by(_grp_bbva)
    if _rc local p_u = .
    else   local p_u = r(p)

    frame post _bbva_bal_ago_nov ///
        ("`yl'") ///
        (`N_ref') (`N_cmp') ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`p_u') (`smd_')
}

frame change _bbva_bal_ago_nov
label var varlabel  "Variable"
label var mean_ref  "Promedio (Noviembre 2024)"
label var N_ref     "N (Noviembre 2024)"
label var mean_cmp  "Promedio (Agosto 2024)"
label var N_cmp     "N (Agosto 2024)"
label var diff_u    "Dif. incond. (Agosto - Noviembre)"
label var p_u       "p-value"
label var smd       "SMD"

format mean_ref mean_cmp diff_u %12.4f
format p_u %9.4f
format smd %9.3f
order varlabel mean_ref N_ref mean_cmp N_cmp diff_u p_u smd
list, sep(0)
export excel using "`outdir'\bbva_balance_p6_ago_vs_nov.xlsx", firstrow(varlabels) replace
frame change default
drop _grp_bbva

********************************************************************************
* D) OCTUBRE 2024 vs NOVIEMBRE 2024
********************************************************************************
capture drop _grp_bbva
gen byte _grp_bbva = .
replace _grp_bbva = 0 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==13 & eleg_bbva_base == 1
replace _grp_bbva = 1 if periodo==6 & papel_may2024_any==1 & bpanel_alt==1 & first_trat_grp==12 & eleg_bbva_base == 1

cap frame drop _bbva_bal_oct_nov
frame create _bbva_bal_oct_nov ///
    str120 varlabel ///
    long N_ref N_cmp ///
    double mean_ref mean_cmp ///
    double diff_u p_u smd

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if _grp_bbva==0
    local mean_ref = r(mean)
    local N_ref    = r(N)
    local sd_ref   = r(sd)

    quietly summarize `y' if _grp_bbva==1
    local mean_cmp = r(mean)
    local N_cmp    = r(N)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    capture quietly ttest `y' if inlist(_grp_bbva,0,1), by(_grp_bbva)
    if _rc local p_u = .
    else   local p_u = r(p)

    frame post _bbva_bal_oct_nov ///
        ("`yl'") ///
        (`N_ref') (`N_cmp') ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`p_u') (`smd_')
}

frame change _bbva_bal_oct_nov
label var varlabel  "Variable"
label var mean_ref  "Promedio (Noviembre 2024)"
label var N_ref     "N (Noviembre 2024)"
label var mean_cmp  "Promedio (Octubre 2024)"
label var N_cmp     "N (Octubre 2024)"
label var diff_u    "Dif. incond. (Octubre - Noviembre)"
label var p_u       "p-value"
label var smd       "SMD"

format mean_ref mean_cmp diff_u %12.4f
format p_u %9.4f
format smd %9.3f
order varlabel mean_ref N_ref mean_cmp N_cmp diff_u p_u smd
list, sep(0)
export excel using "`outdir'\bbva_balance_p6_oct_vs_nov.xlsx", firstrow(varlabels) replace
frame change default
drop _grp_bbva

*******************************************************
* Fin
*******************************************************