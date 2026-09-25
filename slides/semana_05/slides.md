---
theme: default
title: "Control de flujo, vectorización y funciones"
subtitle: Sesión 5 — Programación para Proyectos de Datos I
author: Daniel Kelly
date: Otoño 2026
canvasWidth: 1280
highlighter: shiki
shiki:
  themes:
    light: github-light
    dark: github-dark
lineNumbers: false
drawings:
  persist: false
transition: slide-left
mdc: true
layout: cover
---
---
layout: default
section: Sesión 5
subsection: Mapa de la Sesión
---
# ¿Dónde estamos?
Cuatro sesiones usando funciones ajenas. Esta escribe las [propias]{.colmex-blue}.

Hasta aquí, los errores posibles eran del dato: un delimitador mal identificado, una llave que no emparejaba, un faltante que se colaba en una suma. A partir de hoy también pueden ser del razonamiento, y ese es un tipo de error distinto.

Por eso esta sesión [no lee ningún archivo]{.colmex-orange}. Sus temas son propiedades del lenguaje y se entienden mejor sobre objetos de tres líneas, donde el resultado esperado se puede calcular a mano.

### Contenido de la sesión

1. [**Funciones**]{.colmex-orange} — qué es, anatomía, argumentos, valor de retorno.
2. [**Condicionales**]{.colmex-blue} — `if`, `else`, la guardia de una función, `switch()`.
3. [***Loops***]{.colmex-blue} — `for`, `while`, pre-asignación, `break` y `next`.
4. [**Vectorización**]{.colmex-orange} — el modo por defecto de R, y los contrapatrones que lo ignoran.
5. [**Ambientes y diseño**]{.colmex-orange} — `...`, *scoping*, funciones puras.
6. [**Errores y *debugging***]{.colmex-orange} — el sistema de condiciones y cómo se diagnostica una falla.
7. [**Columnas como argumentos**]{.colmex-blue} — por qué `dplyr` necesita una regla aparte.

<Azul t="La sesión abre con funciones">

`pago_mensual()` queda escrita en los primeros quince minutos y a partir de ahí todas las secciones la llaman, en vez de repetir la fórmula cuatro veces. Lo que se ve al final es lo que pide kilometraje: ambientes, pureza, validación.

</Azul>
---
layout: default
section: Sesión 5
subsection: Mapa de la Sesión
---
# Todo lo que necesita la sesión
Tres escalares, una serie de tasas y una tabla escrita a mano.

```r
capital = 250000     # monto del crédito, en pesos
tasa    = 0.01       # interés MENSUAL, en tanto por uno
plazo   = 24         # número de pagos

tasas_anuales = c(0.041, 0.052, 0.033, 0.048, 0.039)

creditos = tibble(
    folio   = c("C001", "C002", ..., "C008"),
    banco   = c("Norte", "Norte", "Sur", ..., "Norte"),
    capital = c(250000, 180000, 320000, 95000, 410000, 150000, 275000, NA),
    tasa    = c(0.012, 0.0145, 0.0099, 0.018, 0.011, 0.0155, 0.0128, 0.013),
    plazo   = c(24, 36, 48, 12, 60, 24, 36, 24),
    atraso  = c(0, 2, 0, 3, 0, 1, 0, 0)
)
```

El hilo es una [calculadora de crédito]{.colmex-orange}. La tabla de amortización va a ser el ejemplo central: es el caso donde el *loop* es obligatorio, porque cada saldo se calcula sobre el anterior.
---
layout: default
section: Sesión 5
subsection: Mapa de la Sesión
---
# Cómo se arman los mensajes
Casi todo lo que sigue imprime algo, y en R base los mensajes se pegan con `paste0()`.

```r
paste0("Crédito de ", capital, " pesos a ", plazo, " meses.")
# [1] "Crédito de 250000 pesos a 24 meses."
```

`paste0()` une las piezas sin separador y convierte los números a texto por su cuenta, así que el redondeo hay que pedirlo. `paste()` hace lo mismo con un espacio entre piezas, y con `collapse` hace otra cosa: convierte un vector en un solo texto.

```r
paste(c("hogares", "personas", "gastos"), collapse = ", ")
# [1] "hogares, personas, gastos"

paste0("crédito ", creditos$folio[1:3])            # vectorizado: entran 3, salen 3
# [1] "crédito C001" "crédito C002" "crédito C003"
```

<Verde t="Las dos se confunden todo el tiempo">

Con varios argumentos, `paste0()` y `paste()` operan elemento a elemento y devuelven un vector. Con `collapse`, devuelven un texto de largo 1.

</Verde>
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# Funciones
---
layout: default
section: Sesión 5
subsection: Funciones
---
# Qué es una función
Ponerle nombre a un cálculo y dejar huecos donde están las partes que cambian.

Eso es todo, y de ahí salen los tres beneficios que importan:

1. [**El nombre dice qué significa el resultado**]{.colmex-orange}, que es más de lo que dice la fórmula.
2. [**Si el cálculo estaba mal, se corrige en un solo lugar.**]{.colmex-orange}
3. [**Se puede probar aparte**]{.colmex-orange}, con un caso cuyo resultado se conoce de antemano.

<br>

Lo que justifica escribirla es la repetición, y no el tamaño del cálculo. El ETL de la Sesión 4 leyó tres tablas con tres líneas casi idénticas, y el bloque de práctica repitió el mismo `case_when()` en dos lugares distintos.

La función de hoy es la mensualidad de un crédito, y se escribe aquí porque todas las secciones que siguen la van a llamar: el *loop* de la tabla de amortización, el lote de escenarios del `tryCatch()` y el cierre.

<br>

Al llamarla, R abre un ambiente nuevo, asocia cada argumento con el valor que le tocó, evalúa el cuerpo ahí adentro y devuelve el valor de la última expresión que evaluó. `return()` no hace falta para eso.

<Verde t="La regla de tres">

Tres apariciones del mismo patrón justifican encapsularlo. A la tercera, o antes si el patrón ya se ve venir.

</Verde>
---
layout: default
section: Sesión 5
subsection: Funciones
---
# Anatomía
Tres partes, y las tres se pueden inspeccionar.

```r
pago_mensual = function(capital, tasa, plazo) {
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

round(pago_mensual(250000, 0.01, 24), 2)   # [1] 11768.37
```

```r
formals(pago_mensual)       # los argumentos: lo que entra
body(pago_mensual)          # el cuerpo: lo que hace
environment(pago_mensual)   # el ambiente: dónde busca los nombres
```

La tercera es la que nadie escribe y la que explica los comportamientos raros; vuelve en la sección de *scoping*. Y como el cuerpo está armado con operaciones vectorizadas, la función hereda la vectorización sin haber hecho nada especial:

```r
round(pago_mensual(creditos$capital, creditos$tasa, creditos$plazo))
# [1] 12051  6453  8408  8873  9371  7532  9582    NA
```
---
layout: default
section: Sesión 5
subsection: Funciones
---
# Argumentos y valores por defecto
Los argumentos son la interfaz: lo único que el que llama tiene que saber.

Un argumento sin defecto es obligatorio; con defecto es opcional, y deja la decisión habitual escrita en la definición en vez de repetida en cada llamada.

```r
pago_mensual = function(capital, tasa = 0.01, plazo = 24) {
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

round(pago_mensual(250000), 2)                # [1] 11768.37
round(pago_mensual(250000, plazo = 36), 2)    # [1] 8303.58
```

Por nombre, el orden deja de importar y se pueden saltar los de en medio. Y ahí está el argumento a favor de escribir los nombres: los mismos tres valores en el orden equivocado no producen ningún error.

```r
round(pago_mensual(250000, 24, 0.01), 2)
# [1] 189416574        <- alguien va a copiar esto a un reporte
```

<Rojo t="Convención del curso">

El dato va por posición y todo lo demás por nombre. Una llamada con tres valores sueltos no se puede leer sin abrir la definición.

</Rojo>
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# Condicionales
---
layout: default
section: Sesión 5
subsection: Condicionales
---
# Qué decide un condicional
Una decisión sobre el programa, tomada una sola vez.

Un condicional elige [qué líneas se ejecutan]{.colmex-orange}. La decisión se toma antes de calcular nada y de ella depende cuál de dos bloques corre y cuál se ignora por completo: si el archivo no existe, avisar y detenerse; si la tabla viene vacía, no intentar el cálculo.

Eso es distinto de clasificar los elementos de un vector, que no decide nada sobre el programa: calcula una variable nueva, con un valor por elemento.

| Herramienta | Qué hace | Condición | Devuelve |
|---|---|---|---|
| `if` | elige qué código corre | escalar | una rama |
| `if_else()` | calcula un valor por elemento | vectorial | *n* valores |
| `case_when()` | lo mismo con varias condiciones | vectorial | *n* valores |

<Rojo t="La pregunta que resuelve el caso">

Si la condición mira una columna o una serie, no hay `if` que escribir. Si mira un resultado ya calculado —un conteo, una bandera, un nombre de archivo— entonces sí.

</Rojo>
---
layout: default
section: Sesión 5
subsection: Condicionales
---
# `if` y `else`
R evalúa la condición, elige la rama, y el resto del código ni se mira.

```r
if (tasa <= 0) {
    message("Crédito sin interés.")
} else if (tasa < 0.015) {
    message("Tasa moderada.")
} else {
    message("Tasa alta.")
}
# Tasa moderada.
```

El `else` va en la misma línea que la llave que cierra: en el renglón siguiente, R entiende que la instrucción terminó. Con varias ramas encadenadas, la primera condición verdadera gana y las demás ni se evalúan.

Un detalle que casi no se usa pero explica mucho: el condicional es una expresión y devuelve el valor de la rama que corrió. Por eso se puede asignar, y por eso las llaves sobran cuando cada rama es una sola expresión.

```r
tipo = if (plazo > 36) "largo plazo" else "corto plazo"
# [1] "corto plazo"
```
---
layout: default
section: Sesión 5
subsection: Condicionales
---
# La guardia de una función
El primer uso del `if` que aparece al escribir funciones propias.

Una guardia atiende un caso antes de llegar al cálculo general. El valor de una función es la última expresión que evaluó, así que `return()` no hace falta para devolver un resultado: sirve para lo contrario, para [salir antes de tiempo]{.colmex-orange} cuando el resto del cuerpo no aplica.

En `pago_mensual()` hay un caso así. Con tasa cero, el denominador de la fórmula vale cero:

```r
pago_mensual(250000, 0, 24)      # [1] NaN

pago_mensual = function(capital, tasa = 0.01, plazo = 24) {
    if (tasa == 0) return(capital / plazo)   # sin interés: partes iguales
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

pago_mensual(250000, 0, 24)      # [1] 10416.67
```

La guardia cuesta algo, y el costo se ve en la diapositiva que sigue: la condición de un `if` tiene que ser un solo valor, así que esta versión ya no acepta el vector de tasas que la anterior aceptaba sin problema.
---
layout: default
section: Sesión 5
subsection: Condicionales
---
# La condición es una sola
El error más frecuente de la sesión sale de olvidarlo.

```r
tasas_ofrecidas = c(0.008, 0.012, 0.025)

if (tasas_ofrecidas > 0.01) "alta" else "baja"
# Error in if (tasas_ofrecidas > 0.01) "alta" else "baja" :
#   the condition has length > 1
```

Hasta R 4.1 esa línea corría: R usaba el primer elemento del vector y seguía con un aviso. Hay mucho código publicado y varios libros escritos bajo esa regla. Desde la versión 4.2 es un error.

La función de la sección anterior tropieza con la misma regla, y el ejemplo vale doble porque el mensaje sale de adentro de una función propia:

```r
pago_mensual(creditos$capital, creditos$tasa, creditos$plazo)
# Error in if (tasa == 0) return(capital/plazo) : the condition has length > 1
```

Es la misma llamada que corrió sin problema [antes de agregarle la guardia]{.colmex-orange}. Ahora hay que elegir: una función escalar con guardia, o una vectorizada sin ella. La tercera opción es escribir la guardia con `if_else()`, y es la que pide el bloque de práctica.
---
layout: default
section: Sesión 5
subsection: Condicionales
---
# El faltante en la condición
`if` tampoco tolera un `NA`, y el mensaje no dice de dónde salió.

`monto > 100000` con `monto` faltante devuelve `NA`, y con `NA` no hay rama que elegir: R no puede decidir entre dos alternativas cuando no sabe si la condición se cumple.

```r
monto = creditos$capital[8]        # el octavo crédito no tiene monto capturado

if (monto > 100000) "grande" else "chico"
# Error: valor ausente donde TRUE/FALSE es necesario
```

El faltante se atiende antes que todo lo demás, con su propia rama:

```r
if (is.na(monto)) "sin dato" else if (monto > 100000) "grande" else "chico"
# [1] "sin dato"
```

<Azul t="Los mensajes de error y su idioma">

Los de R base se traducen según el *locale*; los del tidyverse siempre están en inglés. Al buscar un error en internet, [la versión en inglés encuentra resultados]{.colmex-blue} y la traducida casi nunca.

</Azul>
---
layout: default
section: Sesión 5
subsection: Condicionales
---
# `switch()`
Una variable con pocos valores conocidos, y una cosa distinta para cada uno.

El caso aparece seguido: el nombre del mes y sus días, la periodicidad de un pago y el número de periodos al año, el formato de un archivo y la función que lo lee. Escrito con `else if` son seis comparaciones seguidas contra la misma variable, y el lector tiene que leerlas todas para reconstruir la lista de casos.

