# Programación para Proyectos de Datos

## Visión general

Curso comprensivo de programación orientado a la construcción de **proyectos completos de datos** (no skills aisladas ni problemas pequeños). Diseñado para incorporarse a la formación de la Licenciatura en Economía de El Colegio de México.

**Hueco que llena:** los cursos existentes cubren skills muy específicas, o resuelven problemas pequeños dentro del flujo de un proyecto, pero no enseñan a construir un proyecto de datos de principio a fin.

**Filosofía:** *zero-to-hero*. Se asume que el estudiante llega con nociones básicas o nulas de programación, y termina capaz de levantar un proyecto de datos completo por su cuenta.

**Lenguaje:** R como único lenguaje del curso. Stata descartado de origen. Python solo aparece como mención comparativa puntual (S1: por qué R sobre Python en el contexto académico + datos; S5: pandas como alternativa a dplyr).

**IDE:** Positron.

**Fuentes de contenido:**
- *Advanced R* (Hadley Wickham)
- *R for Data Science* (Wickham, Çetinkaya-Rundel, Grolemund) — referido como R4DS
- Experiencia propia del profesor

---

## Datos formales del curso

| Campo | Valor |
|---|---|
| Profesor | Daniel Kelly |
| Institución | El Colegio de México |
| Programa | Licenciatura en Economía |
| Semestre | Otoño 2026 (agosto–diciembre) |
| Clave | Pendiente (curso nuevo) |
| Duración | 16 semanas |
| Sesiones | 2 sesiones de 1:30 hr por semana (32 sesiones totales) |

**Título del documento principal:** *Temario del Curso* (NO "Syllabus" — el usuario prefiere el término en español).

---

## Estructura semanal (default)

Cada semana tiene dos sesiones con roles diferenciados:
- **Sesión 1 — Teoría.** Exposición conceptual del tema con código en vivo demostrativo. Proporción típica ~60% teoría / 40% código. Puede inclinarse hacia más teoría en semanas conceptualmente densas.
- **Sesión 2 — Práctica.** Resumen rápido inicial de la sesión 1, seguido de ejercicios prácticos resueltos en clase.

**Sin tareas semanales fuera de clase.** El trabajo evaluable se concentra en ejercicios en clase y en el proyecto integrador.

## Esquema de evaluación

| Componente | Peso |
|---|---:|
| Checkpoints del proyecto integrador | 50% |
| Proyecto final | 20% |
| Ejercicios en clase (segunda sesión semanal) | 20% |
| Asistencia | 10% |

---

## Estructura del curso (16 semanas)

El curso se articula en cinco partes; la lista plana de las 16 semanas es la siguiente:

| # | Semana | Parte |
|---|---|---|
| 1 | ¿Por qué R? Setup y primeros pasos | I — Fundamentos |
| 2 | Estructuras de datos (listas, DataFrames, tibbles, indexación, NA, coerción) | I — Fundamentos |
| 3 | Importación de datos y EDA con base R | I — Fundamentos |
| 4 | Estructura de proyectos, Git y reproducibilidad | I — Fundamentos |
| 5 | dplyr I: pipe, verbos básicos y sistema tidyverse | II — Manipulación |
| 6 | dplyr II: joins, pivots y manejo de NA | II — Manipulación |
| 7 | Strings, expresiones regulares y `stringr` | II — Manipulación |
| 8 | Control de flujo y vectorización | III — Programación |
| 9 | Funciones: diseño, scoping y debugging | III — Programación |
| 10 | Programación funcional: `purrr` y `apply` | III — Programación |
| 11 | Modelado estadístico programático (`lm`, `plm`, `broom`, `modelsummary`) | IV — Análisis |
| 12 | Datos a escala: SQL, `DBI` y `dbplyr` | IV — Análisis |
| 13 | Visualización con `ggplot2` | V — Productos Finales |
| 14 | Automatización con `officer`, `googledrive` y `gmailr` | V — Productos Finales |
| 15 | Shiny | V — Productos Finales |
| 16 | Interfaces de modelos de lenguaje (`ellmer`, `httr2`) | V — Productos Finales |

