#!/usr/bin/env python3
"""Deriva el temario sucinto a partir del temario completo.

De cada sesión conserva únicamente el encabezado, los objetivos de aprendizaje,
las lecturas y la referencia rápida. Elimina el párrafo introductorio, el bloque
de subtemas y el bloque de práctica. Todas las secciones globales (Presentación,
Objetivos, Prerrequisitos, Metodología, Evaluación, Hilo conductor, Estructura,
Continuidad, Referencias) se conservan intactas.

Uso: python3 derivar-sucinto.py curso-1
"""
import re
import sys
from pathlib import Path

INICIO = re.compile(r"^\\sesion\{")
CORTE = re.compile(r"^\\noindent\\textbf\{Objetivos de aprendizaje\}")


def derivar(texto: str) -> str:
    salida, saltando = [], False
    for linea in texto.splitlines():
        if INICIO.match(linea):
            salida.append(linea)
            saltando = True
            continue
        if saltando:
            if CORTE.match(linea):
                salida.append("\\medskip")
                salida.append(linea)
                saltando = False
            continue
        salida.append(linea)
    return "\n".join(salida) + "\n"


def ajustar_titulo(texto: str) -> str:
    texto = texto.replace(
        r"\large\color{subtitle}Temario del Curso",
        r"\large\color{subtitle}Temario sucinto: objetivos y lecturas por sesión",
    )
    return texto.replace("Temario del Curso}", "Temario sucinto}")


def main() -> None:
    curso = sys.argv[1] if len(sys.argv) > 1 else "curso-1"
    raiz = Path(__file__).parent / curso
    origen = raiz / "temario-completo" / "syllabus.tex"
    destino = raiz / "temario-sucinto" / "temario-sucinto.tex"
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(ajustar_titulo(derivar(origen.read_text())), encoding="utf-8")
    print(f"{destino.relative_to(Path(__file__).parent)}: {len(destino.read_text().splitlines())} líneas")


if __name__ == "__main__":
    main()
