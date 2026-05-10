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

---

## Estructura semanal (default)

Cada semana tiene dos sesiones con roles diferenciados:
- **Sesión 1 — Teoría.** Exposición conceptual del tema con código en vivo demostrativo. Proporción típica ~60% teoría / 40% código. Puede inclinarse hacia más teoría en semanas conceptualmente densas.
- **Sesión 2 — Práctica.** Resumen rápido inicial de la sesión 1, seguido de ejercicios prácticos resueltos en clase.

**Sin tareas semanales fuera de clase.** El trabajo evaluable se concentra en ejercicios en clase y en el proyecto integrador.

## Esquema de evaluación

> **Pendiente:** confirmar porcentajes finales.

Propuesta:
- Checkpoints del proyecto integrador — **40%**
- Proyecto final — **30%**
- Ejercicios en clase (sesión 2 semanal) — **25%**
- Asistencia — **5%**

---

## Estructura del curso (16 semanas, 5 partes)

Cada semana tiene 2 sesiones de 1:30 hr. La granularidad fina (qué se ve en la sesión A vs. B de cada semana) se desarrolla iterativamente como parte del temario detallado.

### Parte I — Fundamentos (Semanas 1–4)
- **Semana 1** ¿Por qué R? + setup Positron + primer script + objetos, asignación, vectores, tipos
- **Semana 2** Estructuras de datos: listas, DataFrames, tibbles, indexación, NA, coerción
- **Semana 3** Importación de datos (`readr`, `readxl`, `haven`) + EDA con base R + estadística descriptiva + base graphics
- **Semana 4** Estructura de proyectos + Git + `here` + `renv`

### Parte II — Manipulación (Semanas 5–7)
- **Semana 5** dplyr I: pipe + verbos básicos + sistema tidyverse
- **Semana 6** dplyr II: joins + pivots + NA + `case_when` / `coalesce`
- **Semana 7** Strings + regex + `stringr` + `glue`

### Parte III — Programación (Semanas 8–10)
- **Semana 8** Control flow + vectorización
- **Semana 9** Funciones: diseño, scoping, errores, debugging (`browser`, `traceback`)
- **Semana 10** Programación funcional: `purrr` + familia `apply`

### Parte IV — Análisis (Semanas 11–12)
- **Semana 11** Modelado: `lm` + `plm` (panel) + categóricos + manejo de fechas y series con `zoo`/`ts` + `broom` + `modelsummary`
- **Semana 12** Datos a escala: SQL + `DBI` + `dbplyr` (incluye montar MySQL local y queries básicos)

### Parte V — Productos (Semanas 13–16)
- **Semana 13** ggplot2: gramática completa, themes, faceting, export
- **Semana 14** `officer` + `googledrive` (automatización de PPT/reportes)
- **Semana 15** Shiny
- **Semana 16** Interfaces de LLMs: `ellmer` + Gemini API + `telegram_bot`

---

## Proyecto integrador

El curso se articula alrededor de un proyecto integrador que los estudiantes construyen a lo largo del semestre.

- **Anuncio:** S1.
- **Pipeline:** input → limpieza → modelado → producto.
- **Checkpoints** alineados con las cinco partes del curso (al cierre de cada parte hay una entrega parcial).

> **Pendiente:**
> - Definir el dataset (o set de datasets) recurrente del proyecto integrador.
> - Definir los entregables específicos de cada checkpoint.

---

## Restricciones explícitas (decisiones del usuario)

Estas decisiones se tomaron y deben respetarse:

- **NO** incluir Quarto ni RMarkdown.
- **NO** incluir `data.table` como tema dedicado (mención en passing máximo en S6).
- **Series de tiempo** solo a nivel programático, NO comprensivo (en S11 junto con modelado).
- **officeR+googledrive**, **Shiny**, y **LLMs** cada uno como sesión individual.
- **Modelado de inferencia**: enfoque estrictamente programático — cómo se especifican fórmulas, cómo se extraen coeficientes, cómo se reportan resultados. La teoría estadística la ven en Econometría.

---

## Plantilla de presentaciones

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
- Conexión con el proyecto integrador (cuando aplique)

**Workflow de iteración:**
1. El agente propone desglose completo de la sesión.
2. El usuario comenta y ajusta.
3. Se consolida la sesión antes de pasar a la siguiente.
4. Una vez todas las sesiones acordadas, se transcribe al `syllabus.tex`.

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

- [ ] Confirmar porcentajes exactos de evaluación (asistencia + ejercicios en clase).
- [ ] Definir dataset recurrente del proyecto integrador.
- [ ] Definir entregables específicos de cada checkpoint.
- [ ] Desarrollar temario detallado sesión por sesión.
- [ ] Crear estructura de directorios y `syllabus.tex`.
