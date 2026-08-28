# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         generar_data.R
# Objetivo:       Generar los archivos de trabajo de la Sesión 2: un levantamiento
#                 simulado de la Encuesta de Ingresos y Gastos de los Hogares
#                 (EIGH), en tres formatos y con los defectos típicos de un
#                 archivo real.
#
# Autor:          Daniel Kelly
# Correo(s):      djsanchez@colmex.mx
#
# Fecha:          27/08/2026
#
# Última
# actualización:  27/08/2026
#
# _____________________________________________________________________________
#
# La EIGH no existe: es un levantamiento simulado, construido para que el curso
# trabaje siempre sobre los mismos datos sin depender de una descarga. Imita la
# estructura de una encuesta de ingreso-gasto real —tres tablas relacionadas por
# el folio de la vivienda, catálogos aparte y un descriptor técnico— y trae los
# problemas que un archivo real trae de fábrica:
#
#   folioviv y entidad     identificadores con ceros a la izquierda
#   ing_trab               columna numérica con "n.d." en algunas celdas
#   edad                   código 999 para la no respuesta
#   eigh_personas.txt      delimitado por barra vertical, no por coma
#   eigh_gastos.csv        punto y coma como separador, coma como decimal
#   eigh_hogares_latin1    el mismo CSV codificado en Latin-1 en vez de UTF-8
#   eigh_catalogos.xlsx    hojas con título y filas en blanco antes de los datos
#
# Se corre UNA vez, desde la raíz del repositorio. Los archivos quedan en
# code/files/ y code/docs/, que es lo que reciben los estudiantes en el zip.
#
# _____________________________________________________________________________

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola

# Paquetes
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(readr, tibble, openxlsx)

# Rutas de salida. El script se puede correr desde cualquier carpeta del
# repositorio: la raíz se localiza subiendo directorios hasta encontrar el
# archivo de proyecto que reciben los estudiantes.
localizar_raiz = function(inicio = getwd()) {
    ruta = normalizePath(inicio, winslash = "/", mustWork = TRUE)
    repeat {
        if (file.exists(file.path(ruta, "code", "curso-ppd.Rproj"))) return(ruta)
        padre = dirname(ruta)
        if (identical(padre, ruta)) break
        ruta = padre
    }
    stop("No se encontró la raíz del repositorio a partir de ", inicio,
        ". Correr el script desde alguna carpeta del repositorio.")
}

RAIZ       = localizar_raiz()
RUTA_FILES = file.path(RAIZ, "code", "files")
RUTA_DOCS  = file.path(RAIZ, "code", "docs")

dir.create(RUTA_FILES, recursive = TRUE, showWarnings = FALSE)
dir.create(RUTA_DOCS, recursive = TRUE, showWarnings = FALSE)

cat("Raíz del repositorio:", RAIZ, "\n")

# La semilla fija el levantamiento: sin ella, cada corrida produce datos
# distintos y las salidas de las diapositivas dejan de coincidir.
set.seed(20260821)


# CODIGO ______________________________________________________________________

# CATALOGOS ___________________________________________________________________

# Seis entidades, tres de ellas con acento: son las que rompen la lectura cuando
# el encoding está mal declarado.
entidades = tibble(
    entidad = c("09", "16", "19", "20", "22", "31"),
    nom_ent = c("Ciudad de México", "Michoacán de Ocampo", "Nuevo León",
        "Oaxaca", "Querétaro", "Yucatán")
)

# Rubros de gasto, con la estructura clave-descripción de un catálogo real.
claves_gasto = tibble(
    clave       = c("A001", "A002", "B001", "B002", "C001", "D001", "E001", "F001"),
    rubro       = c("Alimentos", "Alimentos", "Vivienda", "Vivienda",
        "Transporte", "Educación", "Salud", "Vestido"),
    descripcion = c("Alimentos consumidos dentro del hogar",
        "Alimentos consumidos fuera del hogar",
        "Renta o pago de vivienda", "Electricidad, agua y combustible",
        "Transporte público y particular", "Colegiaturas y material escolar",
        "Consultas, medicamentos y hospitalización",
        "Ropa, calzado y accesorios")
)


