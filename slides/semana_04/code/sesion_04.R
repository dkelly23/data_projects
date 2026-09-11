# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_04.R
# Objetivo:       Completar el ETL: reshape, joins entre tablas, manejo de NA y limpieza
#                 sistemática de campos de texto.
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
# BLOQUE DE EXPOSICIÓN — 1:45 hr. Reparto:
#
#   Las tres tablas             5 min
#   Pivots                     20 min
#   Joins                      33 min   <- el núcleo de la sesión
#   Manejo de NA               12 min
#   Categóricas                 7 min   <- repaso, no tema nuevo
#   stringr y regex            20 min
#   glue                        5 min
#   Cierre                      3 min
#
# La sesión tiene dos mitades que se tocan al final: la primera arma la tabla
# (pivots y joins), la segunda limpia lo que quedó adentro (NA y texto). El
# puente es el catálogo sucio: hay que limpiarlo con regex ANTES de poder
# unirlo, así que la limpieza de texto no es un apéndice sino un requisito.
#
# if_else() y case_when() ya se vieron en la S3 como helpers de mutate(). Aquí
# NO se re-enseñan: se usan sobre la tabla unida y se agrega lo que falta
# (.default, y la mención a forcats). Si el tiempo aprieta, esa sección es la
# primera que se recorta; la que no se toca es joins.
#
# tidylog se carga al final del preámbulo y cambia lo que imprime la consola en
# TODA la sesión. Conviene advertirlo antes de la primera corrida, porque el
# ruido extra desconcierta si aparece sin aviso.
#| fin

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola

# Paquetes de la sesión
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(tidyverse, readxl, glue, tidylog)

# Las tres tablas de la EIGH, leídas como quedaron al cierre de la Sesión 2.
hogares = read_csv("files/eigh_hogares.csv", show_col_types = FALSE)

personas = read_delim("files/eigh_personas.txt", delim = "|",
    na = c("", "n.d.", "999"),
    col_types = cols(folioviv = col_character(), ing_trab = col_double()))

gastos = read_csv2("files/eigh_gastos.csv", show_col_types = FALSE)

# El catálogo de rubros, acotado con range como en la Sesión 2.
claves_gasto = read_excel("files/eigh_catalogos.xlsx", sheet = "claves_gasto",
    range = "A3:C11")


# CODIGO ______________________________________________________________________

# LAS TRES TABLAS ______________________________________________________________

## Una unidad de observación por tabla -----------------------------------------=

# La Sesión 3 trabajó siempre sobre UNA tabla. Los seis verbos no alcanzan para
# la pregunta que sigue, porque el dato vive repartido:
#
#   hogares    una vivienda por fila      ingreso, gasto, entidad
#   personas   una persona por fila       sexo, edad, escolaridad
#   gastos     un hogar-rubro por fila    monto por rubro
#   catálogo   un rubro por fila          qué significa cada clave
#
# "¿Cuánto gastan en alimentos los hogares de Oaxaca?" necesita las tres: la
# entidad está en hogares, el monto en gastos y el significado de la clave en el
# catálogo. Ninguna cadena de verbos cruza esa frontera.

# Lo que las une es una columna compartida: folioviv entre las tres tablas de
# campo, clave entre gastos y el catálogo. A esa columna se le llama LLAVE.
hogares  |> select(folioviv, nom_ent, ing_cor)
personas |> select(folioviv, numren, sexo, edad)
gastos   |> select(folioviv, clave, gasto_tri)

#| nota
# Dibujar las cuatro cajas en el pizarrón con las flechas del folio antes de
# escribir una línea de código, y dejarlo dibujado toda la sesión. Es el mapa al
# que hay que volver cada vez que alguien pregunte "¿y esto por qué se duplicó?".
#| fin


# PIVOTS _______________________________________________________________________

# Las dos funciones son de tidyr, no de dplyr. Cambian la FORMA de la tabla: ni
# agregan información ni la quitan, la reacomodan. La pregunta que contestan es
# cuál de las dos formas —ancha o larga— corresponde a la operación que sigue.

## pivot_longer() --------------------------------------------------------------=

#     pivot_longer(datos, cols, names_to, values_to)
#
# Toma varias columnas y las convierte en dos: una con los nombres y otra con
# los valores. La tabla se hace más larga y más angosta.

# En hogares, ing_cor y gasto_mon son dos conceptos del mismo tipo guardados en
# columnas distintas. Para compararlos en una sola operación conviene apilarlos.
hogares |>
    select(folioviv, ing_cor, gasto_mon) |>
    pivot_longer(
        cols      = c(ing_cor, gasto_mon),
        names_to  = "concepto",
        values_to = "monto"
    )

# 800 filas entraron, 1,600 salieron: dos por hogar, una por concepto. Ninguna
# celda se perdió; cambiaron de lugar.
#
# # A tibble: 1,600 × 3
#    folioviv concepto    monto
#    <chr>    <chr>       <dbl>
#  1 0773233  ing_cor    35847.
#  2 0773233  gasto_mon  22717.
#  3 0382982  ing_cor    75262.
#  4 0382982  gasto_mon 102714.
#  5 0348747  ing_cor       NA
#  6 0348747  gasto_mon  37736.

