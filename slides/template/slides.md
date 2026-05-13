---
theme: default
title: Programación para Proyectos de Datos
subtitle: Plantilla de ejemplo — Semana NN
author: Daniel Kelly
date: Otoño 2026
canvasWidth: 1280
highlighter: shiki
lineNumbers: false
drawings:
  persist: false
transition: slide-left
mdc: true
layout: cover
---

---
layout: default
section: Introducción
---

# Estructura de esta plantilla

Esta plantilla replica los componentes del *template* Beamer del curso:

- Paleta institucional Colmex (vino `#5e002b`).
- Layouts [cover]{.colmex-blue}, [section]{.colmex-orange} y [default]{.colmex-green}.
- Bloques [Fragmento]{.colmex-blue} / [Ejemplo]{.colmex-orange} / [Ejercicio]{.colmex-green}.
- Helpers de color inline vía clases MDC.
- Filtrado instructor / estudiante en una sola fuente.

Los slides marcados con `instructor: true` en su frontmatter solo aparecen en la versión completa.

---
layout: section
eyebrow: Parte I
---

# Conceptos clave

---
layout: default
section: Introducción
subsection: Bloques de contenido
---

# Bloque Fragmento

<Fragmento n="1" cita="Adaptado de Wickham (2023), R for Data Science, cap. 3.">

Un [tibble]{.colmex-blue} es una lista de vectores de igual longitud con clase `data.frame`. La diferencia operativa con un `data.frame` clásico está en cómo se imprime y en la ausencia de *partial matching*.

</Fragmento>

---
layout: default
section: Introducción
subsection: Bloques de contenido
---

# Bloque Ejemplo

<Ejemplo n="1" cita="Caso ENSU, 4T 2023.">

La distinción entre `geom_bar()` y `geom_col()` importa: `bar` cuenta filas, `col` grafica el valor que se le pasa.

</Ejemplo>

---
layout: default
section: Práctica
subsection: Ejercicio guiado
---

# Bloque Ejercicio

<Ejercicio n="1">

Dado un `tibble` con las columnas `edad`, `sexo` e `ingreso`, calcula el ingreso promedio por grupo de sexo [únicamente]{.colmex-orange} para mayores de 30 años, en una sola cadena de `dplyr` conectada por `|>`.

</Ejercicio>

---
layout: default
section: Práctica
subsection: Código en vivo
---

# Bloque de código

```r
library(tidyverse)

datos |>
  filter(edad >= 30) |>
  group_by(sexo) |>
  summarise(
    ingreso_medio = mean(ingreso, na.rm = TRUE),
    n             = n(),
    .groups       = "drop"
  )
```

[Observación:]{.colmex-blue} el `.groups = "drop"` evita el *warning* de `dplyr` cuando agrupas y luego resumes.

---
layout: default
section: Práctica
subsection: Código en vivo
instructor: true
---

# Notas para el instructor

Este slide solo aparece en la versión completa.

Puntos a recalcar al pasar el ejercicio anterior:

- [Trampa común:]{.colmex-orange} olvidar `na.rm = TRUE`. Pedirles que corran sin él y vean el efecto.
- Mostrar `summary()` sobre el resultado para reforzar que es un `tibble`.
- Conectar con [S6]{.colmex-blue}: si el filtro fuera más complejo, ¿conviene `case_when` o un *join* con un catálogo?

Tiempo estimado: 8 minutos.

---
layout: default
section: Práctica
subsection: Mezcla
---

# Contenido mixto

Texto normal del slide para el estudiante.

<!-- instructor-only -->

> Solo instructor: este bloque también se elimina del build de estudiante. Útil para anotar tiempos, transiciones o trampas comunes en medio de un slide que sí ven los estudiantes.

<!-- /instructor-only -->

Cierre del slide, también visible para todos.

---
layout: cover
title: Fin del ejemplo
subtitle: ¡Listo para clase!
---
