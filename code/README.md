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

## Los datos

El curso trabaja sobre la **EIGH**, una encuesta simulada de ingreso y gasto de los
hogares. No corresponde a ningún levantamiento real: se generó para que todas las
sesiones operen sobre los mismos datos, con los mismos defectos, sin depender de
una descarga.

| Archivo | Contenido | Formato |
|---|---|---|
| `files/eigh_hogares.csv` | 800 hogares: ingreso, gasto, entidad, integrantes | CSV separado por comas |
| `files/eigh_personas.txt` | 2,606 personas: sexo, edad, escolaridad, ingreso | texto separado por barra vertical |
| `files/eigh_gastos.csv` | 4,418 renglones de gasto por rubro | CSV separado por punto y coma, coma decimal |
| `files/eigh_catalogos.xlsx` | catálogos de entidad y de rubro de gasto | hoja de cálculo |
| `files/eigh_hogares_latin1.csv` | copia del primero, codificada en Latin-1 | CSV |
| `docs/eigh_descriptor.csv` | tipo, descripción y códigos de cada variable | CSV |

Las tres tablas se relacionan por `folioviv`, el folio de la vivienda. El descriptor
es el documento contra el que se verifica cada importación: declara qué tipo tiene
cada variable y qué códigos representan la no respuesta.

## Scripts

Cada sesión de 3:00 h tiene dos bloques, y a cada bloque le corresponde un archivo.

**`pre/ejercicios_NN.R`** — el bloque de práctica. Vienen las consignas y los
huecos marcados `# (escribe el código aquí)`. Es donde trabajas.

**`pre/sesion_NN.R`** — el guion del bloque de exposición: todo el código que se
escribe en el pizarrón durante la clase. Se distribuye al **cierre** de cada
sesión, no antes. La idea es que sigas la exposición mirando y escribiendo, y
que después tengas la referencia correcta sin haber estado copiando a ciegas.

| Sesión | Tema |
|---|---|
| 1 | El lenguaje y el proyecto: R, Positron, Git y GitHub |
| 2 | Estructuras de datos, importación y exploración |
| 3 | dplyr I: pipe, verbos básicos y sistema tidyverse |
| 4 | dplyr II y manejo de texto: joins, pivots y stringr |
| 5 | Control de flujo, vectorización y funciones |
| 6 | Programación funcional y visualización con ggplot2 |

## Requisitos

- R 4.1 o superior (se usa el *pipe* nativo `|>` y la sintaxis `\(x)`).
- Positron, o el IDE de tu preferencia.