# cols acepta la misma notación de select(), incluida la negación: "todo menos
# el folio" es la forma más frecuente de escribirlo cuando las columnas son muchas.
hogares |>
    select(folioviv, ing_cor, gasto_mon) |>
    pivot_longer(cols = -folioviv, names_to = "concepto", values_to = "monto")

# El formato largo es el que quieren group_by() y ggplot2: una columna dice QUÉ
# se mide y otra CUÁNTO. Por eso casi todo el tidyverse lo prefiere.
hogares |>
    select(folioviv, ing_cor, gasto_mon) |>
    pivot_longer(cols = -folioviv, names_to = "concepto", values_to = "monto") |>
    summarize(media = mean(monto, na.rm = TRUE), .by = concepto)


## pivot_wider() ---------------------------------------------------------------=

#     pivot_wider(datos, id_cols, names_from, values_from)
#
# La operación inversa: toma una columna de nombres y otra de valores, y los
# despliega en varias columnas. La tabla se hace más corta y más ancha.

# gastos tiene una fila por hogar-rubro. Para una tabla con una fila por HOGAR y
# una columna por rubro:
gastos |>
    pivot_wider(
        id_cols     = folioviv,
        names_from  = clave,
        values_from = gasto_tri
    )

# 4,418 filas entraron, 800 salieron. Las columnas salen en el orden en que
# apareció cada clave en los datos, no en orden alfabético:
#
# # A tibble: 800 × 9
#    folioviv   A002   E001  B001  A001   C001  B002  F001  D001
#    <chr>     <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
#  1 0773233   5397.  3188. 2124. 4332.   500.  436.   NA    NA
#  2 0382982     NA     NA  2530. 2720.  5249. 1755.   NA    NA

# names_sort lo corrige, y names_prefix evita nombres de columna que empiecen
# con algo que no parezca un nombre.
gastos |>
    pivot_wider(id_cols = folioviv, names_from = clave, values_from = gasto_tri,
        names_sort = TRUE, names_prefix = "gasto_")


### Los NA que fabrica el pivot ----

# El ancho introdujo faltantes que no estaban en el largo. No son no respuesta:
# son combinaciones hogar-rubro que nunca existieron, porque cada hogar declaró
# entre 3 y 8 rubros de los 8 posibles.
gastos_ancho = gastos |>
    pivot_wider(id_cols = folioviv, names_from = clave, values_from = gasto_tri,
        names_sort = TRUE)

colSums(is.na(gastos_ancho))
# folioviv     A001     A002     B001     B002     C001     D001     E001     F001
#        0      235      242      265      243      267      238      245      247

# Aquí el NA significa "no gastó en este rubro", así que el cero es la lectura
# correcta y se pide al pivotar. Es una DECISIÓN, y no siempre es esta: si el
# rubro pudiera haber quedado sin capturar, el cero estaría inventando un dato.
gastos |>
    pivot_wider(id_cols = folioviv, names_from = clave, values_from = gasto_tri,
        names_sort = TRUE, values_fill = 0)

#| nota
# Este es el punto de la sección y conviene decirlo despacio: values_fill = 0 no
# es un argumento de limpieza, es una afirmación sobre el mundo. Preguntar a la
# clase qué tendría que ser cierto para que el cero esté bien, y no seguir hasta
# que alguien diga "que la ausencia signifique que no gastó".
#| fin


### Cuando la llave no es única ----

# pivot_wider() supone que la combinación id_cols + names_from identifica una
# sola fila. Si no, no puede elegir cuál valor poner en la celda, y devuelve una
# lista adentro de la columna:
ejemplo = tibble(
    folioviv  = c("0000001", "0000001", "0000002"),
    clave     = c("A001", "A001", "A001"),
    gasto_tri = c(10, 20, 30)
)

ejemplo |> pivot_wider(names_from = clave, values_from = gasto_tri)
# # A tibble: 2 × 2
#   folioviv A001
#   <chr>    <list>
# 1 0000001  <dbl [2]>
# 2 0000002  <dbl [1]>
#
# Warning: Values from `gasto_tri` are not uniquely identified; output will
# contain list-cols.

# La salida con <list> adentro es la señal de que la llave estaba duplicada. La
# respuesta no es silenciar el aviso: es decidir qué hacer con el duplicado.
ejemplo |> pivot_wider(names_from = clave, values_from = gasto_tri, values_fn = sum)

# En la EIGH la llave sí es única, y eso se verifica antes de pivotar:
gastos |> count(folioviv, clave) |> filter(n > 1)
# # A tibble: 0 × 3   <- cero filas: la llave es única


# JOINS ________________________________________________________________________

