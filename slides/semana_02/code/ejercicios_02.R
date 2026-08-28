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

#| nota
# BLOQUE DE PRÁCTICA — 1:15 hr. Reparto sugerido:
#
#   Ej. 1  Mirar antes de leer            10 min
#   Ej. 2  Importación                    10 min
#   Ej. 3  Contra el descriptor           10 min
#   Ej. 4  Códigos de no respuesta        15 min   <- el núcleo de la sesión
#   Ej. 5  Indexación                     10 min
#   Ej. 6  Exploración descriptiva        15 min
#   Ej. 7  Exploración gráfica             5 min
#   Ej. 8  Tidy y pipe                      5 min
#   Ej. 9  Integrador                   opcional
#
# Los primeros 15 minutos, el 1 y el 2 en conjunto en el proyector: es la primera
# vez que leen un archivo de verdad y conviene que nadie arranque con la ruta mal
# escrita. Del 3 en adelante, trabajo individual.
#
# Si el tiempo aprieta, el 9 se va a casa y el 7 se resuelve en voz alta. Lo que
# NO se puede sacrificar es el 4: la idea de que un 999 y un "n.d." son datos
# faltantes disfrazados de dato es la que sostiene toda la limpieza del curso.
#| fin

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

#| solucion
readLines("files/eigh_personas.txt", n = 3)
# El delimitador es la barra vertical, y la primera línea sí es el encabezado.
#| fin

# b) ¿Cuántas líneas tiene el archivo completo? Cuidado con el encabezado: el
#    número de líneas no es el número de registros.

#| solucion
length(readLines("files/eigh_personas.txt"))
length(readLines("files/eigh_personas.txt")) - 1   # los registros
#| fin

# c) Haz lo mismo con files/eigh_gastos.csv. Trae dos convenciones distintas a
#    las del archivo anterior: ¿cuáles?

#| solucion
readLines("files/eigh_gastos.csv", n = 3)
# Punto y coma como separador de columnas, y coma como separador decimal.
#| fin

#| nota
# Insistir en que este ejercicio no es preparatorio: ES el ejercicio. Quien se lo
# salta elige la función a ciegas. Preguntar en voz alta qué función usarían para
# cada archivo ANTES de dejarlos escribir el 2.
#| fin


## 2. Importación ------------------------------------------------------------=

# a) Importa la tabla de personas con la función que corresponde al delimitador
#    que identificaste. Guárdala en un objeto llamado `personas`.

#| solucion
personas = read_delim("files/eigh_personas.txt", delim = "|")
#| fin

# b) Importa la tabla de gastos en un objeto llamado `gastos`. Recuerda que el
#    separador decimal también es distinto.

#| solucion
gastos = read_csv2("files/eigh_gastos.csv")
#| fin

# c) ¿Cuántas filas y columnas tiene cada una?

#| solucion
dim(personas)
dim(gastos)
#| fin

# d) Lee el bloque de especificación que imprimió cada lectura. ¿Qué columnas
#    quedaron como texto (chr) y cuáles como número (dbl)?


## 3. Contra el descriptor ---------------------------------------------------=

# El descriptor técnico está en docs/ y declara, para cada variable, qué tipo
# tiene y qué códigos usa para la no respuesta. Es contra ese documento que se
# verifica una importación, no contra la intuición.

# a) Impórtalo en un objeto llamado `descriptor`.

#| solucion
descriptor = read_csv("docs/eigh_descriptor.csv")
#| fin

# b) Quédate solo con las filas que describen la tabla de personas. Usa
#    indexación lógica sobre la columna `tabla`.

#| solucion
desc_personas = descriptor[descriptor$tabla == "personas", ]
desc_personas
#| fin

# c) Compara esos tipos declarados contra los que infirió R. ¿Qué columna llegó
#    con un tipo distinto al que dice el descriptor?

#| solucion
personas |> glimpse()
# `ing_trab` está declarada como double y llegó como character.
#| fin

# d) Explica en un comentario por qué ocurrió eso. La respuesta está en la
#    columna `codigos` del descriptor.

