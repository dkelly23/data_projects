# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_02.R
# Objetivo:       Extender el vocabulario más allá de los vectores atómicos e
#                 importar, verificar y explorar los primeros datos reales.
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
# BLOQUE DE EXPOSICIÓN — 1:45 hr. Reparto sugerido:
#
#   Nombres y estructuras   25 min
#   Tidy y el pipe          15 min
#   Importación             30 min   <- el núcleo de la sesión
#   Indexación              20 min
#   Coerción y faltantes    15 min
#   Exploración             10 min
#
# El orden importa: primero se lee una tabla de verdad y después se aprende a
# operar sobre ella. Las secciones de indexación en adelante trabajan sobre los
# 800 hogares que quedaron en memoria, no sobre la tabla de seis filas.
#
# El script se corre con el proyecto abierto (curso-ppd.Rproj), de modo que las
# rutas relativas apunten a files/ y docs/. Los archivos de la EIGH se generan
# con slides/semana_02/code/generar_data.R y ya vienen en el zip.
#
# La sección de importación está construida para leer MAL primero y bien
# después. Vale la pena resistir la tentación de saltarse el primer paso: el
# punto de la sesión es que el error no se anuncia solo.
#| fin

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola

# Paquetes de la sesión
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(readr, readxl, tibble)


# CODIGO ______________________________________________________________________

# ESTRUCTURAS DE DATOS ________________________________________________________

## Nombres válidos -----------------------------------------------------------=

# Antes de crear objetos conviene saber cómo se pueden llamar. Un nombre
# sintáctico empieza con una letra, contiene solo letras, números, punto y guion
# bajo, y no coincide con una palabra reservada del lenguaje.
ing_2024 = 1

# R distingue mayúsculas: este es otro objeto, no el mismo.
Ing_2024 = 2

# Las dos líneas siguientes no corren. Descomentar en clase para ver el error:
# 2024_ing = 1     # empieza con número
# ing 2024 = 1     # contiene un espacio

# Los encabezados de un archivo los escribió alguien más, y no tienen por qué
# cumplir esas reglas. `make.names()` sanea un nombre cualquiera hasta volverlo
# sintáctico: es lo que hace read.csv() al importar, y de ahí salen los nombres
# con puntos que se ven en código ajeno.
make.names("Entidad federativa")

# readr no lo hace: conserva el nombre original, y para usarlo se escribe entre
# acentos graves.
catalogo = list(`Entidad federativa` = "Oaxaca")
catalogo$`Entidad federativa`

#| nota
# Aquí va la regla que no está en las reglas: no nombrar un objeto como una
# función que ya existe (`data`, `mean`, `df`, `c`, `T`). El código sigue
# corriendo y falla mucho después, con un mensaje que no menciona el nombre.
#| fin


## Listas --------------------------------------------------------------------=

# Un vector atómico solo admite un tipo. Un registro de encuesta mezcla un folio
# de texto, un número de integrantes y un ingreso decimal, así que no cabe:
c("0100012", 3, 48200)

# La lista es el contenedor heterogéneo: cada elemento conserva su tipo y su
# longitud.
resultado = list(
    modelo    = "Regresión lineal",
    n         = 800L,
    coefs     = c(intercepto = 2.4, ing_cor = -0.13),
    convergio = TRUE
)

typeof(resultado)
length(resultado)
str(resultado)

### Acceso ----

# Tres operadores, dos resultados distintos. `[` preserva la clase del objeto;
# `[[` y `$` extraen el contenido que está adentro.
resultado["coefs"]
resultado[["coefs"]]
resultado$coefs

class(resultado["coefs"])
class(resultado[["coefs"]])

# La consecuencia práctica: una lista de un elemento no se puede promediar. El
# error no menciona al operador, que es lo que lo vuelve difícil de diagnosticar.
# mean(resultado["coefs"])
mean(resultado[["coefs"]])


## DataFrames y tibbles ------------------------------------------------------=

