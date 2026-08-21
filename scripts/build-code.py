#!/usr/bin/env python3
"""Deriva el material de estudiante a partir de los scripts del instructor.

Cada sesión tiene DOS documentos, que corresponden a los dos bloques de la
sesión de 3:00 hr:

  BLOQUE DE EXPOSICIÓN        slides/semana_NN/code/sesion_NN.R
      El guion que el instructor reproduce en vivo, con sus notas de clase.
      Al cierre de la sesión se entrega limpio: build/sesiones/sesion_NN.R

  BLOQUE DE PRÁCTICA          slides/semana_NN/code/ejercicios_NN.R
      Las consignas más las respuestas del instructor. Los estudiantes lo
      reciben vacío desde el inicio: code/pre/ejercicios_NN.R

Marcas reconocidas (comentarios válidos de R: las fuentes corren tal cual):

    #| nota                 Apuntes de clase, tiempos, énfasis. Se eliminan de
    # recordar preguntar    todo lo que llega a los estudiantes.
    #| fin

    #| solucion             La respuesta a un ejercicio. En la versión de
    resultado = ...         estudiante se sustituye por un hueco con la leyenda
    #| fin                  "# (escribe el código aquí)". Solo en ejercicios_NN.R.

Uso:
    python3 scripts/build-code.py            # deriva todo
    python3 scripts/build-code.py --zip      # además empaqueta los zips
"""
import argparse
import re
import shutil
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PROYECTO = RAIZ / "code"
BUILD = RAIZ / "build"
SESIONES = BUILD / "sesiones"
NOMBRE_PROYECTO = "curso-ppd"

ABRE = re.compile(r"^\s*#\|\s*(solucion|nota)\s*$")
CIERRA = re.compile(r"^\s*#\|\s*fin\s*$")
HUECO = "# (escribe el código aquí)"


def derivar(texto: str) -> str:
    """Elimina las notas del instructor y vacía los bloques de solución."""
    salida, modo = [], None
    for linea in texto.splitlines():
        if modo is None:
            apertura = ABRE.match(linea)
            if apertura:
                modo = apertura.group(1)
                if modo == "solucion":
                    salida.extend([HUECO, "", ""])
                continue
            salida.append(linea)
        elif CIERRA.match(linea):
            modo = None
    if modo is not None:
        raise ValueError(f"bloque #| {modo} sin su #| fin")
    return "\n".join(salida) + "\n"


def fuentes(prefijo: str) -> list[Path]:
    patron = re.compile(rf"{prefijo}_\d{{2}}\.R")
    return sorted(p for p in RAIZ.glob(f"slides/semana_*/code/{prefijo}_*.R")
                  if patron.fullmatch(p.name))


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

    (PROYECTO / "pre").mkdir(parents=True, exist_ok=True)
    SESIONES.mkdir(parents=True, exist_ok=True)

    print("Ejercicios (se reparten al inicio del curso):")
    for origen in fuentes("ejercicios"):
        destino = PROYECTO / "pre" / origen.name
        destino.write_text(derivar(origen.read_text(encoding="utf-8")), encoding="utf-8")
        print(f"  {origen.relative_to(RAIZ)} -> {destino.relative_to(RAIZ)}")

    print("\nGuiones limpios (se entregan al cierre de cada sesión):")
    for origen in fuentes("sesion"):
        destino = SESIONES / origen.name
        destino.write_text(derivar(origen.read_text(encoding="utf-8")), encoding="utf-8")
        print(f"  {origen.relative_to(RAIZ)} -> {destino.relative_to(RAIZ)}")

    if args.zip:
        z1 = empaquetar(PROYECTO, NOMBRE_PROYECTO, NOMBRE_PROYECTO)
        z2 = empaquetar(SESIONES, f"{NOMBRE_PROYECTO}-sesiones", "sesiones")
        print(f"\nzip (inicio del curso):  {z1.relative_to(RAIZ)}")
        print(f"zip (cierre del curso):  {z2.relative_to(RAIZ)}")
        print("Para entregar una sola sesión, usa el archivo suelto de build/sesiones/.")


if __name__ == "__main__":
    main()
