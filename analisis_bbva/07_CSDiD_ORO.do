*=====================================================================================================*
*====================== BBVA - CSDID SOLO UNAM ORO / ORO ============================================*
*==================== SIN producto×periodo; CON producto fijo t=6 ===================================*
*=====================================================================================================*
version 18
set more off

*-----------------------------*
* 0) Outcomes
*-----------------------------*
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w

*-----------------------------*
* 1) Carpeta de salida
*-----------------------------*
local outdir "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Graphs\csdid"
cap mkdir "`outdir'"

*=====================================================================================================*
* 2) Preparar muestra
*=====================================================================================================*
preserve

keep tarjeta periodo first_trat_grp papel_may2024_any bpanel_alt eleg_bbva_base ///
     nombre_t6 prod_t6 ///
     seg_limcred_q_t6 seg_ruso_q_t6 seg_totalero_pre6 ///
     seg_ingreso_q_t6 seg_edad_q_t6 seg_antig_t6 ///
     compme_t6 mujeres_t6 ///
     `outcomes'

* Filtro principal BBVA
keep if papel_may2024_any==1 & bpanel_alt==1 & eleg_bbva_base==1 & periodo<=12

* Submuestra comparable: UNAM Oro / Oro fijados en t=6
keep if inlist(nombre_t6, ///
    "TARJETA AFINIDAD UNAM BBVA", ///
    "TARJETA ORO BBVA")

compress

*-----------------------------*
* 3) Diagnóstico rápido de soporte
*-----------------------------*
di as text "============================================"
di as text "MUESTRA UNAM ORO / ORO"
count
tab nombre_t6
tab first_trat_grp
tab first_trat_grp nombre_t6, row
di as text "============================================"

*-----------------------------*
* 4) Controles pretratamiento
*    SIN clase
*    CON producto fijo t=6
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
* 5) Ventana a mostrar
*-----------------------------*
local evkeep Tm5 Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3 Tp4
local evlabs Tm5 "-5" Tm4 "-4" Tm3 "-3" Tm2 "-2" Tm1 "-1" Tp0 "0" Tp1 "1" Tp2 "2" Tp3 "3" Tp4 "4"

*=====================================================================================================*
* 6) CSDID agg(event)
*=====================================================================================================*
eststo clear

foreach y of local outcomes {

    di as text "============== CSDID EVENT (UNAM Oro/Oro): `y' =============="

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

    quietly estadd scalar Nobs = e(N)
    eststo ev_`y'
    estimates store ev_`y'

    *----------------------*
    * Gráfica event study
    *----------------------*
    local gname "guno_`y'"
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
            title("BBVA UNAM Oro/Oro - CSDID agg(event): `y'") ///
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

    graph export "`outdir'\bbva_unamoro_oro_csdid_event_`y'_win_m5_p4.png", replace width(2400)
    graph drop `gname'
}

*----------------------*
* 7) Tabla principal
*----------------------*
esttab ev_*, ///
    keep(`evkeep') ///
    order(`evkeep') ///
    coeflabels(`evlabs') ///
    b(4) se(4) ///
    label star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles(`outcomes') ///
    stats(Nobs, fmt(%9.0fc) labels("N obs")) ///
    compress nogap nonotes ///
    title("BBVA UNAM Oro/Oro - CSDID (agg(event)) con controles pretratamiento y producto fijo t=6") ///
    addnotes("Muestra restringida a TARJETA AFINIDAD UNAM BBVA y TARJETA ORO BBVA.", ///
             "Se muestra únicamente la ventana [-5,4].", ///
             "Los extremos del postratamiento están identificados con menos cohortes y deben interpretarse con cautela.")

restore