# TABLA DE HOGARES ____________________________________________________________

n_hog = 800

# El folio de la vivienda se construye con siete dígitos y un cero inicial. Es
# un identificador, no una cantidad: si se lee como número pierde ese cero y
# deja de servir para cruzar tablas.
hogares = tibble(
    folioviv  = sprintf("0%06d", sample(100000:999999, n_hog)),
    entidad   = sample(entidades$entidad, n_hog, replace = TRUE),
    tam_loc   = sample(1:4, n_hog, replace = TRUE, prob = c(.45, .25, .18, .12)),
    tot_integ = sample(1:7, n_hog, replace = TRUE, prob = c(.12, .21, .26, .21, .12, .05, .03))
)

# El nombre de la entidad viaja junto al código, como en los archivos reales.
hogares$nom_ent = entidades$nom_ent[match(hogares$entidad, entidades$entidad)]

# Ingreso corriente trimestral: crece con el tamaño del hogar y con el tamaño de
# la localidad, y tiene la asimetría a la derecha propia de una distribución de
# ingreso.
hogares$ing_cor = round(
    exp(rnorm(n_hog, mean = 10.5, sd = 0.55)) *
        (1 + 0.08 * hogares$tot_integ) *
        (1 + 0.15 * (4 - hogares$tam_loc)),
    2
)

# El gasto es una fracción del ingreso, y esa fracción cae conforme el ingreso
# sube: la propensión marginal a consumir no es constante.
hogares$gasto_mon = round(
    hogares$ing_cor * (0.95 - 0.12 * (log(hogares$ing_cor) - 10.5)) *
        exp(rnorm(n_hog, 0, 0.22)),
    2
)

# Factor de expansión. Se excluye el 999 a propósito: es el código de no
# respuesta de la edad, y declararlo como `na` al importar afecta a todas las
# columnas del archivo, no solo a la que interesa.
hogares$factor = sample(c(80:998, 1000:1400), n_hog, replace = TRUE)

# Defecto 1: en 23 viviendas no se pudo determinar el tamaño de localidad, y se
# capturó con el código 9 en vez de dejarlo vacío.
hogares$tam_loc[sample(n_hog, 23)] = 9

# Defecto 2: 18 hogares no reportaron ingreso. Quedan como celda vacía.
hogares$ing_cor[sample(n_hog, 18)] = NA

hogares = hogares[, c("folioviv", "entidad", "nom_ent", "tam_loc",
    "tot_integ", "ing_cor", "gasto_mon", "factor")]


# TABLA DE PERSONAS ___________________________________________________________

# Una fila por integrante de cada hogar: la tabla se expande a partir de
# tot_integ, de modo que las dos tablas se pueden cruzar por folioviv.
integrantes = ifelse(hogares$tot_integ == 9, 1, hogares$tot_integ)

personas = tibble(
    folioviv = rep(hogares$folioviv, times = integrantes),
    numren   = sequence(integrantes)
)

n_per = nrow(personas)

# El renglón 1 es siempre el jefe del hogar; el 2, cónyuge; de ahí en adelante,
# hijos u otros parientes.
personas$parentesco = ifelse(personas$numren == 1, 1,
    ifelse(personas$numren == 2, 2,
        sample(3:4, n_per, replace = TRUE, prob = c(.85, .15))))

personas$sexo = ifelse(personas$parentesco == 1,
    sample(c(1, 2), n_per, replace = TRUE, prob = c(.62, .38)),
    sample(c(1, 2), n_per, replace = TRUE))

