# Programación para Proyectos de Datos

## Visión general

Curso comprensivo de programación orientado a la construcción de **proyectos completos de datos** (no skills aisladas ni problemas pequeños). Diseñado para incorporarse a la formación de la Licenciatura en Economía de El Colegio de México.

**El curso se imparte como una secuencia de dos cursos independientes.** El **curso 1** (6 sesiones, en marcha) cubre fundamentos, manipulación y programación. El **curso 2** (por definir) retoma desde ahí con modelado, SQL, APIs y productos finales. Salvo indicación contraria, "el curso" en este documento se refiere al curso 1.

**Hueco que llena:** los cursos existentes cubren skills muy específicas, o resuelven problemas pequeños dentro del flujo de un proyecto, pero no enseñan a construir un proyecto de datos de principio a fin.

**Filosofía:** *zero-to-hero*. Se asume que el estudiante llega con nociones básicas o nulas de programación, y termina capaz de levantar un proyecto de datos completo por su cuenta.

**Lenguaje:** R como único lenguaje del curso. Stata descartado de origen. Python solo aparece como mención comparativa puntual (Sesión 1: por qué R sobre Python en el contexto académico + datos; Sesión 3: pandas como alternativa a dplyr).

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
| Semestre | Otoño 2026 |
| Clave | Pendiente (curso nuevo) |
| Duración (curso 1) | 6 semanas — viernes 21 ago a 25 sep 2026 |
| Sesiones (curso 1) | 1 sesión de 3:00 hr por semana, viernes (6 sesiones, 18 hrs) |
| Curso 2 | Duración y calendario por definir |

**Título del documento principal:** *Temario del Curso* (NO "Syllabus" — usar el término en español).

---

## Estructura de la sesión (curso 1)

Una sola sesión semanal de 3:00 hr, dividida en dos bloques separados por un receso:
- **Bloque de exposición (~1:45).** Desarrollo conceptual del tema con código en vivo demostrativo.
- **Bloque de práctica (~1:15).** Ejercicios resueltos en clase sobre la ENSU.

**Sin tareas fuera de clase.** El trabajo evaluable se concentra en el bloque de práctica.

## Esquema de evaluación (curso 1)

| Componente | Peso |
|---|---:|
| Ejercicios del bloque de práctica (6) | 70% |
| Asistencia y participación | 30% |

> El curso 1 **no tiene proyecto integrador con entregas evaluables**. Ese esquema (checkpoints + proyecto final) corresponde al curso 2.

---

## Estructura del curso 1 (6 sesiones)

Tres bloques, dos sesiones cada uno:

| # | Sesión | Bloque |
|---|---|---|
| 1 | El lenguaje y el proyecto: R, Positron, Git y GitHub | I — Fundamentos |
| 2 | Estructuras de datos, importación y exploración | I — Fundamentos |
| 3 | dplyr I: pipe, verbos básicos y sistema tidyverse | II — Manipulación |
| 4 | dplyr II y manejo de texto: joins, pivots y `stringr` | II — Manipulación |
| 5 | Control de flujo, vectorización y funciones | III — Programación y visualización |
| 6 | Programación funcional y visualización con `ggplot2` | III — Programación y visualización |

**Origen del mapeo.** El curso 1 comprime las semanas 1–10 del temario original de 16 semanas (más una parte de la S13):

| Sesión nueva | Absorbe del temario de 16 semanas |
|---|---|
| 1 | S1 completa + estructura de carpetas, Git y GitHub de S4 |
| 2 | S2 (estructuras + indexación) + S3 (importación + EDA base) |
| 3 | S5 (dplyr I) |
| 4 | S6 (dplyr II) + S7 (strings/regex) |
| 5 | S8 (control de flujo) + S9 (funciones) |
| 6 | S10 (purrr) + fundamentos de S13 (ggplot2) |

**Recortes deliberados** (30 hrs originales → 18 hrs). Movidos al curso 2, no eliminados: `renv` y *master script*; APIs con `httr2` y el caso SIE de Banco de México; `logger`; `stringdist`, `tidytext` y *word embeddings*; `switch` y *closures* en profundidad; `debug()`/`undebug()`; la familia `apply` completa; `furrr`/`future` y paralelización; `expr()`/`!!` para filtros dinámicos; el ecosistema de `ggplot2` (`patchwork`, `ggrepel`, `ggtext`, `paletteer`, `ggthemes`).

**Curso 2 (por definir).** Contenido restante: reproducibilidad avanzada, APIs HTTP, modelado estadístico programático, SQL/`DBI`/`dbplyr`, `ggplot2` avanzado, `officer`+`googledrive`+`gmailr`, Shiny, e interfaces de modelos de lenguaje. El proyecto integrador con checkpoints vive aquí.

