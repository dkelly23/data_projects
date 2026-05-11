# Guía de estudio — Semana 13: Visualización con `ggplot2`

> **Audiencia:** instructor (Daniel). Esta guía complementa el bloque del syllabus para Semana 13. Está pensada para que llegues a la clase con seguridad sobre el material — no para los estudiantes.

---

## 1. La idea fundacional: gramática de gráficas

`ggplot2` no es una librería de funciones para hacer gráficas. Es una **implementación de una gramática**: un conjunto pequeño de componentes que se combinan según reglas explícitas para producir cualquier visualización. Esa diferencia conceptual es lo que hay que llevarse a la clase.

La gramática viene del libro *The Grammar of Graphics* (Leland Wilkinson, 1999). Wickham la implementó en R en 2007. La idea central:

> Una gráfica es la composición de **capas independientes**. Cada capa tiene una responsabilidad bien acotada. Si la gráfica no se ve como quieres, identificas qué capa controla qué y modificas solo esa.

**Por qué esto importa pedagógicamente:**

- El estudiante que entiende el modelo por capas puede producir cualquier gráfica desde cero.
- El estudiante que solo memoriza recetas (`geom_bar()` para barras, `geom_line()` para líneas) se atora cuando la gráfica que quiere no encaja con ninguna receta.
- La depuración cambia: en vez de "no me sale lo que quiero" → "el problema está en la capa X".

---

## 2. Las 8 capas (lo que tienes que poder enumerar de memoria)

| Capa | Qué controla | Comando típico |
|---|---|---|
| **Data** | El *tibble* que se grafica | Primer argumento de `ggplot()` |
| **Aesthetics** | Qué variable se mapea a qué propiedad visual | `aes(x = var1, y = var2, color = var3)` |
| **Geoms** | La marca visual (puntos, líneas, barras...) | `geom_point()`, `geom_line()`, `geom_bar()` |
| **Stats** | Transformaciones estadísticas implícitas (count, smooth, bin) | `stat_smooth()`, o detrás de un geom |
| **Position** | Cómo se resuelven solapamientos (stack, dodge, jitter) | `position = "dodge"`, `geom_jitter()` |
| **Scales** | Cómo se traducen aesthetics a valores visuales (rango, formato) | `scale_x_log10()`, `scale_color_brewer()` |
| **Coords** | El sistema de coordenadas (cartesiano, polar, transformado) | `coord_flip()`, `coord_polar()` |
| **Facets** | Partición de la gráfica en sub-paneles | `facet_wrap(~ grupo)`, `facet_grid(a ~ b)` |
| **Theme** | Todo lo no-dato (tipografía, fondos, ejes, leyendas) | `theme_minimal()`, `theme(legend.position = "bottom")` |

Son 9 entradas en la tabla pero a veces se cuentan como 7-8 dependiendo de cómo se agrupen (algunas guías meten *stats* y *position* dentro de geoms; otras separan).

### 2.1 Ejemplo de las capas en acción

```r
library(ggplot2)
library(scales)

ggplot(mtcars,                                  # capa 1: data
       aes(x = wt, y = mpg, color = factor(cyl))) +  # capa 2: aesthetics
  geom_point(size = 3, alpha = 0.7) +           # capa 3: geom (con settings)
  geom_smooth(method = "lm", se = FALSE) +      # otro geom + stat implícita
  scale_x_continuous(labels = label_comma()) +  # capa 6: scale
  scale_color_brewer(palette = "Set2",          # capa 6: scale para color
                     name = "Cilindros") +
  coord_cartesian(ylim = c(0, 40)) +            # capa 7: coord (zoom)
  facet_wrap(~ am) +                            # capa 8: facet
  labs(title = "Peso vs. millaje por cilindros",
       x = "Peso", y = "MPG") +
  theme_minimal() +                             # capa 9: theme
  theme(legend.position = "bottom")             # ajuste fino del theme
```

Cada `+` es una capa nueva. Quitar una capa no rompe la gráfica, solo le quita esa pieza específica.

---

## 3. Aesthetics: `mapping` vs. `setting` (el bug #1 de ggplot)

Esta distinción es **la fuente más común de bugs** en ggplot2. Vale la pena dedicarle tiempo explícito en clase.

