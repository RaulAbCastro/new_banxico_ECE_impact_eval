*ESTE DOFILE CREA UNA BASE DE DATOS QUE CONTIENE SOLAMENTE A LAS TARJETAS QUE RECIBEN EL ESTADO DE CUENTA EN PAPEL.
*CABE DESTACAR QUE NO EXISTE UNA ÚNICA DEFINICIÓN DE ESTE TIPO DE USUARIOS. POR EJEMPLO, SE PUEDE DEFINIR COMO LAS TARJETAS QUE RECIBIERON EL ESTADO DE CUENTA EN PAPEL EN MAYO 2024, EN JUNIO 2024, AGOSTO 2024, O ALGUN OTRO PERIODO DE REFERENCIA. UNA DEFINICIÓN MENOS FLEXIBLE ES CONSIDERAR USUARIOS DE ESTADO DE CUENTA EN PAPEL, A LAS TARJETAS QUE RECIBIERON EL ESTADO DE CUENTA EN TODO EL PERIODO DE ANÁLISIS. 

*COMO SE PUDO NOTAR EN UN DOFILE ANTERIOR, SE CONSTRUYERON VARIABLES INDICADORAS PARA CAPTURAR 

clear all
set more off
use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBBVAAll.dta", clear


*===========================================================
* Asegurar que no haya alternancias entre recibir un periodo el estado de cuenta, luego dejar de recibirlo, y luego volver a recibirlo: rellenar ceros "entre unos" en edocta_papel (solo 6..16)
*    Lógica: edo_fix_t = max_{s>=t} edo_s  (sufijo máximo, escaneo hacia atrás)
* Lo que sí puede pasar es que una vez que se deja de recibir el estado de cuenta en papel, sea de forma permanente por políticas de paper-less que implementó el emisor.
*===========================================================

capture drop edocta_papel_fix
gen byte edocta_papel_fix = edocta_papel

* Trata missing como 0 dentro de la ventana (para que no rompa el back-fill)
replace edocta_papel_fix = 0 if missing(edocta_papel_fix) & inrange(periodo,6,16)

* Back-fill: si en un periodo posterior hay 1, los anteriores dentro de 6..16 van a 1
gsort tarjeta -periodo
by tarjeta: replace edocta_papel_fix = max(edocta_papel_fix, edocta_papel_fix[_n-1]) ///
    if _n>1 & inrange(periodo,6,16)

* Regresa a orden natural
sort tarjeta periodo

*===========================================================
* Verificación: identifica tarjetas con alternancias (0 que se vuelven 1)
*===========================================================
capture drop edocta_papel_filled
gen byte edocta_papel_filled = (inrange(periodo,6,16) & edocta_papel==0 & edocta_papel_fix==1)

capture drop edocta_papel_has_alt
bys tarjeta: egen byte edocta_papel_has_alt = max(edocta_papel_filled)

replace edocta_papel = edocta_papel_fix if inrange(periodo,6,16)
drop edocta_papel_fix

*******************************************************
* GRUPOS DE REVISIÓN DE ESTADO DE CUENTA EN PAPEL
*******************************************************
* Todos los periodos mayo-oct 2024
capture drop in_win_7a12
capture drop papel_en_win
capture drop n_obs_win
capture drop n_papel_win
capture drop papel_todos_7a12
gen byte in_win_7a12 = inrange(periodo, 7, 12)
gen byte papel_en_win = (edocta_papel==1) if in_win_7a12
bys tarjeta: egen n_obs_win   = total(in_win_7a12)
bys tarjeta: egen n_papel_win = total(papel_en_win)
gen byte papel_todos_7a12 = (n_obs_win==6 & n_papel_win==6)
label var papel_todos_7a12 "Received paper statement"

capture confirm variable rev_papel_allp
if !_rc drop rev_papel_allp
rename papel_todos_7a12 rev_papel_allp

* Mayo 2024
capture drop _papel_may2024_row
capture drop papel_may2024_any
gen byte _papel_may2024_row = (periodo==7 & edocta_papel==1)
bys tarjeta: egen byte papel_may2024_any = max(_papel_may2024_row)
label var papel_may2024_any "Received paper statement in May 2024"
drop _papel_may2024_row

* Agosto 2024
capture drop _papel_ago2024_row
capture drop papel_ago2024_any
gen byte _papel_ago2024_row = (periodo==10 & edocta_papel==1)
bys tarjeta: egen byte papel_ago2024_any = max(_papel_ago2024_row)
label var papel_ago2024_any "Received paper statement in August 2024"
drop _papel_ago2024_row

* Octubre 2024
capture drop _papel_oct2024_row
capture drop papel_oct2024_any
gen byte _papel_oct2024_row = (periodo==12 & edocta_papel==1)
bys tarjeta: egen byte papel_oct2024_any = max(_papel_oct2024_row)
label var papel_oct2024_any "Received paper statement in October 2024"
drop _papel_oct2024_row

* Último periodo (Feb 2025)
capture drop _papel_feb2025_row
capture drop papel_feb2025_any
gen byte _papel_feb2025_row = (periodo==16 & edocta_papel==1)
bys tarjeta: egen byte papel_feb2025_any = max(_papel_feb2025_row)
label var papel_feb2025_any "Received paper statement in February 2025"
drop _papel_feb2025_row

drop in_win_7a12 papel_en_win n_obs_win n_papel_win

keep if papel_may2024_any == 1 
save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBBVApaper.dta", replace


*use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBBVApaper.dta"