---

## Hilo conductor del curso 1: la ENSU

El curso 1 **no tiene proyecto integrador evaluable**. En su lugar, las seis sesiones operan sobre un mismo conjunto de datos para que cada tema nuevo se aplique sobre material ya conocido.

**Dataset:** Encuesta Nacional de Seguridad Pública Urbana (ENSU) del INEGI, levantamiento trimestral. Razones: archivos ligeros, varios módulos relacionables por identificador (cuestionario básico, sociodemográfico, vivienda), varios levantamientos en el tiempo, y datos crudos representativos (categóricas codificadas numéricamente, catálogos en descriptores externos, no respuesta).

Cada sesión cierra con un bloque de práctica sobre la ENSU que continúa el del bloque anterior: importación (S2) → verbos (S3) → ETL con joins y limpieza de texto (S4) → refactor en funciones (S5) → consolidación con `map()` y gráficas (S6).

## Proyecto integrador (curso 2)

- **Anuncio:** al inicio del curso 2.
- **Pipeline:** input → limpieza → modelado → producto.
- **Checkpoints** alineados con las partes del curso 2.

> **Pendiente:** definir estructura, dataset y entregables una vez que se defina el temario del curso 2.

---

## Restricciones explícitas (decisiones tomadas)

Estas decisiones se tomaron y deben respetarse:

- **NO** incluir Quarto ni RMarkdown.
- **NO** incluir `data.table` como tema dedicado (mención en passing máximo en la Sesión 4).
- **Series de tiempo** solo a nivel programático, NO comprensivo (en S11 junto con modelado). Sin mención a `forecast` ni `fable`.
- **officer+googledrive+gmailr**, **Shiny**, y **LLMs** cada uno como sesión individual.
- **Modelado de inferencia**: enfoque estrictamente programático — cómo se especifican fórmulas, cómo se extraen coeficientes, cómo se reportan resultados. La teoría estadística la ven en Econometría.
- **Política sobre LLMs:** se introduce explícitamente en la Sesión 1. La visión es que **depender mal de un LLM atrofia la capacidad individual**, pero usado **como agente integrado al proyecto** (Claude Code de Anthropic, Codex de OpenAI) puede acelerar el trabajo. **No permitido** en los ejercicios de clase del curso 1 (que no tiene proyecto); permitido en el proyecto integrador del curso 2. El estudiante debe poder leer y modificar cualquier línea que entregue.

---

## Convenciones de lenguaje y tono

Estas convenciones aplican a TODO el contenido generado: temario, slides, materiales.

### Registro

**Impersonal académico.** Nunca segunda persona ("tú"), nunca primera persona del plural didáctica ("vamos a ver"). Nunca "el profesor". Construir las oraciones con el curso o la semana como sujeto:

- ✓ "El curso introduce...", "Esta semana corresponde a...", "La sesión cierra con..."
- ✗ "Esta semana vamos a ver...", "El profesor presenta...", "Aprenderemos..."

### Densidad

**Legible en diagonal.** Los párrafos de introducción a cada sección o semana deben ser cortos (1–2 oraciones máximo). Si algo es enumerable, va en bullets. Los bullets no explican lo que ya dice el título.

### Referencias bibliográficas

**Concentradas en el bloque "Lecturas"** al final de cada semana o sesión. Nunca referencias inline en el cuerpo del texto (`\cite{}` solo dentro del bloque de lecturas en el `.tex`; ningún "como señala Wickham (2019)..." en el cuerpo).

### Terminología

- *"datos"* como término genérico, NO *"microdatos"* salvo contexto de encuesta (ENSU, ENIGH).
- **Banco de México** (forma extendida) o **BANXICO** (versalitas), NO "Banxico" coloquial.
- *"regresión lineal univariable"* cuando se mencione el prerrequisito.
- *"los estudiantes"* (no "el equipo") en contextos pedagógicos.
- *"sistema/vocabulario consistente"* en vez de "API consistente" al hablar de tidyverse al estudiante.
- **El Colegio de México** explícitamente cuando aplique.

### Vínculo con el hilo conductor

- Los subtemas y objetivos NO mencionan la ENSU. La narrativa del contenido usa formulaciones genéricas ("el proyecto en el que se trabaje", "un pipeline ETL").
- La ENSU aparece únicamente en el bloque `\practica{}` de cada sesión y en la sección del hilo conductor.
- Nunca "Checkpoint N" en el curso 1: esa figura pertenece al curso 2.

### Recortes preferidos

