---
theme: default
title: "dplyr I: verbos básicos y sistema tidyverse"
subtitle: Sesión 3 — Programación para Proyectos de Datos I
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
section: Sesión 3
subsection: Mapa de la Sesión
---
# ¿Dónde estamos?
La Sesión 2 dejó los datos cargados y verificados. Falta [operar]{.colmex-blue} sobre ellos.

La indexación con `[` responde cualquier pregunta, pero el código deja de leerse en cuanto la condición crece. `dplyr` sustituye esa notación por un [vocabulario de verbos]{.colmex-orange} que se encadenan con el *pipe*.

### Contenido de la sesión

1. [**El sistema tidyverse**]{.colmex-blue} — qué paquetes lo componen y qué comparten entre sí.
2. [**El *pipe***]{.colmex-blue} — el operador de la Sesión 2 y su marcador de posición.
3. [**Los seis verbos**]{.colmex-orange} — `filter()`, `arrange()`, `select()`, `mutate()`, `summarize()` y `group_by()`.
4. [***Helpers***]{.colmex-blue} — `count()`, `distinct()` y `slice_*()`.
5. [**NSE**]{.colmex-blue} — por qué las columnas se escriben sin comillas y qué se rompe cuando eso ocurre.

<br>

<Azul t="La sesión más corta del curso">

La exposición ocupa la primera mitad. La segunda se dedica entera a [escribir código en vivo]{.colmex-blue}: una consulta completa sobre la EIGH, construida verbo por verbo. Nada de lo que sigue se aprende mirándolo.

</Azul>
---
layout: section
eyebrow: Sesión 3 — Bloque de exposición
---
# El sistema tidyverse
---
layout: default
section: Sesión 3
subsection: Tidyverse
---
# Qué es el tidyverse
Una colección de paquetes que comparten una forma de trabajar.

R base creció por acumulación: `aggregate()`, `merge()`, `reshape()` y `subset()` se escribieron en momentos distintos, por personas distintas, y no coinciden ni en el orden de los argumentos ni en lo que devuelven.

El [tidyverse]{.colmex-blue} es un conjunto de paquetes diseñados en conjunto sobre tres acuerdos:

- El [primer argumento]{.colmex-orange} de toda función es la tabla, de modo que el *pipe* siempre funciona.
- El [valor de retorno]{.colmex-orange} es del mismo tipo que la entrada: `tibble` entra, `tibble` sale.
- Las [columnas se nombran sin comillas]{.colmex-orange} ni `$`, con la misma sintaxis en todos los paquetes.

<br>

<Verde t="Qué se gana con eso">

Una función que no se ha visto antes se puede leer y, en la mayoría de los casos, predecir. El costo del acuerdo se paga una vez: aprender `dplyr` es aprender la mitad de `tidyr`, `stringr` y `purrr`.

</Verde>
---
layout: default
section: Sesión 3
subsection: Tidyverse
---
# Qué paquete provee qué
Nueve paquetes centrales, cada uno con un dominio.

| Paquete | Dominio | Sesión |
|---|---|---|
| `dplyr` | manipulación de tablas: verbos y *joins* | 3 y 4 |
| `tidyr` | forma de la tabla: *pivots* y anidación | 4 |
| `readr` | importación de archivos planos | 2 |
| `tibble` | la tabla misma | 2 |
| `stringr` | texto y expresiones regulares | 4 |
| `purrr` | programación funcional: `map()` y familia | 6 |
| `ggplot2` | visualización | 6 |

`forcats` (factores) y `lubridate` (fechas) completan los nueve; el curso los menciona al pasar.

`tidyverse` no contiene código propio: es un paquete que carga a los demás. `readxl`, `haven` y `dbplyr` se instalan con él pero se cargan aparte.
---
layout: default
section: Sesión 3
subsection: Tidyverse
---
# La carga y sus conflictos
El mensaje de arranque no es decorativo.

```r
library(tidyverse)
── Attaching core tidyverse packages ─────────────────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.5
✔ forcats   1.0.0     ✔ stringr   1.5.2
✔ ggplot2   4.0.0     ✔ tibble    3.3.0
✔ lubridate 1.9.4     ✔ tidyr     1.3.1
✔ purrr     1.2.2
── Conflicts ─────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
```

La segunda mitad declara qué nombres quedaron [enmascarados]{.colmex-orange}: a partir de la carga, `filter()` es el verbo de `dplyr` y ya no la función de series de tiempo de `stats`. Gana el paquete cargado más tarde, y la versión enmascarada se pide con su prefijo: `stats::filter()`.

<Verde t="Convención del curso">

`pacman::p_load(tidyverse)` instala lo que falte y carga todo en una línea, declarado en el preámbulo del script y nunca a media sesión.

