table (nombre_top10 edoctanvo) periodo if inrange(periodo,7,13)

table (nombre_top10 edoctanvo) periodo if inrange(periodo,7,13), ///
    statistic(freq) statistic(percent, across(edoctanvo))
	

*------------------------------------------------------------
* Top 10 productos (por # obs tarjeta-mes) en periodos 7-13
* Crea variable numérica ordenable + labels (Otros=9999 al final)
*------------------------------------------------------------

local TOPN = 10

tempvar __win __freq __tag __r __rname
capture drop prod10

* Ventana
gen byte `__win' = inrange(periodo, 7, 13)

* Frecuencia por producto en la ventana (obs tarjeta-mes)
egen long `__freq' = total(`__win'), by(nombre)

* 1 obs por producto
egen byte `__tag' = tag(nombre)

* Rank por tamaño (1 = más grande). unique fuerza exactamente TOPN
egen int `__r' = rank(-`__freq') if `__tag', unique
egen int `__rname' = min(`__r'), by(nombre)

* Variable final numérica (orden)
gen int prod10 = cond(`__rname'<=`TOPN' & !missing(nombre), `__rname', 9999)
label var prod10 "Producto (Top `TOPN' en 7-13; Otros al final)"

* Labels: 1..TOPN con nombres + 9999=Otros
capture label drop prod10lbl
label define prod10lbl 9999 "Otros", replace
forvalues k = 1/`TOPN' {
    quietly levelsof nombre if `__tag' & `__r'==`k', local(nm)
    * Por construcción debe haber 1 nombre por rank; si hay varios por empate, toma el primero
    local nm1 : word 1 of `nm'
    label define prod10lbl `k' "`nm1'", add
}
label values prod10 prod10lbl

* Limpieza
drop `__win' `__freq' `__tag' `__r' `__rname'







****
table (prod10 edoctanvo) periodo if inrange(periodo,7,13), ///
    statistic(percent, across(edoctanvo)) ///
    nformat(%6.1f) ///
    nototals

* % con ECE por producto-top10 y mes (0–100)

table prod10 periodo if inrange(periodo,7,13), ///
    statistic(mean edoctanvo) ///
    nformat(%6.0f) ///
    nototals








