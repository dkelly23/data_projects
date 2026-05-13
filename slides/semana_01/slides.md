---
theme: default
title: ¿Por qué R? Setup y primeros pasos
subtitle: Semana 1 — Programación para Proyectos de Datos
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
layout: section
eyebrow: Sesión 1 — Teoría
---

# Introducción al Curso

---
layout: default
section: Semana 1
subsection: Introducción
---

# Programación para Proyectos de Datos
Curso comprensivo orientado a la construcción de **proyectos completos de datos**.  

- **Diagnóstico:** La mayoría del contenido disponible en otros cursos (dentro y fuera del programa) se concentran en *habilidades aisladas* y *herramientas específicas*, no al flujo completo del proyecto.

- **Objetivo:** Brindar a los estudiantes las herramientas programáticas y conceptuales necesarias para construir flujos de datos completos, reproducibles y automatizables, en otras palabras, construir un flujo ETL (`Extract`, `Transform` y `Load`).

- **Filosofía:** [zero-to-hero]{.colmex-blue} (no es necesario tener experiencia previa en programación).
- **Duración:** 16 semanas, dos sesiones semanales de 1:30h. La 
- **Lenguaje:** R como único lenguaje del curso (la decisión se justifica más adelante).
- **IDE:** [Positron]{.colmex-orange}, la alternativa superior a [RStudio]{.colmex-orange}.


---
layout: default
section: Semana 1
subsection: Estructura del Curso
---

# Estructura del Curso
Índice temático por semana y sesión.

### Parte 1: Fundamentos
- **Semana 1:** Setup y Primeros Pasos.  
- **Semana 2:** Estructuras de Datos.  
- **Semana 3:** Importación de Datos y Análisis Exploratorio.  
- **Semana 4:** Estructura de Proyectos, `git` y Reproducibilidad.  

### Parte 2: Manipulación
- **Semana 5:** `dplyr` 1; pipes, verbos y `tidyverse`.
- **Semana 6:** `dplyr` 2; joins, pivots y manejo de `NA`'s.
- **Semana 7:** Strings, expresiones regulares (`regex`) y `stringr`.

### Parte 3: Programación
- **Semana 8:** Control de Flujo y Vectorización.
- **Semana 9:** Funciones: diseño, *scoping* y *debbuging*.
- **Semana 10:** Programación Funcional: `purrr` y la familia `apply`.


---
layout: default
section: Semana 1
subsection: Estructura del Curso
---

# Estructura del Curso
Índice temático por semana y sesión.

### Parte 4: Análisis
- **Semana 11:** Modelado estadíostico programático.
- **Semana 12:** Datos a escala: `SQL`, `DBI` y `dbplyr`.

### Parte 5: Productos Finales
- **Semana 13:** Visualización con `ggplot2`.
- **Semana 14:** Automatización con `officer`, `googledrive` y `gmailr`.
- **Semana 15:** Aplicaciones interactivas con `Shiny`.
- **Semana 16:** Interfaces de modelos de lenguaje.  

<br>
<br>
No es un curso de habilidades aisladas, sino de construcción de proyectos completos de datos. Tampoco se busca que el estudiante se vuelva experto, sino que domine las herramientas básicas para posteriormente profundizar en los temas tratados.


---
layout: default
section: Semana 1
subsection: Motivación
---


# ¿Por qué este curso?
Motivación general ([programación]{.colmex-blue}) y específica ([este curso]{.colmex-blue}).

Los cursos previos del programa equipan al estudiante con [habilidades específicas]{.colmex-blue} de programación y de análisis estadístico.  

### ¿Por qué programar?
- Ofrece una forma de pensar y enfrentar problemas, con énfasis en la capacidad de articular soluciones reproducibles y auditables.  
- Salidas laborales amplias.
- Es una herramienta clave para economistas, pues cierra la brecha `teoria` $\to$ `práctica`.

### ¿Por qué este curso?
Énfasis en cómo las habilidades programáticas específicas [se articulan dentro de un mismo proyecto]{.colmex-orange}:  
- Estructurar un repositorio reproducible.
- Traer datos de fuentes diversas.
- Limpiarlos sistemáticamente.
- Modelarlos.
- Producir un entregable comunicable.

