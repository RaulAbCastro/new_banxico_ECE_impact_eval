*******************************************************
* BBVA - Construcción unificada de segmentos pretratamiento
*
* Incluye:
*   1) Producto fijado en t=6:
*      - nombre_t6 (string)
*      - prod_t6   (numérica con labels)
*
*   2) Segmentos principales:
*      - seg_clase_t6
*      - seg_limcred_q_t6
*      - seg_ruso_q_t6
*      - seg_totalero_pre6
*
*   3) Segmentos adicionales:
*      - seg_ingreso_q_t6
*      - seg_edad_q_t6
*      - seg_antig_t6
*      - compme_t6
*      - mujeres_t6
*
* Notas:
*   - Todos los segmentos fijos en t=6 se construyen sobre eleg_bbva_base
*   - NO se modifican las etiquetas originales de clase
*******************************************************

version 18
set more off

*------------------------------------------------------*
* 0) Variable de elegibilidad a usar
*------------------------------------------------------*
local eligvar eleg_bbva_base

*------------------------------------------------------*
* 1) PRODUCTO fijado en t=6
*------------------------------------------------------*
preserve
keep if periodo==6
keep tarjeta nombre
rename nombre nombre_t6
duplicates drop tarjeta, force

tempfile prodt6
save `prodt6'
restore

capture drop nombre_t6
merge m:1 tarjeta using `prodt6', nogen keep(master match)

capture drop prod_t6
capture label drop prod_t6_lbl
encode nombre_t6, gen(prod_t6) label(prod_t6_lbl)

label var nombre_t6 "Producto fijado en periodo 6"
label var prod_t6   "Producto fijado en periodo 6 (numérico)"

