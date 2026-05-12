***OLS_con_initot

version 18
set more off

* Outcomes
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w

* Filtro común (BBVA)
local filt bpanel_alt==1 & periodo<=12 & !missing(treatment) & !missing(initot)

*-----------------------------
* Términos para pruebas F (solo sobre interacciones periodo#treatment)
* pre: 1–6 ; post: 8–12
*-----------------------------
local pre_terms  ///
    1.periodo#1.treatment ///
    2.periodo#1.treatment ///
    3.periodo#1.treatment ///
    4.periodo#1.treatment ///
    5.periodo#1.treatment ///
    6.periodo#1.treatment

local post_terms ///
    8.periodo#1.treatment ///
    9.periodo#1.treatment ///
    10.periodo#1.treatment ///
    11.periodo#1.treatment ///
    12.periodo#1.treatment

*-----------------------------
* Keep/Order para esttab (agrega initot)
*-----------------------------
local common_keep ///
    1.treatment ///
    1.initot ///
    *.periodo ///
    *.periodo#1.treatment ///
    _cons

local common_order ///
    1.treatment 1.initot ///
    1.periodo 2.periodo 3.periodo 4.periodo 5.periodo 6.periodo 8.periodo 9.periodo 10.periodo 11.periodo 12.periodo ///
    1.periodo#1.treatment 2.periodo#1.treatment 3.periodo#1.treatment 4.periodo#1.treatment 5.periodo#1.treatment 6.periodo#1.treatment ///
    8.periodo#1.treatment 9.periodo#1.treatment 10.periodo#1.treatment 11.periodo#1.treatment 12.periodo#1.treatment ///
    _cons

*-----------------------------
* Corre R1+initot para cada outcome y arma tabla conjunta
*-----------------------------
eststo clear
local models ""
local mtitles ""

foreach y of local outcomes {

    di as text "============== R1 BBVA + initot: `y' =============="

    quietly reg `y' ib7.periodo##i.treatment i.initot if `filt', vce(cluster tarjeta)

    * F pre
    capture quietly testparm `pre_terms'
    if !_rc {
        estadd scalar F_pre = r(F)
        estadd scalar p_pre = r(p)
    }
    else {
        estadd scalar F_pre = .
        estadd scalar p_pre = .
    }

    * F post
    capture quietly testparm `post_terms'
    if !_rc {
        estadd scalar F_post = r(F)
        estadd scalar p_post = r(p)
    }
    else {
        estadd scalar F_post = .
        estadd scalar p_post = .
    }

    eststo m_`y'
    local models "`models' m_`y'"
    local mtitles `"`mtitles' "`y'""'
}

esttab `models', ///
    keep(`common_keep') ///
    order(`common_order') ///
    nobaselevels ///
    mtitles(`mtitles') ///
    b(4) se(4) ///
    label star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N F_pre p_pre F_post p_post, ///
          fmt(%9.0fc 3 3 3 3) ///
          labels("N obs" ///
                 "F pre (t=1–6, periodo#Early)" ///
                 "p-value pre" ///
                 "F post (t=8–12, periodo#Early)" ///
                 "p-value post")) ///
    compress nogap nonotes ///
    title("BBVA — R1 + initot: ib7.periodo##treatment + initot (periodo<=12, bpanel_alt==1), cluster tarjeta")
	
	
	
	
	
	
	
	
	
	
	
******ahora con interacciones initot periodo	

version 18
set more off

*==============================================================*
* BBVA — R1 + initot + (periodo × initot) EN EL MODELO
* Pero NO se muestran en la tabla los coeficientes (periodo#initot)
* Columnas = outcomes
*==============================================================*

* Outcomes
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w

* Filtro común (BBVA)
local filt bpanel_alt==1 & periodo<=12 & !missing(treatment) & !missing(initot)

*-----------------------------
* Términos para pruebas F
* (base temporal = 7 por ib7.periodo)
*-----------------------------
local pre_terms_treat  ///
    1.periodo#1.treatment ///
    2.periodo#1.treatment ///
    3.periodo#1.treatment ///
    4.periodo#1.treatment ///
    5.periodo#1.treatment ///
    6.periodo#1.treatment

local post_terms_treat ///
    8.periodo#1.treatment ///
    9.periodo#1.treatment ///
    10.periodo#1.treatment ///
    11.periodo#1.treatment ///
    12.periodo#1.treatment

local pre_terms_initot  ///
    1.periodo#1.initot ///
    2.periodo#1.initot ///
    3.periodo#1.initot ///
    4.periodo#1.initot ///
    5.periodo#1.initot ///
    6.periodo#1.initot

local post_terms_initot ///
    8.periodo#1.initot ///
    9.periodo#1.initot ///
    10.periodo#1.initot ///
    11.periodo#1.initot ///
    12.periodo#1.initot

*-----------------------------
* Keep/Order para esttab
* (NO incluir *.periodo#1.initot)
*-----------------------------
local common_keep ///
    1.treatment ///
    1.initot ///
    *.periodo ///
    *.periodo#1.treatment ///
    _cons

local common_order ///
    1.treatment 1.initot ///
    1.periodo 2.periodo 3.periodo 4.periodo 5.periodo 6.periodo 8.periodo 9.periodo 10.periodo 11.periodo 12.periodo ///
    1.periodo#1.treatment 2.periodo#1.treatment 3.periodo#1.treatment 4.periodo#1.treatment 5.periodo#1.treatment 6.periodo#1.treatment ///
    8.periodo#1.treatment 9.periodo#1.treatment 10.periodo#1.treatment 11.periodo#1.treatment 12.periodo#1.treatment ///
    _cons

*-----------------------------
* Corre regresiones y arma tabla conjunta
*-----------------------------
eststo clear
local models ""
local mtitles ""

foreach y of local outcomes {

    di as text "============== R1 BBVA + initot + periodo×initot (oculto en tabla): `y' =============="

    quietly reg `y' ///
        ib7.periodo##i.treatment ///
        ib7.periodo##i.initot ///
        if `filt', vce(cluster tarjeta)

    * F-tests para periodo#treatment (pre / post)
    capture quietly testparm `pre_terms_treat'
    if !_rc {
        estadd scalar F_pre  = r(F)
        estadd scalar p_pre  = r(p)
    }
    else {
        estadd scalar F_pre  = .
        estadd scalar p_pre  = .
    }

    capture quietly testparm `post_terms_treat'
    if !_rc {
        estadd scalar F_post = r(F)
        estadd scalar p_post = r(p)
    }
    else {
        estadd scalar F_post = .
        estadd scalar p_post = .
    }

    * F-tests para periodo#initot (pre / post) — aunque NO mostremos coeficientes
    capture quietly testparm `pre_terms_initot'
    if !_rc {
        estadd scalar F_pre_i  = r(F)
        estadd scalar p_pre_i  = r(p)
    }
    else {
        estadd scalar F_pre_i  = .
        estadd scalar p_pre_i  = .
    }

    capture quietly testparm `post_terms_initot'
    if !_rc {
        estadd scalar F_post_i = r(F)
        estadd scalar p_post_i = r(p)
    }
    else {
        estadd scalar F_post_i = .
        estadd scalar p_post_i = .
    }

    eststo m_`y'
    local models "`models' m_`y'"
    local mtitles `"`mtitles' "`y'""'
}

*-----------------------------
* Tabla (columnas = outcomes)
*-----------------------------
esttab `models', ///
    keep(`common_keep') ///
    order(`common_order') ///
    nobaselevels ///
    mtitles(`mtitles') ///
    b(4) se(4) ///
    label star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N F_pre p_pre F_post p_post F_pre_i p_pre_i F_post_i p_post_i, ///
          fmt(%9.0fc 3 3 3 3 3 3 3 3) ///
          labels("N obs" ///
                 "F pre (t=1–6, periodo#treatment)" ///
                 "p-value pre (treatment)" ///
                 "F post (t=8–12, periodo#treatment)" ///
                 "p-value post (treatment)" ///
                 "F pre (t=1–6, periodo#initot)" ///
                 "p-value pre (initot)" ///
                 "F post (t=8–12, periodo#initot)" ///
                 "p-value post (initot)")) ///
    compress nogap nonotes ///
    title("BBVA — R1: ib7.periodo##treatment + ib7.periodo##initot (periodo#initot oculto), cluster tarjeta")