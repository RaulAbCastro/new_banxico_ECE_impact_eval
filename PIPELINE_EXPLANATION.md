# Pipeline completo y descripción de do-files

Este documento resume el flujo de trabajo del repositorio y explica qué hace cada archivo `.do`.

## 1) Resumen ejecutivo del pipeline

Flujo general (de datos crudos a resultados):

1. Construcción del panel mensual BBVA/Banorte desde CSVs.
2. Carga y limpieza de BBVA para crear base analítica con variables de resultado y etiquetas.
3. Construcción de segmentos/estratos y universo elegible.
4. Definición de tratamiento y submuestra de usuarios con estado de cuenta en papel.
5. Estimaciones principales (OLS DiD por periodo y CSDID event-study).
6. Robustez (XTREG FE tarjeta, LOGIT) y pruebas de balance/auditorías.

## 2) Dependencias y supuestos importantes

- Los scripts usan rutas de red UNC (`\\bmstatadgasf2\...`) y esperan acceso a esos archivos.
- Varios scripts de estimación asumen que la base ya está cargada en memoria (no hacen `use` al inicio).
- Paquetes de Stata usados en varias salidas:
1. `estout` (por `esttab`, `eststo`, `estadd`)
2. `csdid`
3. `event_plot`
- El índice `periodo` está mapeado de forma secuencial (1 = Jun-2023, ..., 20 = Jun-2025 en construcción; varios análisis recortan a <=12 o <=16).

## 3) Orden recomendado de ejecución (pipeline principal)

### Etapa A. Construcción de panel base

1. `panel_creat/Panel_BBVA_Banorte.do`
2. (Alternativa simplificada) `panel_creat/Panel_BBVA_Banorte_VS.do`

Resultado esperado: `panelexp.dta`.

### Etapa B. Preparación BBVA

1. `analisis_bbva/01_data_load.do`
2. `analisis_bbva/02_variable_definition_cleaness.do`
3. `analisis_bbva/01_1_eligible_universe.do`
4. `analisis_bbva/04_variables_for_modeling.do`
5. `analisis_bbva/05_Paper_users.do`

Resultados esperados:
- `baseBBVAAll.dta` (limpia y enriquecida)
- `baseBBVApaper.dta` (submuestra papel)

### Etapa C. Modelos principales y robustez BBVA

1. `analisis_bbva/06_OLS.do`
2. `analisis_bbva/07_CSDiD.do`
3. Robustez/submuestras:
- `analisis_bbva/07_CSDiD_ORO.do`
- `analisis_bbva/07_CSDiD_VAC.do`
- `analisis_bbva/08_XTReg.do`
- `analisis_bbva/09_Logit.do`

### Etapa D. Pruebas y tabulados auxiliares

Ejecutar según necesidad desde `analisis_bbva/pruebas/` y `analisis_banorte/adicionales/`.

## 4) Qué hace cada do-file (archivo por archivo)

## `panel_creat/`

### `panel_creat/Panel_BBVA_Banorte.do`
- Importa cada CSV mensual de tarjetas.
- Filtra instituciones BBVA y Banorte (`inst==40012|40072`).
- Asigna `periodo` por archivo y guarda `.dta` mensual.
- Hace `append` de todos los meses para crear `panelexp.dta`.

### `panel_creat/Panel_BBVA_Banorte_VS.do`
- Versión más compacta/parametrizada del proceso anterior.
- Valida existencia de archivos y concordancia de listas.
- Convierte `inst` a numérico si llega como string.
- Genera el mismo producto final: `panelexp.dta`.

## `analisis_bbva/` (pipeline central)

### `analisis_bbva/01_data_load.do`
- Carga `panelexp.dta`.
- Conserva solo BBVA (`inst==40012`).
- Mantiene subconjunto de variables de análisis.
- Merge con catálogo de productos y guarda `baseBBVAAll.dta`.

### `analisis_bbva/02_variable_definition_cleaness.do`
- Carga `baseBBVAAll.dta` y realiza limpieza principal.
- Crea identificadores `tarjeta` y `cliente`.
- Corrige persistencia de tratamiento (`edoctanvo`) y calcula `first_trat`.
- Construye outcomes y variables derivadas (`ruso`, `rpagomin_w`, `totalero`, `ctar`, `delinquent`, etc.).
- Etiqueta variables/valores y recodifica clase.
- Construye `nombre_top10` para productos más frecuentes.
- Ejecuta internamente:
1. `02_2_segments_of_cards.do`
2. `02_1_balanced_panel_var.do`
- Guarda versión enriquecida en `baseBBVAAll.dta`.

