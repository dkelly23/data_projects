# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_03.R
# Objetivo:       Alcanzar fluidez con dplyr: traducir una pregunta sobre un tibble en
#                 una secuencia de verbos conectados por el pipe.
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
# BLOQUE DE EXPOSICIÓN — 1:30 hr. Es el bloque más corto del curso, y el reparto
# está apretado a propósito:
#
#   El sistema tidyverse       10 min
#   El pipe y el marcador       7 min
#   Los seis verbos            48 min   <- el núcleo de la sesión
#   Helpers                    10 min
#   NSE                        10 min
#   Cierre                      5 min
#
# Cada verbo se ve en dos pasos, en este orden y sin excepción: primero la
# NOTACIÓN BASE —el esqueleto de la llamada, con un solo ejemplo— y después los
# ARGUMENTOS Y HELPERS. Las diapositivas están armadas con ese mismo par, así
# que conviene no adelantar los helpers mientras se explica la notación.
#
# La segunda mitad de la sesión es código en vivo (ejercicios_03.R), así que
# aquí NO se agota el tema: se instala el vocabulario y se deja el uso para la
# práctica. Si un verbo se lleva más tiempo del previsto, el que se recorta es
# select() —los helpers se reconocen solos— y nunca group_by().
#
# Todo corre sobre las tres tablas de la EIGH, ya conocidas de la Sesión 2. La
# importación va en el preámbulo para no gastar minutos en ella: los estudiantes
# la escribieron completa la semana pasada.
#| fin

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola

# Paquetes de la sesión
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(tidyverse)

# Las tres tablas de la EIGH, leídas como quedaron al cierre de la Sesión 2. Las
# rutas son relativas a la raíz del proyecto: esto exige el .Rproj abierto.
hogares = read_csv("files/eigh_hogares.csv", show_col_types = FALSE)

personas = read_delim("files/eigh_personas.txt", delim = "|",
    na = c("", "n.d.", "999"),
    col_types = cols(folioviv = col_character(), ing_trab = col_double()))

gastos = read_csv2("files/eigh_gastos.csv", show_col_types = FALSE)


# CODIGO ______________________________________________________________________

# EL SISTEMA TIDYVERSE _________________________________________________________

## Carga del ecosistema --------------------------------------------------------=

# R base creció por acumulación: aggregate(), merge(), reshape() y subset() se
# escribieron en momentos distintos y no coinciden ni en el orden de los
# argumentos ni en lo que devuelven. El tidyverse es un conjunto de paquetes
# diseñados en conjunto sobre tres acuerdos:
#
#   1. El primer argumento de toda función es la tabla. Por eso el pipe funciona
#      siempre, sin marcador.
#   2. Lo que entra es un tibble y lo que sale es un tibble.
#   3. Las columnas se nombran sin comillas y sin $, con la misma sintaxis en
#      todos los paquetes.
#
# La consecuencia práctica: aprender dplyr es aprender la mitad de tidyr,
# stringr y purrr.

# El paquete tidyverse no contiene código propio. Es un cargador: su trabajo es
# adjuntar los nueve paquetes centrales de una sola vez.
tidyverse_packages()

# El mensaje de arranque tiene dos mitades y las dos se leen. La primera declara
# las versiones cargadas; la segunda, los nombres que quedaron enmascarados.
library(tidyverse)

# A partir de la carga, filter() es el verbo de dplyr y ya no la función de
# series de tiempo de stats. Gana el paquete cargado más tarde.
tidyverse_conflicts()

# Cuando hace falta la versión enmascarada se pide con su prefijo:
#   stats::filter(x, rep(1/3, 3))

# readxl, haven y dbplyr se instalan con el tidyverse pero NO se cargan con él:
# hay que pedirlos aparte. Por eso la Sesión 2 cargaba readxl explícitamente.

#| nota
# Preguntar aquí quién vio el mensaje de conflictos la semana pasada y lo leyó.
# Nadie. Es el punto: el mensaje no es ruido de arranque, es la única constancia
# de que dos funciones distintas comparten nombre en la sesión.
#| fin

