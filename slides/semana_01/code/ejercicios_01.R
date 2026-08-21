# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         ejercicios_01.R
# Objetivo:       Bloque de práctica de la Sesión 1. Vectores, tipos, coerción,
#                 condiciones lógicas y valores faltantes.
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

#| nota
# BLOQUE DE PRÁCTICA — 1:15 hr. Reparto sugerido:
#
#   Ej. 1  Verificación del entorno         5 min
#   Ej. 2  Estructura del proyecto         10 min
#   Ej. 3  La mini encuesta                10 min
#   Ej. 4  Tipos y coerción                15 min
#   Ej. 5  Vectorización                   10 min
#   Ej. 6  Condiciones lógicas             20 min   <- el núcleo de la sesión
#   Ej. 7  Valores faltantes               10 min
#   Ej. 8  Listas                           5 min
#   Ej. 9  Integrador                     opcional
#
# Método: los estudiantes intentan primero, en silencio, 3-4 minutos. Después se
# construye la solución en el pizarrón preguntando a la clase, línea por línea.
# No dictar la respuesta: pedirla.
#
# Si el tiempo aprieta, el 9 se va a casa y el 8 se resuelve en voz alta. Lo que
# NO se puede sacrificar es el 6: la idea de sum()/mean() sobre un vector lógico
# es la que sostiene todo el resto del curso.
#| fin

# PREAMBULO ___________________________________________________________________

# Limpiar entorno de trabajo
rm(list = ls()) # Limpiar entorno de trabajo
cat("\014") # Limpiar consola


# EJERCICIOS __________________________________________________________________

## 1. Verificación del entorno -----------------------------------------------=

# Ejecuta las líneas siguientes. La versión de R debe ser 4.1 o superior; varias
# cosas del curso dependen de ello. Si no lo es, avisa antes de continuar.

R.version.string
getRversion() >= "4.1.0"

# ¿Qué tipo de objeto devolvió la segunda línea? Averígualo.

#| solucion
class(getRversion() >= "4.1.0")
# logical: es el resultado de una comparación.
#| fin


## 2. Estructura del proyecto ------------------------------------------------=

# Confirma en qué carpeta estás parado:

getwd()

# Crea las cuatro carpetas de la convención del curso: files, docs, pre y output.
# Hazlo de forma que volver a ejecutar la línea no produzca un error si la
# carpeta ya existe.
#
# Pistas: dir.exists() pregunta, dir.create() crea, y `!` niega una condición.

#| solucion
for (carpeta in c("files", "docs", "pre", "output")) {
    if (!dir.exists(carpeta)) {
        dir.create(carpeta)
    }
}
#| fin

#| nota
# El `for` no se ha enseñado (es la Sesión 5). Aceptar CUALQUIER solución que
# funcione, incluidas cuatro líneas de dir.create() repetidas. Mostrar el `for`
# al final solo como adelanto: "esto mismo, sin repetirse". No explicarlo.
#| fin

# Verifica el resultado:

list.dirs(recursive = FALSE)

# ¿Qué devuelve la línea siguiente, y qué tipo tiene?

file.exists("files")


## 3. La mini encuesta -------------------------------------------------------=

# Doce personas respondieron tres preguntas. Construye un vector para cada una.
# Los datos:
#
#   edad:      34, 19, 67, 45, 23, 58, 71, 29, 16, 40, 52, 38
#   sexo:      M, H, M, M, H, H, M, H, M, H, M, H
#   segura:    2, 1, 2, 2, 1, 2, 2, 1, 1, 2, 2, 1
#
# La tercera es la pregunta "¿considera que vivir en su ciudad es seguro?",
# codificada como en las encuestas reales: 1 = seguro, 2 = inseguro.

#| solucion
edad = c(34, 19, 67, 45, 23, 58, 71, 29, 16, 40, 52, 38)
sexo = c("M", "H", "M", "M", "H", "H", "M", "H", "M", "H", "M", "H")
segura = c(2, 1, 2, 2, 1, 2, 2, 1, 1, 2, 2, 1)
#| fin

# Verifica que los tres tengan la misma longitud. Si no, hay un error de captura.

#| solucion
length(edad)
length(sexo)
length(segura)