### 3.1 La regla

| Caso | Qué hacer | Significado |
|---|---|---|
| Quieres que la propiedad **dependa de una variable** | Adentro de `aes()`: `aes(color = grupo)` | *Mapping*: ggplot escoge colores y los asigna por valor de `grupo` |
| Quieres una propiedad **fija para todo** | Afuera de `aes()`: `color = "red"` | *Setting*: todos los puntos en rojo |

### 3.2 El bug clásico

```r
# Lo que el estudiante quiere: todos los puntos rojos
ggplot(df, aes(x = a, y = b, color = "red")) +    # MAL
  geom_point()
# Resultado: todos los puntos del mismo color, pero ese color NO es rojo,
# y aparece una leyenda inútil que dice "red".

# Lo correcto
ggplot(df, aes(x = a, y = b)) +
  geom_point(color = "red")                       # BIEN
```

**Por qué pasa:** dentro de `aes()`, ggplot asume que `"red"` es una variable; no la encuentra como tal pero la trata como una columna constante de un solo valor. Le asigna entonces un color de su paleta default (no rojo).

### 3.3 Aesthetics globales vs. por geom

```r
# aes() global: aplica a todos los geoms
ggplot(df, aes(x = a, y = b, color = grupo)) +
  geom_point() +
  geom_smooth()
# Ambos geoms usan x, y, y color por grupo

# aes() por geom: solo aplica a ese geom
ggplot(df, aes(x = a, y = b)) +
  geom_point(aes(color = grupo)) +
  geom_smooth()
# Los puntos coloreados por grupo, el smooth en un solo color
```

Es común quererlo de una forma y poner la `aes()` en el lugar incorrecto.

---

## 4. Geometrías: el catálogo útil

| `geom_*` | Para qué | Notas |
|---|---|---|
| `geom_point` | *Scatter* | Argumentos clave: `size`, `alpha`, `shape` |
| `geom_line` | Líneas (series temporales, líneas de tendencia) | Requiere orden en `x` |
| `geom_bar` | Barras donde la altura es **conteo** | Calcula conteo automáticamente |
| `geom_col` | Barras donde la altura es un **valor** de la columna | Más común para datos pre-agregados |
| `geom_histogram` | Histograma de una variable continua | `bins` o `binwidth` |
| `geom_boxplot` | Caja-bigote por grupo | Útil con `x = factor`, `y = numérico` |
| `geom_violin` | Densidad por grupo (alternativa visual al boxplot) | Combina bien con `geom_jitter` para mostrar puntos individuales |
| `geom_density` | Densidad univariada | Suaviza |
| `geom_smooth` | Línea de tendencia con intervalo de confianza | `method = "lm"`, `"loess"`, `"gam"` |
| `geom_text` / `geom_label` | Etiquetas en la gráfica | `geom_label` con caja |
| `geom_ribbon` | Banda entre `ymin` e `ymax` | Útil para intervalos de confianza explícitos |
| `geom_area` | Área bajo una línea | Acumulada con `position = "stack"` |
| `geom_jitter` | Puntos con desplazamiento aleatorio para evitar solape | Equivalente a `geom_point(position = "jitter")` |
| `geom_tile` | *Heatmap* | Requiere `x`, `y` y `fill` |

### 4.1 `geom_bar` vs. `geom_col` (la distinción importa)

```r
# geom_bar: calcula el conteo automáticamente
ggplot(df, aes(x = categoria)) + geom_bar()
# Equivale a: count + bar

# geom_col: usa el valor literal de y
df_agregado |> ggplot(aes(x = categoria, y = total)) + geom_col()
```

Es la pregunta clásica: "¿por qué mi `geom_bar(aes(y = valor))` se ve raro?". Respuesta: porque `geom_bar` espera no recibir `y` (lo calcula); para datos pre-agregados, usa `geom_col`.

---

## 5. Scales: el control fino

Las *scales* controlan **cómo** los aesthetics se traducen a valores visuales. Es donde la gráfica pasa de "técnicamente correcta" a "publicación-ready".

### 5.1 Anatomía de una scale