- Evitar adjetivos calificadores fuertes redundantes ("invaluable", "fundamental" en exceso).
- Eliminar frases de dramatización: "anti-patrón clásico", "fuente #1 de bugs", "trampa común", "semana bisagra".
- Eliminar frases de IA evidentes: "el corazón de", "no se trata de... sino de...", "cubrimos".

---

## Materiales por sesión

Artefactos que se producen para cada sesión:

- **Presentación Slidev** (`slides/semana_NN/`) — usada en clase, distribuida a estudiantes como sitio estático en GitHub Pages. La numeración de directorios (`semana_NN`) se conserva por compatibilidad; `semana_01` corresponde a la Sesión 1.
- **Script de la sesión** (`slides/semana_NN/code/sesion_NN.R`) — ver sección *Scripts de sesión*.
- **Lecture notes para estudiantes** — documento detallado en Markdown, render a PDF con Quarto. **Pendiente; se aborda al final del curso una vez consolidadas las presentaciones.**

---

## Scripts de sesión

Cada sesión tiene un `.R` narrado que sirve como guion de clase. Existe en dos versiones y **una sola fuente**:

| Ruta | Versión | Uso |
|---|---|---|
| `slides/semana_NN/code/sesion_NN.R` | Instructor — completa | Fuente. Se lee desde el iPad para guiar la clase. |
| `code/pre/sesion_NN.R` | Estudiante — esqueleto | **Derivada. Nunca editar a mano.** |

`code/` en la raíz es el proyecto R que reciben los estudiantes: `curso-ppd.Rproj`, `README.md` y la estructura `files/` `docs/` `pre/` `output/` que enseña la Sesión 1. Los datos de la ENSU van en `code/files/` y **los coloca el profesor** (no están versionados).

### Marcas de derivación

Son comentarios válidos de R, así que el script del instructor corre tal cual:

```r
#| ejercicio          El bloque se sustituye por "# (escribe el código aquí)"
mean(edad >= 18)      más un hueco en blanco. El comentario que antecede al
#| fin                bloque queda como consigna del ejercicio.

#| nota               El bloque desaparece por completo de la versión de
# Recordar preguntar  estudiante. Para apuntes de clase, tiempos y énfasis.
#| fin
```

### Build

```bash
python3 scripts/build-code.py          # deriva code/pre/*.R desde slides/semana_*/code/
python3 scripts/build-code.py --zip    # además empaqueta build/curso-ppd.zip
```

`build/` está en `.gitignore`. `code/pre/*.R` sí se versiona (es el distribuible).

**Estilo de los scripts.** Seguir `sesion_01.R`: encabezado con bloque de guiones bajos, sección `# PREAMBULO`, sección `# CODIGO`, jerarquía `# NIVEL 1 ___`, `## Nivel 2 ---=`, `### Nivel 3 ----`. Asignación con `=` (no `<-`), indentación de 4 espacios. El comentario antecede al código y explica el porqué, no el qué.

**No hay documento separado de notas del instructor.** El deck Slidev es la única referencia del instructor. Si se necesita contenido visible solo para el instructor, se usa el mecanismo nativo de Slidev (`instructor: true` en el frontmatter del slide, o bloques `<!-- instructor-only --> ... <!-- /instructor-only -->`). No se mantiene ningún `doc-instructor.md` ni archivo paralelo.

---

## Temario (syllabus)

Un directorio por curso, cada uno con dos versiones del temario:

```
syllabus/
├── bibliography.bib            (compartida por ambos cursos)
├── derivar-sucinto.py          (deriva el sucinto del completo)
├── curso-1/
│   ├── temario-completo/syllabus.tex
│   └── temario-sucinto/temario-sucinto.tex
└── curso-2/                    (temario de 16 semanas original — fuente por rehacer)
    ├── temario-completo/syllabus.tex
    └── temario-sucinto/temario-sucinto.tex
```

| Versión | Contenido |
|---|---|
| `temario-completo/syllabus.tex` | Párrafos intro + subtemas + bloque de práctica + objetivos + lecturas + cheatsheets |
| `temario-sucinto/temario-sucinto.tex` | Solo objetivos y lecturas por sesión; secciones globales idénticas al completo |

La bibliografía se referencia como `../../bibliography.bib` desde cada subdirectorio.

**Título del temario sucinto:** *Temario sucinto: objetivos y lecturas por sesión*.

**Derivación del sucinto:** `python3 syllabus/derivar-sucinto.py curso-1`. El script elimina, de cada sesión, todo lo que va entre la línea `\sesion{N}{...}` y `\noindent\textbf{Objetivos de aprendizaje}` (párrafo intro, subtemas y bloque de práctica), conservando intactas todas las secciones globales. **Nunca editar el sucinto a mano**: se regenera desde el completo.