</Verde>
---
layout: section
eyebrow: Sesión 3 — Bloque de exposición
---
# El *pipe*
---
layout: default
section: Sesión 3
subsection: El Pipe
---
# El marcador de posición
Lo que hace el *pipe* cuando la tabla no va en el primer argumento.

El `|>` de la Sesión 2 inserta lo de la izquierda como [primer argumento]{.colmex-orange} de la derecha. Con el tidyverse eso basta siempre: el primer argumento de todo verbo es la tabla.

```r
hogares |> filter(entidad == "09") |> nrow()
[1] 133
```

Las funciones ajenas no siguen ese acuerdo: `lm()` recibe la fórmula primero, así que hay que decir [dónde]{.colmex-blue} va la tabla. Ese es el marcador `_`:

```r
hogares |> lm(ing_cor ~ tot_integ, data = _) |> coef()
(Intercept)   tot_integ
  53010.970    5453.803
```

Dos condiciones, y las dos producen error de sintaxis si se incumplen:

- El marcador va en un argumento [con nombre]{.colmex-orange}: `data = _` sí, `lm(ing_cor ~ tot_integ, _)` no.
- Aparece [una sola vez]{.colmex-orange} por llamada.

<Azul t="Al leer código ajeno">

En material anterior a 2021 el *pipe* se escribe `%>%`, del paquete `magrittr`. Hace lo mismo y se lee igual. La convención del curso es el nativo.

</Azul>
---
layout: section
eyebrow: Sesión 3 — Bloque de exposición
---
# Los seis verbos
---
layout: default
section: Sesión 3
subsection: Los Seis Verbos
---
# Un vocabulario, no un catálogo
Seis funciones cubren casi toda la manipulación de una tabla.

Cada verbo hace [una sola cosa]{.colmex-orange}, recibe un `tibble` y devuelve un `tibble`. Esa firma común es lo que permite encadenarlos sin límite.

| Verbo | Qué modifica |
|---|---|
| `filter()` | conserva **filas** según una condición |
| `arrange()` | reordena **filas** |
| `select()` | conserva, descarta o reordena **columnas** |
| `mutate()` | agrega o modifica **columnas** |
| `summarize()` | colapsa la tabla a un **resumen** |
| `group_by()` | fija el **contexto de grupo** para los dos anteriores |

<Verde t="La operación mental de la sesión">

Traducir la pregunta a una secuencia: *¿qué filas interesan?* → `filter()`; *¿qué hay que calcular?* → `mutate()`.

</Verde>
---
layout: default
section: Sesión 3
subsection: Los Seis Verbos
---
# La misma pregunta, dos veces
*Ingreso per cápita medio por entidad, en localidades urbanas.*

En R base está repartida en cuatro objetos y tres notaciones distintas:

```r
sub = hogares[hogares$tam_loc == 1, ]
sub$ing_pc = sub$ing_cor / sub$tot_integ
agg = aggregate(ing_pc ~ nom_ent, data = sub, FUN = mean)
agg[order(-agg$ing_pc), ]
```

En `dplyr` es una sola expresión, y cada línea nombra el paso que ejecuta:

```r
hogares |>
    filter(tam_loc == 1) |>
    mutate(ing_pc = ing_cor / tot_integ) |>
    group_by(nom_ent) |>
    summarize(ing_pc_medio = mean(ing_pc)) |>
    arrange(desc(ing_pc_medio))
```
---
layout: default
section: Sesión 3
subsection: filter()
---
# `filter()`
Notación base: la tabla y una condición.

```r
filter(datos, condición)
```

La condición se escribe con el [nombre de la columna]{.colmex-blue}, sin comillas y sin `$`. Devuelve una tabla con las mismas columnas y menos filas.

```r
hogares |> filter(entidad == "09")
# A tibble: 133 × 8
   folioviv entidad nom_ent          tam_loc tot_integ ing_cor gasto_mon factor
   <chr>    <chr>   <chr>              <dbl>     <dbl>   <dbl>     <dbl>  <dbl>
 1 0448777  09      Ciudad de México       1         1 106901.    76266.    983
 2 0321531  09      Ciudad de México       1         2 127369.   114276.     81
 3 0205991  09      Ciudad de México       2         3  81367.    65156.    806
# ℹ 130 more rows
```

Es la traducción directa de la indexación lógica de la Sesión 2, `hogares[hogares$entidad == "09", ]`, sin repetir el nombre de la tabla dentro de la condición.
---
layout: default
section: Sesión 3
subsection: filter()
---
# `filter()`: argumentos y *helpers*
Varias condiciones, y funciones que las abrevian.

