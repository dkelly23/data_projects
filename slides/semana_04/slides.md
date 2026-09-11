---
theme: default
title: "dplyr II y manejo de texto: joins, pivots y stringr"
subtitle: Sesión 4 — Programación para Proyectos de Datos I
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
section: Sesión 4
subsection: Mapa de la Sesión
---
# ¿Dónde estamos?
La Sesión 3 dio los verbos. Todos operan sobre [una sola tabla]{.colmex-blue}.

La EIGH tiene cuatro archivos y las preguntas interesantes cruzan varios: la entidad está en `hogares`, el monto en `gastos` y el significado de la clave en el catálogo. Ninguna cadena de verbos cruza esa frontera.

### Contenido de la sesión

1. [***Pivots***]{.colmex-blue} — `pivot_longer()` y `pivot_wider()`, cambiar la forma de la tabla.
2. [***Joins***]{.colmex-orange} — unir tablas por una llave, y verificar que la unión hizo lo que se creía.
3. [**Manejo de `NA`**]{.colmex-blue} — `replace_na()`, `coalesce()` y `drop_na()`.
4. [**Categóricas**]{.colmex-blue} — repaso de `if_else()` y `case_when()` sobre la tabla unida.
5. [**`stringr` y *regex***]{.colmex-orange} — limpieza sistemática de campos de texto.
6. [**`glue`**]{.colmex-blue} — construcción dinámica de *strings*.

<br>

<Azul t="Las dos mitades se tocan al final">

La primera arma la tabla, la segunda limpia lo que quedó adentro. El puente es un catálogo que llega sucio: hay que [limpiarlo con *regex* antes de poder unirlo]{.colmex-blue}, así que la limpieza de texto no es un apéndice de la sesión sino un requisito.

</Azul>
---
layout: default
section: Sesión 4
subsection: Mapa de la Sesión
---
# Cuatro tablas, una llave
Cada archivo tiene su propia unidad de observación.

| Tabla | Una fila es | Aporta |
|---|---|---|
| `hogares` | una vivienda | entidad, ingreso, gasto, integrantes |
| `personas` | una persona | sexo, edad, escolaridad, ingreso laboral |
| `gastos` | un hogar-rubro | monto por rubro |
| catálogo | un rubro | qué significa cada clave |

Lo que las une es una columna compartida: `folioviv` entre las tres tablas de campo, `clave` entre `gastos` y el catálogo. A esa columna se le llama [llave]{.colmex-orange}.

<br>

<Verde t="La pregunta que abre la sesión">

*¿Cuánto gastan en alimentos los hogares de Oaxaca?* necesita las tres tablas a la vez. Con los verbos de la Sesión 3 no se puede responder.

</Verde>
---
layout: section
eyebrow: Sesión 4 — Bloque de exposición
---
# *Pivots*
---
layout: default
section: Sesión 4
subsection: Pivots
---
# Cambiar la forma, no el contenido
Dos funciones de `tidyr` que reacomodan la tabla.

Un *pivot* no agrega información ni la quita: la [reacomoda]{.colmex-orange}. La pregunta que contesta es cuál de las dos formas corresponde a la operación que sigue.

| Forma | Cómo se ve | Para qué sirve |
|---|---|---|
| **larga** | una columna dice *qué* se mide, otra *cuánto* | `group_by()`, `summarize()`, `ggplot2` |
| **ancha** | una columna por variable medida | lectura humana, tablas de reporte, modelos |

<br>

```r
pivot_longer(datos, cols, names_to, values_to)   # ancho  -> largo
pivot_wider(datos, id_cols, names_from, values_from)   # largo -> ancho
```

<Verde t="Regla práctica">

El tidyverse prefiere el formato largo. Si una operación se está volviendo incómoda, casi siempre es porque la tabla está en la forma equivocada.

</Verde>
---
layout: default
section: Sesión 4
subsection: Pivots
---
# `pivot_longer()`
Varias columnas se convierten en dos.

En `hogares`, `ing_cor` y `gasto_mon` son dos conceptos del mismo tipo guardados aparte. Para compararlos en una sola operación conviene apilarlos:

```r
hogares |>
    select(folioviv, ing_cor, gasto_mon) |>
    pivot_longer(cols = c(ing_cor, gasto_mon),
                 names_to = "concepto", values_to = "monto")
# A tibble: 1,600 × 3
   folioviv concepto    monto
   <chr>    <chr>       <dbl>
 1 0773233  ing_cor    35847.
 2 0773233  gasto_mon  22717.
 3 0382982  ing_cor    75262.
 4 0382982  gasto_mon 102714.
# ℹ 1,596 more rows
```

800 filas entraron, 1,600 salieron: dos por hogar, una por concepto. [Ninguna celda se perdió]{.colmex-blue}; cambiaron de lugar.

