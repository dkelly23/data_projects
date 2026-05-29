# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_01.R
# Objetivo:       Introducir el manejo básico de objetos en R.
#
# Autor:          Daniel Kelly
# Correo(s):      djsanchez@colmex.mx
#
# Fecha:          26/05/2026
#
# Última
# actualización:  26/05/2026
#
# _____________________________________________________________________________

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola


# CODIGO ______________________________________________________________________

# OBJETOS Y ASIGNACIONES DE NOMBRES -------------------------------------------

## Objeto de Prueba -----------------------------------------------------------

# Asignación de objetos:
a = "prueba"

# Al ejecutarlo, R hace dos cosas:
# 1. Crea un objeto, sin nombre pero con dirección en memoria, que contiene
# "prueba".
# 2. Crea una asignación (`binding`) entre el nombre `a` y el objeto `"prueba"`.

# Verificamos la instalación de lobstr:
if (!requireNamespace("lobstr", quietly = TRUE)) {
    install.packages("lobstr")
}
library(lobstr)

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
