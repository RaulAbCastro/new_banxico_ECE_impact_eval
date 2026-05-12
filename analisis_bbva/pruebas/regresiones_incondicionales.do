***regresiones_incondicionales
version 18
set more off

*==============================================================*
* BBVA — R1 only (TWFE-style por periodo) en una sola tabla
* Columnas = outcomes
*==============================================================*

* Outcomes
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w

* Filtro común (BBVA)
local filt bpanel_alt==1 & periodo<=12 & !missing(treatment)

*-----------------------------
* Términos para pruebas F
* (pre: 1–6 ; post: 8–12) con base ib7.periodo
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
* Keep/Order para esttab
*-----------------------------
local common_keep ///
    1.treatment ///
    *.periodo ///
    *.periodo#1.treatment ///
    _cons

local common_order ///
    1.treatment ///
    1.periodo 2.periodo 3.periodo 4.periodo 5.periodo 6.periodo 8.periodo 9.periodo 10.periodo 11.periodo 12.periodo ///
    1.periodo#1.treatment 2.periodo#1.treatment 3.periodo#1.treatment 4.periodo#1.treatment 5.periodo#1.treatment 6.periodo#1.treatment ///
    8.periodo#1.treatment 9.periodo#1.treatment 10.periodo#1.treatment 11.periodo#1.treatment 12.periodo#1.treatment ///
    _cons

*-----------------------------
* Corre R1 para cada outcome y guarda scalars de tests
*-----------------------------
eststo clear
local models ""
local mtitles ""

foreach y of local outcomes {

    di as text "============== R1 BBVA: `y' =============="

    quietly reg `y' ib7.periodo##i.treatment if `filt', vce(cluster tarjeta)

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

*-----------------------------
* Tabla conjunta (columnas = outcomes)
*-----------------------------
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
    varwidth(30) modelwidth(18) ///
    compress nogap nonotes ///
    title("BBVA — R1: ib7.periodo##treatment (periodo<=12, bpanel_alt==1), cluster tarjeta")