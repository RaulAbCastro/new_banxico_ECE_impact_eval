***Balance_check_incondicional
version 18
set more off

* Outcomes
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w

* Filtro: periodo inmediato anterior al primer cohorte
local filt (bpanel_alt==1 & periodo==6 & !missing(treatment))

*========================
* Crear tabla de balance en un frame (NO toca tu base)
*========================
cap frame drop _bal6
frame create _bal6 ///
    str30 outcome ///
    long N_c N_t ///
    double mean_c sd_c mean_t sd_t diff_tc se p smd

foreach y of local outcomes {

    quietly summarize `y' if `filt' & treatment==0
    local mean_c = r(mean)
    local sd_c   = r(sd)
    local N_c    = r(N)

    quietly summarize `y' if `filt' & treatment==1
    local mean_t = r(mean)
    local sd_t   = r(sd)
    local N_t    = r(N)

    * t-test (solo para referencia; con N grande siempre "significa")
    capture noisily ttest `y' if `filt', by(treatment)
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

    frame post _bal6 ///
        ("`y'") ///
        (`N_c') (`N_t') ///
        (`mean_c') (`sd_c') ///
        (`mean_t') (`sd_t') ///
        (`diff_tc') (`se') (`p') ///
        (`smd')
}

*========================
* Ver tabla + exportar (desde el frame)
*========================
frame change _bal6
format mean_c mean_t diff_tc se sd_c sd_t %12.4f
format p %9.4f
format smd %9.3f
order outcome N_c mean_c sd_c N_t mean_t sd_t diff_tc se p smd
sort outcome
list, sep(0)

* Export a Excel (opcional)
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Tables"
cap mkdir "`outdir'"
export excel using "`outdir'\bbva_balance_period6.xlsx", firstrow(variables) replace

* Regresar a tu base original
frame change default
* (Opcional) cap frame drop _bal6