# Guía de estudio — Semana 10: Programación funcional con `purrr` y `apply`

> **Audiencia:** instructor (Daniel). Esta guía complementa el bloque del syllabus para Semana 10. Está pensada para que llegues a la clase con seguridad sobre el material — no para los estudiantes.

---

## 1. El núcleo conceptual: tres ideas que cargan toda la semana

### 1.1 Funciones como objetos de primera clase

En R, una función no es distinta de un vector o de un dataframe en términos de manipulación: la puedes asignar, pasar como argumento, devolver, almacenar en una lista. Esto habilita la programación funcional.

```r
sumar <- function(x, y) x + y
restar <- function(x, y) x - y

# Las funciones son datos
operaciones <- list(suma = sumar, resta = restar)
operaciones$suma(3, 4)  # → 7
```

Ese hecho —que las funciones son ciudadanos de primera clase— es la base de toda la semana. Si los estudiantes no salen convencidos de esto, el resto se siente como sintaxis arbitraria.

### 1.2 El patrón "functional"

Un *functional* es una función que toma **otra función** como argumento. Los tres patrones canónicos:

| Patrón | Verbo natural | Ejemplo en R |
|---|---|---|
| **Map** | "aplicar a cada uno" | `map(lista, fn)`, `lapply(lista, fn)` |
| **Reduce** | "colapsar a uno" | `reduce(lista, fn)`, `Reduce(fn, lista)` |
| **Filter** | "quedarse con los que cumplen" | `keep(lista, predicado)`, `Filter(predicado, lista)` |

Estos tres son universales: existen en JavaScript, Python, Scala, Haskell, etc. Si el estudiante entiende los tres, entiende programación funcional al nivel que necesita el curso.

### 1.3 Por qué reemplazar loops por functionals

| Loop | Functional |
|---|---|
| Imperativo: dice *cómo* iterar | Declarativo: dice *qué* hacer con cada elemento |
| Tipo de salida implícito (depende de cómo lo armaste) | Tipo de salida garantizado por el sufijo (`map_dbl` → numérico) |
| Pre-asignación manual | Asignación automática |
| Difícil de paralelizar | `furrr::future_map()` paraleliza con un cambio de prefijo |
| Se ven distintos cada vez | Se ven iguales: el patrón es reconocible |

Cuándo el loop es **mejor**:
- La iteración tiene estado (cada paso depende del anterior y `reduce/accumulate` no aplica limpiamente).
- El cuerpo del loop tiene side effects complejos y `walk` no alcanza.
- Necesitas `break`/`next` por lógica genuina.

Para todo lo demás, functional.

### 1.4 Diferencias computacionales (lo que tienes que poder explicar)

Esto es lo que hay **debajo** del patrón. Los estudiantes no tienen que dominar los detalles, pero sí saber que existen y por qué afectan la elección.

| Aspecto | `for` ingenuo | `for` con pre-asignación | `map_*` de `purrr` |
|---|---|---|---|
| **Asignación de memoria** | Crece dinámicamente (`c(out, x)` o `out[[i+1]] <- x` re-asigna) | Una sola asignación al inicio | Una sola asignación interna |
| **Estabilidad de tipo** | Ninguna garantía | Sí, si pre-asignaste con tipo correcto y respetas el contrato | **Garantizada por construcción.** `map_dbl` falla si una iteración no devuelve escalar numérico |
| **Ámbito de variables** | Las variables del loop persisten en el entorno actual (`i` queda asignado) | Igual | El cuerpo es una función anónima: variables internas no escapan |
| **Side effects** | Permitidos por *default*; mutar el entorno externo es trivial | Igual | Más contenidos; `walk` declara explícitamente la intención de *side effect* |
| **Vía a paralelización** | Re-escritura significativa (`parallel::mclapply`, `foreach`...) | Igual | Cambio de prefijo: `purrr::map` → `furrr::future_map` |
| **Performance bruto** | Lentísimo (cuadrático en n) si crece dinámicamente | Comparable a `map_*` o ligeramente más rápido | Comparable a `for` con pre-asignación; pequeño *overhead* por *dispatching* |

#### El punto pedagógico (esto es lo que vale la pena llevar a clase)

