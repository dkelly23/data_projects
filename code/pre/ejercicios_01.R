# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         ejercicios_01.R
# Objetivo:       Bloque de práctica de la Sesión 1. Vectores, tipos, coerción,
#                 condiciones lógicas y valores faltantes.
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


# EJERCICIOS __________________________________________________________________

## 1. Verificación del entorno -----------------------------------------------=

# Ejecuta las líneas siguientes. La versión de R debe ser 4.1 o superior; varias
# cosas del curso dependen de ello. Si no lo es, avisa antes de continuar.

R.version.string
getRversion() >= "4.1.0"

# ¿Qué tipo de objeto devolvió la segunda línea? Averígualo.

# (escribe el código aquí)




## 2. Estructura del proyecto ------------------------------------------------=

# Confirma en qué carpeta estás parado:

getwd()

# Crea las cuatro carpetas de la convención del curso: files, docs, pre y output.
# Hazlo de forma que volver a ejecutar la línea no produzca un error si la
# carpeta ya existe.
#
# Pistas: dir.exists() pregunta, dir.create() crea, y `!` niega una condición.

# (escribe el código aquí)




# Verifica el resultado:

list.dirs(recursive = FALSE)

# ¿Qué devuelve la línea siguiente, y qué tipo tiene?

file.exists("files")


## 3. La mini encuesta -------------------------------------------------------=

# Doce personas respondieron tres preguntas. Construye un vector para cada una.
# Los datos:
#
#   edad:      34, 19, 67, 45, 23, 58, 71, 29, 16, 40, 52, 38
#   sexo:      M, H, M, M, H, H, M, H, M, H, M, H
#   segura:    2, 1, 2, 2, 1, 2, 2, 1, 1, 2, 2, 1
#
# La tercera es la pregunta "¿considera que vivir en su ciudad es seguro?",
# codificada como en las encuestas reales: 1 = seguro, 2 = inseguro.

# (escribe el código aquí)



# Verifica que los tres tengan la misma longitud. Si no, hay un error de captura.

# (escribe el código aquí)





## 4. Tipos y coerción -------------------------------------------------------=

# a) Averigua el tipo de cada uno de los tres vectores.

# (escribe el código aquí)



# b) `segura` guarda códigos, no cantidades. Calcular su promedio no significa
#    nada, pero R lo hace de todos modos. Compruébalo.

# (escribe el código aquí)




# c) Agrega la respuesta "no especificado" al vector `edad`. Antes de ejecutarlo,
#    predice qué tipo tendrá el resultado. ¿Coincidió?

# (escribe el código aquí)



# d) Intenta ahora sumar 1 a `edad_mixta`. ¿Qué ocurre?

# (escribe el código aquí)



# e) Recupera un vector numérico a partir de `edad_mixta`. ¿Qué pasó con el
#    elemento de texto?

# (escribe el código aquí)




## 5. Vectorización ----------------------------------------------------------=

# a) Todas las personas cumplieron años. Suma 1 a cada edad, sin escribir doce
#    operaciones.

# (escribe el código aquí)



# b) Calcula la edad de cada persona en meses.

# (escribe el código aquí)



# c) Calcula cuántos años le faltan a cada persona para cumplir 65.

# (escribe el código aquí)



# d) ¿Qué observas en el resultado del inciso anterior para las personas que ya
#    pasaron los 65? ¿Tiene sentido?



## 6. Condiciones lógicas ----------------------------------------------------=


# a) Construye un vector lógico que indique, para cada persona, si es mayor de
#    edad.

# (escribe el código aquí)



# b) ¿Cuántas personas son mayores de edad? Una sola línea.

# (escribe el código aquí)



# c) ¿Qué proporción del total representan?

# (escribe el código aquí)



# d) Explica en una línea de comentario por qué funciona el inciso anterior.

# (escribe el código aquí)



# e) ¿Qué proporción de las personas está en edad de trabajar (18 a 64 años)?

# (escribe el código aquí)



# f) ¿Qué proporción percibe su ciudad como insegura? Recuerda que 2 = inseguro.

# (escribe el código aquí)



# g) ¿Qué proporción son mujeres que perciben inseguridad? Ojo: esto NO es lo
#    mismo que la pregunta del inciso siguiente.

# (escribe el código aquí)



# h) De las mujeres, ¿qué proporción percibe inseguridad? Pista: es un cociente
#    entre dos conteos.

# (escribe el código aquí)




# i) ¿Hay alguna persona menor de edad en la muestra? ¿Todas son mayores de 15?

# (escribe el código aquí)




## 7. Valores faltantes ------------------------------------------------------=

# Una persona no quiso dar su edad. Vuelve a capturar el vector con ese dato
# desconocido en la tercera posición:

edad_na = c(34, 19, NA, 45, 23, 58, 71, 29, 16, 40, 52, 38)

# a) Calcula la proporción de mayores de edad. ¿Qué devuelve, y por qué?

# (escribe el código aquí)



# b) Corrígelo excluyendo el dato faltante.

# (escribe el código aquí)



# c) ¿Cuántos datos faltantes hay? Cuidado: `edad_na == NA` no sirve.

# (escribe el código aquí)



# d) Prueba `edad_na == NA` y explica por qué devuelve lo que devuelve.

# (escribe el código aquí)




# e) ¿Sobre cuántas personas se calculó realmente la proporción del inciso b)?

# (escribe el código aquí)




## 8. Listas -----------------------------------------------------------------=

# Los resultados del ejercicio 6 son de tipos distintos: conteos, proporciones y
# lógicos. Guárdalos juntos en una lista con nombres.

# (escribe el código aquí)



# Extrae la proporción de personas que perciben inseguridad, de dos maneras
# distintas.

# (escribe el código aquí)



# Inspecciona la lista completa:

str(resultados)


## 9. Integrador (opcional) --------------------------------------------------=

# Con los tres vectores originales, responde en un solo bloque de código:
#
#   - ¿Cuál es la edad promedio de quienes perciben inseguridad?
#   - ¿Y la de quienes no?
#   - ¿La diferencia te parece grande?
#
# Pista: no necesitas nada que no hayas usado ya. Un promedio es una suma entre
# un conteo, y ya sabes contar con condiciones lógicas.

# (escribe el código aquí)



