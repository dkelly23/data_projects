# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_05.R
# Objetivo:       Pasar de consumidor a autor de código: control de flujo, vectorización
#                 y diseño de funciones propias.
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
#   Punto de partida            5 min
#   Funciones                  18 min   <- abre la sesión, y el resto la usa
#   Condicionales              14 min
#   Loops                      18 min
#   Vectorización              14 min
#   Ambientes y diseño         12 min
#   Errores y debugging        13 min
#   Columnas como argumentos    8 min
#   Cierre                      2 min
#
# ÚNICA SESIÓN SIN LA EIGH. Todo lo que hace falta se declara en el script: tres
# escalares, una serie de tasas y una tabla de ocho renglones. Decirlo al abrir,
# junto con la razón: los temas de hoy son propiedades del lenguaje, y con una
# encuesta de fondo cuesta distinguir si algo falló por el código o por el
# archivo. La EIGH regresa en la Sesión 6.
#
# El hilo es una calculadora de crédito. La tabla de amortización es el ejemplo
# central de la sesión porque ahí el loop es obligatorio: cada saldo se calcula
# sobre el anterior. Esa obligación es la que da sentido a la discusión de
# vectorización que viene después.
#
# CADA TEMA VA EN TRES PASOS, en este orden: primero qué problema resuelve,
# después cómo se comporta, y al final el código corriendo. La demostración sin
# el concepto se olvida en una semana; el concepto sin la demostración no se
# cree. Las dos primeras partes son para hablar, no para teclear.
#
# LA SESIÓN ABRE CON FUNCIONES, contra el orden del libro. La razón es práctica:
# pago_mensual() queda escrita en el minuto quince y a partir de ahí todas las
# secciones la llaman, en vez de repetir la fórmula cuatro veces. El loop, la
# vectorización y el tryCatch se leen mejor cuando el cálculo ya tiene nombre.
#
# Las funciones se ven en dos tandas. La primera es la que no necesita nada del
# resto: qué es, anatomía, argumentos, valor de retorno. La segunda —ambientes,
# los tres puntos, pureza— va después de vectorización, cuando ya escribieron
# unas cuantas y las preguntas son otras. La salida temprana con return() queda
# en medio, adentro de condicionales, porque es una aplicación del if.
#
# Si el tiempo aprieta se recorta switch() y las acumuladoras. La sección de
# funciones y tryCatch() no se recortan: son lo que el bloque de práctica pide.
#
# Tres puntos que hay que dejar dichos, cueste lo que cueste:
#
#   1. if decide por el programa; if_else() calcula por elemento.
#   2. El loop no está prohibido. Está en segundo lugar, y hay tres casos en que
#      es la única opción.
#   3. Una función que lee del ambiente global funciona hoy y falla mañana.
#
# Los tiempos de la sección de vectorización son de la máquina del salón y
# cambian entre corridas. El orden de magnitud no.
#| fin

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola

# Paquetes de la sesión
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(tidyverse)


# CODIGO ______________________________________________________________________

# PUNTO DE PARTIDA _____________________________________________________________

# Las cuatro sesiones anteriores trabajaron sobre un levantamiento: importar,
# manipular, unir, limpiar. En todas ellas el código fue una cadena de llamadas a
# funciones que escribió alguien más. Hoy empieza la parte en que las funciones
# las escribe el estudiante, y eso cambia el tipo de error posible: hasta ahora
# los errores eran del dato, y desde hoy pueden ser del razonamiento.

# Por eso esta sesión no lee ningún archivo. Sus temas son propiedades del
# lenguaje y se entienden mejor sobre objetos de tres líneas, donde el resultado
# esperado se puede calcular a mano y no hay dudas sobre de dónde salió una cifra.

# El hilo es una calculadora de crédito. Todo lo que necesita cabe aquí:
capital = 250000     # monto del crédito, en pesos
tasa    = 0.01       # interés MENSUAL, en tanto por uno
plazo   = 24         # número de pagos

# Una serie de tasas de inflación anual, para la parte de vectorización:
tasas_anuales = c(0.041, 0.052, 0.033, 0.048, 0.039)

# Y una tabla de ocho créditos, para la parte de funciones. Está escrita a mano:
# no se lee de disco ni se simula.
creditos = tibble(
    folio   = c("C001", "C002", "C003", "C004", "C005", "C006", "C007", "C008"),
    banco   = c("Norte", "Norte", "Sur", "Sur", "Sur", "Centro", "Centro", "Norte"),
    capital = c(250000, 180000, 320000, 95000, 410000, 150000, 275000, NA),
    tasa    = c(0.012, 0.0145, 0.0099, 0.018, 0.011, 0.0155, 0.0128, 0.013),
    plazo   = c(24, 36, 48, 12, 60, 24, 36, 24),
    atraso  = c(0, 2, 0, 3, 0, 1, 0, 0)
)

creditos
# # A tibble: 8 × 6
#   folio banco  capital   tasa plazo atraso
#   <chr> <chr>    <dbl>  <dbl> <dbl>  <dbl>
# 1 C001  Norte   250000 0.012     24      0
# 2 C002  Norte   180000 0.0145    36      2
# 3 C003  Sur     320000 0.0099    48      0
# 4 C004  Sur      95000 0.018     12      3
# 5 C005  Sur     410000 0.011     60      0
# 6 C006  Centro  150000 0.0155    24      1
# 7 C007  Centro  275000 0.0128    36      0
# 8 C008  Norte       NA 0.013     24      0

## Cómo se arman los mensajes --------------------------------------------------=

# Casi todo lo que sigue imprime algo en la consola: un diagnóstico, una
# advertencia, el resultado de una pasada del loop. Esos mensajes se construyen
# pegando texto con valores, y en R base eso se hace con paste0().

# paste0() recibe cualquier número de piezas y las une sin separador. Los números
# los convierte a texto por su cuenta, así que el redondeo hay que pedirlo:
paste0("Crédito de ", capital, " pesos a ", plazo, " meses.")
# [1] "Crédito de 250000 pesos a 24 meses."

# paste() hace lo mismo pero mete un espacio entre las piezas. Sirve poco para
# armar frases —termina sobrando el espacio antes de la coma o del punto— y sirve
# mucho para lo otro que hace: con collapse, convierte un vector en un solo texto.
paste("uno", "dos", "tres")
# [1] "uno dos tres"
paste(c("hogares", "personas", "gastos"), collapse = ", ")
# [1] "hogares, personas, gastos"

# Las dos últimas líneas se confunden todo el tiempo. Con varios argumentos,
# paste0() y paste() operan elemento a elemento y devuelven un vector del mismo
# largo que el más largo de ellos; con collapse devuelven un texto de largo 1.
paste0("crédito ", creditos$folio[1:3])
# [1] "crédito C001" "crédito C002" "crédito C003"

#| nota
# Cinco minutos de preámbulo, contando esta subsección. paste0() no figura en el temario,
# pero es la herramienta con la que se van a ver los demás temas: hay que dejarla
# clara aquí para no volver a explicarla en cada sección.
#
# Quien venga de la Sesión 4 va a preguntar por glue(). La respuesta: glue() es
# más legible y para un pipeline es la mejor opción, pero hoy toda la sesión es
# R base a propósito, y paste0() es lo que hay que saber leer porque es lo que
# está escrito en el código que van a heredar.
#
# Abrir el sesion_04.R en la pantalla de al lado y señalar las cuarenta líneas
# del cierre: el ETL escrito de corrido, una sola vez. Hoy se aprende con qué se
# reescribe eso, y en la Sesión 6 se reescribe.
#| fin


# FUNCIONES ____________________________________________________________________

## Qué es una función ----------------------------------------------------------=

# PARA QUÉ SIRVE. Una función le pone nombre a un cálculo y deja huecos donde
# están las partes que cambian. Eso es todo, y de ahí salen los tres beneficios
# que importan:
#
#   1. El nombre dice qué significa el resultado, que es más de lo que dice la
#      fórmula.
#   2. Si el cálculo estaba mal, se corrige en un solo lugar.
#   3. Se puede probar aparte, con un caso cuyo resultado se conoce de antemano.
#
# Lo que justifica escribirla es la repetición, y no el tamaño del cálculo. El
# ETL de la Sesión 4 leyó tres tablas con tres líneas casi idénticas, y el bloque
# de práctica de esa sesión repitió el mismo case_when() en dos lugares distintos:
# a la tercera aparición del mismo patrón, se encapsula.
#
# La función de hoy es la mensualidad de un crédito. Se escribe aquí, en los
# primeros quince minutos, porque todas las secciones que siguen la van a llamar:
# el loop de la tabla de amortización, el lote de escenarios del tryCatch y el
# cierre. Escribirla primero es lo que permite que esas secciones se lean.