`cols` acepta la misma notación de `select()`, incluida la negación: `cols = -folioviv` es la forma más frecuente cuando las columnas son muchas.
---
layout: default
section: Sesión 4
subsection: Pivots
---
# `pivot_wider()`
La operación inversa: dos columnas se despliegan en varias.

`gastos` tiene una fila por hogar-rubro. Para una tabla con una fila por [hogar]{.colmex-orange} y una columna por rubro:

```r
gastos |>
    pivot_wider(id_cols = folioviv, names_from = clave, values_from = gasto_tri)
# A tibble: 800 × 9
   folioviv   A002   E001  B001  A001   C001  B002  F001  D001
   <chr>     <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0773233   5397.  3188. 2124. 4332.   500.  436.   NA    NA
 2 0382982     NA     NA  2530. 2720.  5249. 1755.   NA    NA
# ℹ 798 more rows
```

4,418 filas entraron, 800 salieron. Las columnas salen [en el orden en que apareció cada clave]{.colmex-orange} en los datos, no en orden alfabético:

```r
gastos |>
    pivot_wider(id_cols = folioviv, names_from = clave, values_from = gasto_tri,
                names_sort = TRUE, names_prefix = "gasto_")
```
---
layout: default
section: Sesión 4
subsection: Pivots
---
# Los `NA` que fabrica el *pivot*
El formato ancho introdujo faltantes que no estaban en el largo.

```r
colSums(is.na(gastos_ancho))
folioviv     A001     A002     B001     B002     C001     D001     E001     F001
       0      235      242      265      243      267      238      245      247
```

No son no respuesta: son [combinaciones hogar-rubro que nunca existieron]{.colmex-blue}, porque cada hogar declaró entre 3 y 8 rubros de los 8 posibles.

Aquí el `NA` significa *no gastó en este rubro*, así que el cero es la lectura correcta y se pide al pivotar:

```r
gastos |>
    pivot_wider(id_cols = folioviv, names_from = clave, values_from = gasto_tri,
                names_sort = TRUE, values_fill = 0)
```

<Rojo t="! `values_fill = 0` no es limpieza">

Es una [afirmación sobre el mundo]{.colmex-orange}: que la ausencia de la fila significa que no se gastó. Si el rubro pudiera haber quedado sin capturar, el cero está inventando un dato. La decisión cambia con la tabla y hay que poder justificarla.

</Rojo>
---
layout: default
section: Sesión 4
subsection: Pivots
---
# Cuando la llave no es única
La señal es una columna que contiene listas.

`pivot_wider()` supone que `id_cols` más `names_from` identifican una sola fila. Si no, no puede elegir qué valor poner en la celda:

```r
ejemplo |> pivot_wider(names_from = clave, values_from = gasto_tri)
# A tibble: 2 × 2
  folioviv A001
  <chr>    <list>
1 0000001  <dbl [2]>
2 0000002  <dbl [1]>

Warning: Values from `gasto_tri` are not uniquely identified; output will
contain list-cols.
```

La salida con `<list>` adentro es la señal de que la llave estaba duplicada. La respuesta [no es silenciar el aviso]{.colmex-orange}, es decidir qué hacer con el duplicado: `values_fn = sum` si se suman, o corregir el dato si no deberían existir.

<Verde t="La verificación previa, en una línea">

```r
gastos |> count(folioviv, clave) |> filter(n > 1)
# A tibble: 0 × 3      <- cero filas: la llave es única
```

</Verde>
---
layout: section
eyebrow: Sesión 4 — Bloque de exposición
---
# *Joins*
---
layout: default
section: Sesión 4
subsection: Joins
---
# Dos familias
La diferencia está en qué hacen con las columnas.

Un *join* combina dos tablas emparejando filas por su llave.

- [***Mutating joins***]{.colmex-orange} — agregan columnas de la segunda tabla a la primera. `left_join()`, `right_join()`, `inner_join()`, `full_join()`.
- [***Filtering joins***]{.colmex-blue} — no agregan nada: usan la segunda tabla como criterio para decidir qué filas de la primera se conservan. `semi_join()`, `anti_join()`.

<br>

Las cuatro variantes de *mutating join* se distinguen por qué filas conservan cuando la llave [no]{.colmex-orange} empareja:

| Variante | Conserva |
|---|---|
| `left_join(x, y)` | todas las de `x` — el defecto de trabajo |
| `right_join(x, y)` | todas las de `y` |
| `inner_join(x, y)` | solo las que emparejan — puede perder filas en silencio |
| `full_join(x, y)` | todas las de ambas — puede crear filas con `NA` |
---
layout: default
section: Sesión 4
subsection: Joins
---
# `left_join()`
El join de trabajo: no pierde filas de la tabla que interesa.