# Un DataFrame es una lista de vectores de igual longitud, con una clase encima.
# Todo lo que aplica a las listas aplica también a las tablas.
#
# Esta es la tabla de hogares de la EIGH, reducida a seis filas para tenerla a
# la vista. La completa se lee más adelante, desde files/.
hogares_df = data.frame(
    folioviv  = c("0100012", "0100027", "0100034", "0100041", "0100056", "0100063"),
    entidad   = c("09", "16", "09", "22", "16", "31"),
    tam_loc   = c(1, 3, 1, 2, 9, 4),      # 1 a 4; 9 = no especificado
    tot_integ = c(3, 5, 1, 4, 2, 6),
    ing_cor   = c(48200, 31500, 22800, 76400, 19900, 54100),
    gasto_mon = c(41300, 33800, 18500, 59200, 24600, 47700)
)

# El tibble es la versión del tidyverse. No es una estructura nueva: hereda la
# clase data.frame, y lo que cambia es el comportamiento.
hogares = tibble(
    folioviv  = c("0100012", "0100027", "0100034", "0100041", "0100056", "0100063"),
    entidad   = c("09", "16", "09", "22", "16", "31"),
    tam_loc   = c(1, 3, 1, 2, 9, 4),      # 1 a 4; 9 = no especificado
    tot_integ = c(3, 5, 1, 4, 2, 6),
    ing_cor   = c(48200, 31500, 22800, 76400, 19900, 54100),
    gasto_mon = c(41300, 33800, 18500, 59200, 24600, 47700)
)

class(hogares)

# Las funciones de inspección son las mismas para ambos:
nrow(hogares)
ncol(hogares)
dim(hogares)
names(hogares)
head(hogares)

### Las diferencias que importan ----

# 1. Impresión. El data.frame vuelca el objeto completo; el tibble muestra diez
#    filas, las columnas que caben, y el tipo de cada una.
hogares_df
hogares

# 2. Partial matching. El data.frame adivina el nombre incompleto y devuelve la
#    columna en silencio. El tibble avisa que no existe.
hogares_df$ing
hogares$ing

# 3. Subsetting que no simplifica. La misma expresión devuelve un vector en un
#    caso y una tabla de una columna en el otro.
class(hogares_df[, "ing_cor"])
class(hogares[, "ing_cor"])

# 4. Conversión automática de texto a factor: era el comportamiento de
#    data.frame() hasta R 4.0. Ya no ocurre, pero explica mucho código anterior
#    a 2020 lleno de stringsAsFactors = FALSE.

# La convención del curso es tibble, y no hay que pedirlo: readr y readxl ya
# devuelven tibbles.

### Inspección ----

# Cuatro funciones que responden preguntas distintas:
str(hogares)       # estructura: clase, dimensiones y tipo de cada columna
glimpse(hogares)   # una línea por columna; sirve con tablas anchas
summary(hogares)   # descriptivas por columna

# View() abre la tabla en el visor del IDE. Sirve para mirar, no deja rastro en
# el script y no va dentro de un flujo automatizado.
# View(hogares)


## Datos tidy ----------------------------------------------------------------=

# Una misma información admite formas distintas. La forma tidy cumple tres
# reglas: cada variable es una columna, cada observación una fila y cada valor
# una celda. No es una preferencia estética: las funciones de R asumen esa
# forma. table() espera una columna por variable, boxplot(y ~ g) espera la
# variable y el grupo en columnas distintas, cor() espera cada variable en la
# suya. Cuando la tabla no es tidy, cada operación exige un rodeo.

# La pregunta que hay que hacerle a una tabla es qué es una observación aquí.
# En la EIGH la respuesta cambia por tabla: en hogares es una vivienda, en
# personas una persona, en gastos una combinación de hogar y rubro. Cada una es
# tidy a su propio nivel.

