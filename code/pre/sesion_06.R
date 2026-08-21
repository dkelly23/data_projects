# _____________________________________________________________________________
#
# Proyecto:       Programación para Proyectos de Datos
#
# Script:         sesion_06.R
# Objetivo:       Iterar sobre colecciones sin loops y cerrar el curso con un producto
#                 visual construido por capas.
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
pacman::p_load(tidyverse, scales)


# CODIGO ______________________________________________________________________

# EL PARADIGMA FUNCIONAL _______________________________________________________

## Funciones como objetos de primera clase -------------------------------------=


## La familia apply de base R --------------------------------------------------=


# PURRR ________________________________________________________________________

## map() y sus variantes tipadas -----------------------------------------------=


## map2() y pmap() -------------------------------------------------------------=


## walk() para side effects ----------------------------------------------------=


## Funciones anónimas ----------------------------------------------------------=


## reduce(), keep() y discard() ------------------------------------------------=


# ACROSS _______________________________________________________________________

## across() en mutate() y summarize() ------------------------------------------=


## if_any() e if_all() ---------------------------------------------------------=


# GRAMÁTICA DE GRÁFICAS ________________________________________________________

## Las capas de ggplot2 --------------------------------------------------------=


## Aesthetics: mapping frente a setting ----------------------------------------=


## Geometrías ------------------------------------------------------------------=


# AJUSTE Y EXPORTACIÓN _________________________________________________________

## Scales y formatters ---------------------------------------------------------=


## Facets ----------------------------------------------------------------------=


## Themes ----------------------------------------------------------------------=


## ggsave() --------------------------------------------------------------------=