### `analisis_bbva/02_1_balanced_panel_var.do`
- Crea indicadores de panel balanceado.
- `bpanel`: cobertura completa 1..16 sin duplicados tarjeta-periodo.
- `bpanel_alt`: cobertura completa en ventana corta (1..13) sin duplicados.

### `analisis_bbva/02_2_segments_of_cards.do`
- Construye segmentos “iniciales” fijados en `periodo==6`.
- Ejemplos: `initot`, `inicomp`, `inisal`, `tasaini`, `lcini`, `saldini`, `delini`, `edadini`.

### `analisis_bbva/03_proxy_strata.do`
- Construye estratos proxy a nivel cliente usando foto pretratamiento.
- En `periodo==5`: multitarjeta, gama, límite de crédito, comportamiento de pago.
- En `periodo==6`: indicador de recepción en papel.
- Merge de estratos proxy al panel por `cliente`.

### `analisis_bbva/04_variables_for_modeling.do`
- Define variables de tratamiento para dos esquemas.
- `treatment`: liberación escalonada mayo-junio.
- `treatment2`: versión simplificada tratando mayo como junio (`first_trat_alt`).

### `analisis_bbva/05_Paper_users.do`
- Construye submuestra de usuarios con estado de cuenta en papel.
- Corrige posibles alternancias en `edocta_papel` dentro de ventana analítica.
- Crea indicadores `papel_may2024_any`, `papel_ago2024_any`, `papel_oct2024_any`, `papel_feb2025_any`.
- Filtra a `papel_may2024_any==1` y guarda `baseBBVApaper.dta`.

### `analisis_bbva/06_OLS.do`
- Modelo principal tipo DiD por periodo (R1, R2, R3) para múltiples outcomes.
- Incluye pruebas conjuntas pre y post (`testparm`).
- Reporta tablas con `esttab` por outcome y especificación.

### `analisis_bbva/07_CSDiD.do`
- CSDID principal (`agg(event)`) con muestra BBVA elegible + papel.
- Usa controles pretratamiento y producto fijo en `t=6`.
- Exporta gráficas event-study (ventana mostrada `[-5,4]`) y tabla principal.

### `analisis_bbva/07_CSDiD_ORO.do`
- CSDID para submuestra de productos `UNAM Oro` y `Oro`.
- Misma lógica de controles/evento que el principal.
- Exporta tabla y gráficas específicas de submuestra.

### `analisis_bbva/07_CSDiD_VAC.do`
- CSDID para submuestra `Azul/CREA/Vive`.
- Mantiene diseño de tabla homologado con Banorte.
- Exporta tabla y gráficas específicas de submuestra.

### `analisis_bbva/08_XTReg.do`
- Robustez con panel FE (`xtreg, fe`) a nivel tarjeta.
- Incluye `periodo#treatment2`, estratos y `periodo#estratos`.
- Calcula tests pre/post y tabla de resultados.

### `analisis_bbva/09_Logit.do`
- Robustez con modelos `logit` para outcomes binarios.
- Especificación análoga a R3 y tests Wald pre/post.
- Tabla final con coeficientes relevantes.

## `analisis_bbva/pruebas/` (diagnóstico, balance y tabulados auxiliares)

### `analisis_bbva/pruebas/Balance_check_incondicional.do`
- Balance incondicional en periodo 6 (control vs tratamiento).
- Calcula medias, diferencias, `p-value`, SMD y exporta a Excel.

### `analisis_bbva/pruebas/OLS_con_initot.do`
- Estimaciones OLS segmentadas por `initot` (estado inicial de totalero).
- Incluye pruebas F pre/post y tablas de salida.

### `analisis_bbva/pruebas/Tablas_implementacion_ece.do`
- Tablas de implementación por producto y estado de cuenta en periodos 7..13.
- Construye ranking Top-N de productos para tabulados.

### `analisis_bbva/pruebas/auditoria_estratos.do`
- Auditoría de balance para Banorte.
- Compara control administrativo vs tratamiento conjunto.
- Genera tablas con ajuste por estratos proxy y por estratos reales del emisor.

### `analisis_bbva/pruebas/balance_check_condicionado.do`
- Balance pairwise BBVA en `t=6` con ajuste por segmentos (sin clase).
- Compara cohortes tempranas vs cohorte noviembre.
- Exporta tablas por comparación a Excel.

