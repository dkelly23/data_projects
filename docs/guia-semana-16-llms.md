# Guía de estudio — Semana 16: Interfaces de modelos de lenguaje

> **Audiencia:** instructor (Daniel). Esta guía complementa el bloque del syllabus para Semana 16. Está pensada para que llegues a la clase con seguridad sobre el material — no para los estudiantes.

---

## 0. Nota pedagógica

Esta semana cierra el curso. El estudiante llega habiendo construido un pipeline completo: ETL, análisis, modelado, productos. La pregunta que abre esta semana es: **¿dónde encajan los LLMs dentro de ese pipeline?**

La trampa pedagógica más grande es enseñar LLMs como tema deslumbrante en sí mismo ("mira lo que puede hacer un modelo"). La alternativa correcta es enseñarlos como **una función más del pipeline**: una transformación texto-a-dato que se llama desde R, devuelve un resultado utilizable, y se ejecuta automáticamente en cada corrida.

Tres mensajes que vale la pena llevarse a clase:

1. **Un LLM en el pipeline es una función, no una conversación.** Entra texto, sale dato. Sin humanos en el loop.
2. **Las salidas estructuradas son la diferencia entre "LLM como juguete" y "LLM como herramienta".** Si la salida no se parsea directo al dataframe, el LLM no encaja en el pipeline.
3. **Si una expresión regular resuelve el problema, no uses un LLM.** Los LLMs son caros, lentos, y no-determinísticos. Son el último recurso, no el primero.

---

## 1. La idea fundacional: LLM como función dentro del pipeline

### 1.1 El patrón roto

```
Analista lee párrafo no estructurado
  → abre pestaña de ChatGPT/Claude/Gemini
  → pega el párrafo
  → escribe "extrae nombre, fecha, monto"
  → copia la respuesta
  → pega al Excel
  → cierra la pestaña
```

Problemas:
- No reproducible (¿qué prompt usaste exactamente?)
- No escala (1 fila a la vez, manual)
- No auditable (no queda registro de qué pidió/obtuvo)
- Rompe el flujo (la herramienta vive afuera del código)
- No mejora (cada fila requiere intervención humana)

### 1.2 El patrón integrado

```r
extraer_campos <- function(texto) {
  chat <- chat_anthropic(model = "claude-sonnet-4-5",
                          system_prompt = "Eres un extractor estructurado...")
  chat$chat_structured(texto, type = schema_campos)
}

datos_estructurados <- df_textos |>
  mutate(extraido = map(parrafo, extraer_campos)) |>
  unnest_wider(extraido)
```

Ventajas:
- **Reproducible**: el prompt y el modelo viven en código.
- **Escalable**: `purrr::map` itera sobre N filas.
- **Auditable**: el código documenta exactamente qué pidió.
- **Integrado**: la salida es un tibble listo para el siguiente paso.
- **Iterable**: cambiar el prompt o el modelo es editar una línea.

Esa es la transformación conceptual de la semana.

---

## 2. Forma manual: `httr2` contra una API LLM

Antes de subir al nivel de `ellmer`, vale la pena que el estudiante vea qué hay debajo. Es la versión "explícita y verbosa" del mismo flujo.

### 2.1 Anatomía de un request a Anthropic con `httr2`

```r
library(httr2)

api_key <- Sys.getenv("ANTHROPIC_API_KEY")

response <- request("https://api.anthropic.com/v1/messages") |>
  req_headers(
    `x-api-key` = api_key,
    `anthropic-version` = "2023-06-01",
    `content-type` = "application/json"
  ) |>
  req_body_json(list(
    model = "claude-sonnet-4-5",
    max_tokens = 1024,
    messages = list(
      list(role = "user",
           content = "¿Qué es una encuesta de hogares?")
    )
  )) |>
  req_perform()

# Parsear la respuesta
resultado <- response |>
  resp_body_json()

# Extraer el texto
texto_respuesta <- resultado$content[[1]]$text
```

Esto es **explícito**: ves la URL exacta, los headers, el body, el parsing. Es la versión "no hay magia" del flujo.

### 2.2 Anatomía análoga para OpenAI

```r
response <- request("https://api.openai.com/v1/chat/completions") |>
  req_headers(
    Authorization = paste("Bearer", Sys.getenv("OPENAI_API_KEY"))
  ) |>
  req_body_json(list(
    model = "gpt-4o",
    messages = list(
      list(role = "user", content = "Hola")
    )
  )) |>
  req_perform() |>
  resp_body_json()

texto <- response$choices[[1]]$message$content
```