Cada aesthetic tiene scales correspondientes. La nomenclatura es regular: `scale_{aesthetic}_{tipo}()`.

```r
scale_x_continuous()    # para x continuo
scale_x_discrete()      # para x categórico
scale_x_log10()         # transformación log
scale_x_date()          # para fechas
scale_y_continuous()    # análogos para y
scale_color_brewer()    # paletas ColorBrewer
scale_color_manual()    # control total con vector nombrado
scale_fill_viridis_d()  # paleta viridis discreta
scale_size_continuous() # tamaño continuo
```

Argumentos comunes en cualquier scale:
- `name` — nombre que aparece en la leyenda/eje
- `breaks` — dónde van las marcas
- `labels` — qué texto poner en cada marca
- `limits` — rango forzado
- `expand` — espacio entre los datos y el borde del panel

### 5.2 `coord_cartesian(ylim)` vs. `scale_y_continuous(limits)`

Diferencia sutil pero importante:

```r
# coord_cartesian: zoom visual (los datos fuera del rango siguen ahí, solo no se ven)
ggplot(df, aes(x, y)) + geom_smooth() +
  coord_cartesian(ylim = c(0, 100))

# scale_y_continuous con limits: descarta datos fuera del rango ANTES de graficar
ggplot(df, aes(x, y)) + geom_smooth() +
  scale_y_continuous(limits = c(0, 100))
```

El segundo puede cambiar la línea de tendencia porque está calculando `geom_smooth` sin los puntos descartados. **Regla mental:** si quieres zoom visual, `coord_cartesian`. Si quieres realmente excluir datos, filtra antes con `dplyr::filter()`.

### 5.3 El paquete `scales` — formatters

Sin esto las gráficas se ven amateur. Con esto se ven profesionales.

```r
library(scales)

# Antes:
# eje y: 0, 5e+04, 1e+05, 1.5e+05
# eje x: 0.05, 0.1, 0.15

# Con formatters:
... + scale_y_continuous(labels = label_comma())
# y: 0  50,000  100,000  150,000

... + scale_x_continuous(labels = label_percent())
# x: 5%  10%  15%

... + scale_y_continuous(labels = label_dollar(prefix = "$", big.mark = ","))
# y: $50,000  $100,000

... + scale_x_continuous(labels = label_number(scale_cut = cut_short_scale()))
# x: 50K  100K  150K  (notación abreviada)

... + scale_x_date(labels = label_date_short())
# x: ene 2024, feb 2024, etc.
```

**Recomendación para clase:** mostrar la misma gráfica antes/después de aplicar formatters. El cambio visual es dramático y vende la importancia de scales.

### 5.4 Paletas de color

```r
# ColorBrewer (paletas con teoría detrás)
scale_color_brewer(palette = "Set2")       # discreta cualitativa
scale_fill_brewer(palette = "Blues")       # secuencial
scale_color_brewer(palette = "RdBu")       # divergente

# Viridis (perceptualmente uniforme, color-blind safe)
scale_color_viridis_d()    # discreto
scale_color_viridis_c()    # continuo
scale_color_viridis_b()    # binned

# Manual
scale_color_manual(values = c("hombre" = "#1f77b4",
                              "mujer"  = "#ff7f0e"))
```

**Regla**: para datos categóricos sin orden, paletas cualitativas (Set1, Set2). Para datos ordenados o continuos, secuenciales (Blues, Greens). Para datos con cero significativo (positivo/negativo), divergentes (RdBu, BrBG).

---

## 6. Facets y coordenadas

### 6.1 `facet_wrap` vs. `facet_grid`

```r
# facet_wrap: una variable, los paneles se acomodan en grid
ggplot(df, aes(x, y)) + geom_point() +
  facet_wrap(~ grupo, ncol = 3)

# facet_grid: dos variables, una para filas y una para columnas
ggplot(df, aes(x, y)) + geom_point() +
  facet_grid(rows = vars(sexo), cols = vars(edad_grupo))
```

### 6.2 `scales = "free"` — cuándo sí, cuándo no

```r
# Default: todos los paneles comparten ejes (comparabilidad visual)
facet_wrap(~ grupo)

# Free: cada panel su propia escala (mejor para distribuciones muy distintas)
facet_wrap(~ grupo, scales = "free_y")
```

