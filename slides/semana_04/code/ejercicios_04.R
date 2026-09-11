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

#| nota
# BLOQUE DE PRÁCTICA — 1:15 hr. Como en la S3, es un solo encargo por partes.
# Reparto sugerido:
#
#   Parte 1  Reconocer las llaves     10 min
#   Parte 2  El catálogo sucio        15 min
#   Parte 3  El join central          18 min   <- el núcleo del bloque
#   Parte 4  Reshape a formato ancho  12 min
#   Parte 5  Recodificación            8 min
#   Parte 6  Cierre y guardado        12 min
#
# El bloque produce UN archivo: output/eigh_etl.rds, la tabla de análisis a
# nivel hogar. Ese archivo es el insumo de la Sesión 5, donde se refactoriza
# todo esto en funciones, así que conviene que todos lo terminen. Si alguien se
# atrasa, el objeto se puede reconstruir corriendo las soluciones.
#
# Las partes 1 y 2 en el proyector. La 3 es la que hay que cuidar: el reflejo a
# instalar es contar filas ANTES y DESPUÉS de cada join, y nadie lo hace si no
# se lo piden explícitamente. De la 4 en adelante, cada quien en su máquina.
#
# La parte 2 depende de regex y es la que más atora. Tener a la mano la
# cheatsheet de Posit y resolver el primer str_extract() en conjunto.
#| fin

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

#| solucion
tibble(
    tabla  = c("hogares", "personas", "gastos"),
    filas  = c(nrow(hogares), nrow(personas), nrow(gastos)),
    folios = c(n_distinct(hogares$folioviv), n_distinct(personas$folioviv),
        n_distinct(gastos$folioviv))
)
#| fin

# b) ¿folioviv identifica una sola fila en `hogares`? ¿Y en `personas`? Contesta
#    con código, no de memoria: cuenta las filas por folio y quédate con las que
#    aparecen más de una vez.

#| solucion
hogares  |> count(folioviv) |> filter(n > 1)   # 0 filas: llave única
personas |> count(folioviv) |> filter(n > 1)   # muchas: no es única

# En personas la llave es compuesta: folio más número de renglón.
personas |> count(folioviv, numren) |> filter(n > 1)   # 0 filas
#| fin

# c) Antes de cualquier join, revisa en las dos direcciones qué se quedaría sin
#    pareja. Usa `anti_join()` entre `hogares` y `gastos`. La respuesta que se
#    busca es cero filas en ambas.

#| solucion
hogares |> anti_join(gastos, by = "folioviv")   # 0 filas
gastos |> anti_join(hogares, by = "folioviv")   # 0 filas

# Lo mismo contra personas.
hogares |> anti_join(personas, by = "folioviv")
personas |> anti_join(hogares, by = "folioviv")
#| fin

# d) Escribe con `glue()` una línea que reporte el resultado de la verificación,
#    con los conteos interpolados.

#| solucion
sin_gasto = nrow(anti_join(hogares, gastos, by = "folioviv"))
sin_hogar = nrow(anti_join(gastos, hogares, by = "folioviv"))

