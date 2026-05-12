clear all 
use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\panelexp.dta"

*use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBanortepaper.dta"

keep inst foliocred folioclie idprod edocta_papel etapa reestruc medioadq qcbd tasarev limcreditoini limcreditocorte limcreditorvas saldototini saldototcorte saldomsicorte saldomcicorte saldocont saldolrevini saldopsiini saldopciini saldolrevcorte saldopsicorte saldopcicorte interesrev interespci pagoexigmsicorte pagoexigmcicorte pagominini pngini pagomincorte pngicorte pagorealant pagorealcorte pagorealcapitalcorte pagorealintercorte pagorealcomscorte pagorealfaltacorte pagorealivacorte catcuenta situacion mesessic segmento atrasos antiginst bkart mesapert impagosc hist tasaanual tasaint periodo edoemail edoapp edoweb mtocomtotal mtocompagtard edocuenta generocliente ingresocliente fechacliente estadocliente municipiocliente idcliente

*label drop per
label define per 1 "June-2023" 2 "Aug-2023" 3 "Oct-2023" 4 "Dec-2023" 5 "Feb-2024" 6 "Apr-2024" 7 "May-2024" 8 "June-2024" 9 "July-2024" 10 "Aug-2024" 11 "Sept-2024" 12 "Oct-2024" 13 "Nov-2024" 14 "Dec-2024" 15 "Jan-2025" 16 "Feb-2025" 17 "Mar-2025" 18 "Apr-2025" 19 "May-2025" 20 "June-2025"
label values periodo per

label define nomemi 40012 "BBVA" 40072 "BANORTE"
label values inst nomemi

*keep if inst == 40012  //  Banorte: 40072 , BBVA: 40012
*
drop if periodo > 16

sort inst foliocred periodo
egen long tarjeta=group(inst foliocred)  //  este comando crea una variable que identifica con un número entero a cada tarjeta única

sort inst folioclie tarjeta periodo
egen long cliente=group(inst folioclie)




gen producto = idprod 
rename edocuenta edoctanvo
gen tratamiento = edoctanvo 
*


****

label define tratam 0 "Old statement" 1 "New Statement"
label values tratamiento tratam

label define papel 0 "Didn't receive paper statement" 1 "Received paper statement"
label values edocta_papel papel  


***CREACIÓN DEL PANEL BALANCEADO 

gen nump=1  
sort inst tarjeta periodo
by inst tarjeta: replace nump=sum(nump)
by inst tarjeta: replace nump=nump[_N] //creación de variable que indica el número de periodos de los que se tiene información para cada tarjeta


*****OTROS FILTROS APLICADOS (OBLIGATORIOS)

*Se necesita garantizar que no haya tarjetas que cambian de grupo de control o tratamiento. Esto posiblemente porque cambien de tarjeta y no se les ofrezca el mismo producto en la renovación.
sort producto
egen prod=group(producto)    // Asigna un valor numérico a cada producto de la base

gen cprod=0
sort tarjeta periodo
by tarjeta: replace cprod=sum(prod)   
by tarjeta: replace cprod=cprod[_N]   // para cada tarjeta realiza la suma total del número de producto asignado
gen npro=cprod/nump   // se divide la suma obtenida arriba entre el número de periodos en los que la tarjeta i tiene información.
gen retr=0
replace retr=1 if npro!=prod   // si no hubo un cambio de producto en la tarjeta i durante el periodo, entonces la división anterior debe ser igual al número de producto asignado en la variable "prod".


gen panel = 0
replace panel = 1 if nump == 16 & retr == 0


*** FILTROS BANORTE

run "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\Dofiles\filtros.do"


gen sis = 1 

*****outcome variables
gen ruso=saldototcorte/limcreditocorte
replace ruso = 1 if ruso > 1
replace ruso = 0 if ruso < 0
gen rusocompme=(saldomsicorte+saldomcicorte)/limcreditocorte
gen rpago=pagorealcorte/pngini
replace rpago = 1 if rpago > 1
gen rpagomin=pagorealcorte/pagominini
gen rpagomin_w = rpagomin
replace rpagomin_w = 66 if rpagomin_w > 66 & rpagomin_w < .
gen totalero=0
replace totalero=1 if interesrev==0
gen totalero_alt = 0
replace totalero_alt = 1 if pagorealcorte >= pngini
gen rtinter=interesrev/saldototcorte
gen ctar=0
replace ctar=1 if pagorealfaltacorte>0
gen compme=0
replace compme=1 if saldomsicorte+saldomcicorte>0
gen compmesi=0
replace compmesi=1 if saldomsicorte>0
gen compmeci=0
replace compmeci=1 if saldomcicorte>0
gen delinquent = 0
replace delinquent = 1 if impagosc > 0