**Trade-off:** scales libres son más legibles dentro de cada panel pero rompen la comparabilidad entre paneles. La regla práctica: si los rangos son comparables, deja default. Si son órdenes de magnitud distintos, libera el eje correspondiente.

### 6.3 Coordenadas

```r
coord_cartesian()              # default
coord_cartesian(ylim = c(0,100)) # zoom (no descarta datos)
coord_flip()                   # gira x ↔ y (útil para barras horizontales con labels largos)
coord_polar()                  # coordenadas polares (pie charts, radiales)
coord_fixed(ratio = 1)         # mantiene ratio de aspecto
```

`coord_flip()` es el truco más común: cuando tienes muchas categorías con nombres largos, una barra horizontal es más legible que una vertical con texto rotado.

---

## 7. Themes

`theme()` controla todo lo que no es dato: tipografía, colores de fondo, líneas de grid, posición de leyenda, márgenes.

### 7.1 Themes predefinidos

| Theme | Estilo |
|---|---|
| `theme_gray()` | Default de ggplot2 (fondo gris) |
| `theme_minimal()` | Limpio, sin marco, líneas de grid suaves. **Default recomendado del curso.** |
| `theme_bw()` | Fondo blanco con marco negro |
| `theme_classic()` | Estilo "papel científico", solo ejes |
| `theme_void()` | Sin nada visible (útil cuando solo importan los datos) |
| `theme_dark()` | Fondo oscuro |

### 7.2 Customización fina

```r
theme(
  plot.title = element_text(size = 16, face = "bold"),
  plot.subtitle = element_text(color = "grey50"),
  axis.text = element_text(size = 11),
  axis.title.x = element_text(margin = margin(t = 10)),
  panel.grid.minor = element_blank(),           # quita grid menor
  legend.position = "bottom",
  legend.title = element_blank(),
  strip.background = element_rect(fill = "grey90"), # fondo de facet labels
  strip.text = element_text(face = "bold")
)
```

Argumentos típicos:
- `element_text()` para texto (tipografía)
- `element_line()` para líneas (grid, ejes)
- `element_rect()` para rectángulos (fondos, marcos)
- `element_blank()` para "quitar este elemento"

### 7.3 `theme_set()` — tema global

```r
# Al inicio del script o del proyecto
theme_set(theme_minimal(base_size = 12))

# Todas las gráficas siguientes heredan este theme
```

Patrón recomendado: definir un theme custom del proyecto al inicio del script principal y usarlo en todas las gráficas. Garantiza consistencia visual.

---

## 8. Ecosistema complementario

| Paquete | Para qué | Comando emblemático |
|---|---|---|
| **`scales`** | Formatters de ejes (ya cubierto) | `label_comma()`, `label_percent()`, `label_dollar()` |
| **`patchwork`** | Componer múltiples gráficas | `p1 + p2`, `p1 / p2`, `(p1 \| p2) / p3` |
| **`ggrepel`** | Labels que no se sobreponen | `geom_text_repel()`, `geom_label_repel()` |
| **`ggtext`** | Markdown/HTML en labels | Usa `element_markdown()` en theme |
| **`gghighlight`** | Destacar grupos específicos en gráficas multi-grupo | `gghighlight(grupo == "X")` |
| **`ggthemes`** | Themes adicionales | `theme_economist()`, `theme_fivethirtyeight()`, `theme_wsj()` |
| **`paletteer`** | Acceso unificado a cientos de paletas | `scale_color_paletteer_d("ggsci::default_jco")` |

### 8.1 `patchwork` — el más útil del lote

```r
library(patchwork)

p1 <- ggplot(df, aes(x, y)) + geom_point()
p2 <- ggplot(df, aes(z)) + geom_histogram()
p3 <- ggplot(df, aes(grupo, valor)) + geom_col()

# Horizontal
p1 + p2

# Vertical
p1 / p2

# Layouts complejos
(p1 | p2) / p3

# Con título común
(p1 + p2) + plot_annotation(title = "Análisis exploratorio")
```

Para reportes y tableros, `patchwork` es indispensable. Reemplaza a `grid.arrange` y similares con sintaxis mucho más legible.