Estructura distinta de la de Anthropic. Cada proveedor inventó su forma. Esto motiva `ellmer`.

### 2.3 Ventajas y desventajas de la forma manual

**Ventajas:**
- Control total sobre cada parámetro.
- Sin dependencias adicionales (solo `httr2`).
- Transparente: ves exactamente qué se manda.
- Útil para enseñar.

**Desventajas:**
- Verboso (~15 líneas para una llamada simple).
- API distinta por proveedor (Anthropic vs OpenAI vs Google).
- Manejo de errores manual.
- Sin streaming (la respuesta llega entera al final).
- Sin abstracción para conversaciones multi-turno.

### 2.4 Cuándo enseñar `httr2` para LLMs

Una vez. Para que el estudiante entienda que detrás de `ellmer` hay un POST de HTTP. Después, prácticamente siempre conviene `ellmer`.

---

## 3. Forma amigable: `ellmer`

`ellmer` es el paquete de Posit (Hadley Wickham et al.) que abstrae las APIs de LLM en una interfaz consistente.

### 3.1 La estructura básica

```r
library(ellmer)

# Crear un objeto chat
chat <- chat_anthropic(
  model = "claude-sonnet-4-5",
  system_prompt = "Eres un asistente que responde brevemente."
)

# Hacer una llamada
respuesta <- chat$chat("¿Qué es una encuesta de hogares?")
# Devuelve el texto directamente.
```

Tres líneas vs. ~15. Esa es la victoria.

### 3.2 Portabilidad entre proveedores

```r
# Cambiar de proveedor es cambiar la función de inicialización.
chat <- chat_anthropic(model = "claude-sonnet-4-5")
chat <- chat_openai(model = "gpt-4o")
chat <- chat_google_gemini(model = "gemini-2.0-flash")
chat <- chat_groq(model = "llama-3.3-70b-versatile")
chat <- chat_ollama(model = "llama3.1")    # local

# El resto del código no cambia
respuesta <- chat$chat("Mismo input")
```

Esto es transformacional para el flujo: experimentar con varios modelos sin reescribir nada.

### 3.3 Conversaciones multi-turno

```r
chat <- chat_anthropic(model = "claude-sonnet-4-5")

chat$chat("Hola, ¿qué eres?")
chat$chat("¿Recuerdas qué te pregunté antes?")
# El objeto chat mantiene historia.
```

Útil para construir contexto progresivamente. Para la mayoría de tareas batch del pipeline, sin embargo, cada llamada es independiente.

### 3.4 Streaming (para apps interactivas)

```r
chat$stream("Escribe un párrafo sobre...")
# Imprime tokens conforme llegan, no espera el final.
```

Útil en Shiny si quieres mostrar la respuesta token-por-token como ChatGPT. Para batch processing, irrelevante.

### 3.5 Manejo de credenciales

```r
# .env (gitignored)
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...

# En el código
readRenviron(".env")

chat <- chat_anthropic(model = "claude-sonnet-4-5")
# ellmer lee automáticamente las variables de entorno conocidas.
```

`ellmer` busca `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, etc., por convención. Si las tienes en `.env`, todo funciona sin código adicional.

---

## 4. Salidas estructuradas: el corazón técnico de la semana

Esta es la pieza más importante. Sin salidas estructuradas, el LLM no encaja en un pipeline.

### 4.1 El problema sin schemas

```r
chat$chat("Extrae el nombre y el monto de: 'Juan Pérez compró $1,500 en la tienda'")
# Devuelve:
# "El nombre es Juan Pérez y el monto es $1,500"
```

Esto no se parsea a un dataframe. Hay que extraerlo con regex (irónicamente) o pedirle al LLM que use JSON. La segunda opción tiene mejor robustez si se le indica formalmente — eso es structured output.

### 4.2 Con `ellmer::type_object()`

```r
schema_transaccion <- type_object(
  nombre = type_string("Nombre completo de la persona"),
  monto = type_number("Monto en pesos mexicanos"),
  comercio = type_string("Lugar de la transacción")
)

chat <- chat_anthropic(model = "claude-sonnet-4-5")

resultado <- chat$chat_structured(
  "Juan Pérez compró $1,500 en la tienda La Comer",
  type = schema_transaccion
)

