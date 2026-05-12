***graficas y creación de dummy treatment
table first_trat if bpanel_alt == 1 & periodo == 7
table periodo first_trat if bpanel_alt == 1 & periodo <= 12
table periodo edoctanvo if bpanel_alt == 1 & periodo <= 12



gen treatment = 0
replace treatment = 1 if first_trat < 13
label define lbl_treat 0 "Cohort 13" 1 "Early treated", replace
label values treatment lbl_treat
label var treatment "Simplified treatment"

table periodo treatment if bpanel_alt == 1 & periodo <= 12
table periodo treatment if bpanel_alt == 1 & periodo <= 12, statistic(mean ruso)






version 18
set more off

*==============================================================
* GRÁFICAS DE TENDENCIAS POR GRUPO (Control vs Tratamiento)
* - Serie de medias por periodo (1-11)
* - Línea vertical en periodo 8
* - Etiquetas del eje X con value labels de periodo (per)
* - Eje Y dinámico: 0 a 1.2*max, con 6 saltos
* - Guarda cada gráfica en: \\...\graphs
*==============================================================

* Outcomes a graficar (ajusta si quieres)
local outcomes interesrev totalero rpagomin_w ruso ctar delinquent totalero_alt

* Filtro base
local filt bpanel_alt==1 &  periodo<=12

* Ruta de guardado (ajusta si tu carpeta tiene otro nombre)
local gpath "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\Graphs\means"

* Forzar todas las etiquetas del eje X (1 a 11) usando value labels
local xlabs ""
forvalues p = 1/12 {
    local xlabs `"`xlabs' `p' "`: label (per) `p''""'
}


foreach y of local outcomes {

    preserve

    *----------------------------
    * Filtro y colapso
    *----------------------------
    keep if `filt'
    collapse (mean) `y', by(periodo treatment)

    *----------------------------
    * Eje Y dinámico: 0 a 1.2*max, con 6 saltos
    *----------------------------
    quietly summarize `y'
    local ymax  = 1.2*r(max)
    local ystep = `ymax'/6

    *----------------------------
    * Gráfica
    *----------------------------
    twoway ///
        (line `y' periodo if treatment==0, lwidth(medthick)) ///
        (line `y' periodo if treatment==1, lwidth(medthick)) ///
        , ///
        subtitle("Early treated vs g13") ///
        ytitle("`y'") ///
        xtitle("Period") ///
        xlabel(`xlabs', angle(90) labsize(small)) ///
        legend( ///
            label(1 "Cohort 13") ///
            label(2 "All other cohorts") ///
        )

    *----------------------------
    * Guardar (PNG) en la ruta
    *----------------------------
    graph export "`gpath'\trend_`y'_p1_11.png", replace width(2200)

    restore
}
