El catálogo tiene una fila por clave y `gastos` tiene muchas: cada fila de `gastos` encuentra [exactamente una]{.colmex-blue} pareja. Esto es un join **muchos a uno**.

```r
gastos |> left_join(claves_gasto, by = "clave")
# A tibble: 4,418 × 6
  folioviv clave gasto_tri frecuencia rubro      descripcion
  <chr>    <chr>     <dbl>      <dbl> <chr>      <chr>
1 0773233  A002      5397.          5 Alimentos  Alimentos consumidos fuera d…
2 0773233  E001      3188.          3 Salud      Consultas, medicamentos y ho…
# ℹ 4,416 more rows
```

4,418 filas entraron, 4,418 salieron: un join muchos-a-uno [no cambia el número de filas]{.colmex-blue}, solo agrega columnas.

Con eso ya se responde la pregunta del arranque, que ninguna tabla contestaba sola:

```r
gastos |>
    left_join(claves_gasto, by = "clave") |>
    left_join(hogares, by = "folioviv") |>
    filter(nom_ent == "Oaxaca", rubro == "Alimentos") |>
    summarize(gasto_medio = mean(gasto_tri), hogares = n_distinct(folioviv))
  gasto_medio hogares
1       2940.     113
```
---
layout: default
section: Sesión 4
subsection: Joins
---
# El join que multiplica filas
El error más caro de la sesión, y no avisa.

`hogares` tiene una fila por vivienda y `gastos` tiene varias. Cada fila de `hogares` se [repite]{.colmex-orange} una vez por cada gasto que le corresponde:

```r
hogares |> left_join(gastos, by = "folioviv") |> nrow()
[1] 4418
```

800 entraron, 4,418 salieron. No es un error: es lo que significa un join **uno a muchos**. Se vuelve un error en la línea siguiente:

```r
hogares |> summarize(ingreso = sum(ing_cor, na.rm = TRUE))
      ingreso
1 55350869.

hogares |> left_join(gastos, by = "folioviv") |>
    summarize(ingreso = sum(ing_cor, na.rm = TRUE))
      ingreso
1 307457446.
```

<Rojo t="! Cinco veces y media más ingreso del que existe">

El ingreso es un dato del **hogar** y quedó repetido una vez por rubro declarado. Nadie lo pidió y nadie fue advertido. La regla: un dato solo se suma [al nivel en el que fue medido]{.colmex-orange}.

</Rojo>
---
layout: default
section: Sesión 4
subsection: Joins
---
# `by` y `join_by()`
Cómo se declara la llave.

```r
gastos |> left_join(claves_gasto, by = "clave")       # funciona
gastos |> left_join(claves_gasto, join_by(clave))     # la forma recomendada
```

`join_by()` no lleva comillas, igual que el resto del tidyverse, y admite casos que `by` no:

```r
left_join(x, y, join_by(folio_vivienda == folioviv))   # nombres distintos
left_join(x, y, join_by(folioviv, numren))             # llave compuesta
```

Si se omite `by`, `dplyr` empareja por [todas las columnas de nombre común]{.colmex-orange} y avisa cuáles usó. Sirve para explorar; no para código que se guarda.

<Azul t="Columnas que colisionan">

Cuando las dos tablas traen una columna con el mismo nombre que no es llave, `dplyr` conserva ambas y las desambigua con sufijos: `factor.x` y `factor.y` al unir `hogares` con `personas`. El sufijo avisa, pero no dice cuál es cuál — conviene declararlo con `suffix = c("_hog", "_per")`.

</Azul>
---
layout: default
section: Sesión 4
subsection: Joins
---
# *Filtering joins*
No agregan columnas: filtran.

```r
semi_join(x, y)   # conserva las filas de x que SÍ tienen pareja en y
anti_join(x, y)   # conserva las filas de x que NO tienen pareja en y
```

*¿Qué hogares declararon gasto en educación?* Con `semi_join()` no hace falta arrastrar las columnas de `gastos` ni preocuparse por duplicar filas:

```r
hogares |> semi_join(gastos |> filter(clave == "D001"), by = "folioviv") |> nrow()
[1] 562
```

La diferencia con `left_join()` + `filter()` es que `semi_join()` [nunca duplica filas]{.colmex-blue}, aunque la fila de `x` empareje con varias de `y`. Devuelve un subconjunto de `x`.

<Verde t="`anti_join()` es la herramienta de diagnóstico de la sesión">

Antes de unir, se pregunta qué se va a quedar afuera. La respuesta que se quiere es *nada*, y se lee como cero filas:

```r
hogares |> anti_join(gastos, by = "folioviv")   # A tibble: 0 × 8
gastos |> anti_join(hogares, by = "folioviv")   # A tibble: 0 × 4
```

