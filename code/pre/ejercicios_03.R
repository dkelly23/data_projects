# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         ejercicios_03.R
# Objetivo:       Bloque de práctica de la Sesión 3. Traducir preguntas sobre
#                 la EIGH a los seis verbos de dplyr.
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
pacman::p_load(tidyverse)

# La importación es la de la Sesión 2 y ya viene resuelta: el bloque de hoy es
# sobre los verbos, no sobre la lectura. Las rutas son relativas a la raíz del
# proyecto.
hogares = read_csv("files/eigh_hogares.csv", show_col_types = FALSE)

personas = read_delim("files/eigh_personas.txt", delim = "|",
    na = c("", "n.d.", "999"),
    col_types = cols(folioviv = col_character(), ing_trab = col_double()))

gastos = read_csv2("files/eigh_gastos.csv", show_col_types = FALSE)


# EJERCICIOS __________________________________________________________________

# EL ENCARGO
#
# Un reporte de ingreso y gasto de la EIGH. Al terminar el bloque tienen que
# existir tres tablas de resultados:
#
#   resumen_entidad    ingreso y gasto per cápita medios por entidad
#   perfil_personas    participación e ingreso por sexo y grupo de edad
#   resumen_rubro      peso de cada rubro en el gasto declarado
#
# Cada parte construye una pieza. No se avanza a la siguiente sin haber mirado
# el resultado de la anterior: la cadena se depura por partes, no al final.


## 1. Reconocimiento ---------------------------------------------------------=

# Antes de calcular nada hay que saber qué hay. Tres preguntas por tabla:
# cuántas filas, qué columnas y qué valores toma cada variable de clasificación.

# a) Mira la estructura de las tres tablas con `glimpse()`. ¿Cuál es la unidad de
#    observación de cada una?

# (escribe el código aquí)



# b) ¿Cuántos hogares hay por entidad? Usa `count()`.

# (escribe el código aquí)



# c) ¿Qué valores toma `tam_loc`, y cuántos hogares hay en cada uno? Contrasta lo
#    que salga contra `docs/eigh_descriptor.csv`: hay un código que no es un
#    tamaño de localidad.

# (escribe el código aquí)



# d) Verifica que `entidad` y `nom_ent` se correspondan una a una: la clave
#    numérica y el nombre tienen que dar el mismo número de combinaciones.

# (escribe el código aquí)



# e) ¿Cuántos hogares distintos aparecen en la tabla de gastos, y cuántos rubros
#    distintos hay?

# (escribe el código aquí)




## 2. El universo de análisis ------------------------------------------------=

# Todo reporte empieza declarando sobre qué se calcula. Aquí el universo son los
# hogares con ingreso declarado y con tamaño de localidad conocido.

# a) ¿Cuántos hogares tienen `ing_cor` faltante? ¿Cuántos tienen `tam_loc == 9`?

# (escribe el código aquí)



# b) Construye `hogares_val` con los hogares que cumplen las dos condiciones:
#    ingreso declarado y tamaño de localidad distinto de 9. ¿Cuántos quedan?

# (escribe el código aquí)



# c) ¿Por qué el resultado de (b) no es 800 menos la suma de los dos conteos de
#    (a)?




# d) Sobre `hogares_val`, quédate con los hogares de localidades urbanas
#    (`tam_loc` 1 o 2) de la Ciudad de México y Nuevo León. Usa `%in%` en las dos
#    condiciones.

# (escribe el código aquí)



# e) Sobre `hogares_val`, los hogares de entre tres y cinco integrantes que
#    además gastaron más de lo que ingresaron. Dos condiciones, una con
#    `between()` y otra comparando dos columnas entre sí.

# (escribe el código aquí)




## 3. Indicadores por hogar --------------------------------------------------=

# El reporte necesita variables que no vienen en el archivo. Todas salen de
# `mutate()` sobre `hogares_val`.

# a) Agrega `ing_pc` y `gasto_pc`: ingreso y gasto trimestrales divididos entre
#    el número de integrantes.

# (escribe el código aquí)



# b) Agrega `prop_gasto`: la proporción del ingreso que se va en gasto. Tiene que
#    poder calcularse a partir de las dos columnas de (a), en la misma llamada a
#    `mutate()`.

# (escribe el código aquí)



# c) Agrega `deficitario`: TRUE cuando el gasto supera al ingreso. Cuidado con el
#    reflejo de escribir `if_else()`: la comparación ya devuelve un lógico.

# (escribe el código aquí)



# d) Agrega `urbano`: "urbano" cuando `tam_loc` es 1 o 2, "rural" en otro caso.

# (escribe el código aquí)



# e) Agrega `estrato` con cuatro niveles, según el ingreso per cápita: menos de
#    10,000 "bajo"; menos de 20,000 "medio bajo"; menos de 40,000 "medio alto"; y
#    de ahí en adelante "alto". Usa `case_when()` y cuida el orden de las ramas.

# (escribe el código aquí)



# f) Junta todo en un solo objeto llamado `hogares_ind`, con las seis columnas
#    derivadas en una sola llamada a `mutate()`. Verifica el resultado con
#    `count()` sobre `estrato` y sobre `deficitario`.

