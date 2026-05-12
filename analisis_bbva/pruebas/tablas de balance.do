*******************************************************
* BANORTE - Balance pretratamiento (periodo 6)
* Tabla principal: Control (diferido) vs Tratamiento anticipado conjunto
* - Missing de tratamiento_set1 -> 0 solo en elegibles
* - Ajuste por estratos proxy del panel
* - Sin columnas varname ni ord en la salida final
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
* 3) Grupo principal
*    0 = diferido/control
*    1 = anticipado conjunto (1 o 2)
*======================================================
tempvar trset1 early_any
gen byte `trset1' = .
replace `trset1' = cond(missing(tratamiento_set1), 0, tratamiento_set1) if flg_elegible_1==1

gen byte `early_any' = .
replace `early_any' = 0 if `trset1'==0
replace `early_any' = 1 if inlist(`trset1',1,2)

*======================================================
* 4) Filtro base
*======================================================
local filt (flg_elegible_1==1 & bpanel_alt==1 & periodo==6 & inlist(`early_any',0,1))

*======================================================
* 5) Estratos proxy para ajuste
*======================================================
local prox_strata i.estrato_gama i.estrato_limcred4 i.estrato_multitarjeta i.estrato_comp4

*======================================================
* 6) Frame de resultados
*======================================================
cap frame drop _bal_main
frame create _bal_main ///
    str120 varlabel ///
    int    ord ///
    long   N_c N_t ///
    double mean_c mean_t ///
    double diff_u smd ///
    double diff_a p_a

*======================================================
* 7) Loop
*======================================================
local ord = 0
foreach y of local vars_pre {

    local ++ord
    local yl "`pretty_`y''"
    if "`yl'"=="" local yl "`y'"

    quietly summarize `y' if `filt' & `early_any'==0
    local mean_c = r(mean)
    local N_c    = r(N)
    local sd_c   = r(sd)

    quietly summarize `y' if `filt' & `early_any'==1
    local mean_t = r(mean)
    local N_t    = r(N)
    local sd_t   = r(sd)

    * Diferencia incondicional
    local diff_u = `mean_t' - `mean_c'

    * SMD incondicional
    local denom = sqrt((`sd_t'^2 + `sd_c'^2)/2)
    local smd_  = cond(`denom'==0, ., (`mean_t' - `mean_c')/`denom')

    * Diferencia ajustada por estratos proxy
    capture quietly regress `y' i.`early_any' `prox_strata' if `filt', vce(robust)
    if _rc {
        local diff_a = .
        local p_a    = .
    }
    else {
        quietly lincom 1.`early_any'
        local diff_a = r(estimate)
        local p_a    = r(p)
    }

    frame post _bal_main ///
        ("`yl'") ///
        (`ord') ///
        (`N_c') (`N_t') ///
        (`mean_c') (`mean_t') ///
        (`diff_u') (`smd_') ///
        (`diff_a') (`p_a')
}

*======================================================
* 8) Insertar fila en blanco y ordenar
*======================================================
frame change _bal_main

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

*======================================================
* 9) Etiquetas y formato
*======================================================
label var varlabel "Variable"
label var mean_c   "Promedio (control)"
label var N_c      "N (control)"
label var mean_t   "Promedio (tratamiento)"
label var N_t      "N (tratamiento)"
label var diff_u   "Dif. incond. (trat - ctrl)"
label var smd      "SMD"
label var diff_a   "Dif. ajustada por estratos"
label var p_a      "p ajustada"

format mean_c mean_t diff_u diff_a %12.4f
format smd %9.3f
format p_a %9.4f

* Quitar columna de orden antes de mostrar/exportar
drop ord

order varlabel mean_c N_c mean_t N_t diff_u smd diff_a p_a
list, sep(0)

*======================================================
* 10) Exportar a Excel
*======================================================
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_banorte\Tables"
cap mkdir "`outdir'"
export excel using "`outdir'\banorte_balance_period6_main_limpia.xlsx", firstrow(varlabels) replace

frame change default

*======================================================
* 11) Limpieza
*======================================================
drop `trset1' `early_any'
*******************************************************