Las [dos direcciones]{.colmex-orange} se revisan: contestan cosas distintas.

</Verde>
---
layout: default
section: Sesión 4
subsection: Joins
---
# Cardinalidad
Cuántas filas salen depende de qué identifica la llave en cada tabla.

| Cardinalidad | El número de filas | Ejemplo en la EIGH |
|---|---|---|
| uno a uno | no cambia | |
| muchos a uno | no cambia | `gastos` ← catálogo |
| uno a muchos | **crece** | `hogares` ← `gastos` |
| muchos a muchos | **estalla** | `gastos` ← `personas` |

`dplyr` puede verificar el supuesto y fallar si no se cumple. Es la forma de convertir una creencia en una prueba:

```r
gastos |> left_join(claves_gasto, join_by(clave), relationship = "many-to-one")

hogares |> left_join(gastos, join_by(folioviv), relationship = "one-to-one")
Error in `left_join()`:
! Each row in `x` must match at most 1 row in `y`.
ℹ Row 1 of `x` matches multiple rows in `y`.
```

El *many-to-many* nunca se declara por comodidad: `dplyr` avisa solo cuando ocurre sin haberse pedido, y el aviso casi siempre señala una [llave equivocada]{.colmex-orange}.
---
layout: default
section: Sesión 4
subsection: Joins
---
# El join que no empareja nada
El error silencioso, y es el de la Sesión 2 con otro disfraz.

Si `folioviv` se lee como número, pierde el cero inicial. Con tipos distintos `dplyr` se niega a unir, y este es el caso [afortunado]{.colmex-blue}:

```r
hogares_mal |> left_join(gastos, by = "folioviv")
Error in `left_join()`:
! Can't join `x$folioviv` with `y$folioviv` due to incompatible types.
ℹ `x$folioviv` is a <double>.
ℹ `y$folioviv` is a <character>.
```

El caso desafortunado es cuando alguien *arregla* el tipo sin arreglar el dato. Los tipos coinciden, el join corre, no hay error, y no empareja nada:

```r
hogares_mal |>
    mutate(folioviv = as.character(folioviv)) |>
    left_join(gastos, by = "folioviv") |>
    summarize(filas = n(), con_gasto = sum(!is.na(gasto_tri)))
  filas con_gasto
1   800         0
```

<Rojo t="! Por qué la verificación de filas no lo detecta">

800 filas es [exactamente]{.colmex-orange} lo que se esperaba de un `left_join()` sobre `hogares`. Lo único que delata el desastre es que las columnas de `gastos` vinieron vacías. Un `anti_join()` previo habría devuelto las 800 filas en vez de cero.

</Rojo>
---
layout: default
section: Sesión 4
subsection: Joins
---
# `tidylog`
Un paquete que narra lo que hizo cada verbo.

`tidylog` intercepta las funciones de `dplyr` y `tidyr` e imprime en consola qué hicieron. [No cambia el resultado]{.colmex-blue}: solo lo cuenta.

```r
library(tidylog)

hogares |> left_join(gastos, by = "folioviv")
left_join: added 3 columns (clave, gasto_tri, frecuencia)
           > rows only in hogares      0
           > rows only in gastos  (    0)
           > matched rows          4,418    (includes duplicates)
           >                      =======
           > rows total            4,418
```

Las tres líneas que importan son las mismas tres preguntas de la sección. También narra los verbos de la Sesión 3:

```r
hogares |> filter(ing_cor > 50000)
filter: removed 321 rows (40%), 479 rows remaining

hogares |> mutate(ing_pc = ing_cor / tot_integ)
mutate: new variable 'ing_pc' (double) with 783 unique values and 2% NA
```

<Azul t="Cuándo encenderlo">

Mientras se escribe el *pipeline*; apagado con `pacman::p_unload(tidylog)` cuando ya corre. Deja la consola ilegible en un script largo y no va en código que se entrega.

</Azul>
---
layout: section
eyebrow: Sesión 4 — Bloque de exposición
---
# Manejo de `NA`
---
layout: default
section: Sesión 4
subsection: NA
---
# Tres funciones, tres decisiones
Ninguna es la opción por defecto.

La Sesión 2 vio qué es un `NA` y la Sesión 3 lo vio propagarse. Estas tres [intervienen]{.colmex-orange} sobre él, y las tres hay que poder justificarlas.

```r
replace_na(x, valor)   # sustituye los faltantes por un valor fijo
coalesce(x, y, ...)    # el primer valor no faltante, de izquierda a derecha
drop_na(datos, cols)   # descarta las filas con faltantes
```

<br>

```r
nrow(hogares)                       # 800
nrow(hogares |> drop_na(ing_cor))   # 782
nrow(hogares |> drop_na())          # 782
```

