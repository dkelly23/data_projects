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

#| nota
# BLOQUE DE PRÁCTICA — 1:15 hr. Un solo encargo por partes, como en las dos
# sesiones anteriores. Reparto sugerido:
#
#   Parte 1  Operaciones sobre la serie   14 min
#   Parte 2  El loop con estado           16 min
#   Parte 3  La función de valor futuro   15 min
#   Parte 4  Resumen parametrizado        14 min
#   Parte 5  Captura de fallas y cierre   16 min
#
# BLOQUE SIN LA EIGH, igual que la exposición. Los datos son dos series de doce
# meses y una tabla de ocho renglones, declarados en el preámbulo. El entregable
# es este archivo corriendo de principio a fin, con las cuatro funciones
# definidas y la verificación de la parte 5 en TRUE.
#
# Esa verificación es el punto del bloque y conviene anunciarla al arrancar: la
# simulación con loop de la parte 2 y la fórmula cerrada de la parte 3 tienen que
# dar el mismo número. Cuando no hay con qué comparar un resultado, la única
# salida es calcularlo dos veces por caminos distintos.
#
# La parte 1 en el proyector. De la 2 en adelante, cada quien en su máquina.
#
# Lo que más atora es la parte 4. El operador {{ }} no se entiende leyéndolo: se
# entiende cuando la versión sin él devuelve un número plausible y equivocado.
# Pedirles que corran primero esa versión y que expliquen de dónde salió el 5000
# antes de arreglar nada.
#| fin

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

#| solucion
sum(aportaciones)
# [1] 58000
mean(aportaciones)
# [1] 4833.333

# La suma de un vector lógico cuenta los TRUE, así que contar meses sin
# aportación es sumar la comparación.
sum(aportaciones == 0)
# [1] 1
#| fin

# b) Los rendimientos mensuales no se suman: se encadenan, porque cada mes rinde
#    sobre el saldo que dejó el anterior. Calcula el rendimiento acumulado de los
#    doce meses con `cumprod()` y compáralo con la suma de las tasas. ¿Cuántos
#    puntos base de diferencia hay?

#| solucion
acumulado = cumprod(1 + rendimientos)
round(acumulado, 4)
#  [1] 1.0040 1.0100 1.0080 1.0130 1.0161 1.0232 1.0242 1.0201 1.0262 1.0283
# [11] 1.0334 1.0365

# El rendimiento del año es el último valor de la serie acumulada, menos uno.
rend_anual = last(acumulado) - 1
round(100 * rend_anual, 3)
# [1] 3.654
round(100 * sum(rendimientos), 3)
# [1] 3.6

# La diferencia, en puntos base:
round(10000 * (rend_anual - sum(rendimientos)), 1)
# [1] 5.4
#| fin

# c) Escribe `variacion(x)`, que devuelva el cambio porcentual de un periodo al
#    siguiente. Pruébala sobre la serie acumulada. ¿Por qué el resultado tiene un
#    elemento menos que la entrada?

#| solucion
variacion = function(x) {
    stopifnot(
        "x tiene que ser numérico"         = is.numeric(x),
        "x necesita al menos dos valores"  = length(x) >= 2
    )
    100 * diff(x) / head(x, -1)
}

round(variacion(acumulado), 3)
#  [1]  0.6 -0.2  0.5  0.3  0.7  0.1 -0.4  0.6  0.2  0.5  0.3

# diff() compara cada elemento con el anterior y el primero no tiene anterior, así
# que doce valores producen once diferencias. El denominador tiene que quedar
# alineado con eso, y de ahí el head(x, -1), que deja el vector sin su último
# elemento.
length(acumulado)
# [1] 12
length(variacion(acumulado))
# [1] 11
#| fin

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

#| solucion
signo = character(length(rendimientos))
for (i in seq_along(rendimientos)) {
    if (rendimientos[i] < 0) {
        signo[i] = "pérdida"
    } else if (rendimientos[i] == 0) {
        signo[i] = "sin cambio"
    } else {
        signo[i] = "ganancia"
    }
}

# La condición del if mira un elemento a la vez porque no puede mirar más. La
# versión vectorizada mira los doce de una vez:
signo_vec = case_when(
    rendimientos < 0  ~ "pérdida",
    rendimientos == 0 ~ "sin cambio",
    .default          = "ganancia"
)

