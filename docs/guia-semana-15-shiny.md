# Guía de estudio — Semana 15: Aplicaciones interactivas con Shiny

> **Audiencia:** instructor (Daniel). Esta guía complementa el bloque del syllabus para Semana 15. Está pensada para que llegues a la clase con seguridad sobre el material — no para los estudiantes.

---

## 0. Nota pedagógica (lo primero que tienes que leer)

Tú dominas Shiny en el modo de "construir una app web seria que reemplaza productos en otras tecnologías". **Ese no es el modo en el que estás enseñando esta semana.** El sesgo natural será querer enseñar *modules*, *async*, *custom JS*, *server-side validation*, *connection pools*, *reactive optimization*... Resístelo.

**El estudiante que termina la semana sabiendo:**

- Qué es HTML/CSS y por qué importa
- Cómo Shiny convierte R a HTML
- Cómo armar `ui` y `server` con reactividad básica
- Cómo usar `bslib` para hacer un tablero con `value_box`, `card`, filtros y gráficas

...**ha cumplido el objetivo del curso.** Todo lo demás es construir sobre esa base. Los estudiantes que quieran ir más allá pueden hacerlo con la base sólida que les diste.

La trampa pedagógica es enseñar "todo lo que se puede hacer en Shiny". Eso produce estudiantes confundidos. La alternativa es enseñar **un patrón fijo** (filtros + value_box + 2-3 gráficas reactivas) y enseñarlo bien.

Tres reglas para la semana:

1. **Mostrar el patrón, no la teoría completa.** Una sola estructura de tablero, ejecutada bien.
2. **No mencionar modules, hooks, custom JS, async.** Suman 80% de complejidad para 5% de los proyectos del curso.
3. **`bslib` siempre, no `shinydashboard`.** `shinydashboard` está en mantenimiento; `bslib` es el camino moderno.

---

## 1. La pieza fundacional: HTML y CSS (mínimo viable)

Los estudiantes no necesitan ser expertos en web, pero sí necesitan entender que **una app Shiny es una página web**. Esa intuición elimina mucha confusión.

### 1.1 HTML: el árbol de la página

HTML es texto con *tags* anidados:

```html
<html>
  <body>
    <h1>Título principal</h1>
    <p>Un párrafo con <span class="destacado">texto destacado</span>.</p>
    <div class="card">
      <h2>Sección</h2>
      <p>Contenido.</p>
    </div>
  </body>
</html>
```

Conceptos clave que vale la pena nombrar en clase:

- **Tags**: `<h1>`, `<p>`, `<div>`, `<span>`, `<a>`, `<img>`, `<ul>/<li>`, etc. Cada uno tiene semántica.
- **Atributos**: `id="..."` (único en la página), `class="..."` (compartible).
- **Anidamiento**: los tags se contienen unos a otros. Hay un padre y hay hijos.

### 1.2 CSS: el estilo

CSS son reglas que dicen "los elementos que matchean este selector se ven así":

```css
/* Selector por tag */
h1 {
  color: #5E002B;
  font-size: 24px;
}

/* Selector por class */
.destacado {
  font-weight: bold;
  color: #D24D31;
}

/* Selector por id */
#tablero-principal {
  background-color: #f5f5f5;
  padding: 20px;
}
```

Conceptos clave:

- **Selectores**: por tag, por class (`.nombre`), por id (`#nombre`).
- **Propiedades**: `color`, `background-color`, `font-size`, `font-family`, `margin`, `padding`, `border`, `width`, `height`.
- **Cascada**: las reglas más específicas ganan; el orden importa.

### 1.3 ¿Cuánto HTML/CSS necesita el estudiante?

Lo justo para:

- Reconocer un `<div class="card">` cuando aparezca en el código generado por Shiny.
- Saber que pueden meter una hoja `www/styles.css` en su proyecto Shiny si quieren ajustes finos.
- Entender que cuando Shiny renderiza `value_box("Total", 123)`, eso se convierte en algo como `<div class="value-box"><h3>Total</h3><p>123</p></div>`.

**No** necesitan saber escribir CSS desde cero. Si quieren un tablero más bonito, hay themes de `bslib` listos para usar.

---

## 2. Cómo Shiny convierte R a HTML/CSS/JS