`switch()` lo escribe como lo que es: una [tabla de correspondencias]{.colmex-orange}. Busca el nombre que coincide con el valor, devuelve lo que le toca, y ni evalúa los demás.

```r
periodos = switch(periodicidad,
    mensual    = 12,
    trimestral = 4,
    semestral  = 2,
    anual      = 1,
    stop(paste0("Periodicidad desconocida: ", periodicidad))   # caso por omisión
)
# [1] 12
```

<Rojo t="El caso por omisión es la parte que se olvida">

Sin ese último argumento sin nombre, un valor no previsto no da error: `switch()` devuelve `NULL` de forma invisible y el programa sigue, para reventar diez líneas después lejos de la causa. La coincidencia además es exacta: `"Mensual"` no empareja con `mensual`.

</Rojo>
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# *Loops*
---
layout: default
section: Sesión 5
subsection: Loops
---
# `for`
"Para cada uno de estos, haz lo siguiente."

Antes de empezar, R tiene la secuencia completa. En cada pasada asigna el siguiente elemento a la variable del *loop* y ejecuta el cuerpo.

```r
for (anio in 1:3) {
    print(paste0("Año ", anio, ": el capital crece por ",
        round((1 + tasa)^(12 * anio), 3)))
}
# [1] "Año 1: el capital crece por 1.127"
# [1] "Año 2: el capital crece por 1.27"
# [1] "Año 3: el capital crece por 1.431"
```

Dos consecuencias que sorprenden al principio:

1. El *loop* [no devuelve nada]{.colmex-orange}. No es una expresión con valor, es una instrucción: lo único que queda son los efectos que dejó, y adentro del cuerpo hay que pedir explícitamente que se imprima lo que interese.
2. La variable del *loop* es una variable común. Se sobrescribe en cada pasada y al terminar sigue existiendo, con el último valor que tomó.
---
layout: default
section: Sesión 5
subsection: Loops
---
# El *loop* que no se puede evitar
La tabla de amortización de un crédito.

```r
saldo(t + 1) = saldo(t) * (1 + tasa) - pago
```

El saldo de cada mes se obtiene del saldo del mes anterior. No hay manera de calcular el mes 7 sin haber calculado el 6, así que el cálculo no se puede repartir entre elementos independientes. [Esta es la primera de las tres situaciones]{.colmex-orange} en que el *loop* es la única opción.

<br>

Y hay una decisión de diseño antes de escribirlo: **dónde va la salida**. Un vector en R tiene tamaño fijo; al asignar en una posición que no existe, R crea un vector nuevo más grande, copia lo que había y descarta el anterior. Un *loop* que agrega un elemento por pasada paga esa copia muchas veces.

La alternativa es crear el contenedor una sola vez, del tamaño final y del tipo correcto, y que el *loop* solo escriba adentro.

```r
numeric(n)          # n ceros
character(n)        # n textos vacíos
logical(n)          # n FALSE
vector("list", n)   # n huecos
```
---
layout: default
section: Sesión 5
subsection: Loops
---
# La tabla, en código
El molde tiene 25 lugares: los 24 pagos más el saldo inicial.

```r
pago = capital * tasa / (1 - (1 + tasa)^-plazo)
# [1] 11768.37

saldo = numeric(plazo + 1)
saldo[1] = capital           # el estado del que parte la recursión

for (t in seq_len(plazo)) {
    saldo[t + 1] = saldo[t] * (1 + tasa) - pago
}

round(head(saldo, 5), 2)
# [1] 250000.0 240731.6 231370.6 221915.9 212366.7
```

Este *loop* itera sobre **índices** y no sobre valores, porque el índice se necesita dos veces: para leer la posición anterior y para escribir en la actual.

Con el pago bien calculado, el saldo del último mes tiene que ser cero:

```r
round(saldo[plazo + 1], 2)   # [1] 0
```
---
layout: default
section: Sesión 5
subsection: Loops
---
# Cero no siempre es cero
Sin redondear, ese último saldo no es cero.

```r
saldo[plazo + 1]     # [1] 3.528839e-10
```

El cálculo está bien. Las computadoras guardan los decimales en binario y con un número finito de dígitos: igual que un tercio no tiene escritura decimal exacta, `0.01` no tiene escritura binaria exacta, y cada operación arrastra un error de redondeo diminuto. Veinticuatro operaciones encadenadas dejan un residuo del orden de 10⁻¹⁰.

La consecuencia práctica es que dos números que deberían ser iguales casi nunca lo son bit por bit:

```r
saldo[plazo + 1] == 0            # [1] FALSE
all.equal(saldo[plazo + 1], 0)   # [1] TRUE     tolerancia de ~1.5e-8

0.1 + 0.2 == 0.3                 # [1] FALSE
isTRUE(all.equal(0.1 + 0.2, 0.3))   # [1] TRUE
```

<Rojo t="Una advertencia sobre all.equal()">

Cuando las cosas no son iguales devuelve un texto describiendo la diferencia, no `FALSE`. Adentro de un `if` hay que envolverla en `isTRUE()`, o el `if` recibe un texto y falla.

</Rojo>
---
layout: default
section: Sesión 5
subsection: Loops
---
# `seq_along()` y `seq_len()`
Construir la secuencia de índices sobre la que itera el *loop*.

La forma obvia, `1:length(x)`, tiene un defecto que solo aparece con datos particulares, y por eso es peligrosa. El operador `:` cuenta hacia atrás cuando el segundo extremo es menor que el primero, y con un vector vacío el segundo extremo es cero:

```r
pagos_extra = numeric(0)   # el cliente no hizo pagos adelantados

1:length(pagos_extra)    # [1] 1 0        <- dos pasadas, con índices que no existen
seq_along(pagos_extra)   # integer(0)     <- ninguna pasada
seq_len(0)               # integer(0)     <- lo mismo, a partir de un conteo
```

`seq_along()` construye la secuencia a partir del vector y `seq_len()` a partir de un conteo. Las dos devuelven una secuencia vacía cuando no hay nada que recorrer, que es lo que un *loop* necesita para no hacer nada.

<Verde t="Por qué importa">

El vector vacío aparece solo: es lo que devuelve un `filter()` que no encontró ninguna fila, y llega al *loop* sin que nadie lo haya previsto.

</Verde>
---
layout: default
section: Sesión 5
subsection: Loops
---
# `while`
Repetir mientras una condición se cumpla, sin saber cuántas pasadas harán falta.

El `for` recorre una colección conocida. El `while` **busca**, y el número de pasadas es parte de la respuesta: iterar hasta que un algoritmo converja, leer una fuente hasta agotarla, o averiguar cuánto tarda en liquidarse una deuda.

R evalúa la condición antes de cada pasada. Nada garantiza que llegue a ser falsa: quien escribe el *loop* es responsable de que el cuerpo modifique algo que, con el tiempo, la vuelva falsa.