- Si el `for` está bien escrito (con pre-asignación y tipos respetados), su performance es **indistinguible** de `purrr`. El argumento *"purrr es más rápido"* es **falso**.
- Los argumentos reales para `purrr` son: **estabilidad de tipo, contención de ámbito, consistencia visual y paralelización gratuita** — no velocidad.
- El estudiante que sabe esto elige con criterio. El que cree que `purrr` es más rápido está cargando un mito.

#### Microbenchmark para mostrar en clase

```r
library(microbenchmark)
x <- 1:1000

for_naive <- function() {
  out <- c()
  for (i in x) out <- c(out, sqrt(i))
  out
}

for_prealloc <- function() {
  out <- numeric(length(x))
  for (i in seq_along(x)) out[i] <- sqrt(x[i])
  out
}

map_version <- function() purrr::map_dbl(x, sqrt)

vectorized <- function() sqrt(x)

microbenchmark(for_naive(), for_prealloc(), map_version(), vectorized(), times = 100)
```

Resultado típico, en órdenes de magnitud:

| Versión | Tiempo relativo |
|---|---|
| `for_naive` | ~100x (cuadrático en *n*) |
| `for_prealloc` | ~1x |
| `map_version` | ~1x (overhead marginal) |
| `vectorized` | ~0.01x (operación C bajo el capó) |

El gancho visual: el problema **no** es `for`, es `for` sin pre-asignación. Y la victoria computacional real es la **vectorización** (S8), no los *functionals*. Los *functionals* ganan en otras dimensiones.

---

## 2. La familia `apply` (base R)

Es la versión histórica de programación funcional en R. Existe desde S, mucho antes de purrr. Vale la pena entenderla porque (a) está en todo el código base, (b) no requiere paquetes adicionales y (c) `lapply` sigue siendo la herramienta más rápida en muchos casos.

### 2.1 Tabla de funciones

| Función | Entrada | Salida | Notas |
|---|---|---|---|
| `lapply(x, f)` | lista o vector | **lista** (siempre) | El más predecible. Análogo de `map()`. |
| `sapply(x, f)` | lista o vector | vector si puede; matriz si puede; lista si no | **Inconsistente.** Su tipo de retorno depende de los datos. Evítalo en código de producción. |
| `vapply(x, f, FUN.VALUE)` | lista o vector | vector con tipo declarado | Como `sapply` pero con contrato de tipo. Análogo de `map_dbl`/`map_chr`/`map_lgl`. |
| `mapply(f, x, y)` | varios vectores | vector (con `SIMPLIFY=FALSE`, lista) | Análogo de `map2`/`pmap`. |
| `apply(matriz, MARGIN, f)` | matriz | vector o matriz | `MARGIN=1` filas, `MARGIN=2` columnas. **No** confundir con `lapply`. |
| `tapply(x, grupo, f)` | vector + grupo | vector con nombres | `split-apply`. Análogo a `dplyr::group_by() |> summarize()`. |

### 2.2 El problema de `sapply`

```r
sapply(list(1:3, 1:5), length)
#> [1] 3 5
# Un vector — bien

sapply(list(1:3, 1:5), function(x) x)
#> [[1]] [1] 1 2 3
#> [[2]] [1] 1 2 3 4 5
# Una lista — porque no pudo simplificar

sapply(list(1:3, 1:3), function(x) x)
#>      [,1] [,2]
#> [1,]    1    1
#> [2,]    2    2
#> [3,]    3    3
# Una matriz — porque las salidas tenían longitud uniforme
```

Tres tipos de retorno distintos para llamadas casi idénticas. Por eso purrr existe: `map_dbl` te falla en compilación si el tipo no es uniforme, en lugar de devolverte algo diferente sin avisar.

### 2.3 Cuándo usar `lapply` aún hoy

- Scripts sin dependencias (no quieres cargar tidyverse).
- Performance crítica: `lapply` es marginalmente más rápido que `purrr::map` por overhead.
- Código que será leído por gente sin purrr instalado (poco común hoy).

---

## 3. `purrr`: el sistema unificado

### 3.1 La idea: el sufijo declara el tipo

```r
library(purrr)

map(1:3, sqrt)         # → list(1, 1.41, 1.73)
map_dbl(1:3, sqrt)     # → c(1, 1.41, 1.73)
map_chr(1:3, as.character) # → c("1", "2", "3")
map_lgl(1:3, ~ .x > 2) # → c(FALSE, FALSE, TRUE)
map_int(1:3, ~ .x * 2L) # → c(2L, 4L, 6L)
```