# resultado es una lista con campos nombre, monto, comercio.
# Listo para meter en un tibble.
```

`type_object()` declara el contrato: el LLM debe responder con un JSON que matchee este schema. `ellmer` se encarga de validar y parsear.

### 4.3 Tipos disponibles

| Función | Para qué |
|---|---|
| `type_string(description)` | Texto |
| `type_number(description)` | Número (float) |
| `type_integer(description)` | Entero |
| `type_boolean(description)` | TRUE/FALSE |
| `type_enum(values, description)` | Una de una lista cerrada de valores |
| `type_array(items, description)` | Lista de elementos del tipo dado |
| `type_object(...)` | Objeto con múltiples campos (composición) |

Los `description` son críticos: es el "prompt local" que el modelo lee para cada campo. Mientras más claro y específico, mejor la extracción.

### 4.4 Schema con campos anidados

```r
schema_persona <- type_object(
  nombre_completo = type_string("Nombre y apellidos"),
  edad = type_integer("Edad en años; NA si no aparece"),
  contactos = type_array(
    items = type_object(
      tipo = type_enum(c("email", "telefono", "direccion")),
      valor = type_string("Valor del contacto")
    ),
    description = "Lista de contactos mencionados"
  )
)
```

El esquema puede anidarse arbitrariamente. La salida se parsea preservando la estructura — listas anidadas en R que con `unnest_wider`/`unnest_longer` (tidyr) se aplanan a tibble.

### 4.5 Batch processing con `purrr` (el patrón del curso)

```r
library(purrr)
library(tidyr)

# Datos: una fila por párrafo a procesar
df <- tibble(
  id = 1:10,
  texto = c("Juan compró $500...", "María vendió $1,200...", ...)
)

# Función que procesa un texto
extraer <- function(texto) {
  chat <- chat_anthropic(model = "claude-sonnet-4-5",
                          system_prompt = "Extrae los campos especificados.")
  chat$chat_structured(texto, type = schema_transaccion)
}

# Iterar sobre todos
df_enriquecido <- df |>
  mutate(extraccion = map(texto, extraer)) |>
  unnest_wider(extraccion)

# Resultado: un tibble con columnas id, texto, nombre, monto, comercio
```

Esto combina S9 (funciones), S10 (`purrr::map`), y S16 (LLMs estructurados) en el patrón final del pipeline. **Si los estudiantes pueden escribir esto, han internalizado todo el curso.**

### 4.6 Paralelización (recordatorio de S10)

Si tienes miles de filas y cada llamada tarda 1-2 segundos:

```r
library(furrr)
plan(multisession, workers = 4)

df_enriquecido <- df |>
  mutate(extraccion = future_map(texto, extraer)) |>
  unnest_wider(extraccion)
```

Cuidado: paralelizar también multiplica el costo en tokens y el riesgo de rate-limiting del proveedor. Algunos proveedores penalizan llamadas concurrentes.

---

## 5. Casos de uso típicos en proyectos de datos

Estos son los patrones que vale la pena mostrar en clase.

### 5.1 Extracción estructurada

```r
schema_acta <- type_object(
  fecha = type_string("Fecha de la sesión en formato YYYY-MM-DD"),
  asistentes = type_array(items = type_string("Nombre de asistente")),
  acuerdos = type_array(items = type_string("Texto del acuerdo"))
)

extraer_acta <- function(texto_acta) {
  chat <- chat_anthropic(model = "claude-sonnet-4-5",
                          system_prompt = "Extraes información estructurada de actas.")
  chat$chat_structured(texto_acta, type = schema_acta)
}
```

Casos reales: actas de asamblea, contratos, recetas médicas, formularios de respuestas abiertas en encuestas.

### 5.2 Clasificación

```r
schema_clasificacion <- type_object(
  categoria = type_enum(
    c("queja", "consulta", "felicitacion", "sugerencia"),
    description = "Tipo de mensaje"
  ),
  urgencia = type_enum(c("baja", "media", "alta"))
)

clasificar <- function(mensaje) {
  chat <- chat_anthropic(model = "claude-sonnet-4-5",
                          system_prompt = "Clasificas mensajes de servicio al cliente.")
  chat$chat_structured(mensaje, type = schema_clasificacion)
}
```

`type_enum` fuerza al modelo a elegir entre opciones cerradas. Mucho más robusto que pedir "categoría" y ver qué responde.

### 5.3 Resumen

```r
resumir <- function(texto, longitud_max = 200) {
  chat <- chat_anthropic(
    model = "claude-haiku-4-5",  # más barato/rápido para tareas simples
    system_prompt = paste0(
      "Eres un resumidor. Devuelve un resumen de máximo ",
      longitud_max,
      " caracteres."
    )
  )
  chat$chat(texto)
}
```

Para resumen no necesitas schema (el output es texto libre). Pero sí puedes restringir longitud en el system prompt.

### 5.4 Normalización

```r
schema_normalizado <- type_object(
  nombre_canonico = type_string("Nombre estándar del municipio")
)