### `analisis_bbva/pruebas/balance_con_initot.do`
- Balance en `t=6` separado para `initot==0` y `initot==1`.
- Reporta medias, diferencias, test t y SMD.
- Exporta resultados a Excel en dos hojas.

### `analisis_bbva/pruebas/distribucion_tarjetas_papel.do`
- Resume distribución de tarjetas en papel por periodo.
- Calcula conteos de papel antiguo, papel+ECE, total y porcentaje.
- Exporta tabla de implementación.

### `analisis_bbva/pruebas/graficas.do`
- Script exploratorio con tabulados rápidos de cohortes/tratamiento.
- Crea `treatment` simplificado para inspecciones descriptivas.

### `analisis_bbva/pruebas/productos_bbva.do`
- Tabla puntual de productos BBVA seleccionados por periodo y estado.

### `analisis_bbva/pruebas/regresiones_incondicionales.do`
- Ejecuta sólo R1 (incondicional) para varios outcomes en una tabla conjunta.
- Incluye pruebas F pre/post.

### `analisis_bbva/pruebas/segmentos_pretratamiento.do`
- Construcción unificada de segmentos pretratamiento para BBVA.
- Fija producto en `t=6` (`nombre_t6`, `prod_t6`).
- Genera segmentos de clase, cuartiles (límite, uso, ingreso, edad), totalero pre, antigüedad, `compme_t6`, `mujeres_t6`.

### `analisis_bbva/pruebas/sgmentaciones_usuarios_papel.do`
- Mide reducción de muestra por cohorte al aplicar elegibilidad adicional.
- Incluye soporte descriptivo de segmentos por cohorte en `t=6`.
- Exporta tabla de reducción.

### `analisis_bbva/pruebas/tablas de balance.do`
- Balance Banorte en `t=6`: control diferido vs tratamiento anticipado conjunto.
- Incluye ajuste por estratos proxy y exporta tabla principal.

### `analisis_bbva/pruebas/tablas de balance_cohortes_bbva.do`
- Balance pairwise BBVA en `t=6` por cohorte vs noviembre 2024.
- Compara junio, julio, agosto y octubre contra noviembre.
- Exporta una tabla por comparación.

### `analisis_bbva/pruebas/tablas de balancev2.do`
- Set ampliado de balances Banorte en `t=6`.
- Genera 4 tablas: original vs adicional, control vs original, control vs adicional, control vs conjunto.
- Todas con ajuste por estratos proxy y exportación a Excel.

## `analisis_banorte/adicionales/`

### `analisis_banorte/adicionales/08_XTReg.do`
- Robustez FE de panel (`xtreg, fe`) para Banorte.
- Especificación equivalente a R3 con estratos e interacciones.
- Reporta tests pre/post y tabla final.

### `analisis_banorte/adicionales/09_Logit.do`
- Robustez `logit` para outcomes binarios (en Banorte).
- Incluye interacciones periodo-tratamiento y controles de estratos.
- Reporta tests Wald pre/post y tabla final.

### `analisis_banorte/adicionales/analisis_estratos_proxy_vs_reales.do`
- Validación de calidad de estratos proxy.
- Incluye diagnóstico interno, soporte por celdas y balance pre con SMD crudo vs ajustado.

### `analisis_banorte/adicionales/comparacion_r1_r2_r3.do`
- Compara especificaciones R1/R2/R3 usando `joint_strata`.
- Produce tablas por outcome con pruebas pre/post.

## `data/`

### `data/02_data_cleaness - Copy.do`
- Script amplio de limpieza/armado (principalmente orientado a Banorte/mixto).
- Crea outcomes, panel balanceado, segmentos iniciales y dummies de papel.
- Hace merges con catálogo y listas de elegibilidad Banorte.
- Se percibe como versión de trabajo/soporte respecto al pipeline BBVA modular.

## 5) Notas prácticas para correr sin errores

1. Cargar la base correcta antes de scripts que no incluyen `use`.
2. Revisar que las variables clave existan antes de estimaciones:
- `tarjeta`, `periodo`, `first_trat`/`first_trat_grp`
- `bpanel_alt`, `papel_may2024_any`, `eleg_bbva_base`
- segmentos `*_t6`
3. Instalar paquetes en Stata si faltan:
- `ssc install estout, replace`
- `ssc install csdid, replace` (si aplica para tu versión)
- `ssc install event_plot, replace` (si aplica)
4. Si cambias la definición de elegibilidad o ventana temporal, volver a correr desde la etapa de construcción de variables/segmentos para mantener consistencia.