gen mujeres = 0
replace mujeres = 1 if generocliente == 2
label variable mujeres "Women"
label variable ingresocliente "Income"


label define totalerol 0 "Revolving" 1 "Non-Revolving"
label values totalero totalerol
label values totalero_alt totalerol

label define ctarl 0 "Paid on time" 1 "Missed due date"
label values ctar ctarl

label define compmel 0 "No deferred purchases" 1 "With deferred purchases"
label values compme compmel

label define rpaper 0 "Didn't receive paper statement" 1 "Received paper statement" 
label values edocta_papel rpaper

label define delinquent_val 0 "No delinquent" 1 "Delinquent"
label values delinquent delinquent_val

label variable  ruso "CUR"
label variable  rusocompme "CUR (Deferred Purchases)"
label variable  interesrev "Interests Charged"
label variable  rtinter "Ratio Interest/Total Balance"
label variable  rpago "Ratio Realized Payment/Payment to Avoid Interests"
label variable  rpagomin "Ratio Realized Payment/Minimum Payment"
label variable  rpagomin_w "Ratio Realized Payment/Minimum Payment"
label variable  ctar "Missed the due date"
label variable tratamiento "Treatment"
label variable edoemail "Download statement via email"
label variable edoapp "Download statement via app"
label variable edoweb "Download statement via website"
label variable edocta_papel "Receive paper statement"

label variable delinquent "Delinquency indicator"
label variable rpagomin_w "Payment-to-minimum ratio"
label variable totalero "No interest charged"
label variable totalero_alt "Full payment (PNGI)"
label variable saldototcorte "Total balance"
label variable limcreditocorte "Credit limit"
label variable tasarev "Interest rate"

*==============================================================*
* Labels "presentables" para reporte (sin renombrar variables)
*==============================================================*

*----------------------------
* OUTCOMES
*----------------------------
label var interesrev    "Interest charges"
label var totalero      "Total payer (no interest charged)"
label var totalero_alt  "Full payment (PNGI)"
label var rpagomin_w    "Payment-to-minimum ratio"
label var ruso          "Credit utilization ratio"
label var ctar          "Late payment fee indicator"
label var delinquent    "Delinquency indicator"

* (Opcionales que usaste en descriptivos)
capture confirm variable saldototcorte
if !_rc label var saldototcorte "Total balance at statement close"

capture confirm variable limcreditocorte
if !_rc label var limcreditocorte "Credit limit"

capture confirm variable tasarev
if !_rc label var tasarev "Revolving interest rate"

*----------------------------
* TRATAMIENTO: value labels para treatment2
*----------------------------
capture label drop tr2
label define tr2 0 "Control (deferred treatment)" 1 "Early treatment group", replace
label values treatment2 tr2
label var treatment2 "Early treatment indicator"

*----------------------------
* TIEMPO: label para el índice (si quieres)
*----------------------------
label var periodo "Period index (t)"

* Si ya tienes value labels para periodo (mes-año), NO los toco aquí.
* Si NO los tienes y quieres crearlos, dímelo y te paso el bloque.

*----------------------------
* TRATAMIENTO: value labels para treatment2
*----------------------------
capture label drop tr2
label define tr2 0 "Control (deferred treatment)" 1 "Early treatment group", replace
label values treatment2 tr2
label var treatment2 "Early treatment indicator"

*----------------------------
* TIEMPO: label para el índice (si quieres)
*----------------------------
label var periodo "Period index (t)"

**SEGMENTOS CON CARACTERÍSTICAS EN EL T == 1
*totalero
sort tarjeta periodo
generate initot=0
replace initot=1 if totalero==1&periodo==7

by tarjeta: replace initot=sum(initot)
by tarjeta: replace initot=initot[_N]

label define initotalero 0 "Revolving Client in t=1" 1 "Non-revolving Client in t=1"
label values initot initotalero

*Compras
generate inicomp=0
replace inicomp=1 if saldomcicorte+saldomsicorte>0&periodo==7

by tarjeta: replace inicomp=sum(inicomp)
by tarjeta: replace inicomp=inicomp[_N]

label define inicompras 0 "No deferred purchases in t=1" 1 "With deferred purchases in t=1"
label values inicomp inicompras

*saldopositivo
generate inisal=0
replace inisal=1 if saldototcorte>0&periodo==7

by tarjeta: replace inisal=sum(inisal)
by tarjeta: replace inisal=inisal[_N]

label define inisaldo 0 "No Balance in t=1" 1 "Balance greater than 0 in t=1"
label values inisal inisald

*tasa de interés al inicio del periodo
sort tarjeta periodo
gen tasaini = 0
replace tasaini = tasarev if periodo == 7
by tarjeta: replace tasaini = sum(tasaini)

