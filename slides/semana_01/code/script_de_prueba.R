# _____________________________________________________________________________
#
# Proyecto:       Programming for Data Projects
#
# Script:         script_de_prueba.R
#
# Autor:          Daniel Kelly
# Correo(s):      daniel.kelly@transformaciondigital.gob.mx
#
# Fecha:          12/05/2026
# 
# Última
# actualización:  12/05/2026
#
# _____________________________________________________________________________

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls())       # Limpiar entorno de trabajo
# source("~/.Rprofile") # Cargar configuraciones globales
cat("\014")           # Limpiar consola


# CODIGO ______________________________________________________________________

# Construímos un vector de prueba:
vector = c(1,2,3,4,5)
print(vector)

# Podemos también generar objetos de texto:
vector_de_texto = c(
    "este",
    "es",
    "un",
    "objeto",
    "de",
    "prueba"
)
print(vector_de_texto)

# Otra característica clave es la capacidad de realizar operaciones matemáticas:
suma = vector + 10
print(suma)

# O realizarlos con escalares:
a = 10
b = 5
suma_escalar = a + b
print(suma_escalar)

# En el flujo, también se pueden incorporar comentarios que se imprimen en la terminal:
cat(
    "\033[31m\033[1mEste es un comentario que se imprimirá en la terminal\033[0m\033[0m\n\n"
)

# Las posibilidades son infinitas:
for (i in 1:5) {
    cat(
        "\033[34m\033[1mIteración", i, "\033[0m\033[0m\n"
    )
}

# O más creativas:
boot_screen = function(delay = 0.08) {
    opciones = c(
        "\033[32m",
        "\033[1m"
    )

    cat(paste0(opciones, collapse = ""))

    lines = c(
        "██╗  ██╗ ██████╗ ██╗      █████╗",
        "██║  ██║██╔═══██╗██║     ██╔══██╗",
        "███████║██║   ██║██║     ███████║",
        "██╔══██║██║   ██║██║     ██╔══██║",
        "██║  ██║╚██████╔╝███████╗██║  ██║",
        "╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝",
        "",
        "[ SYSTEM INITIALIZED ]",
        "",
        "> loading workspace...",
        "> attaching packages...",
        "> checking dependencies...",
        "> initializing runtime...",
        "> ready."
    )

    for (i in seq_along(lines)) {
        cat(lines[i], "\n")

        flush.console()

        Sys.sleep(delay)
    }

    cat("\033[0m")
}
boot_screen(delay = 0.2)

# Podemos también simular datos:
set.seed(123)
datos_simulados = data.frame(
    id = 1:100,
    valor = rnorm(100, mean = 50, sd = 10)
)
print(head(datos_simulados))

# Y visualizarlos!
plot(
    datos_simulados$id,
    datos_simulados$valor,
    main = "Gráfico de Datos Simulados",
    xlab = "ID",
    ylab = "Valor",
    pch = 19,
    col = "dodgerblue",
    type = "l"
)

# También podemos hacer tareas de estadística descriptiva:
df = data.frame(
    x = rnorm(1000, mean = 50, sd = 10),
    e = rnorm(1000, mean = 0, sd = 5)
)
df$y = 0.5 * df$x + df$e

# Y construir modelos estadísticos:
modelo = lm(y ~ x, data = df)
summary(modelo)

# Hasta visualizarlos:
plot(modelo)

# Y por supuesto, podemos escribir funciones personalizadas:
mi_funcion = function(x) {
    resultado = x^2 + 2*x + 1
    return(resultado)
}
print(mi_funcion(5))

# Las posibilidades son infinitas...