# La tabla de gastos está en formato largo: una fila por hogar y rubro, con el
# rubro como valor de una columna. Se lee más adelante; así se ve:
#
#   folioviv   clave   gasto_tri   frecuencia
#   0773233    A002      5396.77            5
#   0773233    E001      3187.76            3
#
# Muchas encuestas la distribuyen en ancho, con una columna por rubro
# (gasto_A001, gasto_A002, ...). Ahí el rubro deja de ser un valor y se esconde
# en los nombres de las columnas. Ninguna de las dos está mal; son útiles para
# cosas distintas. Pero solo la larga permite agrupar por rubro sin escribir el
# nombre de cada columna. El reshape entre ambas es la Sesión 4.


## El pipe -------------------------------------------------------------------=

# El pipe nativo |> toma lo que está a su izquierda y lo inserta como primer
# argumento de la función que está a su derecha. Los demás argumentos se
# escriben normalmente en la llamada de la derecha.

# Estas dos líneas son la misma operación:
mean(hogares$ing_cor, na.rm = TRUE)
hogares$ing_cor |> mean(na.rm = TRUE)

# Requiere R 4.1 o superior, que es el requisito del curso. Y el lado derecho
# tiene que ser una llamada, con paréntesis: `x |> mean` es un error de
# sintaxis. Descomentar en clase para verlo:
# hogares$ing_cor |> mean

# En código ajeno se ve `%>%`, del paquete magrittr, que hace lo mismo y algo
# más. La convención del curso es el nativo; la diferencia se trata en la S3.

# ¿Cuándo conviene? Con una sola llamada no cambia nada, y f(x) suele leerse
# mejor. La diferencia aparece al anidar: las llamadas se escriben de adentro
# hacia afuera pero se leen al revés.
round(prop.table(table(hogares$tam_loc)), 3)

# Con el pipe, el orden de escritura y el de lectura coinciden:
hogares$tam_loc |> table() |> prop.table() |> round(3)

# Regla práctica: con dos o más llamadas anidadas, pipe; con una sola, la
# llamada directa. Y cuando la cadena deja de caber en la pantalla, conviene
# cortarla y darle nombre al resultado intermedio.

#| nota
# Las dos líneas de arriba usan `hogares`, que en este punto todavía es la tabla
# de seis filas construida a mano. Correrlas ahí es deliberado: el resultado no
# importa, importa comparar las dos formas de escribirlo. Los números de la
# diapositiva salen de la tabla completa, que se lee en la sección siguiente.
#| fin



# IMPORTACIÓN _________________________________________________________________

# Los archivos de la EIGH viven en files/ y de ahí no se mueven. Las rutas son
# relativas a la raíz del proyecto, así que esto exige tener abierto el .Rproj.
list.files("files")

## Archivos planos con readr -------------------------------------------------=

hogares = read_csv("files/eigh_hogares.csv")

# El bloque que imprime al leer es el primer control de calidad de la sesión:
# declara el delimitador detectado, el número de filas y el tipo asignado a cada
# columna. Se lee siempre, antes de escribir la línea siguiente.
spec(hogares)

# read.csv() de base hace lo mismo con otro comportamiento. La diferencia
# operativa no es la velocidad, sino que readr deja constancia de lo que decidió.
hogares_base = read.csv("files/eigh_hogares.csv")

class(hogares)
class(hogares_base)

# El identificador es el caso que más cuesta: readr reconoce el cero inicial y
# deja la columna como texto; read.csv() la lee como número y lo pierde. Un
# folio sin su cero ya no cruza con la tabla de personas, y el error no aparece
# hasta que se intenta el join.
hogares$folioviv[1]
hogares_base$folioviv[1]

# De aquí en adelante el curso usa el pipe donde las llamadas se anidan.


## Texto delimitado y archivos .txt ------------------------------------------=

# La extensión .txt no declara el formato: puede estar separado por tabuladores,
# por punto y coma o por barras verticales. El primer paso no es leerlo, es
# mirarlo. Dos preguntas: cuál es el separador y si la primera línea trae los
# nombres de las columnas.
readLines("files/eigh_personas.txt", n = 3)

