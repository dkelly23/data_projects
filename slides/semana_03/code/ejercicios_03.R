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

#| nota
# BLOQUE DE PRÁCTICA — 1:15 hr. No son ejercicios sueltos: es un solo encargo
# resuelto por partes. Reparto sugerido:
#
#   Parte 1  Reconocimiento          10 min
#   Parte 2  El universo de análisis 12 min
#   Parte 3  Indicadores por hogar   15 min   <- el núcleo del bloque
#   Parte 4  Comparación por grupo   18 min
#   Parte 5  El perfil de personas   12 min
#   Parte 6  El lado del gasto        8 min
#
# Las partes 1 a 3 se escriben en el proyector, con la clase dictando el verbo
# ANTES de que se teclee. La pregunta a repetir en cada paso es la misma: "¿qué
# quiere esto de la tabla, filas o columnas?". De la 4 en adelante, cada quien en
# su máquina y recorrido por el salón.
#
# Si el tiempo aprieta, la parte 6 se resuelve en voz alta. Lo que NO se puede
# sacrificar es la 4: es la única donde group_by() se usa sobre una pregunta que
# el estudiante no puede responder de memoria.
#
# El encargo produce tres tablas de resultados —resumen_entidad, perfil_personas
# y resumen_rubro— más hogares_ind, la tabla de trabajo. La Sesión 4 retoma esos
# objetos para unirlos entre sí.
#| fin

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

#| solucion
hogares |> glimpse()     # una vivienda por fila
personas |> glimpse()    # una persona por fila
gastos |> glimpse()      # una combinación de hogar y rubro por fila
#| fin

# b) ¿Cuántos hogares hay por entidad? Usa `count()`.

#| solucion
hogares |> count(nom_ent)
#| fin

# c) ¿Qué valores toma `tam_loc`, y cuántos hogares hay en cada uno? Contrasta lo
#    que salga contra `docs/eigh_descriptor.csv`: hay un código que no es un
#    tamaño de localidad.

#| solucion
hogares |> count(tam_loc)
# El 9 es "no especificado", no un tamaño. Son 23 hogares.
#| fin

# d) Verifica que `entidad` y `nom_ent` se correspondan una a una: la clave
#    numérica y el nombre tienen que dar el mismo número de combinaciones.

#| solucion
hogares |> distinct(entidad, nom_ent)
# Seis filas: seis claves y seis nombres, sin duplicados de escritura.
#| fin

# e) ¿Cuántos hogares distintos aparecen en la tabla de gastos, y cuántos rubros
#    distintos hay?

#| solucion
gastos |> summarize(hogares = n_distinct(folioviv), rubros = n_distinct(clave))
#| fin
#| nota
# El inciso (e) es el que importa: 800 hogares en gastos y 800 en hogares. Que
# coincidan NO significa que sean los mismos, y comprobarlo exige un join, que
# es la Sesión 4. Vale la pena decirlo en voz alta y dejarlo pendiente.
#| fin


## 2. El universo de análisis ------------------------------------------------=

# Todo reporte empieza declarando sobre qué se calcula. Aquí el universo son los
# hogares con ingreso declarado y con tamaño de localidad conocido.

# a) ¿Cuántos hogares tienen `ing_cor` faltante? ¿Cuántos tienen `tam_loc == 9`?

#| solucion
hogares |> filter(is.na(ing_cor)) |> nrow()
hogares |> filter(tam_loc == 9) |> nrow()
#| fin

# b) Construye `hogares_val` con los hogares que cumplen las dos condiciones:
#    ingreso declarado y tamaño de localidad distinto de 9. ¿Cuántos quedan?

#| solucion
hogares_val = hogares |> filter(!is.na(ing_cor), tam_loc != 9)
nrow(hogares_val)
#| fin

# c) ¿Por qué el resultado de (b) no es 800 menos la suma de los dos conteos de
#    (a)?

#| nota
# Porque los dos conjuntos se traslapan: 18 sin ingreso y 23 sin tamaño de
# localidad, pero un hogar cae en las dos listas. 800 - 40 = 760, no 759.
#| fin



# d) Sobre `hogares_val`, quédate con los hogares de localidades urbanas
#    (`tam_loc` 1 o 2) de la Ciudad de México y Nuevo León. Usa `%in%` en las dos
#    condiciones.

#| solucion
hogares_val |> filter(tam_loc %in% c(1, 2), entidad %in% c("09", "19"))
#| fin

