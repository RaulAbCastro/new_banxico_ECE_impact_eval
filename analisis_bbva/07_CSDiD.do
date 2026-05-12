clear all 
use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBBVApaper.dta"

*=====================================================================================================*
*=========================== BBVA - CSDID PRINCIPAL (EVENT) =========================================*
*========================= ESTIMA CON TODA LA MUESTRA / MUESTRA [-5,4] ==============================*
*=====================================================================================================*
version 18
set more off

*-----------------------------*
* 0) Outcomes
*-----------------------------*
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w

*-----------------------------*
* 1) Filtro principal BBVA
*-----------------------------*
local filt (papel_may2024_any==1 & bpanel_alt==1 & eleg_bbva_base==1 & periodo<=12)

*-----------------------------*
* 2) Controles pretratamiento (SIN clase) + producto fijo t=6
*-----------------------------*
local xpre i.seg_limcred_q_t6 ///
           i.seg_ruso_q_t6 ///
           i.seg_totalero_pre6 ///
           i.seg_ingreso_q_t6 ///
           i.seg_edad_q_t6 ///
           i.seg_antig_t6 ///
           i.compme_t6 ///
           i.mujeres_t6 ///
           i.prod_t6

*-----------------------------*
* 3) Ventana a MOSTRAR en tabla/gráfica
*-----------------------------*
local evkeep Tm5 Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3 Tp4

*-----------------------------*
* 4) Etiquetas para la tabla
*-----------------------------*
local evlabs ///
    Tm5 "-5" ///
    Tm4 "-4" ///
    Tm3 "-3" ///
    Tm2 "-2" ///
    Tm1 "-1" ///
    Tp0 "0"  ///
    Tp1 "1"  ///
    Tp2 "2"  ///
    Tp3 "3"  ///
    Tp4 "4"

*-----------------------------*
* 5) Carpeta de salida
*-----------------------------*
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Graphs\csdid"
cap mkdir "`outdir'"

*=====================================================================================================*
* 6) CSDID agg(event) + gráficas en ventana [-5,4]
*=====================================================================================================*
preserve
    keep tarjeta periodo first_trat_grp papel_may2024_any bpanel_alt eleg_bbva_base ///
         prod_t6 seg_limcred_q_t6 seg_ruso_q_t6 seg_totalero_pre6 ///
         seg_ingreso_q_t6 seg_edad_q_t6 seg_antig_t6 compme_t6 mujeres_t6 ///
         `outcomes'

    keep if `filt'
    compress

    eststo clear

    foreach y of local outcomes {

        di as text "============== CSDID EVENT: `y' =============="

        capture noisily csdid `y', ///
            ivar(tarjeta) ///
            time(periodo) ///
            gvar(first_trat_grp) ///
            method(dripw) ///
            vce(cluster tarjeta) ///
            notyet ///
            xvar(`xpre') ///
            agg(event)

        if _rc {
            di as error ">> csdid falló para `y' (rc=" _rc "). Se salta."
            continue
        }

        * Guardar N
        quietly estadd scalar Nobs = e(N)
        eststo ev_`y'
        estimates store ev_`y'

        *----------------------*
        * Gráfica event study
        * MUESTRA SOLO [-5,4]
        *----------------------*
        local gname "gev_`y'"
        capture noisily event_plot ev_`y', ///
            stub_lag(Tp#) stub_lead(Tm#) ///
            trimlag(4) trimlead(5) ///
            lag_opt(  lcolor(navy)   lwidth(medthick) ) ///
            lead_opt( lcolor(maroon) lwidth(medthick) ) ///
            lag_ci_opt(  fcolor(navy%35)   lcolor(navy%0) ) ///
            lead_ci_opt( fcolor(maroon%35) lcolor(maroon%0) ) ///
            graph_opt( ///
                xtitle("Tiempo relativo al tratamiento") ///
                ytitle("ATT (`y')") ///
                title("BBVA - CSDID agg(event): `y'") ///
                subtitle("Ventana mostrada: [-5,4]") ///
                note("Los extremos del postratamiento se sostienen por menos cohortes.", size(vsmall)) ///
                xlabel(-5(1)4) ///
                yline(0, lpattern(dash)) ///
                legend(off) ///
                scheme(s2color) ///
                plotregion(color(white)) graphregion(color(white)) ///
                name(`gname', replace) ///
            )

        if _rc {
            di as error ">> event_plot falló para `y' (rc=" _rc "). No exporto gráfica."
            continue
        }

        graph export "`outdir'\bbva_csdid_event_`y'_win_m5_p4.png", replace width(2400)
        graph drop `gname'
    }

 

set linesize 255
*----------------------*
* 7) Tabla principal
*----------------------*
local evkeep Pre_avg Post_avg Tm5 Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3 Tp4

esttab ev_*, ///
    keep(`evkeep') ///
    order(`evkeep') ///
    b(4) se(4) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Intereses" ///
            "Totalero" ///
            "Totalero (PNGI)" ///
            "Razón de Uso" ///
            "Pago Tardío" ///
            "Impago" ///
            "Pago/min") ///
    stats(Nobs, fmt(%9.0fc) labels("Observaciones")) ///
    modelwidth(16) ///
    varwidth(12) ///
    nogap nonotes ///
    title("BBVA - CSDID (agg(event)) con controles pretratamiento y producto fijo t=6") ///
    addnotes("Se muestra únicamente la ventana [-5,4].", ///
             "Los extremos del postratamiento están identificados con menos cohortes y deben interpretarse con cautela.")
			 
restore