### 8.2 `ggrepel` — labels sin solape

```r
library(ggrepel)

ggplot(df, aes(x, y, label = nombre)) +
  geom_point() +
  geom_text_repel()
```

Cuando tienes muchos puntos con etiquetas (estados, países, individuos), `geom_text` los amontona; `geom_text_repel` los empuja automáticamente para que no se solapen.

### 8.3 Mención somera

- **`plotly`**: convierte ggplot a gráfica interactiva con `ggplotly(p)`. Útil para exploración o tableros, pero rara vez para entregables académicos finales. En el contexto del curso, Shiny (S15) cubre la interactividad de forma más controlada.
- **`gganimate`**: animaciones. Bonito pero rara vez práctico en publicaciones académicas.

---

## 9. Exportación con `ggsave()`

### 9.1 La función básica

```r
ggsave(filename = "output/grafica.png",
       plot = p,                    # default: última gráfica
       width = 8, height = 5,
       units = "in",                # in, cm, mm, px
       dpi = 300,                   # resolución
       bg = "white")                # fondo
```

### 9.2 Formatos: cuándo cada uno

| Formato | Tipo | Cuándo usar | Cuándo NO |
|---|---|---|---|
| **PNG** | *Raster* | Web, Word, presentaciones, capturas de pantalla | Cuando se requiere escalabilidad o re-edición |
| **JPG** | *Raster* (lossy) | Cuando el tamaño de archivo es crítico y la calidad puede sacrificarse | Casi siempre. Inferior a PNG y al SVG para casi todo |
| **SVG** | Vector | Cuando la gráfica va a ser escalada (zoom, impresión grande) o editada (Illustrator, Inkscape) | Documentos que no soporten SVG (Word viejo) |

El default del curso para exportar al proyecto integrador: **PNG con `dpi = 300`** para inserción en el reporte de `officer` (S14). SVG si necesitas escalar.

### 9.3 Dimensiones y `dpi`

- **`dpi`** (dots per inch): densidad de píxeles. 72 dpi es resolución de pantalla (web); 300 dpi es estándar de impresión.
- **Para Word/presentaciones**: 8×5 in a 300 dpi suele ser suficiente.
- **Para impresión grande (póster, banner)**: ir a SVG o subir el dpi.

### 9.4 El anti-patrón clásico: "el texto se ve microscópico"

```r
# Mal: gráfica creada en RStudio (panel chico ~600px), exportada en width=12
ggsave("grafica.png", p, width = 12, height = 8, dpi = 300)
# Resultado: las gráficas tienen los labels que se veían perfectos en pantalla
# pero ahora se ven minúsculos porque la imagen es de 3600×2400 px.

# Bien: planear el tamaño FINAL desde el inicio
theme_set(theme_minimal(base_size = 14))   # base_size proporcional al export
ggsave("grafica.png", p, width = 8, height = 5, dpi = 300, bg = "white")
```

**Regla práctica:** decide el tamaño físico de tu export (ej. 8×5 in para Word), y ajusta el `base_size` del theme proporcionalmente. Más grande la imagen → más grande el `base_size`.

### 9.5 `bg = "white"` — el detalle que se olvida

Por default, el fondo de un PNG exportado de ggplot es **transparente**. Al insertar en Word con tema oscuro o en una presentación, las áreas "blancas" aparecen transparentes y rompen la lectura. La solución es trivial: `bg = "white"`. Es el argumento que más vale la pena memorizar.

---

## 10. Anti-patrones comunes (los 5 que vas a ver en tareas)

1. **Mezclar `aes()` global con `aes()` por geom sin saber cuál aplica.** Resultado: leyendas duplicadas, colores que no se ven como uno espera.

2. **`color = "red"` dentro de `aes()`.** Resultado: una leyenda llamada "red" y todos los puntos del mismo color, pero no rojo.

3. **`geom_bar(aes(y = valor))`** con datos pre-agregados. Resultado: `Error: stat_count() requires no y aesthetic`. Solución: usar `geom_col`.

4. **`coord_cartesian(ylim)` vs. `scale_y_continuous(limits)`** confundidos. Resultado: `geom_smooth` se ve raro porque se calculó sin los puntos "descartados".

