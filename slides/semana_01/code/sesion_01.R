# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_01.R
# Objetivo:       Introducir el manejo básico de objetos en R, la evaluación
#                 de condiciones lógicas y la estructura del proyecto.
#
# Autor:          Daniel Kelly
# Correo(s):      djsanchez@colmex.mx
#
# Fecha:          26/05/2026
#
# Última
# actualización:  20/08/2026
#
# _____________________________________________________________________________

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola


# CODIGO ______________________________________________________________________

# PAQUETES ____________________________________________________________________

# R base trae lo esencial. Casi todo lo demás vive en paquetes: colecciones de
# funciones que alguien más escribió y publicó, normalmente en CRAN.

# El flujo clásico son dos pasos. Instalar ocurre una vez; cargar, en cada
# sesión de trabajo:
#
#   install.packages("dplyr")   # descarga desde CRAN
#   library(dplyr)              # lo deja disponible en esta sesión

# La instalación va en la consola, nunca dentro del script. Un script con
# install.packages() adentro vuelve a descargar el paquete cada vez que alguien
# lo corre.

## pacman --------------------------------------------------------------------=

# El problema del flujo anterior: si alguien más abre el script sin tener los
# paquetes instalados, falla. `pacman` resuelve ambos pasos en una línea, y
# para cualquier número de paquetes:
#
#   pacman::p_load(dplyr, ggplot2, readr)

# La convención del curso es que todo script arranque así:
if (!requireNamespace("pacman", quietly = TRUE)) {
    install.packages("pacman")
}
pacman::p_load(lobstr)

# El operador `::` indica de qué paquete viene una función: `pacman::p_load` es
# "la función p_load del paquete pacman". Sirve para usarla sin cargar el
# paquete completo, y para dejar explícito el origen cuando dos paquetes tienen
# funciones con el mismo nombre.


# OBJETOS Y ASIGNACIONES DE NOMBRES -------------------------------------------

## Objeto de Prueba -----------------------------------------------------------

# Asignación de objetos:
a = "prueba"

# Al ejecutarlo, R hace dos cosas:
# 1. Crea un objeto, sin nombre pero con dirección en memoria, que contiene
# "prueba".
# 2. Crea una asignación (`binding`) entre el nombre `a` y el objeto `"prueba"`.

# Usamos `lobstr`, cargado en el preámbulo de la sección anterior, para mirar
# las direcciones de memoria:

# Creamos un objeto que replica a `a`
b = a

# Inspeccionamos las direcciones de los objetos `a` y `b` para ver que de fondo
# son el mismo objeto.
obj_addr(a)
obj_addr(b)


# ¿Qué sucede si ejecutamos `a = "prueba"` y `b = "prueba"` y luego inspeccionamos
# sus direcciones?


## Vectores ------------------------------------------------------------------=

# ¿Cómo se construye un vector atómico?
vector = c("A", "B", "C")

# ¿Cómo se construye una lista?
lista = list(
    "A",
    c("elemento—1", "elemento-2", "elemento-3"),
    TRUE
)

### Vectores Atómicos ----

# Los cuatro tipos de vectores atómicos son:
l = TRUE            # logical (TRUE o FALSE)
i = 10L             # interger (número entero + sufijo `L`)
d = 12.125          # double (valor numerico con decimales)
c = "Texto"         # character (`strings` de texto)

# Los voy a meter en una lista:
lista_atomicos = list(l, i, d, c) # En el extremo derecho de la sesión, ves su tipo.

# Todos los vectores tienen 3 `propiedades`:
# - Longitud.
# - Tipo.
# - Atributos.

# Longitud: Número de elementos.
length(c("A", "B", "C"))
length(10)

# Tipo: Los que vimos antes:
typeof(l)
typeof(i)
typeof(d)
typeof(c)

# Atributos: Metadata genérica.
x = rnorm(10, mean = 0, sd = 1)
attributes(x) # Por defecto, los vectores atómicos no tienen metadata.

# Pero podemos generarles atributos:
attr(x, "autor") = "Daniel Kelly"
attributes(x)

# Adelantemonos un poco e introduzcamos una función que sirve para obtener la 
# fecha actual:
print(Sys.Date())

# Y creemos un binding con el nombre `fecha_hoy`:
fecha_hoy = Sys.Date()

# Vamos a analizar los inner-workings de esta función: `Sys.Date()` representa solo
# el número de días que han pasado desde el 1 de enero de 1970, es decir, es un 
# interger que se formatea de una manera específica:
typeof(fecha_hoy) # double