Las condiciones se escriben como argumentos sucesivos, separados por coma, y se combinan con **y**:

```r
hogares |> filter(entidad == "09", tot_integ >= 4)
# A tibble: 42 × 8
```

Los operadores son los de la Sesión 2; `dplyr` agrega dos *helpers* que evitan escribirlos a mano:

```r
hogares |> filter(entidad %in% c("09", "20"))    # pertenencia a un conjunto
hogares |> filter(between(tot_integ, 2, 4))      # rango cerrado, inclusivo
hogares |> filter(tam_loc == 1 | tam_loc == 2)   # disyunción
hogares |> filter(!is.na(ing_cor))               # negación
```

La coma y el `&` producen el mismo resultado; la coma se lee mejor cuando las condiciones son varias y largas.

<Rojo t="! Prácticas a Evitar">

`filter(tam_loc == c(1, 2))` no es un error de sintaxis y no filtra lo que parece: compara elemento contra elemento reciclando el vector, y devuelve 276 filas en vez de 539. Para pertenencia siempre `%in%`.

</Rojo>
---
layout: default
section: Sesión 3
subsection: filter()
---
# Los dos errores al escribirlo
Los dos avisan, pero solo uno dice de qué se trata.

El primero es la confusión entre asignación y comparación, y `dplyr` lo diagnostica con nombre y apellido:

```r
hogares |> filter(entidad = "09")
Error in `filter()`:
! We detected a named input.
ℹ This usually means that you've used `=` instead of `==`.
ℹ Did you mean `entidad == "09"`?
```

El segundo aparece cuando `dplyr` no está cargado, o cuando otro paquete lo enmascaró. `filter()` resuelve entonces a la función de series de tiempo de `stats`, que evalúa sus argumentos de forma normal y no conoce las columnas de la tabla:

```r
hogares |> filter(entidad == "09")
Error : objeto 'entidad' no encontrado
```

El mensaje señala la columna, y el problema es el paquete. El diagnóstico es preguntar de dónde salió la función:

```r
find("filter")
[1] "package:dplyr" "package:stats"    # correcto: dplyr primero
[1] "package:stats"                    # el error de arriba
```
---
layout: default
section: Sesión 3
subsection: filter()
---
# El filtro que no avisa
El tercer error es silencioso.

Una condición sobre una columna con faltantes devuelve `NA`, y `filter()` [descarta]{.colmex-orange} toda fila que no evalúe a `TRUE`:

```r
hogares |> filter(ing_cor > 50000) |> nrow()
[1] 479

hogares |> filter(ing_cor <= 50000) |> nrow()
[1] 303
```

479 más 303 son 782, no 800. Los 18 hogares sin ingreso declarado no están en el resultado [ni en su complemento]{.colmex-orange}.

```r
hogares |> filter(is.na(ing_cor)) |> nrow()
[1] 18
```

<Verde t="Cuando el faltante es parte de la pregunta">

Hay que pedirlo: `filter(ing_cor > 50000 | is.na(ing_cor))` devuelve 497. La verificación barata es comparar `nrow()` antes y después de filtrar, y ver si la resta cuadra.

</Verde>
---
layout: default
section: Sesión 3
subsection: arrange()
---
# `arrange()`
Notación base: la tabla y la columna que ordena.

```r
arrange(datos, columna)
```

Reordena las filas sin agregar ni quitar ninguna. El defecto es ascendente.

```r
hogares |> arrange(ing_cor) |> select(folioviv, nom_ent, ing_cor)
# A tibble: 800 × 3
   folioviv nom_ent          ing_cor
   <chr>    <chr>              <dbl>
 1 0735561  Yucatán            7694.
 2 0851711  Querétaro          9873.
 3 0256349  Nuevo León        11122.
# ℹ 797 more rows
```

Es el único verbo que no cambia el contenido de la tabla, solo el orden en que se mira. Por eso suele ir al final de la cadena.
---
layout: default
section: Sesión 3
subsection: arrange()
---
# `arrange()`: argumentos y *helpers*
Sentido, llaves múltiples y grupos.

```r
hogares |> arrange(desc(ing_cor))            # descendente
hogares |> arrange(entidad, desc(ing_cor))   # segunda llave, para los empates
```

`desc()` no es un argumento sino una función que envuelve a la columna: se puede aplicar a unas llaves y a otras no. Las llaves se leen de izquierda a derecha, y la segunda solo interviene donde la primera empata.

Sobre datos agrupados, `arrange()` [ignora los grupos]{.colmex-orange} por defecto. Para ordenar dentro de cada uno se pide explícitamente:

```r
hogares |>
    group_by(nom_ent) |>
    arrange(desc(ing_cor), .by_group = TRUE)
```