5. **Exportar sin planear dimensiones.** Resultado: texto microscópico, gráfica que no se inserta bien al documento final.

---

## 11. Tabla decisión rápida

| Quieres... | Usa |
|---|---|
| Una propiedad visual que depende de una variable | `aes(propiedad = variable)` |
| Una propiedad visual fija | `propiedad = valor`, fuera de `aes()` |
| Convertir números a formato amigable en ejes | `scale_*_continuous(labels = label_*())` de `scales` |
| Color por grupo categórico | `scale_color_brewer(palette = "Set2")` o similar |
| Color por gradiente continuo | `scale_color_viridis_c()` |
| Particionar por una variable | `facet_wrap(~ var)` |
| Particionar por dos variables | `facet_grid(rows = vars(a), cols = vars(b))` |
| Cada panel su propia escala | `facet_*(scales = "free")` |
| Barras horizontales (labels largos) | `coord_flip()` o `geom_col(aes(x = valor, y = categoria))` |
| Zoom sin perder datos | `coord_cartesian(ylim = c(...))` |
| Filtrar datos antes de graficar | `dplyr::filter()`, NO `scale_*(limits)` |
| Combinar varias gráficas | `library(patchwork)`, `p1 + p2`, `p1 / p2` |
| Labels que no se solapen | `library(ggrepel)`, `geom_text_repel()` |
| Highlight un grupo en una gráfica multi-grupo | `library(gghighlight)`, `gghighlight(condición)` |
| Exportar para Word/web | `ggsave(..., png, dpi = 300, bg = "white")` |
| Exportar escalable (póster, edición) | `ggsave(..., svg, ...)` |

---

## 12. Lecturas y orden recomendado

**Para preparar la clase:**

1. **R4DS Cap. 9 *Layers*** — la introducción canónica a la arquitectura por capas. Léelo primero.
2. **R4DS Cap. 11 *Communication*** — labels, scales, themes, layout. Léelo segundo. *Nota: este capítulo no cubre `ggsave`/export.*
3. **Documentación de `ggsave`** — `?ggsave` en R, o la página del paquete: `https://ggplot2.tidyverse.org/reference/ggsave.html`
4. **Cheatsheet de ggplot2** — `https://rstudio.github.io/cheatsheets/data-visualization.pdf` — tener impresa.

**Lecturas complementarias:**

- *ggplot2: Elegant Graphics for Data Analysis* (Wickham), libro completo — `https://ggplot2-book.org/`. Es la referencia comprehensiva; consultar capítulos según necesidad. Especialmente útil:
  - Caps. sobre *aesthetics* y *geoms* — para profundizar.
  - Cap. sobre *scales* — para entender el modelo completo.
  - Cap. sobre *themes* — para customización avanzada.
- Documentación de `patchwork`: `https://patchwork.data-imaginist.com/`
- Documentación de `scales`: `https://scales.r-lib.org/`

---

## 13. Nota final: cómo enseñar este tema

Esta semana es estética en superficie, pero conceptual en profundidad. La trampa pedagógica más común es enseñar `ggplot2` como un catálogo de funciones ("para barras usas `geom_bar`, para líneas usas `geom_line`"). Esa enseñanza produce estudiantes que copian recetas y se atoran ante cualquier gráfica no estándar.

El enfoque que vale la pena es **enseñar la gramática primero**. Si el estudiante puede responder "¿qué capa controla X?", podrá producir cualquier gráfica. Si solo sabe "para barras se usa esto", su techo está fijado por el catálogo que memorizó.

Tres mensajes que vale la pena llevarse a clase:

1. **Una gráfica es la composición de capas independientes.** No es un objeto monolítico. Cada capa tiene una responsabilidad acotada.
2. **`mapping` vs. `setting` es la distinción que evita más bugs.** Internalizarla temprano ahorra horas de frustración.
3. **`scales` (el paquete) es la diferencia entre una gráfica amateur y una profesional.** Formatters en ejes son baratos y dan retornos enormes.

El estudiante que se lleva esto a casa no va a necesitar recetas — va a poder leer cualquier código `ggplot2` y, más importante, escribir cualquier gráfica que se le ocurra.
