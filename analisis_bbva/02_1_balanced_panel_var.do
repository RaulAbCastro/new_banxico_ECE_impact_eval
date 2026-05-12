*------------------------------------------------------------
* bpanel     : 1 si tarjeta tiene info 1..16
* bpanel_alt : 1 si tarjeta tiene info 1..12
*------------------------------------------------------------

* 1) Tag único por tarjeta-periodo (para contar periodos únicos)
bysort tarjeta periodo: gen byte __tag_tp = (_n==1)

* 2) Indicador de duplicado tarjeta-periodo (1 si hay más de 1 fila)
bysort tarjeta periodo: gen byte __dup_tp = (_N>1)

* 3) Conteos de periodos únicos por tarjeta (ignorando duplicados)
bysort tarjeta: egen byte __nper_1_16 = total(__tag_tp * inrange(periodo,1,16))
bysort tarjeta: egen byte __nper_1_13 = total(__tag_tp * inrange(periodo,1,13))

* 4) ¿La tarjeta tiene algún duplicado dentro de la ventana?
bysort tarjeta: egen byte __anydup_1_16 = max(__dup_tp * inrange(periodo,1,16))
bysort tarjeta: egen byte __anydup_1_13 = max(__dup_tp * inrange(periodo,1,13))

* 5) Dummies finales: completa + sin duplicados
capture drop bpanel
gen byte bpanel = (__nper_1_16==16 & __anydup_1_16==0)

capture drop bpanel_alt
gen byte bpanel_alt = (__nper_1_13==13 & __anydup_1_13==0)

* 6) Limpieza: borrar auxiliares
drop __tag_tp __dup_tp __nper_1_16 __nper_1_13 __anydup_1_16 __anydup_1_13