Si el sufijo no coincide con el tipo real devuelto por la función, `map_*` falla con un error claro. Esto es **type stability** y es el principal valor de `purrr` sobre `sapply`.

### 3.2 Funciones anónimas: dos sintaxis

**Estilo R 4.1+ (recomendado):**
```r
map_dbl(1:5, \(x) x^2 + 1)
```

**Estilo purrr (`~` con `.x`):**
```r
map_dbl(1:5, ~ .x^2 + 1)
```

Ambos funcionan. La sintaxis `\(x)` es más estándar y portable; la `~` es más corta. **Recomendación para el curso:** enseñar `\(x)` como default, mencionar `~` porque está en todo el código existente.

### 3.3 Variantes para varias entradas

```r
# map2: dos vectores en paralelo
map2_dbl(c(1, 2, 3), c(10, 20, 30), \(a, b) a + b)
#> [1] 11 22 33

# pmap: n vectores via lista
pmap_dbl(list(c(1, 2), c(10, 20), c(100, 200)),
         \(a, b, c) a + b + c)
#> [1] 111 222
```

Regla práctica: si tienes 1 vector → `map`; si tienes 2 → `map2`; si tienes 3 o más → `pmap` con lista.

### 3.4 `walk`: iteración por side effects

Cuando la función no devuelve nada útil (escribe a disco, imprime, manda mensaje), usa `walk`. Se diferencia de `map` en que devuelve el input invisiblemente, pensado para encadenar.

```r
# Guardar N gráficas
walk2(graficas, nombres,
      \(g, n) ggsave(paste0(n, ".png"), g))

# Imprimir mensajes
walk(archivos, \(a) message("Procesando: ", a))
```

`walk` es el patrón natural en ETL para escribir archivos múltiples sin acumular outputs.

### 3.5 `map_dfr` y `map_dfc`: salida en data frame

Cuando cada iteración devuelve un data frame y quieres pegarlos:

```r
# Por filas (rbind)
archivos <- list.files("input/", full.names = TRUE)
datos <- map_dfr(archivos, read_csv)

# Por columnas (cbind) — menos común
columnas <- map_dfc(c("a", "b", "c"), \(col) tibble("{col}" := rnorm(10)))
```

`map_dfr` es **el** patrón para "lee todos los archivos de una carpeta y combínalos en un dataset".

> **Nota:** en versiones recientes de purrr (≥1.0), `map_dfr`/`map_dfc` están *suavemente* depreciadas en favor de `map() |> list_rbind()` / `list_cbind()`. Ambas formas funcionan; `map_dfr` sigue siendo idiomática y aceptada.

---

## 4. Reducción y predicados

### 4.1 `reduce`

`reduce(x, f)` aplica `f` acumulativamente: `f(f(f(x[1], x[2]), x[3]), x[4])`. Útil cuando una función toma dos argumentos y quieres aplicarla sobre una lista.

```r
# Sumar una lista (caso trivial; equivalente a sum())
reduce(1:5, `+`)        # → 15

# Joins múltiples — caso real
tablas <- list(t1, t2, t3)
combinada <- reduce(tablas, left_join, by = "id")
```

El segundo ejemplo es **el** caso de uso principal en datos: cuando tienes N tablas que debes ir combinando con joins, `reduce(tablas, left_join, by = "id")` reemplaza un loop.

### 4.2 `accumulate`

Como `reduce` pero conserva los pasos intermedios.

```r
accumulate(1:5, `+`)
#> [1]  1  3  6 10 15

# Útil para cumsum sobre listas, paths de transformación, etc.
```

### 4.3 Predicados

Funciones que toman un elemento y devuelven `TRUE`/`FALSE`. `purrr` los usa para filtrado y validación de listas.

| Función | Qué hace | Devuelve |
|---|---|---|
| `keep(x, p)` | Quédate con los elementos donde `p(x) == TRUE` | Lista filtrada |
| `discard(x, p)` | Descarta los elementos donde `p(x) == TRUE` | Lista filtrada |
| `every(x, p)` | ¿Todos cumplen? | Logical único |
| `some(x, p)` | ¿Al menos uno cumple? | Logical único |
| `none(x, p)` | ¿Ninguno cumple? | Logical único |
| `detect(x, p)` | Devuelve el primer elemento que cumple | Elemento |
| `detect_index(x, p)` | Posición del primero que cumple | Integer |