# Un join combina dos tablas emparejando filas por su llave. dplyr tiene dos
# familias, y la diferencia está en qué hacen con las columnas:
#
#   MUTATING JOINS    agregan columnas de la segunda tabla a la primera
#   FILTERING JOINS   no agregan nada: solo deciden qué filas de la primera se
#                     conservan, usando la segunda como criterio

## Mutating joins --------------------------------------------------------------=

#     left_join(x, y, by = "llave")
#
# Conserva TODAS las filas de x y les pega las columnas de y donde la llave
# coincide. Es el join de trabajo: el que se usa mientras no haya razón para
# otro, porque no pierde filas de la tabla que interesa.

# El catálogo tiene una fila por clave y gastos tiene muchas: cada fila de
# gastos encuentra exactamente una pareja. Esto es un join MUCHOS A UNO.
gastos |> left_join(claves_gasto, by = "clave")

# 4,418 filas entraron, 4,418 salieron. Un join muchos-a-uno no cambia el número
# de filas: solo agrega columnas.
#
# # A tibble: 4,418 × 6
#    folioviv clave gasto_tri frecuencia rubro      descripcion
#    <chr>    <chr>     <dbl>      <dbl> <chr>      <chr>
#  1 0773233  A002      5397.          5 Alimentos  Alimentos consumidos fuera d…
#  2 0773233  E001      3188.          3 Salud      Consultas, medicamentos y ho…

# Ahora sí se puede responder la pregunta del arranque, que ninguna tabla
# contestaba sola:
gastos |>
    left_join(claves_gasto, by = "clave") |>
    left_join(hogares, by = "folioviv") |>
    filter(nom_ent == "Oaxaca", rubro == "Alimentos") |>
    summarize(gasto_medio = mean(gasto_tri), hogares = n_distinct(folioviv))
#   gasto_medio hogares
# 1       2940.     113


### El join que multiplica filas ----

# El caso inverso: hogares tiene una fila por vivienda y gastos tiene varias.
# Cada fila de hogares se REPITE una vez por cada gasto que le corresponde.
hogares |> left_join(gastos, by = "folioviv") |> nrow()
# [1] 4418

# 800 filas entraron y 4,418 salieron. No es un error: es lo que significa un
# join UNO A MUCHOS, y es correcto si lo que se quiere es una tabla al nivel del
# gasto. Se vuelve un error cuando después se suma ing_cor, porque el ingreso
# del hogar aparece repetido entre 3 y 8 veces.
hogares |> summarize(ingreso = sum(ing_cor, na.rm = TRUE))
#      ingreso
# 1 55350869.

hogares |> left_join(gastos, by = "folioviv") |> summarize(ingreso = sum(ing_cor, na.rm = TRUE))
#      ingreso
# 1 307457446.   <- el mismo ingreso contado una vez por rubro

#| nota
# Correr las dos líneas y dejar los dos números en pantalla: 55,350,869 contra
# 307,457,446, cinco veces y media más. Nadie lo pidió y nadie fue advertido. Esta es la diapositiva que
# hay que lograr que recuerden en diciembre; el resto de la sección es
# vocabulario. La regla que se llevan: después de un join, la primera pregunta
# es SIEMPRE cuántas filas hay.
#| fin


### Las cuatro variantes ----

# Se distinguen por qué filas conservan cuando la llave no empareja:
#
#   left_join(x, y)    todas las de x           (el defecto de trabajo)
#   right_join(x, y)   todas las de y
#   inner_join(x, y)   solo las que emparejan   (puede perder filas en silencio)
#   full_join(x, y)    todas las de ambas       (puede crear filas con NA)

# En la EIGH las llaves están completas, así que las cuatro coinciden:
inner_join(hogares, gastos, by = "folioviv") |> nrow()
full_join(hogares, gastos, by = "folioviv")  |> nrow()

# Que coincidan es el resultado deseable, no el esperable. Con datos reales,
# comparar left_join contra inner_join es la forma barata de medir cuántas filas
# no encontraron pareja.


### by y join_by() ----

# by = "folioviv" funciona cuando la columna se llama igual en las dos tablas.
# La sintaxis recomendada es join_by(), que no lleva comillas y admite llaves
# con nombres distintos:
gastos |> left_join(claves_gasto, join_by(clave))
hogares |> left_join(gastos, join_by(folioviv))

# Con nombres distintos a cada lado:
#   left_join(x, y, join_by(folio_vivienda == folioviv))

# Con llave compuesta se nombran las dos columnas, y las dos tienen que coincidir:
#   left_join(x, y, join_by(folioviv, numren))

# Si se omite by, dplyr empareja por TODAS las columnas de nombre común y avisa
# cuáles usó. Sirve para explorar; no para código que se guarda.
hogares |> left_join(gastos)


### Columnas que colisionan ----