# CÓMO SE COMPORTA. function() crea un objeto como cualquier otro y se guarda en
# un nombre. Al llamarla, R abre un ambiente nuevo, asocia cada argumento con el
# valor que le tocó, evalúa el cuerpo ahí adentro y devuelve el valor de la última
# expresión que evaluó.

# EN CÓDIGO. La fórmula del pago, encapsulada y con nombre:
pago_mensual = function(capital, tasa, plazo) {
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

round(pago_mensual(250000, 0.01, 24), 2)
# [1] 11768.37

# Una función tiene exactamente tres partes, y las tres se pueden inspeccionar:
#
#   argumentos   lo que entra              formals()
#   cuerpo       lo que hace               body()
#   ambiente     dónde busca los nombres   environment()

formals(pago_mensual)
# $capital
# $tasa
# $plazo
body(pago_mensual)
# {
#     capital * tasa/(1 - (1 + tasa)^-plazo)
# }
environment(pago_mensual)
# <environment: R_GlobalEnv>

# La tercera es la que nadie escribe y la que explica los comportamientos raros.
# Vuelve más abajo, en la sección de scoping.

# La prueba con un caso conocido: un crédito casi sin interés se paga en
# mensualidades casi iguales al capital entre el plazo.
pago_mensual(1200, 0.0001, 12)   # 1200 / 12 = 100
# [1] 100.065

# Y una propiedad que sale gratis: el cuerpo está armado con operaciones
# vectorizadas, así que la función hereda la vectorización sin haber hecho nada
# especial. Los ocho créditos de la tabla, de una sola llamada:
round(pago_mensual(creditos$capital, creditos$tasa, creditos$plazo))
# [1] 12051  6453  8408  8873  9371  7532  9582    NA

## Argumentos y valores por defecto --------------------------------------------=

# PARA QUÉ SIRVEN. Los argumentos son la interfaz de la función: lo único que el
# que la llama tiene que saber. Darle valor por defecto a uno significa que hay
# una decisión habitual, y deja esa decisión escrita en la definición en vez de
# repetida en cada llamada.

# CÓMO SE COMPORTA. Un argumento sin defecto es obligatorio y su ausencia produce
# un error en el momento en que el cuerpo lo necesita. Con defecto es opcional, y
# el valor por omisión se evalúa dentro de la función, así que puede depender de
# los otros argumentos.
pago_mensual = function(capital, tasa = 0.01, plazo = 24) {
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

round(pago_mensual(250000), 2)
# [1] 11768.37
round(pago_mensual(250000, plazo = 36), 2)
# [1] 8303.58

# Los argumentos se pasan por posición o por nombre. Por nombre el orden deja de
# importar y se pueden saltar los de en medio:
round(pago_mensual(plazo = 12, capital = 250000, tasa = 0.015), 2)
# [1] 22920

# Y aquí está el argumento a favor de escribir los nombres. Los mismos tres
# valores en el orden equivocado no producen ningún error: producen un número, y
# alguien lo va a copiar a un reporte.
round(pago_mensual(250000, 24, 0.01), 2)
# [1] 189416574

# La convención del curso es pasar el dato por posición y todo lo demás por
# nombre. Una llamada con tres valores sueltos no se puede leer sin abrir la
# definición de la función.

# CONDICIONALES ________________________________________________________________

## if y else -------------------------------------------------------------------=

# PARA QUÉ SIRVE. Un condicional elige qué líneas se ejecutan. La decisión es
# sobre el programa, no sobre los datos: se toma una vez, antes de calcular nada,
# y de ella depende cuál de dos bloques corre y cuál se ignora por completo.
#
# Los casos típicos son de control: si el archivo no existe, avisar y detenerse;
# si la tabla viene vacía, no intentar el cálculo; si el usuario pidió el reporte
# largo, agregar las páginas de anexos.

# CÓMO SE COMPORTA. R evalúa la condición, que tiene que resolverse en un solo
# TRUE o FALSE. Si es TRUE corre el bloque entre llaves; si es FALSE, salta al
# else cuando lo hay, y si no lo hay no hace nada. Con varias ramas encadenadas,
# la primera condición verdadera gana y las siguientes ni se evalúan.

# EN CÓDIGO. El else va en la misma línea que la llave que cierra, porque si se
# manda al renglón siguiente R entiende que la instrucción terminó.
if (tasa <= 0) {
    message("Crédito sin interés.")
} else if (tasa < 0.015) {
    message("Tasa moderada.")
} else {
    message("Tasa alta.")
}
# Tasa moderada.

# Un detalle que casi no se usa pero explica mucho: en R el condicional es una
# expresión y devuelve un valor, el de la rama que se ejecutó. Por eso se puede
# asignar, y por eso las llaves sobran cuando cada rama es una sola expresión.
tipo = if (plazo > 36) "largo plazo" else "corto plazo"
tipo
# [1] "corto plazo"

### La guardia de una función: return() ----

# El primer uso del if que aparece al escribir funciones propias es la guardia: un
# caso que hay que atender antes de llegar al cálculo general.
#
# PARA QUÉ SIRVE. El valor de una función es la última expresión que evaluó, así
# que return() no hace falta para devolver un resultado. Sirve para lo contrario:
# para salir antes de tiempo cuando el resto del cuerpo no aplica.
#
# En pago_mensual() hay un caso así. Con tasa cero, el denominador de la fórmula
# vale cero y el resultado es indefinido:
pago_mensual(250000, 0, 24)
# [1] NaN

# La salida temprana atiende ese caso y deja el cuerpo principal para lo demás:
pago_mensual = function(capital, tasa = 0.01, plazo = 24) {
    if (tasa == 0) return(capital / plazo)   # sin interés: partes iguales
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

pago_mensual(250000, 0, 24)
# [1] 10416.67

# La guardia cuesta algo, y el costo se ve en la sección que sigue: la condición
# de un if tiene que ser un solo valor, así que esta versión ya no acepta el vector
# de tasas que la anterior aceptaba sin problema.

### La condición es una sola ----

# El error más frecuente de la sesión sale de olvidar que la condición se resuelve
# en un solo valor lógico. Con un vector, R no tiene manera de elegir una rama:
tasas_ofrecidas = c(0.008, 0.012, 0.025)

#   if (tasas_ofrecidas > 0.01) "alta" else "baja"
#
#   Error in if (tasas_ofrecidas > 0.01) "alta" else "baja" :
#     the condition has length > 1

# Hasta R 4.1 esa línea corría: R usaba el primer elemento del vector y seguía
# adelante con un aviso. Hay mucho código publicado y varios libros de texto
# escritos bajo esa regla, así que el patrón todavía se encuentra. Desde la
# versión 4.2 es un error.

# La pregunta de fondo es qué se quería hacer. Clasificar cada tasa no es
# controlar el flujo del programa: es calcular una variable nueva a partir de otra,
# con un valor por elemento. Para eso están las funciones de la Sesión 3, que
# reciben el vector completo y devuelven un vector del mismo largo.
#
#   if          elige qué código corre           condición escalar   -> 1 rama
#   if_else()   calcula un valor por elemento     condición vectorial -> n valores
#   case_when() lo mismo con varias condiciones   condición vectorial -> n valores

if_else(tasas_ofrecidas > 0.01, "alta", "baja")
# [1] "baja" "alta" "alta"

case_when(
    tasas_ofrecidas < 0.01  ~ "baja",
    tasas_ofrecidas < 0.02  ~ "media",
    .default                = "alta"
)
# [1] "baja"  "media" "alta"

# Regla para decidir cuál toca: si la condición mira una columna o una serie,
# ninguna de las dos es un if. Si mira un resultado ya calculado —un conteo, una
# bandera, un nombre de archivo— entonces sí.

# La función de hace un momento tropieza con esta misma regla, y el ejemplo vale
# doble porque el mensaje sale de adentro de una función propia:
#
#   pago_mensual(creditos$capital, creditos$tasa, creditos$plazo)
#
#   Error in if (tasa == 0) return(capital/plazo) :
#     the condition has length > 1
#
# Es la misma llamada que corrió sin problema antes de agregarle la guardia. Lo
# que la rompió fue el if, y ahora hay que elegir: una función escalar con
# guardia, o una vectorizada sin ella. La tercera opción es escribir la guardia
# con if_else(), y es la que pide el bloque de práctica.

### El faltante en la condición ----

# Un NA en la condición produce un error distinto, y el mensaje no dice qué lo
# provocó. Es un error de producción más que de clase: la tabla traía un hueco
# donde el código suponía un número.
monto = creditos$capital[8]   # el octavo crédito no tiene monto capturado
monto
# [1] NA

#   if (monto > 100000) "grande" else "chico"
#
#   Error in if (monto > 100000) "grande" else "chico" :
#     valor ausente donde TRUE/FALSE es necesario

# La razón es que monto > 100000 devuelve NA, y con NA no hay rama que elegir: R
# no puede decidir entre dos alternativas cuando no sabe si la condición se
# cumple. El faltante se atiende antes que todo lo demás, con su propia rama.
if (is.na(monto)) {
    "sin dato"
} else if (monto > 100000) {
    "grande"
} else {
    "chico"
}
# [1] "sin dato"

#| nota
# Los mensajes de error de R base están traducidos y aparecen en español si el
# locale está en español. Los del tidyverse siempre salen en inglés. Decirlo aquí
# y decir para qué importa: al buscar un error en internet, la versión en inglés
# encuentra resultados y la traducida casi nunca. Quien quiera ver los mensajes en
# inglés puede correr Sys.setenv(LANGUAGE = "en") al inicio de la sesión.
#| fin

## switch() --------------------------------------------------------------------=

# PARA QUÉ SIRVE. Hay un caso particular de decisión que aparece seguido: una
# variable puede tomar unos pocos valores conocidos, y a cada valor le
# corresponde una cosa distinta. El nombre del mes y sus días; la periodicidad de
# un pago y el número de periodos al año; el formato de un archivo y la función
# que lo lee.
#
# Eso escrito con else if son cinco o seis comparaciones seguidas contra la misma
# variable, y el lector tiene que leerlas todas para reconstruir la lista de casos.
# switch() lo escribe como lo que es: una tabla de correspondencias.

# CÓMO SE COMPORTA. Recibe un valor y una serie de argumentos con nombre. Busca
# el nombre que coincide exactamente con el valor y devuelve lo que le corresponde;
# los demás argumentos no se evalúan siquiera. Un último argumento sin nombre hace
# de caso por omisión y atrapa todo lo que no coincidió.

# EN CÓDIGO. La periodicidad del crédito decide cuántos periodos tiene un año:
periodicidad = "mensual"

periodos = switch(periodicidad,
    mensual    = 12,
    trimestral = 4,
    semestral  = 2,
    anual      = 1,
    stop(paste0("Periodicidad desconocida: ", periodicidad))   # caso por omisión
)

periodos
# [1] 12

# Y con eso, la tasa anual equivalente a la mensual del crédito:
round((1 + tasa)^periodos - 1, 4)
# [1] 0.1268

# El caso por omisión es la parte que se olvida y la que más cuesta. Sin él, un
# valor no previsto no produce error: switch() devuelve NULL, de forma invisible,
# y el programa sigue con un NULL adentro que va a reventar diez líneas después,
# lejos de donde estuvo la causa.
otra = switch("quincenal", mensual = 12, trimestral = 4, anual = 1)
is.null(otra)
# [1] TRUE

# Dos advertencias sobre la coincidencia. Es exacta y distingue mayúsculas, así
# que "Mensual" no empareja con mensual. Y si el valor que llega es un número,
# switch() cambia de reglas y selecciona por posición, cosa que casi nunca es lo
# que se quiere: conviene pasarle siempre texto.

# switch() vuelve a aparecer en el cierre de la sesión, eligiendo con qué función
# leer un archivo. Fuera de este uso —repartir sobre unas pocas etiquetas
# conocidas— no hace falta: para condiciones numéricas o compuestas va el if.


# LOOPS ________________________________________________________________________

## for -------------------------------------------------------------------------=

# PARA QUÉ SIRVE. Repetir un bloque de código una vez por cada elemento de una
# colección, con una sola cosa cambiando entre pasada y pasada. Es la traducción
# directa de "para cada uno de estos, haz lo siguiente".

# CÓMO SE COMPORTA. Antes de empezar, R tiene la secuencia completa. En cada
# pasada asigna el siguiente elemento a la variable del loop y ejecuta el cuerpo.
# Dos consecuencias que sorprenden al principio:
#
#   1. El loop no devuelve nada. No es una expresión con valor, es una
#      instrucción: lo único que queda de él son los efectos que dejó, y dentro
#      del cuerpo hay que pedir explícitamente que se imprima lo que interese.
#   2. La variable del loop es una variable común. Se sobrescribe en cada pasada
#      y al terminar sigue existiendo, con el último valor que tomó.

# EN CÓDIGO. Tres años de capitalización del crédito, uno por pasada:
for (anio in 1:3) {
    print(paste0("Año ", anio, ": el capital crece por ",
        round((1 + tasa)^(12 * anio), 3)))
}
# [1] "Año 1: el capital crece por 1.127"
# [1] "Año 2: el capital crece por 1.27"
# [1] "Año 3: el capital crece por 1.431"

# Y la variable sigue ahí después del loop, con el valor de la última pasada:
anio
# [1] 3

### El loop que no se puede evitar ----

# La tabla de amortización de un crédito es el ejemplo donde el loop es la única
# forma de calcular. El saldo de cada mes se obtiene del saldo del mes anterior:
#
#   saldo(t + 1) = saldo(t) * (1 + tasa) - pago
#
# No hay manera de calcular el mes 7 sin haber calculado el 6. La operación no se
# puede repartir entre elementos independientes, y es por eso que la sección de
# vectorización que viene más adelante no va a poder reemplazar este loop.

# El pago fijo que liquida el crédito en `plazo` meses ya tiene nombre: es la
# función de la primera sección, llamada con los valores del preámbulo.
pago = pago_mensual(capital, tasa, plazo)
round(pago, 2)
# [1] 11768.37

### Pre-asignar la salida ----

# PARA QUÉ SIRVE. Un vector en R tiene un tamaño fijo. Al asignar en una posición
# que no existe, R no lo estira: crea un vector nuevo, más grande, copia lo que
# había y descarta el anterior. Un loop que agrega un elemento por pasada paga esa
# copia muchas veces.
#
# La alternativa es crear el contenedor una sola vez, del tamaño final y del tipo
# correcto, y que el loop solo escriba adentro. En un vector de mil elementos la
# diferencia es de milisegundos; en uno de un millón se mide con reloj, y eso se
# ve en la sección de vectorización.

# CÓMO SE COMPORTA. numeric(n) devuelve n ceros, character(n) devuelve n textos
# vacíos, logical(n) devuelve n FALSE, y vector("list", n) devuelve n huecos. Todos
# se llenan por posición.

# EN CÓDIGO. El molde tiene 25 lugares porque hay 24 pagos más el saldo inicial:
saldo = numeric(plazo + 1)
saldo[1] = capital           # el estado del que parte la recursión

for (t in seq_len(plazo)) {
    saldo[t + 1] = saldo[t] * (1 + tasa) - pago
}

round(head(saldo, 5), 2)
# [1] 250000.0 240731.6 231370.6 221915.9 212366.7

# Este loop itera sobre índices y no sobre valores, porque el índice se necesita
# dos veces: para leer la posición anterior y para escribir en la actual.

# Con el pago bien calculado, el saldo del último mes tiene que ser cero:
round(saldo[plazo + 1], 2)
# [1] 0

### Cero no siempre es cero ----

# Sin redondear, ese último saldo no es cero:
saldo[plazo + 1]
# [1] 3.528839e-10

# El cálculo está bien; lo que pasa es que las computadoras guardan los decimales
# en binario y con un número finito de dígitos. Igual que un tercio no tiene
# escritura decimal exacta, 0.01 no tiene escritura binaria exacta, así que cada
# operación arrastra un error de redondeo diminuto. Veinticuatro operaciones
# encadenadas dejan un residuo del orden de 10^-10.

# La consecuencia práctica es que dos números que deberían ser iguales casi nunca
# lo son bit por bit:
saldo[plazo + 1] == 0
# [1] FALSE

# Las igualdades entre decimales se comparan con una tolerancia. all.equal()
# trae una razonable por defecto, del orden de 1.5e-8:
all.equal(saldo[plazo + 1], 0)
# [1] TRUE

# El ejemplo mínimo del mismo fenómeno, con dos decimales y una suma:
0.1 + 0.2 == 0.3
# [1] FALSE
all.equal(0.1 + 0.2, 0.3)
# [1] TRUE

# Una advertencia sobre all.equal(): cuando las cosas no son iguales no devuelve
# FALSE, devuelve un texto describiendo la diferencia. Adentro de un if hay que
# envolverla en isTRUE(), o el if recibe un texto y falla.
isTRUE(all.equal(0.1 + 0.2, 0.3))
# [1] TRUE

#| nota
# Dos minutos, no más, pero no se salta: de aquí sale la forma de verificar que
# usa el bloque de práctica. Si alguien pregunta por qué R imprime 0.3 cuando
# escribe 0.1 + 0.2, la respuesta es que imprime siete dígitos significativos por
# omisión y el error está en el decimoséptimo; print(0.1 + 0.2, digits = 20) lo
# muestra.
#| fin

### seq_along() y seq_len() ----

# PARA QUÉ SIRVEN. Construir la secuencia de índices sobre la que itera el loop.
# La forma obvia, 1:length(x), tiene un defecto que solo aparece con datos
# particulares, y por eso es peligrosa: cuando el vector viene vacío, en vez de no
# iterar, itera dos veces.

# CÓMO SE COMPORTA. El operador : cuenta hacia atrás si el segundo extremo es
# menor que el primero, y con un vector vacío el segundo extremo es cero.
pagos_extra = numeric(0)   # el cliente no hizo pagos adelantados

1:length(pagos_extra)
# [1] 1 0

# seq_along() construye la secuencia a partir del vector y seq_len() a partir de
# un conteo. Las dos devuelven una secuencia vacía cuando no hay nada que
# recorrer, que es lo que un loop necesita para no hacer nada.
seq_along(pagos_extra)
# integer(0)
seq_len(0)
# integer(0)

# El vector vacío aparece solo: es lo que devuelve un filter() que no encontró
# ninguna fila, y llega al loop sin que nadie lo haya previsto.


## while -----------------------------------------------------------------------=

# PARA QUÉ SIRVE. Repetir mientras una condición se cumpla, sin saber de antemano
# cuántas pasadas van a hacer falta. El for recorre una colección conocida; el
# while busca, y el número de pasadas es parte de la respuesta.
#
# Los usos habituales son de ese tipo: iterar hasta que un algoritmo converja,
# leer una fuente hasta que se agote, o —como aquí— averiguar cuánto tarda en
# liquidarse una deuda con un abono dado.

# CÓMO SE COMPORTA. R evalúa la condición antes de cada pasada. Si es TRUE corre
# el cuerpo y vuelve a evaluarla; si es FALSE termina. Nada garantiza que eso
# ocurra: quien escribe el loop es responsable de que el cuerpo modifique algo
# que, con el tiempo, vuelva falsa la condición.

# EN CÓDIGO. ¿Cuántos meses tarda en liquidarse el crédito si el cliente abona
# 12,000 fijos en vez del pago calculado?
saldo_actual = capital
meses = 0

while (saldo_actual > 0) {
    meses = meses + 1
    saldo_actual = saldo_actual * (1 + tasa) - 12000
}

meses
# [1] 24

# El saldo terminó en negativo, y esa cifra también responde algo: el último abono
# no tenía que ser de 12,000, sino de la diferencia.
round(saldo_actual, 2)
# [1] -6247.92

### El loop infinito ----

# La condición del ejemplo anterior se vuelve falsa porque el abono es mayor que
# el interés del mes. Si fuera menor, la deuda crecería en cada pasada y el loop
# no terminaría nunca. El interés del primer mes es de 2,500:
capital * tasa
# [1] 2500

# Con un abono de 2,000 el saldo no baja jamás. La protección estándar es una
# condición adicional que acote el número de pasadas, de modo que el problema se
# vuelva visible en la salida en lugar de colgar la sesión:
saldo_actual = capital
meses = 0

while (saldo_actual > 0 && meses < 600) {
    meses = meses + 1
    saldo_actual = saldo_actual * (1 + tasa) - 2000
}

meses
# [1] 600

# El 600 que devuelve es el tope, no la respuesta. Un while que se detiene
# exactamente en su tope hay que leerlo como un loop que no terminó, y el saldo
# confirma el diagnóstico:
round(saldo_actual)
# [1] 19779170

#| nota
# Sin el tope la sesión se cuelga y hay que interrumpir con Esc, o con el botón de
# stop en Positron. Hacerlo a propósito una vez: es la única forma de que
# reconozcan la sensación, y además deja a la vista que el objeto quedó a medio
# construir, que es el precio de trabajar con efectos en el ambiente en vez de con
# funciones.
#| fin

## break y next ----------------------------------------------------------------=

# PARA QUÉ SIRVEN. Interrumpir la secuencia normal del loop. next abandona la
# pasada actual y continúa con la siguiente; break abandona el loop completo. Son
# el equivalente, dentro de la iteración, de la decisión que toma un if.
#
# El uso más común de next es descartar los elementos que no sirven, sin tener que
# anidar el resto del cuerpo dentro de un if. El de break es dejar de buscar
# cuando ya se encontró lo que se buscaba.

# EN CÓDIGO. Cinco solicitudes de crédito, dos con montos imposibles:
solicitudes = c(250000, -5000, 180000, 0, 320000)

for (i in seq_along(solicitudes)) {
    if (solicitudes[i] <= 0) {
        message(paste0("Solicitud ", i, ": monto inválido (",
            solicitudes[i], "), se salta."))
        next
    }

    print(paste0("Solicitud ", i, ": pago mensual de ",
        round(pago_mensual(solicitudes[i]))))
}
# [1] "Solicitud 1: pago mensual de 11768"
# Solicitud 2: monto inválido (-5000), se salta.
# [1] "Solicitud 3: pago mensual de 8473"
# Solicitud 4: monto inválido (0), se salta.
# [1] "Solicitud 5: pago mensual de 15064"

# El mismo recorrido con break, buscando la primera solicitud que excede el límite
# de autorización automática. En cuanto la encuentra, no tiene sentido seguir:
for (i in seq_along(solicitudes)) {
    if (solicitudes[i] > 300000) {
        print(paste0("La solicitud ", i, " excede el límite de autorización."))
        break
    }
}
# [1] "La solicitud 5 excede el límite de autorización."

# Hay una diferencia importante entre este next y el tryCatch() de la sección de
# errores, aunque las dos cosas sirvan para que el loop no se caiga. Aquí el aviso
# se fue a la consola y se perdió; con tryCatch() el problema queda guardado en un
# objeto y se puede reportar al final. Un proceso que corre sin nadie mirando
# necesita lo segundo.

## Cuándo se justifica un loop -------------------------------------------------=

# El loop no está prohibido. Está en segundo lugar, y hay tres situaciones en que
# es la primera y única opción:
#
#   1. Cada pasada necesita el resultado de la anterior. La tabla de
#      amortización, una serie recursiva, un algoritmo iterativo.
#   2. Lo que importa son los efectos y no un valor de salida: leer archivos,
#      escribirlos, imprimir, hacer peticiones a un servidor.
#   3. El número de pasadas no se conoce, que es el caso del while.
#
# Fuera de esos tres, casi siempre hay una versión vectorizada, y es la que sigue.


# VECTORIZACIÓN ________________________________________________________________

## Qué significa que R sea vectorizado -----------------------------------------=

# PARA QUÉ SIRVE. En la mayoría de los lenguajes, sumar 1% a una lista de saldos
# se escribe recorriendo la lista. En R se escribe saldos * 1.01, y el recorrido
# lo hace el lenguaje. No es un atajo de notación: las operaciones aritméticas y
# lógicas de R están definidas sobre vectores completos, y el vector de un solo
# elemento es apenas el caso particular más corto.
#
# El recorrido sigue existiendo, pero ocurre dentro de código compilado en C, no
# en el intérprete. De ahí salen las dos ventajas: el código dice qué se calcula
# en vez de cómo se recorre, y el costo por elemento desaparece.

# CÓMO SE COMPORTA. La operación se aplica posición por posición y devuelve un
# vector del mismo largo. Las comparaciones devuelven lógicos, las funciones
# matemáticas devuelven números, y un NA en la entrada deja un NA en esa misma
# posición de la salida sin afectar a las demás ni detener el cálculo.

# EN CÓDIGO. Las cinco tasas de inflación, en puntos porcentuales:
tasas_anuales * 100
# [1] 4.1 5.2 3.3 4.8 3.9

# Entre dos vectores del mismo largo, también posición por posición. La desviación
# de cada año respecto del promedio del periodo:
tasas_anuales - mean(tasas_anuales)
# [1] -0.0016  0.0094 -0.0096  0.0054 -0.0036

# Las comparaciones producen un vector lógico, que es el insumo de filter():
tasas_anuales > 0.04
# [1]  TRUE  TRUE FALSE  TRUE FALSE

# Y el faltante se queda quieto en su lugar:
creditos$capital / 1000
# [1] 250 180 320  95 410 150 275  NA

# Esto explica por dentro los verbos de la Sesión 3. mutate() no recorre filas:
# evalúa una expresión vectorizada sobre la columna entera, y por eso la expresión
# que se le escribe es la misma que se escribiría fuera de la tabla.
creditos |> mutate(tasa_anual = round((1 + tasa)^12 - 1, 4)) |> select(folio, tasa, tasa_anual)
# # A tibble: 8 × 3
#   folio   tasa tasa_anual
#   <chr>  <dbl>      <dbl>
# 1 C001  0.012       0.154
# 2 C002  0.0145      0.189
# 3 C003  0.0099      0.126

## El mismo cálculo, tres veces ------------------------------------------------=

# La comparación que sigue tiene un millón de elementos para que las diferencias
# se puedan medir. El cálculo es trivial —multiplicar por 1.16— y lo único que
# cambia es cómo se escribe el recorrido.
n = 1e6
x = runif(n)

# (a) Loop que agrega un elemento en cada pasada. Cada vez que el vector se queda
#     sin espacio reservado, R asigna uno más grande y copia lo que había.
system.time({
    y = c()
    for (i in seq_len(n)) y[i] = x[i] * 1.16
})
#    user  system elapsed
#   0.126   0.022   0.162

# (b) El mismo loop con la salida pre-asignada. La lógica es idéntica; lo único
#     que cambia es que el contenedor se creó completo desde el principio.
system.time({
    y = numeric(n)
    for (i in seq_len(n)) y[i] = x[i] * 1.16
})
#    user  system elapsed
#   0.034   0.001   0.034

# (c) Vectorizado. Una llamada, sin índices, sin contenedor y sin cuerpo de loop.
system.time({
    y = x * 1.16
})
#    user  system elapsed
#   0.000   0.000   0.001

# Pre-asignar cuesta la cuarta parte que dejar crecer el vector. Vectorizar baja
# otro orden de magnitud, con una línea en lugar de cuatro.

#| nota
# Los tiempos cambian entre corridas y entre máquinas; lo que se sostiene es el
# orden. Aclarar que el argumento principal no tiene que ver con la velocidad: con
# ocho créditos las tres versiones terminan al mismo tiempo, y (c) se prefiere
# porque cabe en un renglón y no tiene ningún índice que equivocar. Un millón de
# elementos es más de lo que tiene cualquier tabla del curso.
#| fin

## Reglas de recycling ---------------------------------------------------------=

# PARA QUÉ SIRVE. La regla que permite escribir saldos * 1.01 es que R, cuando los
# dos operandos tienen distinto largo, repite el corto desde el principio hasta
# completar el largo del otro. Con un escalar y un vector, que es el caso para el
# que se pensó, hace exactamente lo que uno espera.

# CÓMO SE COMPORTA. La repetición no se limita al escalar: R la aplica con
# cualquier par de largos. Si el largo mayor es múltiplo del menor, lo hace en
# silencio; si no lo es, completa a medias y avisa con un warning.
1:6 * 2
# [1]  2  4  6  8 10 12

1:6 + c(0, 100)
# [1]   1 102   3 104   5 106

1:6 + 1:4
# [1] 2 4 6 8 6 8
# Aviso:
# In 1:6 + 1:4 :
#   longitud de objeto mayor no es múltiplo de la longitud de uno menor
# Aviso: longitud de objeto mayor no es múltiplo de la longitud de uno menor

# Los dos últimos casos son los peligrosos, porque el resultado tiene el largo
# correcto, el tipo correcto y los valores mal. Nada en la salida delata que hubo
# una repetición que nadie pidió.

# El tidyverse decidió no heredar esa regla: dentro de mutate() solo se recicla lo
# de largo 1, y cualquier otro desajuste es un error.
#
#   creditos |> mutate(bandera = c(TRUE, FALSE))
#
#   Error in `mutate()`:
#   ℹ In argument: `bandera = c(TRUE, FALSE)`.
#   Caused by error:
#   ! `bandera` must be size 8 or 1, not 2.

# Esa es la regla que conviene adoptar también fuera del tidyverse: reciclar lo de
# largo 1 y desconfiar de todo lo demás.

## Funciones acumuladoras ------------------------------------------------------=

# PARA QUÉ SIRVEN. Hay una familia de cálculos que parecen exigir un loop y no lo
# exigen: los que en cada posición resumen todo lo que venía antes. El saldo
# acumulado de una serie de flujos, el nivel de precios que dejan varias tasas de
# inflación, el máximo alcanzado hasta cada fecha.
#
# R los tiene resueltos y vectorizados para las cuatro operaciones más comunes:
# cumsum() para la suma, cumprod() para el producto, cummax() y cummin() para los
# extremos. Devuelven un vector del mismo largo que la entrada, donde la posición
# k es el resultado de aplicar la operación a los primeros k elementos.

# EN CÓDIGO. Las tasas de inflación no se suman: cada año se aplica sobre el nivel
# de precios que dejó el anterior, así que los factores se multiplican.
cumprod(1 + tasas_anuales)
# [1] 1.041000 1.095132 1.131271 1.185572 1.231810

# El último valor es el nivel de precios al final del periodo, y de ahí sale la
# inflación acumulada de los cinco años. Comparada con la suma de las tasas:
round(100 * (prod(1 + tasas_anuales) - 1), 1)
# [1] 23.2
round(100 * sum(tasas_anuales), 1)
# [1] 21.3

# Casi dos puntos de diferencia en cinco años, y la brecha crece con el número de
# periodos y con el nivel de las tasas.

# Las acumuladoras combinan bien con which.max(), que sobre un vector lógico
# devuelve la posición del primer TRUE. Con las dos se contesta en qué momento una
# serie cruzó un umbral, sin recorrerla:
which.max(cumprod(1 + tasas_anuales) >= 1.10)
# [1] 3

# cummax() sobre una serie de precios da el máximo alcanzado hasta cada fecha, que
# es el punto de partida para medir caídas desde el pico:
precios = c(102.4, 103.1, 104.8, 104.2, 106.9, 108.3)

cummax(precios)
# [1] 102.4 103.1 104.8 104.8 106.9 108.3

# En sentido contrario, diff() devuelve la diferencia entre cada elemento y el
# anterior. El primero no tiene anterior, así que la salida trae un elemento menos
# que la entrada, y de ahí vienen la mitad de los errores de largo al trabajar con
# series de tiempo.
diff(precios)
# [1]  0.7  1.7 -0.6  2.7  1.4
length(precios)
# [1] 6
length(diff(precios))
# [1] 5

## Contrapatrones de iteración -------------------------------------------------=

# Los tres que más aparecen, con lo que va en su lugar:
#
#   Crecer el vector dentro del loop        ->  pre-asignar, o vectorizar
#   Iterar con 1:length(x)                  ->  seq_along(x) o seq_len(n)
#   Recorrer filas para llenar una columna  ->  mutate() con if_else o case_when
#
# El tercero es el más frecuente, y llega siempre de la misma parte: de quien
# aprendió a programar en un lenguaje donde no había otra opción. Escrito con
# loop, clasificar el atraso de ocho créditos toma diez líneas y cuatro índices:
etiqueta = character(nrow(creditos))

for (i in seq_len(nrow(creditos))) {
    if (creditos$atraso[i] == 0) {
        etiqueta[i] = "al corriente"
    } else if (creditos$atraso[i] <= 2) {
        etiqueta[i] = "atraso leve"
    } else {
        etiqueta[i] = "atraso grave"
    }
}

etiqueta
# [1] "al corriente" "atraso leve"  "al corriente" "atraso grave" "al corriente"
# [6] "atraso leve"  "al corriente" "al corriente"

# Con la herramienta correcta, una expresión. No hay contenedor que declarar, no
# hay índices, y no existe la posibilidad de desalinear el resultado respecto de
# la tabla:
creditos |>
    mutate(etiqueta = case_when(
        atraso == 0  ~ "al corriente",
        atraso <= 2  ~ "atraso leve",
        .default     = "atraso grave"
    )) |>
    count(etiqueta)
# # A tibble: 3 × 2
#   etiqueta         n
#   <chr>        <int>
# 1 al corriente     5
# 2 atraso grave     1
# 3 atraso leve      2

#| nota
# Este es el patrón que hay que perseguir al revisar código ajeno. Con ocho filas
# las dos versiones tardan lo mismo, así que el rendimiento no viene al caso. Lo
# que cambia es cuánto hay que leer para convencerse de que el resultado está
# bien: en la primera versión, cuatro índices y el largo del contenedor.
# Preguntarlo así a la clase antes de mostrar la segunda.
#| fin


# AMBIENTES Y DISEÑO DE FUNCIONES ______________________________________________

# La primera tanda de funciones cubrió lo que hace falta para escribir una y
# usarla. Esta segunda cubre las tres cosas que se preguntan después de haber
# escrito unas cuantas: cómo pasar argumentos a otra función sin nombrarlos, dónde
# busca R los nombres que el cuerpo menciona, y qué distingue a una función con la
# que se puede razonar de una con la que no.

## El argumento ... ------------------------------------------------------------=

# PARA QUÉ SIRVE. Cuando una función existe para llamar a otra, replicar la lista
# completa de argumentos ajenos es trabajo perdido y se desactualiza. Los tres
# puntos recogen todo lo que la función no nombró y lo pasan tal cual a la que se
# llama adentro.
resumen_numerico = function(x, ...) {
    c(media = mean(x, ...), mediana = median(x, ...), maximo = max(x, ...))
}

# Sin argumentos extra, el faltante de la columna contamina los tres resultados:
resumen_numerico(creditos$capital)
#   media mediana  maximo
#      NA      NA      NA

# na.rm no aparece en la definición de resumen_numerico(), pero viaja por el ... y
# llega a las tres funciones de adentro al mismo tiempo:
resumen_numerico(creditos$capital, na.rm = TRUE)
#   media mediana  maximo
#  240000  250000  410000

# El precio del ... es que un argumento mal escrito no produce error: la función no
# tiene forma de saber que nadie lo esperaba, y lo pasa a donde se ignora.

## Scoping léxico --------------------------------------------------------------=

# PARA QUÉ SIRVE ENTENDERLO. Todo lo que pasa adentro de una función pasa en un
# lugar propio. Ese lugar se llama ambiente, y es una correspondencia entre nombres
# y valores. Cada llamada crea uno nuevo, con los argumentos ya asociados a sus
# valores, y ese ambiente se descarta cuando la función termina.
#
# Cuando el cuerpo menciona un nombre, R lo busca primero ahí. Si no lo encuentra,
# sube al ambiente donde la función fue DEFINIDA, y de ahí sigue subiendo hasta el
# ambiente global y los paquetes cargados. La cadena la fija el lugar del texto
# donde se escribió la función, no el lugar desde donde se la llamó, y a eso se le
# llama scoping léxico.

# CÓMO SE COMPORTA. La primera consecuencia es que asignar adentro no toca nada de
# afuera, incluso usando un nombre que ya existe:
f = function() {
    tasa = 0.99
    tasa
}

f()
# [1] 0.99
tasa
# [1] 0.01

# La segunda es que los objetos intermedios no sobreviven. Una función puede
# calcular en diez pasos sin dejar diez objetos en el entorno, y por eso es la
# unidad de trabajo limpia frente a un script de arriba abajo:
g = function() {
    parcial = 1:10
    sum(parcial)
}

g()
# [1] 55
exists("parcial")
# [1] FALSE

### La dependencia silenciosa ----

# La segunda mitad de la regla de búsqueda tiene un costo. Si un nombre no está
# entre los argumentos, R no se detiene: lo busca afuera y casi siempre lo
# encuentra. La función corre, devuelve el número correcto, y depende de algo que
# no está declarado en su interfaz.
pago_mal = function(capital, plazo) {
    capital * tasa / (1 - (1 + tasa)^-plazo)   # tasa no es argumento
}

round(pago_mal(250000, 24), 2)
# [1] 11768.37

# Tres semanas después alguien cambia la tasa arriba en el script, por una razón
# que no tiene nada que ver. La llamada es idéntica y el resultado es otro:
tasa = 0.02
round(pago_mal(250000, 24), 2)
# [1] 13217.77

tasa = 0.01   # se restaura para lo que sigue

# Y si el objeto llega a borrarse, la función que venía funcionando deja de
# hacerlo, con un mensaje que habla de un objeto que la llamada no menciona:
#
#   rm(tasa)
#   pago_mal(250000, 24)
#
#   Error in pago_mal(250000, 24) : objeto 'tasa' no encontrado

# La versión correcta recibe todo lo que usa:
pago_bien = function(capital, tasa, plazo) {
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

round(pago_bien(250000, 0.01, 24), 2)
# [1] 11768.37

#| nota
# Hacer la pregunta al revés: ¿por qué R no falla de una vez si el objeto no es
# argumento? Porque es la misma regla que permite usar mean() o paste0() adentro
# de una función sin pasarlas como argumento. Las dos cosas son la misma búsqueda,
# y no se puede tener una sin la otra. Lo que hay es una convención: los datos
# entran por argumento, las funciones se buscan afuera.
#| fin

## Funciones puras y side effects ----------------------------------------------=

# PARA QUÉ SIRVE LA DISTINCIÓN. Una función es pura cuando su resultado depende
# solo de sus argumentos y no deja ningún rastro fuera de ella. Dos llamadas con la
# misma entrada dan lo mismo hoy, en marzo y en otra computadora, y para entender
# qué hace basta leerla.
#
# Todo lo demás es un side effect: escribir un archivo, imprimir en consola,
# graficar, modificar un objeto de afuera. No tienen nada de malo —un programa que
# no deja rastro no sirve de nada— pero conviene no mezclarlos con el cálculo,
# porque una función que calcula y además escribe no se puede probar sin ensuciar
# el disco.
#
#   calcular_*  /  clasificar_*  /  resumir_*     puras
#   leer_*      /  guardar_*     /  reportar_*    con side effect, y el nombre avisa

# El caso que sí es un defecto es modificar el ambiente global desde adentro. R lo
# permite con <<-, y produce funciones que cambian cosas que no se ven en la
# llamada:
contador = 0

registrar_mal = function() {
    contador <<- contador + 1   # modifica el global
}

registrar_mal(); registrar_mal()
contador
# [1] 2

# La convención del curso es no usar <<-. Lo que la función calcule, lo devuelve, y
# quien la llama decide dónde guardarlo.


# ERRORES Y DEBUGGING __________________________________________________________

## El sistema de condiciones ---------------------------------------------------=

# PARA QUÉ SIRVE. Una función propia se va a encontrar con entradas que no había
# previsto: un monto negativo, un texto donde iba un número, una tabla vacía. Lo
# que hace en ese momento es parte de su diseño, igual que lo que calcula.
#
# R tiene un mecanismo específico para eso. Cuando una función detecta algo
# anormal, SEÑALA una condición; no decide qué hacer con ella, solo la anuncia.
# Quien la llamó puede instalar manejadores para atenderla, y si nadie lo hace,
# R aplica el comportamiento por omisión. Las tres condiciones de uso diario se
# distinguen justamente por ese comportamiento:
#
#   message()   informa. No interrumpe. Sale por el canal de errores, así que no
#               se mezcla con el resultado ni se guarda al redirigir la salida.
#   warning()   advierte de algo sospechoso. No interrumpe. R las junta y las
#               imprime al terminar, que es por qué a veces aparecen todas juntas.
#   stop()      abandona la evaluación. Lo que venía después no corre.
#
# La diferencia entre message() y print() no es cosmética: print() es parte del
# resultado del programa y message() es parte de su diagnóstico. Solo el segundo
# se puede silenciar cuando estorba, con suppressMessages().

# EN CÓDIGO. Una validación que usa las tres:
validar_credito = function(capital, tasa, plazo) {
    if (!is.numeric(capital) || capital <= 0) {
        stop(paste0("capital tiene que ser un número positivo; llegó: ", capital, "."))
    }
    if (tasa < 0) {
        stop(paste0("la tasa no puede ser negativa; llegó: ", tasa, "."))
    }
    if (tasa > 0.05) {
        warning(paste0("tasa mensual de ", 100 * tasa,
            "%: ¿no estará en términos anuales?"))
    }

    message(paste0("Crédito válido: ", capital, " a ", plazo, " pagos."))
    invisible(TRUE)
}

validar_credito(250000, 0.01, 24)
# Crédito válido: 250000 a 24 pagos.

# invisible() devuelve el valor sin imprimirlo. Es lo que permite usar una función
# de validación en medio de un pipe sin que la consola se llene de salidas
# intermedias.

# El warning avisa y la función termina igual, devolviendo su valor:
validar_credito(250000, 0.12, 24)
# Crédito válido: 250000 a 24 pagos.
# Aviso:
# In validar_credito(250000, 0.12, 24) :
#   tasa mensual de 12%: ¿no estará en términos anuales?

# Y los dos casos que interrumpen, para correr en clase:
#
#   validar_credito(-5000, 0.01, 24)
#   Error in validar_credito(-5000, 0.01, 24) :
#     capital tiene que ser un número positivo; llegó: -5000.
#
#   validar_credito("mucho", 0.01, 24)
#   Error in validar_credito("mucho", 0.01, 24) :
#     capital tiene que ser un número positivo; llegó: mucho.

## Validación con stopifnot() --------------------------------------------------=

# PARA QUÉ SIRVE. Las condiciones que una función necesita para poder trabajar son
# su contrato, y el mejor momento para revisarlas es antes de calcular nada. Una
# función que falla en su primera línea deja un error que se entiende solo; una que
# falla a la mitad deja objetos a medio construir y un mensaje sobre algo que
# ocurrió tres pasos después de la causa.
#
# El criterio de qué revisar: lo que, si viene mal, produce un resultado
# EQUIVOCADO en vez de un error. Un tipo de dato, un signo, un largo, un entero que
# llegó con decimales. Lo que de todos modos va a reventar no necesita guardia.

# CÓMO SE COMPORTA. stopifnot() recibe varias condiciones y falla en la primera que
# no sea verdadera. Desde R 4.0 se le puede poner nombre a cada una, y ese nombre
# es el mensaje de error, que es lo que lo hace útil: sin nombre, el mensaje es la
# condición literal —"is.numeric(capital) is not TRUE"— que dice qué se violó pero
# no qué se esperaba.
pago_seguro = function(capital, tasa = 0.01, plazo = 24) {
    stopifnot(
        "capital tiene que ser numérico"  = is.numeric(capital),
        "capital tiene que ser positivo"  = all(capital > 0),
        "la tasa no puede ser negativa"   = tasa >= 0,
        "el plazo tiene que ser entero"   = plazo == round(plazo)
    )

    if (tasa == 0) return(capital / plazo)
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

round(pago_seguro(250000), 2)
# [1] 11768.37

# Las guardias en acción. Para correr en clase:
#
#   pago_seguro("250000")
#   Error in pago_seguro("250000") : capital tiene que ser numérico
#
#   pago_seguro(250000, plazo = 24.5)
#   Error in pago_seguro(250000, plazo = 24.5) : el plazo tiene que ser entero

# Nótese que all() envuelve la condición del signo. Es deliberado: la función
# acepta un vector de capitales, y sin all() la condición devolvería un vector y
# stopifnot() se quejaría de otra cosa.

## Captura con tryCatch() ------------------------------------------------------=

# PARA QUÉ SIRVE. stop() abandona la evaluación, y eso es correcto para una función
# suelta: el problema es de quien la llamó. Pero cuando la llamada está dentro de
# un proceso que recorre veinte casos, la falla del tercero no tiene por qué
# cancelar los diecisiete restantes.
#
# tryCatch() es la otra mitad del sistema de condiciones: instala manejadores
# mientras se evalúa una expresión. Si la condición se señala en cualquier punto,
# por profundo que sea, la evaluación de la expresión se abandona, corre el
# manejador que corresponde, y el valor que devuelve el manejador pasa a ser el
# valor de todo el tryCatch(). El error deja de ser fatal y se convierte en un
# valor que se puede revisar.

# CÓMO SE COMPORTA. El manejador recibe el objeto de la condición, del que sale el
# mensaje original con conditionMessage(). Conviene devolver algo del tipo que la
# expresión habría devuelto, para que la salida siga siendo homogénea.
resultado = tryCatch(
    pago_seguro(-5000),
    error = function(e) {
        message(paste0("No se pudo calcular: ", conditionMessage(e)))
        NA_real_
    }
)
# No se pudo calcular: capital tiene que ser positivo

resultado
# [1] NA

# Hay manejador para cada clase de condición, y un bloque finally que corre haya
# pasado lo que haya pasado y sirve para cerrar lo que se abrió:
#
#   tryCatch(expr,
#       error   = function(e) NA_real_,
#       warning = function(w) NA_real_,
#       finally = message("terminó")
#   )

### El lote que sobrevive a un caso roto ----

# El patrón completo junta lo de toda la sesión: pre-asignar la salida, envolver
# cada llamada en tryCatch(), registrar cuáles salieron bien y reportar al final.
# Cuatro escenarios de crédito, dos de ellos imposibles:
escenarios = tibble(
    nombre  = c("base", "sin monto", "tasa negativa", "plazo largo"),
    capital = c(250000, -5000, 180000, 320000),
    tasa    = c(0.010, 0.010, -0.020, 0.011),
    plazo   = c(24, 24, 36, 48)
)

pagos = numeric(nrow(escenarios))
ok = logical(nrow(escenarios))

for (i in seq_len(nrow(escenarios))) {
    pagos[i] = tryCatch(
        pago_seguro(escenarios$capital[i], escenarios$tasa[i], escenarios$plazo[i]),
        error = function(e) {
            message(paste0(escenarios$nombre[i], ": ", conditionMessage(e)))
            NA_real_
        }
    )
    ok[i] = !is.na(pagos[i])
}
# sin monto: capital tiene que ser positivo
# tasa negativa: la tasa no puede ser negativa

round(pagos, 2)
# [1] 11768.37       NA       NA  8616.60

paste0("Calculados ", sum(ok), " de ", nrow(escenarios), " escenarios. ",
    "Fallaron: ", paste(escenarios$nombre[!ok], collapse = ", "), ".")
# [1] "Calculados 2 de 4 escenarios. Fallaron: sin monto, tasa negativa."

# La diferencia con el next del loop de solicitudes es qué queda del problema. Allá
# el aviso se imprimió y se perdió; aquí quedó en dos objetos, `pagos` y `ok`, que
# se pueden contar, revisar y reportar cuando el proceso termine.

#| nota
# Este bloque reaparece en el bloque de práctica, así que conviene correrlo entero
# y dejarlo en pantalla mientras se explica. Mencionar que purrr tiene esto
# resuelto en una función, safely(), y que es tema de la Sesión 6: hoy se escribe a
# mano para saber qué hace por dentro.
#| fin

## traceback() y browser() -----------------------------------------------------=

# Dos herramientas de diagnóstico, y con saber cuándo sirve cada una alcanza.

# Mientras R evalúa, mantiene una pila de llamadas activas: la que se escribió,
# la que esa llamó, y así. El error se señala en la más profunda, que casi nunca
# es la que uno escribió. costo_total() no valida nada; la validación está una
# llamada más abajo:
costo_total = function(capital, tasa, plazo) {
    pago_seguro(capital, tasa, plazo) * plazo - capital
}

round(costo_total(250000, 0.01, 24), 2)
# [1] 32440.83

# Con un argumento mal escrito, el mensaje habla de pago_seguro(), que esta
# llamada nunca menciona. traceback(), corrido enseguida del error, muestra la
# pila y resuelve el desconcierto:
#
#   costo_total("250000", 0.01, 24)
#   Error in pago_seguro(capital, tasa, plazo) : capital tiene que ser numérico
#
#   traceback()
#   4: stop(...)
#   3: stopifnot("capital tiene que ser numérico" = is.numeric(capital), ...)
#   2: pago_seguro(capital, tasa, plazo)
#   1: costo_total("250000", 0.01, 24)
#
# Se lee de abajo hacia arriba: el 1 es lo que se escribió, el 4 es donde reventó,
# y el intermedio es el que recibió el argumento equivocado.

# browser() contesta la otra pregunta, la de con qué valores: se pega en el cuerpo
# de la función, R se detiene ahí y entrega la consola con los objetos locales. El
# prompt cambia a Browse[1]> y se sale con Q. En Positron se consigue lo mismo con
# un breakpoint en el margen, sin tocar el código.

#| nota
# Tres minutos para toda la sección, y dos de ellos son la demostración en vivo de
# browser(): pegar la línea en costo_total(), llamarla con "250000", teclear
# `capital` y `class(capital)`, salir con Q, volver a comentar la línea. No hay
# forma de enseñarlo en una diapositiva y no hay mucho más que decir de él.
#| fin


# FUNCIONES QUE RECIBEN COLUMNAS _______________________________________________

## Por qué dplyr necesita una regla aparte -------------------------------------=

# PARA QUÉ SIRVE ENTENDERLO. En R, los argumentos de una función se evalúan antes
# de que el cuerpo empiece a correr, y se evalúan donde está escrita la llamada.
# Por eso mean(x) necesita que x exista: para cuando mean() arranca, ya recibió un
# vector de números.
#
# dplyr hace algo distinto. Al llamar filter(creditos, atraso > 0), la expresión
# atraso > 0 NO se evalúa en la consola —donde `atraso` no existe— sino que se
# captura sin evaluar y se evalúa después, en un ambiente donde las columnas de la
# tabla están visibles como si fueran objetos. Ese mecanismo se llama data masking,
# y es lo que permite escribir los nombres de columna sin comillas y sin repetir el
# nombre de la tabla en cada mención.
#
# El precio aparece al escribir funciones propias. El nombre de columna que se pasa
# como argumento es una expresión, no un valor, y hay que decirle a dplyr qué hacer
# con ella.

# CÓMO SE COMPORTA. Escrita de la manera natural, la función no funciona:
resumen_mal = function(datos, variable) {
    datos |> summarize(media = mean(variable, na.rm = TRUE))
}

#   resumen_mal(creditos, atraso)
#
#   Error in `summarize()`:
#   ℹ In argument: `media = mean(variable, na.rm = TRUE)`.
#   Caused by error:
#   ! object 'atraso' not found

# Lo que summarize() recibió fue la expresión `variable`, tal como está escrita en
# el cuerpo. La buscó como columna de la tabla, no la encontró, y al no hallarla en
# ninguna parte reportó el nombre que el argumento traía adentro.

### El caso que no da error ----

# Peor que el error es el silencio. Si el nombre existe fuera de la tabla, la
# búsqueda tiene éxito en el ambiente global y la función devuelve un número
# equivocado sin avisar. `capital` es a la vez una columna de la tabla y el escalar
# que se declaró al abrir la sesión:
resumen_mal(creditos, capital)
# # A tibble: 1 × 1
#    media
#    <dbl>
# 1 250000

# Ese 250,000 es el escalar del preámbulo. El promedio de los ocho créditos es otro
# número:
mean(creditos$capital, na.rm = TRUE)
# [1] 240000

# Es el mismo tipo de falla que el join que no emparejaba nada de la Sesión 4: la
# salida tiene la forma esperada, una tabla de un renglón con una columna media, y
# el contenido no corresponde a nada. Ninguna revisión de dimensiones lo detecta.

## El operador {{ }} -----------------------------------------------------------=

# PARA QUÉ SIRVE. Le dice a dplyr: no evalúes mi argumento, toma la expresión que
# trae adentro e insértala aquí como si la hubieran escrito en este lugar. Con eso,
# el nombre de columna llega hasta el ambiente donde las columnas son visibles.

# CÓMO SE COMPORTA. Se escribe en cada lugar donde el argumento se usa, y funciona
# en cualquier argumento que dplyr evalúe dentro de la tabla, incluido .by.
resumen_variable = function(datos, variable) {
    datos |>
        summarize(
            casos     = n(),
            faltantes = sum(is.na({{ variable }})),
            media     = mean({{ variable }}, na.rm = TRUE),
            mediana   = median({{ variable }}, na.rm = TRUE)
        )
}

resumen_variable(creditos, capital)
# # A tibble: 1 × 4
#   casos faltantes  media mediana
#   <int>     <int>  <dbl>   <dbl>
# 1     8         1 240000  250000

resumen_variable(creditos, atraso)
# # A tibble: 1 × 4
#   casos faltantes media mediana
#   <int>     <int> <dbl>   <dbl>
# 1     8         0  0.75       0

# La misma idea con el grupo como argumento. Con dos huecos, una función contesta
# toda una familia de preguntas:
resumen_por = function(datos, grupo, variable) {
    datos |>
        summarize(
            casos = n(),
            media = mean({{ variable }}, na.rm = TRUE),
            .by   = {{ grupo }}
        ) |>
        arrange(desc(media))
}

resumen_por(creditos, banco, capital)
# # A tibble: 3 × 3
#   banco  casos  media
#   <chr>  <int>  <dbl>
# 1 Sur        3 275000
# 2 Norte      3 215000
# 3 Centro     2 212500

resumen_por(creditos, banco, tasa)
# # A tibble: 3 × 3
#   banco  casos  media
#   <chr>  <int>  <dbl>
# 1 Centro     2 0.0142
# 2 Norte      3 0.0132
# 3 Sur        3 0.0130

resumen_por(creditos, atraso, capital)
# # A tibble: 4 × 3
#   atraso casos  media
#    <dbl> <int>  <dbl>
# 1      0     5 313750
# 2      2     1 180000
# 3      1     1 150000
# 4      3     1  95000

# Lo que se ganó no es escribir menos. Antes, cada una de esas tres respuestas era
# un summarize() completo, y bastaba que en uno se olvidara na.rm para que dejaran
# de ser comparables. Ahora la decisión está en un solo lugar.

## Nombres dinámicos con := ----------------------------------------------------=

# PARA QUÉ SIRVE. El problema inverso: no recibir el nombre de una columna, sino
# construir el de una columna nueva. El lado izquierdo de un = dentro de mutate()
# se toma literalmente, así que no hay forma de calcularlo; := existe justamente
# para eso, y acepta un nombre armado como texto, con {{ }} adentro de las comillas.
en_miles = function(datos, variable) {
    datos |> mutate("{{ variable }}_miles" := {{ variable }} / 1000)
}

creditos |>
    en_miles(capital) |>
    select(folio, capital, capital_miles)
# # A tibble: 8 × 3
#   folio capital capital_miles
#   <chr>   <dbl>         <dbl>
# 1 C001   250000           250
# 2 C002   180000           180
# 3 C003   320000           320

## Cuando la columna llega como texto ------------------------------------------=

# PARA QUÉ SIRVE. {{ }} resuelve el caso en que el nombre de la columna se escribe
# sin comillas en la llamada. Cuando llega como texto —de un vector, de un archivo
# de configuración, del argumento de un script— el mecanismo es otro: .data es un
# pronombre que representa la tabla que se está evaluando, y con doble corchete
# busca una columna por su nombre.
resumen_texto = function(datos, columna) {
    datos |> summarize(media = mean(.data[[columna]], na.rm = TRUE))
}

resumen_texto(creditos, "capital")
# # A tibble: 1 × 1
#    media
#    <dbl>
# 1 240000

# Esta es la versión que sirve para iterar, porque los nombres se pueden guardar en
# un vector y recorrerlos. Con un loop, hoy; con map(), en la Sesión 6.
for (col in c("capital", "tasa", "plazo")) {
    print(paste0(col, ": ", round(mean(creditos[[col]], na.rm = TRUE), 4)))
}
# [1] "capital: 240000"
# [1] "tasa: 0.0133"
# [1] "plazo: 33"


# CIERRE _______________________________________________________________________

# Una función que junta casi todo lo de la sesión: valida sus argumentos antes de
# calcular, decide con un if, itera con un for porque el saldo de cada mes depende
# del anterior, y devuelve un objeto sin dejar rastro en el ambiente.
tabla_amortizacion = function(capital, tasa = 0.01, plazo = 24) {
    stopifnot(
        "capital tiene que ser positivo" = capital > 0,
        "la tasa no puede ser negativa"  = tasa >= 0,
        "el plazo tiene que ser entero"  = plazo == round(plazo)
    )

    pago = pago_seguro(capital, tasa, plazo)

    saldo = numeric(plazo + 1)
    saldo[1] = capital

    for (t in seq_len(plazo)) {
        saldo[t + 1] = saldo[t] * (1 + tasa) - pago
    }

    tibble(
        mes           = seq_len(plazo),
        saldo_inicial = saldo[seq_len(plazo)],
        interes       = saldo_inicial * tasa,
        amortizacion  = pago - interes,
        saldo_final   = saldo[seq_len(plazo) + 1]
    )
}

amortizacion = tabla_amortizacion(250000, 0.01, 24)
amortizacion
# # A tibble: 24 × 5
#      mes saldo_inicial interes amortizacion saldo_final
#    <int>         <dbl>   <dbl>        <dbl>       <dbl>
#  1     1       250000    2500         9268.     240732.
#  2     2       240732.   2407.        9361.     231371.
#  3     3       231371.   2314.        9455.     221916.
#  4     4       221916.   2219.        9549.     212367.
#  5     5       212367.   2124.        9645.     202722.

# Devolver una tabla en lugar de imprimir permite verificar el resultado, que es la
# razón de haberla escrito así. Las dos comprobaciones que tienen que dar TRUE:
all.equal(sum(amortizacion$amortizacion), 250000)   # ¿se pagó todo el capital?
# [1] TRUE
all.equal(last(amortizacion$saldo_final), 0)        # ¿quedó liquidado?
# [1] TRUE

# Y el dato que le interesa a quien pide el crédito, que es la suma de intereses:
round(sum(amortizacion$interes), 2)
# [1] 32440.83

# Lo que queda de la sesión, en ocho líneas:
#
#   1. if decide qué código corre y su condición es escalar. Clasificar los
#      elementos de un vector es otra cosa, y para eso están if_else y case_when.
#   2. El loop es la segunda opción: se justifica cuando cada pasada depende de la
#      anterior, cuando lo que importa son los efectos, o cuando no se sabe cuántas
#      pasadas van a hacer falta.
#   3. Si se escribe un loop, la salida se pre-asigna y los índices salen de
#      seq_along() o seq_len().
#   4. Los decimales no se comparan con ==, sino con all.equal() dentro de isTRUE().
#   5. Tres repeticiones del mismo patrón justifican una función: un propósito, un
#      nombre que lo diga, y todo lo que usa entrando por argumentos.
#   6. La validación va en las primeras líneas del cuerpo, con mensajes que digan
#      qué se esperaba.
#   7. tryCatch() convierte un error en un valor, y con eso un proceso frágil pasa
#      a ser uno que reporta.
#   8. Para pasar columnas a una función propia: {{ }} si vienen sin comillas,
#      .data con doble corchete si vienen como texto.

#| nota
# Cerrar con las dos deudas de la sesión. La primera: el loop del lote de
# escenarios tiene ocho líneas y solo dos hacen el trabajo; las otras seis son
# mecánica que se repite igual en cualquier lote, y eso es lo que map() quita en la
# Sesión 6. La segunda: hoy no se tocó la EIGH, y la Sesión 6 vuelve a ella con
# estas herramientas —una función de lectura, map() sobre varios levantamientos y
# ggplot2—. Lo de hoy es la mitad del camino, no un paréntesis.
#| fin