<Azul t="Los faltantes no se ordenan">

`NA` va siempre al final, en orden ascendente y en descendente. No es un valor grande ni pequeño: es un valor desconocido, y `dplyr` lo aparta en vez de inventarle una posición.

</Azul>
---
layout: default
section: Sesión 3
subsection: select()
---
# `select()`
Notación base: la tabla y las columnas que se conservan.

```r
select(datos, columnas)
```

Las columnas se nombran sin comillas, igual que en la condición de `filter()`. El orden en que se nombran es el orden que tendrán en el resultado, así que `select()` también reordena.

```r
hogares |> select(folioviv, nom_ent, ing_cor)
# A tibble: 800 × 3
   folioviv nom_ent             ing_cor
   <chr>    <chr>                 <dbl>
 1 0773233  Querétaro            35847.
 2 0382982  Michoacán de Ocampo  75262.
 3 0348747  Oaxaca                  NA
# ℹ 797 more rows
```

`rename()` es el caso particular que cambia el nombre y conserva todo lo demás: `rename(nombre_entidad = nom_ent)`, con el nombre nuevo a la izquierda.
---
layout: default
section: Sesión 3
subsection: select()
---
# `select()`: argumentos y *helpers*
Seleccionar por rango, por negación y por patrón.

```r
hogares |> select(folioviv:tam_loc)         # rango de posiciones
hogares |> select(!c(nom_ent, factor))      # todas menos estas
```

Una encuesta real trae doscientas columnas y nombres construidos por convención. Nombrarlas una por una no escala, y para eso están los *helpers*:

```r
hogares |> select(starts_with("ing"))       # el nombre empieza con
hogares |> select(ends_with("_mon"))        # el nombre termina en
hogares |> select(contains("_"))            # el nombre contiene
hogares |> select(where(is.numeric))        # la columna cumple una condición
hogares |> select(folioviv, everything())   # el folio primero, el resto después
```

```r
hogares |> select(where(is.numeric))
# A tibble: 800 × 5
   tam_loc tot_integ ing_cor gasto_mon factor
     <dbl>     <dbl>   <dbl>     <dbl>  <dbl>
 1       1         3  35847.    22717.    913
# ℹ 799 more rows
```

`where()` recibe una [función]{.colmex-blue}, no un resultado: se escribe `is.numeric`, sin paréntesis.
---
layout: default
section: Sesión 3
subsection: mutate()
---
# `mutate()`
Notación base: nombre nuevo, igual, expresión.

```r
mutate(datos, nombre = expresión)
```

La expresión se calcula sobre el vector completo, fila por fila, con las columnas que ya existen. La columna nueva se agrega al final de la tabla.

```r
hogares |> mutate(ing_pc = ing_cor / tot_integ)
# A tibble: 800 × 9
   folioviv entidad nom_ent   tam_loc tot_integ ing_cor gasto_mon factor  ing_pc
   <chr>    <chr>   <chr>       <dbl>     <dbl>   <dbl>     <dbl>  <dbl>   <dbl>
 1 0773233  22      Querétaro       1         3  35847.    22717.    913  11949.
 2 0382982  16      Michoacá…       2         7  75262.   102714.   1058  10752.
 3 0348747  20      Oaxaca          9         6     NA     37736.    596     NA
# ℹ 797 more rows
```

Si el nombre asignado [ya existe]{.colmex-orange}, la columna se sobrescribe. Es la forma de corregir una variable sin crear una copia.
---
layout: default
section: Sesión 3
subsection: mutate()
---
# `mutate()`: argumentos y *helpers*
Varias columnas por llamada, y dónde queda cada una.

Las asignaciones se evalúan en orden, y cada una ve a la anterior: no hace falta un `mutate()` por columna.

```r
hogares |>
    mutate(
        ing_pc   = ing_cor / tot_integ,
        gasto_pc = gasto_mon / tot_integ,
        ahorro   = 1 - gasto_pc / ing_pc,
        .keep = "used"
    )
# A tibble: 800 × 6
   tot_integ ing_cor gasto_mon  ing_pc gasto_pc ahorro
       <dbl>   <dbl>     <dbl>   <dbl>    <dbl>  <dbl>
 1         3  35847.    22717.  11949.    7572.  0.366
 2         7  75262.   102714.  10752.   14673. -0.365
# ℹ 798 more rows
```

Tres argumentos que empiezan con punto, para no confundirse con una columna nueva:

- `.keep = "used"` conserva solo las columnas que intervinieron en el cálculo.
- `.before = 1` o `.after = ing_cor` colocan la nueva donde se la pueda ver.
- `.by = nom_ent` calcula por grupo sin `group_by()`.
---
layout: default
section: Sesión 3
subsection: mutate()
---
# `if_else()`
El *helper* de dos ramas: la condición, el valor si se cumple y el valor si no.