# e) Sobre `hogares_val`, los hogares de entre tres y cinco integrantes que
#    además gastaron más de lo que ingresaron. Dos condiciones, una con
#    `between()` y otra comparando dos columnas entre sí.

#| solucion
hogares_val |> filter(between(tot_integ, 3, 5), gasto_mon > ing_cor)
#| fin


## 3. Indicadores por hogar --------------------------------------------------=

# El reporte necesita variables que no vienen en el archivo. Todas salen de
# `mutate()` sobre `hogares_val`.

# a) Agrega `ing_pc` y `gasto_pc`: ingreso y gasto trimestrales divididos entre
#    el número de integrantes.

#| solucion
hogares_val |>
    mutate(
        ing_pc   = ing_cor / tot_integ,
        gasto_pc = gasto_mon / tot_integ,
        .keep = "used"
    )
#| fin

# b) Agrega `prop_gasto`: la proporción del ingreso que se va en gasto. Tiene que
#    poder calcularse a partir de las dos columnas de (a), en la misma llamada a
#    `mutate()`.

#| solucion
hogares_val |>
    mutate(
        ing_pc     = ing_cor / tot_integ,
        gasto_pc   = gasto_mon / tot_integ,
        prop_gasto = gasto_pc / ing_pc,
        .keep = "used"
    )
#| fin

# c) Agrega `deficitario`: TRUE cuando el gasto supera al ingreso. Cuidado con el
#    reflejo de escribir `if_else()`: la comparación ya devuelve un lógico.

#| solucion
hogares_val |> mutate(deficitario = gasto_mon > ing_cor, .keep = "used")
# if_else(gasto_mon > ing_cor, TRUE, FALSE) da lo mismo y sobra: la condición
# que se le pasaría como primer argumento ES el resultado.
#| fin

# d) Agrega `urbano`: "urbano" cuando `tam_loc` es 1 o 2, "rural" en otro caso.

#| solucion
hogares_val |>
    mutate(urbano = if_else(tam_loc %in% c(1, 2), "urbano", "rural"), .keep = "used")
#| fin

# e) Agrega `estrato` con cuatro niveles, según el ingreso per cápita: menos de
#    10,000 "bajo"; menos de 20,000 "medio bajo"; menos de 40,000 "medio alto"; y
#    de ahí en adelante "alto". Usa `case_when()` y cuida el orden de las ramas.

#| solucion
hogares_val |>
    mutate(
        ing_pc  = ing_cor / tot_integ,
        estrato = case_when(
            ing_pc <  10000 ~ "bajo",
            ing_pc <  20000 ~ "medio bajo",
            ing_pc <  40000 ~ "medio alto",
            .default = "alto"
        ),
        .keep = "used"
    )
#| fin

# f) Junta todo en un solo objeto llamado `hogares_ind`, con las seis columnas
#    derivadas en una sola llamada a `mutate()`. Verifica el resultado con
#    `count()` sobre `estrato` y sobre `deficitario`.

#| solucion
hogares_ind = hogares_val |>
    mutate(
        ing_pc      = ing_cor / tot_integ,
        gasto_pc    = gasto_mon / tot_integ,
        prop_gasto  = gasto_pc / ing_pc,
        deficitario = gasto_mon > ing_cor,
        urbano      = if_else(tam_loc %in% c(1, 2), "urbano", "rural"),
        estrato     = case_when(
            ing_pc <  10000 ~ "bajo",
            ing_pc <  20000 ~ "medio bajo",
            ing_pc <  40000 ~ "medio alto",
            .default = "alto"
        )
    )

hogares_ind |> count(estrato)
hogares_ind |> count(deficitario)
#| fin

# g) Reduce `hogares_ind` a lo que el reporte va a usar: el folio, el nombre de
#    la entidad, todo lo que empiece con "ing", todo lo que termine en "_pc", y
#    las tres columnas categóricas. Usa `select()` con helpers donde se pueda.

#| solucion
hogares_ind |>
    select(folioviv, nom_ent, starts_with("ing"), ends_with("_pc"),
        urbano, estrato, deficitario)
#| fin
#| nota
# El inciso (f) es donde se separa quien entendió de quien está copiando. Los que
# escribieron seis mutate() encadenados llegan al mismo resultado y hay que
# dejarlos llegar; el comentario va después, sobre por qué una sola llamada basta.
#| fin


## 4. Comparación por grupo --------------------------------------------------=

# La primera tabla del reporte. Todo sale de `group_by()` y `summarize()` sobre
# `hogares_ind`.