```r
saldo_actual = capital
meses = 0

while (saldo_actual > 0) {
    meses = meses + 1
    saldo_actual = saldo_actual * (1 + tasa) - 12000   # abona 12,000 fijos
}

meses                      # [1] 24
round(saldo_actual, 2)     # [1] -6247.92
```

El saldo terminó en negativo, y esa cifra también responde algo: el último abono no tenía que ser de 12,000, sino de la diferencia.
---
layout: default
section: Sesión 5
subsection: Loops
---
# El *loop* infinito
La condición se volvió falsa porque el abono era mayor que el interés del mes.

Si fuera menor, la deuda crecería en cada pasada y el *loop* no terminaría nunca. El interés del primer mes es de 2,500 (`capital * tasa`), así que con un abono de 2,000 el saldo no baja jamás.

La protección estándar es una condición adicional que acote las pasadas, de modo que el problema se vea en la salida en vez de colgar la sesión:

```r
while (saldo_actual > 0 && meses < 600) {
    meses = meses + 1
    saldo_actual = saldo_actual * (1 + tasa) - 2000
}

meses                  # [1] 600
round(saldo_actual)    # [1] 19779170
```

El 600 que devuelve es el tope, no la respuesta. [Un `while` que se detiene exactamente en su tope es un `while` que no terminó]{.colmex-orange}, y el saldo confirma el diagnóstico.

<Azul t="Si pasa sin tope">

La sesión se queda colgada y hay que interrumpir con `Esc`, o con el botón de *stop* en Positron. El objeto queda a medio construir, que es el precio de trabajar con efectos sobre el ambiente en lugar de funciones.

</Azul>
---
layout: default
section: Sesión 5
subsection: Loops
---
# `break` y `next`
Interrumpir la secuencia normal del *loop*.

`next` abandona la pasada actual y continúa con la siguiente; `break` abandona el *loop* completo. Son, dentro de la iteración, el equivalente de la decisión que toma un `if`. El uso más común de `next` es descartar los elementos que no sirven sin anidar el resto del cuerpo:

```r
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
```

Hay una diferencia importante con el `tryCatch()` de la sección de errores, aunque las dos cosas eviten que el *loop* se caiga: aquí el aviso se imprimió y se perdió.
---
layout: default
section: Sesión 5
subsection: Loops
---
# Cuándo se justifica un *loop*
No está prohibido. Está en segundo lugar.

Hay tres situaciones en que es la primera y única opción:

1. [**Cada pasada necesita el resultado de la anterior.**]{.colmex-orange} La tabla de amortización, una serie recursiva, un algoritmo iterativo.
2. [**Lo que se busca son los efectos y no un valor.**]{.colmex-orange} Leer archivos, escribirlos, imprimir, hacer peticiones a un servidor.
3. [**El número de pasadas no se conoce.**]{.colmex-orange} El caso del `while`.

<br>

Fuera de esos tres, casi siempre existe una versión vectorizada, y es la que sigue.

<Verde t="La pregunta que lo resuelve">

*¿El elemento 7 se puede calcular sin haber calculado el 6?* Si la respuesta es sí, no hay *loop* que escribir.

</Verde>
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# Vectorización
---
layout: default
section: Sesión 5
subsection: Vectorización
---
# Qué significa que R sea vectorizado
El recorrido existe, pero no lo escribe quien usa el lenguaje.

En la mayoría de los lenguajes, sumar 1% a una lista de saldos se escribe recorriendo la lista. En R se escribe `saldos * 1.01`. No es un atajo de notación: las operaciones aritméticas y lógicas de R [están definidas sobre vectores completos]{.colmex-orange}, y el vector de un solo elemento es apenas el caso más corto.

El recorrido ocurre dentro de código compilado en C, no en el intérprete. De ahí salen las dos ventajas, en este orden de importancia:

1. El código dice **qué** se calcula en lugar de **cómo** se recorre, así que no hay índices que equivocar.
2. El costo por elemento desaparece.

<br>

La operación se aplica posición por posición y devuelve un vector del mismo largo. Las comparaciones devuelven lógicos, las funciones matemáticas devuelven números, y un `NA` en la entrada deja un `NA` en esa misma posición sin afectar a las demás.

<Verde t="Esto explica los verbos de la Sesión 3">

`mutate()` no recorre filas: evalúa una expresión vectorizada sobre la columna entera. Por eso la expresión que se le escribe es la misma que se escribiría fuera de la tabla.

</Verde>
---
layout: default
section: Sesión 5
subsection: Vectorización
---
# En código
Las cinco tasas de inflación, operadas de cuatro maneras.

```r
tasas_anuales * 100                  # [1] 4.1 5.2 3.3 4.8 3.9
tasas_anuales - mean(tasas_anuales)  # [1] -0.0016  0.0094 -0.0096  0.0054 -0.0036
tasas_anuales > 0.04                 # [1]  TRUE  TRUE FALSE  TRUE FALSE
creditos$capital / 1000              # [1] 250 180 320  95 410 150 275  NA
```

La segunda línea opera entre dos vectores del mismo largo, posición por posición. La tercera produce el vector lógico que es el insumo de `filter()`. La cuarta muestra el faltante quedándose quieto en su lugar.

```r
creditos |>
    mutate(tasa_anual = round((1 + tasa)^12 - 1, 4)) |>
    select(folio, tasa, tasa_anual)
# A tibble: 8 × 3
  folio   tasa tasa_anual
  <chr>  <dbl>      <dbl>
1 C001  0.012       0.154
2 C002  0.0145      0.189
3 C003  0.0099      0.126
```
---
layout: default
section: Sesión 5
subsection: Vectorización
---
# El mismo cálculo, tres veces
Un millón de elementos para que las diferencias se puedan medir.

```r
n = 1e6
x = runif(n)

system.time({ y = c();          for (i in seq_len(n)) y[i] = x[i] * 1.16 })
#    user  system elapsed
#   0.123   0.019   0.142     <- agrega un elemento por pasada: copia y copia

system.time({ y = numeric(n);   for (i in seq_len(n)) y[i] = x[i] * 1.16 })
#   0.033   0.000   0.034     <- la misma lógica, con el contenedor completo

system.time({ y = x * 1.16 })
#   0.000   0.000   0.001     <- vectorizado
```

Pre-asignar cuesta la cuarta parte que dejar crecer el vector. Vectorizar baja otro orden de magnitud, con una línea en lugar de cuatro.

<Verde t="El argumento no pasa por la velocidad">

Con ocho créditos las tres versiones terminan al mismo tiempo. La tercera se prefiere porque cabe en un renglón y no tiene ningún índice que equivocar; un millón de elementos es más de lo que tiene cualquier tabla del curso.

</Verde>
---
layout: default
section: Sesión 5
subsection: Vectorización
---
# Reglas de *recycling*
La regla que permite escribir `saldos * 1.01`, y hasta dónde llega.