Este es el momento "ajá" de la semana. Si los estudiantes entienden esto, entienden Shiny.

### 2.1 Las funciones que generan HTML

```r
library(shiny)

# Esto es R
tags$div(class = "card",
  tags$h2("Mi sección"),
  tags$p("Algo de texto.")
)

# Esto es HTML (lo que se genera)
# <div class="card">
#   <h2>Mi sección</h2>
#   <p>Algo de texto.</p>
# </div>
```

Cada función `tags$XXX()` corresponde a un tag HTML. Hay atajos para los más comunes:

```r
h1("Título")            # = tags$h1("Título")
p("Párrafo")             # = tags$p("Párrafo")
div(class = "card", ...) # = tags$div(class = "card", ...)
a(href = "...", "link")  # = tags$a(href = "...", "link")
```

**Demostración para clase:** Correr una mini-app con un solo `tags$div()` y mostrar el HTML resultante con "Inspect" del navegador. El estudiante ve por sí mismo la correspondencia 1-a-1.

### 2.2 Inputs y outputs son HTML especial

```r
# En el UI
selectInput("anio", "Año:", choices = c(2023, 2024, 2025))

# Genera algo así
# <div class="form-group shiny-input-container">
#   <label for="anio">Año:</label>
#   <select id="anio" class="shiny-bound-input"> ... </select>
# </div>
```

El `id="anio"` es la clave: el JavaScript que Shiny inyecta escucha cambios en ese `select`, los manda al servidor R, y R los expone como `input$anio`. **Eso es todo el "magic" de Shiny.**

### 2.3 Bootstrap por debajo

Shiny carga **Bootstrap** (un framework CSS popular) por defecto. Eso explica:

- Por qué los inputs se ven con cierto estilo "default web" sin que tú hayas hecho nada.
- Por qué `fluidRow()` y `column()` funcionan: usan el grid de Bootstrap (12 columnas).
- Por qué hay clases como `.btn`, `.form-group`, `.container` disponibles "gratis".

`bslib` controla qué versión de Bootstrap usa Shiny (default actualmente es Bootstrap 5) y permite themes custom.

### 2.4 htmlwidgets: el puente con JavaScript

`highcharter`, `plotly`, `leaflet`, `DT` (tablas interactivas) y otros son **htmlwidgets**: envoltorios R alrededor de librerías JavaScript que se renderizan en el navegador.

```r
library(highcharter)

hchart(mtcars, "scatter", hcaes(x = wt, y = mpg))
# Esto NO produce una imagen estática. Produce un objeto que, cuando se renderiza
# en una página web (o en Shiny), inyecta el JS de Highcharts y la gráfica
# resultante es completamente interactiva.
```

El estudiante no escribe JS. La librería JS está pre-empaquetada; el wrapper R la configura.

---

## 3. Anatomía mínima de una app Shiny

### 3.1 La estructura básica

```r
library(shiny)

ui <- fluidPage(
  titlePanel("Mi primera app"),

  sidebarLayout(
    sidebarPanel(
      selectInput("variable", "Variable:",
                  choices = names(mtcars))
    ),
    mainPanel(
      plotOutput("histograma")
    )
  )
)

server <- function(input, output, session) {
  output$histograma <- renderPlot({
    hist(mtcars[[input$variable]],
         main = paste("Histograma de", input$variable))
  })
}

shinyApp(ui, server)
```

Cuatro elementos:

1. **`ui`** — lo que se ve. Una composición de funciones que generan HTML.
2. **`server`** — la lógica. Una función con tres argumentos (`input`, `output`, `session`).
3. **Inputs en UI, accesibles vía `input$id` en server.**
4. **Outputs declarados en UI (`*Output()`), poblados en server con `render*()`.**

### 3.2 La correspondencia input/output

| En UI | En server |
|---|---|
| `selectInput("var", ...)` | `input$var` |
| `numericInput("n", ...)` | `input$n` |
| `sliderInput("rango", ...)` | `input$rango` |
| `plotOutput("grafica")` | `output$grafica <- renderPlot({...})` |
| `tableOutput("tabla")` | `output$tabla <- renderTable({...})` |
| `textOutput("texto")` | `output$texto <- renderText({...})` |
| `highchartOutput("hc")` | `output$hc <- renderHighchart({...})` |
| `plotlyOutput("pl")` | `output$pl <- renderPlotly({...})` |
| `valueBoxOutput("kpi")` | `output$kpi <- renderValueBox({...})` |