**Compilación:** `latexmk -pdf` desde el directorio del `.tex` (requiere `biber`).

**Comandos LaTeX custom en `syllabus.tex` (curso 1):**
- `\bloqueCurso{título}` — divisor de bloque (fuerza `\clearpage`)
- `\sesion{N}{título}` — encabezado de sesión
- `\practica{texto}` — bloque de práctica al cierre de la sesión
- `\cheatsheet{slug}{título}` — enlace a cheatsheet de Posit
- `\blue{texto}`, `\orange{texto}`, `\green{texto}` — texto en color institucional

> El `.tex` de `curso-2/` sigue usando `\semana{N}{título}` y `\parteCurso{}`: es el documento de 16 semanas sin modificar, del cual se derivará el temario del curso 2.

---

## Slides (Slidev)

Stack: [Slidev](https://sli.dev) con tema custom Colmex en `slides/_theme/`.

### Estructura de directorios

```
slides/
├── _theme/
│   ├── layouts/
│   │   ├── cover.vue        # Portada del deck
│   │   └── default.vue      # Layout principal con footer y logo
│   ├── components/
│   │   ├── Block.vue        # Bloque genérico (fragmento/ejemplo/ejercicio)
│   │   ├── Ejemplo.vue
│   │   └── Ejercicio.vue
│   ├── scripts/
│   │   └── build-student.mjs  # Elimina slides/bloques instructor-only
│   ├── public/
│   │   ├── colmex-logo.png
│   │   └── section-bg.png
│   └── style.css
├── template/                # Plantilla maestra — copiar para nueva semana
│   ├── slides.md
│   ├── package.json
│   └── vite.config.mjs
├── semana_01/               # Contenido S1 (único deck completo al momento)
│   ├── slides.md
│   ├── package.json         # symlink → ../template/package.json
│   ├── vite.config.mjs      # symlink → ../template/vite.config.mjs
│   ├── layouts/             # symlink → ../_theme/layouts/
│   ├── components/          # symlink → ../_theme/components/
│   ├── public/              # symlink → ../_theme/public/
│   └── style.css            # symlink → ../_theme/style.css
└── README.md                # Setup local + GitHub Pages completo
```

### Arranque de nueva semana

Copiar `template/` a `semana_NN/`, luego crear los symlinks:
```bash
cd slides/semana_NN
ln -s ../template/package.json package.json
ln -s ../template/vite.config.mjs vite.config.mjs
ln -s ../_theme/layouts layouts
ln -s ../_theme/components components
ln -s ../_theme/public public
ln -s ../_theme/style.css style.css
```

### npm scripts (`package.json`)

```json
{
  "dev":           "slidev --open",
  "build":         "slidev build --base ./",
  "preview":       "lsof -ti:4173 2>/dev/null | xargs kill -9 2>/dev/null; python3 -m http.server 4173 --directory dist",
  "export":        "slidev export --output presentacion-instructor.pdf",
  "build:student": "node ../_theme/scripts/build-student.mjs && slidev build slides.student.md --base ./ --out dist-student"
}
```

**`slidev` debe estar instalado globalmente** (`npm install -g @slidev/cli`). No usar `node_modules` local: iCloud Drive corrompe la sincronización de módulos.

**Preview siempre vía HTTP.** `dist/index.html` no funciona con `file://` (ES modules bloqueados). Usar `npm run preview` (python http.server en puerto 4173).

### `vite.config.mjs`

Plain object sin imports (no funciona `import` de vite sin node_modules local):

```js
export default {
  server: { fs: { strict: false, allow: ['..'] } }
}
```

Esto es necesario porque Vite bloquea reads fuera del root del proyecto; los symlinks a `../_theme/` apuntan fuera del directorio de la semana.

### Layouts Vue

Los layouts leen `$frontmatter` directamente (NO `defineProps`, que falla en Slidev 0.49):

- `default.vue` — lee `$frontmatter.instructor`, `$frontmatter.section`, `$frontmatter.subsection`, `$frontmatter.author`. Muestra banner amarillo de rayas cuando `instructor: true`.
- `cover.vue` — lee `$frontmatter.title`, `$frontmatter.subtitle`, etc. No renderiza `<slot />` para evitar duplicar el título.

### CSS y Shiki

El archivo `style.css` en `_theme/` define la paleta Colmex y overrides de tipografía.

**Regla crítica para tamaño de fuente en bloques de código:** Shiki renderiza `<pre><code><span>` con font-size propio en cada hijo. Se requiere el selector triple con `!important`:

```css
.slidev-layout pre,
.slidev-layout pre code,
.slidev-layout pre span {
  font-size: 1em !important;
  line-height: 1.5 !important;
}
```

**Sintaxis de código:** declarar siempre el lenguaje explícitamente (` ```r `, ` ```bash `, ` ```sql `). Shiki usa `github-light`/`github-dark` (declarados en el frontmatter global del deck).

**Evitar `[N:M]` en output de código.** UnoCSS interpreta literales como `[1:2]` como utilidades CSS, causando `SyntaxError`. Reescribir los ejemplos que produzcan esa notación.

### Versión estudiante vs instructor

Mecanismo de filtrado para generar `slides.student.md`:

1. **Slide completo instructor-only:** `instructor: true` en el frontmatter del slide.
2. **Bloque dentro de slide:** `<!-- instructor-only --> ... <!-- /instructor-only -->`.

El script `build-student.mjs` usa `process.cwd()` (no `__dirname`) para resolver paths correctamente desde el directorio de la semana, independientemente de cómo resuelvan los symlinks.

### GitHub Pages

**Implementado** en `.github/workflows/deploy-slides.yml`. La documentación de referencia está en `slides/README.md`. Build target: `slidev build --base /data_projects/semana_NN/`. El workflow corre sobre Node 24 e instala `@slidev/theme-default` vía el `package.json` de la raíz.

---

## Plantilla de presentaciones Beamer (legado)

Plantilla LaTeX/Beamer original. Ya **no se usa para slides** (eso se hace con Slidev). Sirve como referencia de estilo para el tema Colmex.

Ubicación: `muestra_ppt/` — **no modificar**.

**Diseño:**
- Color principal: `#5e002b` (vino, paleta Colmex)
- Idioma: español (`babel`); bibliografía `biblatex` APA

---

## Estructura real de directorios

```
Programming for Data Projects/
├── CLAUDE.md
├── AGENTS.md              (copia idéntica de CLAUDE.md — mantener en sync)
├── package.json           (deps de CI para el build de slides)
├── .github/workflows/
│   └── deploy-slides.yml  (build + deploy a GitHub Pages)
├── syllabus/
│   ├── bibliography.bib
│   ├── derivar-sucinto.py
│   ├── curso-1/           (temario vigente — 6 sesiones)
│   └── curso-2/           (temario de 16 semanas — fuente por rehacer)
├── scripts/
│   └── build-code.py      (deriva los esqueletos de estudiante + arma el zip)
├── code/                  (proyecto R que reciben los estudiantes — DERIVADO)
│   ├── curso-ppd.Rproj
│   ├── README.md
│   ├── files/ docs/ output/
│   └── pre/               (sesion_01.R … sesion_06.R, esqueletos)
├── slides/
│   ├── README.md
│   ├── _theme/            (assets compartidos — layouts, components, CSS, public)
│   ├── template/          (plantilla maestra)
│   ├── semana_01/         (deck de la Sesión 1, único completo al momento)
│   └── semana_02..06/     (solo code/ por ahora; los decks faltan)
├── docs/                  (guías de contenido por tema, insumo para armar decks)
└── muestra_ppt/           (referencia Beamer — no tocar)
```

**`AGENTS.md` es una copia byte a byte de `CLAUDE.md`.** Cualquier edición a uno debe copiarse al otro (`cp CLAUDE.md AGENTS.md`).

---

## Pendientes

**Curso 1 (arranca el 21 de agosto de 2026):**
- [ ] Actualizar el deck `slides/semana_01/` para que cubra el contenido nuevo de la Sesión 1 (Git, GitHub y estructura de carpetas se agregaron desde la antigua S4).
- [ ] Desarrollar slides de las Sesiones 2–6.
- [ ] Desarrollar el contenido de `sesion_02.R` … `sesion_06.R` (hoy solo tienen el esqueleto de secciones con marcas `#| nota` de POR DESARROLLAR).
- [ ] Colocar los archivos de ENSU en `code/files/` antes de armar el zip.
- [ ] Elegir los trimestres concretos de ENSU y descargar los archivos de trabajo.
- [ ] Redactar los enunciados de los 6 ejercicios del bloque de práctica.

**Curso 2:**
- [ ] Definir duración, calendario y estructura de bloques.
- [ ] Reescribir `syllabus/curso-2/` a partir del temario de 16 semanas.
- [ ] Definir dataset y entregables del proyecto integrador.

**Transversal:**
- [ ] Lecture notes (Quarto) — diferido a después de consolidar las presentaciones.