# Leerlo como si fuera un CSV devuelve 2,606 filas y UNA sola columna: el
# delimitador equivocado no produce un error, produce una tabla inservible.
read_csv("files/eigh_personas.txt", show_col_types = FALSE)

# Con el delimitador identificado:
personas = read_delim("files/eigh_personas.txt", delim = "|")

# read_delim() es el lector general. Sin el argumento intenta adivinar el
# separador a partir de las primeras líneas.
read_delim("files/eigh_personas.txt", show_col_types = FALSE)

# read_csv() y read_tsv() son esa misma función con el delim ya fijado. La
# extensión del archivo no interviene en la elección: lo que decide es el
# contenido que mostró readLines().

### El separador decimal ----

# El software configurado en español exporta con punto y coma, porque la coma ya
# está ocupada como separador decimal. Así llegó la tabla de gastos.
readLines("files/eigh_gastos.csv", n = 3)

# Leerlo con read_csv() produce una sola columna de texto.
read_csv("files/eigh_gastos.csv", show_col_types = FALSE)

# read_csv2() fija las dos convenciones a la vez.
gastos = read_csv2("files/eigh_gastos.csv")

# Y cuando la combinación es otra, se declara explícitamente.
read_delim("files/eigh_gastos.csv", delim = ";", show_col_types = FALSE,
    locale = locale(decimal_mark = ",", grouping_mark = "."))


## Encoding y locale ---------------------------------------------------------=

# Un archivo de texto es una secuencia de bytes, y el encoding es la tabla que
# dice qué carácter representa cada byte. Cuando el lector usa una tabla distinta
# a la del generador, se rompen los acentos.
guess_encoding("files/eigh_hogares_latin1.csv")

# Leído como UTF-8, que es lo que readr asume por defecto:
roto = read_csv("files/eigh_hogares_latin1.csv", show_col_types = FALSE)
unique(roto$nom_ent)

# Leído declarando la codificación real:
bien = read_csv("files/eigh_hogares_latin1.csv", show_col_types = FALSE,
    locale = locale(encoding = "latin1"))
unique(bien$nom_ent)

# El problema está en la lectura, no en los datos: se resuelve con `locale`, una
# sola vez, y no con reemplazos de texto sobre la columna ya importada.


## Tipos declarados y problemas de lectura -----------------------------------=

# readr infiere el tipo de cada columna a partir de las primeras mil filas. El
# ingreso por trabajo trae "n.d." en algunas celdas, y basta eso para que toda la
# columna llegue como texto.
typeof(personas$ing_trab)

# Declarar el tipo convierte el problema silencioso en un registro consultable:
# el valor que no corresponde se vuelve NA y el incidente queda anotado.
forzada = read_delim("files/eigh_personas.txt", delim = "|",
    col_types = cols(folioviv = col_character(), ing_trab = col_double()))

problems(forzada)
nrow(problems(forzada))

# Declarar cómo se escribió la no respuesta lo resuelve de raíz. Ojo: el
# argumento `na` se aplica a TODAS las columnas del archivo, no solo a la que
# interesa, así que conviene revisar que ningún otro dato use esos códigos.
personas = read_delim("files/eigh_personas.txt", delim = "|",
    na = c("", "n.d.", "999"),
    col_types = cols(folioviv = col_character(), ing_trab = col_double()))

problems(personas)
colSums(is.na(personas))


## Hojas de cálculo con readxl -----------------------------------------------=

# Primera pregunta de cualquier hoja de cálculo: qué hojas contiene.
excel_sheets("files/eigh_catalogos.xlsx")

# El problema del formato es que la hoja mezcla los datos con su presentación:
# títulos, filas en blanco y notas al pie. Leerla completa arrastra todo eso.
read_excel("files/eigh_catalogos.xlsx", sheet = "entidades")

# El rango se acota de forma explícita.
entidades = read_excel("files/eigh_catalogos.xlsx", sheet = "entidades",
    range = "A4:B10")
entidades