**Nota:** la Parte V se nombra *Productos Finales* (no solo "Productos").

---

## Proyecto integrador

El curso se articula alrededor de un proyecto integrador que los estudiantes construyen a lo largo del semestre.

- **Anuncio:** S1.
- **Pipeline:** input → limpieza → modelado → producto.
- **Checkpoints** alineados con las cinco partes del curso (al cierre de cada parte hay una entrega parcial).
- **Separación del contenido semanal:** el contenido de cada semana NO se ata explícitamente al proyecto integrador dentro de los subtemas u objetivos. El proyecto integrador vive en su propia sección; las semanas mencionan flujos generales ("el proyecto en el que se trabaje"), no checkpoints específicos.

> **Pendiente:**
> - Definir el dataset (o set de datasets) recurrente del proyecto integrador.
> - Definir los entregables específicos de cada checkpoint.

---

## Restricciones explícitas (decisiones del usuario)

Estas decisiones se tomaron y deben respetarse:

- **NO** incluir Quarto ni RMarkdown.
- **NO** incluir `data.table` como tema dedicado (mención en passing máximo en S6).
- **Series de tiempo** solo a nivel programático, NO comprensivo (en S11 junto con modelado). Sin mención a `forecast` ni `fable`.
- **officer+googledrive+gmailr**, **Shiny**, y **LLMs** cada uno como sesión individual.
- **Modelado de inferencia**: enfoque estrictamente programático — cómo se especifican fórmulas, cómo se extraen coeficientes, cómo se reportan resultados. La teoría estadística la ven en Econometría.
- **Política sobre LLMs:** se introduce explícitamente en S1.1. La visión es que **depender mal de un LLM atrofia la capacidad individual**, pero usado **como agente integrado al proyecto** (Claude Code de Anthropic, Codex de OpenAI) puede acelerar el trabajo. **Permitido** en el proyecto integrador; **no permitido** en ejercicios de clase. El estudiante debe poder leer y modificar cualquier línea que entregue.

---

## Convenciones de lenguaje y tono

Estas convenciones surgen de las correcciones del usuario al primer borrador del `.tex` y aplican a TODO contenido posterior (semanas, slides, materiales):

**Tono.**
- Académico formal. Evitar fórmulas casuales del tipo "Esta semana es la entrada al curso", "Esta semana es la primera vez que…". Preferir construcciones como "Esta semana corresponde a…", "Semana que cierra…", "Esta semana constituye…".
- Atribución impersonal: NO referirse a "el profesor" en el texto. La estructura propuesta es "de proyectos profesionales reales", no "del profesor".

**Terminología.**
- *"datos"* como término genérico, NO *"microdatos"* salvo cuando el contexto sea específicamente de encuesta (ENSU, ENIGH). El curso no debe leerse como centrado en encuestas.
- **Banco de México** (forma extendida) o **BANXICO** (versalitas), NO "Banxico" como nombre propio coloquial.
- *"regresión lineal univariable"* cuando se mencione el prerrequisito.
- *"los estudiantes"* (no "el equipo") en contextos pedagógicos donde el referente es la clase.
- *"sistema/vocabulario consistente"* en vez de "API consistente" cuando se hable de paquetes tidyverse al estudiante.
- Nombrar el lugar como **El Colegio de México** explícitamente cuando se pueda.

**Vínculo con el proyecto integrador.**
- Las semanas NO referencian "Checkpoint N" en su narrativa, subtemas u objetivos de aprendizaje. Esa vinculación vive solo en la sección dedicada al proyecto integrador.
- Cuando se necesite ejemplificar un flujo aplicado, usar formulaciones genéricas ("el proyecto en el que se trabaje", "un pipeline ETL", "un flujo de análisis") en lugar de "el proyecto integrador".

**Recortes preferidos.**
- Evitar adjetivos calificadores fuertes redundantes ("invaluable", "fundamental" en exceso). Si un punto es central, ya se nota por su posición.
- Evitar enumeraciones internas que se sienten checklist ("anti-patrón clásico…", "fuente #1 de bugs"). Mantener los que aportan al diagnóstico; recortar los que solo dramatizan.

---

## Materiales por semana