# La edad depende del parentesco: jefes y cónyuges son adultos, los hijos no.
personas$edad = ifelse(personas$parentesco %in% c(1, 2),
    sample(24:88, n_per, replace = TRUE),
    sample(0:40, n_per, replace = TRUE))

personas$nivel_esc = sample(0:5, n_per, replace = TRUE,
    prob = c(.06, .22, .27, .21, .18, .06))

# El ingreso por trabajo depende de la edad y la escolaridad. Los menores de 15
# y una parte de los adultos no perciben ingreso laboral: es 0, no faltante.
ingreso = exp(1.9 + 0.35 * personas$nivel_esc + 0.02 * personas$edad +
    rnorm(n_per, 0, 0.5)) * 100
ingreso[personas$edad < 15] = 0
ingreso[sample(n_per, round(n_per * 0.18))] = 0
personas$ing_trab = round(ingreso, 2)

personas$factor = hogares$factor[match(personas$folioviv, hogares$folioviv)]

# Defecto 3: 31 personas no declararon su edad, capturada con el código 999.
personas$edad[sample(n_per, 31)] = 999

# Defecto 4: el ingreso por trabajo se captura como texto, y 26 celdas traen
# "n.d." en vez de un número. Basta eso para que toda la columna llegue a R
# como character.
personas$ing_trab = as.character(personas$ing_trab)
personas$ing_trab[sample(n_per, 26)] = "n.d."

# Defecto 5: el nivel de escolaridad falta en 14 registros, como celda vacía.
personas$nivel_esc[sample(n_per, 14)] = NA


# TABLA DE GASTOS _____________________________________________________________

# Entre tres y ocho rubros de gasto por hogar.
rubros_por_hogar = sample(3:8, n_hog, replace = TRUE)

gastos = tibble(
    folioviv = rep(hogares$folioviv, times = rubros_por_hogar),
    clave    = unlist(lapply(rubros_por_hogar,
        function(k) sample(claves_gasto$clave, k)))
)

n_gas = nrow(gastos)

gastos$gasto_tri = round(exp(rnorm(n_gas, 7.6, 0.85)), 2)
gastos$frecuencia = sample(1:6, n_gas, replace = TRUE)


# DESCRIPTOR TECNICO __________________________________________________________

# El descriptor es contra lo que se verifica la importación: declara el tipo de
# cada variable y los códigos de no respuesta. Va en docs/, no en files/.
descriptor = tibble(
    tabla = c(rep("hogares", 8), rep("personas", 7), rep("gastos", 4)),
    variable = c(
        "folioviv", "entidad", "nom_ent", "tam_loc", "tot_integ", "ing_cor",
        "gasto_mon", "factor",
        "folioviv", "numren", "parentesco", "sexo", "edad", "nivel_esc",
        "ing_trab",
        "folioviv", "clave", "gasto_tri", "frecuencia"),
    tipo = c(
        "character", "character", "character", "integer", "integer", "double",
        "double", "integer",
        "character", "integer", "integer", "integer", "integer", "integer",
        "double",
        "character", "character", "double", "integer"),
    descripcion = c(
        "Folio de la vivienda. Identificador, conserva el cero inicial",
        "Clave de la entidad federativa, dos dígitos",
        "Nombre de la entidad federativa",
        "Tamaño de localidad",
        "Total de integrantes del hogar",
        "Ingreso corriente trimestral del hogar, en pesos",
        "Gasto monetario trimestral del hogar, en pesos",
        "Factor de expansión de la vivienda",
        "Folio de la vivienda. Llave con la tabla de hogares",
        "Número de renglón de la persona dentro del hogar",
        "Parentesco con el jefe del hogar",
        "Sexo de la persona",
        "Edad en años cumplidos",
        "Nivel de escolaridad",
        "Ingreso trimestral por trabajo, en pesos",
        "Folio de la vivienda. Llave con la tabla de hogares",
        "Clave del rubro de gasto",
        "Gasto trimestral en el rubro, en pesos",
        "Frecuencia declarada del gasto"),
    codigos = c(
        "", "", "", "1 a 4; 9 = no especificado", "", "vacío = no respuesta",
        "", "",
        "", "", "1 jefe; 2 cónyuge; 3 hijo; 4 otro", "1 hombre; 2 mujer",
        "999 = no especificado", "0 a 5; vacío = no respuesta",
        "n.d. = no declarado",
        "", "", "", "1 semanal a 6 anual")
)