# Convención del curso: una sola línea en el preámbulo.
#   pacman::p_load(tidyverse)


## Tidy data -------------------------------------------------------------------=

# Recordatorio de la Sesión 2, porque todo lo que sigue lo presupone: una tabla
# tidy tiene una variable por columna, una observación por fila y un valor por
# celda. Los verbos de dplyr están escritos para esa forma. Sobre una tabla que
# no la cumple, corren igual y responden otra pregunta.

# La pregunta previa a cualquier verbo es cuál es la unidad de observación.
hogares |> glimpse()     # una vivienda por fila
personas |> glimpse()    # una persona por fila
gastos |> glimpse()      # una combinación de hogar y rubro por fila

#| nota
# Insistir en que "el ingreso medio" significa cosas distintas en hogares y en
# personas, y que el verbo no lo va a advertir. Es la única línea de defensa que
# tienen contra un resultado plausible y equivocado.
#| fin


# EL PIPE ______________________________________________________________________

## El pipe nativo --------------------------------------------------------------=

# El |> es parte del lenguaje desde R 4.1. Toma lo de la izquierda y lo inserta
# como primer argumento de la llamada de la derecha. Ya se usó en la S2, y con
# el tidyverse basta siempre: el primer argumento de todo verbo es la tabla.
hogares |> filter(entidad == "09") |> nrow()


## El marcador de posición -----------------------------------------------------=

# Las funciones ajenas al tidyverse no siguen ese acuerdo. lm() recibe la
# fórmula primero y los datos después, así que hay que decir DÓNDE va la tabla.
hogares |> lm(ing_cor ~ tot_integ, data = _) |> coef()

# Dos condiciones, y las dos dan error de sintaxis si se incumplen. Descomentar
# en clase:
#
#   1. El marcador va en un argumento CON NOMBRE.
# hogares |> lm(ing_cor ~ tot_integ, _)
#
#   2. Aparece UNA SOLA VEZ por llamada.
# hogares |> merge(_, _, by = "folioviv")

# Y el lado derecho tiene que ser una llamada, con paréntesis:
# hogares |> nrow

#| nota
# No abrir la comparación con %>%. Basta con decir que en material anterior a
# 2021 el pipe se escribe así, que hace lo mismo y que su marcador es el punto.
# Quien pregunte por las diferencias finas se lleva la respuesta en el pasillo:
# en clase no rinde, y la sesión no tiene minutos que regalar.
#| fin


# LOS SEIS VERBOS ______________________________________________________________

# Cada verbo hace una sola cosa, recibe un tibble como primer argumento y
# devuelve un tibble. Esa firma común es lo que permite encadenarlos sin límite.
#
#   filter()      conserva filas según una condición
#   arrange()     reordena filas
#   select()      conserva, descarta o reordena columnas
#   mutate()      agrega o modifica columnas
#   summarize()   colapsa la tabla a un resumen
#   group_by()    fija el contexto de grupo para los dos anteriores

# Antes de verlos por separado, conviene ver por qué existen. La pregunta es:
# ingreso per cápita medio por entidad, en localidades urbanas.

# En R base la respuesta existe, repartida en cuatro objetos y tres notaciones:
sub = hogares[hogares$tam_loc %in% c(1, 2) & !is.na(hogares$ing_cor), ]
sub$ing_pc = sub$ing_cor / sub$tot_integ
agg = aggregate(ing_pc ~ nom_ent, data = sub, FUN = mean)
agg[order(-agg$ing_pc), ]

# En dplyr es una sola expresión, y cada línea nombra el paso que ejecuta:
hogares |>
    filter(tam_loc %in% c(1, 2), !is.na(ing_cor)) |>
    mutate(ing_pc = ing_cor / tot_integ) |>
    group_by(nom_ent) |>
    summarize(ing_pc_medio = mean(ing_pc)) |>
    arrange(desc(ing_pc_medio))

#| nota
# Correr las dos y dejar los resultados a la vista. Son idénticos. El argumento
# no es que dplyr pueda más: es que la segunda versión se lee en voz alta y la
# primera no. Y el objeto intermedio `sub` sigue en el entorno, sucio, mientras
# que la cadena no dejó nada.
#| fin