length(edad) == length(sexo)
#| fin

#| nota
# Aquí aparece el primer uso "real" de una condición lógica: verificar la
# consistencia de los datos. Vale la pena nombrarlo: esto es lo que se hace al
# importar un archivo de verdad, que es la Sesión 2.
#| fin


## 4. Tipos y coerción -------------------------------------------------------=

# a) Averigua el tipo de cada uno de los tres vectores.

#| solucion
typeof(edad)
typeof(sexo)
typeof(segura)
#| fin

# b) `segura` guarda códigos, no cantidades. Calcular su promedio no significa
#    nada, pero R lo hace de todos modos. Compruébalo.

#| solucion
mean(segura)
# 1.583...: el promedio de un código es un número sin interpretación. R no sabe
# que 1 y 2 son etiquetas; hay que saberlo nosotros.
#| fin

#| nota
# Este inciso es más importante de lo que parece. Es la diferencia entre que R
# te avise de un error y que te devuelva un número equivocado con toda calma.
# Insistir: el lenguaje no protege contra preguntas mal planteadas.
#| fin

# c) Agrega la respuesta "no especificado" al vector `edad`. Antes de ejecutarlo,
#    predice qué tipo tendrá el resultado. ¿Coincidió?

#| solucion
edad_mixta = c(edad, "no especificado")
typeof(edad_mixta)
# character: basta un elemento de texto para arrastrar todo el vector.
#| fin

# d) Intenta ahora sumar 1 a `edad_mixta`. ¿Qué ocurre?

#| solucion
# edad_mixta + 1
# Error: argumento no-numérico para operador binario. La columna dejó de ser
# numérica y toda la aritmética falla. Este es el error más caro de la
# importación de datos.
#| fin

# e) Recupera un vector numérico a partir de `edad_mixta`. ¿Qué pasó con el
#    elemento de texto?

#| solucion
as.numeric(edad_mixta)
# El texto se convierte en NA, con una advertencia. La coerción explícita no
# inventa datos: lo que no puede convertir, lo marca como desconocido.
#| fin


## 5. Vectorización ----------------------------------------------------------=

# a) Todas las personas cumplieron años. Suma 1 a cada edad, sin escribir doce
#    operaciones.

#| solucion
edad + 1
#| fin

# b) Calcula la edad de cada persona en meses.

#| solucion
edad * 12
#| fin

# c) Calcula cuántos años le faltan a cada persona para cumplir 65.

#| solucion
65 - edad
#| fin

# d) ¿Qué observas en el resultado del inciso anterior para las personas que ya
#    pasaron los 65? ¿Tiene sentido?

#| nota
# Salen negativos. Preguntar qué habría que hacer para que no aparezcan. Nadie
# tiene aún las herramientas (if_else es la Sesión 4), y está bien: la idea es
# que noten la limitación y la recuerden cuando llegue.
#| fin


## 6. Condiciones lógicas ----------------------------------------------------=

#| nota
# EL NÚCLEO DE LA SESIÓN. Reservar 20 minutos completos. Todo indicador que
# construyan el resto del semestre sale de esta idea.
#| fin

# a) Construye un vector lógico que indique, para cada persona, si es mayor de
#    edad.

#| solucion
edad >= 18
#| fin

# b) ¿Cuántas personas son mayores de edad? Una sola línea.

#| solucion
sum(edad >= 18)
#| fin

# c) ¿Qué proporción del total representan?

#| solucion
mean(edad >= 18)
#| fin

# d) Explica en una línea de comentario por qué funciona el inciso anterior.

#| solucion
# Porque TRUE vale 1 y FALSE vale 0. La suma de los TRUE es el conteo, y el
# promedio de ceros y unos es la proporción de unos.
#| fin

# e) ¿Qué proporción de las personas está en edad de trabajar (18 a 64 años)?

#| solucion
mean(edad >= 18 & edad < 65)
#| fin

# f) ¿Qué proporción percibe su ciudad como insegura? Recuerda que 2 = inseguro.

#| solucion
mean(segura == 2)
#| fin

# g) ¿Qué proporción son mujeres que perciben inseguridad? Ojo: esto NO es lo
#    mismo que la pregunta del inciso siguiente.

#| solucion
mean(sexo == "M" & segura == 2)
#| fin