# Veamos su lista de atributos:
attributes(fecha_hoy)


### Coerción y Concatenación ----

# R decide el tipo del vector, no nosotros. Cuando le pedimos meter tipos
# distintos en un mismo vector atómico, no falla: convierte todo al tipo más
# general de los presentes. A eso se le llama coerción implícita.

# La jerarquía va de menos a más general:
#   logical -> integer -> double -> character

# Un lógico y un número conviven como número:
c(TRUE, 1L)

#| nota
# Preguntar a la clase qué esperan que devuelva `c(TRUE, 1L)` ANTES de correrlo.
# El error típico es esperar un error. Aquí se gana la intuición de la sesión.
#| fin

# Un número y un texto conviven como texto:
c(1, "a")

# Y basta un solo elemento de texto para arrastrar a todo el vector:
mixto = c(1, 2, 3, "cuatro")
typeof(mixto)

# Esto importa porque es el error más caro de la importación de datos: una
# columna numérica con una sola celda que dice "N/D" llega a R como character,
# y toda operación aritmética sobre ella falla.

# La coerción también se puede pedir de forma explícita:
as.numeric("42")
as.character(42)
as.logical("TRUE")

# Cuando la conversión no tiene sentido, R devuelve NA y avisa:
as.numeric("cuarenta y dos")

# ¿Qué tipo tiene el siguiente vector, y por qué?
c(TRUE, FALSE, 10L, 2.5)


## Condiciones Lógicas -------------------------------------------------------=

### Comparación ----

# Los operadores de comparación devuelven vectores lógicos:
edad = c(17, 22, 35, 15, 68)

edad >= 18
edad == 22
edad != 22

# Nótese que la comparación es vectorizada: se evalúa elemento por elemento y
# devuelve un lógico por cada entrada, no un solo TRUE/FALSE.


### Operadores lógicos ----

# `&` (y), `|` (o) y `!` (no) combinan condiciones, también elemento a elemento:
edad >= 18 & edad < 65
edad < 18 | edad >= 65
!(edad >= 18)

# Sus contrapartes dobles, `&&` y `||`, operan sobre un solo valor y son las
# que se usan para controlar el flujo de un programa (lo veremos en la Sesión 5).
# Desde R 4.3 aplicarlas a un vector es un error, precisamente para evitar
# confundirlas con las versiones vectorizadas.

TRUE && FALSE
TRUE || FALSE


### Del lógico al número ----

# Este es el truco que más se usa en el curso. Un vector lógico se coerciona a
# número con TRUE = 1 y FALSE = 0:
as.numeric(edad >= 18)

# Y de ahí se siguen dos atajos que conviene tener memorizados:

# `sum()` sobre un lógico cuenta cuántos TRUE hay:
sum(edad >= 18)

# `mean()` sobre un lógico da la proporción de TRUE:
mean(edad >= 18)

# Es decir: "¿cuántos mayores de edad hay?" y "¿qué proporción son mayores de
# edad?" son la misma línea con distinta función. Casi todo indicador que se
# construya en el curso sale de esta idea.

# Con el vector `edad`, calcula qué proporción de las personas tiene entre 18 y
# 64 años:
mean(edad >= 18 & edad < 65)


### Funciones auxiliares y NA ----

# `any()` pregunta si al menos una condición se cumple; `all()`, si todas:
any(edad > 60)
all(edad > 60)

# El NA representa un valor desconocido, y por eso se propaga: si no sabemos
# cuánto vale, tampoco sabemos si es mayor que 18.
edad_na = c(17, 22, NA, 15, 68)
edad_na >= 18

# La consecuencia práctica: las agregaciones también devuelven NA.
mean(edad_na >= 18)

# Se resuelve declarando explícitamente que se ignoran los faltantes:
mean(edad_na >= 18, na.rm = TRUE)

# Ojo con lo que esto significa: `na.rm = TRUE` no rellena el dato, lo excluye
# del denominador. La decisión de excluir debe ser consciente, no automática.

#| nota
# Si hay tiempo: mostrar que NA == NA devuelve NA, no TRUE. Es la razón por la
# que existe is.na() y el motivo de que filtrar con `== NA` nunca funcione.
#| fin

# ¿Por qué esto devuelve NA y no TRUE?
NA == NA

# Para preguntar si un valor es faltante se usa is.na():
is.na(edad_na)
sum(is.na(edad_na))


# ESTRUCTURA DEL PROYECTO _____________________________________________________