*límite de crédito al inicio del periodo en el periodo 1
gen lcini = 0
replace lcini = limcreditoini if periodo == 7
by tarjeta: replace lcini = sum(lcini)

*saldo total
gen saldini = 0
replace saldini = saldototini if periodo == 7
by tarjeta: replace saldini = sum(saldini)

*delinquency
gen delini = 0
replace delini = impagosc if periodo == 7
by tarjeta: replace delini = sum(delini)

gen del6mini = 0
replace del6mini = hist if periodo == 7
by tarjeta: replace del6mini = sum(del6mini)

*Edad de la tarjeta

gen edadini = 0
replace edadini = mesapert if periodo == 7
by tarjeta: replace edadini = sum(edadini)

*******************
*********GRUPOS DE REVISIÓN DE ESTADO DE CUENTA
gen edoapp1 = edoapp
gen edoweb1 = edoweb
gen edocta_papel1 = edocta_papel
sort tarjeta periodo 
by tarjeta: replace edocta_papel1 = 0 if periodo<=6 // esto es porque la calidad de la información para antes de abril, es mala

replace edoapp1 = 0 if edoapp1 == 2
replace edoweb1 = 0 if edoweb1 == 2

**REVISÓ ESTADO DE CUENTA EN TODOS LOS PERIODOS DESDE MAYO A OCTUBRE (de momento solo papel)
* Asegura panel ordenado (opcional)
sort tarjeta periodo

* Marca la ventana mayo–oct 2024 (7–12)
gen byte in_win_7a12 = inrange(periodo, 7, 12)

* Marca "1" cuando haya papel en esa ventana (0 en caso contrario dentro de la ventana)
gen byte papel_en_win = (edocta_papel==1) if in_win_7a12

* (Por tarjeta) cuenta cuántas observaciones hay en la ventana y cuántas con papel==1
bys tarjeta: egen n_obs_win   = total(in_win_7a12)
bys tarjeta: egen n_papel_win = total(papel_en_win)

* Indicador final: 1 si la tarjeta tuvo papel en TODOS los 6 periodos (y existen los 6 periodos)
gen byte papel_todos_7a12 = (n_obs_win==6 & n_papel_win==6)
label var papel_todos_7a12 "Received paper statement"

rename papel_todos_7a12 rev_papel_allp

**REVISÓ ESTADO DE CUENTA EN MAYO
gen byte _papel_may2024_row = (periodo==7 & edocta_papel==1)
bys tarjeta: egen byte papel_may2024_any = max(_papel_may2024_row)
label var papel_may2024_any "Received paper statement in May 2024"
drop _papel_may2024_row


**REVISÓ ESTADO DE CUENTA EN AGOSTO
gen byte _papel_ago2024_row = (periodo==10 & edocta_papel==1)
bys tarjeta: egen byte papel_ago2024_any = max(_papel_ago2024_row)
label var papel_ago2024_any "Received paper statement in August 2024"
drop _papel_ago2024_row


***REVISÓ ESTADO DE CUENTA EN OCTUBRE
gen byte _papel_oct2024_row = (periodo==12 & edocta_papel==1)
bys tarjeta: egen byte papel_oct2024_any = max(_papel_oct2024_row)
label var papel_oct2024_any "Received paper statement in October 2024"
drop _papel_oct2024_row


***REVISÓ ESTADO DE CUENTA EN ULTIMO PERIODO

gen byte _papel_feb2025_row = (periodo==16 & edocta_papel==1)
bys tarjeta: egen byte papel_feb2025_any = max(_papel_feb2025_row)
label var papel_feb2025_any "Received paper statement in February 2025"
drop _papel_feb2025_row

*****Modificación de quienes recibieron estado de cuetna en junio y recibieron tratamiento en agosto

*sort tarjeta periodo
*by tarjeta: replace treatment = 0 if treatment == 2 // REVISAR 


merge m:1 inst idprod using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\CatalogoProductos120824.dta"
keep if _merge==3
drop _merge
destring clase, replace


***Matchear listas de Banorte

merge m:1 foliocred using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\FoliosElegiblesBanorte\BASE_FEB24_SET1.dta"
rename _merge match1

merge m:1 foliocred using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\FoliosElegiblesBanorte\BASE_JUN24_SET2.dta"
rename _merge match2



*************
replace clase = 1 if clase == 4 & (flg_elegible_1 == 1 | flg_elegible_2 == 1)
drop if clase > 3
label define clasel 1 "Classic" 2 "Gold" 3 "Platinum"
label values clase clasel

*replace flg_elegible_2 = 0 if treatment == 1 & flg_elegible_2 == .  // REVISAR


*