Cuando los dos operandos tienen distinto largo, R repite el corto desde el principio hasta completar el largo del otro. Con un escalar y un vector, que es el caso para el que se pensó, hace lo que uno espera. El problema es que R **no se limita al escalar**:

```r
1:6 * 2              # [1]  2  4  6  8 10 12
1:6 + c(0, 100)      # [1]   1 102   3 104   5 106    <- en silencio: 6 es múltiplo de 2
1:6 + 1:4            # [1] 2 4 6 8 6 8
# Aviso: longitud de objeto mayor no es múltiplo de la longitud de uno menor
```

Los dos últimos casos son los peligrosos: el resultado tiene el largo correcto, el tipo correcto y los valores mal. Nada en la salida delata que hubo una repetición que nadie pidió.

El tidyverse decidió no heredar la regla. Dentro de `mutate()` solo se recicla lo de largo 1:

```r
creditos |> mutate(bandera = c(TRUE, FALSE))
# Error in `mutate()`: ! `bandera` must be size 8 or 1, not 2.
```
---
layout: default
section: Sesión 5
subsection: Vectorización
---
# Funciones acumuladoras
Cálculos que parecen exigir un *loop* y no lo exigen.

Son los que en cada posición resumen todo lo que venía antes: el saldo acumulado de una serie de flujos, el nivel de precios que dejan varias tasas de inflación, el máximo alcanzado hasta cada fecha. R los tiene vectorizados para las cuatro operaciones más comunes — `cumsum()`, `cumprod()`, `cummax()`, `cummin()` — y devuelven un vector del mismo largo, donde la posición *k* resulta de aplicar la operación a los primeros *k* elementos.

```r
cumprod(1 + tasas_anuales)            # las tasas no se suman: se encadenan
# [1] 1.041000 1.095132 1.131271 1.185572 1.231810

round(100 * (prod(1 + tasas_anuales) - 1), 1)   # [1] 23.2   acumulada
round(100 * sum(tasas_anuales), 1)              # [1] 21.3   suma de las tasas
```

Casi dos puntos de diferencia en cinco años, y la brecha crece con el número de periodos. Combinadas con `which.max()`, que sobre un lógico da la posición del primer `TRUE`, contestan en qué momento una serie cruzó un umbral:

```r
which.max(cumprod(1 + tasas_anuales) >= 1.10)   # [1] 3

precios = c(102.4, 103.1, 104.8, 104.2, 106.9, 108.3)
cummax(precios)   # [1] 102.4 103.1 104.8 104.8 106.9 108.3   el pico hasta cada fecha
diff(precios)     # [1]  0.7  1.7 -0.6  2.7  1.4              un elemento MENOS
```
---
layout: default
section: Sesión 5
subsection: Vectorización
---
# Contrapatrones
Crecer el vector dentro del *loop*; iterar con `1:length(x)`; y este, el más frecuente:

**recorrer filas para llenar una columna**, que se reemplaza con `mutate()` y `case_when()`.

```r
etiqueta = character(nrow(creditos))            # 10 líneas, 4 índices, 1 contenedor
for (i in seq_len(nrow(creditos))) {
    if (creditos$atraso[i] == 0) {
        etiqueta[i] = "al corriente"
    } else if (creditos$atraso[i] <= 2) {
        etiqueta[i] = "atraso leve"
    } else {
        etiqueta[i] = "atraso grave"
    }
}
```

```r
creditos |> mutate(etiqueta = case_when(   # 1 expresión, 0 índices
    atraso == 0 ~ "al corriente",
    atraso <= 2 ~ "atraso leve",
    .default    = "atraso grave"
))
```
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# Ambientes y diseño
---
layout: default
section: Sesión 5
subsection: Ambientes y diseño
---
# El argumento `...`
Cuando una función existe para llamar a otra.

Replicar la lista completa de argumentos ajenos es trabajo perdido y se desactualiza en cuanto el otro paquete cambia. Los tres puntos recogen lo que la función no nombró y lo pasan tal cual a la que se llama adentro:

```r
resumen_numerico = function(x, ...) {
    c(media = mean(x, ...), mediana = median(x, ...), maximo = max(x, ...))
}

resumen_numerico(creditos$capital)                 #     NA      NA      NA
resumen_numerico(creditos$capital, na.rm = TRUE)   # 240000  250000  410000
```

`na.rm` no aparece en la definición de `resumen_numerico()`, pero viaja por el `...` y llega a las tres funciones de adentro al mismo tiempo.

<Rojo t="El precio de los tres puntos">

Un argumento mal escrito no produce error: la función no tiene forma de saber que nadie lo esperaba, y lo pasa a donde se ignora en silencio.

</Rojo>
---
layout: default
section: Sesión 5
subsection: Ambientes y diseño
---
# *Scoping* léxico
Todo lo que pasa adentro de una función pasa en un lugar propio.

Ese lugar se llama **ambiente**, y es una correspondencia entre nombres y valores. Cada llamada crea uno nuevo, con los argumentos ya asociados a sus valores, y se descarta cuando la función termina. Cuando el cuerpo menciona un nombre, R lo busca primero ahí; si no lo encuentra, sube al ambiente donde la función fue [definida]{.colmex-orange} —no donde fue llamada— y sigue subiendo:

```r
    ambiente de la llamada  ->  ambiente de definición  ->  global  ->  paquetes
```

Que la cadena la fije el lugar del texto donde se escribió la función, y no el lugar desde donde se la llamó, es lo que se llama *scoping* léxico.

<Verde t="Las dos consecuencias que se usan a diario">

Asignar adentro no toca nada de afuera, ni siquiera usando un nombre que ya existe. Y los objetos intermedios no sobreviven: una función puede calcular en diez pasos sin dejar diez objetos en el entorno.

</Verde>
---
layout: default
section: Sesión 5
subsection: Ambientes y diseño
---
# Las dos consecuencias, en código
Lo que pasa adentro se queda adentro.

```r
f = function() {
    tasa = 0.99
    tasa
}

f()       # [1] 0.99
tasa      # [1] 0.01      <- intacto: asignar adentro no toca nada de afuera

g = function() {
    parcial = 1:10
    sum(parcial)
}

g()                  # [1] 55
exists("parcial")    # [1] FALSE     <- los objetos intermedios no sobreviven
```

Por eso la función es la unidad de trabajo limpia frente a un script de arriba abajo: el entorno no se llena de resultados intermedios que después nadie sabe si están actualizados.
---
layout: default
section: Sesión 5
subsection: Funciones
---
# La dependencia silenciosa
La segunda mitad de la regla de búsqueda tiene un costo.

Si un nombre no está entre los argumentos, R no se detiene: lo busca afuera y casi siempre lo encuentra. La función corre, devuelve el número correcto, y depende de algo que no está declarado en su interfaz.