# a) ¿Cuántos hogares y cuál es el ingreso per cápita medio, por entidad?

#| solucion
hogares_ind |>
    group_by(nom_ent) |>
    summarize(hogares = n(), ing_pc_medio = mean(ing_pc))
#| fin

# b) Agrega a ese resumen la mediana del ingreso per cápita y el gasto per cápita
#    medio. ¿La media y la mediana coinciden? ¿Qué dice eso de la distribución?

#| solucion
hogares_ind |>
    group_by(nom_ent) |>
    summarize(
        hogares        = n(),
        ing_pc_medio   = mean(ing_pc),
        ing_pc_mediano = median(ing_pc),
        gasto_pc_medio = mean(gasto_pc)
    )
# La media está por encima de la mediana en todas las entidades: la cola alta
# de la distribución de ingreso la jala.
#| fin

# c) Construye `resumen_entidad`: el resumen de (b), más la proporción de hogares
#    deficitarios de cada entidad, ordenado de mayor a menor ingreso per cápita.
#    La proporción sale de promediar una columna lógica.

#| solucion
resumen_entidad = hogares_ind |>
    group_by(nom_ent) |>
    summarize(
        hogares         = n(),
        ing_pc_medio    = mean(ing_pc),
        ing_pc_mediano  = median(ing_pc),
        gasto_pc_medio  = mean(gasto_pc),
        prop_deficit    = mean(deficitario)
    ) |>
    arrange(desc(ing_pc_medio))

resumen_entidad
#| fin

# d) El mismo ingreso per cápita medio, ahora por entidad Y por condición urbana.
#    Lee el mensaje que imprime `summarize()`: ¿por cuál variable quedó agrupado
#    el resultado?

#| solucion
hogares_ind |>
    group_by(nom_ent, urbano) |>
    summarize(ing_pc_medio = mean(ing_pc))
# El mensaje avisa que el resultado sigue agrupado por nom_ent: summarize()
# consumió solo la última variable de agrupación.
#| fin

# e) Repite (d) dejando el resultado desagrupado, de las dos formas: con
#    `.groups = "drop"` y con `ungroup()`. Comprueba con `group_vars()`.

#| solucion
hogares_ind |>
    group_by(nom_ent, urbano) |>
    summarize(ing_pc_medio = mean(ing_pc), .groups = "drop") |>
    group_vars()

hogares_ind |>
    group_by(nom_ent, urbano) |>
    summarize(ing_pc_medio = mean(ing_pc)) |>
    ungroup() |>
    group_vars()
#| fin

# f) ¿Cuál es el hogar de mayor ingreso per cápita de cada entidad? Devuelve una
#    fila por entidad, con el folio y el ingreso per cápita.

#| solucion
hogares_ind |>
    group_by(nom_ent) |>
    slice_max(ing_pc, n = 1) |>
    ungroup() |>
    select(nom_ent, folioviv, ing_pc)
#| fin

# g) Agrega a `hogares_ind` una columna `ing_pc_rel`: el ingreso per cápita del
#    hogar dividido entre el ingreso per cápita medio DE SU ENTIDAD. Aquí
#    `group_by()` va con `mutate()`, no con `summarize()`. Acuérdate de
#    desagrupar antes de guardar.

#| solucion
hogares_ind = hogares_ind |>
    group_by(nom_ent) |>
    mutate(ing_pc_rel = ing_pc / mean(ing_pc)) |>
    ungroup()

hogares_ind |> select(folioviv, nom_ent, ing_pc, ing_pc_rel)
#| fin

# h) ¿Cuántos hogares de cada entidad están por encima del ingreso per cápita
#    medio de su propia entidad? Se responde filtrando sobre la columna de (g).

#| solucion
hogares_ind |>
    filter(ing_pc_rel > 1) |>
    count(nom_ent)
#| fin


## 5. El perfil de personas --------------------------------------------------=

# La segunda tabla del reporte. Cambia la unidad de observación: aquí cada fila
# es una persona, así que "el ingreso medio" ya no significa lo mismo.

# a) ¿Cuántas personas tienen edad faltante? Recuerda que la importación ya
#    convirtió el código 999 en NA.

#| solucion
personas |> filter(is.na(edad)) |> nrow()
#| fin

# b) Construye `personas_val`: personas con edad declarada y de 15 años o más.

#| solucion
personas_val = personas |> filter(!is.na(edad), edad >= 15)
nrow(personas_val)
#| fin