## filter(): notación base -----------------------------------------------------=

#     filter(datos, condición)
#
# Conserva las filas que cumplen la condición. La columna se nombra sin comillas
# y sin $. Salen las mismas columnas y menos filas.
hogares |> filter(entidad == "09")

# Es la traducción directa de la indexación lógica de la S2, sin repetir el
# nombre de la tabla dentro de la condición.
hogares[hogares$entidad == "09", ]


## filter(): argumentos y helpers ----------------------------------------------=

# Las condiciones se escriben como argumentos sucesivos, separados por coma, y
# se combinan con Y.
hogares |> filter(entidad == "09", tot_integ >= 4)

# La coma y el & producen el mismo resultado; la coma se lee mejor cuando las
# condiciones son varias y largas.
hogares |> filter(entidad == "09" & tot_integ >= 4)

# Los operadores son los de la S2. dplyr agrega dos helpers que evitan
# escribirlos a mano:
hogares |> filter(entidad %in% c("09", "20"))    # pertenencia a un conjunto
hogares |> filter(between(tot_integ, 2, 4))      # rango cerrado, inclusivo
hogares |> filter(tam_loc == 1 | tam_loc == 2)   # disyunción
hogares |> filter(!is.na(ing_cor))               # negación

# Un error que no es error de sintaxis y no filtra lo que parece: compara
# elemento contra elemento reciclando el vector. Para pertenencia, siempre %in%.
hogares |> filter(tam_loc == c(1, 2)) |> nrow()
hogares |> filter(tam_loc %in% c(1, 2)) |> nrow()


### Los dos errores al escribirlo ----

# El primero es la confusión entre asignación y comparación, y dplyr lo
# diagnostica con nombre y apellido. Descomentar en clase:
# hogares |> filter(entidad = "09")

# El segundo es el clásico, y aparece cuando dplyr no está cargado o cuando otro
# paquete lo enmascaró. filter() resuelve entonces a la función de series de
# tiempo de stats, que evalúa sus argumentos de forma normal y no sabe nada de
# las columnas de la tabla:
#
#   hogares |> filter(entidad == "09")
#   Error : objeto 'entidad' no encontrado
#
# El mensaje señala la columna, y el problema es el paquete. El diagnóstico es
# preguntar de dónde salió la función:
find("filter")

# Con el tidyverse cargado devuelve "package:dplyr" primero y "package:stats"
# después. Si devuelve solo stats, falta la carga.

#| nota
# Este error es el que más consultas genera en el semestre, y siempre llega
# descrito como "no encuentra mi columna". Vale la pena hacerlo en vivo: correr
# find("filter") con el tidyverse puesto, y contar que basta cargar otro paquete
# encima para volver al mensaje de arriba. El reflejo que hay que instalar es
# leer el mensaje de conflictos al cargar, no el de la columna al fallar.
#| fin


### El filtro que no avisa ----

# El tercer error es silencioso. Una condición sobre una columna con faltantes
# devuelve NA, y filter() descarta todo lo que no evalúa a TRUE.
hogares |> filter(ing_cor > 50000) |> nrow()
hogares |> filter(ing_cor <= 50000) |> nrow()
hogares |> filter(is.na(ing_cor)) |> nrow()

# 479 + 303 = 782, no 800. Los 18 hogares sin ingreso declarado no están en
# ninguno de los dos resultados. Cuando el faltante es parte de la pregunta, hay
# que pedirlo explícitamente:
hogares |> filter(ing_cor > 50000 | is.na(ing_cor)) |> nrow()

#| nota
# Preguntar en voz alta cuánto suman 479 y 303 ANTES de correr la tercera línea.
# La respuesta esperada es 800 y no lo es: ahí se instala la idea.
#| fin


## arrange(): notación base ----------------------------------------------------=

#     arrange(datos, columna)
#
# Reordena las filas sin agregar ni quitar ninguna. El defecto es ascendente.
hogares |> arrange(ing_cor) |> select(folioviv, nom_ent, ing_cor)

# Es el único verbo que no cambia el contenido de la tabla, solo el orden en que
# se mira. Por eso suele ir al final de la cadena.