```r
pago_mal = function(capital, plazo) {
    capital * tasa / (1 - (1 + tasa)^-plazo)   # tasa no es argumento
}

round(pago_mal(250000, 24), 2)   # [1] 11768.37

tasa = 0.02                      # tres semanas después, alguien la cambia arriba
round(pago_mal(250000, 24), 2)   # [1] 13217.77
```

La misma llamada, otro resultado, ningún aviso. Y si el objeto llega a borrarse, la función que venía funcionando deja de hacerlo con un mensaje que habla de algo que la llamada no menciona.

<Azul t="¿Y por qué R no falla de una vez?">

Porque es la misma regla que permite usar `mean()` o `paste0()` adentro de una función sin pasarlas como argumento. Las dos cosas son la misma búsqueda. Lo que hay es una convención: [los datos entran por argumento, las funciones se buscan afuera]{.colmex-blue}.

</Azul>
---
layout: default
section: Sesión 5
subsection: Funciones
---
# Puras y con *side effects*
Una función pura depende solo de sus argumentos y no deja rastro afuera.

Dos llamadas con la misma entrada dan lo mismo hoy, en marzo y en otra computadora, y para entender qué hace basta leerla. Todo lo demás es un *side effect*: escribir un archivo, imprimir, graficar, modificar un objeto de afuera.

No tienen nada de malo —un programa que no deja rastro no sirve de nada— pero conviene no mezclarlos con el cálculo, porque una función que calcula y además escribe no se puede probar sin ensuciar el disco.

| Convención de nombres | Qué esperar |
|---|---|
| `calcular_*`, `clasificar_*`, `resumir_*` | puras: entra algo, sale algo |
| `leer_*`, `guardar_*`, `reportar_*` | tocan el disco o la consola, y el nombre avisa |

```r
contador = 0
registrar_mal = function() contador <<- contador + 1   # cambia algo que no se ve
```

<Rojo t="Convención del curso">

`<<-` no se usa. Lo que la función calcule, lo devuelve, y quien la llama decide dónde guardarlo.

</Rojo>
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# Errores y *debugging*
---
layout: default
section: Sesión 5
subsection: Errores
---
# El sistema de condiciones
Qué hace una función cuando se encuentra con algo que no había previsto.

Eso es parte de su diseño, igual que lo que calcula. R tiene un mecanismo específico: cuando una función detecta algo anormal, [señala una condición]{.colmex-orange}. No decide qué hacer con ella, solo la anuncia. Quien la llamó puede instalar manejadores para atenderla, y si nadie lo hace, R aplica el comportamiento por omisión.

Las tres condiciones de uso diario se distinguen justamente por ese comportamiento:

| Función | Si nadie la atiende | Para qué |
|---|---|---|
| `message()` | imprime y continúa | informar. Sale por el canal de errores, así que no se mezcla con el resultado |
| `warning()` | imprime al terminar y continúa | advertir de algo sospechoso; por eso a veces aparecen todas juntas |
| `stop()` | abandona la evaluación | el problema impide seguir |

<Verde t="message() no es print()">

`print()` es parte del resultado del programa; `message()` es parte de su diagnóstico. Solo el segundo se puede silenciar cuando estorba, con `suppressMessages()`.

</Verde>
---
layout: default
section: Sesión 5
subsection: Errores
---
# Las tres, en una validación
Y `invisible()`, que es lo que la hace usable en un *pipe*.

```r
validar_credito = function(capital, tasa, plazo) {
    if (!is.numeric(capital) || capital <= 0) {
        stop(paste0("capital tiene que ser un número positivo; llegó: ", capital, "."))
    }
    if (tasa > 0.05) {
        warning(paste0("tasa mensual de ", 100 * tasa,
            "%: ¿no estará en términos anuales?"))
    }
    message(paste0("Crédito válido: ", capital, " a ", plazo, " pagos."))
    invisible(TRUE)
}

validar_credito(250000, 0.01, 24)   # Crédito válido: 250000 a 24 pagos.
validar_credito(-5000, 0.01, 24)    # Error: capital tiene que ser un número
                                    #   positivo; llegó: -5000.
```

`invisible()` devuelve el valor sin imprimirlo. El mensaje incluye [el valor que llegó]{.colmex-orange}, que es la diferencia entre un error que se arregla solo y uno que obliga a reconstruir la llamada.
---
layout: default
section: Sesión 5
subsection: Errores
---
# `stopifnot()`
Las condiciones que la función necesita para trabajar son su contrato.

El mejor momento para revisarlas es antes de calcular nada. Una función que falla en su primera línea deja un error que se entiende solo; una que falla a la mitad deja objetos a medio construir y un mensaje sobre algo que ocurrió tres pasos después de la causa.

```r
pago_seguro = function(capital, tasa = 0.01, plazo = 24) {
    stopifnot(
        "capital tiene que ser numérico" = is.numeric(capital),
        "capital tiene que ser positivo" = all(capital > 0),
        "la tasa no puede ser negativa"  = tasa >= 0,
        "el plazo tiene que ser entero"  = plazo == round(plazo)
    )
    if (tasa == 0) return(capital / plazo)
    capital * tasa / (1 - (1 + tasa)^-plazo)
}

pago_seguro(250000, plazo = 24.5)   # Error: el plazo tiene que ser entero
```

Desde R 4.0 el **nombre** de cada condición es el mensaje de error. Sin nombre, el mensaje es la condición literal — `is.numeric(capital) is not TRUE` — que dice qué se violó pero no qué se esperaba.

Qué revisar: lo que, si viene mal, produce un resultado [equivocado en vez de un error]{.colmex-blue} —un tipo, un signo, un largo, un entero con decimales—. Lo que de todos modos va a reventar no necesita guardia.
---
layout: default
section: Sesión 5
subsection: Errores
---
# `tryCatch()`
La otra mitad del sistema de condiciones: atenderlas en lugar de señalarlas.

`stop()` abandona la evaluación, y eso es correcto para una función suelta: el problema es de quien la llamó. Pero cuando la llamada está dentro de un proceso que recorre veinte casos, la falla del tercero no tiene por qué cancelar los diecisiete restantes.

`tryCatch()` instala manejadores mientras se evalúa una expresión. Si la condición se señala en cualquier punto, por profundo que sea, la evaluación se abandona, corre el manejador, y **el valor que devuelve el manejador pasa a ser el valor de todo el `tryCatch()`**. El error deja de ser fatal y se convierte en un valor que se puede revisar.

```r
resultado = tryCatch(
    pago_seguro(-5000),
    error = function(e) {
        message(paste0("No se pudo calcular: ", conditionMessage(e)))
        NA_real_
    }
)
# No se pudo calcular: capital tiene que ser positivo

resultado     # [1] NA
```

El manejador recibe el objeto de la condición, del que sale el mensaje original con `conditionMessage()`. Conviene devolver algo del tipo que la expresión habría devuelto, para que la salida siga siendo homogénea.
---
layout: default
section: Sesión 5
subsection: Errores
---
# El lote que sobrevive a un caso roto
Pre-asignar, capturar, registrar, reportar.

