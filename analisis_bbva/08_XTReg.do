Segundo modelo de robustez de resultados (continua sin responder):

**PANEL
*------------------------------------------------------------*
* REGRESIÓN 3 (VERSIÓN PANEL FE TARJETA)
*   Y_it = α_i + λ_t + β_t*(treatment2_i) 
*          + θ_{t,s}*(estratos_s × periodo_t) + u_it
*------------------------------------------------------------*

version 18
set more off

* Panel: tarjeta = unidad, periodo = tiempo
xtset tarjeta periodo

* Necesitas estout instalado para usar esttab / estadd
* ssc install estout, replace

* Outcomes
local outcomes interesrev // totalero totalero_alt ruso ctar delinquent rpagomin_w

* Filtro común (mismo que antes para Regresión 3)
local filt bpanel_alt==1 & flg_elegible_1==1 & periodo<=11

eststo clear
foreach y of local outcomes {

    di as text "-----------------------------------------------------------"
    di as result "XTFE (versión panel Regresión 3) para outcome: `y'"
    di as text "-----------------------------------------------------------"

    quietly xtreg `y' ///
        ib7.periodo##i.treatment2 ///  FE de periodo + trat + periodo#trat
        i.estrato_multitarjeta ///
        i.estrato_gama ///
        i.estrato_limcred4 ///
        i.estrato_comp4 ///
        i.periodo#i.estrato_multitarjeta ///
        i.periodo#i.estrato_gama ///
        i.periodo#i.estrato_limcred4 ///
        i.periodo#i.estrato_comp4 ///
        if `filt', fe vce(cluster tarjeta)

    *-----------------------------------------------------------*
    * F PRE: interacciones periodo×treatment2 en periodos 1–6
    * (7 es la base, por diseño de ib7.periodo)
    *-----------------------------------------------------------*
    quietly testparm ///
        1.periodo#1.treatment2 ///
        2.periodo#1.treatment2 ///
        3.periodo#1.treatment2 ///
        4.periodo#1.treatment2 ///
        5.periodo#1.treatment2 ///
        6.periodo#1.treatment2

    scalar F_pre  = r(F)
    scalar p_pre  = r(p)
    estadd scalar F_pre = F_pre
    estadd scalar p_pre = p_pre

    *-----------------------------------------------------------*
    * F POST: interacciones periodo×treatment2 en periodos 8–11
    *-----------------------------------------------------------*
    quietly testparm ///
        8.periodo#1.treatment2 ///
        9.periodo#1.treatment2 ///
        10.periodo#1.treatment2 ///
        11.periodo#1.treatment2

    scalar F_post = r(F)
    scalar p_post = r(p)
    estadd scalar F_post = F_post
    estadd scalar p_post = p_post

    * Guardar el modelo FE
    eststo reg3_fe_`y'
}

*------------------------------------------------------------*
* TABLA ÚNICA DE COEFICIENTES (columnas = outcomes)
* Nota: en FE tarjeta se absorben treatment2 y los estratos
*       como niveles, por eso NO aparecen sus coeficientes puros.
*       Sí se reportan:
*       - efectos fijos de periodo
*       - periodo#treatment2
*       - periodo#estratos
*------------------------------------------------------------*
esttab reg3_fe_*, ///
    keep( ///
        *.periodo ///
        *.periodo#1.treatment2 ///
    ) ///
    noomitted ///
    b(4) se(4) ///
    label star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N F_pre p_pre F_post p_post, ///
          fmt(%9.0fc 3 3 3 3 3) ///
          labels("N obs" ///
                 "F pre (periodos 1-6, trat×periodo)" ///
                 "p-value pre" ///
                 "F post (periodos 8-11, trat×periodo)" ///
                 "p-value post")) ///
    varwidth(25) modelwidth(18) ///
    compress nogap nonotes ///
    title("XTFE: outcome ~ ib7.periodo##i.treatment2 + estratos + periodo×estratos (FE tarjeta, base periodo = 7)")