Los dos números coinciden porque `ing_cor` es la única columna con faltantes. En una tabla de veinte columnas, [`drop_na()` sin argumentos]{.colmex-orange} elimina filas por defectos en columnas que ni siquiera participan en el análisis.

<Verde t="La forma de tomar la decisión">

Mirar primero cuántos son: `summarize(total = n(), sin_ingreso = sum(is.na(ing_cor)))`. Y dejar el conteo en el reporte, no solo en la consola.

</Verde>
---
layout: default
section: Sesión 4
subsection: NA
---
# `coalesce()`
Rellenar una columna con otra fuente.

Los 18 hogares sin `ing_cor` declarado tienen personas con ingreso por trabajo. La suma de esas personas es un respaldo razonable:

```r
hogares_ing = hogares |>
    left_join(ing_personas, by = "folioviv") |>
    mutate(ing_final = coalesce(ing_cor, ing_pers),
           fuente    = if_else(is.na(ing_cor), "personas", "hogar"))

hogares_ing |> count(fuente)
  fuente       n
1 hogar      782
2 personas    18
```

La columna `fuente` no es decorativa: es la [constancia de qué se imputó]{.colmex-blue} y de dónde salió. Un dato rellenado sin marca es indistinguible de uno declarado.

<Rojo t="! Lo que `coalesce()` no arregla">

```r
  folioviv ing_cor ing_pers ing_final
2 0461718       NA       0         0
```

Ese hogar recibió un ingreso de **cero**. Ninguna de sus personas declaró `ing_trab`, y `sum(na.rm = TRUE)` sobre puros `NA` devuelve 0. El respaldo [fabricó un dato falso]{.colmex-orange}, y `coalesce()` no tenía cómo saberlo: recibió un cero legítimo. El error entra en el eslabón anterior.

</Rojo>
---
layout: section
eyebrow: Sesión 4 — Bloque de exposición
---
# Variables categóricas
---
layout: default
section: Sesión 4
subsection: Categóricas
---
# Repaso, con una advertencia
`if_else()` y `case_when()` ya se vieron en la Sesión 3.

Lo que agrega esta sesión es [dónde]{.colmex-orange} se usan: sobre la tabla unida, para traducir los códigos del catálogo a etiquetas legibles.

```r
personas |>
    mutate(
        sexo_etq = if_else(sexo == 1, "Hombre", "Mujer"),
        grupo_edad = case_when(
            is.na(edad)  ~ "sin dato",
            edad < 15    ~ "0-14",
            edad < 30    ~ "15-29",
            edad < 60    ~ "30-59",
            .default     = "60+"
        )
    )
```

- `case_when()` evalúa [en orden]{.colmex-blue} y toma la primera rama verdadera.
- Lo que no cae en ninguna rama recibe `NA`, salvo que se use `.default`.
- Las ramas tienen que devolver el mismo tipo.

<Rojo t="! El `NA` va en la primera rama">

`edad < 15` con `edad` faltante devuelve `NA`, no `FALSE`, así que la fila nunca entra en ninguna rama posterior. `is.na(edad)` es la única condición que las comparaciones no pueden contestar, y por eso va arriba.

</Rojo>
---
layout: default
section: Sesión 4
subsection: Categóricas
---
# `forcats`, en una diapositiva
Una categórica de texto se ordena alfabéticamente.

Eso casi nunca es el orden que se quiere: `"0-14"`, `"15-29"`, `"30-59"`, `"60+"` funciona por casualidad, y `"alto"`, `"bajo"`, `"medio"` no. `forcats` convierte a factor y controla el orden de los niveles.

```r
factor(estrato, levels = c("bajo", "medio", "alto", "sin dato"))

fct_relevel()   # mueve niveles a una posición
fct_reorder()   # ordena los niveles por otra variable
fct_infreq()    # ordena por frecuencia
fct_lump()      # agrupa las categorías menos frecuentes
```

<br>

<Azul t="Dónde importa">

Sobre todo al graficar: el orden de los niveles es el orden de las barras y el de la leyenda. Se retoma en la Sesión 6, con `ggplot2`.

</Azul>
---
layout: section
eyebrow: Sesión 4 — Bloque de exposición
---
# `stringr` y expresiones regulares
---
layout: default
section: Sesión 4
subsection: Texto
---
# El catálogo que no se puede unir
El problema concreto que abre la segunda mitad.

La clasificación del gasto en necesario o discrecional vive en una hoja capturada a mano, y [ese dato no está en ninguna otra tabla]{.colmex-blue}. Así llega:

```r
rubros_texto = read_excel("files/eigh_catalogos.xlsx", sheet = "rubros_texto", skip = 2)
# A tibble: 8 × 2
  rubro_completo                                  tipo
  <chr>                                           <chr>
1 A001 - Alimentos consumidos dentro del hogar    necesario
2 A002 – ALIMENTOS CONSUMIDOS FUERA DEL HOGAR     discrecional
3 B001- Renta o pago de vivienda                  NECESARIO
4 B002 : Electricidad,  agua y combustible        Necesario
5 C001 - transporte público y particular          necesario
6 D001  -  Colegiaturas y material escolar        NA
7 E001- CONSULTAS, medicamentos y hospitalización NECESARIO
8 F001 – Ropa, calzado y accesorios               Discrecional
```

<Rojo t="! No hay columna `clave`">

La clave viene [pegada a la etiqueta]{.colmex-orange}, con un separador que cambia de fila en fila. Sin esa columna no hay *join* posible: la limpieza de texto no es un adorno de esta sesión, es lo que permite terminarla.

</Rojo>
---
layout: default
section: Sesión 4
subsection: Texto
---
# `stringr`: un sistema, no un catálogo
Las funciones de texto de R base no comparten convención.

`paste0()`, `nchar()`, `substr()`, `tolower()` y `gsub()` se escribieron en momentos distintos, con el argumento del texto unas veces primero y otras después. `stringr` las reemplaza con cuatro acuerdos: todas empiezan con `str_`, el primer argumento es [siempre]{.colmex-orange} el texto, el segundo [siempre]{.colmex-orange} el patrón, y todas están vectorizadas.

| Qué hace | Funciones |
|---|---|
| detectar | `str_detect()`, `str_count()` |
| extraer | `str_extract()`, `str_match()`, `str_sub()` |
| reemplazar | `str_replace()`, `str_replace_all()`, `str_remove()` |
| partir | `str_split()` |
| recortar | `str_trim()`, `str_squish()`, `str_pad()` |
| capitalizar | `str_to_lower()`, `str_to_upper()`, `str_to_title()`, `str_to_sentence()` |
| medir | `str_length()` |

<Verde t="`str_trim()` contra `str_squish()`">

```r
x = "  B001-  Renta   o pago "
str_trim(x)     # "B001-  Renta   o pago"   solo los extremos
str_squish(x)   # "B001- Renta o pago"      extremos Y repetidos internos
```

`squish` es el que sirve sobre datos capturados a mano.

</Verde>
---
layout: default
section: Sesión 4
subsection: Texto
---
# Por qué hace falta un *regex*
El primer intento falla en tres filas.

```r
str_detect(rubros_texto$rubro_completo, "-")
[1]  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE FALSE
```

Las filas 2 y 8 traen un guion largo (`–`), y la 4 trae dos puntos. [Tres separadores distintos]{.colmex-orange} en ocho filas capturadas a mano, y buscar literal no alcanza.

Un *regex* es un patrón que describe un **conjunto** de textos:

| Componente | Qué significa |
|---|---|
| `[abc]` `[A-Z]` `[-–:]` | un caracter de ese conjunto |
| `\d` `\s` `\w` `.` | dígito, espacio, caracter de palabra, cualquiera |
| `*` `+` `?` `{3}` `{2,4}` | cero o más, una o más, cero o una, exactamente, entre |
| `^` `$` | inicio y final del texto |
| `()` | grupo de captura |

<Azul t="La diagonal doble">

En R el patrón se escribe dentro de un *string*, así que la diagonal invertida se duplica: `"\\d"` en el código es `\d` en el *regex*.

</Azul>
---
layout: default
section: Sesión 4
subsection: Texto
---
# Aplicado al catálogo
La clave es constante aunque el separador no lo sea.

Una mayúscula seguida de tres dígitos:

```r
str_extract(rubros_texto$rubro_completo, "[A-Z]\\d{3}")
[1] "A001" "A002" "B001" "B002" "C001" "D001" "E001" "F001"
```

Con el separador incluido se ve la variedad que había que absorber. `\\s*` dice *cero o más espacios*, que es exactamente lo que varía:

```r
str_extract(rubros_texto$rubro_completo, "[A-Z]\\d{3}\\s*[-–:]")
[1] "A001 -"  "A002 –"  "B001-"   "B002 :"  "C001 -"  "D001  -" "E001-"   "F001 –"
```

Las anclas verifican forma. *¿Todos los folios tienen siete dígitos y empiezan con cero?*

```r
all(str_detect(hogares$folioviv, "^0"))        # TRUE
all(str_detect(hogares$folioviv, "^\\d{7}$"))  # TRUE
```

<Verde t="`^` y `$` juntos">

Exigen que el patrón describa el texto **completo**. Sin ellos, `"\\d{7}"` emparejaría cualquier texto que *contenga* siete dígitos seguidos.

</Verde>
---
layout: default
section: Sesión 4
subsection: Texto
---
# La limpieza completa
Tres operaciones encadenadas, cada una con un propósito nombrado.