## arrange(): argumentos y helpers ---------------------------------------------=

# desc() no es un argumento sino una función que envuelve a la columna: se puede
# aplicar a unas llaves y a otras no.
hogares |> arrange(desc(ing_cor))

# Las llaves se leen de izquierda a derecha, y la segunda solo interviene donde
# la primera empata.
hogares |> arrange(entidad, desc(ing_cor))

# Sobre datos agrupados, arrange() IGNORA los grupos por defecto. Para ordenar
# dentro de cada uno se pide explícitamente:
hogares |>
    group_by(nom_ent) |>
    arrange(desc(ing_cor), .by_group = TRUE)

# Los faltantes no se ordenan: van al final en ascendente Y en descendente. NA
# no es un valor grande ni pequeño, es un valor desconocido, y dplyr lo aparta
# en vez de inventarle una posición.
hogares |> arrange(desc(ing_cor)) |> select(folioviv, ing_cor) |> tail(3)


## select(): notación base -----------------------------------------------------=

#     select(datos, columnas)
#
# Las columnas se nombran sin comillas, igual que en la condición de filter(). El
# orden en que se nombran es el orden del resultado, así que select() también
# reordena.
hogares |> select(folioviv, nom_ent, ing_cor)
hogares |> select(ing_cor, folioviv)

# rename() es el caso particular que cambia el nombre y conserva todo lo demás.
# El nombre NUEVO va a la izquierda, como en cualquier asignación.
hogares |> rename(nombre_entidad = nom_ent)


## select(): argumentos y helpers ----------------------------------------------=

# Dos formas de nombrar varias columnas sin listarlas:
hogares |> select(folioviv:tam_loc)         # rango de posiciones
hogares |> select(!c(nom_ent, factor))      # todas menos estas

# Una encuesta real trae doscientas columnas y nombres construidos por
# convención. Nombrarlas una por una no escala, y para eso están los helpers.
hogares |> select(starts_with("ing"))       # el nombre empieza con
hogares |> select(ends_with("_mon"))        # el nombre termina en
hogares |> select(contains("_"))            # el nombre contiene
hogares |> select(where(is.numeric))        # la columna cumple una condición
hogares |> select(folioviv, everything())   # el folio primero, el resto después

# where() recibe una FUNCIÓN, no un resultado: se escribe is.numeric, sin
# paréntesis. dplyr la aplica a cada columna y conserva las que dan TRUE.


## mutate(): notación base -----------------------------------------------------=

#     mutate(datos, nombre = expresión)
#
# La expresión se calcula sobre el vector completo, fila por fila, con las
# columnas que ya existen. La nueva se agrega al final de la tabla.
hogares |> mutate(ing_pc = ing_cor / tot_integ)

# Si el nombre asignado YA EXISTE, la columna se sobrescribe. Es la forma de
# corregir una variable sin crear una copia.
hogares |> mutate(ing_cor = ing_cor / 1000)


## mutate(): argumentos y helpers ----------------------------------------------=

# Las asignaciones se evalúan en orden y cada una ve a la anterior: no hace
# falta un mutate() por columna.
hogares |>
    mutate(
        ing_pc   = ing_cor / tot_integ,
        gasto_pc = gasto_mon / tot_integ,
        ahorro   = 1 - gasto_pc / ing_pc,
        .keep = "used"
    )

# El faltante viaja por el cálculo hasta donde llega la columna que lo contiene:
# el hogar sin ingreso da NA en ing_pc y en ahorro, pero no en gasto_pc.

# Tres argumentos que empiezan con punto, para no confundirse con una columna:
hogares |> mutate(ing_pc = ing_cor / tot_integ, .keep = "used")
hogares |> mutate(ing_pc = ing_cor / tot_integ, .after = ing_cor)
hogares |> mutate(ing_rel = ing_cor / mean(ing_cor, na.rm = TRUE), .by = nom_ent)


### if_else() ----

# El helper de dos ramas: la condición, el valor si se cumple y el valor si no.
# El uso más frecuente en encuestas es convertir un código de no respuesta en NA.
hogares |>
    mutate(tam_loc = if_else(tam_loc == 9, NA, tam_loc)) |>
    count(tam_loc)