El uso más frecuente en datos de encuesta es convertir un código de no respuesta en un faltante declarado.

```r
hogares |>
    mutate(tam_loc = if_else(tam_loc == 9, NA, tam_loc)) |>
    count(tam_loc)
# A tibble: 5 × 2
  tam_loc     n
    <dbl> <int>
1       1   343
2       2   196
3       3   149
4       4    89
5      NA    23
```

<Verde t="if_else() frente a ifelse()">

La versión de base devuelve lo que resulte y a veces pierde el tipo: un `Date` sale como número. `if_else()` exige que las dos ramas sean del mismo tipo y falla en voz alta cuando no lo son.

</Verde>
---
layout: default
section: Sesión 3
subsection: mutate()
---
# `case_when()`
El *helper* de más de dos ramas, evaluadas en orden.

Cada línea es `condición ~ valor`. Se toma la [primera]{.colmex-orange} que se cumple: el orden decide el resultado.

```r
hogares |>
    mutate(
        estrato = case_when(
            ing_cor <  30000  ~ "bajo",
            ing_cor < 100000  ~ "medio",
            ing_cor >= 100000 ~ "alto"
        )
    ) |>
    count(estrato)
# A tibble: 4 × 2
  estrato     n
  <chr>   <int>
1 alto      152
2 bajo       82
3 medio     548
4 <NA>       18
```

Los 18 hogares sin ingreso no caen en ninguna rama y reciben `NA`. Para darles una categoría explícita se agrega `.default = "sin dato"`.
---
layout: default
section: Sesión 3
subsection: summarize()
---
# `summarize()`
Notación base: nombre nuevo, igual, función que reduce.

```r
summarize(datos, nombre = función(columna))
```

La notación es la de `mutate()`, con una diferencia: la expresión tiene que devolver [un solo valor]{.colmex-orange}. El resultado es una tabla de una fila y una columna por argumento.

```r
hogares |> summarize(ing_medio = mean(ing_cor, na.rm = TRUE))
# A tibble: 1 × 1
  ing_medio
      <dbl>
1    70781.
```

Es el único verbo que colapsa la tabla de forma deliberada: 800 filas entran, una sale. Sirven aquí `mean()`, `median()`, `sd()`, `min()`, `max()`, `sum()` y cualquier otra función que devuelva un escalar.
---
layout: default
section: Sesión 3
subsection: summarize()
---
# `summarize()`: argumentos y *helpers*
Varias columnas por llamada, y dos funciones que solo existen aquí.

```r
hogares |>
    summarize(
        hogares   = n(),
        entidades = n_distinct(entidad),
        ing_min   = min(ing_cor, na.rm = TRUE),
        ing_max   = max(ing_cor, na.rm = TRUE)
    )
# A tibble: 1 × 4
  hogares entidades ing_min ing_max
    <int>     <int>   <dbl>   <dbl>
1     800         6   7694. 347889.
```

- `n()` no recibe argumentos: cuenta las filas del contexto en el que se evalúa.
- `n_distinct(x)` cuenta valores únicos; es la forma corta de `length(unique(x))`.
- `.by = nom_ent` resume por grupo sin `group_by()`, y devuelve el resultado desagrupado.

Las dos primeras solo tienen sentido dentro de un verbo: fuera de él no hay contexto del cual contar filas.
---
layout: default
section: Sesión 3
subsection: summarize()
---
# El resumen que sale `NA`
El error más frecuente de la sesión, y no produce ningún mensaje.

```r
hogares |> summarize(ing = mean(ing_cor))
# A tibble: 1 × 1
    ing
  <dbl>
1    NA
```

Dieciocho hogares de ochocientos no declararon ingreso. Basta uno para que el promedio de la columna sea `NA`: es la propagación de la Sesión 2, dentro de un verbo.

```r
hogares |> summarize(ing = mean(ing_cor, na.rm = TRUE))
# A tibble: 1 × 1
      ing
    <dbl>
1  70781.
```

<Rojo t="! Prácticas a Evitar">

Escribir `na.rm = TRUE` por reflejo. El argumento no arregla el dato: cambia el denominador y calcula sobre los 782 hogares que sí respondieron. Es una decisión, y se toma habiendo mirado antes cuántos faltantes hay.

</Rojo>
---
layout: default
section: Sesión 3
subsection: group_by()
---
# `group_by()`
Notación base: la tabla y la columna que define los grupos.

```r
group_by(datos, columna)
```