*------------------------------------------------------*
* 2) CLASE fijada en t=6
*------------------------------------------------------*
capture drop seg_clase_t6
bys tarjeta: egen byte seg_clase_t6 = max(cond(periodo==6 & `eligvar'==1, clase, .))

local lbl_clase : value label clase
if "`lbl_clase'" != "" {
    label values seg_clase_t6 `lbl_clase'
}
label var seg_clase_t6 "Clase de tarjeta en periodo 6"

*------------------------------------------------------*
* 3) Cuartiles de límite de crédito en t=6
*------------------------------------------------------*
capture drop _lim_t6 _tag_lim_t6 seg_limcred_q_t6 _seg_limcred_q_t6

bys tarjeta: egen double _lim_t6 = max(cond(periodo==6 & `eligvar'==1, limcreditocorte, .))
egen byte _tag_lim_t6 = tag(tarjeta) if `eligvar'==1

xtile seg_limcred_q_t6 = _lim_t6 if _tag_lim_t6==1 & !missing(_lim_t6), nq(4)

bys tarjeta: egen byte _seg_limcred_q_t6 = max(seg_limcred_q_t6)
drop seg_limcred_q_t6
rename _seg_limcred_q_t6 seg_limcred_q_t6

label define lbl_seg_limcred_q_t6 ///
    1 "Q1 límite de crédito" ///
    2 "Q2 límite de crédito" ///
    3 "Q3 límite de crédito" ///
    4 "Q4 límite de crédito", replace
label values seg_limcred_q_t6 lbl_seg_limcred_q_t6
label var seg_limcred_q_t6 "Cuartil de límite de crédito en periodo 6"

*------------------------------------------------------*
* 4) Cuartiles de razón de uso en t=6
*------------------------------------------------------*
capture drop _ruso_t6 _tag_ruso_t6 seg_ruso_q_t6 _seg_ruso_q_t6

bys tarjeta: egen double _ruso_t6 = max(cond(periodo==6 & `eligvar'==1, ruso, .))
egen byte _tag_ruso_t6 = tag(tarjeta) if `eligvar'==1

xtile seg_ruso_q_t6 = _ruso_t6 if _tag_ruso_t6==1 & !missing(_ruso_t6), nq(4)

bys tarjeta: egen byte _seg_ruso_q_t6 = max(seg_ruso_q_t6)
drop seg_ruso_q_t6
rename _seg_ruso_q_t6 seg_ruso_q_t6

label define lbl_seg_ruso_q_t6 ///
    1 "Q1 razón de uso" ///
    2 "Q2 razón de uso" ///
    3 "Q3 razón de uso" ///
    4 "Q4 razón de uso", replace
label values seg_ruso_q_t6 lbl_seg_ruso_q_t6
label var seg_ruso_q_t6 "Cuartil de razón de uso en periodo 6"

*------------------------------------------------------*
* 5) Totalero pretratamiento usando periodos 1 a 6
*    Totalero = interesrev==0 en al menos 3 periodos
*------------------------------------------------------*
capture drop _pre6_obs _pre6_zeroir seg_totalero_pre6

bys tarjeta: egen int _pre6_obs    = total(inrange(periodo,1,6) & `eligvar'==1 & !missing(interesrev))
bys tarjeta: egen int _pre6_zeroir = total(inrange(periodo,1,6) & `eligvar'==1 & interesrev==0)

gen byte seg_totalero_pre6 = .
replace seg_totalero_pre6 = 1 if _pre6_obs==6 & _pre6_zeroir>=3
replace seg_totalero_pre6 = 0 if _pre6_obs==6 & _pre6_zeroir<3

label define lbl_seg_totalero_pre6 ///
    0 "No totalero pretratamiento" ///
    1 "Totalero pretratamiento", replace
label values seg_totalero_pre6 lbl_seg_totalero_pre6
label var seg_totalero_pre6 ///
    "Totalero pretratamiento: interesrev=0 en al menos 3 de los periodos 1-6"

*------------------------------------------------------*
* 6) INGRESO en cuartiles, fijado en t=6
*------------------------------------------------------*
capture drop _ing_t6 _tag_ing_t6 seg_ingreso_q_t6 _seg_ingreso_q_t6

bys tarjeta: egen double _ing_t6 = max(cond(periodo==6 & `eligvar'==1, ingresocliente, .))
egen byte _tag_ing_t6 = tag(tarjeta) if `eligvar'==1

xtile seg_ingreso_q_t6 = _ing_t6 if _tag_ing_t6==1 & !missing(_ing_t6), nq(4)

bys tarjeta: egen byte _seg_ingreso_q_t6 = max(seg_ingreso_q_t6)
drop seg_ingreso_q_t6
rename _seg_ingreso_q_t6 seg_ingreso_q_t6

label define lbl_seg_ingreso_q_t6 ///
    1 "Q1 ingreso" ///
    2 "Q2 ingreso" ///
    3 "Q3 ingreso" ///
    4 "Q4 ingreso", replace
label values seg_ingreso_q_t6 lbl_seg_ingreso_q_t6
label var seg_ingreso_q_t6 "Cuartil de ingreso del cliente en periodo 6"

*------------------------------------------------------*
* 7) EDAD en cuartiles, fijada en t=6
*------------------------------------------------------*
capture drop _edad_t6 _tag_edad_t6 seg_edad_q_t6 _seg_edad_q_t6

bys tarjeta: egen double _edad_t6 = max(cond(periodo==6 & `eligvar'==1, edad, .))
egen byte _tag_edad_t6 = tag(tarjeta) if `eligvar'==1

xtile seg_edad_q_t6 = _edad_t6 if _tag_edad_t6==1 & !missing(_edad_t6), nq(4)

bys tarjeta: egen byte _seg_edad_q_t6 = max(seg_edad_q_t6)
drop seg_edad_q_t6
rename _seg_edad_q_t6 seg_edad_q_t6

label define lbl_seg_edad_q_t6 ///
    1 "Q1 edad" ///
    2 "Q2 edad" ///
    3 "Q3 edad" ///
    4 "Q4 edad", replace
label values seg_edad_q_t6 lbl_seg_edad_q_t6
label var seg_edad_q_t6 "Cuartil de edad del cliente en periodo 6"

*------------------------------------------------------*
* 8) ANTIGÜEDAD de la tarjeta, fijada en t=6
*    mesapert = meses desde apertura
*    Grupos:
*      1) <= 6 meses
*      2) > 6 y < 12 meses
*      3) >= 12 meses
*------------------------------------------------------*
capture drop _antig_t6 seg_antig_t6

bys tarjeta: egen double _antig_t6 = max(cond(periodo==6 & `eligvar'==1, mesapert, .))

gen byte seg_antig_t6 = .
replace seg_antig_t6 = 1 if !missing(_antig_t6) & _antig_t6<=6
replace seg_antig_t6 = 2 if !missing(_antig_t6) & _antig_t6>6 & _antig_t6<12
replace seg_antig_t6 = 3 if !missing(_antig_t6) & _antig_t6>=12

label define lbl_seg_antig_t6 ///
    1 "6 meses o menos" ///
    2 "Mas de 6 y menos de 12 meses" ///
    3 "12 meses o mas", replace
label values seg_antig_t6 lbl_seg_antig_t6
label var seg_antig_t6 "Antigüedad de la tarjeta en periodo 6"

*------------------------------------------------------*
* 9) COMPRAS A MESES, fija en t=6
*------------------------------------------------------*
capture drop compme_t6
bys tarjeta: egen byte compme_t6 = max(cond(periodo==6 & `eligvar'==1, compme, .))

capture label define lbl_compme_t6 0 "Sin compras a meses" 1 "Con compras a meses", replace
capture label values compme_t6 lbl_compme_t6
label var compme_t6 "Compras a meses en periodo 6"

*------------------------------------------------------*
* 10) GÉNERO, fijo en t=6
*------------------------------------------------------*
capture drop mujeres_t6
bys tarjeta: egen byte mujeres_t6 = max(cond(periodo==6 & `eligvar'==1, mujeres, .))

capture label define lbl_mujeres_t6 0 "Hombre" 1 "Mujer", replace
capture label values mujeres_t6 lbl_mujeres_t6
label var mujeres_t6 "Género en periodo 6"

*------------------------------------------------------*
* 11) Limpieza de auxiliares
*------------------------------------------------------*
drop _lim_t6 _tag_lim_t6 ///
     _ruso_t6 _tag_ruso_t6 ///
     _pre6_obs _pre6_zeroir ///
     _ing_t6 _tag_ing_t6 ///
     _edad_t6 _tag_edad_t6 ///
     _antig_t6
*******************************************************