identical(signo, signo_vec)
# [1] TRUE

table(signo_vec)
# signo_vec
# ganancia  pérdida
#       10        2
#| fin


## 2. El loop con estado ------------------------------------------------------=

# La parte anterior se resolvió sin iterar porque cada elemento se podía calcular
# por separado. Aquí no: el saldo de cada mes se obtiene del saldo del mes
# anterior, y esa dependencia es la que obliga a escribir un loop.
#
#   saldo(t + 1) = saldo(t) * (1 + rendimiento(t)) + aportacion(t)

# a) Simula la trayectoria del saldo a doce meses con las dos series del
#    preámbulo. Pre-asigna la salida y usa `seq_along()` para los índices.

#| solucion
saldo = numeric(length(aportaciones) + 1)   # 13 lugares: el inicial más doce meses
saldo[1] = 0                                # el plan arranca sin saldo

for (t in seq_along(aportaciones)) {
    saldo[t + 1] = saldo[t] * (1 + rendimientos[t]) + aportaciones[t]
}

round(saldo, 2)
#  [1]     0.00  5000.00 10030.00 15009.94 22084.99 27151.24 32341.30 32373.64
#  [9] 37244.15 42467.62 48552.55 53795.31 58956.70
#| fin

# b) ¿Cuánto se acumuló al cierre del año? De ese monto, ¿cuánto es aportación y
#    cuánto es rendimiento? Reporta las tres cifras en una línea con `paste0()`.

#| solucion
final = last(saldo)

paste0("Saldo final: ", round(final, 2),
    ". Aportado: ", sum(aportaciones),
    ". Rendimiento: ", round(final - sum(aportaciones), 2), ".")
# [1] "Saldo final: 58956.7. Aportado: 58000. Rendimiento: 956.7."
#| fin

# c) Con una aportación fija de 5,000 al mes y un rendimiento constante de 0.4%
#    mensual, ¿cuántos meses se necesitan para juntar 100,000? El número de
#    pasadas es parte de la respuesta, así que va un `while`. Agrégale un tope de
#    seguridad.

#| solucion
meta = 100000
saldo_actual = 0
meses = 0

while (saldo_actual < meta && meses < 600) {
    meses = meses + 1
    saldo_actual = saldo_actual * (1.004) + 5000
}

meses
# [1] 20
round(saldo_actual, 2)
# [1] 103892.8

# El tope de 600 no forma parte del cálculo: protege contra el loop infinito. Si
# el resultado hubiera sido exactamente 600, habría que leerlo como un loop que no
# terminó y no como la respuesta a la pregunta.
#| fin

# d) Explica en un comentario por qué el inciso (a) no se puede escribir con una
#    operación vectorizada, y por qué `cumsum()` tampoco alcanza.

#| solucion
# La vectorización aplica la misma operación a elementos independientes. Aquí los
# elementos están encadenados: el mes 7 necesita el resultado del mes 6, que a su
# vez necesita el del 5. No hay forma de repartir ese cálculo.
#
# Las acumuladoras resuelven una versión más simple de esa dependencia, con una
# sola operación repetida sobre una sola serie. En este caso entran dos series a la
# vez y el factor se aplica sobre un saldo que además recibe aportaciones, así que
# ni cumsum() ni cumprod() describen la recursión.
#| fin


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

#| solucion
valor_futuro = function(aportacion, tasa_anual = 0.06, anios = 10,
                        periodicidad = "mensual") {

    periodos = switch(periodicidad,
        mensual    = 12,
        trimestral = 4,
        anual      = 1,
        stop(paste0("Periodicidad no prevista: ", periodicidad))
    )

    i = tasa_anual / periodos
    n = anios * periodos

    aportacion * ((1 + i)^n - 1) / i
}

round(valor_futuro(5000), 2)
# [1] 819396.7
#| fin

# b) Agrega la validación al principio del cuerpo, con `stopifnot()` y mensajes
#    nombrados: la aportación numérica y positiva, la tasa no negativa, los años
#    positivos. Agrega también una salida temprana con `return()` para el caso de
#    tasa cero, donde la fórmula divide entre cero.