---
layout: default
section: Semana 1
subsection: Criterios de Evaluación
---

# Esquema de evaluación
Desglose de la evaluación para el curso.

| Componente                                     | Peso |
|------------------------------------------------|-----:|
| Checkpoints del Proyecto Integrador            | 50%  |
| Proyecto Integrador                            | 20%  |
| Ejercicios en Clase (segunda sesión semanal)   | 20%  |
| Asistencia                                     | 10%  |

[Sin tareas semanales fuera de clase.]{.colmex-orange} El trabajo evaluable se concentra en los ejercicios resueltos en la segunda sesión de la semana y en el proyecto integrador.

### Proyecto Integrador
- Desarrollo de un flujo completo en forma de un repositorio, que permita la [extracción]{.colmex-blue}, [limpieza]{.colmex-blue} y [análisis]{.colmex-blue} de datos.
- Tratamiento de los microdatos de una encuesta de INEGI.
El resto de los detalles se darán más adelante en el curso...

---
layout: section
eyebrow: Sesión 1 — Teoría
---

# ¿Por qué R?

---
layout: default
section: Sesión 1
subsection: ¿Por qué R?
---

# R, Python, Stata: ¿cuándo cada uno?
Diferencias entre los lenguajes de programación más usados para manejo de datos y estadística.

[**R**]{.colmex-blue} — lenguaje de la investigación cuantitativa en economía.

- Ecosistema completo diseñado alrededor del trabajo con datos.
- Sintaxis vectorizada nativa; verbos de manipulación de datos expresivos que se encadenan entre sí.
- Excelente para insumos reproducibles: reportes, gráficas publicables y modelos estadísticos.

<br>  

[**Python**]{.colmex-orange} — propósito general; fuerza en producción y ML.

- Lenguaje de propósito general, adaptado al trabajo con datos (menos amigable).
- Ecosistema muy rico para modelos de aprendizaje automático e IA.
- Más "bajo nivel" que R.

<br>  

[**Stata**]{.colmex-orange} — históricamente común en economía aplicada.

- Requiere una licencia súmamente cara.
- Poco adaptable a flujos reproducibles.
- Sin herramientas de programación general.
- No puedes abrir más de una tabla a la vez!!! (Sin `environment`).
- [Descartado de origen para este curso.]{.colmex-orange}

---
layout: default
section: ¿Por qué R?
subsection: Ecosistema
---

# Tres piezas que vamos a usar todo el curso
Bloques fundacionales del trabajo con [R]{.colmex-blue}.

[**CRAN**]{.colmex-blue} — Comprehensive R Archive Network.

- Repositorio oficial de paquetes y distribuciones del lenguaje. Garantiza compatibilidad con la versión que estés corriendo y verifica los paquetes antes de publicarlos.
- Sistematización de la naturaleza `open-source` del lenguaje.  

<br>

[**tidyverse**]{.colmex-blue} — colección de paquetes con [gramática compartida]{.colmex-orange}.

Manipulación (`dplyr`), visualización (`ggplot2`), strings (`stringr`), iteración (`purrr`), entre otros. Es el dialecto principal del curso y del uso de [R]{.colmex-blue}.

<br>

[**Positron**]{.colmex-blue} — IDE (*Integrated Development Environment*) pensado específicamente para análisis de datos (desarrollado por Posit).

- Provee infraestructura comercial sin comprometer la naturaleza abierta del lenguaje.
- Instrucciones de instalación a continuación.

---
layout: section
---

# Setup: Positron + R

---
layout: default
section: Setup
subsection: Instalación
---

# Instalación + Setup Inicial
Las dos piezas que requerimos para empezar.

[**1. R**]{.colmex-blue} — el intérprete del lenguaje.