`escenarios` es un `tibble` de cuatro renglones —*base*, *sin monto*, *tasa negativa*, *plazo largo*— y dos de ellos traen valores imposibles.

```r
pagos = numeric(nrow(escenarios))
ok = logical(nrow(escenarios))

for (i in seq_len(nrow(escenarios))) {
    pagos[i] = tryCatch(
        pago_seguro(escenarios$capital[i], escenarios$tasa[i], escenarios$plazo[i]),
        error = function(e) NA_real_)
    ok[i] = !is.na(pagos[i])
}

round(pagos, 2)   # [1] 11768.37       NA       NA  8616.60
```

La diferencia con el `next` del *loop* de solicitudes es qué queda del problema. Allá el aviso se imprimió y se perdió; aquí quedó en dos objetos, `pagos` y `ok`, que se pueden contar y reportar cuando el proceso termine.
---
layout: default
section: Sesión 5
subsection: Errores
---
# Dónde falló: `traceback()`
Mientras R evalúa, mantiene una pila de llamadas activas.

El error se señala en la llamada más profunda, que casi nunca es la que se escribió, y el mensaje menciona una función que no aparece en la línea que se corrió.

```r
costo_total("250000", 0.01, 24)
# Error in pago_seguro(capital, tasa, plazo) : capital tiene que ser numérico

traceback()
# 4: stop(...)
# 3: stopifnot("capital tiene que ser numérico" = is.numeric(capital), ...)
# 2: pago_seguro(capital, tasa, plazo)
# 1: costo_total("250000", 0.01, 24)
```

Se lee de abajo hacia arriba: el 1 es lo que se escribió, el 4 es donde reventó, y el nivel intermedio es el que recibió el argumento equivocado.

<Azul t="Y con qué valores: browser()">

Detiene la ejecución dentro de la función y entrega la consola con los objetos locales. En Positron, lo mismo con un *breakpoint* en el margen. Se ve en vivo; no hay mucho más que decir de él.

</Azul>
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# Funciones que reciben columnas
---
layout: default
section: Sesión 5
subsection: Columnas como argumentos
---
# Por qué `dplyr` necesita una regla aparte
En R, los argumentos se evalúan antes de que el cuerpo empiece a correr.

Y se evalúan donde está escrita la llamada. Por eso `mean(x)` necesita que `x` exista: para cuando `mean()` arranca, ya recibió un vector de números.

`dplyr` hace algo distinto. Al llamar `filter(creditos, atraso > 0)`, la expresión `atraso > 0` no se evalúa en la consola —donde `atraso` no existe— sino que [se captura sin evaluar]{.colmex-orange} y se evalúa después, en un ambiente donde las columnas de la tabla están visibles como si fueran objetos. Ese mecanismo se llama *data masking*.

Es lo que permite escribir los nombres de columna sin comillas y sin repetir el nombre de la tabla en cada mención. El precio aparece al escribir funciones propias:

```r
resumen_mal = function(datos, variable) {
    datos |> summarize(media = mean(variable, na.rm = TRUE))
}

resumen_mal(creditos, atraso)
# Error in `summarize()`: ! object 'atraso' not found
```

Lo que `summarize()` recibió fue la expresión `variable`, tal como está escrita en el cuerpo. La buscó como columna, no la encontró, y al no hallarla en ninguna parte reportó el nombre que el argumento traía adentro.
---
layout: default
section: Sesión 5
subsection: Columnas como argumentos
---
# El caso que no da error
Peor que el error es el silencio.

Si el nombre existe fuera de la tabla, la búsqueda tiene éxito en el ambiente global y la función devuelve un número equivocado sin avisar. `capital` es a la vez una columna de `creditos` y el escalar que se declaró al abrir la sesión:

```r
resumen_mal(creditos, capital)
# A tibble: 1 × 1
   media
   <dbl>
1 250000        <- el escalar del preámbulo

mean(creditos$capital, na.rm = TRUE)
# [1] 240000     <- el promedio de los ocho créditos
```

<Rojo t="Por qué este error es de los peores">

Es el mismo tipo de falla que el *join* que no emparejaba nada de la Sesión 4: la salida tiene la forma esperada, una tabla de un renglón con una columna `media`, y el contenido no corresponde a nada. [Ninguna revisión de dimensiones lo detecta.]{.colmex-orange}

</Rojo>
---
layout: default
section: Sesión 5
subsection: Columnas como argumentos
---
# El operador *embrace*
"No evalúes mi argumento: toma la expresión que trae adentro e insértala aquí."

Con eso, el nombre de columna llega hasta el ambiente donde las columnas son visibles. Se escribe en cada lugar donde el argumento se usa, y funciona en cualquier argumento que `dplyr` evalúe dentro de la tabla, incluido `.by`.

```r
resumen_por = function(datos, grupo, variable) {
    datos |>
        summarize(casos = n(),
                  media = mean({{ variable }}, na.rm = TRUE),
                  .by = {{ grupo }}) |>
        arrange(desc(media))
}

resumen_por(creditos, banco, capital)
#   banco  casos  media
# 1 Sur        3 275000
# 2 Norte      3 215000
# 3 Centro     2 212500
```

La misma función contesta `resumen_por(creditos, banco, tasa)` o `resumen_por(creditos, atraso, capital)`. Lo que se ganó no es escribir menos: antes, cada respuesta era un `summarize()` completo, y bastaba que en uno se olvidara `na.rm` para que dejaran de ser comparables.
---
layout: default
section: Sesión 5
subsection: Columnas como argumentos
---
# `:=` y `.data`
Dos problemas más, y cada uno tiene su herramienta.

**Construir el nombre de una columna nueva.** El lado izquierdo de un `=` dentro de `mutate()` se toma literalmente, así que no hay forma de calcularlo. `:=` existe para eso, y acepta un nombre armado como texto:

```r
en_miles = function(datos, variable) {
    datos |> mutate("{{ variable }}_miles" := {{ variable }} / 1000)
}
creditos |> en_miles(capital) |> select(folio, capital, capital_miles)
# 1 C001   250000           250
```

**Recibir el nombre como texto**, de un vector o de un archivo de configuración. `.data` es un pronombre que representa la tabla que se está evaluando:

```r
resumen_texto = function(datos, columna) {
    datos |> summarize(media = mean(.data[[columna]], na.rm = TRUE))
}
resumen_texto(creditos, "capital")   # 240000
```

Esta última es la versión que sirve para iterar, porque los nombres se pueden guardar en un vector y recorrerlos. Con un *loop* hoy; con `map()`, en la Sesión 6.
---
layout: section
eyebrow: Sesión 5 — Bloque de exposición
---
# Cierre
---
layout: default
section: Sesión 5
subsection: Cierre
---
# Todo junto
Valida, decide, itera porque no hay otra opción, y devuelve un objeto.