# Cuando las dos tablas traen una columna con el mismo nombre que no es llave,
# dplyr conserva ambas y las desambigua con sufijos:
hogares |> left_join(personas, by = "folioviv") |> names()
#  [1] "folioviv"  "entidad"  "nom_ent"  "tam_loc"  "tot_integ"
#  [6] "ing_cor"   "gasto_mon" "factor.x" "numren"   "parentesco"
# [11] "sexo"      "edad"     "nivel_esc" "ing_trab" "factor.y"

# factor.x es el de la vivienda y factor.y el de la persona. El sufijo avisa,
# pero no dice cuál es cuál: conviene renombrar antes de unir, o declararlo.
hogares |>
    left_join(personas, by = "folioviv", suffix = c("_hog", "_per")) |>
    select(folioviv, factor_hog, factor_per)


## Filtering joins -------------------------------------------------------------=

# No agregan columnas. Usan la segunda tabla como criterio para filtrar la
# primera, y devuelven exactamente las columnas de x.

#     semi_join(x, y)   conserva las filas de x que SÍ tienen pareja en y
#     anti_join(x, y)   conserva las filas de x que NO tienen pareja en y

# ¿Qué hogares declararon gasto en educación? Con semi_join no hace falta
# arrastrar las columnas de gastos ni preocuparse por duplicar filas:
hogares |> semi_join(gastos |> filter(clave == "D001"), by = "folioviv") |> nrow()
# [1] 562

# La diferencia con left_join + filter es que semi_join NUNCA duplica filas,
# aunque la fila de x empareje con varias de y. Devuelve un subconjunto de x.

### anti_join como verificación ----

# anti_join es la herramienta de diagnóstico de la sesión. Antes de unir dos
# tablas, se pregunta qué se va a quedar afuera. La respuesta que se quiere es
# "nada", y se lee como cero filas:
hogares |> anti_join(gastos, by = "folioviv")
# # A tibble: 0 × 8    <- ningún hogar sin gastos

gastos |> anti_join(hogares, by = "folioviv")
# # A tibble: 0 × 4    <- ningún gasto sin hogar

# Las dos direcciones se revisan, porque contestan cosas distintas. Con datos
# reales casi nunca dan cero, y ahí empieza el trabajo: entender POR QUÉ no
# emparejan antes de decidir qué join usar.


## Keys y cardinalidad ---------------------------------------------------------=

# Una llave identifica filas. Antes de un join hay que saber si identifica UNA
# fila o varias en cada tabla, porque de eso depende cuántas filas salen.
hogares  |> count(folioviv) |> filter(n > 1)   # 0 filas: llave única
personas |> count(folioviv) |> filter(n > 1)   # varias: uno a muchos
personas |> count(folioviv, numren) |> filter(n > 1)   # 0 filas: la llave es compuesta

# Las cuatro cardinalidades y lo que le pasa al número de filas:
#
#   uno a uno        no cambia
#   muchos a uno     no cambia          gastos   <- catálogo
#   uno a muchos     crece              hogares  <- gastos
#   muchos a muchos  estalla            gastos   <- personas

### El argumento relationship ----

# dplyr puede verificar la cardinalidad esperada y fallar si no se cumple. Es la
# forma de convertir un supuesto en una prueba:
gastos |> left_join(claves_gasto, join_by(clave), relationship = "many-to-one")

# Si el supuesto es falso, el join no corre. Descomentar en clase:
# hogares |> left_join(gastos, join_by(folioviv), relationship = "one-to-one")
#
#   Error in `left_join()`:
#   ! Each row in `x` must match at most 1 row in `y`.
#   ℹ Row 1 of `x` matches multiple rows in `y`.

# El many-to-many nunca se declara por comodidad. dplyr avisa solo cuando ocurre
# sin haberse pedido, y el aviso casi siempre señala una llave equivocada:
gastos |> left_join(personas, by = "folioviv") |> nrow()
# Warning: Detected an unexpected many-to-many relationship between `x` and `y`.
# [1] 14340

# 4,418 por las personas de cada hogar. La tabla resultante no tiene unidad de
# observación: cada gasto aparece repetido una vez por integrante. La llave
# correcta entre esas dos tablas no existe, porque el gasto es del hogar y no de
# la persona.


### El join que no empareja nada ----

# El error silencioso de la sesión, y es el de la Sesión 2 con otro disfraz. Si
# folioviv se lee como número, pierde el cero inicial:
hogares_mal = read_csv("files/eigh_hogares.csv", show_col_types = FALSE,
    col_types = cols(folioviv = col_double()))

head(hogares_mal$folioviv, 3)   # [1] 773233 382982 348747
head(gastos$folioviv, 3)        # [1] "0773233" "0773233" "0773233"

# Con tipos distintos, dplyr se niega a unir. Este error es el caso AFORTUNADO:
# hogares_mal |> left_join(gastos, by = "folioviv")
#
#   Error in `left_join()`:
#   ! Can't join `x$folioviv` with `y$folioviv` due to incompatible types.
#   ℹ `x$folioviv` is a <double>.
#   ℹ `y$folioviv` is a <character>.

