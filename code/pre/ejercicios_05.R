# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         ejercicios_05.R
# Objetivo:       Bloque de práctica de la Sesión 5. Escribir funciones propias:
#                 control de flujo, validación y captura de fallas.
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
pacman::p_load(tidyverse)

# Los datos del bloque: un plan de ahorro a doce meses. Nada se lee de disco.

# Aportación mensual observada, en pesos. Dos meses salieron de lo habitual y en
# uno no hubo aportación.
aportaciones = c(5000, 5000, 5000, 7000, 5000, 5000, 0, 5000, 5000, 6000, 5000, 5000)

# Rendimiento mensual del fondo, en tanto por uno.
rendimientos = c(0.004, 0.006, -0.002, 0.005, 0.003, 0.007,
    0.001, -0.004, 0.006, 0.002, 0.005, 0.003)

# La aportación de referencia del contrato, como escalar.
aportacion = 5000

# Y ocho planes contratados, para la parte 4.
planes = tibble(
    cliente     = c("P01", "P02", "P03", "P04", "P05", "P06", "P07", "P08"),
    sucursal    = c("Centro", "Centro", "Norte", "Norte", "Norte", "Sur", "Sur", "Sur"),
    aportacion  = c(5000, 3500, 8000, 2000, 6500, 4000, 12000, NA),
    tasa_anual  = c(0.060, 0.045, 0.072, 0.038, 0.055, 0.050, 0.068, 0.058),
    anios       = c(10, 15, 10, 20, 12, 10, 8, 15)
)


# EJERCICIOS __________________________________________________________________

# EL ENCARGO
#
# Construir la calculadora de un plan de ahorro. Al cerrar el bloque tienen que
# existir cuatro funciones que corran solas, con validación y con un caso de
# prueba cuyo resultado se pueda verificar a mano:
#
#   variacion()        el cambio de una serie de un periodo al siguiente
#   simular_saldo()    la trayectoria del saldo, mes por mes
#   valor_futuro()     el valor acumulado por la fórmula cerrada
#   resumen_por()      un resumen de cualquier columna por cualquier grupo
#
# El bloque cierra comparando las dos últimas: con los mismos supuestos, la
# simulación mes por mes y la fórmula cerrada tienen que coincidir.


## 1. Operaciones sobre la serie ----------------------------------------------=

# Las dos series del preámbulo tienen doce elementos cada una. Todo lo que se
# pide aquí se calcula sobre el vector completo, sin escribir un solo loop: es la
# parte donde conviene acostumbrarse a pensar en vectores y no en posiciones.

# a) ¿Cuánto se aportó en total en el año, cuál fue la aportación media y en
#    cuántos meses no hubo aportación?

# (escribe el código aquí)



# b) Los rendimientos mensuales no se suman: se encadenan, porque cada mes rinde
#    sobre el saldo que dejó el anterior. Calcula el rendimiento acumulado de los
#    doce meses con `cumprod()` y compáralo con la suma de las tasas. ¿Cuántos
#    puntos base de diferencia hay?

# (escribe el código aquí)



# c) Escribe `variacion(x)`, que devuelva el cambio porcentual de un periodo al
#    siguiente. Pruébala sobre la serie acumulada. ¿Por qué el resultado tiene un
#    elemento menos que la entrada?

# (escribe el código aquí)



# d) Aquí está escrito con loop lo que se resuelve en una expresión. Reescríbelo
#    vectorizado y comprueba que los dos resultados son idénticos.
#
#      signo = character(length(rendimientos))
#      for (i in seq_along(rendimientos)) {
#          if (rendimientos[i] < 0) {
#              signo[i] = "pérdida"
#          } else if (rendimientos[i] == 0) {
#              signo[i] = "sin cambio"
#          } else {
#              signo[i] = "ganancia"
#          }
#      }

# (escribe el código aquí)




## 2. El loop con estado ------------------------------------------------------=

# La parte anterior se resolvió sin iterar porque cada elemento se podía calcular
# por separado. Aquí no: el saldo de cada mes se obtiene del saldo del mes
# anterior, y esa dependencia es la que obliga a escribir un loop.
#
#   saldo(t + 1) = saldo(t) * (1 + rendimiento(t)) + aportacion(t)

# a) Simula la trayectoria del saldo a doce meses con las dos series del
#    preámbulo. Pre-asigna la salida y usa `seq_along()` para los índices.

# (escribe el código aquí)



# b) ¿Cuánto se acumuló al cierre del año? De ese monto, ¿cuánto es aportación y
#    cuánto es rendimiento? Reporta las tres cifras en una línea con `paste0()`.

# (escribe el código aquí)



