*A PARTIR DE ESTE PUNTO, NOS CENTRAREMOS EN EL ANÁLISIS DE 

********************************************************************************
* BANORTE — TABLAS POR OUTCOME (R1 vs R2 vs R3)
* FIX: no usar drop(0b.* *bn.*) porque esttab lo interpreta como coeficientes.
* En su lugar: (i) NO usar noomitted, (ii) usar nobaselevels para que no imprima bases.
********************************************************************************

version 18
set more off

* Outcomes
local outcomes interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w

* Filtro común
local filt bpanel_alt==1 & flg_elegible_1==1 & periodo<=11 & papel_may2024_any == 1

* Controles (R2 y R3)
local strata ///
    i.estrato_multitarjeta ///
    i.estrato_gama ///
    i.estrato_limcred4 ///
    i.estrato_comp4

local strataXtime ///
    i.periodo#i.estrato_multitarjeta ///
    i.periodo#i.estrato_gama ///
    i.periodo#i.estrato_limcred4 ///
    i.periodo#i.estrato_comp4

* Términos para pruebas F (pre y post)
local pre_terms  ///
    1.periodo#1.treatment2 ///
    2.periodo#1.treatment2 ///
    3.periodo#1.treatment2 ///
    4.periodo#1.treatment2 ///
    5.periodo#1.treatment2 ///
    6.periodo#1.treatment2

local post_terms ///
    8.periodo#1.treatment2 ///
    9.periodo#1.treatment2 ///
    10.periodo#1.treatment2 ///
    11.periodo#1.treatment2

* Keep/Order comunes (Early -> FE tiempo -> Interacciones -> Constante)
local common_keep ///
    1.treatment2 ///
    *.periodo ///
    *.periodo#1.treatment2 ///
    _cons

local common_order ///
    1.treatment2 ///
    1.periodo 2.periodo 3.periodo 4.periodo 5.periodo 6.periodo 8.periodo 9.periodo 10.periodo 11.periodo ///
    1.periodo#1.treatment2 2.periodo#1.treatment2 3.periodo#1.treatment2 4.periodo#1.treatment2 5.periodo#1.treatment2 6.periodo#1.treatment2 ///
    8.periodo#1.treatment2 9.periodo#1.treatment2 10.periodo#1.treatment2 11.periodo#1.treatment2 ///
    _cons

********************************************************************************
* Loop: una tabla por outcome
*Se puede incluir i.q_ruso para introducir cuartiles de nivel de endeudamiento
********************************************************************************
foreach y of local outcomes {

    di as text "============================================================"
    di as result "TABLA POR OUTCOME: `y'  (R1 vs R2 vs R3)"
    di as text "============================================================"

    eststo clear

    *=========================
    * R1: Inconditional
    *=========================
    quietly reg `y' ib7.periodo##i.treatment2 if `filt', vce(cluster tarjeta)

    quietly testparm `pre_terms'
    estadd scalar F_pre  = r(F)
    estadd scalar p_pre  = r(p)

    quietly testparm `post_terms'
    estadd scalar F_post = r(F)
    estadd scalar p_post = r(p)

    eststo r1

    *=========================
    * R2: +Strata
    *=========================
    quietly reg `y' ib7.periodo##i.treatment2 ///
        `strata'  ///
        if `filt', vce(cluster tarjeta)

    quietly testparm `pre_terms'
    estadd scalar F_pre  = r(F)
    estadd scalar p_pre  = r(p)

    quietly testparm `post_terms'
    estadd scalar F_post = r(F)
    estadd scalar p_post = r(p)

    eststo r2

    *=========================
    * R3: Complete (+ strata×time)
    *=========================
    quietly reg `y' ib7.periodo##i.treatment2 ///
        `strata' ///
        `strataXtime'  ///
        if `filt', vce(cluster tarjeta)

    quietly testparm `pre_terms'
    estadd scalar F_pre  = r(F)
    estadd scalar p_pre  = r(p)

    quietly testparm `post_terms'
    estadd scalar F_post = r(F)
    estadd scalar p_post = r(p)

    eststo r3

    *=========================
    * TABLA (columnas = R1–R3)
    * - sin bases/omitidas: nobaselevels (y NO usamos noomitted)
    *=========================
    esttab r1 r2 r3, ///
        keep(`common_keep') ///
        order(`common_order') ///
        nobaselevels ///
        mtitle("Inconditional Reg (R1)" "+Strata (R2)" "Complete (R3)") ///
        b(4) se(4) ///
        label star(* 0.10 ** 0.05 *** 0.01) ///
        stats(N F_pre p_pre F_post p_post, ///
              fmt(%9.0fc 3 3 3 3) ///
              labels("N obs" ///
                     "F pre (t=1–6, periodo#Early)" ///
                     "p-value pre" ///
                     "F post (t=8–11, periodo#Early)" ///
                     "p-value post")) ///
        varwidth(30) modelwidth(22) ///
        compress nogap nonotes ///
        title("Outcome: `y' — DiD por periodo (base t=7), cluster tarjeta")

}

********************************************************************************
* FIN
********************************************************************************