El patrón es siempre el mismo: `*Output("id")` en UI, `output$id <- render*({...})` en server.

### 3.3 Inputs comunes para tableros del curso

```r
selectInput("anio", "Año:",
            choices = 2018:2026,
            selected = 2026)

selectInput("estado", "Estado:",
            choices = c("Todos" = "todos", setNames(estados$cve, estados$nombre)),
            selected = "todos")

sliderInput("rango_edad", "Rango de edad:",
            min = 0, max = 100,
            value = c(18, 65))

dateRangeInput("fechas", "Periodo:",
               start = "2023-01-01",
               end = Sys.Date())

checkboxGroupInput("modulos", "Módulos:",
                   choices = c("CS", "CB", "VIV"),
                   selected = c("CS", "CB", "VIV"))
```

Estos cinco cubren ~90% de los filtros que aparecerán en proyectos del curso.

---

## 4. Reactividad: el modelo mental

Aquí es donde Shiny se vuelve confuso si no se enseña bien.

### 4.1 La idea central

**Una expresión reactiva se recalcula automáticamente cuando alguno de sus inputs cambia.** No hay que llamarla, no hay que invocarla. Shiny la observa y la corre cuando hace falta.

```r
server <- function(input, output, session) {
  # Una "reactive" es como una variable que se recalcula sola
  datos_filtrados <- reactive({
    datos |> filter(anio == input$anio)
  })

  # En cualquier output que la use, se llama como función: datos_filtrados()
  output$grafica <- renderPlot({
    ggplot(datos_filtrados(), aes(x, y)) + geom_point()
  })

  output$tabla <- renderTable({
    head(datos_filtrados(), 10)
  })
}
```

Cuando `input$anio` cambia, `datos_filtrados()` se recalcula, y **automáticamente** todos los outputs que la usan se redibujan. Esto es la magia de Shiny.

### 4.2 Tres herramientas, tres roles

| Herramienta | Para qué | Devuelve |
|---|---|---|
| `reactive({...})` | Calcular un valor que depende de inputs | Una función; se invoca con `()` |
| `observe({...})` | Side effect: hacer algo cuando cambia un input | Nada (no se "usa" su resultado) |
| `reactiveVal(init)` | Estado mutable explícito | Una función que sirve tanto para leer (`x()`) como para escribir (`x(nuevo_valor)`) |

```r
# reactive: para valores derivados
datos_filtrados <- reactive({ ... })

# observe: para side effects (logs, escribir archivos, mostrar mensaje)
observe({
  if (input$descargar) {
    write_csv(datos_filtrados(), "output/descarga.csv")
  }
})

# reactiveVal: para estado que muta por click u otro evento
contador <- reactiveVal(0)

observeEvent(input$boton_sumar, {
  contador(contador() + 1)
})
```

### 4.3 Reglas de oro

1. **Si un output usa `input$X`, debe pasar por `reactive()` solo si ese cálculo se reusa en varios outputs.** Si solo lo usa un output, mete el código directo en el `render*({})`.
2. **`observe()` NUNCA debe calcular un valor que otro código va a usar. Para eso es `reactive()`.**
3. **`reactiveVal` es para botones y eventos. Para filtros que se reflejan automáticamente, `reactive()` basta.**

### 4.4 El gotcha de la reactividad: usar `()` para invocar

```r
# MAL
output$grafica <- renderPlot({
  ggplot(datos_filtrados, aes(x, y)) + geom_point()
  # error: datos_filtrados es una función, no un data frame
})

# BIEN
output$grafica <- renderPlot({
  ggplot(datos_filtrados(), aes(x, y)) + geom_point()
  # los paréntesis invocan la función reactiva y devuelven el data frame
})
```

Es el error #1 de estudiantes en Shiny. Vale la pena anticiparlo en clase.

---

## 5. Layouts con `bslib`: la estructura del tablero

