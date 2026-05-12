Previo a correr el archivo "Panel_BBVA_Banorte.do" se requiere contar con las bases requeridas para la construcción del panel. 

El archivo "Panel_BBVA_Banorte.do" realiza las siguientes tareas para cada base:

1. Carga una de las bases de tarjetas, que por lo regular se encuentran en formato .csv
2. Se asegura de mantener solo las instituciones BBVA y Banorte
3. Agrega una variable llamada "periodo" que vale 1 para la base más antigua en orden cronológico (jun-2023), 2 para la segunda base más antigua (ago-2023), y así sucesivamente.
   Recordando que a partir de abril 2024, las bases son mensuales.
4. Guarda cada base en formato .dta
5. Crea un panel con todas las bases consideradas y las guarda en formato .dta.


El panel final que se guarda es la materia prima para el análisis de BBVA y Banorte.


Nota: El archivo "Panel_BBVA_Banorte_VS.do" es una versión más simple del archivo anterior, sin embargo, aun no he probado su funcionamiento.