clear all
set more off
use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBBVAAll.dta", clear

*******************************************************
* 1) ETIQUETAS BÁSICAS Y FILTROS INICIALES
*******************************************************

capture label drop per
label define per 1 "June-2023" 2 "Aug-2023" 3 "Oct-2023" 4 "Dec-2023" 5 "Feb-2024" 6 "Apr-2024" 7 "May-2024" 8 "June-2024" 9 "July-2024" 10 "Aug-2024" 11 "Sept-2024" 12 "Oct-2024" 13 "Nov-2024" 14 "Dec-2024" 15 "Jan-2025" 16 "Feb-2025" 17 "Mar-2025" 18 "Apr-2025" 19 "May-2025" 20 "June-2025"
label values periodo per

capture label drop nomemi
label define nomemi 40012 "BBVA" 40072 "BANORTE"
label values inst nomemi

drop if periodo > 16  // Se coloca 16 porque el código se creó cuando estaban disponibles 16 periodos con calidad decente, se pueden incorporar más periodos, sin embargo, el análisis CSDiD y las regresiones base, no ocupan más de los primeros 12 periodos

sort inst foliocred periodo
capture drop tarjeta
egen long tarjeta = group(inst foliocred)

sort inst folioclie tarjeta periodo
capture drop cliente
egen long cliente = group(inst folioclie)


capture drop edoctanvo
gen edoctanvo = edocuenta   // se crea para no modificar la variable original
replace edoctanvo = 0 if periodo < 7 & missing(edoctanvo)

*******************************************************
* Permanencia del tratamiento (una vez 1, siempre 1)
* En la base de datos se han observado alternancias ocasionadas por problemas operativos del emisor. Incluso se pueden observar tarjetas que reciben el tratamiento por primera vez en periodos no acordados, por ejemplo en julio, esto puede deberse a ser tarjetas nuevas (no debería) o porque en realidad lo recibieron en junio, pero el emisor reportó junio en 0. Este error se debe a que las tarjetas tuvieron un tipo de bloqueo en el periodo y se reportaron como 0, a pesar de ser un 1 realmente.
*******************************************************
* Limpieza por si ya existían
capture drop first_trat

* Orden dentro de tarjeta
sort tarjeta periodo

* 1) Primer periodo en que la tarjeta tiene edoctanvo==1
by tarjeta: egen int first_trat = min(cond(edoctanvo==1, periodo, .))

* 2) corrige los valores 0 a 1 en los casos con error
replace edoctanvo = 1 if first_trat<. & periodo >= first_trat
label var first_trat "First period treated"


* Etiquetas de valores para first_trat (7=Mayo-2024, 8=Junio-2024, ..., 13=Noviembre-2024)

capture label drop lbl_first_trat
label define lbl_first_trat ///
    7  "g7 (May-2024)" ///
    8  "g8 (June-2024)" ///
    9  "g9 (July-2024)" ///
    10 "g10 (Aug-2024)" ///
    11 "g11 (Sep-2024)" ///
    12 "g12 (Oct-2024)" ///
    13 "g13 (Nov-2024)", replace

label values first_trat lbl_first_trat
label var first_trat "Cohort (first time treated)"
*******************************************************
* OUTCOME VARIABLES
*******************************************************

capture drop ruso
gen ruso = saldototcorte/limcreditocorte
replace ruso = 1 if ruso > 1
replace ruso = 0 if ruso < 0

capture drop rusocompme
gen rusocompme = (saldomsicorte+saldomcicorte)/limcreditocorte

capture drop rpago
gen rpago = pagorealcorte/pngini
replace rpago = 1 if rpago > 1

capture drop rpagomin
gen rpagomin = pagorealcorte/pagominini

capture drop rpagomin_w
gen rpagomin_w = rpagomin
replace rpagomin_w = 66 if rpagomin_w > 66 & rpagomin_w < .

capture drop totalero
gen totalero = 0
replace totalero = 1 if interesrev == 0

capture drop totalero_alt
gen totalero_alt = 0
replace totalero_alt = 1 if pagorealcorte >= pngini

capture drop rtinter
gen rtinter = interesrev/saldototcorte

capture drop ctar
gen ctar = 0
replace ctar = 1 if pagorealfaltacorte > 0

capture drop compme
gen compme = 0
replace compme = 1 if saldomsicorte+saldomcicorte > 0

capture drop compmesi
gen compmesi = 0
replace compmesi = 1 if saldomsicorte > 0

capture drop compmeci
gen compmeci = 0
replace compmeci = 1 if saldomcicorte > 0

capture drop delinquent
gen delinquent = 0
replace delinquent = 1 if impagosc > 0

capture drop mujeres
gen mujeres = 0
replace mujeres = 1 if generocliente == 2
label variable mujeres "Women"
label variable ingresocliente "Income"