normalizar_municipio <- function(texto_sucio) {
  chat <- chat_anthropic(
    model = "claude-sonnet-4-5",
    system_prompt = paste0(
      "Recibes nombres de municipios mexicanos con variaciones ortográficas. ",
      "Devuelve el nombre canónico según INEGI."
    )
  )
  chat$chat_structured(texto_sucio, type = schema_normalizado)
}

# "Cd. de Mexico" → "Ciudad de México"
# "Naucalpán" → "Naucalpan de Juárez"
# "Aguascalientes" → "Aguascalientes"
```

Más robusto que `stringdist` cuando hay variaciones semánticas, no solo ortográficas.

### 5.5 Etiquetado

```r
schema_tags <- type_object(
  tags = type_array(
    items = type_string("Etiqueta corta en minúsculas"),
    description = "3 a 5 etiquetas que describen el tema principal"
  )
)

etiquetar <- function(texto) {
  chat <- chat_anthropic(model = "claude-sonnet-4-5")
  chat$chat_structured(texto, type = schema_tags)
}
```

Útil para indexación de documentos, categorización de notas de prensa, etc.

---

## 6. Manejo de credenciales y costos

### 6.1 API keys: nunca en código

```r
# MAL — nunca
chat <- chat_anthropic(api_key = "sk-ant-xxxxxx")

# BIEN — variable de entorno
# .env
ANTHROPIC_API_KEY=sk-ant-xxxxxx

# En código
readRenviron(".env")
chat <- chat_anthropic(model = "claude-sonnet-4-5")
# ellmer lee la variable automáticamente
```

`.env` siempre en `.gitignore`. Esto se introdujo en S4 y aplica en S14 y S16.

### 6.2 Costos por token

Cada proveedor cobra por uso. Pricing en USD aproximado (revisar páginas oficiales para precios actuales):

| Modelo | Costo entrada (1M tokens) | Costo salida (1M tokens) |
|---|---|---|
| Claude Sonnet 4.5 | ~$3 | ~$15 |
| Claude Haiku 4.5 | ~$1 | ~$5 |
| GPT-4o | ~$2.50 | ~$10 |
| Gemini 2.0 Flash | gratuito hasta cuota / muy barato | gratuito hasta cuota |
| Groq llama-3.3-70b | gratuito hasta cuota | gratuito hasta cuota |
| Ollama (local) | $0 | $0 (pagas en hardware) |

**Tokens, no palabras.** 1 token ≈ 4 caracteres en inglés, ~3 en español. Un párrafo de 500 caracteres en español ≈ 170 tokens.

**Estimación rápida para el curso:** procesar 1000 párrafos de 500 caracteres con Claude Sonnet ≈ 170K tokens de entrada + ~50K de salida = ~$0.50 + $0.75 = **~$1.25**.

Para datos académicos esto es barato. Para producción a escala, calcular antes de correr.

### 6.3 Recomendación de provider para el curso

Para que los estudiantes experimenten sin pagar:

- **Google Gemini**: tier gratuito generoso, suficiente para el proyecto del curso.
- **Groq**: también gratuito, inferencia muy rápida con modelos open source.

Para experimentación seria:
- **Anthropic Claude**: modelos potentes, structured output excelente.

**Default recomendado en clase:** Gemini para empezar (gratuito), Anthropic para calidad si está disponible.

---

## 7. Panorama: extensiones del flujo

Mención superficial — no se enseña en profundidad pero el estudiante debe saber que existe.

### 7.1 Modelos locales con `ollama`

`ollama` es un runtime para correr LLMs en tu propia máquina. Sin enviar datos a un servidor externo.

```r
# Después de instalar ollama y descargar un modelo:
# $ ollama pull llama3.1

chat <- chat_ollama(model = "llama3.1")
chat$chat("Hola")
# El modelo corre en tu CPU/GPU local. No hay API key, no hay costo, no hay envío externo.
```

**Cuándo usar:**
- Datos sensibles que no pueden salir del entorno (PII, clínicos, fiscales).
- Sin internet o con conexión inestable.
- Sin presupuesto para APIs.

**Limitación:** los modelos locales son típicamente más pequeños/menos capaces que GPT-4o o Claude. Para tareas simples (clasificación binaria, normalización) funcionan bien; para razonamiento complejo, menos.

### 7.2 OCR local

Extraer texto de imágenes o PDFs escaneados:

```r
library(tesseract)

