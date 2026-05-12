version 18
set more off

*==========================================================*
* VALIDACION DE ESTRATOS PROXY
*   A) Validacion interna en universo elegible
*   B) Soporte por celdas en muestra analitica
*   C) Balance pre (periodo 6): SMD crudo vs ajustado
*
* NO borra la base en memoria
*==========================================================*

tempfile balres

*==========================================================*
* A) VALIDACION INTERNA DE ESTRATOS
*    Universo: elegibles de la primera aleatorizacion
*==========================================================*
preserve
    keep if flg_elegible_1==1

    keep cliente tarjeta periodo ///
         estrato_multitarjeta estrato_gama estrato_limcred4 estrato_comp4 ///
         clase limcreditocorte pagorealcorte pngini

    compress

    * una fila por cliente-tarjeta-periodo
    bys cliente tarjeta periodo: keep if _n==1

    *-----------------------------*
    * variables de validacion
    *-----------------------------*
    gen byte _p5 = (periodo==5)

    bys cliente: egen n_tarjetas_p5 = total(_p5)
    bys cliente: egen max_clase_p5 = max(cond(periodo==5, clase, .))
    bys cliente: egen lim_max_p5   = max(cond(periodo==5, limcreditocorte, .))

    * proxy de comportamiento del nuevo estrato 4
    gen double r_pago = .
    replace r_pago = pagorealcorte/pngini if inrange(periodo,2,5) & pngini>0 & !missing(pagorealcorte, pngini)

    bys cliente tarjeta: egen double avg_r_pago_tar = mean(r_pago)
    bys cliente: egen double worst_avg_r_pago = min(avg_r_pago_tar)

    keep cliente estrato_multitarjeta estrato_gama estrato_limcred4 estrato_comp4 ///
         n_tarjetas_p5 max_clase_p5 lim_max_p5 worst_avg_r_pago

    duplicates drop

    di as text "======================================================"
    di as text "VALIDACION INTERNA DE ESTRATOS (UNIVERSO ELEGIBLE)"
    di as text "======================================================"

    di as text "---- estrato_multitarjeta vs numero de tarjetas en p5 ----"
    tabstat n_tarjetas_p5, by(estrato_multitarjeta) ///
        stat(n mean sd p50 min max) columns(statistics)

    di as text "---- estrato_gama vs maxima clase en p5 ----"
    tabstat max_clase_p5, by(estrato_gama) ///
        stat(n mean sd p50 min max) columns(statistics)

    di as text "---- estrato_limcred4 vs limite maximo en p5 ----"
    tabstat lim_max_p5, by(estrato_limcred4) ///
        stat(n mean sd p50 min max) columns(statistics)

    di as text "---- estrato_comp4 vs peor promedio de pago/pngini en p2-p5 ----"
    tabstat worst_avg_r_pago, by(estrato_comp4) ///
        stat(n mean sd p50 min max) columns(statistics)
restore

*==========================================================*
* B) SOPORTE POR CELDAS EN MUESTRA ANALITICA
*==========================================================*
preserve
    keep if bpanel_alt==1 & flg_elegible_1==1 & periodo<=11 & papel_may2024_any==1
    keep if periodo==6

    bys tarjeta: keep if _n==1

    di as text "======================================================"
    di as text "SOPORTE POR CELDAS: treatment2 x estratos (muestra paper, periodo 6)"
    di as text "======================================================"

    tab treatment2 estrato_multitarjeta, missing
    tab treatment2 estrato_gama, missing
    tab treatment2 estrato_limcred4, missing
    tab treatment2 estrato_comp4, missing
restore

*==========================================================*
* C) BALANCE PRE EN PERIODO 6
*    Muestra analitica paper
*    SMD crudo vs ajustado por estratos
*==========================================================*
postfile H str20 var double n mean_t mean_c sd_t sd_c smd_raw smd_adj using `balres', replace

preserve
    keep if bpanel_alt==1 & flg_elegible_1==1 & periodo<=11 & papel_may2024_any==1
    keep if periodo==6

    keep cliente tarjeta treatment2 ///
         estrato_multitarjeta estrato_gama estrato_limcred4 estrato_comp4 ///
         interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w limcreditocorte

    bys tarjeta: keep if _n==1
    compress

    local balvars interesrev totalero totalero_alt ruso ctar delinquent rpagomin_w limcreditocorte

    foreach v of local balvars {

        quietly count if !missing(`v', treatment2)
        local N = r(N)

        if `N'==0 {
            continue
        }

        *-----------------------------*
        * SMD crudo
        *-----------------------------*
        quietly summarize `v' if treatment2==1
        local m1 = r(mean)
        local s1 = r(sd)

        quietly summarize `v' if treatment2==0
        local m0 = r(mean)
        local s0 = r(sd)

        local smd_raw = .
        local denom_raw = sqrt((`s1'^2 + `s0'^2)/2)
        if `denom_raw' > 0 & `denom_raw' < . {
            local smd_raw = (`m1' - `m0')/`denom_raw'
        }

        *-----------------------------*
        * SMD ajustado por estratos
        * residual de v sobre estratos
        *-----------------------------*
        capture drop __resid

        quietly regress `v' ///
            i.estrato_multitarjeta ///
            i.estrato_gama ///
            i.estrato_limcred4 ///
            i.estrato_comp4 ///
            if !missing(`v', treatment2, estrato_multitarjeta, estrato_gama, estrato_limcred4, estrato_comp4)

        predict double __resid if e(sample), resid

        quietly summarize __resid if treatment2==1
        local rm1 = r(mean)
        local rs1 = r(sd)

        quietly summarize __resid if treatment2==0
        local rm0 = r(mean)
        local rs0 = r(sd)

        local smd_adj = .
        local denom_adj = sqrt((`rs1'^2 + `rs0'^2)/2)
        if `denom_adj' > 0 & `denom_adj' < . {
            local smd_adj = (`rm1' - `rm0')/`denom_adj'
        }

        post H ("`v'") (`N') (`m1') (`m0') (`s1') (`s0') (`smd_raw') (`smd_adj')

        drop __resid
    }
restore

postclose H

*==========================================================*
* D) MOSTRAR RESULTADOS DE BALANCE SIN BORRAR LA BASE
*==========================================================*
preserve
    use `balres', clear

    gen abs_smd_raw = abs(smd_raw)
    gen abs_smd_adj = abs(smd_adj)
    gen reduction   = abs_smd_raw - abs_smd_adj

    gsort -abs_smd_raw

    di as text "======================================================"
    di as text "BALANCE PRE (periodo 6): SMD crudo vs ajustado"
    di as text "======================================================"
    list var n mean_t mean_c sd_t sd_c smd_raw smd_adj reduction, clean noobs
restore