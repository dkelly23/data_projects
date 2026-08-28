# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         ejercicios_02.R
# Objetivo:       Bloque de práctica de la Sesión 2. Importar la EIGH, verificarla
#                 contra el descriptor y explorarla.
#
# Autor:          Daniel Kelly
# Correo(s):      djsanchez@colmex.mx
#
# Fecha:          20/08/2026
#
# Última
# actualización:  20/08/2026
#
# _____________________________________________________________________________


# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola

# Paquetes de la sesión
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(readr, readxl, tibble)

# Este script supone el proyecto abierto (curso-ppd.Rproj): las rutas son
# relativas a la raíz, y los archivos de la EIGH están en files/.
list.files("files")


# EJERCICIOS __________________________________________________________________

## 1. Mirar antes de leer ----------------------------------------------------=

# El bloque de práctica trabaja sobre dos archivos que la exposición apenas tocó:
# la tabla de personas y la de gastos.

# a) Antes de importar nada, mira las tres primeras líneas de la tabla de
#    personas. ¿Cuál es el delimitador? ¿La primera línea trae los nombres de las
#    columnas o ya es un dato?

# (escribe el código aquí)



# b) ¿Cuántas líneas tiene el archivo completo? Cuidado con el encabezado: el
#    número de líneas no es el número de registros.

# (escribe el código aquí)



# c) Haz lo mismo con files/eigh_gastos.csv. Trae dos convenciones distintas a
#    las del archivo anterior: ¿cuáles?

# (escribe el código aquí)





## 2. Importación ------------------------------------------------------------=

# a) Importa la tabla de personas con la función que corresponde al delimitador
#    que identificaste. Guárdala en un objeto llamado `personas`.

# (escribe el código aquí)



# b) Importa la tabla de gastos en un objeto llamado `gastos`. Recuerda que el
#    separador decimal también es distinto.

# (escribe el código aquí)



# c) ¿Cuántas filas y columnas tiene cada una?

# (escribe el código aquí)



# d) Lee el bloque de especificación que imprimió cada lectura. ¿Qué columnas
#    quedaron como texto (chr) y cuáles como número (dbl)?


## 3. Contra el descriptor ---------------------------------------------------=

# El descriptor técnico está en docs/ y declara, para cada variable, qué tipo
# tiene y qué códigos usa para la no respuesta. Es contra ese documento que se
# verifica una importación, no contra la intuición.

# a) Impórtalo en un objeto llamado `descriptor`.

# (escribe el código aquí)



# b) Quédate solo con las filas que describen la tabla de personas. Usa
#    indexación lógica sobre la columna `tabla`.

# (escribe el código aquí)



# c) Compara esos tipos declarados contra los que infirió R. ¿Qué columna llegó
#    con un tipo distinto al que dice el descriptor?

# (escribe el código aquí)



# d) Explica en un comentario por qué ocurrió eso. La respuesta está en la
#    columna `codigos` del descriptor.

# (escribe el código aquí)




## 4. Códigos de no respuesta ------------------------------------------------=


# a) Según el descriptor, ¿qué código usa `edad` para la no respuesta?

# (escribe el código aquí)



# b) Compruébalo: ¿cuántos registros traen ese código? Cuidado, `table()` sobre
#    una variable con muchos valores distintos imprime muchísimo. Conviene
#    contar directamente con una condición lógica.

# (escribe el código aquí)



# c) ¿Qué pasa si se calcula la edad promedio sin corregir ese código? Calcúlala
#    y compárala con la mediana.

# (escribe el código aquí)



# d) Vuelve a importar la tabla de personas, esta vez declarando los códigos de
#    no respuesta y forzando `ing_trab` a numérica. Guárdala en `personas`.

# (escribe el código aquí)



# e) Cuenta los faltantes de cada columna. ¿Los números coinciden con lo que
#    esperabas de los incisos anteriores?

# (escribe el código aquí)



# f) Vuelve a calcular la edad promedio. ¿Cuánto cambió?

# (escribe el código aquí)





## 5. Indexación -------------------------------------------------------------=

# a) Extrae la columna de edad de dos maneras: como vector y como tabla de una
#    columna. Verifica la clase de cada resultado.

# (escribe el código aquí)



# b) ¿Cuántas personas tienen 65 años o más? Una sola línea.

# (escribe el código aquí)



# c) Construye una tabla que contenga únicamente a los jefes de hogar. El
#    descriptor dice qué código les corresponde en `parentesco`.

# (escribe el código aquí)



# d) ¿Cuál es el folio de la vivienda de la persona de mayor edad? Pista: no
#    buscas el valor, buscas su posición.

# (escribe el código aquí)




## 6. Exploración descriptiva ------------------------------------------------=

# a) Descriptivas de la edad y del ingreso por trabajo. Recuerda que ambas tienen
#    faltantes.

# (escribe el código aquí)



# b) Frecuencias de `sexo` y de `nivel_esc`, sin esconder los faltantes.

# (escribe el código aquí)



# c) ¿Qué proporción de las personas no percibe ingreso por trabajo? Ojo: no
#    percibir ingreso es un 0, no un faltante.

# (escribe el código aquí)



# d) Cruza sexo contra nivel de escolaridad y calcula los porcentajes por fila.
#    ¿Qué pregunta responde ese margen, y cuál respondería el otro?

# (escribe el código aquí)



# e) ¿Se relacionan la edad y el ingreso por trabajo? Cuidado con los faltantes.

# (escribe el código aquí)




## 7. Exploración gráfica ----------------------------------------------------=

# Produce al menos dos gráficas, eligiendo el tipo según la pregunta y no según
# lo que se vea mejor. Ponle título y nombres a los ejes.

# a) ¿Cómo se distribuye la edad?

# (escribe el código aquí)



# b) ¿Difiere el ingreso por trabajo entre hombres y mujeres?

# (escribe el código aquí)



# c) Escribe en un comentario el hallazgo que te parezca más claro de las dos
#    gráficas. Una línea basta, pero tiene que decir algo.


## 8. Integrador (opcional) --------------------------------------------------=

# Con la tabla de personas ya corregida, responde en un solo bloque de código:
#
#   - ¿Cuál es la edad promedio de quienes perciben ingreso por trabajo?
#   - ¿Y la de quienes no?
#   - ¿La escolaridad se asocia con percibir ingreso?
#
# Pista: no necesitas nada que no hayas usado ya. Una condición lógica sirve para
# filtrar filas, para contar y para cruzar.

# (escribe el código aquí)



