#!/usr/bin/env python3
"""Deriva los scripts de estudiante a partir de los scripts del instructor.

Una sola fuente, tres artefactos:

    slides/semana_NN/code/sesion_NN.R     INSTRUCTOR  código + notas de clase
    code/pre/sesion_NN.R                  EJERCICIOS  huecos, sin notas
    build/soluciones/sesion_NN_solucion.R SOLUCIÓN    código, sin notas

Los EJERCICIOS se reparten al inicio del curso, empaquetados con el proyecto R
en build/curso-ppd.zip. La SOLUCIÓN se entrega al cierre de cada sesión: lleva
sufijo _solucion para que el estudiante la deje caer en pre/ sin sobrescribir
lo que escribió en clase.

Marcas reconocidas dentro del script del instructor:

    #| ejercicio            En EJERCICIOS el bloque se sustituye por un hueco
    codigo resuelto         con la leyenda "# (escribe el código aquí)"; el
    #| fin                  comentario que antecede queda como consigna.
                            En SOLUCIÓN el bloque se conserva íntegro.

    #| nota                 Se elimina en ambas versiones de estudiante. Para
    # recordatorio          apuntes de clase, tiempos y énfasis.
    #| fin

Las marcas son comentarios válidos de R: el script del instructor corre tal cual.

Uso:
    python3 scripts/build-code.py            # deriva ejercicios y soluciones
    python3 scripts/build-code.py --zip      # además empaqueta los dos zips
"""
import argparse
import re
import shutil
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
EJERCICIOS = RAIZ / "code"
BUILD = RAIZ / "build"
SOLUCIONES = BUILD / "soluciones"
NOMBRE_PROYECTO = "curso-ppd"

ABRE = re.compile(r"^\s*#\|\s*(ejercicio|nota)\s*$")
CIERRA = re.compile(r"^\s*#\|\s*fin\s*$")
CABECERA = re.compile(r"^(# Script:\s+)(sesion_\d{2})\.R\s*$")
HUECO = "# (escribe el código aquí)"


def derivar(texto: str, variante: str) -> str:
    """variante: 'ejercicios' vacía los bloques #| ejercicio; 'solucion' los conserva."""
    salida, modo = [], None
    for linea in texto.splitlines():
        if modo is None:
            apertura = ABRE.match(linea)
            if apertura:
                modo = apertura.group(1)
                if modo == "ejercicio" and variante == "ejercicios":
                    salida.extend([HUECO, "", ""])
                continue
            if variante == "solucion":
                cabecera = CABECERA.match(linea)
                if cabecera:
                    salida.append(f"{cabecera.group(1)}{cabecera.group(2)}_solucion.R")
                    continue
            salida.append(linea)
        elif CIERRA.match(linea):
            # El cuerpo de #| ejercicio se conserva en 'solucion' y se descarta
            # en 'ejercicios'; el de #| nota se descarta siempre.
            modo = None
        elif modo == "ejercicio" and variante == "solucion":
            salida.append(linea)
    if modo is not None:
        raise ValueError(f"bloque #| {modo} sin su #| fin")
    return "\n".join(salida) + "\n"


def fuentes() -> list[Path]:
    encontradas = sorted(RAIZ.glob("slides/semana_*/code/sesion_*.R"))
    return [p for p in encontradas if re.fullmatch(r"sesion_\d{2}\.R", p.name)]


def empaquetar(origen: Path, nombre: str, base: str) -> Path:
    staging = BUILD / "_staging" / base
    if staging.parent.exists():
        shutil.rmtree(staging.parent)
    staging.parent.mkdir(parents=True)
    shutil.copytree(
        origen, staging,
        ignore=shutil.ignore_patterns(".DS_Store", ".gitkeep", "*.Rproj.user"),
    )
    archivo = shutil.make_archive(str(BUILD / nombre), "zip",
                                  root_dir=staging.parent, base_dir=base)
    shutil.rmtree(staging.parent)
    return Path(archivo)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--zip", action="store_true", help="empaquetar el resultado")
    args = parser.parse_args()

    (EJERCICIOS / "pre").mkdir(parents=True, exist_ok=True)
    SOLUCIONES.mkdir(parents=True, exist_ok=True)

    for origen in fuentes():
        texto = origen.read_text(encoding="utf-8")
        etiqueta = origen.relative_to(RAIZ)

        ejercicios = EJERCICIOS / "pre" / origen.name
        ejercicios.write_text(derivar(texto, "ejercicios"), encoding="utf-8")

        solucion = SOLUCIONES / f"{origen.stem}_solucion.R"
        solucion.write_text(derivar(texto, "solucion"), encoding="utf-8")

        print(f"{etiqueta}\n"
              f"    -> {ejercicios.relative_to(RAIZ)}\n"
              f"    -> {solucion.relative_to(RAIZ)}")

    if args.zip:
        z1 = empaquetar(EJERCICIOS, NOMBRE_PROYECTO, NOMBRE_PROYECTO)
        z2 = empaquetar(SOLUCIONES, f"{NOMBRE_PROYECTO}-soluciones", "soluciones")
        print(f"\nzip (inicio del curso): {z1.relative_to(RAIZ)}")
        print(f"zip (cierre del curso): {z2.relative_to(RAIZ)}")
        print("Para entregar una sola sesión, usa el archivo suelto de build/soluciones/.")


if __name__ == "__main__":
    main()
