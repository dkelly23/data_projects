# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         ejercicios_01.R
# Objetivo:       Bloque de práctica de la Sesión 1. Montar el proyecto,
#                 versionarlo y operar con vectores y condiciones lógicas.
#
# Autor:          Daniel Kelly
# Correo(s):      djsanchez@colmex.mx
#
# Fecha:          20/08/2026
#
# Última
# actualización:  20/08/2026
#
# _____________________________________________________________________________

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola


# EJERCICIOS __________________________________________________________________

## 1. Verificar la instalación -----------------------------------------------=

# Ejecuta las tres líneas siguientes y verifica que la versión de R sea 4.1 o
# superior. Si no lo es, avisa antes de continuar: varias cosas del curso
# dependen de ello.

R.version.string
getRversion() >= "4.1.0"
.libPaths()


## 2. Montar la estructura del proyecto --------------------------------------=

# Con el proyecto abierto, confirma dónde estás parado:

getwd()

# Crea las cuatro carpetas de la convención del curso, si no existen todavía.
# Pista: dir.exists() pregunta, dir.create() crea.

#| solucion
for (carpeta in c("files", "docs", "pre", "output")) {
    if (!dir.exists(carpeta)) {
        dir.create(carpeta)
    }
}
#| fin

# Verifica el resultado:

list.dirs(recursive = FALSE)


## 3. Escribir el .gitignore -------------------------------------------------=

# Escribe un archivo .gitignore que excluya, como mínimo: los datos crudos, los
# outputs, el historial de R, la imagen del entorno y los archivos de sistema.

#| solucion
writeLines(
    c("files/", "output/", ".Rhistory", ".RData", ".Rproj.user/", ".DS_Store", ".env"),
    ".gitignore"
)
#| fin

# Léelo de vuelta para confirmar que quedó bien:

readLines(".gitignore")


## 4. Versionar el proyecto --------------------------------------------------=

# En la TERMINAL (no en la consola de R), deja el repositorio iniciado, con un
# primer commit y sincronizado con GitHub. La secuencia:
#
#   git init
#   git status
#   git add .
#   git commit -m "Estructura inicial del proyecto"
#
# Después crea el repositorio VACÍO en GitHub y conéctalo:
#
#   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
#   git push -u origin main
#
# Verifica en el navegador que los archivos llegaron.


## 5. Vectores y tipos -------------------------------------------------------=

# Construye un vector con las edades siguientes: 17, 22, 35, 15, 68, 41, 19.

#| solucion
edad = c(17, 22, 35, 15, 68, 41, 19)
#| fin

# Averigua su tipo y su longitud.

#| solucion
typeof(edad)
length(edad)
#| fin

# Ahora agrega el valor "no especificado" al vector. Antes de ejecutarlo,
# predice qué tipo tendrá el resultado. ¿Coincidió con lo que esperabas?

#| solucion
edad_mixta = c(edad, "no especificado")
typeof(edad_mixta)
#| fin


## 6. Condiciones lógicas ----------------------------------------------------=

# Sobre el vector `edad` original, responde con una sola línea cada una:

# a) ¿Cuántas personas son mayores de edad?

#| solucion
sum(edad >= 18)
#| fin

# b) ¿Qué proporción del total representan?

#| solucion
mean(edad >= 18)
#| fin

# c) ¿Qué proporción está en edad de trabajar (18 a 64 años)?

#| solucion
mean(edad >= 18 & edad < 65)
#| fin

# d) ¿Hay alguien mayor de 65?

#| solucion
any(edad > 65)
#| fin


## 7. Valores faltantes ------------------------------------------------------=

# Repite el vector, ahora con un dato desconocido:

edad_na = c(17, 22, NA, 15, 68, 41, 19)

# Calcula la proporción de mayores de edad. ¿Qué devuelve y por qué?

#| solucion
mean(edad_na >= 18)
# Devuelve NA: no sabemos si el valor desconocido es mayor de edad, así que
# tampoco podemos saber la proporción. El NA se propaga.
#| fin

# Corrígelo excluyendo el faltante, y cuenta cuántos faltantes había.

#| solucion
mean(edad_na >= 18, na.rm = TRUE)
sum(is.na(edad_na))
#| fin


## 8. Cierre -----------------------------------------------------------------=

# Haz un commit con el trabajo de esta sesión y súbelo:
#
#   git add .
#   git commit -m "Ejercicios de la sesión 1"
#   git push
