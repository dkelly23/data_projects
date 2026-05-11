# Guía de estudio — Semana 14: Automatización con `officer`, `googledrive` y `gmailr`

> **Audiencia:** instructor (Daniel). Esta guía complementa el bloque del syllabus para Semana 14. Está pensada para que llegues a la clase con seguridad sobre el material — no para los estudiantes.

---

## 1. La idea fundacional

La regla mental de la semana es:

> **`template + datos + código = entregable`**

El patrón sustituye un flujo manual ("cada mes alguien actualiza los números en el PPT") por uno donde la presentación se regenera con un *script*, partiendo de un *template* pre-estilizado. Una vez que el template está bien diseñado, las corridas subsecuentes son gratuitas.

**Por qué importa pedagógicamente:**

- El estudiante deja de pensar en el reporte como un objeto manual y empieza a verlo como un *output* del pipeline ---igual que un dataset o una gráfica.
- Cualquier cambio en los datos se refleja automáticamente en el entregable.
- El estilo y la lógica viven separados: el template gestiona la apariencia; el código gestiona los valores.

**Énfasis del curso: PowerPoint, no Word.** En análisis aplicado real, el medio de entrega más común es la presentación de tableros/resultados, no el documento de texto. Por eso esta guía se concentra en PPT; los principios aplican a Word con cambios menores.

---

## 2. `officer` para PowerPoint

### 2.1 El modelo mental

Una presentación con `officer` tiene tres niveles:

1. **El \*template\*** (`.pptx` pre-estilizado): define los *layouts* disponibles, los estilos, las paletas de color, el *master slide*. Se construye en PowerPoint, una vez.
2. **Los \*layouts\***: cada *layout* es una plantilla de diapositiva con *placeholders* nombrados (Título, Contenido, Imagen, etc.). El template define cuáles existen.
3. **El código**: lee el template, agrega diapositivas eligiendo un *layout*, e inyecta contenido en cada *placeholder*.

```r
library(officer)

# 1. Cargar el template estilizado
doc <- read_pptx("templates/marca_corporativa.pptx")

# 2. Agregar una slide eligiendo un layout del master
doc <- add_slide(doc,
                 layout = "Title and Content",
                 master = "Office Theme")

# 3. Inyectar contenido en placeholders nombrados
doc <- ph_with(doc,
               value = "Resultados Q3 2026",
               location = ph_location_type(type = "title"))

doc <- ph_with(doc,
               value = grafica_ggplot,
               location = ph_location_type(type = "body"))

# 4. Exportar
print(doc, target = "output/presentacion.pptx")
```

### 2.2 Inspeccionar el template antes de programar

Antes de escribir código, hay que saber qué layouts y placeholders tiene el template:

```r
doc <- read_pptx("templates/marca_corporativa.pptx")

# ¿Qué layouts existen?
layout_summary(doc)

# ¿Qué placeholders tiene un layout específico?
layout_properties(doc, layout = "Title and Content")
```

`layout_summary()` devuelve un *tibble* con todos los layouts disponibles. `layout_properties()` devuelve los placeholders (sus tipos, nombres, posiciones) de un layout particular.

### 2.3 Tipos de `ph_with` (inyectar contenido)

| Contenido | Cómo |
|---|---|
| Texto plano | `ph_with(doc, "texto", location = ph_location_type("title"))` |
| Texto enriquecido | `ph_with(doc, fpar(...), location = ...)` |
| Gráfica ggplot | `ph_with(doc, plot_ggplot, location = ...)` |
| Imagen desde archivo | `ph_with(doc, external_img("ruta.png"), location = ...)` |
| Tabla simple | `ph_with(doc, data_frame, location = ...)` |
| Tabla con formato | `ph_with(doc, flextable_object, location = ...)` |

### 2.4 Iteración sobre múltiples diapositivas

El patrón más común: una slide por grupo (estado, trimestre, indicador).

```r
library(purrr)

estados <- c("CDMX", "Jalisco", "Nuevo León")

doc <- read_pptx("templates/template.pptx")

doc <- reduce(estados, function(d, estado) {
  d |>
    add_slide(layout = "Title and Content", master = "Office Theme") |>
    ph_with(value = paste("Resultados:", estado),
            location = ph_location_type("title")) |>
    ph_with(value = grafica_para(estado),
            location = ph_location_type("body"))
}, .init = doc)

print(doc, target = "output/reporte_estados.pptx")
```