# ESCRITURA DE LOS ARCHIVOS ___________________________________________________

## hogares: CSV separado por comas, UTF-8 ------------------------------------=

write_csv(hogares, file.path(RUTA_FILES, "eigh_hogares.csv"), na = "")

## hogares: el mismo CSV codificado en Latin-1 -------------------------------=

con = file(file.path(RUTA_FILES, "eigh_hogares_latin1.csv"), open = "wb")
writeLines(
    iconv(format_csv(hogares, na = ""), "UTF-8", "latin1"),
    con, useBytes = TRUE
)
close(con)

## personas: texto delimitado por barra vertical, extensión .txt -------------=

write_delim(personas, file.path(RUTA_FILES, "eigh_personas.txt"),
    delim = "|", na = "")

## gastos: exportado a la española, punto y coma y coma decimal --------------=

write.table(gastos, file.path(RUTA_FILES, "eigh_gastos.csv"),
    sep = ";", dec = ",", row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")

## catálogos: hoja de cálculo con título y filas en blanco -------------------=

# Las hojas se escriben con el encabezado del catálogo en las primeras filas,
# como llegan los archivos institucionales: los datos no empiezan en A1, y hay
# una hoja de notas que no contiene datos.
wb = createWorkbook()

addWorksheet(wb, "entidades")
writeData(wb, "entidades", "Catálogo de entidades federativas", startCol = 1, startRow = 1)
writeData(wb, "entidades", "EIGH - levantamiento simulado", startCol = 1, startRow = 2)
writeData(wb, "entidades", entidades, startCol = 1, startRow = 4)

addWorksheet(wb, "claves_gasto")
writeData(wb, "claves_gasto", "Catálogo de rubros de gasto", startCol = 1, startRow = 1)
writeData(wb, "claves_gasto", claves_gasto, startCol = 1, startRow = 3)

addWorksheet(wb, "notas")
writeData(wb, "notas", c(
    "Notas metodológicas",
    "",
    "1. Los montos son trimestrales y están expresados en pesos corrientes.",
    "2. El factor de expansión se aplica a nivel vivienda.",
    "3. Este levantamiento es simulado y no corresponde a ninguna encuesta real."
))

saveWorkbook(wb, file.path(RUTA_FILES, "eigh_catalogos.xlsx"), overwrite = TRUE)

## descriptor técnico --------------------------------------------------------=

write_csv(descriptor, file.path(RUTA_DOCS, "eigh_descriptor.csv"))


# VERIFICACION ________________________________________________________________

cat("\nArchivos escritos:\n")
print(file.info(list.files(RUTA_FILES, full.names = TRUE))["size"])

cat("\nDimensiones:\n")
cat("  hogares :", nrow(hogares), "x", ncol(hogares), "\n")
cat("  personas:", nrow(personas), "x", ncol(personas), "\n")
cat("  gastos  :", nrow(gastos), "x", ncol(gastos), "\n")

cat("\nDefectos sembrados:\n")
cat("  tam_loc == 9      :", sum(hogares$tam_loc == 9), "\n")
cat("  ing_cor faltante  :", sum(is.na(hogares$ing_cor)), "\n")
cat("  edad == 999       :", sum(personas$edad == 999), "\n")
cat("  ing_trab == n.d.  :", sum(personas$ing_trab == "n.d."), "\n")
cat("  nivel_esc faltante:", sum(is.na(personas$nivel_esc)), "\n")