# ifelse() de base hace lo mismo y a veces pierde el tipo: un Date sale como
# número. if_else() exige que las dos ramas sean del mismo tipo y falla en voz
# alta cuando no lo son, que es el momento correcto para enterarse.
# hogares |> mutate(x = if_else(tam_loc == 9, "sin dato", tam_loc))


### case_when() ----

# El helper de más de dos ramas, evaluadas en orden: se toma la PRIMERA que se
# cumple. Por eso el orden decide el resultado y las condiciones no necesitan
# excluirse entre sí.
hogares |>
    mutate(
        estrato = case_when(
            ing_cor <  30000  ~ "bajo",
            ing_cor < 100000  ~ "medio",
            ing_cor >= 100000 ~ "alto"
        )
    ) |>
    count(estrato)

# Los 18 hogares sin ingreso no caen en ninguna rama y reciben NA. Para
# asignarles una categoría explícita:
hogares |>
    mutate(
        estrato = case_when(
            is.na(ing_cor)    ~ "sin dato",
            ing_cor <  30000  ~ "bajo",
            ing_cor < 100000  ~ "medio",
            .default = "alto"
        )
    ) |>
    count(estrato)


## summarize(): notación base --------------------------------------------------=

#     summarize(datos, nombre = función(columna))
#
# La notación es la de mutate(), con una diferencia: la expresión tiene que
# devolver UN SOLO VALOR. El resultado es una tabla de una fila.
hogares |> summarize(ing_medio = mean(ing_cor, na.rm = TRUE))

# Es el único verbo que colapsa la tabla de forma deliberada: 800 filas entran,
# una sale. Sirven mean(), median(), sd(), min(), max(), sum() y cualquier otra
# función que devuelva un escalar.


## summarize(): argumentos y helpers -------------------------------------------=

hogares |>
    summarize(
        hogares   = n(),
        entidades = n_distinct(entidad),
        ing_min   = min(ing_cor, na.rm = TRUE),
        ing_max   = max(ing_cor, na.rm = TRUE)
    )

# n() no recibe argumentos: cuenta las filas del contexto en el que se evalúa.
# n_distinct() es la forma corta de length(unique(x)). Las dos solo tienen
# sentido dentro de un verbo: fuera de él no hay contexto del cual contar filas.

# .by resume por grupo sin group_by(), y devuelve el resultado desagrupado.
hogares |> summarize(ing_medio = mean(ing_cor, na.rm = TRUE), .by = nom_ent)


### El resumen que sale NA ----

# El error más frecuente de la sesión, y no produce ningún mensaje:
hogares |> summarize(ing = mean(ing_cor))

# Dieciocho hogares de ochocientos no declararon ingreso. Basta uno para que el
# promedio de la columna sea NA: es la propagación de la S2, dentro de un verbo.
hogares |> summarize(ing = mean(ing_cor, na.rm = TRUE))

#| nota
# No dejar que na.rm = TRUE se vuelva un reflejo. El argumento no arregla el
# dato: cambia el denominador y calcula sobre los 782 que sí respondieron. Puede
# ser lo correcto o no serlo, pero es una decisión. La forma de tomarla es mirar
# antes cuántos faltantes hay, que es lo que hicieron con colSums(is.na()).
#| fin

# La versión que deja constancia de sobre cuántos se calculó:
hogares |>
    summarize(
        hogares   = n(),
        sin_dato  = sum(is.na(ing_cor)),
        ing_medio = mean(ing_cor, na.rm = TRUE)
    )


## group_by(): notación base ---------------------------------------------------=

#     group_by(datos, columna)
#
# No transforma la tabla: MARCA el contexto. Los verbos posteriores dejan de
# operar sobre las 800 filas y pasan a operar una vez por grupo.
hogares |>
    group_by(nom_ent) |>
    summarize(ing_medio = mean(ing_cor, na.rm = TRUE))

# Una fila por grupo, y la columna de agrupación primero. Es la combinación que
# responde casi toda pregunta comparativa: cuánto vale esto, por cada cuál.