# El caso desafortunado es cuando alguien "arregla" el tipo sin arreglar el dato.
# Ahora los tipos coinciden, el join corre, no hay error, y no empareja NADA:
hogares_mal |>
    mutate(folioviv = as.character(folioviv)) |>
    left_join(gastos, by = "folioviv") |>
    summarize(filas = n(), con_gasto = sum(!is.na(gasto_tri)))
# filas: 800, con_gasto: 0

#| nota
# Aquí conviene detenerse. El resultado tiene 800 filas, que es exactamente lo
# que se esperaba de un left_join sobre hogares, así que la verificación de
# "¿cuántas filas hay?" pasa sin problema. Lo único que delata el desastre es
# que todas las columnas de gastos vinieron vacías. Preguntar a la clase cómo lo
# habrían detectado: la respuesta es anti_join ANTES de unir, que habría
# devuelto las 800 filas en vez de cero.
#| fin


## Diagnóstico con tidylog -----------------------------------------------------=

# tidylog intercepta las funciones de dplyr y tidyr e imprime en consola qué
# hizo cada una. No cambia el resultado: solo lo narra.
#
#   library(tidylog)
#
#   hogares |> left_join(gastos, by = "folioviv")
#   left_join: added 3 columns (clave, gasto_tri, frecuencia)
#              > rows only in hogares      0
#              > rows only in gastos  (    0)
#              > matched rows          4,418    (includes duplicates)
#              >                      =======
#              > rows total            4,418
#
# Las tres líneas que importan son las mismas tres preguntas de la sección:
# cuántas filas se quedaron sin pareja de cada lado, y cuántas salieron.

# También narra los verbos de la Sesión 3, y ahí es donde más sirve: dice cuánto
# filtró cada paso y cuántos NA nuevos apareció cada mutate.
hogares |> filter(ing_cor > 50000)
# filter: removed 321 rows (40%), 479 rows remaining

hogares |> mutate(ing_pc = ing_cor / tot_integ)
# mutate: new variable 'ing_pc' (double) with 783 unique values and 2% NA

# Se apaga cuando estorba, sin descargar el paquete:
#   pacman::p_unload(tidylog)

#| nota
# La recomendación honesta: encendido mientras se escribe el pipeline, apagado
# cuando el pipeline ya corre. Deja la consola ilegible en un script largo, y en
# un bucle imprime una vez por iteración. No va en código que se entrega.
#| fin


# MANEJO DE NA _________________________________________________________________

# La Sesión 2 vio qué es un NA y la Sesión 3 lo vio propagarse. Aquí van las tres
# funciones que intervienen sobre él. Ninguna es la opción por defecto: las tres
# son decisiones que hay que poder justificar.

## replace_na() ----------------------------------------------------------------=

#     replace_na(x, valor)
#
# Sustituye los faltantes por un valor fijo. Es lo mismo que values_fill del
# pivot, aplicado después y sobre la columna que sea.
gastos_ancho |> mutate(across(A001:F001, \(x) replace_na(x, 0)))

# Sobre una sola columna, la forma directa:
gastos_ancho |> mutate(D001 = replace_na(D001, 0))


## coalesce() ------------------------------------------------------------------=

#     coalesce(x, y, ...)
#
# Devuelve el primer valor no faltante de cada fila, leyendo los argumentos de
# izquierda a derecha. Sirve para rellenar una columna con otra fuente.

# Los 18 hogares sin ing_cor declarado tienen personas con ingreso por trabajo.
# La suma de esas personas es un respaldo razonable del ingreso del hogar:
ing_personas = personas |>
    summarize(ing_pers = sum(ing_trab, na.rm = TRUE), .by = folioviv)

hogares_ing = hogares |>
    left_join(ing_personas, by = "folioviv") |>
    mutate(
        ing_final = coalesce(ing_cor, ing_pers),
        fuente    = if_else(is.na(ing_cor), "personas", "hogar")
    )

hogares_ing |> count(fuente)
# 1 hogar       782
# 2 personas     18

sum(is.na(hogares_ing$ing_final))   # [1] 0

# La columna `fuente` no es decorativa: es la constancia de qué se imputó y de
# dónde salió. Un dato rellenado sin marca es indistinguible de uno declarado.

### Lo que coalesce() no arregla ----

hogares_ing |>
    filter(is.na(ing_cor)) |>
    select(folioviv, ing_cor, ing_pers, ing_final) |>
    head(3)
#   folioviv ing_cor ing_pers ing_final
# 1 0348747       NA   24337.    24337.
# 2 0461718       NA       0         0
# 3 0942995       NA   24123.    24123.

# El segundo hogar recibió un ingreso de CERO. No es que no tenga ingreso: es
# que ninguna de sus personas declaró ing_trab, y sum(na.rm = TRUE) sobre puros
# NA devuelve 0. El respaldo fabricó un dato falso, y coalesce() no tenía cómo
# saberlo porque recibió un cero legítimo.