glue("Verificación de llaves: {sin_gasto} hogares sin gasto, \\
     {sin_hogar} gastos sin hogar, sobre {nrow(hogares)} hogares.")
#| fin


## 2. El catálogo sucio -------------------------------------------------------=

# La clasificación del gasto en necesario o discrecional vive en la hoja
# `rubros_texto` del archivo de catálogos, y no está en ninguna otra tabla. Sin
# ella no se puede cerrar el encargo, y como llega no se puede unir.

# a) Lee la hoja `rubros_texto` saltando las dos filas de encabezado, e
#    imprímela. Identifica los tres problemas que tiene el campo de texto.

#| solucion
rubros_texto = read_excel("files/eigh_catalogos.xlsx", sheet = "rubros_texto",
    skip = 2)

rubros_texto

# Los tres problemas:
#   1. La clave viene pegada a la etiqueta: no hay columna para unir.
#   2. El separador cambia de fila en fila: "-", "–" y ":".
#   3. La capitalización y los espacios no son consistentes.
#| fin

# b) Extrae la clave del rubro a una columna nueva. El patrón es constante
#    aunque el separador no lo sea: una letra mayúscula seguida de tres dígitos.

#| solucion
rubros_texto |>
    mutate(clave = str_extract(rubro_completo, "[A-Z]\\d{3}"))
#| fin

# c) Construye la etiqueta limpia: quita la clave y el separador del inicio,
#    colapsa los espacios sobrantes y deja una capitalización pareja.

#| solucion
rubros_texto |>
    mutate(
        clave = str_extract(rubro_completo, "[A-Z]\\d{3}"),
        etiqueta = rubro_completo |>
            str_remove("^\\s*[A-Z]\\d{3}\\s*[-–:]\\s*") |>
            str_squish() |>
            str_to_sentence()
    )
#| fin

# d) Normaliza `tipo` a minúsculas. Una de las ocho filas viene vacía: decide
#    qué hacer con ella y deja la decisión escrita en el código, no implícita.

#| solucion
rubros = rubros_texto |>
    mutate(
        clave = str_extract(rubro_completo, "[A-Z]\\d{3}"),
        etiqueta = rubro_completo |>
            str_remove("^\\s*[A-Z]\\d{3}\\s*[-–:]\\s*") |>
            str_squish() |>
            str_to_sentence(),
        tipo = str_to_lower(tipo),
        .keep = "none"
    ) |>
    # La celda vacía se vuelve una categoría explícita en vez de un NA que
    # desaparezca de los conteos: el rubro existe y su gasto hay que reportarlo.
    mutate(tipo = replace_na(tipo, "sin clasificar"))

rubros
#| fin

# e) Verifica que las ocho claves del catálogo limpio coinciden con las ocho de
#    `claves_gasto`. Un `anti_join()` en las dos direcciones.

#| solucion
rubros |> anti_join(claves_gasto, by = "clave")   # 0 filas
claves_gasto |> anti_join(rubros, by = "clave")   # 0 filas
#| fin


## 3. El join central ---------------------------------------------------------=

# Con el catálogo limpio ya hay llave. Toca unir gastos con su clasificación y
# con los datos del hogar.

# a) Une `gastos` con `rubros` por la clave. Declara la cardinalidad que esperas
#    con `relationship`, y cuenta las filas antes y después.

#| solucion
nrow(gastos)   # 4418

gastos_clas = gastos |>
    left_join(rubros, join_by(clave), relationship = "many-to-one")

nrow(gastos_clas)   # 4418: un join muchos-a-uno no cambia el número de filas
#| fin

# b) Ahora une el resultado con `hogares`. Otra vez: ¿qué cardinalidad esperas,
#    y cuántas filas debe haber al final?

#| solucion
gastos_full = gastos_clas |>
    left_join(hogares, join_by(folioviv), relationship = "many-to-one")

nrow(gastos_full)   # 4418: cada gasto encuentra un hogar y solo uno
#| fin

# c) ¿Qué pasa si se hace al revés, `hogares |> left_join(gastos)`? Córrelo y
#    explica en un comentario por qué el número de filas es otro, y por qué
#    sumar `ing_cor` sobre ese resultado da un número equivocado.

#| solucion
hogares |> left_join(gastos, join_by(folioviv)) |> nrow()   # 4418

# El número de filas coincide, pero la tabla es la misma que en (b): está al
# nivel del gasto, no del hogar. La diferencia se ve al sumar el ingreso, que es
# un dato del HOGAR y queda repetido una vez por cada rubro declarado.
hogares |> summarize(ingreso = sum(ing_cor, na.rm = TRUE))
hogares |> left_join(gastos, join_by(folioviv)) |>
    summarize(ingreso = sum(ing_cor, na.rm = TRUE))

# 55,350,869 contra 307,457,446. La regla: un dato solo se suma al nivel en el
# que fue medido.
#| fin

# d) Sobre `gastos_full`, ¿cuánto se gastó en total por tipo de gasto, y qué
#    participación tiene cada uno?

#| solucion
gastos_full |>
    summarize(total = sum(gasto_tri), .by = tipo) |>
    mutate(participacion = total / sum(total)) |>
    arrange(desc(total))
#| fin


## 4. Reshape a formato ancho -------------------------------------------------=

# La tabla de análisis necesita una fila por hogar. El gasto por tipo tiene que
# pasar de filas a columnas.

# a) Calcula el gasto total de cada hogar en cada tipo. El resultado tiene una
#    fila por combinación de folio y tipo.

#| solucion
gasto_tipo = gastos_full |>
    summarize(gasto = sum(gasto_tri), .by = c(folioviv, tipo))

gasto_tipo
#| fin

# b) Pásalo a formato ancho: una fila por hogar, una columna por tipo. Decide
#    qué va en las celdas de los hogares que no gastaron en un tipo, y justifica
#    la decisión en un comentario.

#| solucion
# El cero es correcto aquí: la ausencia de la fila significa que el hogar no
# declaró gasto en ese tipo, no que el dato falte.
gasto_ancho = gasto_tipo |>
    pivot_wider(
        id_cols     = folioviv,
        names_from  = tipo,
        values_from = gasto,
        values_fill = 0,
        names_sort  = TRUE
    )

gasto_ancho
nrow(gasto_ancho)   # 800: una fila por hogar
#| fin

# c) Agrega una columna con el gasto total del hogar y verifica que coincide con
#    el total calculado directamente sobre `gastos`.

#| solucion
gasto_ancho = gasto_ancho |>
    mutate(gasto_total = discrecional + necesario + `sin clasificar`)

# La verificación: los dos totales tienen que ser iguales.
sum(gasto_ancho$gasto_total)
sum(gastos$gasto_tri)
all.equal(sum(gasto_ancho$gasto_total), sum(gastos$gasto_tri))
#| fin

# d) Como práctica del camino inverso, regresa `gasto_ancho` a formato largo.

#| solucion
gasto_ancho |>
    select(-gasto_total) |>
    pivot_longer(cols = -folioviv, names_to = "tipo", values_to = "gasto")
#| fin


## 5. Recodificación y composición del hogar ----------------------------------=

# Falta traer de `personas` lo que describe al hogar, y traducir los códigos a
# etiquetas legibles.

# a) Construye, a partir de `personas`, una tabla con una fila por hogar que
#    tenga: número de integrantes, número de menores de 15 años, y el sexo del
#    jefe del hogar (parentesco == 1) en etiqueta.

#| solucion
# El sexo del jefe no es un resumen del hogar: es el dato de UNA de sus
# personas. Se resuelve aparte y se une, que es el tema de la sesión.
jefes = personas |>
    filter(parentesco == 1) |>
    mutate(sexo_jefe = if_else(sexo == 1, "Hombre", "Mujer")) |>
    select(folioviv, sexo_jefe)

nrow(jefes)   # 800: un jefe por hogar, ni más ni menos

comp_hogar = personas |>
    summarize(
        integrantes = n(),
        menores     = sum(edad < 15, na.rm = TRUE),
        .by = folioviv
    ) |>
    left_join(jefes, join_by(folioviv), relationship = "one-to-one")

comp_hogar
#| fin

# b) Sobre `hogares`, traduce `tam_loc` a etiqueta con `case_when()`. El
#    descriptor dice que 9 es "no especificado", así que esa rama va explícita.

#| solucion
hogares |>
    mutate(
        tam_loc_etq = case_when(
            tam_loc == 1 ~ "100,000 y más",
            tam_loc == 2 ~ "15,000 a 99,999",
            tam_loc == 3 ~ "2,500 a 14,999",
            tam_loc == 4 ~ "Menos de 2,500",
            tam_loc == 9 ~ "No especificado"
        )
    ) |>
    count(tam_loc, tam_loc_etq)
#| fin

# c) Construye un estrato de ingreso per cápita con `case_when()`, en tres
#    niveles más una categoría para los hogares sin ingreso declarado.

#| solucion
hogares |>
    mutate(
        ing_pc = ing_cor / tot_integ,
        estrato = case_when(
            is.na(ing_pc)  ~ "sin dato",
            ing_pc < 10000 ~ "bajo",
            ing_pc < 25000 ~ "medio",
            .default       = "alto"
        )
    ) |>
    count(estrato)
#| fin


## 6. Cierre y guardado -------------------------------------------------------=

# a) Arma `eigh_etl`: una fila por hogar, con los datos del hogar, el gasto por
#    tipo, la composición traída de personas y las categóricas en etiqueta.
#    Declara la cardinalidad en cada join.

#| solucion
eigh_etl = hogares |>
    left_join(gasto_ancho, join_by(folioviv), relationship = "one-to-one") |>
    left_join(comp_hogar,  join_by(folioviv), relationship = "one-to-one") |>
    mutate(
        ing_pc   = ing_cor / tot_integ,
        gasto_pc = gasto_total / tot_integ,
        tam_loc_etq = case_when(
            tam_loc == 1 ~ "100,000 y más",
            tam_loc == 2 ~ "15,000 a 99,999",
            tam_loc == 3 ~ "2,500 a 14,999",
            tam_loc == 4 ~ "Menos de 2,500",
            tam_loc == 9 ~ "No especificado"
        ),
        estrato = case_when(
            is.na(ing_pc)  ~ "sin dato",
            ing_pc < 10000 ~ "bajo",
            ing_pc < 25000 ~ "medio",
            .default       = "alto"
        ),
        con_menores = menores > 0
    )

eigh_etl
#| fin

# b) Verifica el resultado antes de guardarlo: número de filas, folios únicos, y
#    cuántos NA quedaron en cada columna. Ninguna de las tres respuestas debería
#    sorprender.

#| solucion
nrow(eigh_etl)                    # 800
n_distinct(eigh_etl$folioviv)     # 800
colSums(is.na(eigh_etl))          # solo ing_cor e ing_pc: los 18 conocidos
#| fin

# c) Reporta con `glue()` una línea de resumen del ETL.

#| solucion
glue("ETL terminado: {nrow(eigh_etl)} hogares, \\
     {ncol(eigh_etl)} columnas, \\
     {sum(is.na(eigh_etl$ing_cor))} sin ingreso declarado.")
#| fin

# d) Guarda la tabla en `output/` como .rds. Es el insumo de la Sesión 5.

#| solucion
# .rds conserva los tipos de R tal cual: un factor sigue siendo factor y una
# fecha sigue siendo fecha, cosa que un CSV no garantiza.
write_rds(eigh_etl, "output/eigh_etl.rds")

# La verificación de que quedó bien escrito es volverlo a leer.
read_rds("output/eigh_etl.rds") |> glimpse()
#| fin
