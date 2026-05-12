*******************************************************
* BANORTE - 4 tablas de balance pretratamiento (periodo 6)
* Universo elegible + panel comparable
* Ajuste con estratos proxy del panel
*******************************************************

version 18
set more off

*======================================================
* 0) Variables en el orden solicitado
*======================================================
local vars_pre ///
    interesrev rpagomin_w totalero totalero_alt ruso ctar delinquent ///
    limcreditocorte saldototcorte compme edad ingresocliente mujeres

*======================================================
* 1) Etiquetas de valores
*======================================================
capture label define lbl_mujeres 0 "Hombre" 1 "Mujer", replace
capture label values mujeres lbl_mujeres

capture label define lbl_compme 0 "Sin compras a meses" 1 "Con compras a meses", replace
capture label values compme lbl_compme

*======================================================
* 2) Nombres amigables EXACTOS
*======================================================
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

*======================================================
* 3) Variable base de tratamiento_set1 "limpia"
*    Missing -> 0 SOLO dentro de elegibles
*======================================================
tempvar trset1
gen byte `trset1' = .
replace `trset1' = cond(missing(tratamiento_set1), 0, tratamiento_set1) if flg_elegible_1==1

*======================================================
* 4) Filtro base
*======================================================
local basefilt (flg_elegible_1==1 & bpanel_alt==1 & periodo==6)

*======================================================
* 5) Estratos proxy para ajuste
*======================================================
local prox_strata i.estrato_gama i.estrato_limcred4 i.estrato_multitarjeta i.estrato_comp4

*======================================================
* 6) Ruta de salida
*======================================================
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_banorte\Tables"
cap mkdir "`outdir'"