`bslib` es el sistema moderno para layouts en Shiny. Reemplaza a `shinydashboard` (que sigue funcionando pero está en mantenimiento, no desarrollo activo).

### 5.1 `page_sidebar`: la estructura clásica

```r
library(shiny)
library(bslib)

ui <- page_sidebar(
  title = "Tablero ENSU",

  sidebar = sidebar(
    selectInput("anio", "Año:", choices = 2018:2026),
    selectInput("estado", "Estado:", choices = estados),
    sliderInput("trimestre", "Trimestre:", min = 1, max = 4, value = 1)
  ),

  # Contenido principal (puede ser cualquier cosa)
  layout_columns(
    value_box(title = "Total", value = textOutput("total")),
    value_box(title = "Promedio", value = textOutput("promedio"))
  ),

  card(
    card_header("Distribución temporal"),
    highchartOutput("grafica_temporal")
  )
)
```

`page_sidebar` da una estructura inmediatamente reconocible como "tablero": panel lateral con filtros + área principal con contenido.

### 5.2 `page_navbar`: para tableros multi-sección

```r
ui <- page_navbar(
  title = "Análisis ENSU",

  nav_panel("Resumen",
    layout_columns(
      value_box(...),
      value_box(...),
      value_box(...)
    )
  ),

  nav_panel("Series temporales",
    card(highchartOutput("series"))
  ),

  nav_panel("Datos",
    DT::DTOutput("tabla")
  )
)
```

Útil cuando el tablero tiene secciones temáticamente distintas.

### 5.3 `value_box`: KPIs prominentes

```r
value_box(
  title = "Total de hogares",
  value = textOutput("total_hogares"),
  showcase = bsicons::bs_icon("house"),
  theme = "primary"
)
```

En el `server`:

```r
output$total_hogares <- renderText({
  format(nrow(datos_filtrados()), big.mark = ",")
})
```

`value_box` es la pieza que más vende un tablero. **Tres a cinco** value_boxes en la parte superior es un patrón clásico y efectivo.

### 5.4 `card`: contenedores para gráficas/tablas

```r
card(
  card_header("Distribución por estado"),
  highchartOutput("mapa_estados"),
  card_footer("Fuente: INEGI")
)
```

Encapsular cada gráfica en un `card` da estructura visual al tablero y permite agregar título y nota al pie sin código adicional.

### 5.5 Grids con `layout_columns` y `layout_column_wrap`

```r
# Columnas explícitas: 3 elementos lado a lado
layout_columns(
  col_widths = c(4, 4, 4),
  value_box(...),
  value_box(...),
  value_box(...)
)

# Auto-grid: tantas columnas como quepan
layout_column_wrap(
  width = 1/3,  # cada columna ocupa 1/3 del ancho mínimo
  value_box(...),
  value_box(...),
  value_box(...)
)
```

`layout_column_wrap` es responsive: en pantallas chicas las columnas se apilan automáticamente.

---

## 6. Gráficas interactivas: `highcharter` vs `plotly`

Ambas son válidas. La elección depende de preferencia estética y del tipo de gráfica.

### 6.1 `highcharter`

```r
library(highcharter)

# En UI
highchartOutput("mi_grafica")

# En server
output$mi_grafica <- renderHighchart({
  datos <- datos_filtrados()
  hchart(datos, "column",
         hcaes(x = categoria, y = valor)) |>
    hc_title(text = "Mi título") |>
    hc_yAxis(title = list(text = "Valor"),
             labels = list(format = "{value}%"))
})
```

**Fortalezas de highcharter:**
- Estética profesional out-of-the-box (lo que se ve en periódicos como Financial Times).
- Animaciones suaves.
- Buena documentación.

**Limitación legal:**
- Highcharts es gratis solo para uso **no comercial** y proyectos educativos. Para uso comercial requiere licencia. Para el curso (educativo) no hay problema.

### 6.2 `plotly`

```r
library(plotly)

# En UI
plotlyOutput("mi_grafica")

# En server
output$mi_grafica <- renderPlotly({
  p <- ggplot(datos_filtrados(), aes(categoria, valor)) +
    geom_col()
  ggplotly(p)
})
```