#| nota
# Preguntar cómo se arregla antes de mostrarlo. La respuesta es no dejar que la
# suma produzca un cero cuando no hay nada que sumar, y eso se decide arriba, en
# el summarize(), no abajo en el coalesce(). El punto general: el error entra en
# el eslabón anterior, igual que en la depuración de cadenas de la S3.
#| fin

ing_personas_ok = personas |>
    summarize(
        ing_pers = if_else(all(is.na(ing_trab)), NA, sum(ing_trab, na.rm = TRUE)),
        .by = folioviv
    )


## drop_na() -------------------------------------------------------------------=

#     drop_na(datos, columnas)
#
# Descarta filas con faltantes. Sin argumentos mira TODAS las columnas, que casi
# nunca es lo que se quiere.
nrow(hogares)                       # [1] 800
nrow(hogares |> drop_na(ing_cor))   # [1] 782
nrow(hogares |> drop_na())          # [1] 782

# Aquí los dos números coinciden porque ing_cor es la única columna con
# faltantes. En una tabla con veinte columnas, drop_na() sin argumentos elimina
# filas por defectos en columnas que no participan en el análisis.

# La decisión se toma y se deja por escrito, con el conteo a la vista:
hogares |>
    summarize(total = n(), sin_ingreso = sum(is.na(ing_cor)))


# VARIABLES CATEGORICAS ________________________________________________________

#| nota
# REPASO, no tema nuevo: if_else() y case_when() se vieron en la S3 como helpers
# de mutate(). Siete minutos. Lo único nuevo es .default y la mención a forcats.
# Si la sesión va retrasada, esta sección se resuelve leyendo el código en voz
# alta sin correrlo.
#| fin

## if_else() y case_when() -----------------------------------------------------=

# Los dos ya se usaron arriba. Lo que agrega esta sesión es dónde se usan: sobre
# la tabla unida, para traducir los códigos del catálogo a etiquetas legibles.
personas |>
    mutate(
        sexo_etq = if_else(sexo == 1, "Hombre", "Mujer"),
        grupo_edad = case_when(
            is.na(edad)  ~ "sin dato",
            edad < 15    ~ "0-14",
            edad < 30    ~ "15-29",
            edad < 60    ~ "30-59",
            .default     = "60+"
        )
    ) |>
    count(sexo_etq, grupo_edad)

# Tres recordatorios de la S3 que siguen valiendo:
#
#   1. case_when() evalúa en ORDEN y toma la primera rama verdadera.
#   2. Lo que no cae en ninguna rama recibe NA, salvo que se use .default.
#   3. Las ramas tienen que devolver el mismo tipo.

# El NA se atiende PRIMERO, porque is.na(edad) es la única condición que las
# comparaciones no pueden contestar: edad < 15 con edad NA devuelve NA, no FALSE.

## forcats, en una línea -------------------------------------------------------=

# Una categórica guardada como texto se ordena alfabéticamente, que casi nunca es
# el orden que se quiere. forcats convierte a factor y controla ese orden.
#
#   factor(grupo_edad, levels = c("0-14", "15-29", "30-59", "60+", "sin dato"))
#   fct_relevel()   mueve niveles a una posición
#   fct_reorder()   ordena los niveles por otra variable
#   fct_lump()      agrupa las categorías menos frecuentes en "Other"
#
# Importa sobre todo al graficar, así que se retoma en la Sesión 6.


# TEXTO ________________________________________________________________________

# El catálogo de rubros tiene una segunda hoja, capturada a mano, con la
# clasificación del gasto en necesario o discrecional. Ese dato no está en
# ninguna otra tabla, así que hay que usarla. El problema es cómo llega:
rubros_texto = read_excel("files/eigh_catalogos.xlsx", sheet = "rubros_texto",
    skip = 2)

rubros_texto
# # A tibble: 8 × 2
#   rubro_completo                                  tipo
#   <chr>                                           <chr>
# 1 A001 - Alimentos consumidos dentro del hogar    necesario
# 2 A002 – ALIMENTOS CONSUMIDOS FUERA DEL HOGAR     discrecional
# 3 B001- Renta o pago de vivienda                  NECESARIO
# 4 B002 : Electricidad,  agua y combustible        Necesario
# 5 C001 - transporte público y particular          necesario
# 6 D001  -  Colegiaturas y material escolar        NA
# 7 E001- CONSULTAS, medicamentos y hospitalización NECESARIO
# 8 F001 – Ropa, calzado y accesorios               Discrecional

# No hay columna `clave`: la clave viene PEGADA a la etiqueta, con un separador
# que cambia de fila en fila. Sin esa columna no hay join posible. La limpieza de
# texto no es un adorno de esta sesión: es lo que permite terminarla.

## stringr: vocabulario consistente --------------------------------------------=