********************************************************************************
* TABLA 1: Tratamiento original vs tratamiento adicional
********************************************************************************
tempvar grp12
gen byte `grp12' = .
replace `grp12' = 0 if `basefilt' & `trset1'==1
replace `grp12' = 1 if `basefilt' & `trset1'==2

local filt12 (`basefilt' & inlist(`trset1',1,2) & inlist(`grp12',0,1))

cap frame drop _bal12
frame create _bal12 ///
    str120 varlabel ///
    int ord ///
    long N_c N_t ///
    double mean_c mean_t ///
    double diff_u smd ///
    double diff_a p_a

local ord = 0
foreach y of local vars_pre {

    local ++ord
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if `filt12' & `grp12'==0
    local mean_c = r(mean)
    local N_c    = r(N)
    local sd_c   = r(sd)

    quietly summarize `y' if `filt12' & `grp12'==1
    local mean_t = r(mean)
    local N_t    = r(N)
    local sd_t   = r(sd)

    local diff_u = `mean_t' - `mean_c'

    local denom = sqrt((`sd_t'^2 + `sd_c'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_t' - `mean_c')/`denom')

    capture quietly regress `y' i.`grp12' `prox_strata' if `filt12', vce(robust)
    if _rc {
        local diff_a = .
        local p_a    = .
    }
    else {
        quietly lincom 1.`grp12'
        local diff_a = r(estimate)
        local p_a    = r(p)
    }

    frame post _bal12 ///
        ("`yl'") ///
        (`ord') ///
        (`N_c') (`N_t') ///
        (`mean_c') (`mean_t') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}

frame change _bal12
quietly count
local N = r(N)
set obs `=`N'+1'

replace ord      = 8   in `=`N'+1'
replace varlabel = " " in `=`N'+1'
replace N_c      = .   in `=`N'+1'
replace N_t      = .   in `=`N'+1'
replace mean_c   = .   in `=`N'+1'
replace mean_t   = .   in `=`N'+1'
replace diff_u   = .   in `=`N'+1'
replace smd      = .   in `=`N'+1'
replace diff_a   = .   in `=`N'+1'
replace p_a      = .   in `=`N'+1'

replace ord = ord + 1 if ord >= 8 & varlabel != " "
sort ord
drop ord

label var varlabel "Variable"
label var mean_c   "Promedio (trat. original)"
label var N_c      "N (trat. original)"
label var mean_t   "Promedio (trat. adicional)"
label var N_t      "N (trat. adicional)"
label var diff_u   "Dif. incond. (adic. - orig.)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada por estratos"
label var p_a      "p ajustada"

format mean_c mean_t diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f

order varlabel mean_c N_c mean_t N_t diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\banorte_balance_p6_original_vs_adicional.xlsx", firstrow(varlabels) replace

frame change default
drop `grp12'

********************************************************************************
* TABLA 2: Control vs tratamiento original
********************************************************************************
tempvar grp01
gen byte `grp01' = .
replace `grp01' = 0 if `basefilt' & `trset1'==0
replace `grp01' = 1 if `basefilt' & `trset1'==1

local filt01 (`basefilt' & inlist(`trset1',0,1) & inlist(`grp01',0,1))

cap frame drop _bal01
frame create _bal01 ///
    str120 varlabel ///
    int ord ///
    long N_c N_t ///
    double mean_c mean_t ///
    double diff_u smd ///
    double diff_a p_a

local ord = 0
foreach y of local vars_pre {

    local ++ord
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if `filt01' & `grp01'==0
    local mean_c = r(mean)
    local N_c    = r(N)
    local sd_c   = r(sd)

    quietly summarize `y' if `filt01' & `grp01'==1
    local mean_t = r(mean)
    local N_t    = r(N)
    local sd_t   = r(sd)

    local diff_u = `mean_t' - `mean_c'

    local denom = sqrt((`sd_t'^2 + `sd_c'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_t' - `mean_c')/`denom')

    capture quietly regress `y' i.`grp01' `prox_strata' if `filt01', vce(robust)
    if _rc {
        local diff_a = .
        local p_a    = .
    }
    else {
        quietly lincom 1.`grp01'
        local diff_a = r(estimate)
        local p_a    = r(p)
    }

    frame post _bal01 ///
        ("`yl'") ///
        (`ord') ///
        (`N_c') (`N_t') ///
        (`mean_c') (`mean_t') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}

frame change _bal01
quietly count
local N = r(N)
set obs `=`N'+1'

replace ord      = 8   in `=`N'+1'
replace varlabel = " " in `=`N'+1'
replace N_c      = .   in `=`N'+1'
replace N_t      = .   in `=`N'+1'
replace mean_c   = .   in `=`N'+1'
replace mean_t   = .   in `=`N'+1'
replace diff_u   = .   in `=`N'+1'
replace smd      = .   in `=`N'+1'
replace diff_a   = .   in `=`N'+1'
replace p_a      = .   in `=`N'+1'

replace ord = ord + 1 if ord >= 8 & varlabel != " "
sort ord
drop ord

label var varlabel "Variable"
label var mean_c   "Promedio (control)"
label var N_c      "N (control)"
label var mean_t   "Promedio (trat. original)"
label var N_t      "N (trat. original)"
label var diff_u   "Dif. incond. (orig. - ctrl)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada por estratos"
label var p_a      "p ajustada"

format mean_c mean_t diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f

order varlabel mean_c N_c mean_t N_t diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\banorte_balance_p6_control_vs_original.xlsx", firstrow(varlabels) replace

frame change default
drop `grp01'

********************************************************************************
* TABLA 3: Control vs tratamiento adicional
********************************************************************************
tempvar grp02
gen byte `grp02' = .
replace `grp02' = 0 if `basefilt' & `trset1'==0
replace `grp02' = 1 if `basefilt' & `trset1'==2

local filt02 (`basefilt' & inlist(`trset1',0,2) & inlist(`grp02',0,1))

cap frame drop _bal02
frame create _bal02 ///
    str120 varlabel ///
    int ord ///
    long N_c N_t ///
    double mean_c mean_t ///
    double diff_u smd ///
    double diff_a p_a

local ord = 0
foreach y of local vars_pre {

    local ++ord
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if `filt02' & `grp02'==0
    local mean_c = r(mean)
    local N_c    = r(N)
    local sd_c   = r(sd)

    quietly summarize `y' if `filt02' & `grp02'==1
    local mean_t = r(mean)
    local N_t    = r(N)
    local sd_t   = r(sd)

    local diff_u = `mean_t' - `mean_c'

    local denom = sqrt((`sd_t'^2 + `sd_c'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_t' - `mean_c')/`denom')

    capture quietly regress `y' i.`grp02' `prox_strata' if `filt02', vce(robust)
    if _rc {
        local diff_a = .
        local p_a    = .
    }
    else {
        quietly lincom 1.`grp02'
        local diff_a = r(estimate)
        local p_a    = r(p)
    }

    frame post _bal02 ///
        ("`yl'") ///
        (`ord') ///
        (`N_c') (`N_t') ///
        (`mean_c') (`mean_t') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}

frame change _bal02
quietly count
local N = r(N)
set obs `=`N'+1'

replace ord      = 8   in `=`N'+1'
replace varlabel = " " in `=`N'+1'
replace N_c      = .   in `=`N'+1'
replace N_t      = .   in `=`N'+1'
replace mean_c   = .   in `=`N'+1'
replace mean_t   = .   in `=`N'+1'
replace diff_u   = .   in `=`N'+1'
replace smd      = .   in `=`N'+1'
replace diff_a   = .   in `=`N'+1'
replace p_a      = .   in `=`N'+1'

replace ord = ord + 1 if ord >= 8 & varlabel != " "
sort ord
drop ord

label var varlabel "Variable"
label var mean_c   "Promedio (control)"
label var N_c      "N (control)"
label var mean_t   "Promedio (trat. adicional)"
label var N_t      "N (trat. adicional)"
label var diff_u   "Dif. incond. (adic. - ctrl)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada por estratos"
label var p_a      "p ajustada"

format mean_c mean_t diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f

order varlabel mean_c N_c mean_t N_t diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\banorte_balance_p6_control_vs_adicional.xlsx", firstrow(varlabels) replace

frame change default
drop `grp02'

********************************************************************************
* TABLA 4: Control vs tratamiento conjunto
********************************************************************************
tempvar grp0A
gen byte `grp0A' = .
replace `grp0A' = 0 if `basefilt' & `trset1'==0
replace `grp0A' = 1 if `basefilt' & inlist(`trset1',1,2)

local filt0A (`basefilt' & inlist(`trset1',0,1,2) & inlist(`grp0A',0,1))

cap frame drop _bal0A
frame create _bal0A ///
    str120 varlabel ///
    int ord ///
    long N_c N_t ///
    double mean_c mean_t ///
    double diff_u smd ///
    double diff_a p_a

local ord = 0
foreach y of local vars_pre {

    local ++ord
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if `filt0A' & `grp0A'==0
    local mean_c = r(mean)
    local N_c    = r(N)
    local sd_c   = r(sd)

    quietly summarize `y' if `filt0A' & `grp0A'==1
    local mean_t = r(mean)
    local N_t    = r(N)
    local sd_t   = r(sd)

    local diff_u = `mean_t' - `mean_c'

    local denom = sqrt((`sd_t'^2 + `sd_c'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_t' - `mean_c')/`denom')

    capture quietly regress `y' i.`grp0A' `prox_strata' if `filt0A', vce(robust)
    if _rc {
        local diff_a = .
        local p_a    = .
    }
    else {
        quietly lincom 1.`grp0A'
        local diff_a = r(estimate)
        local p_a    = r(p)
    }

    frame post _bal0A ///
        ("`yl'") ///
        (`ord') ///
        (`N_c') (`N_t') ///
        (`mean_c') (`mean_t') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}

frame change _bal0A
quietly count
local N = r(N)
set obs `=`N'+1'

replace ord      = 8   in `=`N'+1'
replace varlabel = " " in `=`N'+1'
replace N_c      = .   in `=`N'+1'
replace N_t      = .   in `=`N'+1'
replace mean_c   = .   in `=`N'+1'
replace mean_t   = .   in `=`N'+1'
replace diff_u   = .   in `=`N'+1'
replace smd      = .   in `=`N'+1'
replace diff_a   = .   in `=`N'+1'
replace p_a      = .   in `=`N'+1'

replace ord = ord + 1 if ord >= 8 & varlabel != " "
sort ord
drop ord

label var varlabel "Variable"
label var mean_c   "Promedio (control)"
label var N_c      "N (control)"
label var mean_t   "Promedio (trat. conjunto)"
label var N_t      "N (trat. conjunto)"
label var diff_u   "Dif. incond. (trat. - ctrl)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada por estratos"
label var p_a      "p ajustada"

format mean_c mean_t diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f

order varlabel mean_c N_c mean_t N_t diff_u smd diff_a p_a
list, sep(0)
export excel using "`outdir'\banorte_balance_p6_control_vs_conjunto.xlsx", firstrow(varlabels) replace

frame change default
drop `grp0A'

*******************************************************
* Limpieza final
*******************************************************
drop `trset1'
*******************************************************