Esto encadena los patrones de S10 (`purrr::reduce`) con `officer`. Una presentación con 32 slides (una por estado) se genera con el mismo código que una con 3.

### 2.5 Localizaciones (`ph_location_*`)

`ph_with` necesita saber dónde meter el contenido. Hay varias formas:

```r
# Por tipo de placeholder (lo más común y robusto)
location = ph_location_type(type = "title")
location = ph_location_type(type = "body")

# Por etiqueta del placeholder (requiere conocer el template)
location = ph_location_label(ph_label = "Content Placeholder 2")

# Por posición absoluta (last resort)
location = ph_location(left = 1, top = 1, width = 8, height = 5)
```

**Recomendación:** usar `ph_location_type()` siempre que se pueda. Es lo más portable entre templates.

---

## 3. Estilización fina

Aquí es donde la presentación pasa de funcional a publicable.

### 3.1 Texto enriquecido con `fp_text` y `fpar`

```r
library(officer)

# Definir un estilo de texto reutilizable
estilo_titulo <- fp_text(font.size = 24, bold = TRUE,
                         color = "#5E002B", font.family = "Calibri")

estilo_destacado <- fp_text(font.size = 14, bold = TRUE,
                            color = "#D24D31")

estilo_normal <- fp_text(font.size = 14, color = "grey20")

# Componer un párrafo con texto mezclado
parrafo <- fpar(
  ftext("El crecimiento fue de ", prop = estilo_normal),
  ftext("12.3%", prop = estilo_destacado),
  ftext(" comparado con el trimestre anterior.", prop = estilo_normal)
)

doc <- ph_with(doc, value = parrafo, location = ph_location_type("body"))
```

`fp_text()` define un estilo; `ftext()` aplica un estilo a un fragmento de texto; `fpar()` compone fragmentos en un párrafo. La idea es la misma que en CSS: definir clases reutilizables y aplicarlas selectivamente.

### 3.2 Párrafos: `fp_par`

```r
estilo_parrafo <- fp_par(text.align = "center",
                        padding.bottom = 10,
                        padding.top = 10)

parrafo <- fpar(ftext("Centrado", prop = estilo_titulo),
                fp_p = estilo_parrafo)
```

### 3.3 Bloques de varios párrafos con `block_list`

```r
contenido <- block_list(
  fpar(ftext("Punto 1", prop = estilo_destacado)),
  fpar(ftext("Punto 2", prop = estilo_destacado)),
  fpar(ftext("Punto 3", prop = estilo_destacado))
)

doc <- ph_with(doc, value = contenido, location = ph_location_type("body"))
```

### 3.4 Imágenes con dimensiones controladas

```r
doc <- ph_with(doc,
               value = external_img("output/grafica.png",
                                    width = 8, height = 5),
               location = ph_location(left = 1, top = 1.5,
                                      width = 8, height = 5))
```

Las dimensiones de `external_img()` y de `ph_location()` deben coincidir o la imagen se distorsiona. Es el error más frecuente al insertar imágenes.

### 3.5 La consigna pedagógica

> **Todo el estilo vive en el template y en el código de `officer`. No se "arregla" en PowerPoint a mano después.**

Esta consigna es el núcleo de la semana. Cada vez que un estudiante "ajusta visualmente" en PowerPoint después de generar el archivo, está rompiendo el flujo: la siguiente corrida no tendrá ese ajuste y el problema regresa.

Si algo no se ve bien:
- ¿El template tiene los estilos correctos? → editar el template.
- ¿El código está usando los estilos correctos? → editar el código.
- ¿Las dimensiones de la imagen / tabla no son las correctas? → editar las dimensiones en el código.

Nunca: "lo arreglo cada vez en PPT manualmente".

---

## 4. `flextable` para tablas en PPT

`flextable` es el compañero natural de `officer` cuando se trata de tablas.

### 4.1 Construcción básica