# c) Agrega dos columnas: `sexo_lab`, con "hombre" y "mujer" según el código 1/2
#    del descriptor, y `grupo_edad`, con los cortes 15-29, 30-44, 45-64 y 65 o
#    más. La primera con `if_else()`, la segunda con `case_when()`.

#| solucion
personas_val = personas_val |>
    mutate(
        sexo_lab   = if_else(sexo == 1, "hombre", "mujer"),
        grupo_edad = case_when(
            edad < 30 ~ "15-29",
            edad < 45 ~ "30-44",
            edad < 65 ~ "45-64",
            .default = "65+"
        )
    )

personas_val |> count(sexo_lab, grupo_edad)
#| fin

# d) Agrega `ocupado`: TRUE cuando `ing_trab` es mayor que cero. Cuidado con los
#    faltantes: hay personas que no declararon ingreso por trabajo, y no es lo
#    mismo que haber declarado cero.

#| solucion
personas_val = personas_val |> mutate(ocupado = ing_trab > 0)
personas_val |> count(ocupado)
# El TRUE/FALSE sale directo de la comparación; las personas sin dato quedan NA.
#| fin

# e) Construye `perfil_personas`: por sexo y grupo de edad, el número de
#    personas, la tasa de ocupación y el ingreso medio por trabajo de quienes lo
#    declararon. Deja el resultado desagrupado.

#| solucion
perfil_personas = personas_val |>
    group_by(sexo_lab, grupo_edad) |>
    summarize(
        personas       = n(),
        tasa_ocupacion = mean(ocupado, na.rm = TRUE),
        ing_trab_medio = mean(ing_trab, na.rm = TRUE),
        .groups = "drop"
    )

perfil_personas
#| fin

# f) ¿Qué combinación de sexo y grupo de edad tiene el ingreso medio por trabajo
#    más alto? Y la más baja?

#| solucion
perfil_personas |> slice_max(ing_trab_medio, n = 1)
perfil_personas |> slice_min(ing_trab_medio, n = 1)
#| fin
#| nota
# En (e) la tasa de ocupación se calcula sobre quienes SÍ declararon, porque
# na.rm = TRUE cambió el denominador. Preguntarlo explícitamente: ¿cuántas
# personas quedaron fuera de ese promedio? Es la misma discusión de la
# exposición, ahora con consecuencias sustantivas.
#| fin


## 6. El lado del gasto ------------------------------------------------------=

# La tercera tabla. Solo con `gastos`: cruzar rubro con entidad exige un join, y
# eso es la Sesión 4.

# a) ¿Cuántos renglones de gasto hay por rubro, de mayor a menor?

#| solucion
gastos |> count(clave, sort = TRUE)
#| fin

# b) Construye `resumen_rubro`: por rubro, el número de renglones, el gasto
#    trimestral medio y el gasto total, ordenado por gasto total descendente.

#| solucion
resumen_rubro = gastos |>
    group_by(clave) |>
    summarize(
        renglones   = n(),
        gasto_medio = mean(gasto_tri),
        gasto_total = sum(gasto_tri),
        .groups = "drop"
    ) |>
    arrange(desc(gasto_total))

resumen_rubro
#| fin

# c) Agrega a `resumen_rubro` la participación de cada rubro en el gasto total
#    declarado. Es un `mutate()` después del `summarize()`, y la suma de la
#    columna nueva tiene que dar 1.

#| solucion
resumen_rubro = resumen_rubro |>
    mutate(participacion = gasto_total / sum(gasto_total))

resumen_rubro
sum(resumen_rubro$participacion)
#| fin

# d) ¿Cuánto gastó cada hogar en total, y cuáles son los diez que más gastaron?
#    El resultado tiene una fila por hogar.

#| solucion
gastos |>
    group_by(folioviv) |>
    summarize(gasto_total = sum(gasto_tri), rubros = n(), .groups = "drop") |>
    slice_max(gasto_total, n = 10)
#| fin

# e) Para cada hogar, ¿qué rubro se llevó el gasto más alto? Una fila por hogar,
#    con el folio, la clave del rubro y el monto.

#| solucion
gastos |>
    group_by(folioviv) |>
    slice_max(gasto_tri, n = 1) |>
    ungroup() |>
    select(folioviv, clave, gasto_tri)
#| fin

# f) ¿Cuántas veces resultó ganador cada rubro en (e)? Encadena `count()` al
#    resultado anterior.

#| solucion
gastos |>
    group_by(folioviv) |>
    slice_max(gasto_tri, n = 1) |>
    ungroup() |>
    count(clave, sort = TRUE)
#| fin