## group_by(): argumentos y helpers --------------------------------------------=

# Con dos variables los grupos son las combinaciones observadas, y summarize()
# consume la ÚLTIMA.
hogares |>
    group_by(nom_ent, tam_loc) |>
    summarize(ing_medio = mean(ing_cor, na.rm = TRUE))

# El mensaje avisa de algo que se paga después: el resultado SIGUE agrupado por
# nom_ent, y todo verbo posterior operará por entidad aunque nada lo diga.
resumen = hogares |> group_by(nom_ent, tam_loc) |> summarize(n = n())

group_vars(resumen)

# Esta línea no da el total, da un total por entidad:
resumen |> summarize(total = sum(n))

# Tres formas de evitarlo:
hogares |> group_by(nom_ent, tam_loc) |> summarize(n = n(), .groups = "drop")
hogares |> group_by(nom_ent, tam_loc) |> summarize(n = n()) |> ungroup()
hogares |> summarize(n = n(), .by = nom_ent)

# Regla práctica: toda cadena que agrupa, desagrupa antes de asignar el
# resultado a un nombre. Un tibble agrupado guardado en el entorno es una bomba
# de tiempo, porque el código que lo use después estará escrito como si no lo
# estuviera. group_vars() dice si quedó algo puesto.


### group_by() con mutate() ----

# summarize() colapsa; mutate() sobre datos agrupados calcula el resumen del
# grupo y lo reparte de vuelta en cada fila. Con eso se normaliza una variable
# contra su propio grupo.
hogares |>
    group_by(nom_ent) |>
    mutate(ing_rel = ing_cor / mean(ing_cor, na.rm = TRUE)) |>
    ungroup() |>
    select(folioviv, nom_ent, ing_cor, ing_rel)

# El primer hogar gana 53% del ingreso medio de Querétaro. Sin agrupar, la misma
# línea lo compararía contra el promedio nacional, que es otra pregunta.
hogares |>
    mutate(ing_rel = ing_cor / mean(ing_cor, na.rm = TRUE)) |>
    select(folioviv, nom_ent, ing_cor, ing_rel)


# HELPERS Y NSE ________________________________________________________________

## count(), distinct(), slice_*() ----------------------------------------------=

# count() es group_by() seguido de summarize(n = n()), en una línea. Suele ser
# la primera llamada sobre una tabla desconocida.
gastos |> count(clave, sort = TRUE)
hogares |> count(nom_ent)
hogares |> count(nom_ent, tam_loc)

# distinct() devuelve las combinaciones únicas sin contarlas. Sirve para
# verificar que dos columnas se corresponden.
hogares |> distinct(entidad, nom_ent)

# Seis claves y seis nombres: la correspondencia es uno a uno, como debe ser. Si
# devolviera siete filas, alguna entidad estaría escrita de dos maneras, y eso
# rompería el join de la Sesión 4.

# n_distinct() responde lo mismo con un número.
gastos |> summarize(hogares = n_distinct(folioviv), rubros = n_distinct(clave))

# slice_*() extrae filas por posición o por valor extremo.
hogares |> slice_head(n = 5)              # las primeras cinco
hogares |> slice_sample(n = 5)            # cinco al azar
hogares |> slice_max(ing_cor, n = 5)      # las cinco mayores
hogares |> slice_min(ing_cor, n = 5)      # las cinco menores

# Combinado con group_by() responde algo que arrange() no alcanza: el extremo
# DENTRO de cada grupo.
hogares |>
    group_by(nom_ent) |>
    slice_max(ing_cor, n = 1) |>
    select(nom_ent, folioviv, ing_cor)

# slice_max(x, n = 1) no es filter(x == max(x)): el primero devuelve una fila
# aunque haya empates, y no se rompe si la columna tiene faltantes.


## Non-Standard Evaluation -----------------------------------------------------=

# ing_cor no es un objeto del entorno. Suelto en la consola da error, y adentro
# de filter() se resuelve sin comillas y sin $. Descomentar la primera:
# ing_cor
hogares |> filter(ing_cor > 100000) |> nrow()

