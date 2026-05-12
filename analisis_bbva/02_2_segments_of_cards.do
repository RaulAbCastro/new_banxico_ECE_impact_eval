*******************************************************
* SEGMENTOS CON CARACTERÍSTICAS EN UN PERIODO ESPECÍFICO
*******************************************************

sort tarjeta periodo

capture drop initot
generate initot = 0
replace initot = 1 if totalero == 1 & periodo == 6
by tarjeta: replace initot = sum(initot)
by tarjeta: replace initot = initot[_N]
capture label drop initotalero
label define initotalero 0 "Revolving Client in t=1" 1 "Non-revolving Client in t=1"
label values initot initotalero

capture drop inicomp
generate inicomp = 0
replace inicomp = 1 if saldomcicorte+saldomsicorte > 0 & periodo == 6
by tarjeta: replace inicomp = sum(inicomp)
by tarjeta: replace inicomp = inicomp[_N]
capture label drop inicompras
label define inicompras 0 "No deferred purchases in t=1" 1 "With deferred purchases in t=1"
label values inicomp inicompras

capture drop inisal
generate inisal = 0
replace inisal = 1 if saldototcorte > 0 & periodo == 6
by tarjeta: replace inisal = sum(inisal)
by tarjeta: replace inisal = inisal[_N]
capture label drop inisaldo
label define inisaldo 0 "No Balance in t=1" 1 "Balance greater than 0 in t=1"
label values inisal inisaldo

capture drop tasaini
gen tasaini = 0
replace tasaini = tasarev if periodo == 6
by tarjeta: replace tasaini = sum(tasaini)

capture drop lcini
gen lcini = 0
replace lcini = limcreditoini if periodo == 6
by tarjeta: replace lcini = sum(lcini)

capture drop saldini
gen saldini = 0
replace saldini = saldototini if periodo == 6
by tarjeta: replace saldini = sum(saldini)

capture drop delini
gen delini = 0
replace delini = impagosc if periodo == 6
by tarjeta: replace delini = sum(delini)

capture drop del6mini
gen del6mini = 0
replace del6mini = hist if periodo == 6
by tarjeta: replace del6mini = sum(del6mini)

capture drop edadini
gen edadini = 0
replace edadini = mesapert if periodo == 6
by tarjeta: replace edadini = sum(edadini)