```r
listas <- list(c(1,2,3), c(4,5), c(6,7,8,9))

keep(listas, \(x) length(x) > 2)
#> [[1]] 1 2 3
#> [[2]] 6 7 8 9

every(listas, \(x) is.numeric(x))   # TRUE
some(listas,  \(x) length(x) > 3)   # TRUE
```

---

## 5. `across()`: iteración dentro de `dplyr`

`across()` permite aplicar una función a varias columnas dentro de `mutate()` o `summarize()` sin escribir un loop. Es la cara de `purrr` dentro del flujo tidy.

### 5.1 Forma básica

```r
# Convertir varias columnas a numérico
df |> mutate(across(c(precio, cantidad, total), as.numeric))

# Con tidy-select helpers
df |> mutate(across(starts_with("var_"), as.numeric))
df |> mutate(across(where(is.character), str_trim))
```

### 5.2 Múltiples funciones a la vez

```r
df |>
  group_by(grupo) |>
  summarize(across(c(x, y, z), list(media = mean, sd = sd), .names = "{.col}_{.fn}"))
```

Genera columnas `x_media`, `x_sd`, `y_media`, `y_sd`, etc. Patrón clásico para tablas de descriptivas.

### 5.3 `if_any` / `if_all`

Para usar una condición sobre varias columnas dentro de `filter`.

```r
df |> filter(if_any(c(a, b, c), is.na))   # filas con NA en al menos una
df |> filter(if_all(c(a, b, c), \(x) x > 0)) # filas con todas positivas
```

---

## 6. Paralelización: `furrr` + `future`

Una de las grandes virtudes operativas de los *functionals* es que paralelizar es **un cambio de prefijo**, no una re-escritura:

```r
library(furrr)
plan(multisession, workers = 4)

# Secuencial
map_dbl(1:1000, tarea)

# Paralelo (mismo código, prefijo distinto)
future_map_dbl(1:1000, tarea)
```

Las firmas de `furrr::future_map_*` son idénticas a las de `purrr::map_*`. Esto es la ganancia central: el patrón se mantiene; solo cambia el motor de ejecución.

### 6.1 El modelo de paralelización en R (lo que tienes que poder explicar)

R es **single-threaded** por defecto. La paralelización vía `future` no usa hilos sino **procesos** separados:

- Cada *worker* es un proceso R completo, con su propio espacio de memoria.
- **No hay memoria compartida.** Los objetos globales que la función necesita se serializan y se copian a cada *worker* al inicio.
- Los resultados también se serializan al regresar al proceso principal.

Esto tiene consecuencias prácticas muy concretas.

**Multiplicación de memoria.** Si tu dataset pesa 1 GB y declaras `workers = 4`, vas a necesitar ~4 GB de RAM solo para los workers (más lo que use el proceso principal). En máquinas modestas esto es una restricción real. Regla mental:

> `workers × tamaño_de_objetos_globales ≈ RAM mínima requerida`

**Costo de serialización.** Mover objetos grandes entre procesos no es gratis. Si tu iteración hace algo trivial sobre un objeto grande, vas a pagar más en *overhead* de copia/serialización que lo que ganas en cómputo. **Cosa pequeña × muchas veces = malo para paralelizar.**

**Cuándo paraleliza bien:**
- Tareas *CPU-bound* (cómputo pesado, modelos, simulaciones, *bootstrap*).
- Iteraciones independientes (no comparten estado, no se comunican entre sí).
- Inputs y outputs pequeños relativo al cómputo por iteración.
- N de iteraciones >> N de workers.

**Cuándo NO paraleliza bien:**
- Tareas *I/O-bound* (leer/escribir disco): los workers se bloquean esperando disco; en el peor caso, varios workers compiten por el mismo disco.
- Iteraciones triviales: *overhead* > beneficio.
- Cuando el objeto global es enorme y la tarea por iteración es chica.
- Tareas con efectos colaterales no aislados (escribir al mismo archivo desde varios workers, por ejemplo).

### 6.2 Backends de `future`

```r
# Para debug: secuencial, sin procesos extra
plan(sequential)

# Portable a Windows/Mac/Linux: spawn de procesos R nuevos
# Cada worker tarda un poco en arrancar; copia objetos vía serialización
plan(multisession, workers = 4)

# Solo Unix (Mac/Linux): forking. Comparte memoria via copy-on-write
# (más eficiente), PERO problemático dentro de RStudio/Positron en
# sesiones interactivas (suele colgarse). Reservar para scripts batch.
plan(multicore, workers = 4)

# Cluster en otra máquina (avanzado, fuera del alcance del curso)
plan(cluster, workers = c("host1", "host2"))
```

