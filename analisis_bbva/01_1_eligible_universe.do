*******************************************************
* BBVA - Construcción de universo elegible analítico
*
* Universo base:
*   - usuarios de estado de cuenta en papel en mayo 2024
*   - panel balanceado (bpanel_alt==1)
*   - actividad en al menos 2 de los periodos 4, 5 y 6
*     medida como pngicorte > 0
*******************************************************

version 18
set more off

*------------------------------------------------------*
* 1) Limpieza de auxiliares previas
*------------------------------------------------------*
capture drop _act_456 _n_act_456 _impagosc_t6 eleg_bbva_base eleg_bbva_strict

*------------------------------------------------------*
* 2) Actividad reciente en periodos 4, 5 y 6
*    Actividad = pngicorte > 0
*------------------------------------------------------*
gen byte _act_456 = inlist(periodo,4,5,6) & pngicorte>0 if !missing(pngicorte)

bys tarjeta: egen int _n_act_456 = total(_act_456)

*------------------------------------------------------*
* 3) Número de impagos consecutivos en t=6
*    Se arrastra a toda la tarjeta para poder usarlo en filtros
*------------------------------------------------------*
bys tarjeta: egen int _impagosc_t6 = max(cond(periodo==6, impagosc, .))

*------------------------------------------------------*
* 4) Universo elegible base
*    - papel en mayo 2024
*    - panel balanceado
*    - actividad en >=2 de periodos 4,5,6
*------------------------------------------------------*
gen byte eleg_bbva_base = .
replace eleg_bbva_base = 1 if papel_may2024_any==1 & bpanel_alt==1 & _n_act_456>=2
replace eleg_bbva_base = 0 if papel_may2024_any==1 & bpanel_alt==1 & _n_act_456<2

label define lbl_eleg_bbva_base ///
    0 "No elegible BBVA (sin actividad suficiente)" ///
    1 "Elegible BBVA (con actividad reciente)", replace
label values eleg_bbva_base lbl_eleg_bbva_base
label var eleg_bbva_base ///
    "Elegible BBVA"

