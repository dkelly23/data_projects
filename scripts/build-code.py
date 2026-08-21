#!/usr/bin/env python3
"""Deriva los scripts de estudiante a partir de los scripts del instructor.

Fuente:  slides/semana_NN/code/sesion_NN.R   (versión completa, del instructor)
Destino: code/pre/sesion_NN.R                (esqueleto, para los estudiantes)

Marcas reconocidas dentro del script del instructor:

    #| ejercicio            El bloque hasta `#| fin` se sustituye por un hueco
    codigo resuelto         con la leyenda "# (escribe el código aquí)". El
    #| fin                  comentario que antecede al bloque queda como consigna.

    #| nota                 El bloque hasta `#| fin` se elimina por completo.
    # recordatorio          Sirve para apuntes de clase que el estudiante no ve.
    #| fin

Las marcas son comentarios válidos de R: el script del instructor corre tal cual.

Uso:
    python3 scripts/build-code.py            # deriva los esqueletos
    python3 scripts/build-code.py --zip      # deriva y empaqueta curso-ppd.zip
"""
import argparse
import re
import shutil
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "code"
NOMBRE_PROYECTO = "curso-ppd"

ABRE = re.compile(r"^\s*#\|\s*(ejercicio|nota)\s*$")
CIERRA = re.compile(r"^\s*#\|\s*fin\s*$")
HUECO = "# (escribe el código aquí)"


def derivar(texto: str) -> str:
    salida, modo = [], None
    for linea in texto.splitlines():
        if modo is None:
            apertura = ABRE.match(linea)
            if apertura:
                modo = apertura.group(1)
                if modo == "ejercicio":
                    salida.extend([HUECO, "", ""])
                continue
            salida.append(linea)
        elif CIERRA.match(linea):
            modo = None
    if modo is not None:
        raise ValueError(f"bloque #| {modo} sin su #| fin")
    return "\n".join(salida) + "\n"


def fuentes() -> list[Path]:
    encontradas = sorted(RAIZ.glob("slides/semana_*/code/sesion_*.R"))
    return [p for p in encontradas if re.fullmatch(r"sesion_\d{2}\.R", p.name)]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--zip", action="store_true", help="empaquetar el resultado")
    args = parser.parse_args()

    (DESTINO / "pre").mkdir(parents=True, exist_ok=True)
    for origen in fuentes():
        destino = DESTINO / "pre" / origen.name
        destino.write_text(derivar(origen.read_text(encoding="utf-8")), encoding="utf-8")
        print(f"{origen.relative_to(RAIZ)} -> {destino.relative_to(RAIZ)}")

    if args.zip:
        staging = RAIZ / "build" / NOMBRE_PROYECTO
        if staging.exists():
            shutil.rmtree(staging)
        staging.parent.mkdir(exist_ok=True)
        shutil.copytree(
            DESTINO, staging,
            ignore=shutil.ignore_patterns(".DS_Store", ".gitkeep", "*.Rproj.user"),
        )
        archivo = shutil.make_archive(str(RAIZ / "build" / NOMBRE_PROYECTO), "zip",
                                      root_dir=staging.parent, base_dir=NOMBRE_PROYECTO)
        shutil.rmtree(staging)
        print(f"\nzip: {Path(archivo).relative_to(RAIZ)}")


if __name__ == "__main__":
    main()
