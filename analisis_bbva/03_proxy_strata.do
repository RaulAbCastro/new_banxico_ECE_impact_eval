
*============================================================*
* ESTRATOS A NIVEL CLIENTE (versión sin preserve anidado)
*   Periodo 5 (feb-2024): multitarjeta, gama, línea, comp (peor)
*   Periodo 6 (apr-2024): recibió edocta en papel
* Requiere: cliente, tarjeta, periodo, clase,
*           limcreditocorte, pagorealcorte, pngini, edocta_papel
*============================================================*

* ---- Tempfiles para resultados intermedios
tempfile _p5 _p6 _estratos

*============================================================*
* ======= FOTO PERIODO 5: multitarjeta, gama, línea, comp ===
*============================================================*
preserve
keep if periodo == 5

* (por seguridad) 1 fila por tarjeta dentro de cliente
bys cliente tarjeta: keep if _n == 1

* 1) Multitarjeta (0 una; 1 >1)
bys cliente: gen num_tarjetas_feb24 = _N
gen byte estrato_multitarjeta = num_tarjetas_feb24 > 1
label define L_bin 0 "Una tarjeta" 1 "Más de una", replace
label values estrato_multitarjeta L_bin
label var estrato_multitarjeta "Number of cards"

* 2) Gama (1=solo clás.; 2=oro o mix clás+oro; 3=≥1 platino)
bys cliente: egen min_clase = min(clase)
bys cliente: egen max_clase = max(clase)
gen byte estrato_gama = .
replace estrato_gama = 1 if min_clase==1 & max_clase==1
replace estrato_gama = 2 if max_clase<=2 & estrato_gama==.
replace estrato_gama = 3 if max_clase==3
label define L_gama 1 "Classic" 2 "Gold" 3 "Platinum", replace
label values estrato_gama L_gama
label var estrato_gama "Highest class"

* 3) Línea de crédito (máximo entre tarjetas en periodo 5)
bys cliente: egen double lim_max_feb24 = max(limcreditocorte)
gen byte estrato_limcred4 = .
replace estrato_limcred4 = 1 if lim_max_feb24 <= 11000              & !missing(lim_max_feb24)
replace estrato_limcred4 = 2 if lim_max_feb24 >  11000 & lim_max_feb24 <= 27000
replace estrato_limcred4 = 3 if lim_max_feb24 >  27000 & lim_max_feb24 <= 64000
replace estrato_limcred4 = 4 if lim_max_feb24 >  64000
label define L_lim 1 "<= 11,000" 2 "(11,000, 27,000]" 3 "(27,000, 64,000]" 4 "> 64,000", replace
label values estrato_limcred4 L_lim
label var estrato_limcred4 "Highest Credit Limit"

* 4) Comportamiento (peor tarjeta del cliente en periodo 5)
gen double r_pago = .
replace r_pago = pagorealcorte/pngini if pngini>0 & !missing(pagorealcorte, pngini)
bys cliente: egen double min_r_pago = min(r_pago)

gen byte estrato_comp4 = .
replace estrato_comp4 = 1 if min_r_pago >= 0.95
replace estrato_comp4 = 2 if min_r_pago < 0.95 & min_r_pago >= 0.74
replace estrato_comp4 = 3 if min_r_pago < 0.74 & min_r_pago >= 0.17
replace estrato_comp4 = 4 if min_r_pago < 0.17
label define L_comp 1 "≥95% of pngini" 2 "[74%, 95%)" 3 "[17%, 74%)" 4 "<17%", replace
label values estrato_comp4 L_comp
label var estrato_comp4 "% of PNGI paid"

drop r_pago min_r_pago

* Guardar solo una fila por cliente con estratos de p5
keep cliente estrato_multitarjeta estrato_gama estrato_limcred4 estrato_comp4
duplicates drop
save `_p5'
restore

*============================================================*
* ======= FOTO PERIODO 6: recibió edocta en papel ===========*
*============================================================*
preserve
keep if periodo == 6
bys cliente tarjeta: keep if _n == 1

* 5) Recibió edocta en papel (1 si alguna tarjeta con edocta_papel==1)
bys cliente: egen byte estrato_papel = max(edocta_papel)
capture label drop L_bin_papel
label define L_bin_papel 0 "Didn't receive paper statement" 1 "Received paper statement" 
label values estrato_papel L_bin_papel
label var estrato_papel "Received Paper statement in April 2024"

keep cliente estrato_papel
duplicates drop
save `_p6'
restore

*============================================================*
* ======= COMBINAR ESTRATOS Y MERGEAR AL PANEL ==============*
*============================================================*
preserve
use `_p5', clear
merge 1:1 cliente using `_p6', nogenerate
save `_estratos', replace
restore

merge m:1 cliente using `_estratos', nogenerate
*============================================================*