**Fortalezas de plotly:**
- Conversión directa de ggplot con `ggplotly()` (reusas todo lo de S13).
- Totalmente gratuito (licencia MIT).
- Tooltips y zoom interactivo "gratis".

**Limitación:**
- Estética más "tecnológica" que "editorial".
- Menos opciones de customización fina que highcharter.

### 6.3 Recomendación para el curso

Si los estudiantes ya construyeron sus gráficas en `ggplot2` (S13), **`plotly` vía `ggplotly()` es el camino de menor fricción**: cero código nuevo, las gráficas se vuelven interactivas. Si quieren algo más "editorial", `highcharter` da mejor resultado pero requiere aprender una sintaxis nueva.

**Default sugerido del curso:** plotly. Aprendieron ggplot, lo aprovechan. Quien quiera highcharter, tiene el camino abierto.

---

## 7. El patrón fijo del tablero del curso

Esta es la estructura que vas a enseñar y que los estudiantes deben replicar para Checkpoint 5. **Fija, simple, completa.**

```
+--------------------------------------------------+
| Título del tablero                               |
+----------+---------------------------------------+
| FILTROS  | KPI 1 | KPI 2 | KPI 3 | KPI 4         |
|          +---------------------------------------+
| anio     |  Card: Gráfica principal               |
| estado   |  (serie temporal o distribución)       |
| otro     |                                        |
|          +---------------------------------------+
|          |  Card: Gráfica secundaria              |
|          |  (comparación entre grupos)            |
|          +---------------------------------------+
|          |  Card: Tabla resumen (opcional)        |
+----------+---------------------------------------+
```

### 7.1 Esqueleto completo

```r
library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(ggplot2)
library(DBI)
library(RSQLite)

# Carga de datos (una vez al inicio de la app)
con <- dbConnect(SQLite(), "output/proyecto.sqlite")
datos <- dbReadTable(con, "encuesta")
dbDisconnect(con)

ui <- page_sidebar(
  title = "Mi tablero",
  theme = bs_theme(version = 5, primary = "#5E002B"),

  sidebar = sidebar(
    width = 250,
    selectInput("anio", "Año:",
                choices = sort(unique(datos$anio)),
                selected = max(datos$anio)),
    selectInput("estado", "Estado:",
                choices = c("Todos" = "todos", sort(unique(datos$estado))))
  ),

  # KPIs arriba
  layout_columns(
    fill = FALSE,
    value_box(title = "Total", value = textOutput("kpi_total"),
              showcase = bsicons::bs_icon("people")),
    value_box(title = "Promedio", value = textOutput("kpi_promedio"),
              showcase = bsicons::bs_icon("graph-up")),
    value_box(title = "Máximo", value = textOutput("kpi_max"),
              showcase = bsicons::bs_icon("trophy"))
  ),

  # Gráficas
  layout_columns(
    card(
      card_header("Serie temporal"),
      plotlyOutput("grafica_temporal")
    ),
    card(
      card_header("Distribución por categoría"),
      plotlyOutput("grafica_distribucion")
    )
  )
)

server <- function(input, output, session) {
  # Reactive: datos filtrados
  datos_filtrados <- reactive({
    df <- datos |> filter(anio == input$anio)
    if (input$estado != "todos") {
      df <- df |> filter(estado == input$estado)
    }
    df
  })

  # KPIs
  output$kpi_total <- renderText({
    format(nrow(datos_filtrados()), big.mark = ",")
  })

  output$kpi_promedio <- renderText({
    round(mean(datos_filtrados()$variable, na.rm = TRUE), 1)
  })

  output$kpi_max <- renderText({
    max(datos_filtrados()$variable, na.rm = TRUE)
  })

  # Gráficas
  output$grafica_temporal <- renderPlotly({
    p <- datos_filtrados() |>
      count(trimestre) |>
      ggplot(aes(trimestre, n)) +
      geom_line() +
      theme_minimal()
    ggplotly(p)
  })

  output$grafica_distribucion <- renderPlotly({
    p <- ggplot(datos_filtrados(), aes(categoria, fill = categoria)) +
      geom_bar() +
      theme_minimal() +
      theme(legend.position = "none")
    ggplotly(p)
  })
}

shinyApp(ui, server)
```