#| solucion
# Porque algunas celdas traen "n.d." en vez de un número, y basta un solo valor
# de texto para que toda la columna se coercione a character.
#| fin


## 4. Códigos de no respuesta ------------------------------------------------=

#| nota
# EL NÚCLEO DE LA SESIÓN. Reservar los 15 minutos completos. La idea de que un
# 999 se ve como un dato pero no lo es reaparece en todas las sesiones que
# siguen, y es la que más se les olvida.
#| fin

# a) Según el descriptor, ¿qué código usa `edad` para la no respuesta?

#| solucion
descriptor[descriptor$variable == "edad", ]
# El 999.
#| fin

# b) Compruébalo: ¿cuántos registros traen ese código? Cuidado, `table()` sobre
#    una variable con muchos valores distintos imprime muchísimo. Conviene
#    contar directamente con una condición lógica.

#| solucion
sum(personas$edad == 999)
#| fin

# c) ¿Qué pasa si se calcula la edad promedio sin corregir ese código? Calcúlala
#    y compárala con la mediana.

#| solucion
mean(personas$edad)
median(personas$edad)
# El promedio se dispara: 31 registros con valor 999 arrastran la media hacia
# arriba. La mediana casi no se mueve, porque el código no cambia el orden.
#| fin

# d) Vuelve a importar la tabla de personas, esta vez declarando los códigos de
#    no respuesta y forzando `ing_trab` a numérica. Guárdala en `personas`.

#| solucion
personas = read_delim(
    "files/eigh_personas.txt",
    delim     = "|",
    na        = c("", "n.d.", "999"),
    col_types = cols(folioviv = col_character(), ing_trab = col_double())
)
#| fin

# e) Cuenta los faltantes de cada columna. ¿Los números coinciden con lo que
#    esperabas de los incisos anteriores?

#| solucion
personas |> is.na() |> colSums()
#| fin

# f) Vuelve a calcular la edad promedio. ¿Cuánto cambió?

#| solucion
mean(personas$edad, na.rm = TRUE)
#| fin

#| nota
# El argumento `na` se aplica a TODAS las columnas del archivo, no solo a la que
# interesa. Si alguien pregunta si eso es peligroso, la respuesta es sí: hay que
# verificar que ningún otro dato legítimo use esos códigos. Aquí no ocurre, pero
# vale la pena decirlo.
#| fin


## 5. Indexación -------------------------------------------------------------=

# a) Extrae la columna de edad de dos maneras: como vector y como tabla de una
#    columna. Verifica la clase de cada resultado.

#| solucion
class(personas$edad)
class(personas["edad"])
#| fin

# b) ¿Cuántas personas tienen 65 años o más? Una sola línea.

#| solucion
sum(personas$edad >= 65, na.rm = TRUE)
#| fin

# c) Construye una tabla que contenga únicamente a los jefes de hogar. El
#    descriptor dice qué código les corresponde en `parentesco`.

#| solucion
jefes = personas[personas$parentesco == 1, ]
nrow(jefes)
#| fin

# d) ¿Cuál es el folio de la vivienda de la persona de mayor edad? Pista: no
#    buscas el valor, buscas su posición.

#| solucion
personas$folioviv[which.max(personas$edad)]
#| fin


## 6. Exploración descriptiva ------------------------------------------------=

# a) Descriptivas de la edad y del ingreso por trabajo. Recuerda que ambas tienen
#    faltantes.

#| solucion
personas$edad     |> summary()
personas$ing_trab |> summary()
#| fin

# b) Frecuencias de `sexo` y de `nivel_esc`, sin esconder los faltantes.

#| solucion
personas$sexo      |> table(useNA = "ifany")
personas$nivel_esc |> table(useNA = "ifany")
#| fin

# c) ¿Qué proporción de las personas no percibe ingreso por trabajo? Ojo: no
#    percibir ingreso es un 0, no un faltante.

#| solucion
mean(personas$ing_trab == 0, na.rm = TRUE)
#| fin