```r
library(flextable)

ft <- flextable(head(mtcars[, 1:4], 5))

# Insertar en una slide
doc <- ph_with(doc, value = ft, location = ph_location_type("body"))
```

### 4.2 Themes predefinidos

```r
ft <- flextable(df) |>
  theme_vanilla()    # Limpio, profesional, default recomendado

ft <- flextable(df) |>
  theme_box()        # Con bordes completos

ft <- flextable(df) |>
  theme_zebra()      # Filas alternadas
```

### 4.3 Customización fina

```r
ft <- flextable(df) |>
  # Formato numérico por columna
  colformat_double(j = "porcentaje", suffix = "%", digits = 1) |>
  colformat_double(j = "monto", prefix = "$", big.mark = ",") |>

  # Headers
  set_header_labels(values = list(
    porcentaje = "Cambio (%)",
    monto = "Monto (MXN)"
  )) |>

  # Colores y formato
  bg(part = "header", bg = "#5E002B") |>
  color(part = "header", color = "white") |>
  bold(part = "header") |>

  # Alineación
  align(j = c("porcentaje", "monto"), align = "right") |>

  # Anchos
  width(j = "estado", width = 1.5) |>
  width(j = c("porcentaje", "monto"), width = 1)
```

### 4.4 Merge de celdas y headers compuestos

```r
ft <- flextable(df) |>
  merge_v(j = "region") |>        # Merge vertical de celdas iguales
  add_header_row(
    values = c("", "Indicadores 2025", "Indicadores 2026"),
    colwidths = c(1, 3, 3)         # 1 columna sola + 3 + 3
  )
```

### 4.5 Patrón típico: función helper

```r
make_table <- function(df) {
  flextable(df) |>
    theme_vanilla() |>
    colformat_double(digits = 1) |>
    bold(part = "header") |>
    bg(part = "header", bg = "#5E002B") |>
    color(part = "header", color = "white") |>
    autofit()
}

# Reutilizar en todas las tablas del reporte
ft1 <- make_table(datos_q1)
ft2 <- make_table(datos_q2)
```

Esta abstracción mantiene consistencia visual entre tablas y reduce código repetido.

---

## 5. `googledrive`: autenticación y gestión de archivos

### 5.1 Autenticación

```r
library(googledrive)

# OAuth interactivo: abre navegador, pide login, guarda token local.
# Para desarrollo.
drive_auth()

# Service Account: usa una credencial JSON descargada de Google Cloud Console.
# Para automatización (cron, scheduled scripts, servers).
drive_auth(path = "credenciales/service_account.json")

# Email específico (útil cuando hay múltiples cuentas)
drive_auth(email = "trabajo@dominio.com")
```

**Service Account vs OAuth:**

| Aspecto | OAuth interactivo | Service Account |
|---|---|---|
| Requiere humano | Sí (al login inicial) | No |
| Para | Desarrollo, exploración | Producción, automatización |
| Setup | Trivial | Crear proyecto en Google Cloud, descargar JSON |
| Acceso a archivos | Los del usuario logueado | Los compartidos con el service account |

**Para el curso:** OAuth es suficiente para que los estudiantes prueben. Mencionar Service Account como la versión "real" sin obligar a configurarla.

### 5.2 Gestión de archivos (el corazón de la semana)

```r
# Listar contenido de una carpeta
drive_ls(as_id("1abc...XYZ"))    # por ID
drive_ls("Reportes Q3/")          # por path

# Obtener un archivo específico
archivo <- drive_get("reporte_2026.pptx")

# Descargar
drive_download(file = archivo,
               path = "files/reporte_2026.pptx",
               overwrite = TRUE)

# Subir
drive_upload(media = "output/presentacion.pptx",
             path = "Reportes Q3/",
             name = "presentacion_q3_2026.pptx",
             overwrite = TRUE)

# Compartir
drive_share(file = archivo,
            role = "reader",
            type = "user",
            emailAddress = "colega@empresa.com")

# Mover
drive_mv(file = archivo, path = "Archivo histórico/")

# Eliminar (a papelera)
drive_trash(file = archivo)
```

### 5.3 El patrón "buzón"