```r
rubros = rubros_texto |>
    mutate(
        clave = str_extract(rubro_completo, "[A-Z]\\d{3}"),
        etiqueta = rubro_completo |>
            str_remove("^\\s*[A-Z]\\d{3}\\s*[-–:]\\s*") |>   # quitar clave y separador
            str_squish() |>                                   # espacios sobrantes
            str_to_sentence(),                                # capitalización pareja
        tipo = str_to_lower(tipo),
        .keep = "none"
    ) |>
    mutate(tipo = replace_na(tipo, "sin clasificar"))
```

```r
# A tibble: 8 × 3
  tipo           clave etiqueta
  <chr>          <chr> <chr>
1 necesario      A001  Alimentos consumidos dentro del hogar
2 discrecional   A002  Alimentos consumidos fuera del hogar
6 sin clasificar D001  Colegiaturas y material escolar
```

Con la columna `clave` construida el catálogo ya se puede unir, y la sesión [cierra el círculo]{.colmex-blue}: el *regex* produjo la llave que el *join* necesitaba.
---
layout: default
section: Sesión 4
subsection: Texto
---
# El círculo cerrado
Texto limpio, llave construida, *join* posible.

```r
gastos |>
    left_join(rubros, join_by(clave), relationship = "many-to-one") |>
    summarize(total = sum(gasto_tri), .by = tipo) |>
    arrange(desc(total))
# A tibble: 3 × 2
  tipo              total
  <chr>             <dbl>
1 necesario      7939059.
2 discrecional   2970824.
3 sin clasificar 1542840.
```

<br>

<Verde t="Por qué «sin clasificar» vale 1.5 millones">

Es el rubro de educación, que quedó sin tipo porque la celda venía vacía. El `replace_na()` lo hizo [visible en el resultado]{.colmex-blue} en vez de dejarlo desaparecer en un `NA` que `summarize()` habría reportado aparte o descartado.

Es el argumento para no descartar faltantes por reflejo: un faltante que se vuelve categoría se puede discutir; uno que se borra, no.

</Verde>
---
layout: default
section: Sesión 4
subsection: Texto
---
# `glue`
Construcción dinámica de *strings*.

Lo que va entre llaves se evalúa y se pega al texto. Adentro va [cualquier expresión de R]{.colmex-blue}, no solo un nombre:

```r
tabla = "hogares"
glue("files/eigh_{tabla}.csv")
files/eigh_hogares.csv

glue("El levantamiento tiene {nrow(hogares)} hogares y {nrow(personas)} personas.")
El levantamiento tiene 800 hogares y 2606 personas.
```

Vectorizado: un vector adentro produce un vector afuera. Así se arma una lista de rutas, y es lo que la [Sesión 6]{.colmex-orange} le pasará a `map()`:

```r
tablas = c("hogares", "personas", "gastos")
glue("files/eigh_{tablas}.csv")
files/eigh_hogares.csv
files/eigh_personas.csv
files/eigh_gastos.csv
```

<Verde t="Contra las alternativas de base">

```r
paste0("files/eigh_", tabla, ".csv")    # se rompe al leerlo
sprintf("files/eigh_%s.csv", tabla)     # el valor va lejos del hueco
glue("files/eigh_{tabla}.csv")          # el valor va donde aparece
```

La ventaja no es escribir menos: es que el texto final [se lee en el código]{.colmex-blue}.

</Verde>
---
layout: default
section: Sesión 4
subsection: Cierre
---
# El *pipeline* completo
De cuatro tablas crudas a una tabla de análisis.

```r
etl = gastos |>
    left_join(rubros, join_by(clave), relationship = "many-to-one") |>
    left_join(hogares, join_by(folioviv), relationship = "many-to-one") |>
    summarize(gasto = sum(gasto_tri), .by = c(folioviv, tipo)) |>
    pivot_wider(names_from = tipo, values_from = gasto, values_fill = 0)
# A tibble: 800 × 4
   folioviv discrecional necesario `sin clasificar`
   <chr>           <dbl>     <dbl>            <dbl>
 1 0773233         5397.    10581.               0
 2 0382982            0     12253.               0
```

Cada paso es uno de los temas de hoy: el texto limpio produjo la llave, los *joins* trajeron las columnas, el *pivot* fijó la unidad de observación.

<Rojo t="Las tres preguntas después de CADA join">

1. **¿Cuántas filas hay?** — `nrow()` antes y después.
2. **¿Qué se quedó afuera?** — `anti_join()` en las dos direcciones.
3. **¿Aparecieron `NA` nuevos?** — `colSums(is.na())`.

Un *join* que no se verificó [no está terminado]{.colmex-orange}.