# (escribe el código aquí)



# g) Reduce `hogares_ind` a lo que el reporte va a usar: el folio, el nombre de
#    la entidad, todo lo que empiece con "ing", todo lo que termine en "_pc", y
#    las tres columnas categóricas. Usa `select()` con helpers donde se pueda.

# (escribe el código aquí)




## 4. Comparación por grupo --------------------------------------------------=

# La primera tabla del reporte. Todo sale de `group_by()` y `summarize()` sobre
# `hogares_ind`.

# a) ¿Cuántos hogares y cuál es el ingreso per cápita medio, por entidad?

# (escribe el código aquí)



# b) Agrega a ese resumen la mediana del ingreso per cápita y el gasto per cápita
#    medio. ¿La media y la mediana coinciden? ¿Qué dice eso de la distribución?

# (escribe el código aquí)



# c) Construye `resumen_entidad`: el resumen de (b), más la proporción de hogares
#    deficitarios de cada entidad, ordenado de mayor a menor ingreso per cápita.
#    La proporción sale de promediar una columna lógica.

# (escribe el código aquí)



# d) El mismo ingreso per cápita medio, ahora por entidad Y por condición urbana.
#    Lee el mensaje que imprime `summarize()`: ¿por cuál variable quedó agrupado
#    el resultado?

# (escribe el código aquí)



# e) Repite (d) dejando el resultado desagrupado, de las dos formas: con
#    `.groups = "drop"` y con `ungroup()`. Comprueba con `group_vars()`.

# (escribe el código aquí)



# f) ¿Cuál es el hogar de mayor ingreso per cápita de cada entidad? Devuelve una
#    fila por entidad, con el folio y el ingreso per cápita.

# (escribe el código aquí)



# g) Agrega a `hogares_ind` una columna `ing_pc_rel`: el ingreso per cápita del
#    hogar dividido entre el ingreso per cápita medio DE SU ENTIDAD. Aquí
#    `group_by()` va con `mutate()`, no con `summarize()`. Acuérdate de
#    desagrupar antes de guardar.

# (escribe el código aquí)



# h) ¿Cuántos hogares de cada entidad están por encima del ingreso per cápita
#    medio de su propia entidad? Se responde filtrando sobre la columna de (g).

# (escribe el código aquí)




## 5. El perfil de personas --------------------------------------------------=

# La segunda tabla del reporte. Cambia la unidad de observación: aquí cada fila
# es una persona, así que "el ingreso medio" ya no significa lo mismo.

# a) ¿Cuántas personas tienen edad faltante? Recuerda que la importación ya
#    convirtió el código 999 en NA.

# (escribe el código aquí)



# b) Construye `personas_val`: personas con edad declarada y de 15 años o más.

# (escribe el código aquí)



# c) Agrega dos columnas: `sexo_lab`, con "hombre" y "mujer" según el código 1/2
#    del descriptor, y `grupo_edad`, con los cortes 15-29, 30-44, 45-64 y 65 o
#    más. La primera con `if_else()`, la segunda con `case_when()`.

# (escribe el código aquí)



# d) Agrega `ocupado`: TRUE cuando `ing_trab` es mayor que cero. Cuidado con los
#    faltantes: hay personas que no declararon ingreso por trabajo, y no es lo
#    mismo que haber declarado cero.

# (escribe el código aquí)



# e) Construye `perfil_personas`: por sexo y grupo de edad, el número de
#    personas, la tasa de ocupación y el ingreso medio por trabajo de quienes lo
#    declararon. Deja el resultado desagrupado.

# (escribe el código aquí)



# f) ¿Qué combinación de sexo y grupo de edad tiene el ingreso medio por trabajo
#    más alto? Y la más baja?

# (escribe el código aquí)




## 6. El lado del gasto ------------------------------------------------------=

# La tercera tabla. Solo con `gastos`: cruzar rubro con entidad exige un join, y
# eso es la Sesión 4.

# a) ¿Cuántos renglones de gasto hay por rubro, de mayor a menor?

# (escribe el código aquí)



# b) Construye `resumen_rubro`: por rubro, el número de renglones, el gasto
#    trimestral medio y el gasto total, ordenado por gasto total descendente.

# (escribe el código aquí)



# c) Agrega a `resumen_rubro` la participación de cada rubro en el gasto total
#    declarado. Es un `mutate()` después del `summarize()`, y la suma de la
#    columna nueva tiene que dar 1.

# (escribe el código aquí)



# d) ¿Cuánto gastó cada hogar en total, y cuáles son los diez que más gastaron?
#    El resultado tiene una fila por hogar.

# (escribe el código aquí)



# e) Para cada hogar, ¿qué rubro se llevó el gasto más alto? Una fila por hogar,
#    con el folio, la clave del rubro y el monto.

# (escribe el código aquí)



# f) ¿Cuántas veces resultó ganador cada rubro en (e)? Encadena `count()` al
#    resultado anterior.

# (escribe el código aquí)