No transforma la tabla: [marca]{.colmex-orange} el contexto. Los verbos posteriores dejan de operar sobre las 800 filas y pasan a operar una vez por grupo.

```r
hogares |>
    group_by(nom_ent) |>
    summarize(ing_medio = mean(ing_cor, na.rm = TRUE))
# A tibble: 6 × 2
  nom_ent             ing_medio
  <chr>                   <dbl>
1 Ciudad de México       68794.
2 Michoacán de Ocampo    72083.
3 Nuevo León             74414.
4 Oaxaca                 72052.
5 Querétaro              68192.
6 Yucatán                69646.
```

Una fila por grupo, y la columna de agrupación primero. Es la combinación que responde casi toda pregunta comparativa: *cuánto vale esto, por cada cuál*.
---
layout: default
section: Sesión 3
subsection: group_by()
---
# `group_by()`: argumentos y *helpers*
Varias variables, y cómo se apaga la agrupación.

Con dos variables los grupos son las combinaciones observadas, y `summarize()` consume la [última]{.colmex-orange}:

```r
hogares |>
    group_by(nom_ent, tam_loc) |>
    summarize(ing_medio = mean(ing_cor, na.rm = TRUE))
`summarise()` has grouped output by 'nom_ent'. You can override using the
`.groups` argument.
# A tibble: 30 × 3
# Groups:   nom_ent [6]
```

El resultado sigue agrupado por `nom_ent`, y todo verbo posterior operará por entidad aunque nada en su código lo diga. Tres formas de evitarlo:

```r
... |> summarize(n = n(), .groups = "drop")     # dentro del verbo
... |> summarize(n = n()) |> ungroup()          # como paso siguiente
hogares |> summarize(n = n(), .by = nom_ent)    # sin group_by(), ya desagrupado
```

<Verde t="Regla práctica">

Toda cadena que agrupa, desagrupa antes de asignar el resultado a un nombre. `group_vars()` dice si quedó algo puesto.

</Verde>
---
layout: default
section: Sesión 3
subsection: group_by()
---
# `group_by()` con `mutate()`
Cuando el resumen tiene que volver a la fila.

`summarize()` colapsa; `mutate()` sobre datos agrupados calcula el resumen del grupo y lo [reparte de vuelta]{.colmex-blue} en cada fila. Con eso se normaliza una variable contra su propio grupo:

```r
hogares |>
    group_by(nom_ent) |>
    mutate(ing_rel = ing_cor / mean(ing_cor, na.rm = TRUE)) |>
    ungroup() |>
    select(folioviv, nom_ent, ing_cor, ing_rel)
# A tibble: 800 × 4
   folioviv nom_ent             ing_cor ing_rel
   <chr>    <chr>                 <dbl>   <dbl>
 1 0773233  Querétaro            35847.   0.526
 2 0382982  Michoacán de Ocampo  75262.   1.04
 3 0348747  Oaxaca                  NA   NA
# ℹ 797 more rows
```

El primer hogar gana 53% del ingreso medio de Querétaro. Sin agrupar, la misma línea lo compararía contra el promedio nacional, que es otra pregunta.
---
layout: section
eyebrow: Sesión 3 — Bloque de exposición
---
# *Helpers*
---
layout: default
section: Sesión 3
subsection: Helpers
---
# `count()` y `distinct()`
Las dos primeras llamadas sobre una tabla desconocida.

`count()` es `group_by()` más `summarize(n = n())`, en una línea. Con `sort = TRUE` ordena de mayor a menor:

```r
gastos |> count(clave, sort = TRUE)
# A tibble: 8 × 2
  clave     n
  <chr> <int>
1 A001    565
2 D001    562
# ℹ 6 more rows
```

`distinct()` devuelve las combinaciones únicas, sin contarlas. Sirve para verificar que dos columnas se corresponden:

```r
hogares |> distinct(entidad, nom_ent)
# A tibble: 6 × 2
  entidad nom_ent
  <chr>   <chr>
1 22      Querétaro
# ℹ 5 more rows
```

Seis claves y seis nombres: la correspondencia es uno a uno. Si devolviera siete filas, alguna entidad estaría escrita de dos maneras.
---
layout: default
section: Sesión 3
subsection: Helpers
---
# `slice_*()`
Filas por posición o por valor extremo.

```r
hogares |> slice_head(n = 5)              # las primeras cinco
hogares |> slice_sample(n = 5)            # cinco al azar
hogares |> slice_max(ing_cor, n = 5)      # las cinco mayores
hogares |> slice_min(ing_cor, n = 5)      # las cinco menores
```

Combinado con `group_by()` responde una pregunta que `arrange()` no alcanza: el extremo [dentro de cada grupo]{.colmex-orange}.