gen double dob_tc = clock(fechacliente , "DMY hms")   // "02dec1944 00:00:00"
gen dob = dofc(dob_tc)
format dob %tdDD/NN/CCYY
gen int edad = floor((today() - dob) / 365.25)

*******************************************************
*VALUE LABELS Y VARIABLE LABELS
*******************************************************
*========================
* VALUE LABELS
*========================

capture label drop totalerol
label define totalerol 0 "Revolving" 1 "Non-Revolving"
label values totalero totalerol
label values totalero_alt totalerol

capture label drop ctarl
label define ctarl 0 "Paid on time" 1 "Missed due date"
label values ctar ctarl

capture label drop compmel
label define compmel 0 "No deferred purchases" 1 "With deferred purchases"
label values compme compmel

capture label drop rpaper
label define rpaper 0 "Didn't receive paper statement" 1 "Received paper statement"
label values edocta_papel rpaper

capture label drop delinquent_val
label define delinquent_val 0 "No delinquent" 1 "Delinquent"
label values delinquent delinquent_val

capture label drop tratam   
label define tratam 0 "Old statement" 1 "New Statement"
label values edoctanvo tratam

capture label drop papel
label define papel 0 "Didn't receive paper statement" 1 "Received paper statement"
label values edocta_papel papel

*========================
* VARIABLE LABELS 
*========================

* Outcomes / principales (presentables)
label var interesrev    "Interest charged"
label var totalero      "Totalero (NIC)"
label var totalero_alt  "Totalero (FP)"
label var rpagomin_w    "Payment-to-minimum ratio"
label var ruso          "Credit utilization ratio"
label var ctar          "Late payment"
label var delinquent    "Delinquency"

* Otros que no estaban en "presentables" pero sí quieres etiquetar
label var rusocompme    "CUR (Deferred Purchases)"
label var rtinter       "Ratio Interest/Total Balance"
label var rpago         "Ratio Realized Payment/Payment to Avoid Interests"
label var rpagomin      "Ratio Realized Payment/Minimum Payment"
label var edad          "Age"

label var edoctanvo     "Treatment"
label var edoemail      "Download statement via email"
label var edoapp        "Download statement via app"
label var edoweb        "Download statement via website"
label var edocta_papel  "Receive paper statement"

* (Opcionales)
capture confirm variable saldototcorte
if !_rc label var saldototcorte "Total balance at statement close"

capture confirm variable limcreditocorte
if !_rc label var limcreditocorte "Credit limit"

capture confirm variable tasarev
if !_rc label var tasarev "Revolving interest rate"

label var periodo "Period"


*******************************************************
* AJUSTES FINALES DE CLASE
*******************************************************
replace clase = 1 if clase == 4
drop if clase > 3
capture label drop clasel
label define clasel 1 "Classic" 2 "Gold" 3 "Platinum"
label values clase clasel


*------------------------------------------------------------
* Top 10 productos (por # obs tarjeta-mes) en periodos 7-13
* Resto = "Otros"
*------------------------------------------------------------

local TOPN = 10
tempvar __win __freq __tag __r __rname

* Ventana de interés
gen byte `__win' = inrange(periodo, 7, 13)

* Frecuencia por producto dentro de la ventana (obs tarjeta-mes)
egen long `__freq' = total(`__win'), by(nombre)

* Marcar 1 obs por producto (sin ordenar la base)
egen byte `__tag' = tag(nombre)

* Rankear productos por tamaño (1 = más grande)
* unique fuerza exactamente TOPN aunque haya empates
egen int `__r' = rank(-`__freq') if `__tag', unique

* Propagar el rank a todas las obs del mismo producto
egen int `__rname' = min(`__r'), by(nombre)

* Variable final
capture drop nombre_top10
gen strL nombre_top10 = cond(!missing(nombre) & `__rname'<=`TOPN', nombre, "Otros")
label var nombre_top10 "Producto (Top `TOPN' en periodos 7-13; resto=Otros)"

* Limpieza
drop `__win' `__freq' `__tag' `__r' `__rname'


*******************************************************
* INCORPORAR SEGMENTOS DE INTERÉS
*******************************************************
run "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\02_2_segments_of_cards.do"

*run "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\03_proxy_strata.do" REVISAR QUÉ PUEDE SER DE UTILIDAD


*******************************************************
* INCORPORAR VARIABLES QUE SE UTILIZAN EN LOS ANÁLISIS SOBRE EL TRATAMIENTO
*******************************************************
* run "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\04_variables_for_modeling.do"  NO PARECE NECESARIO

*******************************************************
* CREACIÓN DE INDICADORES DEL PANEL BALANCEADO
*******************************************************
run "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\Impact_Eval\analisis_bbva\02_1_balanced_panel_var.do"
*******************************************************
* GUARDAR 
*******************************************************
compress

save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBBVAAll.dta", replace