#| solucion
valor_futuro = function(aportacion, tasa_anual = 0.06, anios = 10,
                        periodicidad = "mensual") {
    stopifnot(
        "la aportación tiene que ser numérica" = is.numeric(aportacion),
        "la aportación tiene que ser positiva" = all(aportacion > 0),
        "la tasa no puede ser negativa"        = tasa_anual >= 0,
        "los años tienen que ser positivos"    = anios > 0
    )

    periodos = switch(periodicidad,
        mensual    = 12,
        trimestral = 4,
        anual      = 1,
        stop(paste0("Periodicidad no prevista: ", periodicidad))
    )

    n = anios * periodos

    # Sin interés no hay nada que capitalizar y la fórmula se indefine: el
    # acumulado es la suma de las aportaciones.
    if (tasa_anual == 0) return(aportacion * n)

    i = tasa_anual / periodos
    aportacion * ((1 + i)^n - 1) / i
}
#| fin

# c) Pruébala con un caso cuyo resultado se pueda verificar sin computadora: con
#    tasa cero, diez años y aportación mensual de 5,000, tiene que dar 600,000.

#| solucion
valor_futuro(5000, tasa_anual = 0, anios = 10)
# [1] 6e+05

# R lo imprime en notación científica: 6e+05 son 600,000.
#
# 5,000 por 12 meses por 10 años. Una función que no pasa la prueba fácil no
# merece confianza en el caso con interés, que nadie puede verificar de memoria.
identical(valor_futuro(5000, tasa_anual = 0, anios = 10), 600000)
# [1] TRUE
#| fin

# d) Corre la función con los cuatro argumentos por nombre, cambiando la
#    periodicidad a trimestral, y después con una periodicidad que no existe.

#| solucion
round(valor_futuro(aportacion = 15000, tasa_anual = 0.06, anios = 10,
    periodicidad = "trimestral"), 2)
# [1] 814018.4

# valor_futuro(5000, periodicidad = "quincenal")
#   Error in valor_futuro(5000, periodicidad = "quincenal") :
#     Periodicidad no prevista: quincenal
#
# El mensaje sale del último argumento sin nombre del switch(). Sin él, periodos
# quedaría en NULL y el error aparecería más adelante, hablando de una división
# imposible en vez del argumento equivocado.
#| fin


## 4. Resumen parametrizado ---------------------------------------------------=

# La tabla `planes` tiene ocho contratos. Las preguntas que se le hacen son todas
# de la misma forma con distinta columna, que es la situación en que conviene una
# función. El obstáculo es que los verbos de dplyr evalúan sus argumentos dentro
# de la tabla, y un nombre de columna que viaja como argumento deja de encontrarse.

# a) Escribe la versión que NO funciona: una función que reciba la tabla y una
#    columna y devuelva la media. Córrela con la columna `anios` y después con la
#    columna `aportacion`. Las dos respuestas están mal, cada una a su manera:
#    explica las dos.

#| solucion
resumen_mal = function(datos, variable) {
    datos |> summarize(media = mean(variable, na.rm = TRUE))
}

# resumen_mal(planes, anios)
#   Error in `summarize()`:
#   ℹ In argument: `media = mean(variable, na.rm = TRUE)`.
#   Caused by error:
#   ! object 'anios' not found

# Con `anios` hay error. summarize() recibió la expresión `variable` y la buscó
# como columna de la tabla; al no encontrarla ahí ni en ningún otro lado, reportó
# el nombre que el argumento traía adentro.

resumen_mal(planes, aportacion)
# # A tibble: 1 × 1
#   media
#   <dbl>
# 1  5000

# Con `aportacion` no hay error, y por eso es el caso grave: además de la columna,
# existe un escalar con ese nombre en el preámbulo. La búsqueda tuvo éxito en el
# ambiente global y la función devolvió 5000, que no es el promedio de nada.
mean(planes$aportacion, na.rm = TRUE)
# [1] 5857.143
#| fin

# b) Arréglala con `{{ }}`. Que devuelva el número de casos, los faltantes y la
#    media.

#| solucion
resumen_variable = function(datos, variable) {
    datos |>
        summarize(
            casos     = n(),
            faltantes = sum(is.na({{ variable }})),
            media     = mean({{ variable }}, na.rm = TRUE)
        )
}