</Rojo>
---
layout: default
section: Sesión 4
subsection: Cierre
---
# Recapitulación
Lo que esta sesión deja instalado.

- [***Pivots*.**]{.colmex-blue} `pivot_longer()` y `pivot_wider()` cambian la forma, no el contenido. `values_fill` es una afirmación sobre el mundo, y una columna `<list>` delata una llave duplicada.
- [***Joins*.**]{.colmex-orange} *Mutating* agregan columnas, *filtering* filtran filas. `left_join()` es el defecto; `anti_join()` es el diagnóstico.
- [**Cardinalidad.**]{.colmex-orange} Uno a muchos hace crecer la tabla y arruina cualquier suma posterior. `relationship` convierte el supuesto en una prueba.
- [**El join silencioso.**]{.colmex-orange} Tipos que coinciden y datos que no. El conteo de filas no lo detecta; `anti_join()` sí.
- [**`NA`.**]{.colmex-blue} `replace_na()`, `coalesce()` y `drop_na()` son decisiones documentables, no limpieza automática. Lo imputado se marca.
- [**`stringr` y *regex*.**]{.colmex-blue} Un sistema con convención fija, y patrones que describen conjuntos de textos. Sirvieron para construir una llave que no existía.
- [**`glue`.**]{.colmex-blue} Interpolación legible y vectorizada.

### Hacia la Sesión 5

Este *pipeline* está escrito [una vez, para un levantamiento]{.colmex-orange}. La Sesión 5 lo convierte en funciones y la Sesión 6 lo corre sobre varios con `map()`. Lo que hoy son cuarenta líneas sueltas, en tres semanas será una función de diez.
---
layout: section
eyebrow: Sesión 4 — Bloque de práctica
---
# Bloque de práctica
---
layout: default
section: Sesión 4
subsection: Bloque de Práctica
---
# El ETL de la EIGH
Hora y cuarto para construir la tabla que faltaba.

La Sesión 3 dejó tres tablas de resultados, cada una calculada sobre [una]{.colmex-orange} tabla. El encargo de hoy produce **un solo archivo**: `output/eigh_etl.rds`, con una fila por hogar y todo lo que hoy está repartido en cuatro fuentes.

<br>

1. [**Reconocer**]{.colmex-orange} las llaves: qué identifica una fila, y qué se quedaría sin pareja.
2. [**Limpiar**]{.colmex-orange} el catálogo sucio con `stringr` y *regex* hasta poder unirlo.
3. [**Unir**]{.colmex-orange} gastos, clasificación y hogares, declarando la cardinalidad en cada paso.
4. [**Reacomodar**]{.colmex-orange} el gasto por tipo a formato ancho.
5. [**Recodificar**]{.colmex-orange} las categóricas y traer la composición del hogar desde `personas`.
6. [**Cerrar**]{.colmex-orange} con la verificación y el guardado.

<br>

<Rojo t="Recordatorio">

El bloque se resuelve [sin asistencia de modelos de lenguaje]{.colmex-orange}. El archivo de trabajo es `pre/ejercicios_04.R`, y su resultado es el insumo de la Sesión 5.

</Rojo>

<!-- instructor-only -->

> Tiempo: 1:15. Partes 1 y 2 en el proyector. La 3 es la que hay que cuidar: el reflejo a instalar es contar filas antes y después de cada *join*, y nadie lo hace si no se lo piden. La parte 2 es la que más atora — resolver el primer `str_extract()` en conjunto y tener la cheatsheet de *regex* a la mano.

<!-- /instructor-only -->
---
layout: default
section: Sesión 4
subsection: Referencias
---
# Lecturas
Para la sesión y para la siguiente.

- *R for Data Science* (2.ª ed.), Cap. 5 *Data tidying*, §5.3 *Lengthening data* y §5.4 *Widening data*.
- *R for Data Science* (2.ª ed.), Cap. 19 *Joins*, completo.
- *R for Data Science* (2.ª ed.), Cap. 14 *Strings* y Cap. 15 *Regular expressions*.

<br>

### Referencia rápida

- *Data tidying with `tidyr`* — los dos *pivots* con diagramas, que es la forma en que conviene recordarlos.
- *String manipulation with `stringr`* y *Regular Expressions* — las dos de Posit. La de *regex* vale la pena tenerla abierta durante el bloque de práctica.

<br>

<Azul t="Cómo se prueba un *regex*">

Por partes y sobre pocos casos: `str_extract()` sobre las ocho filas del catálogo dice de inmediato si el patrón sirve. Escribir el patrón completo de un tirón y aplicarlo a una columna de diez mil filas es la forma segura de no entender qué falló.

</Azul>
---
layout: cover
title: ¡Gracias!
subtitle: Sesión 4 — Programación para Proyectos de Datos I
---