# d) Cruza sexo contra nivel de escolaridad y calcula los porcentajes por fila.
#    ¿Qué pregunta responde ese margen, y cuál respondería el otro?

#| solucion
table(personas$sexo, personas$nivel_esc) |> prop.table(margin = 1) |> round(3)
# Por fila: de las mujeres, qué proporción está en cada nivel. Por columna: de
# quienes están en un nivel, qué proporción son mujeres.
#| fin

# e) ¿Se relacionan la edad y el ingreso por trabajo? Cuidado con los faltantes.

#| solucion
cor(personas$edad, personas$ing_trab, use = "complete.obs")
#| fin


## 7. Exploración gráfica ----------------------------------------------------=

# Produce al menos dos gráficas, eligiendo el tipo según la pregunta y no según
# lo que se vea mejor. Ponle título y nombres a los ejes.

# a) ¿Cómo se distribuye la edad?

#| solucion
hist(personas$edad,
    main = "Distribución de la edad",
    xlab = "Años",
    col  = "#5e002b")
#| fin

# b) ¿Difiere el ingreso por trabajo entre hombres y mujeres?

#| solucion
boxplot(ing_trab ~ sexo, data = personas,
    main = "Ingreso por trabajo según sexo",
    xlab = "1 = hombre, 2 = mujer", ylab = "Pesos")
#| fin

# c) Escribe en un comentario el hallazgo que te parezca más claro de las dos
#    gráficas. Una línea basta, pero tiene que decir algo.


## 8. Tidy y pipe --------------------------------------------------=

# a) ¿Cuál es la unidad de observación de `personas`? ¿Y la de `gastos`? Es la
#    pregunta que define si una tabla está en forma tidy.

#| solucion
# En `personas`, una persona dentro de un hogar (folioviv + numren). En
# `gastos`, una combinación de hogar y rubro (folioviv + clave). Cada tabla es
# tidy a su propio nivel de observación.
#| fin

# b) La tabla de gastos está en formato largo. Explica en un comentario qué se
#    perdería si estuviera en ancho, con una columna por rubro.

#| solucion
# El rubro dejaría de ser un valor y pasaría a los nombres de las columnas, así
# que agrupar o filtrar por rubro exigiría escribir el nombre de cada columna en
# vez de usar una sola variable.
#| fin

# c) Reescribe esta línea con el pipe y comprueba que da lo mismo:
#
#      round(prop.table(table(gastos$clave)), 3)

#| solucion
round(prop.table(table(gastos$clave)), 3)
gastos$clave |> table() |> prop.table() |> round(3)
#| fin

# d) ¿En cuál de estas dos líneas NO conviene el pipe, y por qué?
#
#      nrow(personas)
#      round(prop.table(table(personas$sexo)), 3)

#| solucion
# En la primera: una sola llamada, sin anidar. `nrow(personas)` se lee mejor que
# `personas |> nrow()`. El pipe paga cuando hay dos o más llamadas anidadas.
#| fin


## 9. Integrador (opcional) ---------------------------------------------------=

# Con la tabla de personas ya corregida, responde en un solo bloque de código:
#
#   - ¿Cuál es la edad promedio de quienes perciben ingreso por trabajo?
#   - ¿Y la de quienes no?
#   - ¿La escolaridad se asocia con percibir ingreso?
#
# Pista: no necesitas nada que no hayas usado ya. Una condición lógica sirve para
# filtrar filas, para contar y para cruzar.

#| solucion
percibe = personas$ing_trab > 0

mean(personas$edad[percibe], na.rm = TRUE)
mean(personas$edad[!percibe], na.rm = TRUE)

table(personas$nivel_esc, percibe) |> prop.table(margin = 1) |> round(3)
#| fin

#| nota
# El inciso c) se resuelve mucho más fácil con group_by() y summarise(), que es
# la Sesión 3. Si alguien lo propone, celebrarlo y mostrarlo: es el puente
# perfecto hacia la próxima clase. Si nadie lo propone, cerrar con eso.
#| fin