Aquí es donde Drive se vuelve una pieza de automatización real:

```r
# CARPETA DE INSUMOS — el equipo deposita archivos ahí
insumos <- drive_ls(as_id("1insumos..."), pattern = "\\.csv$")

# Descargar todos al disco local
walk(insumos$id,
     \(id) drive_download(as_id(id),
                          path = file.path("files", drive_get(as_id(id))$name),
                          overwrite = TRUE))

# ... procesar con el pipeline ETL ...

# CARPETA DE OUTPUTS — el reporte se sube ahí
drive_upload(media = "output/reporte.pptx",
             path = as_id("1outputs..."),
             name = paste0("reporte_", Sys.Date(), ".pptx"),
             overwrite = FALSE)  # FALSE preserva versiones
```

**Por qué este patrón es valioso:**

- El equipo no toca el código. Solo arrastra archivos a carpetas conocidas.
- El script no tiene que saber paths del equipo. Solo conoce dos IDs de carpeta.
- Las versiones quedan automáticas (cada corrida sube un archivo con fecha).
- Drive maneja permisos: nada se pierde, todo es auditable.

Esto es "low-code" en el sentido relevante: una solución de automatización donde la **interfaz** con el equipo es algo que ya saben usar (Drive), no algo nuevo (un sistema custom, un panel, una CLI).

---

## 6. `gmailr`: correo como canal de automatización

`gmailr` aplica la misma filosofía que `googledrive`, pero sobre Gmail.

### 6.1 Autenticación

```r
library(gmailr)

# OAuth interactivo: igual que con googledrive
gm_auth_configure(path = "credenciales/oauth_client.json")
gm_auth()

# Service Account: análogo
gm_auth(path = "credenciales/service_account.json")
```

### 6.2 Envío de correo programático

```r
# Componer
correo <- gm_mime() |>
  gm_to("equipo@empresa.com") |>
  gm_cc("supervisor@empresa.com") |>
  gm_from("scripts@empresa.com") |>
  gm_subject(paste0("Reporte automatizado ", Sys.Date())) |>
  gm_html_body(
    "<p>Hola equipo,</p>
     <p>Adjunto el reporte de este ciclo. Cualquier comentario me avisan.</p>
     <p>Saludos.</p>"
  ) |>
  gm_attach_file("output/presentacion.pptx")

# Enviar
gm_send_message(correo)
```

`gm_mime()` construye un mensaje encadenable. `gm_html_body()` permite formato HTML (negritas, listas, enlaces). `gm_attach_file()` añade adjuntos.

### 6.3 Lectura de correo como buzón de entrada

Esta es la pieza menos obvia pero más potente: usar el correo como fuente de datos.

```r
# Buscar mensajes con un filtro tipo Gmail
mensajes <- gm_messages(
  search = "from:proveedor@empresa.com subject:'datos mensuales' has:attachment"
)

# Obtener detalles de uno específico
msg <- gm_message(mensajes$messages[[1]]$id)

# Listar los adjuntos
gm_attachments(msg)

# Guardar todos los adjuntos al disco
gm_save_attachments(msg, path = "files/")
```

**Sintaxis de búsqueda:** es la misma que en la barra de búsqueda de Gmail (`from:`, `subject:`, `has:`, `before:`, `after:`, `is:unread`, etc.). Toda la potencia del buscador de Gmail es accesible desde R.

### 6.4 El patrón "buzón Gmail"

```r
# Lectura periódica de un buzón específico
mensajes_nuevos <- gm_messages(
  search = "from:proveedor@empresa.com is:unread has:attachment"
)

# Descargar adjuntos de todos los nuevos
walk(mensajes_nuevos$messages, function(m) {
  msg <- gm_message(m$id)
  gm_save_attachments(msg, path = "files/inbox/")
  # Marcar como leído para no procesarlo dos veces
  gm_message_modify(m$id, remove_labels = "UNREAD")
})

# ... pipeline ETL toma archivos de files/inbox/ ...

# Enviar resultado
gm_mime() |>
  gm_to("equipo@empresa.com") |>
  gm_subject("Reporte procesado") |>
  gm_text_body("Adjunto el reporte generado a partir de los insumos recibidos.") |>
  gm_attach_file("output/reporte.pptx") |>
  gm_send_message()
```

