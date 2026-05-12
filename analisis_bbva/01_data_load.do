clear all 
use "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\panelexp.dta"

*-----Nos quedamos solo con BBVA
keep if inst == 40012

*------Solo nos quedamos con las variables que podríamos utilizar en los análisis
keep inst foliocred folioclie idprod edocta_papel tasarev limcreditoini limcreditocorte saldototini saldototcorte saldomsicorte saldomcicorte saldolrevini saldopsiini saldopciini saldolrevcorte saldopsicorte saldopcicorte interesrev interespci pagoexigmsicorte pagoexigmcicorte pagominini pngini pagomincorte pngicorte pagorealant pagorealcorte pagorealcapitalcorte pagorealintercorte pagorealcomscorte pagorealfaltacorte pagorealivacorte catcuenta situacion atrasos antiginst bkart mesapert impagosc hist periodo edoemail edoapp edoweb mtocomtotal mtocompagtard edocuenta generocliente ingresocliente fechacliente estadocliente municipiocliente idcliente

*-----Match con catálogo de productos (no contiene todas las variables del catálogo de productos)
merge m:1 inst idprod using "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\CatalogoProductos120824.dta"
keep if _merge==3
drop _merge
destring clase, replace


compress
save "\\bmstatadgasf2\Datos_STATA_DGASF\BASESFUENTE\BANXICO\RIBTC\CarlosArturo\2024\bases\baseBBVAAll.dta", replace