```r
tabla_amortizacion = function(capital, tasa = 0.01, plazo = 24) {
    stopifnot("capital tiene que ser positivo" = capital > 0,
              "la tasa no puede ser negativa"  = tasa >= 0,
              "el plazo tiene que ser entero"  = plazo == round(plazo))

    pago = pago_seguro(capital, tasa, plazo)
    saldo = numeric(plazo + 1)
    saldo[1] = capital

    for (t in seq_len(plazo)) {
        saldo[t + 1] = saldo[t] * (1 + tasa) - pago
    }

    tibble(mes = seq_len(plazo),
           saldo_inicial = saldo[seq_len(plazo)],
           interes       = saldo_inicial * tasa,
           amortizacion  = pago - interes,
           saldo_final   = saldo[seq_len(plazo) + 1])
}
```
---
layout: default
section: Sesión 5
subsection: Cierre
---
# Y la verificación
Devolver una tabla en lugar de imprimir es lo que permite comprobar el resultado.

```r
amortizacion = tabla_amortizacion(250000, 0.01, 24)

all.equal(sum(amortizacion$amortizacion), 250000)   # [1] TRUE   ¿se pagó el capital?
all.equal(last(amortizacion$saldo_final), 0)        # [1] TRUE   ¿quedó liquidado?

round(sum(amortizacion$interes), 2)                 # [1] 32440.83   el costo
```

Las dos comprobaciones son independientes del camino: cualquier error en la fórmula del pago, en el acumulado del *loop* o en el orden de las columnas rompe al menos una. Esa es la razón de haber escrito la función para que devuelva un objeto.

<Verde t="La misma idea, en el bloque de práctica">

Ahí la comprobación es otra: la simulación mes por mes y la fórmula cerrada tienen que coincidir. Dos caminos independientes al mismo número.

</Verde>
---
layout: default
section: Sesión 5
subsection: Cierre
---
# Recapitulación
Lo que queda de la sesión, en ocho líneas.

1. [**`if` decide qué código corre**]{.colmex-blue} y su condición es escalar. Clasificar los elementos de un vector es otra cosa, y para eso están `if_else()` y `case_when()`.
2. [**El *loop* es la segunda opción.**]{.colmex-orange} Se justifica cuando cada pasada depende de la anterior, cuando lo que se busca son los efectos, o cuando no se sabe cuántas pasadas harán falta.
3. [**Si se escribe un *loop*,**]{.colmex-orange} la salida se pre-asigna y los índices salen de `seq_along()` o `seq_len()`.
4. [**Los decimales no se comparan con `==`,**]{.colmex-orange} sino con `all.equal()` dentro de `isTRUE()`.
5. [**Tres repeticiones justifican una función:**]{.colmex-orange} un propósito, un nombre que lo diga, y todo lo que usa entrando por argumentos.
6. [**La validación va en las primeras líneas**]{.colmex-blue} del cuerpo, con mensajes que digan qué se esperaba.
7. [**`tryCatch()` convierte un error en un valor,**]{.colmex-orange} y con eso un proceso frágil pasa a ser uno que reporta.
8. [**Para pasar columnas a una función propia:**]{.colmex-blue} el operador *embrace* si vienen sin comillas, `.data` con doble corchete si vienen como texto.

### Hacia la Sesión 6

El *loop* del lote de escenarios tiene ocho líneas y solo dos hacen el trabajo; las otras seis se repiten igual en cualquier lote, y `map()` las quita. Y la EIGH regresa, con una función de lectura, varios levantamientos y `ggplot2`.
---
layout: section
eyebrow: Sesión 5 — Bloque de práctica
---
# Bloque de práctica
---
layout: default
section: Sesión 5
subsection: Bloque de Práctica
---
# La calculadora de un plan de ahorro
Hora y cuarto para escribir cuatro funciones propias.

También sin la EIGH: los datos son dos series de doce meses y una tabla de ocho contratos, declaradas en el preámbulo. El archivo de trabajo es `pre/ejercicios_05.R`.

<br>

1. [**Operaciones sobre la serie**]{.colmex-orange} — `cumprod()`, `diff()`, y un *loop* que hay que reescribir vectorizado.
2. [**El *loop* con estado**]{.colmex-orange} — simular el saldo mes por mes, y un `while` con tope de seguridad.
3. [**`valor_futuro()`**]{.colmex-orange} — `switch()` para la periodicidad, validación con `stopifnot()` y salida temprana con `return()`.
4. [**`resumen_por()`**]{.colmex-orange} — el operador *embrace*, un nombre dinámico con `:=`, y dos errores que hay que leer antes de arreglar.
5. [**Captura de fallas**]{.colmex-orange} — `tryCatch()` sobre un lote de cuatro escenarios, y la verificación final.

<br>

<Rojo t="La verificación es el entregable">

La simulación con *loop* de la parte 2 y la fórmula cerrada de la parte 3 tienen que dar el mismo número. Cuando no hay con qué comparar un resultado, la salida es calcularlo dos veces por caminos distintos. El bloque se resuelve [sin asistencia de modelos de lenguaje]{.colmex-orange}.

</Rojo>

<!-- instructor-only -->

> Tiempo: 1:15. Parte 1 en el proyector; de la 2 en adelante, cada quien en su máquina. La que más atora es la 4: pedirles que corran primero la versión sin el operador *embrace* y que expliquen de dónde salió el 5000 antes de arreglar nada. La parte 4d falla dos veces a propósito, por el `NA` y por el `if` escalar: que lean los dos errores.

<!-- /instructor-only -->
---
layout: default
section: Sesión 5
subsection: Referencias
---
# Lecturas
Para la sesión y para la siguiente.

- *Advanced R* (2.ª ed.), Cap. 5 *Control flow* y Cap. 6 *Functions*, completos.
- *Advanced R* (2.ª ed.), Cap. 8 *Conditions*, §8.2 *Signalling conditions* y §8.4 *Handling conditions*; Cap. 22 *Debugging*.
- *R for Data Science* (2.ª ed.), Cap. 25 *Functions*, §25.3 *Data frame functions*.

<br>

### Referencia rápida

- El capítulo 6 de *Advanced R* conviene leerlo dos veces: una antes de escribir funciones propias y otra después de haber escrito unas cuantas. La segunda lectura es la que se entiende.
- La sección §25.3 de R4DS trata exactamente el problema de las columnas como argumentos, con más ejemplos que los de hoy.

<br>

<Azul t="Cómo se prueba una función propia">

Con un caso de juguete y el resultado calculado a mano: `valor_futuro(5000, tasa_anual = 0, anios = 10)` tiene que dar 600,000. Una función que solo se puede probar con la tabla completa suele estar haciendo [más de una cosa]{.colmex-blue}.

</Azul>
---
layout: cover
title: ¡Gracias!
subtitle: Sesión 5 — Programación para Proyectos de Datos I
---
