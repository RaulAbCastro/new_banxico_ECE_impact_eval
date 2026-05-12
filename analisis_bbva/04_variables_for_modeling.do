***ESTE CÓDIGO ES PENSANDO EN EL SEGMENTO DE TARJETAS QUE RECIBEN EL ESTADO DE CUENTA EN PAPEL, POR LO QUE SI SE REQUIERE ANALIZAR A OTROS SEGMENTOS, SE DEBE REVISAR CON CUIDADO

**-EXISTEN DOS FORMAS PROPUESTAS PARA ANALIZAR LOS DATOS, UNA ES MANTENIENDO LA ESTRUCTURA REAL DEL ROLL OUT DEL PRIMER SET, ES DECIR, CONSIDERAR QUE EL TRATAMIENTO SE RECIBIÓ EN MAYO Y EN JUNIO (MUY POCAS TARJETAS RECIBEN EL TRATAMIENTO EN MAYO), ES DECIR, UNA LIBERACIÓN ESCALONADA. LA SEGUNDA FORMA, ES CONSIDERAR QUE EL TRATAMIENTO SE RECIBIÓ A PARTIR DE JUNIO, ES DECIR, CONSIDERAR QUE LAS POCAS TARJETAS QUE RECIBIERON EL TRATAMIENTO EN MAYO, EN REALIDAD LO RECIBIERON EN JUNIO. SI SOLO HAY UN PERIODO DE LIBERACIÓN DEL TRATAMIENTO, SE SIMPLIFICA MUCHO EL ANÁLISIS.

*=====================VARIABLES CONSIDERANDO LIBERACION ESCALONADA EN MAYO Y JUNIO =============================
*================================================================================================================

*========================
* Dummy que identifica al grupo de tratamiento, forma alternativa
*========================
capture drop treatment
gen byte treatment = .
replace treatment = 1 if inlist(first_trat, 7, 8)
replace treatment = 0 if first_trat > 8

label define L_earlylate 1 "Early group" 0 "Later group", replace
label values treatment L_earlylate
label var treatment "Control/Treatment"


*=====================VARIABLES CONSIDERANDO LIBERACION UNICA EN JUNIO =============================
*================================================================================================================

***NOTAR QUE EN LOS RESULTADOS PRESENTADOS SE UTILIZA ESTA FORMA ALTERNATIVA POR ACUERDO CON LOS INVESTIGADORES, YA QUE ES UNA FORMA MÁS PARSIMONIOSA DE ANÁLISIS, LA JUSTIFICACIÓN PRINCIPAL ES PORQUE EL NUMERO DE TARJETAS QUE RECIBIERON EL TRATAMIENTO EN MAYO ES PEQUEÑO, LO CUAL NO DEBERÍA AFECTAR LOS RESULTADOS, EN ADICIÓN DE QUE EL TRATAMIENTO ES PERMANENTE.


capture drop edoctanvo_alt
gen edoctanvo_alt = edoctanvo
replace edoctanvo_alt = 0 if periodo == 7

*========================
* Primer periodo tratado, forma alternativa
*========================
capture drop first_trat_alt
gen first_trat_alt = first_trat
replace first_trat_alt = 8 if first_trat_alt == 7
label var first_trat_alt "First period treated"

*========================
* Dummy que identifica al grupo de tratamiento, forma alternativa
*========================
capture drop treatment2
gen byte treatment2 = .

replace treatment2 = 1 if inlist(first_trat_alt, 8)
replace treatment2 = 0 if first_trat_alt > 8

label define L_earlylate2 1 "Early group" 0 "Later group", replace
label values treatment2 L_earlylate2
label var treatment2 "Control/Treatment"