# h) De las mujeres, ¿qué proporción percibe inseguridad? Pista: es un cociente
#    entre dos conteos.

#| solucion
sum(sexo == "M" & segura == 2) / sum(sexo == "M")
#| fin

#| nota
# g) frente a h) es la distinción entre proporción conjunta y proporción
#    condicional, y es donde más se equivocan. Escribir los dos resultados en el
#    pizarrón, lado a lado, y preguntar cuál responde "¿las mujeres se sienten
#    más inseguras?". Vale la pena gastar cinco minutos aquí.
#| fin

# i) ¿Hay alguna persona menor de edad en la muestra? ¿Todas son mayores de 15?

#| solucion
any(edad < 18)
all(edad > 15)
#| fin


## 7. Valores faltantes ------------------------------------------------------=

# Una persona no quiso dar su edad. Vuelve a capturar el vector con ese dato
# desconocido en la tercera posición:

edad_na = c(34, 19, NA, 45, 23, 58, 71, 29, 16, 40, 52, 38)

# a) Calcula la proporción de mayores de edad. ¿Qué devuelve, y por qué?

#| solucion
mean(edad_na >= 18)
# NA. No sabemos si la persona desconocida es mayor de edad, así que tampoco
# podemos saber la proporción exacta. El NA se propaga a través del cálculo.
#| fin

# b) Corrígelo excluyendo el dato faltante.

#| solucion
mean(edad_na >= 18, na.rm = TRUE)
#| fin

# c) ¿Cuántos datos faltantes hay? Cuidado: `edad_na == NA` no sirve.

#| solucion
sum(is.na(edad_na))
#| fin

# d) Prueba `edad_na == NA` y explica por qué devuelve lo que devuelve.

#| solucion
edad_na == NA
# Devuelve NA en todas las posiciones. Preguntar si un valor desconocido es
# igual a otro valor desconocido no tiene respuesta: R contesta "no sé".
#| fin

#| nota
# El inciso d) explica por qué existe is.na(). Es la causa número uno de filtros
# que no filtran nada, y lo van a arrastrar hasta dplyr si no queda claro hoy.
#| fin

# e) ¿Sobre cuántas personas se calculó realmente la proporción del inciso b)?

#| solucion
sum(!is.na(edad_na))
# na.rm = TRUE no rellena el dato: lo saca del denominador. La proporción se
# calculó sobre 11 personas, no sobre 12. Eso hay que reportarlo, no esconderlo.
#| fin


## 8. Listas -----------------------------------------------------------------=

# Los resultados del ejercicio 6 son de tipos distintos: conteos, proporciones y
# lógicos. Guárdalos juntos en una lista con nombres.

#| solucion
resultados = list(
    n_mayores = sum(edad >= 18),
    prop_mayores = mean(edad >= 18),
    prop_insegura = mean(segura == 2),
    hay_menores = any(edad < 18)
)
#| fin

# Extrae la proporción de personas que perciben inseguridad, de dos maneras
# distintas.

#| solucion
resultados$prop_insegura
resultados[["prop_insegura"]]
#| fin

# Inspecciona la lista completa:

str(resultados)


## 9. Integrador (opcional) --------------------------------------------------=

# Con los tres vectores originales, responde en un solo bloque de código:
#
#   - ¿Cuál es la edad promedio de quienes perciben inseguridad?
#   - ¿Y la de quienes no?
#   - ¿La diferencia te parece grande?
#
# Pista: no necesitas nada que no hayas usado ya. Un promedio es una suma entre
# un conteo, y ya sabes contar con condiciones lógicas.

#| solucion
sum(edad * (segura == 2)) / sum(segura == 2)
sum(edad * (segura == 1)) / sum(segura == 1)
# El vector lógico multiplica: los FALSE se vuelven 0 y no aportan a la suma.
# Es el mismo truco de siempre, ahora como filtro aritmético.
#| fin

#| nota
# Este ejercicio se resuelve mucho más fácil con indexación (edad[segura == 2]),
# que es la Sesión 2. Si alguien lo propone, celebrarlo y mostrarlo: es el
# puente perfecto hacia la próxima clase. Si nadie lo propone, cerrar con eso.
#| fin
