# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_05.R
# Objetivo:       Pasar de consumidor a autor de código: control de flujo, vectorización
#                 y diseño de funciones propias.
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

# Paquetes de la sesión
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(tidyverse)


# CODIGO ______________________________________________________________________

# CONTROL DE FLUJO _____________________________________________________________

## Condicionales: if y else ----------------------------------------------------=


## switch() --------------------------------------------------------------------=


## Loops: for y while ----------------------------------------------------------=


## break y next ----------------------------------------------------------------=


# VECTORIZACIÓN ________________________________________________________________

## Operaciones elemento a elemento ---------------------------------------------=


## Reglas de recycling ---------------------------------------------------------=


## Funciones acumuladoras ------------------------------------------------------=


## Contrapatrones de iteración -------------------------------------------------=


# FUNCIONES ____________________________________________________________________

## Anatomía y diseño -----------------------------------------------------------=


## Argumentos y valores por defecto --------------------------------------------=


## Scoping léxico --------------------------------------------------------------=


## Funciones puras y side effects ----------------------------------------------=


# ERRORES Y DEBUGGING __________________________________________________________

## stop(), warning(), message() ------------------------------------------------=


## Validación con stopifnot() --------------------------------------------------=


## Captura con tryCatch() ------------------------------------------------------=


## traceback() y browser() -----------------------------------------------------=


# NSE EN FUNCIONES _____________________________________________________________

## El operador embrace {{ }} ---------------------------------------------------=


## Nombres dinámicos con := ----------------------------------------------------=

