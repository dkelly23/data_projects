# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         ejercicios_04.R
# Objetivo:       Bloque de práctica de la Sesión 4. Construir el ETL de la EIGH.
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
pacman::p_load(tidyverse, readxl, glue, tidylog)

# Las cuatro fuentes, leídas como en las sesiones anteriores.
hogares = read_csv("files/eigh_hogares.csv", show_col_types = FALSE)

personas = read_delim("files/eigh_personas.txt", delim = "|",
    na = c("", "n.d.", "999"),
    col_types = cols(folioviv = col_character(), ing_trab = col_double()))

gastos = read_csv2("files/eigh_gastos.csv", show_col_types = FALSE)

claves_gasto = read_excel("files/eigh_catalogos.xlsx", sheet = "claves_gasto",
    range = "A3:C11")


# EJERCICIOS __________________________________________________________________

# EL ENCARGO
#
# La Sesión 3 dejó tres tablas de resultados, cada una calculada sobre UNA tabla
# de la EIGH. El encargo de hoy es construir la tabla que faltaba: una sola
# tabla de análisis, con una fila por hogar, que reúna lo que hoy está repartido
# en cuatro archivos.
#
# Al cerrar el bloque tiene que existir output/eigh_etl.rds con:
#
#   - los datos del hogar (entidad, integrantes, ingreso)
#   - el gasto por tipo, en columnas (necesario, discrecional, sin clasificar)
#   - el tamaño y la composición del hogar, traídos de personas
#   - las categóricas en etiqueta legible, no en código
#
# Y un requisito que vale tanto como el resultado: cada join verificado, con el
# conteo de filas a la vista antes y después.


## 1. Reconocer las llaves ----------------------------------------------------=

# Antes de unir nada hay que saber qué identifica una fila en cada tabla. Sin
# esto, el número de filas del resultado es una sorpresa.

# a) ¿Cuántas filas tiene cada tabla, y cuántos folios distintos hay en cada una?

# (escribe el código aquí)



# b) ¿folioviv identifica una sola fila en `hogares`? ¿Y en `personas`? Contesta
#    con código, no de memoria: cuenta las filas por folio y quédate con las que
#    aparecen más de una vez.

# (escribe el código aquí)



# c) Antes de cualquier join, revisa en las dos direcciones qué se quedaría sin
#    pareja. Usa `anti_join()` entre `hogares` y `gastos`. La respuesta que se
#    busca es cero filas en ambas.

# (escribe el código aquí)



# d) Escribe con `glue()` una línea que reporte el resultado de la verificación,
#    con los conteos interpolados.

# (escribe el código aquí)




## 2. El catálogo sucio -------------------------------------------------------=

# La clasificación del gasto en necesario o discrecional vive en la hoja
# `rubros_texto` del archivo de catálogos, y no está en ninguna otra tabla. Sin
# ella no se puede cerrar el encargo, y como llega no se puede unir.

# a) Lee la hoja `rubros_texto` saltando las dos filas de encabezado, e
#    imprímela. Identifica los tres problemas que tiene el campo de texto.

# (escribe el código aquí)



# b) Extrae la clave del rubro a una columna nueva. El patrón es constante
#    aunque el separador no lo sea: una letra mayúscula seguida de tres dígitos.

# (escribe el código aquí)



# c) Construye la etiqueta limpia: quita la clave y el separador del inicio,
#    colapsa los espacios sobrantes y deja una capitalización pareja.

# (escribe el código aquí)



# d) Normaliza `tipo` a minúsculas. Una de las ocho filas viene vacía: decide
#    qué hacer con ella y deja la decisión escrita en el código, no implícita.

# (escribe el código aquí)



# e) Verifica que las ocho claves del catálogo limpio coinciden con las ocho de
#    `claves_gasto`. Un `anti_join()` en las dos direcciones.

# (escribe el código aquí)




## 3. El join central ---------------------------------------------------------=

# Con el catálogo limpio ya hay llave. Toca unir gastos con su clasificación y
# con los datos del hogar.

# a) Une `gastos` con `rubros` por la clave. Declara la cardinalidad que esperas
#    con `relationship`, y cuenta las filas antes y después.

# (escribe el código aquí)



# b) Ahora une el resultado con `hogares`. Otra vez: ¿qué cardinalidad esperas,
#    y cuántas filas debe haber al final?

# (escribe el código aquí)



# c) ¿Qué pasa si se hace al revés, `hogares |> left_join(gastos)`? Córrelo y
#    explica en un comentario por qué el número de filas es otro, y por qué
#    sumar `ing_cor` sobre ese resultado da un número equivocado.

# (escribe el código aquí)



# d) Sobre `gastos_full`, ¿cuánto se gastó en total por tipo de gasto, y qué
#    participación tiene cada uno?

# (escribe el código aquí)




## 4. Reshape a formato ancho -------------------------------------------------=

# La tabla de análisis necesita una fila por hogar. El gasto por tipo tiene que
# pasar de filas a columnas.

# a) Calcula el gasto total de cada hogar en cada tipo. El resultado tiene una
#    fila por combinación de folio y tipo.

# (escribe el código aquí)



# b) Pásalo a formato ancho: una fila por hogar, una columna por tipo. Decide
#    qué va en las celdas de los hogares que no gastaron en un tipo, y justifica
#    la decisión en un comentario.

# (escribe el código aquí)



# c) Agrega una columna con el gasto total del hogar y verifica que coincide con
#    el total calculado directamente sobre `gastos`.

# (escribe el código aquí)



# d) Como práctica del camino inverso, regresa `gasto_ancho` a formato largo.

# (escribe el código aquí)




## 5. Recodificación y composición del hogar ----------------------------------=

# Falta traer de `personas` lo que describe al hogar, y traducir los códigos a
# etiquetas legibles.

# a) Construye, a partir de `personas`, una tabla con una fila por hogar que
#    tenga: número de integrantes, número de menores de 15 años, y el sexo del
#    jefe del hogar (parentesco == 1) en etiqueta.

# (escribe el código aquí)



# b) Sobre `hogares`, traduce `tam_loc` a etiqueta con `case_when()`. El
#    descriptor dice que 9 es "no especificado", así que esa rama va explícita.

# (escribe el código aquí)



# c) Construye un estrato de ingreso per cápita con `case_when()`, en tres
#    niveles más una categoría para los hogares sin ingreso declarado.

# (escribe el código aquí)




## 6. Cierre y guardado -------------------------------------------------------=

# a) Arma `eigh_etl`: una fila por hogar, con los datos del hogar, el gasto por
#    tipo, la composición traída de personas y las categóricas en etiqueta.
#    Declara la cardinalidad en cada join.

# (escribe el código aquí)



# b) Verifica el resultado antes de guardarlo: número de filas, folios únicos, y
#    cuántos NA quedaron en cada columna. Ninguna de las tres respuestas debería
#    sorprender.

# (escribe el código aquí)



# c) Reporta con `glue()` una línea de resumen del ETL.

# (escribe el código aquí)



# d) Guarda la tabla en `output/` como .rds. Es el insumo de la Sesión 5.

# (escribe el código aquí)