# Todo lo anterior se escribió en un script suelto. A partir de aquí, el trabajo
# del curso vive dentro de un proyecto: una carpeta con una estructura fija y un
# historial de versiones.

## Convención de carpetas ----------------------------------------------------=

# La estructura del curso tiene cuatro carpetas:
#
#   files/    Datos crudos, tal como se descargan. Solo lectura.
#   docs/     Descriptores técnicos, catálogos, documentación de las fuentes.
#   pre/      Los scripts. Aquí se trabaja.
#   output/   Todo lo que produce el código: datos limpios, gráficas, reportes.
#
# El criterio de la separación no es estético. `files/` es insumo y no se toca;
# `output/` es desechable y se debe poder borrar completo, porque el código lo
# regenera. Si borrar `output/` rompe el proyecto, el proyecto no es reproducible.

# La carpeta de trabajo actual se consulta así:
getwd()

# Con el proyecto abierto (el archivo .Rproj), el directorio de trabajo queda
# fijo en la raíz del proyecto y las rutas se escriben relativas a ella:
#
#   read_csv("files/ensu_2024_t1.csv")     <- funciona en cualquier máquina
#   read_csv("/Users/daniel/Desktop/...")  <- funciona solo en la mía
#
# Esta es la diferencia entre un proyecto que se puede compartir y uno que no.

# `file.path()` construye rutas sin preocuparse por el separador del sistema:
file.path("files", "ensu_2024_t1.csv")

# Y estas funciones permiten inspeccionar y crear la estructura desde R:
list.files()
list.dirs(recursive = FALSE)
file.exists("files")

# Crea desde R las cuatro carpetas de la convención, si no existen todavía:
for (carpeta in c("files", "docs", "pre", "output")) {
    if (!dir.exists(carpeta)) {
        dir.create(carpeta)
    }
}
list.dirs(recursive = FALSE)


# GIT Y GITHUB ________________________________________________________________

# Git lleva el historial del proyecto: qué cambió, cuándo y por qué. GitHub es
# el lugar donde ese historial vive en línea y se puede compartir.
#
# Los comandos siguientes NO son de R. Van en la terminal (en Positron, la
# pestaña Terminal, no la consola de R).

## Configuración inicial -----------------------------------------------------=

# Una sola vez por computadora:
#
#   git config --global user.name  "Nombre Apellido"
#   git config --global user.email "correo@colmex.mx"

## El ciclo de trabajo -------------------------------------------------------=

# Iniciar el repositorio, una vez por proyecto:
#
#   git init
#
# Ver en qué estado están los archivos:
#
#   git status
#
# Seleccionar qué cambios entran en la siguiente foto:
#
#   git add pre/sesion_01.R
#
# Guardar la foto, con un mensaje que explique el cambio:
#
#   git commit -m "Agrega ejercicios de condiciones lógicas"
#
# Ver el historial:
#
#   git log --oneline
#
# El ciclo es siempre el mismo: status -> add -> commit. Un commit debería
# corresponder a un cambio con sentido propio, no a "lo que llevaba hoy".

## Sincronizar con GitHub ----------------------------------------------------=

# Tras crear el repositorio vacío en GitHub, se conecta una sola vez:
#
#   git remote add origin https://github.com/usuario/repositorio.git
#   git push -u origin main
#
# Y en adelante:
#
#   git push    para subir los commits locales
#   git pull    para traer los que no se tienen

## Qué NO se versiona --------------------------------------------------------=

# El archivo .gitignore lista lo que Git debe ignorar. Un .gitignore mínimo
# para este curso:
#
#   files/          # datos crudos: pesados y no son nuestros
#   output/         # se regenera con el código
#   .Rhistory       # historial de la consola
#   .RData          # imagen del entorno
#   .Rproj.user/    # configuración local del IDE
#   .DS_Store       # basura de macOS
#   .env            # credenciales, tokens, contraseñas
#
# Las dos últimas líneas importan más de lo que parece. Un token subido a un
# repositorio público queda en el historial aunque se borre después: el commit
# que lo introdujo sigue ahí. La forma de no tener ese problema es no cometerlo.

# Desde R se puede escribir el .gitignore directamente:
writeLines(
    c("files/", "output/", ".Rhistory", ".RData", ".Rproj.user/", ".DS_Store", ".env"),
    ".gitignore"
)
readLines(".gitignore")

#| nota
# Cierre de la sesión: verificar que TODOS tengan el repositorio creado, el
# primer commit hecho y el push a GitHub funcionando. Sin esto, la Sesión 2
# arranca en falso. Dejar 10 minutos para resolver casos individuales.
#| fin
