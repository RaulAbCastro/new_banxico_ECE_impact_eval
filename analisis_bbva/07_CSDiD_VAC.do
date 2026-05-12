*=====================================================================================================*
*===================== BBVA - CSDID SOLO AZUL / CREA / VIVE =========================================*
*===================== CON DISEÑO DE TABLA HOMOLOGADO A BANORTE =====================================*
*=====================================================================================================*
version 18
set more off
set linesize 255

*-----------------------------*
* 0) Outcomes en el mismo orden que Banorte
*-----------------------------*
local outcomes interesrev rpagomin_w totalero totalero_alt ruso ctar delinquent

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

* Submuestra comparable: Azul / Vive / Crea fijados en t=6
keep if inlist(nombre_t6, ///
    "TARJETA AZUL BBVA", ///
    "TARJETA VIVE BBVA", ///
    "TARJETA CREA BBVA")

compress

*-----------------------------*
* 3) Diagnóstico rápido
*-----------------------------*
di as text "============================================"
di as text "MUESTRA AZUL / CREA / VIVE"
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
local evkeep Pre_avg Post_avg Tm5 Tm4 Tm3 Tm2 Tm1 Tp0 Tp1 Tp2 Tp3 Tp4

*=====================================================================================================*
* 6) CSDID agg(event) + gráficas
*=====================================================================================================*
eststo clear

foreach y of local outcomes {

    di as text "============== CSDID EVENT (Azul/CREA/Vive): `y' =============="

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
    local gname "gavc_`y'"
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
            title("BBVA Azul/CREA/Vive - CSDID agg(event): `y'") ///
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

    graph export "`outdir'\bbva_acv_csdid_event_`y'_win_m5_p4.png", replace width(2400)
    graph drop `gname'
}

*----------------------*
* 7) Tabla principal
*    - mantiene Pre_avg y Post_avg
*    - deja Tm# y Tp# tal cual
*    - homologa columnas con Banorte
*    - columnas más anchas
*----------------------*
esttab ev_*, ///
    keep(`evkeep') ///
    order(`evkeep') ///
    b(4) se(4) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Intereses" ///
            "Pago/min" ///
            "Totalero (CIR)" ///
            "Totalero (PNGI)" ///
            "Razón de Uso" ///
            "Pago Tardío" ///
            "Impago") ///
    stats(Nobs, fmt(%9.0fc) labels("Observaciones")) ///
    modelwidth(16) ///
    varwidth(12) ///
    nogap nonotes ///
    title("BBVA Azul/CREA/Vive - CSDID (agg(event)) con controles pretratamiento y producto fijo t=6") ///
    addnotes("Muestra restringida a TARJETA AZUL BBVA, TARJETA CREA BBVA y TARJETA VIVE BBVA.", ///
             "Se muestran Pre_avg, Post_avg y la ventana [-5,4].", ///
             "Los extremos del postratamiento están identificados con menos cohortes y deben interpretarse con cautela.")

restore