```r
hogares |>
    group_by(nom_ent) |>
    slice_max(ing_cor, n = 1) |>
    select(nom_ent, folioviv, ing_cor)
# A tibble: 6 × 3
# Groups:   nom_ent [6]
  nom_ent             folioviv ing_cor
  <chr>               <chr>      <dbl>
1 Ciudad de México    0677507  347889.
2 Michoacán de Ocampo 0588763  252729.
# ℹ 4 more rows
```

`slice_max(x, n = 1)` no es `filter(x == max(x))`: devuelve una fila aunque haya empates y no se rompe con faltantes.
---
layout: section
eyebrow: Sesión 3 — Bloque de exposición
---
# *Non-Standard Evaluation*
---
layout: default
section: Sesión 3
subsection: NSE
---
# Por qué `filter(df, x > 5)` funciona
Una función normal de R no podría hacer eso.

`ing_cor` no es un objeto del entorno. Escrito suelto en la consola produce un error, y sin embargo adentro de `filter()` se resuelve sin comillas y sin `$`:

```r
ing_cor
Error: objeto 'ing_cor' no encontrado

hogares |> filter(ing_cor > 100000)   # funciona
```

Lo que ocurre es que los verbos no reciben el [valor]{.colmex-orange} del argumento sino la [expresión sin evaluar]{.colmex-blue}, y la evalúan después en un entorno donde las columnas de la tabla existen como si fueran objetos. Eso es *data masking*, la forma de NSE que usa el tidyverse.

<br>

<Verde t="Qué se gana">

Menos ruido. `filter(hogares$entidad == "09" & hogares$tot_integ >= 4)` repite el nombre de la tabla en cada condición; `filter(entidad == "09", tot_integ >= 4)` no lo repite ninguna. En una cadena de seis pasos la diferencia es la legibilidad completa.

</Verde>
---
layout: default
section: Sesión 3
subsection: NSE
---
# Qué se paga a cambio
La ambigüedad entre un nombre de columna y un nombre del entorno.

Si existe un objeto llamado igual que una columna, la columna gana, y el resultado no es el esperado:

```r
entidad = "09"
hogares |> filter(entidad == entidad) |> nrow()
[1] 800
```

Los dos lados de la comparación son la columna, así que la condición es `TRUE` en las 800 filas. No hay error, no hay advertencia: solo un filtro que no filtró.

Dos [pronombres]{.colmex-blue} resuelven la ambigüedad diciendo explícitamente de dónde sale cada nombre:

```r
hogares |> filter(.data$entidad == .env$entidad) |> nrow()
[1] 133
```

<Verde t="Regla práctica">

Nombrar los objetos del entorno de forma que no puedan colisionar: `ent_objetivo`, no `entidad`. Los pronombres son la salida cuando la colisión ya existe.

</Verde>
---
layout: default
section: Sesión 3
subsection: NSE
---
# Lo que se rompe en la Sesión 5
El anuncio de un problema, no su solución.

El mismo mecanismo que hace legible una cadena impide envolverla en una función. Este intento parece razonable y no funciona:

```r
resumen_por = function(datos, variable) {
    datos |>
        group_by(variable) |>
        summarize(ing_medio = mean(ing_cor, na.rm = TRUE))
}

resumen_por(hogares, nom_ent)
Error in `group_by()`:
! Column `variable` is not found.
```

`group_by()` no evalúa `variable`: busca una columna con ese nombre literal. El argumento nunca llega a leerse como lo que contiene.

<Azul t="Adelanto">

La solución se llama *tunneling* y se escribe `{{ variable }}`. Requiere entender antes cómo se evalúan los argumentos en R, que es material de la Sesión 5. Por ahora basta con reconocer el síntoma: [`Column ... is not found`]{.colmex-orange} al pasar un nombre de columna como argumento.

</Azul>
---
layout: default
section: Sesión 3
subsection: Cierre
---
# De la pregunta a la cadena
El orden de los verbos casi siempre es el mismo.

| La pregunta dice | El verbo es |
|---|---|
| «solo los hogares que…» | `filter()` |
| «por cada entidad», «según sexo» | `group_by()` |
| «el promedio», «el total», «cuántos» | `summarize()` con `n()`, `mean()`, `sum()` |
| «per cápita», «como proporción de» | `mutate()` |
| «los cinco mayores», «el más alto» | `arrange()` + `slice_max()` |
| «cuántos hay de cada» | `count()` |

<br>

Un orden que funciona como punto de partida: **filtrar → calcular → agrupar → resumir → ordenar**.

<Verde t="Cómo se depura una cadena">

Por partes: se ejecuta hasta el primer `|>`, se mira el resultado, se agrega el paso siguiente. El error casi nunca está donde revienta, está en el eslabón anterior.

