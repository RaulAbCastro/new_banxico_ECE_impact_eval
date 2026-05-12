**balance_con_initot

version 18
set more off

*========================
* Inputs (igual que antes)
*========================
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w
local filt (bpanel_alt==1 & periodo==6 & !missing(treatment) & !missing(initot))

*========================
* Crear tabla de balance en un frame (NO toca tu base)
* Dos cortes: initot==0 y initot==1
*========================
cap frame drop _bal6_initot
frame create _bal6_initot ///
    byte initot ///
    str30 outcome ///
    long N_c N_t ///
    double mean_c sd_c mean_t sd_t diff_tc se p smd

foreach g in 0 1 {

    foreach y of local outcomes {

        * Resumen por grupo dentro de initot==g
        quietly summarize `y' if `filt' & initot==`g' & treatment==0
        local mean_c = r(mean)
        local sd_c   = r(sd)
        local N_c    = r(N)

        quietly summarize `y' if `filt' & initot==`g' & treatment==1
        local mean_t = r(mean)
        local sd_t   = r(sd)
        local N_t    = r(N)

        * t-test (solo referencia; con N grande se vuelve "hipersensible")
        capture noisily ttest `y' if `filt' & initot==`g', by(treatment)
        if _rc {
            local diff_tc = .
            local se      = .
            local p       = .
        }
        else {
            * diff = Treatment - Control
            local diff_tc = r(mu_2) - r(mu_1)
            local se      = r(se)
            local p       = r(p)
        }

        * SMD / normalized diff
        local denom = sqrt((`sd_t'^2 + `sd_c'^2)/2)
        local smd   = cond(`denom'==0, ., (`mean_t' - `mean_c')/`denom')

        frame post _bal6_initot ///
            (`g') ///
            ("`y'") ///
            (`N_c') (`N_t') ///
            (`mean_c') (`sd_c') ///
            (`mean_t') (`sd_t') ///
            (`diff_tc') (`se') (`p') ///
            (`smd')
    }
}

*========================
* Ver tablas (una por initot)
*========================
frame change _bal6_initot
format mean_c mean_t diff_tc se sd_c sd_t %12.4f
format p %9.4f
format smd %9.3f
order initot outcome N_c mean_c sd_c N_t mean_t sd_t diff_tc se p smd
sort initot outcome

di as text "================ BALANCE @ period=6 | initot==0 ================"
list outcome N_c mean_c sd_c N_t mean_t sd_t diff_tc se p smd if initot==0, sep(0)

di as text "================ BALANCE @ period=6 | initot==1 ================"
list outcome N_c mean_c sd_c N_t mean_t sd_t diff_tc se p smd if initot==1, sep(0)

*========================
* (Opcional) Export a Excel: 2 hojas (initot0 / initot1)
*========================
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Tables"
cap mkdir "`outdir'"
local xls "`outdir'\bbva_balance_period6_by_initot.xlsx"
cap erase "`xls'"

preserve
    keep if initot==0
    drop initot
    export excel using "`xls'", sheet("initot0") firstrow(variables) replace
restore

preserve
    keep if initot==1
    drop initot
    export excel using "`xls'", sheet("initot1") firstrow(variables) sheetreplace
restore

* Regresar a tu base original en memoria
frame change default
* (Opcional) cap frame drop _bal6_initot