**Ese código completo, ~80 líneas, es lo que un estudiante debe poder reproducir.** Es un tablero funcional con filtros, KPIs, gráficas interactivas, conectado a SQLite. Cubre el Checkpoint 5.

### 7.2 Qué NO meter en este patrón

- ❌ Shiny modules (`callModule`, `moduleServer`)
- ❌ Custom CSS más allá de un `bs_theme()` con un color primario
- ❌ Async processing (`promises`, `future`)
- ❌ Server-side rendering de tablas grandes
- ❌ Custom JavaScript con `shinyjs`
- ❌ Authentication
- ❌ Múltiples bases de datos
- ❌ Background workers
- ❌ `reactlog` y reactive debugging avanzado

Si un estudiante quiere meter esto, ofrécele extensión opcional pero no lo hagas estándar del curso.

---

## 8. Limitaciones de Shiny (cuándo NO es la herramienta)

Vale la pena ser explícito con los estudiantes para que tengan criterio.

### 8.1 Memoria por sesión

Cada sesión de Shiny es un proceso R completo. Si tu app carga 500MB de datos y tienes 10 usuarios concurrentes, necesitas 5GB de RAM en el servidor (más R + el sistema). Esto no es problema para tableros internos o académicos, pero sí lo es a escala.

### 8.2 Escalabilidad

`shinyapps.io` (Posit) sirve hasta cierto punto. Más allá:

- Posit Connect (de pago, enterprise)
- ShinyProxy + Docker (open source, requiere setup)
- Servidor propio con `shiny-server` (gratis pero limitado)

Ninguna de esas opciones es trivial. Para apps que necesitan miles de usuarios concurrentes, Shiny no es la opción correcta.

### 8.3 Interactividad granular

Si lo que el usuario quiere es algo tipo "arrastrar nodos en una red, animaciones complejas, integración con APIs externas en tiempo real", Shiny puede hacerlo pero con mucho esfuerzo. React/Vue/Svelte hacen eso de forma nativa.

**La regla:** si la complejidad está en los **datos y el cómputo R**, Shiny es ideal. Si la complejidad está en la **UI y la interactividad**, Shiny es la herramienta incorrecta.

### 8.4 Audiencia no-R

Si tu audiencia incluye desarrolladores web que van a mantener la app, Shiny no es la opción correcta — vivirán traduciendo R a algo que entiendan.

---

## 9. Despliegue: `shinyapps.io` paso a paso

Para el curso, `shinyapps.io` (gratuito limitado) es suficiente.

```r
# 1. Instalar y configurar (una sola vez)
install.packages("rsconnect")
rsconnect::setAccountInfo(
  name = "tu-usuario",
  token = "...",      # desde shinyapps.io account
  secret = "..."
)

# 2. Desplegar
rsconnect::deployApp("app/",
                     appName = "mi-tablero-ensu",
                     appTitle = "Tablero ENSU")
```

Limitaciones del plan gratuito:
- 5 apps activas
- 25 horas/mes de uso total (sumando todas)
- Sin custom domain

Para el curso es más que suficiente. Cada estudiante mantiene su app desplegada durante la evaluación; no se espera tráfico real.

---

## 10. Anti-patrones comunes

1. **Olvidar los `()` al invocar un `reactive`.** El error #1. `datos_filtrados` es una función; `datos_filtrados()` es el data frame.

2. **`reactive()` para algo que solo usa un output.** Suma código sin ganancia. Si el cálculo es exclusivo de un output, mete el código directo en el `render*()`.

3. **`observe()` para calcular valores.** `observe` es para side effects. Si necesitas un valor, usa `reactive`.

4. **Cargar datos dentro del server.** Cada sesión recargará desde cero. Carga datos **fuera** del server (al inicio del script).

5. **No usar `bslib`.** Usar `shinydashboard` o estructuras manuales con `fluidRow`/`column`. `bslib` con `page_sidebar` + `card` + `value_box` da mejor resultado con menos código.

6. **Custom CSS para todo.** Antes de escribir CSS, prueba con un `bs_theme()` cambiando el color primario. Cubre el 80% de los casos.

7. **Mezclar inputs y outputs en el mismo lugar.** La estructura es siempre: inputs en `sidebar`/columna lateral, outputs en el área principal. Mezclarlos confunde al usuario.