# .xlsx guarda su propia codificación, así que aquí no hay problema de encoding.
# A cambio aparece el de las celdas con formato: una fecha o un porcentaje
# pueden llegar como número.


## Inspección post-importación -----------------------------------------------=

# Cinco verificaciones, siempre en este orden, inmediatamente después de leer.
# No producen resultados de análisis: producen la certeza de que el análisis se
# hará sobre lo que se cree.
hogares |> dim()                    # 1. ¿coincide con lo documentado?
hogares |> glimpse()                # 2. ¿los tipos son los correctos?
hogares |> summary()                # 3. ¿los rangos son plausibles?
hogares |> is.na() |> colSums()     # 4. ¿cuántos faltantes por columna?
hogares |> problems()               # 5. ¿hubo incidentes de lectura?

# Lo documentado está en docs/: el descriptor declara el tipo de cada variable y
# los códigos de no respuesta. La verificación es contra ese archivo, no contra
# la intuición.
descriptor = read_csv("docs/eigh_descriptor.csv", show_col_types = FALSE)
descriptor[descriptor$tabla == "hogares", ]

#| nota
# Ninguno de los errores de esta sección produce una falla al importar. Todos
# producen una tabla que se imprime sin quejarse. Por eso la verificación tiene
# que ser deliberada: no hay nada que avise.
#| fin


# INDEXACIÓN __________________________________________________________________

# Los ejemplos de aquí en adelante usan la tabla completa, la que quedó en
# memoria tras la importación.
ingresos = hogares$ing_cor
ingresos |> head()

## Formas de escribir el índice ----------------------------------------------=

# Posicional. R empieza a contar en 1, no en 0. La tercera posición es un hogar
# que no reportó ingreso: el NA ocupa lugar como cualquier otro valor.
ingresos[2]
ingresos[3]

# Por nombre, cuando el vector los tiene.
coefs = c(intercepto = 2.4, ing_cor = -0.13)
coefs["ing_cor"]

# Negativa: descarta en vez de seleccionar.
ingresos[-1]

# Lógica: un vector de TRUE/FALSE de la misma longitud. Es la forma que se usa
# para filtrar, y la condición se evalúa de manera vectorizada sobre los 800
# hogares. Conviene contar antes que imprimir.
sum(ingresos >= 40000, na.rm = TRUE)

# which() convierte la máscara lógica en las posiciones donde se cumple. Sirve
# cuando el interés no está en el valor sino en su ubicación.
which.max(ingresos)

# Y esa posición se usa sobre otra columna de la misma tabla:
hogares$folioviv[which.max(hogares$ing_cor)]

## Indexación de tablas ------------------------------------------------------=

# Sobre un objeto rectangular el índice tiene dos posiciones separadas por coma:
# [filas, columnas]. Dejar una vacía significa "todas".
hogares[3, ]
hogares[, "ing_cor"]
hogares[3, "ing_cor"]

# El patrón central: una condición lógica en la posición de las filas.
hogares[hogares$tot_integ >= 6, ] |> nrow()
hogares[hogares$tot_integ >= 6 & hogares$entidad == "16", ] |> nrow()

# Esta notación es correcta, pero obliga a repetir el nombre de la tabla en cada
# término y se vuelve ilegible en cuanto la condición crece. Es exactamente el
# problema que resuelve dplyr en la Sesión 3.

## Asignación por subsetting -------------------------------------------------=

# Cualquier expresión de indexación puede recibir una asignación, y modifica
# únicamente las posiciones seleccionadas.
ingresos[2] = 32000
ingresos[ingresos > 1e7] = NA
ingresos |> head()

# Sobre una tabla, el mismo mecanismo crea o reemplaza columnas. La corrección
# se escribe sobre una copia: si resulta equivocada, la tabla cruda sigue ahí.
limpia = hogares
limpia$deficit = limpia$gasto_mon > limpia$ing_cor
limpia$tam_loc[limpia$tam_loc == 9] = NA
limpia$tam_loc |> table(useNA = "ifany")