Decisiones tomadas sobre los artefactos que se producen para cada semana:

- **Presentación Slidev** (`slides/semana_NN/`) — usada en clase, distribuida a estudiantes como sitio estático en GitHub Pages.
- **Lecture notes para estudiantes** — documento detallado en Markdown, render a PDF con Quarto. **Pendiente; se aborda al final del curso una vez consolidadas las presentaciones.**

**No hay documento separado de notas del instructor.** El deck Slidev es la única referencia del instructor; no se mantiene un `doc-instructor.md` ni similar paralelo a las slides. Si en algún momento se requiere contenido visible solo para el instructor, se usa el mecanismo nativo de Slidev (`instructor: true` en el frontmatter de un slide, o bloques `<!-- instructor-only -->`), no un archivo aparte.

---

## Slides (Slidev)

Stack: [Slidev](https://sli.dev) con tema custom Colmex en `slides/_theme/`.

**Ubicación:**
- `slides/_theme/` — layouts, components, style.css, public assets (compartido entre semanas).
- `slides/template/` — plantilla maestra que se copia para arrancar cada semana.
- `slides/semana_NN/` — una carpeta por semana, con symlinks a `_theme`.

**Stack interno:** Slidev usa Vite + Vue por debajo. `vite.config.mjs` en cada semana amplía `server.fs.allow` al directorio padre para que los symlinks a `../_theme/` resuelvan. Builds usan `--base ./` para que las rutas a assets sean relativas y funcionen tanto en GitHub Pages como vía servidor local.

**Para arrancar:** ver `slides/README.md`.

---

## Plantilla de presentaciones (Beamer)

Plantilla LaTeX/Beamer original, **referencia de estilo** para `syllabus.tex` y para el tema Slidev. Ya **no se usa para slides** (eso se hace ahora con Slidev).

Ubicación: `muestra_ppt/` (referencia — no tocar la plantilla original).

**Archivos:**
- `swjtu.sty` — estilo Beamer
- `Presentación Tópicos.tex` — ejemplo de uso
- `bibliography.bib` — referencias
- `Imágenes/title_bg.png`, `section_title.png`, `final_page_bg.png`

**Diseño:**
- Color principal: `#5e002b` (vino, paleta Colmex)
- Tipografía serif profesional
- Idioma: español (`babel`)
- Bibliografía: `biblatex` con estilo APA

**Comandos custom disponibles:**
- `\blue{texto}`, `\orange{texto}`, `\green{texto}` — destacar texto en color
- `\fragmento{N}{contenido}{cita}` — bloque de ejemplo
- `\ejemplo{N}{moción}{cita}` — bloque de alerta
- `\ejercicio{N}{enunciado}` — bloque de ejercicio

**Bloques de código:** vía `lstlistings` con estilo predefinido (verde para comentarios, rojo para keywords).

---

## Convenciones para el desarrollo del temario

**Idioma de los materiales:** español.

**Detalle por sesión** (acordado con el usuario):
- Subtemas
- Objetivos de aprendizaje (2–4)
- Lecturas específicas (capítulo + sección de R4DS / Advanced R / otras)
- Ejercicio sugerido

**Workflow de iteración:**
1. El agente propone desglose completo de la sesión.
2. El usuario comenta y ajusta.
3. Se consolida la sesión antes de pasar a la siguiente.
4. Una vez todas las sesiones acordadas, se transcribe al `syllabus.tex` (titulado *Temario del Curso*).

**Estructura de directorios propuesta:**
```
Programming for Data Projects/
├── CLAUDE.md
├── syllabus/
│   ├── syllabus.tex
│   └── bibliography.bib
├── slides/
│   ├── assets/         (imágenes compartidas, copia de muestra_ppt)
│   ├── swjtu.sty       (estilo compartido)
│   └── semana_NN/      (una carpeta por semana, contiene ambas sesiones)
└── muestra_ppt/        (referencia, no tocar)
```

---

## Pendientes generales

- [ ] Definir dataset recurrente del proyecto integrador.
- [ ] Definir entregables específicos de cada checkpoint.
- [ ] Desarrollar slides sesión por sesión.