**Por qué este patrón funciona:**

- El equipo no necesita aprender nada nuevo. Saben mandar correos.
- El script habla con un servicio que el equipo ya usa diariamente.
- Las versiones quedan en el historial de Gmail (no se pierde nada).
- Los filtros de Gmail son extremadamente expresivos.

### 6.5 Cuándo Drive y cuándo Gmail

| Necesidad | Mejor herramienta |
|---|---|
| Archivos grandes (>10 MB) | Drive |
| Histórico de cambios | Drive (versiones nativas) |
| Notificar a stakeholders cuando hay output nuevo | Gmail |
| Distribuir reporte a lista de destinatarios | Gmail |
| Buzón asíncrono donde "depositan" archivos | Cualquiera (preferencia del equipo) |
| Colaboración (varios editan el mismo archivo) | Drive |
| Trigger basado en evento específico (correo recibido) | Gmail |

En la práctica los dos se usan juntos: el equipo manda por Gmail con adjunto, el script guarda en Drive para versionado, procesa, y manda por Gmail al equipo el resultado.

---

## 7. Integración al pipeline + manejo de secretos

### 7.1 El paso final del `master.R`

```r
# pre/master.R

# ETL
source("pre/01-extract.R")
source("pre/02-transform.R")
source("pre/03-load.R")

# Análisis
source("pre/04-analisis.R")

# Generación de outputs (gráficas → output/)
source("pre/05-graficas.R")

# Reporte (NUEVO en S14)
source("pre/06-presentacion.R")

# Distribución (NUEVO en S14)
source("pre/07-distribucion.R")  # sube a Drive y manda por Gmail
```

Esta secuencia sigue el patrón heredado de proyectos profesionales: un *master script* que orquesta scripts numerados, cada uno con una responsabilidad clara. La diferencia de S14 es agregar los pasos de producto y distribución.

### 7.2 Estructura de directorios sugerida

```
proyecto/
├── pre/
│   ├── master.R
│   ├── 01-extract.R
│   ├── 02-transform.R
│   ├── 03-load.R
│   ├── 04-analisis.R
│   ├── 05-graficas.R
│   ├── 06-presentacion.R     ← officer
│   └── 07-distribucion.R     ← googledrive + gmailr
├── templates/
│   └── presentacion.pptx     ← template estilizado, versionado
├── credenciales/
│   ├── service_account.json  ← gitignored
│   └── oauth_client.json     ← gitignored
├── files/                    ← insumos descargados, gitignored
└── output/
    ├── grafica_q1.png
    ├── presentacion.pptx
    └── ...
```

### 7.3 Manejo de secretos

```r
# .gitignore
credenciales/
*.json
.env

# .env (cargar con dotenv::load_dot_env() o readRenviron(".env"))
DRIVE_FOLDER_INSUMOS=1abc...
DRIVE_FOLDER_OUTPUTS=1def...
GMAIL_DESTINATARIOS=equipo@empresa.com,supervisor@empresa.com
```

```r
# En el código
folder_insumos <- Sys.getenv("DRIVE_FOLDER_INSUMOS")
destinatarios <- strsplit(Sys.getenv("GMAIL_DESTINATARIOS"), ",")[[1]]
```

Los IDs de carpeta y emails específicos son sensibles (revelan estructura interna del equipo). El JSON de Service Account es **muy** sensible (permite hacerse pasar por la cuenta). Ambos viven fuera del repo.

---

## 8. Anti-patrones comunes

1. **Construir el PPT desde cero sin template.** Funciona pero pierde el estilo corporativo, las paletas, los layouts. Siempre partir de un `.pptx` con styles.
2. **Arreglar el output a mano en PowerPoint después de generarlo.** Rompe el flujo: la siguiente corrida no tendrá el ajuste. El estilo vive en el template + código, no en el archivo generado.
3. **Hardcodear paths absolutos.** El script se rompe si se mueve a otra máquina. Usar paths relativos al proyecto (S4).
4. **Commitear el JSON del Service Account.** Pasa una vez y es un compromiso de seguridad. Ya en el `.gitignore` desde el día uno.
5. **Re-autenticar OAuth en cada corrida.** OAuth guarda el token en cache local; debe persistir entre corridas. Si se está pidiendo cada vez, hay algo mal en el setup.
6. **Iterar adjuntos uno por uno con un loop manual.** Mejor `purrr::walk` (S10) — encadena natural.
7. **Dimensiones de imagen y placeholder desacopladas.** Si `external_img(width=8, height=5)` y `ph_location(width=6, height=5)`, la imagen se distorsiona. Mantener sincronizado.