resumen_variable(planes, aportacion)
# # A tibble: 1 × 3
#   casos faltantes media
#   <int>     <int> <dbl>
# 1     8         1 5857.
resumen_variable(planes, anios)
# # A tibble: 1 × 3
#   casos faltantes media
#   <int>     <int> <dbl>
# 1     8         0  12.5
#| fin

# c) Escribe `resumen_por(datos, grupo, variable)`: el mismo resumen por grupo,
#    ordenado de mayor a menor media. El grupo también entra por `{{ }}`.

#| solucion
resumen_por = function(datos, grupo, variable) {
    datos |>
        summarize(
            casos = n(),
            media = mean({{ variable }}, na.rm = TRUE),
            .by   = {{ grupo }}
        ) |>
        arrange(desc(media))
}

resumen_por(planes, sucursal, aportacion)
# # A tibble: 3 × 3
#   sucursal casos media
#   <chr>    <int> <dbl>
# 1 Sur          3  8000
# 2 Norte        3  5500
# 3 Centro       2  4250
resumen_por(planes, sucursal, tasa_anual)
# # A tibble: 3 × 3
#   sucursal casos  media
#   <chr>    <int>  <dbl>
# 1 Sur          3 0.0587
# 2 Norte        3 0.055
# 3 Centro       2 0.0525
#| fin

# d) Agrega a `planes` una columna con el valor futuro de cada plan, y otra con el
#    nombre construido a partir del argumento usando `:=`. Los dos primeros
#    intentos fallan, y cada error señala algo que ya se vio hoy: córrelos, léelos
#    y explícalos antes de arreglar nada.

#| solucion
# Primer intento, sobre la tabla completa:
#
#   planes |> mutate(vf = valor_futuro(aportacion, tasa_anual, anios))
#
#   Error in `mutate()`:
#   ℹ In argument: `vf = valor_futuro(aportacion, tasa_anual, anios)`.
#   Caused by error in `valor_futuro()`:
#   ! la aportación tiene que ser positiva
#
# El octavo plan no tiene aportación, y all(NA > 0) no es TRUE. La validación hizo
# exactamente su trabajo: detuvo el cálculo en la puerta en vez de devolver una
# columna con un NA que nadie hubiera revisado.

# Segundo intento, ya sin el faltante:
#
#   planes |>
#       filter(!is.na(aportacion)) |>
#       mutate(vf = valor_futuro(aportacion, tasa_anual, anios))
#
#   Error in `mutate()`:
#   ℹ In argument: `vf = valor_futuro(aportacion, tasa_anual, anios)`.
#   Caused by error in `if (tasa_anual == 0) ...`:
#   ! the condition has length > 1
#
# Es la primera lección de la sesión, ahora dentro de una función propia. El if de
# la salida temprana necesita una condición escalar, así que la función acepta
# vectores en la aportación y en los años, pero no en la tasa.

# Con la tasa fija la llamada vuelve a ser legítima:
con_vf = planes |>
    filter(!is.na(aportacion)) |>
    mutate(vf = valor_futuro(aportacion, 0.06, anios))

con_vf |> select(cliente, aportacion, anios, vf)
# # A tibble: 7 × 4
#   cliente aportacion anios       vf
#   <chr>        <dbl> <dbl>    <dbl>
# 1 P01           5000    10  819397.
# 2 P02           3500    15 1017865.
# 3 P03           8000    10 1311035.

# Para usar la tasa de cada plan hay dos caminos: cambiar el if por if_else(), que
# sí es vectorizado, o llamar la función una vez por renglón. El segundo camino es
# map2(), y es tema de la Sesión 6.

# Y la columna con nombre dinámico:
en_miles = function(datos, variable) {
    datos |> mutate("{{ variable }}_miles" := {{ variable }} / 1000)
}

con_vf |> en_miles(vf) |> select(cliente, vf, vf_miles)
# # A tibble: 7 × 3
#   cliente       vf vf_miles
#   <chr>      <dbl>    <dbl>
# 1 P01      819397.     819.
# 2 P02     1017865.    1018.
#| fin


## 5. Captura de fallas y cierre ----------------------------------------------=

# Falta lo que convierte cuatro funciones en un proceso: correr un lote de casos
# sin que uno malo cancele el resto, y comprobar que el resultado es correcto.

# a) Aquí hay cuatro escenarios y tres vienen mal, cada uno por una razón
#    distinta. Calcula el valor futuro de todos con un loop: pre-asigna la salida,
#    envuelve la llamada en `tryCatch()` y registra en un vector lógico cuáles
#    salieron bien.