#| nota
# Recalcar: esto se escribe SIEMPRE sobre un objeto nuevo, nunca sobre la tabla
# recién importada. Cuando la corrección resulta equivocada, la única salida es
# volver a leer el archivo.
#| fin


# COERCIÓN Y VALORES FALTANTES ________________________________________________

## Coerción de tipos ---------------------------------------------------------=

# Un vector atómico admite un solo tipo. Al recibir tipos distintos R no falla:
# convierte todo al más general de los presentes.
c(TRUE, 1L)
c(1L, 2.5)
c(1, "a")
typeof(c(1, "a"))

# La jerarquía va en una sola dirección:
#   logical -> integer -> double -> character

### Del lógico al número ----

# La coerción que sí conviene aprovechar: TRUE vale 1 y FALSE vale 0.
deficit = hogares$gasto_mon > hogares$ing_cor

deficit |> sum(na.rm = TRUE)     # cuántos gastan más de lo que ingresan
deficit |> mean(na.rm = TRUE)    # qué proporción del total lo hace

# Y sobre una condición cualquiera, sin construir la columna:
mean(hogares$tam_loc == 9)     # qué fracción trae el código de no especificado

### Coerción explícita ----

# El caso recurrente en datos de encuesta: una columna numérica que llegó como
# texto, porque el archivo traía un guion o un "n.d." en alguna celda. Es
# exactamente lo que pasa con el ingreso por trabajo de la EIGH.
ing_trab = c("12500", "8500", "n.d.", "15300")
ing_trab |> as.numeric()

# La advertencia no es ruido: informa cuántos valores no pudieron convertirse.
# Si ese número no coincide con lo esperado, la columna traía algo más.
sum(is.na(as.numeric(ing_trab)))


## Valores faltantes ---------------------------------------------------------=

# NA no es cero ni cadena vacía: es un valor desconocido. De ahí se sigue su
# propiedad central, la propagación.
48200 + NA
mean(c(48200, 31500, NA, 76400))

# Por la misma razón no se puede comparar. "¿Es este valor desconocido igual a
# 48200?" no tiene respuesta.
NA == 48200
NA == NA

### Detectar y excluir ----

# La detección se hace con una función dedicada:
ingresos_na = c(48200, 31500, NA, 76400, 19900)
is.na(ingresos_na)

# Sobre esa máscara lógica, sum() cuenta y mean() da la proporción de faltantes.
ingresos_na |> is.na() |> sum()
ingresos_na |> is.na() |> mean()

# Las funciones agregadoras aceptan un argumento que los descarta antes de
# operar. Existe en sum, median, sd, var, min, max y quantile.
ingresos_na |> mean()
ingresos_na |> mean(na.rm = TRUE)

# Ojo con lo que significa: na.rm no rellena el dato, lo saca del denominador.
# El promedio pasa a ser el de los casos observados, no el de la muestra.
sum(!is.na(ingresos_na))

### NA, NULL y NaN ----

# NA ocupa una posición en el vector; NULL no ocupa ninguna.
length(c(1, NA, 3))
length(c(1, NULL, 3))

# NaN es el resultado de una operación aritmética indefinida.
0 / 0

# is.na() devuelve TRUE también para NaN. Para distinguirlos existe is.nan().
is.na(NaN)
is.nan(NA)


# EXPLORACIÓN _________________________________________________________________

## Descriptivas univariadas --------------------------------------------------=

ing = hogares$ing_cor

ing |> mean(na.rm = TRUE)
ing |> median(na.rm = TRUE)
ing |> sd(na.rm = TRUE)
ing |> var(na.rm = TRUE)
ing |> range(na.rm = TRUE)
ing |> quantile(na.rm = TRUE)

# summary() reúne casi todo lo anterior y además informa cuántos faltantes hay.
ing |> summary()

# La media supera a la mediana por casi diez mil pesos: es la asimetría a la
# derecha característica de una distribución de ingreso. Reportar solo el
# promedio describiría mal a la mayoría de los hogares.