Descarga desde [CRAN](https://cran.itam.mx/). Última versión: 4.6.0.

[**2. Positron**]{.colmex-orange} — el IDE.

Descarga desde [positron.posit.co](https://positron.posit.co/). Sucesor de RStudio (el antecesor espiritual, desarrollado específicamente para R), desarrollado por la misma organización. Port de VSCode.

<br>

<Fragmento t="Instrucciones de Instalación">

1. Descarga [R]{.colmex-blue} desde [CRAN](https://cran.itam.mx/) y [Positron]{.colmex-orange} desde la web de [Posit](https://positron.posit.co/).
2. Verifica la instalación abriendo `Terminal` (Mac) o `Shell` (Windows) y ejecutando:
```bash
R --version
```
3. Dirígete a la consola de R y ejecuta:
```r
print("Mi primera línea de código")
```

</Fragmento>

---
layout: default
section: Setup
subsection: El IDE
---

# Anatomía de Positron

Cuatro paneles principales que se quedan contigo el resto del semestre:

- [**Source**]{.colmex-blue} — los scripts `.R` que editas.
- [**Consola**]{.colmex-blue} — el REPL donde se ejecuta R en vivo.
- [**Environment**]{.colmex-orange} — los objetos creados en la sesión actual.
- [**Plots / Help / Files**]{.colmex-orange} — outputs visuales, documentación, navegación del proyecto.

Atajo fundamental: `Cmd-Enter` envía la línea actual del script a la consola.

(Demo en vivo.)

---
layout: section
---

# Modelos de lenguaje en el curso

---
layout: default
section: LLMs
subsection: Dos usos distintos
---

# Chatbot vs. agente integrado

[**LLM como chatbot**]{.colmex-blue} — pegas la pregunta, copias la respuesta.

- ChatGPT, Claude, Gemini en su interfaz web.
- Cero contexto del proyecto; depende de lo que tú copies.
- [Riesgo:]{.colmex-orange} atrofia la capacidad individual de razonar sobre código.

[**LLM como agente integrado**]{.colmex-orange} — lee archivos, propone cambios, ejecuta comandos con el humano en el [loop]{.colmex-blue}.

- [Claude Code de Anthropic]{.colmex-blue}, [Codex de OpenAI]{.colmex-blue}.
- Conoce tu repositorio, tus convenciones, tus errores recientes.
- Puede acelerar drásticamente el trabajo, pero solo si ya dominas los fundamentos.

---
layout: default
section: LLMs
subsection: Política del curso
---

# Política del curso

[**Permitido**]{.colmex-blue} en el proyecto integrador, [como agente]{.colmex-blue}. Documenta qué le pediste y verifica cada línea que entregues.

[**No permitido**]{.colmex-orange} en los ejercicios de clase (segunda sesión semanal). Esos son el momento para que [tú]{.colmex-orange} construyas el músculo.

[**Regla práctica**]{.colmex-blue}: debes ser capaz de leer y modificar cualquier línea que entregues como tuya.

<Ejemplo n="1">

La idea no es prohibir herramientas reales. La idea es que termines el curso pudiendo programar [sin depender de ellas]{.colmex-orange}.

</Ejemplo>

---
layout: section
---

# El lenguaje R

---
layout: default
section: El lenguaje R
subsection: Características
---

# Tres características clave

[**Interpretado**]{.colmex-blue} — cada línea se ejecuta sin paso de compilación.

Trade-off: iteración rápida y exploratoria; más lento que C/Rust para operaciones masivas.

[**Vectorizado**]{.colmex-orange} — las operaciones aplican elemento a elemento sobre vectores sin necesidad de `for`.

```r
x <- c(1, 2, 3, 4)
x * 2          # 2 4 6 8 — sin loop explícito
```

[**Multiparadigma**]{.colmex-blue} — admite estilos funcional, imperativo y orientado a objetos, sin imponer uno.

---
layout: default
section: El lenguaje R
subsection: Cómo se corre código
---

# Tres formas de ejecutar R

[**1. REPL**]{.colmex-blue} (Read-Eval-Print Loop) — la consola interactiva. Útil para exploración rápida.

[**2. Script con `source()`**]{.colmex-blue} — ejecuta un archivo `.R` completo desde la consola.

```r
source("pre/01-extract.R")
```

[**3. Ejecutable con `Rscript`**]{.colmex-blue} — corre un script desde la terminal del sistema, sin abrir R interactivo.

```bash
Rscript pre/01-extract.R
```

[Convención del curso:]{.colmex-orange} durante autoría usamos REPL para inspeccionar, pero el ETL final se diseña para correrse con `Rscript` o `source()` desde un master script.

---
layout: section
---

# Primeros objetos en R

---
layout: default
section: Primeros objetos
subsection: Asignación
---

# Asignación: `<-` vs. `=`

R acepta dos operadores de asignación:

```r
x <- 5      # idiomático, recomendado
x = 5       # válido, menos común en R
```

[Convención del curso:]{.colmex-blue} usar `<-` consistentemente.

Razones:

- Es la convención dominante en la literatura R.
- Diferencia visualmente la asignación del paso de argumentos en funciones (`f(x = 5)`).

> Atajo en Positron: `Option--` inserta `<- ` automáticamente.

---
layout: default
section: Primeros objetos
subsection: Tipos atómicos
---

# Los cuatro tipos atómicos

```r
n <- 3.14          # numeric (double por default)
i <- 42L           # integer (sufijo L)
b <- TRUE          # logical (también FALSE; NA es válido)
s <- "datos"       # character (string)
```

Inspección:

```r
class(n)           # "numeric"
typeof(i)          # "integer"
length(s)          # 1
```

> Todo en R es un vector. Un "escalar" en realidad es un vector de longitud 1.

---
layout: default
section: Primeros objetos
subsection: Vectores
---

# Construir vectores con `c()`

```r
edades   <- c(23, 45, 31, 28, 52)
ciudades <- c("CDMX", "MTY", "GDL")
activos  <- c(TRUE, TRUE, FALSE, TRUE)
```

[Vectorización en acción]{.colmex-orange}:

```r
edades + 5
# [1] 28 50 36 33 57

edades > 30
# [1] FALSE  TRUE  TRUE FALSE  TRUE

mean(edades)
# [1] 35.8
```

[Recycling]{.colmex-blue} — cuando operas vectores de distinta longitud, R recicla el corto:

```r
c(1, 2, 3, 4) + c(10, 20)
# [1] 11 22 13 24
```

---
layout: default
section: Primeros objetos
subsection: Inspección
---

# Funciones esenciales de inspección

```r
class(edades)     # "numeric"  — la clase del objeto
typeof(edades)    # "double"   — el tipo subyacente
length(edades)    # 5          — número de elementos
str(edades)       # estructura compacta (un resumen)
```

`str()` es particularmente útil cuando un objeto es complejo:

```r
str(list(nombre = "ENSU", n = 1500L, pais = "México"))
# List of 3
#  $ nombre: chr "ENSU"
#  $ n     : int 1500
#  $ pais  : chr "México"
```

<Fragmento n="1">

Reflejo del curso: cuando algo no se comporta como esperas, `str()` es la primera pregunta —"¿qué es lo que tengo realmente entre manos?".

</Fragmento>

---
layout: section
---

# Evaluación de condiciones lógicas

---
layout: default
section: Condiciones lógicas
subsection: Operadores
---

# Comparación y operadores lógicos

[**Comparación**]{.colmex-blue} (vectorizados, devuelven `logical`):

```r
x <- c(10, 25, 47, 30)
x > 20            # FALSE  TRUE  TRUE  TRUE
x == 30           # FALSE FALSE FALSE  TRUE
x != 47           #  TRUE  TRUE FALSE  TRUE
```

[**Lógicos entre vectores**]{.colmex-orange}:

```r
(x > 20) & (x < 40)    # FALSE  TRUE FALSE  TRUE
(x < 15) | (x > 40)    #  TRUE FALSE  TRUE FALSE
!(x > 20)              #  TRUE FALSE FALSE FALSE
```

[Versiones escalares]{.colmex-blue}: `&&` y `||` operan solo en el primer elemento, útiles dentro de `if` (semana 8).

---
layout: default
section: Condiciones lógicas
subsection: Coerción
---

# `logical` → numérico: contar y promediar

Un vector lógico se coerce automáticamente a numérico (`TRUE → 1`, `FALSE → 0`):

```r
TRUE + TRUE             # 2
sum(c(T, F, T, T))      # 3
```

De ahí, dos idiomas frecuentes:

```r
x <- c(15, 25, 35, 45, 55)

# Cuántos cumplen la condición:
sum(x > 30)             # 3

# Qué proporción cumplen:
mean(x > 30)            # 0.6
```

<Fragmento n="2">

`sum(condición)` y `mean(condición)` son la forma idiomática de [contar y obtener proporciones]{.colmex-blue} en R, sin necesidad de `if` ni de `for`.

</Fragmento>

---
layout: default
section: Condiciones lógicas
subsection: NA en condiciones
---

# `NA` se propaga silenciosamente

`NA` (Not Available) representa valor faltante. Cuando aparece en una condición, [se propaga]{.colmex-orange}:

```r
NA == 5             # NA  (¡no FALSE!)
NA > 3              # NA
TRUE & NA           # NA
FALSE & NA          # FALSE   (ya es falsa, no requiere el NA)
```

Implicación práctica:

```r
x <- c(10, NA, 30)
sum(x > 20)                  # NA  ← sorpresa
sum(x > 20, na.rm = TRUE)    # 1   ← lo que probablemente quieres
```

[Funciones útiles]{.colmex-blue}: `any()`, `all()`, `is.na()`, `isTRUE()`, `isFALSE()`.

> Sospechen de cualquier resultado `NA` inesperado: casi siempre indica que un valor faltante invadió un cálculo donde no debía.

---
layout: section
eyebrow: Sesión 2 — Práctica
---

# Ejercicios en clase

---
layout: default
section: Sesión 2
subsection: Resumen de la Sesión 1
---

# Lo que vimos la sesión pasada

- Por qué R en este curso y dónde encaja en el ecosistema.
- Cómo instalar Positron + R.
- Política sobre LLMs: agentes sí, chatbots no en ejercicios.
- Tres formas de ejecutar R: REPL, `source()`, `Rscript`.
- Tipos atómicos: `numeric`, `integer`, `logical`, `character`.
- Vectorización y `c()`.
- Operadores de comparación y lógicos.
- Coerción `logical → numeric` para contar y promediar.
- Propagación silenciosa de `NA` en condiciones.

Hoy lo bajamos a código en clase.

---
layout: default
section: Sesión 2
subsection: Ejercicios
---

# Ejercicio 1 — Temperaturas

<Ejercicio n="1">

Crea un vector llamado `temperaturas` con las temperaturas máximas registradas durante 7 días en la CDMX: `21, 24, 22, 26, 28, 25, 23`.

Calcula:

1. La temperatura promedio de la semana.
2. Cuántos días superaron los 25°C.
3. Qué proporción de días estuvo entre 22 y 26°C (inclusive).

</Ejercicio>

---
layout: default
section: Sesión 2
subsection: Ejercicios
---

# Ejercicio 2 — Ingresos con NA

<Ejercicio n="2">

Tienes el siguiente vector, con algunos valores faltantes:

```r
ingreso <- c(15000, 22000, NA, 18000, 31000, NA, 12000)
```

Calcula:

1. El ingreso promedio ignorando los `NA`.
2. Cuántas observaciones tienen ingreso registrado (no `NA`).
3. Qué proporción de las personas con ingreso registrado gana más de 20,000.

</Ejercicio>

---
layout: default
section: Sesión 2
subsection: Ejercicios
---

# Ejercicio 3 — Inspección

<Ejercicio n="3">

Considera el objeto:

```r
encuesta <- list(
  nombre   = "ENSU",
  periodo  = "4T 2023",
  n        = 1500L,
  factores = c(1.2, 0.9, 1.1)
)
```

1. ¿De qué clase es `encuesta`? ¿Qué tipo tiene cada uno de sus elementos?
2. ¿Cuál es la longitud de `encuesta`? ¿Y la de `encuesta$factores`?
3. Usa `str()` sobre `encuesta` y explica qué muestra cada línea.

</Ejercicio>

---
layout: cover
title: Hasta la próxima
subtitle: Semana 2 — Estructuras de datos e indexación
---
