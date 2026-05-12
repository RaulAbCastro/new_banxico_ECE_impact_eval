Estructura modular sugerida (Banorte/BBVA)

Archivos:
00_config.do            -> Configuración: paths, banco (inst), macros globales
01_load_data.do         -> Carga dataset base (panel ya creado)
02_strata.do            -> Construye estratos (cliente) y los mergea al panel
03_treatment.do         -> Construye variables de tratamiento/cohorte (treatment2, g_csdid, etc.)
04_models_main.do       -> Regresiones principales R1–R3 (por outcome)
05_robustness_csdid.do  -> CSDID + event_plot + pretrend
06_plots_trends.do      -> Gráficas de tendencias (incondicional y segmentación)
99_run_all.do           -> Ejecuta el flujo completo

Notas:
- Todo está escrito para NO borrar observaciones (usa if y preserve/restore).
- Ajusta los globals de paths en 00_config.do y el nombre del dataset en 01_load_data.do.
- Cambia $INST para correr Banorte (40072) o BBVA (ajusta al código que uses).