---

## 9. Tabla decisión rápida

| Quieres... | Usa |
|---|---|
| Generar una presentación con datos del análisis | `officer::read_pptx() + ph_with()` |
| Aplicar estilos consistentes | Template `.pptx` con styles, no ajuste manual |
| Texto con negrita/color/tamaño mezclados | `fp_text() + ftext() + fpar()` |
| Una tabla profesional dentro del PPT | `flextable` con theme |
| Insertar una gráfica ggplot | `ph_with(value = gg, location = ph_location_type("body"))` |
| Iterar sobre N grupos generando N slides | `purrr::reduce()` sobre `add_slide |> ph_with` |
| Descargar archivos compartidos | `googledrive::drive_download()` |
| Subir el reporte generado | `googledrive::drive_upload()` |
| Notificar al equipo con el reporte adjunto | `gmailr::gm_mime() |> gm_attach_file() |> gm_send_message()` |
| Leer una bandeja de correos como input | `gmailr::gm_messages(search = "...")` |
| Extraer adjuntos de un correo | `gm_attachments() + gm_save_attachments()` |
| Auth para desarrollo | OAuth (`drive_auth()`, `gm_auth()`) |
| Auth para producción | Service Account (`*_auth(path = "service_account.json")`) |
| Manejar secretos | `.env` + `Sys.getenv()`; JSONs en `credenciales/`, `.gitignore`-ed |

---

## 10. Lecturas y orden recomendado

**Para preparar la clase:**

1. **`officer` — vignette "Get started with PowerPoint"** — `https://davidgohel.github.io/officer/articles/powerpoint.html`
2. **`officer` — vignette "Layouts and slide manipulation"** — para entender `ph_with` y `ph_location_*`
3. **`flextable` — Quick start** — `https://davidgohel.github.io/flextable/`
4. **`googledrive` — vignettes "Authentication" y referencia de `drive_*`** — `https://googledrive.tidyverse.org/`
5. **`gmailr` — vignettes "Sending email" y "Working with messages"** — `https://gmailr.r-lib.org/`

**Para profundizar (opcional):**

- *Officeverse book*: `https://ardata-fr.github.io/officeverse/` — referencia comprehensiva de la familia officer + flextable.
- Documentación oficial de la Gmail API (sintaxis de search): `https://support.google.com/mail/answer/7190`

---

## 11. Nota final: por qué este tema importa

`officer` + `googledrive` + `gmailr` son el set que convierte un proyecto de datos académico en algo que *sirve*. Sin esta semana, el proyecto integrador termina con un script que produce gráficas — útiles, pero estáticas, que dependen de alguien que las recolecte y comunique.

Con esta semana, el proyecto integrador termina con un **flujo**: los datos entran (Drive/Gmail), se procesan, el reporte se genera (officer), y se distribuye (Drive/Gmail). Cuando llegan nuevos datos, el ciclo se repite sin intervención manual.

Tres mensajes que vale la pena llevarse a clase:

1. **Template + datos + código = entregable.** El template aísla el estilo; el código aísla la lógica.
2. **Todo el estilo vive en el template y en el código de `officer`.** Nunca se "arregla" a mano en PowerPoint.
3. **Drive y Gmail son interfaces low-code de automatización.** Su valor no está en la API, sino en que el equipo ya sabe usarlas. Eso elimina la fricción más cara: convencer a la gente de aprender una herramienta nueva.

El estudiante que se lleva esto a casa sabe diseñar canales de automatización que las personas no técnicas pueden adoptar sin entrenamiento. Esa habilidad es rara y tiene un valor desproporcionado en cualquier organización.