**Default recomendado para el curso: `multisession`.** Portable, funciona en todas las plataformas y dentro de Positron/RStudio sin tropiezos. La pérdida de eficiencia frente a `multicore` es marginal y vale el costo por seguridad.

### 6.3 Reproducibilidad con semillas

Cuando la iteración usa números aleatorios (simulación, *bootstrap*, *resampling*), el orden no-determinístico de ejecución paralela puede hacer el resultado no reproducible. `furrr` resuelve esto con la opción `seed`:

```r
future_map_dbl(
  1:1000,
  \(i) rnorm(1) |> abs(),
  .options = furrr_options(seed = TRUE)
)
```

Sin `seed = TRUE` puedes obtener resultados distintos entre corridas idénticas. Es un *gotcha* común — vale la pena mencionarlo en clase.

### 6.4 Microbenchmark para mostrar en clase

```r
library(microbenchmark)
library(furrr)

x <- 1:100

# Tarea CPU-bound suficientemente pesada para que valga la pena
tarea_pesada <- function(i) {
  Sys.sleep(0.05)  # simula cómputo
  i^2
}

plan(sequential)
sec <- function() future_map_dbl(x, tarea_pesada)

plan(multisession, workers = 4)
par <- function() future_map_dbl(x, tarea_pesada)

microbenchmark(sec(), par(), times = 3)
```

Resultado esperado:

| Versión | Tiempo |
|---|---|
| `sec()` | ~5 s (100 × 0.05 s) |
| `par()` | ~1.3 s (idealmente 1.25 s, más overhead) |

Speedup teórico = N workers; speedup real es menor por overhead de spawn + serialización + sincronización.

**Contraprueba pedagógica:** correr el mismo benchmark con `tarea_trivial <- function(i) i^2` (sin sleep). El secuencial gana al paralelo porque el overhead domina. Esto pega visualmente y demuestra que "paralelizar" no es gratis.

### 6.5 El punto pedagógico

Tres ideas que vale la pena llevarse de esta sección:

1. **Paralelizar es un cambio de prefijo, no una re-escritura.** Esa es la victoria. El código mantiene su estructura.
2. **Pero tiene costo de memoria real.** R copia el mundo a cada worker. No es gratis. Plan tus RAM antes de plan tu `workers`.
3. **No toda iteración se beneficia.** Medir antes de paralelizar. Una tarea trivial × muchas veces se ejecuta más lento en paralelo que en secuencial.

---

## 7. Patrones aplicados (el "set jugable" para clase)

Estos son los patrones que vas a querer mostrar en clase y que probablemente aparezcan en el proyecto integrador.

### 6.1 Leer N archivos de una carpeta

```r
archivos <- list.files("input/", pattern = "\\.csv$", full.names = TRUE)
datos <- map_dfr(archivos, read_csv, .id = "archivo")
# .id agrega una columna con el path, útil para saber de dónde vino cada fila
```

### 6.2 Ajustar un modelo por grupo

```r
modelos <- df |>
  group_by(grupo) |>
  group_split() |>
  map(\(d) lm(y ~ x, data = d))

# Extraer coeficientes
map_dfr(modelos, broom::tidy, .id = "grupo")
```

### 6.3 Guardar N gráficas

```r
graficas <- df |>
  group_split(grupo) |>
  map(\(d) ggplot(d, aes(x, y)) + geom_point() + ggtitle(unique(d$grupo)))

walk2(graficas,
      paste0("output/grafica_", seq_along(graficas), ".png"),
      \(g, ruta) ggsave(ruta, g, width = 6, height = 4))
```

### 6.4 Joins múltiples con `reduce`

```r
tablas <- list(personas, hogares, vivienda)
encuesta_completa <- reduce(tablas, left_join, by = "id_hogar")
```

### 6.5 Validación de columnas

```r
# Todas las columnas numéricas tienen al menos un valor no-NA
every(df |> select(where(is.numeric)),
      \(col) any(!is.na(col)))
```

---

## 8. Errores comunes y cómo diagnosticarlos

### 7.1 "El sufijo no coincide con el tipo"