texto <- ocr("documento_escaneado.png", engine = tesseract("spa"))
```

`tesseract` corre localmente. Combina con LLM para post-procesar el output (que suele tener errores) y extraer estructura.

### 7.3 Censura / PII redaction

Antes de publicar datos, eliminar información personal identificable (PII):

```r
schema_pii <- type_object(
  texto_limpio = type_string("El texto con CURPs, RFCs, direcciones y nombres reemplazados por placeholders")
)

censurar <- function(texto) {
  chat <- chat_anthropic(
    model = "claude-sonnet-4-5",
    system_prompt = "Recibes texto con datos personales. Reemplaza CURPs, RFCs, direcciones físicas y nombres por [REDACTED]. Mantén el resto del texto intacto."
  )
  chat$chat_structured(texto, type = schema_pii)
}
```

Combinado con regex para los patrones más obvios (CURP, RFC tienen formato fijo) y LLM para los menos obvios (nombres, direcciones).

### 7.4 Interfaces conversacionales con `telegram.bot`

```r
library(telegram.bot)

bot <- Bot(token = Sys.getenv("TELEGRAM_BOT_TOKEN"))

# Cuando alguien manda /resumen al bot, ejecutar el pipeline
# y devolver el resumen automáticamente.
```

El bot se vuelve la interfaz al pipeline. Tus proyectos profesionales (aduanas-back, seguridad-back) usan este patrón.

---

## 8. Consideraciones éticas y operativas

### 8.1 Privacidad de los datos

Cuando mandas un texto a una API externa, ese texto sale de tu entorno. Cosas a considerar:

- ¿Los datos contienen PII? (CURPs, RFCs, nombres, direcciones)
- ¿Los datos son confidenciales? (financieros, médicos, gubernamentales)
- ¿El proveedor entrena modelos con tus datos? (Anthropic NO; OpenAI tiene opciones; Google Gemini varía por tier)
- ¿Cumple con regulaciones locales? (LFPDPPP en México, GDPR si hay datos europeos)

**Regla mental:** si no lo mandarías por correo a un proveedor externo, no lo mandes a una API LLM.

Para datos sensibles: **ollama local** es la respuesta.

### 8.2 No-determinismo

Los LLMs son estocásticos. La misma entrada puede dar salidas distintas.

```r
chat <- chat_anthropic(
  model = "claude-sonnet-4-5",
  params = params(temperature = 0)  # menos aleatorio
)
```

`temperature = 0` reduce la variabilidad pero no la elimina. Para análisis científico reproducible, considera registrar las salidas en una BD y reusar (caché) en vez de re-llamar.

### 8.3 Rate limiting

Cada proveedor limita requests por minuto/segundo. Cuando paralelizas con `furrr`, puedes exceder. Manejar con `tryCatch` y `Sys.sleep`:

```r
extraer_con_reintento <- function(texto, intentos = 3) {
  for (i in seq_len(intentos)) {
    result <- tryCatch(
      extraer(texto),
      error = function(e) NULL
    )
    if (!is.null(result)) return(result)
    Sys.sleep(2 ^ i)  # backoff exponencial
  }
  NULL
}
```

### 8.4 La regla de oro

> **Si una expresión regular resuelve el problema, no uses un LLM.**

Los LLMs son ~1000x más lentos que un regex, ~10000x más caros, y no-determinísticos. Úsalos cuando:

- El texto es genuinamente irregular o ambiguo.
- La transformación requiere comprensión semántica.
- Las reglas no se pueden escribir explícitamente.

No los uses cuando:

- El patrón es fijo (regex).
- La transformación es mecánica (`stringr`).
- El cómputo es matemático.
- Tienes que justificar cada salida a un auditor (los LLMs son cajas grises).

---

## 9. Anti-patrones comunes

1. **Llamar al LLM dentro de un loop sin batching.** Si tienes 10K filas, son 10K llamadas; con `purrr::map` está bien (es lo correcto), pero no anides loops `for` adentro.

2. **No usar structured output.** Pedir "responde en JSON" en el system prompt y luego parsear con `jsonlite` es frágil. `chat_structured` con schema es el camino.

3. **Reintentar sin backoff exponencial.** Si la API te limita por rate, reintentar inmediatamente solo empeora.

4. **Hardcodear API keys.** Siempre `.env` + `Sys.getenv()`.

5. **No registrar resultados.** Cada llamada cuesta. Si vas a re-correr el pipeline, considera cachear los resultados con `memoise` o guardar en disco.

6. **Usar el modelo más caro por default.** Para clasificación simple, Haiku/Flash/Gemini Flash son ~10x más baratos que Sonnet/GPT-4o y suficientes.

7. **Olvidar `temperature = 0` para tareas estructuradas.** Si quieres reproducibilidad relativa, baja la temperatura. Para creatividad, súbela.

8. **Usar LLM cuando un regex resuelve.** El primer caso de uso del estudiante suele ser "extraer un email de un texto". Hay un regex para eso. Usa el regex.

---

## 10. Tabla decisión rápida

| Quieres... | Usa |
|---|---|
| Entender qué hay debajo de una API LLM | `httr2` con POST manual |
| Usar un LLM en producción sin atarte a un proveedor | `ellmer::chat_*()` |
| Extraer campos de un texto al dataframe | `chat_structured()` con `type_object()` |
| Clasificar texto en categorías cerradas | `chat_structured()` con `type_enum()` |
| Resumir un texto largo | `chat$chat()` con system_prompt que define el formato |
| Iterar sobre N filas | `purrr::map()` aplicando una función LLM |
| Paralelizar (con cuidado de rate limits) | `furrr::future_map()` (S10) |
| Datos sensibles que no pueden salir del entorno | `chat_ollama()` con modelo local |
| Extraer texto de imágenes/PDFs escaneados | `tesseract::ocr()` |
| Eliminar PII antes de publicar | combinación regex + LLM con prompt de censura |
| Manejo de credenciales | `.env` + `Sys.getenv()` (siempre) |
| Reproducibilidad relativa | `params = params(temperature = 0)` |
| Caché para evitar re-llamar | `memoise::memoise()` o serialización a disco |
| Reintento ante rate limit | `tryCatch` + `Sys.sleep(2^i)` |
| Decidir entre LLM y regex | **Si regex resuelve, regex.** |

---

## 11. Lecturas y orden recomendado

**Para preparar la clase:**

1. **`ellmer` — Getting started** — `https://ellmer.tidyverse.org/articles/ellmer.html`. Léelo primero.
2. **`ellmer` — Structured data** — `https://ellmer.tidyverse.org/articles/structured-data.html`. La pieza más importante para integración a pipeline.
3. **`httr2` — Getting started** — `https://httr2.r-lib.org/articles/httr2.html`. Para enseñar la versión "qué hay debajo".

