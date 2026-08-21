# Programación para Proyectos de Datos I

Material de trabajo del curso. Abre `curso-ppd.Rproj` antes de ejecutar cualquier
script: el proyecto fija el directorio de trabajo en esta carpeta y todas las
rutas de los scripts son relativas a ella.

## Estructura

| Carpeta | Contenido |
|---|---|
| `files/` | Datos crudos, tal como se descargan. No se modifican nunca. |
| `docs/` | Descriptores técnicos, catálogos y documentación de las fuentes. |
| `pre/` | Los scripts de cada sesión. Aquí se trabaja. |
| `output/` | Todo lo que produce el código: datos procesados, gráficas, reportes. |

La separación no es cosmética. `files/` es insumo y se trata como de solo lectura;
`output/` es desechable y se puede borrar completo, porque el código lo regenera.
Si borrar `output/` rompe algo, el pipeline no es reproducible.

## Scripts

Un script por sesión, en `pre/`. Están comentados y con huecos marcados
`# (escribe el código aquí)`: esos huecos se llenan durante la clase.

Al cierre de cada sesión se distribuye la versión resuelta, `sesion_NN_solucion.R`.
Lleva otro nombre a propósito: se guarda junto al tuyo en `pre/` sin sobrescribir
lo que escribiste. Compara, no reemplaces.

| Script | Sesión |
|---|---|
| `pre/sesion_01.R` | El lenguaje y el proyecto: R, Positron, Git y GitHub |
| `pre/sesion_02.R` | Estructuras de datos, importación y exploración |
| `pre/sesion_03.R` | dplyr I: pipe, verbos básicos y sistema tidyverse |
| `pre/sesion_04.R` | dplyr II y manejo de texto: joins, pivots y stringr |
| `pre/sesion_05.R` | Control de flujo, vectorización y funciones |
| `pre/sesion_06.R` | Programación funcional y visualización con ggplot2 |

## Requisitos

- R 4.1 o superior (se usa el *pipe* nativo `|>` y la sintaxis `\(x)`).
- Positron, o el IDE de tu preferencia.