```r
map_dbl(c("1", "2", "tres"), as.numeric)
# Warning: NAs introduced by coercion
# Pero ojo: si una función a veces devuelve numeric y a veces character, falla.
```

Usa `map()` (devuelve lista) si no estás seguro del tipo, luego inspecciona y elige el sufijo correcto.

### 7.2 "Devuelve una lista anidada cuando esperaba un vector"

Probablemente porque tu función devuelve un vector de longitud >1 por elemento. `map_dbl` exige longitud 1 por elemento. Si la función devuelve longitud variable, usa `map` y luego `unlist` o `list_c`.

### 7.3 NULL vs NA en outputs

Si una iteración devuelve `NULL`, `map` la mantiene en la lista. Eso puede romper un `map_dbl` posterior. Usa `compact()` para eliminar NULLs:

```r
map(items, fn) |> compact() |> map_dbl(\(x) x$valor)
```

### 7.4 Funciones anónimas con `dplyr` adentro

Si dentro de la función anónima necesitas referirte al elemento iterado por nombre, recuerda que `\(x)` te lo da como `x` y `~` te lo da como `.x`. Mezclarlos confunde.

### 7.5 Tibbles vs data frames en `map_dfr`

`map_dfr` requiere que cada iteración devuelva un data frame con columnas compatibles. Si una iteración devuelve un tibble con columnas distintas, `bind_rows` rellenará con NA — útil pero a veces inesperado.

---

## 9. Tabla decisión rápida (la que vas a tener abierta en clase)

| Situación | Herramienta |
|---|---|
| Una operación built-in sobre un vector | Vectorización (S8) — sin functional |
| Aplicar mi función a cada elemento, salida lista | `map()` o `lapply()` |
| Aplicar mi función a cada elemento, salida vector | `map_dbl/chr/lgl/int()` |
| Aplicar mi función a cada elemento, salida data frame | `map_dfr()` (rbind) o `map_dfc()` (cbind) |
| Iterar con dos vectores en paralelo | `map2_*()` |
| Iterar con n vectores en paralelo | `pmap_*()` |
| Iterar y descartar el output (side effects) | `walk()`, `walk2()` |
| Colapsar una lista a un valor | `reduce()` |
| Colapsar una lista guardando pasos | `accumulate()` |
| Quedarme con elementos que cumplen | `keep()` |
| ¿Todos cumplen? | `every()` |
| Aplicar misma fn a varias columnas en mutate/summarize | `across()` |
| Filtrar filas con condición sobre varias columnas | `if_any()`, `if_all()` |
| Iteración con estado dependiente del paso anterior | `for` loop honesto |
| Iteración con `break`/`next` por lógica genuina | `for` loop honesto |

---

## 10. Lecturas y orden recomendado

**Para preparar la clase, en este orden:**

1. **R4DS Cap. 26 *Iteration*** — la versión aplicada. Más corta y aterriza los casos de uso. Léelo primero para tener los ejemplos concretos en la cabeza.
2. **Advanced R Cap. 9 *Functionals*** — la versión profunda. Léelo segundo para tener el modelo mental claro y los nombres de los patrones.
3. **Cheatsheet de purrr** — `https://rstudio.github.io/cheatsheets/purrr.pdf` — para consultar durante la clase. Tener impresa.

**Lecturas complementarias por si quieres profundizar:**

- *Advanced R* Cap. 10 *Function factories* y Cap. 11 *Function operators* — siguen el hilo de FP. No los necesitas para enseñar S10, pero te dan el contexto completo.
- Documentación oficial de purrr: `https://purrr.tidyverse.org/` — sección "Articles" tiene varios ejemplos buenos.
- Para `across()` específicamente: `https://dplyr.tidyverse.org/articles/colwise.html` — la viñeta oficial.

---

## 11. Una nota final sobre por qué este tema importa

Este es el tema que separa al estudiante que *escribe código* del que *piensa en código*. Una vez que internalizas el patrón funcional, dejas de ver iteraciones como problemas mecánicos ("hago un loop, declaro un vector, asigno por índice") y empiezas a verlas como aplicaciones del operador correcto sobre la colección correcta.

Si los estudiantes salen de la semana convencidos de que `map_dfr(archivos, read_csv)` es **la forma normal** de leer múltiples archivos —no un truco avanzado— habrán internalizado el paradigma. El resto es vocabulario.