# Los verbos no reciben el VALOR del argumento sino la EXPRESIÓN sin evaluar, y
# la evalúan después en un entorno donde las columnas existen como si fueran
# objetos. Eso es data masking, la forma de NSE que usa el tidyverse.

# Lo que se gana es menos ruido. Estas dos líneas son la misma condición:
hogares |> filter(entidad == "09", tot_integ >= 4) |> nrow()
hogares[hogares$entidad == "09" & hogares$tot_integ >= 4, ] |> nrow()

### Lo que se paga ----

# La ambigüedad entre un nombre de columna y un nombre del entorno. Si existe un
# objeto llamado igual que una columna, gana la columna.
entidad = "09"
hogares |> filter(entidad == entidad) |> nrow()

# Los dos lados de la comparación son la columna, así que la condición es TRUE
# en las 800 filas. No hay error ni advertencia: solo un filtro que no filtró.

# Dos pronombres resuelven la ambigüedad diciendo de dónde sale cada nombre.
hogares |> filter(.data$entidad == .env$entidad) |> nrow()

# Regla práctica: nombrar los objetos del entorno de modo que no colisionen
# —ent_objetivo, no entidad—. Los pronombres son la salida cuando la colisión ya
# existe, sobre todo dentro de una función.
rm(entidad)

### Lo que se rompe en la Sesión 5 ----

# El mismo mecanismo que hace legible una cadena impide envolverla en una
# función. Este intento parece razonable y no funciona:
resumen_por = function(datos, variable) {
    datos |>
        group_by(variable) |>
        summarize(ing_medio = mean(ing_cor, na.rm = TRUE))
}

# Descomentar en clase:
# resumen_por(hogares, nom_ent)

# group_by() no evalúa `variable`: busca una columna con ese nombre literal. El
# argumento nunca llega a leerse como lo que contiene.

# La solución se llama tunneling y se escribe {{ variable }}. Requiere entender
# antes cómo se evalúan los argumentos en R, que es material de la Sesión 5. Por
# ahora basta reconocer el síntoma: "Column ... is not found" al pasar un nombre
# de columna como argumento.

#| nota
# No resolverlo aquí, ni aunque alguien pregunte. Escribir {{ }} en el pizarrón
# sin explicarlo es peor que no mencionarlo: la S5 dedica media hora a por qué
# funciona, y la respuesta anticipada la convierte en un truco memorizado.
#| fin


# CIERRE _______________________________________________________________________

# El orden de los verbos casi siempre es el mismo:
#
#   "solo los hogares que..."            filter()
#   "por cada entidad", "según sexo"     group_by()
#   "el promedio", "cuántos"             summarize() con n(), mean(), sum()
#   "per cápita", "como proporción de"   mutate()
#   "los cinco mayores"                  arrange() + slice_max()
#   "cuántos hay de cada"                count()
#
# Punto de partida: filtrar -> calcular -> agrupar -> resumir -> ordenar.
# Filtrar primero abarata todo lo que sigue; ordenar al final es lo único que no
# cambia el contenido del resultado.

# Cómo se depura una cadena: por partes. Se corre hasta el primer pipe, se mira
# el resultado, se agrega el paso siguiente. El error casi nunca está donde
# revienta, está en el eslabón anterior, que devolvió algo distinto de lo que se
# creía.
hogares |> filter(tam_loc %in% c(1, 2), !is.na(ing_cor))

hogares |>
    filter(tam_loc %in% c(1, 2), !is.na(ing_cor)) |>
    mutate(ing_pc = ing_cor / tot_integ)

hogares |>
    filter(tam_loc %in% c(1, 2), !is.na(ing_cor)) |>
    mutate(ing_pc = ing_cor / tot_integ) |>
    group_by(nom_ent) |>
    summarize(ing_pc_medio = mean(ing_pc)) |>
    arrange(desc(ing_pc_medio))

#| nota
# Cerrar con esta cadena, que es la misma del arranque de la sección. Sirve para
# que el bloque de práctica empiece con la sensación de que ya se escribió una
# entera. Los verbos operan sobre UNA tabla: la Sesión 4 agrega los joins.
#| fin
