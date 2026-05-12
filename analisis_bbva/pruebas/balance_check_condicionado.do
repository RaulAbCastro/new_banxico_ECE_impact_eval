*******************************************************
* BBVA - Tablas de balance pairwise ajustadas en t=6
* Ajuste con segmentos pretratamiento ampliados
* pero SIN clase
*******************************************************

version 18
set more off

local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Tables"
cap mkdir "`outdir'"

local vars_pre ///
    interesrev rpagomin_w totalero totalero_alt ruso ctar delinquent ///
    limcreditocorte saldototcorte compme edad ingresocliente mujeres

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

local segs_full_noclase ///
    i.seg_limcred_q_t6 ///
    i.seg_ruso_q_t6 ///
    i.seg_totalero_pre6 ///
    i.seg_ingreso_q_t6 ///
    i.seg_edad_q_t6 ///
    i.seg_antig_t6 ///
    i.compme_t6 ///
    i.mujeres_t6

*******************************************************
* A) JUNIO vs NOVIEMBRE
*******************************************************
capture drop grp_bbva
gen byte grp_bbva = .
replace grp_bbva = 0 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==13
replace grp_bbva = 1 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==8

cap frame drop _bjnfsn
frame create _bjnfsn ///
    str120 varlabel ///
    double mean_ref mean_cmp ///
    double diff_u smd ///
    double diff_a p_a

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if grp_bbva==0
    local mean_ref = r(mean)
    local sd_ref   = r(sd)

    quietly summarize `y' if grp_bbva==1
    local mean_cmp = r(mean)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    quietly regress `y' grp_bbva `segs_full_noclase' if inlist(grp_bbva,0,1), vce(robust)
    local diff_a = _b[grp_bbva]
    local p_a    = 2*ttail(e(df_r), abs(_b[grp_bbva]/_se[grp_bbva]))

    frame post _bjnfsn ///
        ("`yl'") ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}
drop grp_bbva

frame change _bjnfsn
label var varlabel "Variable"
label var mean_ref "Promedio (Noviembre 2024)"
label var mean_cmp "Promedio (Junio 2024)"
label var diff_u   "Dif. incond. (Junio - Noviembre)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada (Junio - Noviembre)"
label var p_a      "p ajustada"
format mean_ref mean_cmp diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f
order varlabel mean_ref mean_cmp diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\bbva_balance_adj_p6_jun_vs_nov_fullseg_noclase.xlsx", firstrow(varlabels) replace
frame change default

*******************************************************
* B) JULIO vs NOVIEMBRE
*******************************************************
capture drop grp_bbva
gen byte grp_bbva = .
replace grp_bbva = 0 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==13
replace grp_bbva = 1 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==9

cap frame drop _bjlfsn
frame create _bjlfsn ///
    str120 varlabel ///
    double mean_ref mean_cmp ///
    double diff_u smd ///
    double diff_a p_a

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if grp_bbva==0
    local mean_ref = r(mean)
    local sd_ref   = r(sd)

    quietly summarize `y' if grp_bbva==1
    local mean_cmp = r(mean)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    quietly regress `y' grp_bbva `segs_full_noclase' if inlist(grp_bbva,0,1), vce(robust)
    local diff_a = _b[grp_bbva]
    local p_a    = 2*ttail(e(df_r), abs(_b[grp_bbva]/_se[grp_bbva]))

    frame post _bjlfsn ///
        ("`yl'") ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}
drop grp_bbva

frame change _bjlfsn
label var varlabel "Variable"
label var mean_ref "Promedio (Noviembre 2024)"
label var mean_cmp "Promedio (Julio 2024)"
label var diff_u   "Dif. incond. (Julio - Noviembre)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada (Julio - Noviembre)"
label var p_a      "p ajustada"
format mean_ref mean_cmp diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f
order varlabel mean_ref mean_cmp diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\bbva_balance_adj_p6_jul_vs_nov_fullseg_noclase.xlsx", firstrow(varlabels) replace
frame change default

*******************************************************
* C) AGOSTO vs NOVIEMBRE
*******************************************************
capture drop grp_bbva
gen byte grp_bbva = .
replace grp_bbva = 0 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==13
replace grp_bbva = 1 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==10

cap frame drop _bagnfsn
frame create _bagnfsn ///
    str120 varlabel ///
    double mean_ref mean_cmp ///
    double diff_u smd ///
    double diff_a p_a

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if grp_bbva==0
    local mean_ref = r(mean)
    local sd_ref   = r(sd)

    quietly summarize `y' if grp_bbva==1
    local mean_cmp = r(mean)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    quietly regress `y' grp_bbva `segs_full_noclase' if inlist(grp_bbva,0,1), vce(robust)
    local diff_a = _b[grp_bbva]
    local p_a    = 2*ttail(e(df_r), abs(_b[grp_bbva]/_se[grp_bbva]))

    frame post _bagnfsn ///
        ("`yl'") ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}
drop grp_bbva

frame change _bagnfsn
label var varlabel "Variable"
label var mean_ref "Promedio (Noviembre 2024)"
label var mean_cmp "Promedio (Agosto 2024)"
label var diff_u   "Dif. incond. (Agosto - Noviembre)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada (Agosto - Noviembre)"
label var p_a      "p ajustada"
format mean_ref mean_cmp diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f
order varlabel mean_ref mean_cmp diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\bbva_balance_adj_p6_ago_vs_nov_fullseg_noclase.xlsx", firstrow(varlabels) replace
frame change default

*******************************************************
* D) OCTUBRE vs NOVIEMBRE
*******************************************************
capture drop grp_bbva
gen byte grp_bbva = .
replace grp_bbva = 0 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==13
replace grp_bbva = 1 if periodo==6 & eleg_bbva_base==1 & first_trat_grp==12

cap frame drop _boctfsn
frame create _boctfsn ///
    str120 varlabel ///
    double mean_ref mean_cmp ///
    double diff_u smd ///
    double diff_a p_a

foreach y of local vars_pre {
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if grp_bbva==0
    local mean_ref = r(mean)
    local sd_ref   = r(sd)

    quietly summarize `y' if grp_bbva==1
    local mean_cmp = r(mean)
    local sd_cmp   = r(sd)

    local diff_u = `mean_cmp' - `mean_ref'
    local denom = sqrt((`sd_cmp'^2 + `sd_ref'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_cmp' - `mean_ref')/`denom')

    quietly regress `y' grp_bbva `segs_full_noclase' if inlist(grp_bbva,0,1), vce(robust)
    local diff_a = _b[grp_bbva]
    local p_a    = 2*ttail(e(df_r), abs(_b[grp_bbva]/_se[grp_bbva]))

    frame post _boctfsn ///
        ("`yl'") ///
        (`mean_ref') (`mean_cmp') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}
drop grp_bbva

frame change _boctfsn
label var varlabel "Variable"
label var mean_ref "Promedio (Noviembre 2024)"
label var mean_cmp "Promedio (Octubre 2024)"
label var diff_u   "Dif. incond. (Octubre - Noviembre)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada (Octubre - Noviembre)"
label var p_a      "p ajustada"
format mean_ref mean_cmp diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f
order varlabel mean_ref mean_cmp diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\bbva_balance_adj_p6_oct_vs_nov_fullseg_noclase.xlsx", firstrow(varlabels) replace
frame change default

*******************************************************
* Fin
*******************************************************