8. **No probar con datos vacíos.** Si el filtro resulta en cero filas, las gráficas/value_boxes deben manejarlo (`req(nrow(datos_filtrados()) > 0)` o mensajes informativos).

---

## 11. Tabla decisión rápida

| Quieres... | Usa |
|---|---|
| Un input para elegir un valor de una lista | `selectInput()` |
| Un input numérico continuo | `sliderInput()` |
| Un input numérico discreto | `numericInput()` |
| Mostrar texto reactivo | `textOutput()` + `renderText()` |
| Mostrar una gráfica estática (ggplot) | `plotOutput()` + `renderPlot()` |
| Mostrar una gráfica interactiva (ggplot + interactividad) | `plotlyOutput()` + `renderPlotly()` con `ggplotly()` |
| Mostrar una gráfica interactiva editorial | `highchartOutput()` + `renderHighchart()` |
| Mostrar una tabla simple | `tableOutput()` + `renderTable()` |
| Mostrar una tabla con búsqueda/orden/paginación | `DT::DTOutput()` + `DT::renderDT()` |
| Un KPI prominente | `value_box()` con `textOutput()` adentro |
| Encapsular una gráfica con título | `card()` + `card_header()` |
| Layout de tablero clásico | `page_sidebar()` |
| Layout con secciones | `page_navbar()` con `nav_panel()` |
| Cálculo que se reusa en varios outputs | `reactive({...})`, invocar con `()` |
| Hacer algo cuando cambia un input | `observeEvent(input$X, {...})` |
| Estado que muta por click | `reactiveVal(init)`; leer con `x()`, escribir con `x(nuevo)` |
| Customizar el color del tema | `theme = bs_theme(primary = "#5E002B")` |
| Desplegar la app | `rsconnect::deployApp()` a `shinyapps.io` |

---

## 12. Lecturas y orden recomendado

**Para preparar la clase:**

1. **Mastering Shiny (Wickham)** — `https://mastering-shiny.org/`. Lee los capítulos 1-4 (UI básica, server, reactividad básica). El resto del libro entra en módulos, async, escalado — fuera del alcance del curso.
2. **bslib — Dashboards** — `https://rstudio.github.io/bslib/articles/dashboards/`. Cubre `page_sidebar`, `value_box`, `card`, `layout_columns`.
3. **Cheatsheet de Shiny** — `https://rstudio.github.io/cheatsheets/shiny.pdf`. Tener impresa.

**Para profundizar (opcional, no para el curso):**

- *Engineering Production-Grade Shiny Apps* (Fay et al.) — `https://engineering-shiny.org/`. Modules, async, deployment serio.
- *Mastering Shiny* capítulos 19-23 — módulos, escalado, performance.

---

## 13. Una nota final sobre cómo enseñar este tema

Tu instinto te va a llevar a enseñar "Shiny como deberías hacerlo en producción". Resístelo. Para el curso lo que importa es:

1. **Que el estudiante entienda qué hay debajo** (HTML, CSS, conversión).
2. **Que pueda armar un patrón fijo de tablero** (filtros + value_boxes + gráficas).
3. **Que reconozca cuándo Shiny es la herramienta correcta** y cuándo no.

El tablero del Checkpoint 5 no necesita modules, ni async, ni custom JS, ni server-side rendering avanzado. Necesita ser **claro, funcional y desplegable**. Esos tres atributos lo logra el patrón fijo de la sección 7.

Si un estudiante termina la semana orgulloso de su tablero de 80 líneas que conecta a su SQLite, muestra 4 KPIs, 2 gráficas con plotly y un filtro de año, **ha logrado el objetivo**. Cualquier cosa más allá es bonus.

El estudiante que sale con esto y quiere profundizar después tiene la base correcta: sabe qué es HTML, cómo Shiny lo genera, qué es reactividad, qué es `bslib`. Puede seguir leyendo *Mastering Shiny* completo, puede aprender módulos, puede aprender `golem` para empaquetar como app real. Pero esos pasos son después, no en esta semana.

**La trampa pedagógica más grande de enseñar Shiny es enseñar todo lo que se puede hacer. Eso confunde. Enseña un patrón fijo, ejecutado bien.**