## Frecuencias y tablas cruzadas ---------------------------------------------=

# En datos crudos, 1 y 2 no son cantidades: son etiquetas codificadas como
# número. Promediarlas no significa nada; lo que corresponde es tabular.
hogares$tam_loc |> table()

# El 9 no es una categoría: es el código de no especificado que declara el
# descriptor. Y table() descarta los NA por defecto, que es justo lo que
# interesa verificar.
hogares$tam_loc |> table(useNA = "ifany")

# Las proporciones se calculan sobre la tabla de frecuencias ya construida.
hogares$tam_loc |> table() |> prop.table()
hogares$tam_loc |> table() |> prop.table() |> round(3)

# Dos variables a la vez. La columna se construye primero:
hogares$deficit = hogares$gasto_mon > hogares$ing_cor
table(hogares$tam_loc, hogares$deficit)

# Sobre una tabla de dos entradas, el margen es la pregunta de investigación.
# Por fila: "de los hogares rurales, qué proporción gasta más de lo que ingresa".
# Por columna: "de los hogares en déficit, qué proporción son rurales". Son
# números distintos y responden cosas distintas.
table(hogares$tam_loc, hogares$deficit) |> prop.table(margin = 1) |> round(3)
table(hogares$tam_loc, hogares$deficit) |> prop.table(margin = 2) |> round(3)

addmargins(table(hogares$tam_loc, hogares$deficit))


## Descriptivas bivariadas ---------------------------------------------------=

# Sin declarar qué hacer con los faltantes, un solo NA devuelve NA.
cor(hogares$ing_cor, hogares$gasto_mon)
cor(hogares$ing_cor, hogares$gasto_mon, use = "complete.obs")

# Sobre varias columnas numéricas devuelve la matriz completa.
cor(hogares[, c("ing_cor", "gasto_mon", "tot_integ")], use = "complete.obs")

# cor() mide asociación lineal. Una relación fuerte pero curva puede dar un
# coeficiente cercano a cero, y un solo valor extremo puede dar uno alto donde
# no hay relación. Por eso se grafica antes de interpretar.


## Visualización con base graphics -------------------------------------------=

# Cuatro funciones, los mismos argumentos: main para el título, xlab y ylab para
# los ejes, col para el color.

# Una numérica: cómo se distribuye.
hist(hogares$ing_cor,
    main = "Distribución del ingreso trimestral",
    xlab = "Pesos",
    col  = "#5e002b")

# Una numérica por grupos: si la distribución difiere entre ellos. La notación
# `y ~ g` es una fórmula, y se lee "y en función de g".
boxplot(ing_cor ~ tam_loc, data = hogares,
    main = "Ingreso por tamaño de localidad",
    xlab = "Tamaño de localidad", ylab = "Pesos")

# Una categórica: cuántos casos hay en cada nivel.
barplot(table(hogares$tam_loc),
    main = "Hogares por tamaño de localidad",
    ylab = "Frecuencia")

# Dos numéricas: si se relacionan.
plot(hogares$ing_cor, hogares$gasto_mon,
    main = "Gasto contra ingreso",
    xlab = "Ingreso", ylab = "Gasto", pch = 20)

# Estas gráficas son de diagnóstico, no de publicación: se producen rápido, se
# miran y se descartan. La visualización comunicable es la Sesión 6.


## El flujo de exploración ---------------------------------------------------=

# El análisis exploratorio es un ciclo, no una lista:
#
#   pregunta -> carga -> inspección -> descriptivas -> gráficas -> hallazgo
#
# y del hallazgo se vuelve a la pregunta. Cada vuelta la refina: la gráfica
# revela un valor extremo, el valor extremo obliga a volver al descriptor
# técnico, y la pregunta original se vuelve más precisa.

# El ciclo se recorre de forma interactiva, pero lo que se conserva es el script
# y los hallazgos comentados. Una exploración que solo existió en la consola no
# ocurrió: nadie puede repetirla, empezando por quien la hizo.