# R base tiene funciones de texto —paste0(), nchar(), substr(), tolower(),
# gsub()— escritas en momentos distintos, con el argumento del texto unas veces
# primero y otras después. stringr las reemplaza con un sistema:
#
#   1. Todas empiezan con str_
#   2. El primer argumento es SIEMPRE el vector de texto (así que el pipe sirve)
#   3. El segundo es SIEMPRE el patrón
#   4. Vectorizadas: operan sobre la columna entera

# Las funciones núcleo, agrupadas por lo que hacen:
#
#   detectar     str_detect()    ¿contiene el patrón?      -> lógico
#   contar       str_count()     ¿cuántas veces?           -> entero
#   extraer      str_extract()   devuelve lo que coincide  -> texto
#   reemplazar   str_replace()   primera coincidencia
#                str_replace_all()  todas
#   quitar       str_remove()    reemplazar por ""
#   partir       str_split()     por un separador          -> lista
#   recortar     str_trim()      espacios de los extremos
#                str_squish()    extremos Y repetidos internos
#   rellenar     str_pad()       hasta un ancho fijo
#   mayúsculas   str_to_lower(), str_to_upper(), str_to_title(), str_to_sentence()
#   medir        str_length()
#   cortar       str_sub()       por posición

str_length(rubros_texto$rubro_completo)
str_to_lower(rubros_texto$tipo)
str_sub(gastos$clave[1:5], 1, 1)     # [1] "A" "E" "B" "A" "C"

### str_trim() y str_squish() ----

x = "  B001-  Renta   o pago "
str_trim(x)     # "B001-  Renta   o pago"    solo los extremos
str_squish(x)   # "B001- Renta o pago"       extremos y repetidos internos

# squish es el que se usa sobre datos capturados a mano: el espacio doble en
# medio de una frase es tan frecuente como el sobrante al final.


## Expresiones regulares -------------------------------------------------------=

# Un regex es un patrón que describe un CONJUNTO de textos. Se necesita aquí
# porque el separador del catálogo no es constante y no se puede buscar literal.

# Primer intento, y falla en tres filas:
str_detect(rubros_texto$rubro_completo, "-")
# [1]  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE FALSE

# Las filas 2 y 8 traen un guion largo (–, en dash) y la 4 trae dos puntos. Tres
# separadores distintos en ocho filas capturadas a mano.

### Los componentes ----

# Literales: se buscan a sí mismos.  "A001" empareja "A001"
#
# Clases de caracteres: un caracter de un conjunto
#   [abc]     a, b o c                [A-Z]  una mayúscula
#   [-–:]     guion, guion largo o dos puntos
#   \\d       un dígito               \\s    un espacio
#   \\w       letra, dígito o _       .      cualquier caracter
#
# Cuantificadores: cuántas veces se repite lo anterior
#   *         cero o más              +      una o más
#   ?         cero o una              {3}    exactamente tres
#   {2,4}     entre dos y cuatro
#
# Anclas: dónde tiene que ocurrir
#   ^         inicio del texto        $      final del texto
#
# Grupos: ()  delimitan una parte para extraerla o repetirla

# En R el patrón se escribe dentro de un string, así que la diagonal invertida
# se duplica: "\\d" en el código es \d en el regex.

### Aplicado al catálogo ----

# La clave es una mayúscula seguida de tres dígitos, y eso sí es constante:
str_extract(rubros_texto$rubro_completo, "[A-Z]\\d{3}")
# [1] "A001" "A002" "B001" "B002" "C001" "D001" "E001" "F001"

# Con el separador incluido se ve la variedad que había que absorber:
str_extract(rubros_texto$rubro_completo, "[A-Z]\\d{3}\\s*[-–:]")
# [1] "A001 -"  "A002 –"  "B001-"   "B002 :"  "C001 -"  "D001  -" "E001-"   "F001 –"

# \\s* dice "cero o más espacios", que es exactamente lo que varía.

# Los grupos de captura parten la coincidencia en piezas. str_match() devuelve
# una matriz: la coincidencia completa y luego un grupo por paréntesis.
str_match(rubros_texto$rubro_completo, "([A-Z])(\\d{3})") |> head(3)
#      [,1]   [,2] [,3]
# [1,] "A001" "A"  "001"
# [2,] "A002" "A"  "002"
# [3,] "B001" "B"  "001"

# Las anclas verifican forma. ¿Todos los folios empiezan con cero?
all(str_detect(hogares$folioviv, "^0"))        # [1] TRUE
all(str_detect(hogares$folioviv, "^\\d{7}$"))  # [1] TRUE: siete dígitos, ni uno más

# ^ y $ juntos exigen que el patrón describa el texto COMPLETO. Sin ellos,
# "\\d{7}" emparejaría cualquier texto que contenga siete dígitos seguidos.


### La limpieza completa ----