</Verde>
---
layout: default
section: Sesión 3
subsection: Cierre
---
# Recapitulación
Lo que esta sesión deja instalado.

- [**El tidyverse.**]{.colmex-blue} Paquetes con una gramática común: la tabla va primero, el retorno es una tabla, las columnas se nombran sin comillas. El mensaje de carga declara qué funciones quedaron enmascaradas.
- [**El *pipe*.**]{.colmex-blue} `|>` inserta en el primer argumento; el marcador `_` dice dónde va la tabla cuando la función no sigue el acuerdo del tidyverse.
- [**Los seis verbos.**]{.colmex-orange} `filter()` y `arrange()` sobre filas, `select()` y `mutate()` sobre columnas, `summarize()` colapsa, `group_by()` fija el contexto.
- [**Los faltantes.**]{.colmex-orange} `filter()` los descarta en silencio, `arrange()` los manda al final, `summarize()` los propaga hasta volver `NA` el resumen completo.
- [**Agrupar.**]{.colmex-blue} `summarize()` consume una variable de agrupación y deja el resto puesto. Toda cadena que agrupa, desagrupa.
- [***Helpers*.**]{.colmex-blue} `count()` y `distinct()` para reconocer una tabla; `slice_*()` para extremos; `if_else()` y `case_when()` para recodificar.
- [**NSE.**]{.colmex-blue} Las columnas se resuelven en el contexto de la tabla. Esa comodidad se paga al escribir funciones, y ahí entra la Sesión 5.

### Hacia la Sesión 4

Los verbos operan sobre [una]{.colmex-orange} tabla. La EIGH tiene tres, y las preguntas interesantes cruzan varias: gasto por entidad exige unir `gastos` con `hogares`. La Sesión 4 agrega los *joins* y los *pivots*.
---
layout: section
eyebrow: Sesión 3 — Bloque de práctica
---
# Bloque de práctica
---
layout: default
section: Sesión 3
subsection: Bloque de Práctica
---
# Un reporte de ingreso y gasto
Hora y media de código en vivo sobre la EIGH.

El bloque de práctica no son ejercicios sueltos: es [un solo encargo]{.colmex-blue}, resuelto por partes, que al terminar produce tres tablas de resultados. Cada parte se escribe primero en pantalla, en conjunto, y se sigue en el script.

<br>

1. [**Reconocer**]{.colmex-orange} las tres tablas con `glimpse()`, `count()` y `distinct()`.
2. [**Recortar**]{.colmex-orange} el universo de análisis con `filter()` y dejarlo dicho por escrito.
3. [**Construir**]{.colmex-orange} los indicadores por hogar: ingreso per cápita, gasto per cápita, estrato.
4. [**Comparar**]{.colmex-orange} por entidad y por tamaño de localidad con `group_by()` y `summarize()`.
5. [**Perfilar**]{.colmex-orange} a las personas: participación e ingreso por sexo y grupo de edad.
6. [**Cerrar**]{.colmex-orange} con la tabla de gastos: qué rubro pesa más y en qué hogares.

<br>

<Rojo t="Recordatorio">

El bloque de práctica se resuelve [sin asistencia de modelos de lenguaje]{.colmex-orange}. El archivo de trabajo es `pre/ejercicios_03.R`.

</Rojo>

<!-- instructor-only -->

> Tiempo: 1:15. Las partes 1 a 3 en el proyector, con la clase dictando el verbo antes de escribirlo. De la 4 en adelante, cada quien en su máquina y recorrido por el salón. La parte 6 se sacrifica si el tiempo aprieta.

<!-- /instructor-only -->
---
layout: default
section: Sesión 3
subsection: Referencias
---
# Lecturas
Para la sesión y para la siguiente.

- *R for Data Science* (2.ª ed.), Cap. 3 *Data transformation*, completo.
- *R for Data Science* (2.ª ed.), Cap. 5 *Data tidying*, §5.1 y §5.2. Los *pivots* de §5.3 y §5.4 corresponden a la Sesión 4.

<br>

### Referencia rápida

- *Data transformation with `dplyr`* — cheatsheet de Posit. Una hoja con los seis verbos, los *helpers* de selección y las funciones de resumen. Vale la pena tenerla abierta durante el bloque de práctica.

<br>

<Azul t="Cómo se lee la documentación de un verbo">

`?filter` abre la ayuda. La sección que sirve es la última: los ejemplos ejecutables. La descripción de los argumentos se entiende después de haber corrido uno.

</Azul>
---
layout: cover
title: ¡Gracias!
subtitle: Sesión 3 — Programación para Proyectos de Datos I
---
