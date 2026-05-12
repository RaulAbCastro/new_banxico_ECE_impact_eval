

**LOGIT

*****************************************************
* LOGIT versión REGRESIÓN 3 + WALD PRE/POST
* Outcomes: totalero totalero_alt ctar delinquent
* Cluster: tarjeta
*****************************************************

version 18
set more off

* Necesitas estout instalado para usar esttab / estadd
* ssc install estout, replace

* Outcomes binarios
local outcomes totalero // totalero_alt ctar delinquent

* Filtro común
local filt bpanel_alt==1 & flg_elegible_1==1 & periodo<=11

eststo clear
foreach y of local outcomes {

    di as text "-----------------------------------------------------------"
    di as result "LOGIT para outcome: `y'"
    di as text "-----------------------------------------------------------"

    quietly logit `y' ///
        ib7.periodo##i.treatment2 ///        // FE de periodo + trat + periodo#trat
        i.estrato_multitarjeta ///           // estratos (niveles)
        i.estrato_gama ///
        i.estrato_limcred4 ///
        i.estrato_comp4 ///
        i.periodo#i.estrato_multitarjeta /// // interacciones periodo×estrato
        i.periodo#i.estrato_gama ///
        i.periodo#i.estrato_limcred4 ///
        i.periodo#i.estrato_comp4 ///
        if `filt', vce(cluster tarjeta)

    *=============================
    * WALD PRE: periodos 1–6
    *=============================
    quietly testparm ///
        1.periodo#1.treatment2 ///
        2.periodo#1.treatment2 ///
        3.periodo#1.treatment2 ///
        4.periodo#1.treatment2 ///
        5.periodo#1.treatment2 ///
        6.periodo#1.treatment2

    scalar W_pre = r(chi2)
    scalar p_pre = r(p)
    estadd scalar W_pre = W_pre
    estadd scalar p_pre = p_pre

    *=============================
    * WALD POST: periodos 8–11
    *=============================
    quietly testparm ///
        8.periodo#1.treatment2 ///
        9.periodo#1.treatment2 ///
        10.periodo#1.treatment2 ///
        11.periodo#1.treatment2

    scalar W_post = r(chi2)
    scalar p_post = r(p)
    estadd scalar W_post = W_post
    estadd scalar p_post = p_post

    * Guardar el modelo
    eststo logit_`y'
}

*============================================
* TABLA: solo periodo, tratamiento, periodo#trat y estratos (niveles)
*============================================
esttab logit_*, ///
    drop( ///
        *.periodo#*.estrato_multitarjeta ///  quita periodo×estrato_multitarjeta
        *.periodo#*.estrato_gama ///          quita periodo×estrato_gama
        *.periodo#*.estrato_limcred4 ///      quita periodo×estrato_limcred4
        *.periodo#*.estrato_comp4 ///         quita periodo×estrato_comp4
    ) ///
    noomitted ///
    b(4) se(4) ///
    label star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N W_pre p_pre W_post p_post, ///
          fmt(%9.0fc 3 3 3 3 3)  ///
          labels("N obs" ///
                 "Wald pre (periodos 1-6, trat×periodo)" ///
                 "p-value pre" ///
                 "Wald post (periodos 8-11, trat×periodo)" ///
                 "p-value post")) ///
    varwidth(25) modelwidth(18) ///
    compress nogap nonotes ///
    title("LOGIT: outcome ~ ib7.periodo##i.treatment2 + estratos + periodo×estratos (base periodo = 7)")