# Tres operaciones encadenadas, cada una con un propósito nombrado:
rubros = rubros_texto |>
    mutate(
        clave = str_extract(rubro_completo, "[A-Z]\\d{3}"),
        etiqueta = rubro_completo |>
            str_remove("^\\s*[A-Z]\\d{3}\\s*[-–:]\\s*") |>   # quitar clave y separador
            str_squish() |>                                   # espacios sobrantes
            str_to_sentence(),                                # capitalización pareja
        tipo = str_to_lower(tipo),
        .keep = "none"
    ) |>
    mutate(tipo = replace_na(tipo, "sin clasificar"))

rubros
# # A tibble: 8 × 3
#   tipo           clave etiqueta
#   <chr>          <chr> <chr>
# 1 necesario      A001  Alimentos consumidos dentro del hogar
# 2 discrecional   A002  Alimentos consumidos fuera del hogar
# 3 necesario      B001  Renta o pago de vivienda
# 4 necesario      B002  Electricidad, agua y combustible
# 5 necesario      C001  Transporte público y particular
# 6 sin clasificar D001  Colegiaturas y material escolar
# 7 necesario      E001  Consultas, medicamentos y hospitalización
# 8 discrecional   F001  Ropa, calzado y accesorios

# Con la columna clave construida, el catálogo ya se puede unir, y la sesión
# cierra el círculo: el regex produjo la llave que el join necesitaba.
gastos |>
    left_join(rubros, join_by(clave), relationship = "many-to-one") |>
    summarize(total = sum(gasto_tri), .by = tipo) |>
    arrange(desc(total))
# 1 necesario      7939059.
# 2 discrecional   2970824.
# 3 sin clasificar 1542840.

#| nota
# Vale la pena decir en voz alta que "sin clasificar" se lleva 1.5 millones. Es
# el rubro de educación, que quedó sin tipo porque la celda venía vacía. El
# replace_na() lo hizo visible en el resultado en vez de dejarlo desaparecer en
# un NA, y ese es el argumento para no descartar faltantes por reflejo.
#| fin


## Construcción dinámica con glue ----------------------------------------------=

# Interpolación: lo que va entre llaves se evalúa y se pega al texto.
tabla = "hogares"
glue("files/eigh_{tabla}.csv")
# files/eigh_hogares.csv

# Adentro de las llaves va CUALQUIER expresión de R, no solo un nombre:
glue("El levantamiento tiene {nrow(hogares)} hogares y {nrow(personas)} personas.")
# El levantamiento tiene 800 hogares y 2606 personas.

# Vectorizado: un vector adentro produce un vector afuera. Esta es la forma en
# que se arma una lista de rutas, y es lo que la Sesión 6 le pasará a map().
tablas = c("hogares", "personas", "gastos")
glue("files/eigh_{tablas}.csv")
# files/eigh_hogares.csv
# files/eigh_personas.csv
# files/eigh_gastos.csv

# Comparación con las alternativas de base:
#
#   paste0("files/eigh_", tabla, ".csv")           se rompe al leerlo
#   sprintf("files/eigh_%s.csv", tabla)            el valor va lejos del hueco
#   glue("files/eigh_{tabla}.csv")                 el valor va donde aparece
#
# La ventaja no es escribir menos, es que el texto final se lee en el código.

# Sirve también para mensajes de diagnóstico, que es donde más se usa:
n_sin = sum(is.na(hogares$ing_cor))
glue("Hogares sin ingreso declarado: {n_sin} de {nrow(hogares)} ({round(100 * n_sin / nrow(hogares), 1)}%).")
# Hogares sin ingreso declarado: 18 de 800 (2.2%).


# CIERRE _______________________________________________________________________

# El pipeline completo de la sesión, de las cuatro tablas crudas a una tabla de
# análisis. Cada paso es uno de los temas de hoy:
etl = gastos |>
    left_join(rubros, join_by(clave), relationship = "many-to-one") |>   # texto + join
    left_join(hogares, join_by(folioviv), relationship = "many-to-one") |>
    summarize(gasto = sum(gasto_tri), .by = c(folioviv, tipo)) |>
    pivot_wider(names_from = tipo, values_from = gasto, values_fill = 0)  # reshape

etl
# # A tibble: 800 × 4
#    folioviv discrecional necesario `sin clasificar`
#    <chr>           <dbl>     <dbl>            <dbl>
#  1 0773233         5397.    10581.               0
#  2 0382982            0     12253.               0
#  3 0348747         2422.    23991.               0
#  4 0224990         1696.     8203.            1811.

# Las tres preguntas que se hacen después de CADA join, en este orden:
#
#   1. ¿Cuántas filas hay?         nrow() antes y después
#   2. ¿Qué se quedó afuera?       anti_join() en las dos direcciones
#   3. ¿Aparecieron NA nuevos?     colSums(is.na())
#
# Y la regla que las resume: un join que no se verificó no está terminado.

#| nota
# Cerrar diciendo qué queda pendiente. Este pipeline está escrito una vez, para
# un levantamiento. La Sesión 5 lo convierte en funciones y la Sesión 6 lo corre
# sobre varios levantamientos con map(). Lo que hoy son 40 líneas sueltas, en
# tres semanas será una función de diez.
#| fin