**Para profundizar:**

- Documentación del proveedor elegido:
  - Anthropic: `https://docs.anthropic.com/en/api/overview`
  - OpenAI: `https://platform.openai.com/docs/`
  - Google Gemini: `https://ai.google.dev/gemini-api/docs`
- `ollama` para modelos locales: `https://ollama.com/`
- `tesseract` para OCR: `https://docs.ropensci.org/tesseract/`

---

## 12. Una nota final: cómo cerrar el curso

Esta es la última semana. Vale la pena cerrar con una reflexión explícita.

El estudiante llegó al curso sin saber programar. Termina con un pipeline completo: importa datos del INEGI, los limpia con dplyr, los transforma con funciones reutilizables, los modela, los carga a SQLite, los visualiza con ggplot, los reporta automáticamente con officer, los distribuye con googledrive/gmailr, los expone en un Shiny, y los enriquece con LLMs integrados.

**Eso es un proyecto de datos completo.** No "skills aisladas", sino la cadena entera de principio a fin. Ese es exactamente el hueco que el curso quería llenar.

Tres mensajes para llevar a clase en el cierre:

1. **La habilidad que aprendieron no es R; es ingeniería de proyectos de datos.** R es la herramienta. Lo que sabrán hacer es construir flujos completos, reproducibles, auditables.

2. **Los LLMs son una herramienta más, no la herramienta principal.** Hay temas en este curso (dplyr, funciones, vectorización) más fundamentales que los LLMs. El que sabe dplyr resuelve el 80% de los problemas; el que sabe LLM sin saber dplyr no resuelve nada.

3. **El pipeline siempre supera al uso manual.** Cualquier tarea que harían a mano una vez, si la automatizan, la podrán correr cien veces gratis. Esa es la ventaja que tienen ahora sobre quien no programa.

El estudiante que se lleva esto a casa tiene la base para hacer trabajo de datos serio. No le falta nada esencial. Lo que sigue es práctica y profundización — pero ya saben cómo es la cosa.