# c) Con una aportación fija de 5,000 al mes y un rendimiento constante de 0.4%
#    mensual, ¿cuántos meses se necesitan para juntar 100,000? El número de
#    pasadas es parte de la respuesta, así que va un `while`. Agrégale un tope de
#    seguridad.

# (escribe el código aquí)



# d) Explica en un comentario por qué el inciso (a) no se puede escribir con una
#    operación vectorizada, y por qué `cumsum()` tampoco alcanza.

# (escribe el código aquí)




## 3. La función de valor futuro ----------------------------------------------=

# Cuando la aportación y el rendimiento son constantes, la recursión del inciso
# anterior tiene solución algebraica y no hace falta iterar:
#
#   VF = aportacion * ((1 + i)^n - 1) / i
#
# donde i es la tasa POR PERIODO y n el número de periodos. Encapsular esa fórmula
# es el ejercicio de diseño de la sesión: hay que decidir qué entra por argumento,
# qué se asume por omisión y qué se rechaza de entrada.

# a) Escribe `valor_futuro()` con cuatro argumentos: la aportación, la tasa anual,
#    los años y la periodicidad. Los tres últimos con valor por defecto. La
#    periodicidad se resuelve con `switch()` —mensual, trimestral, anual— y un
#    caso por omisión que falle con un mensaje útil.

# (escribe el código aquí)



# b) Agrega la validación al principio del cuerpo, con `stopifnot()` y mensajes
#    nombrados: la aportación numérica y positiva, la tasa no negativa, los años
#    positivos. Agrega también una salida temprana con `return()` para el caso de
#    tasa cero, donde la fórmula divide entre cero.

# (escribe el código aquí)



# c) Pruébala con un caso cuyo resultado se pueda verificar sin computadora: con
#    tasa cero, diez años y aportación mensual de 5,000, tiene que dar 600,000.

# (escribe el código aquí)



# d) Corre la función con los cuatro argumentos por nombre, cambiando la
#    periodicidad a trimestral, y después con una periodicidad que no existe.

# (escribe el código aquí)




## 4. Resumen parametrizado ---------------------------------------------------=

# La tabla `planes` tiene ocho contratos. Las preguntas que se le hacen son todas
# de la misma forma con distinta columna, que es la situación en que conviene una
# función. El obstáculo es que los verbos de dplyr evalúan sus argumentos dentro
# de la tabla, y un nombre de columna que viaja como argumento deja de encontrarse.

# a) Escribe la versión que NO funciona: una función que reciba la tabla y una
#    columna y devuelva la media. Córrela con la columna `anios` y después con la
#    columna `aportacion`. Las dos respuestas están mal, cada una a su manera:
#    explica las dos.

# (escribe el código aquí)



# b) Arréglala con `{{ }}`. Que devuelva el número de casos, los faltantes y la
#    media.

# (escribe el código aquí)



# c) Escribe `resumen_por(datos, grupo, variable)`: el mismo resumen por grupo,
#    ordenado de mayor a menor media. El grupo también entra por `{{ }}`.

# (escribe el código aquí)



# d) Agrega a `planes` una columna con el valor futuro de cada plan, y otra con el
#    nombre construido a partir del argumento usando `:=`. Los dos primeros
#    intentos fallan, y cada error señala algo que ya se vio hoy: córrelos, léelos
#    y explícalos antes de arreglar nada.

# (escribe el código aquí)




## 5. Captura de fallas y cierre ----------------------------------------------=

# Falta lo que convierte cuatro funciones en un proceso: correr un lote de casos
# sin que uno malo cancele el resto, y comprobar que el resultado es correcto.

# a) Aquí hay cuatro escenarios y tres vienen mal, cada uno por una razón
#    distinta. Calcula el valor futuro de todos con un loop: pre-asigna la salida,
#    envuelve la llamada en `tryCatch()` y registra en un vector lógico cuáles
#    salieron bien.

# (escribe el código aquí)



# b) La verificación del bloque. Simula con un loop el saldo de doce aportaciones
#    de 5,000 con rendimiento constante de 0.5% mensual, y compáralo con
#    `valor_futuro()` sobre los mismos supuestos. Los dos números tienen que
#    coincidir; piensa con qué se comparan.

# (escribe el código aquí)



# c) Reporta con `paste0()` una línea de cierre: cuántos escenarios se calcularon,
#    cuántas funciones quedaron definidas y si la verificación pasó.

# (escribe el código aquí)



# d) Última pregunta, y es la que abre la Sesión 6: el loop del inciso (a) tiene
#    ocho líneas y solo dos hacen el trabajo. ¿Cuáles son las otras seis, y qué
#    tienen en común?

# (escribe el código aquí)