#| solucion
escenarios = tibble(
    nombre       = c("base", "sin aportación", "tasa negativa", "quincenal"),
    aportacion   = c(5000, -1000, 5000, 5000),
    tasa_anual   = c(0.06, 0.06, -0.02, 0.06),
    anios        = c(10, 10, 10, 10),
    periodicidad = c("mensual", "mensual", "mensual", "quincenal")
)

vf = numeric(nrow(escenarios))
ok = logical(nrow(escenarios))

for (i in seq_len(nrow(escenarios))) {
    vf[i] = tryCatch(
        valor_futuro(escenarios$aportacion[i], escenarios$tasa_anual[i],
            escenarios$anios[i], escenarios$periodicidad[i]),
        error = function(e) {
            message(paste0(escenarios$nombre[i], ": ", conditionMessage(e)))
            NA_real_
        }
    )
    ok[i] = !is.na(vf[i])
}
# sin aportación: la aportación tiene que ser positiva
# tasa negativa: la tasa no puede ser negativa
# quincenal: Periodicidad no prevista: quincenal

round(vf, 2)
# [1] 819396.7       NA       NA       NA

paste0("Calculados ", sum(ok), " de ", nrow(escenarios), " escenarios. ",
    "Fallaron: ", paste(escenarios$nombre[!ok], collapse = ", "), ".")
# [1] "Calculados 1 de 4 escenarios. Fallaron: sin aportación, tasa negativa, quincenal."
#| fin

# b) La verificación del bloque. Simula con un loop el saldo de doce aportaciones
#    de 5,000 con rendimiento constante de 0.5% mensual, y compáralo con
#    `valor_futuro()` sobre los mismos supuestos. Los dos números tienen que
#    coincidir; piensa con qué se comparan.

#| solucion
# El loop: la aportación entra al final de cada mes, sobre un saldo que capitaliza.
saldo_sim = 0
for (t in 1:12) {
    saldo_sim = saldo_sim * 1.005 + 5000
}

round(saldo_sim, 2)
# [1] 61677.81

# La fórmula: una tasa anual de 6% con periodicidad mensual da 0.5% por periodo.
cerrada = valor_futuro(5000, tasa_anual = 0.06, anios = 1)
round(cerrada, 2)
# [1] 61677.81

# Son decimales calculados por caminos distintos, así que la comparación va con
# tolerancia y no con ==.
all.equal(saldo_sim, cerrada)
# [1] TRUE
saldo_sim == cerrada
# [1] FALSE

# Dos caminos independientes que dan el mismo número: eso es lo que permite
# confiar en los dos. Si no coincidieran, el trabajo sería encontrar cuál de los
# dos está mal, y ninguno de los dos podría descartarse de antemano.
#| fin

# c) Reporta con `paste0()` una línea de cierre: cuántos escenarios se calcularon,
#    cuántas funciones quedaron definidas y si la verificación pasó.

#| solucion
paste0("Bloque terminado: ", sum(ok), " de ", nrow(escenarios),
    " escenarios calculados, 4 funciones definidas, verificación ",
    if (isTRUE(all.equal(saldo_sim, cerrada))) "OK" else "FALLIDA", ".")
# [1] "Bloque terminado: 1 de 4 escenarios calculados, 4 funciones definidas, verificación OK."

# isTRUE() alrededor de all.equal() es obligatorio dentro de un if: cuando la
# comparación falla, all.equal() devuelve un texto con la diferencia, y un if que
# recibe un texto no corre.
#| fin

# d) Última pregunta, y es la que abre la Sesión 6: el loop del inciso (a) tiene
#    ocho líneas y solo dos hacen el trabajo. ¿Cuáles son las otras seis, y qué
#    tienen en común?

#| solucion
# Las otras seis son la mecánica del loop: crear el vector de salida, crear el de
# banderas, recorrer los índices, escribir en la posición correcta y marcar si
# hubo resultado. Ninguna tiene que ver con planes de ahorro; serían idénticas
# para cualquier función y cualquier lote de casos.
#
# Todo lo que se repite igual en todos los casos se puede escribir una sola vez en
# otra parte. Eso es map(), y es el tema de la Sesión 6.
#| fin
