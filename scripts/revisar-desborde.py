"""Detecta diapositivas cuyo contenido se sale del lienzo.

Uso: python3 scripts/revisar-desborde.py <carpeta_de_capturas> <slides.md>

Mide, en cada captura de 1280x720, la distancia entre la última tinta del
cuerpo y el borde superior del pie de página. Menos de 25 px es señal de que
el contenido quedó tapado.
"""
import io, re, sys
from PIL import Image
import numpy as np

capturas, md = sys.argv[1], sys.argv[2]
P = re.split(r"(?=\n---\nlayout:)", io.open(md, encoding="utf-8").read())

filas = []
for i, p in enumerate(P):
    if not re.search(r"(?m)^layout: default$", p):
        continue                                   # portadas y divisores no llevan pie
    n = i + 1
    tit = re.search(r"(?m)^# (.+)$", p)
    a = np.asarray(Image.open(f"{capturas}/s{n:02d}.png").convert("L")).astype(int)
    alto = a.shape[0]
    media_fila = a[:, 200:1000].mean(axis=1)
    y = alto - 1
    while y > 0 and media_fila[y] < 120:           # el pie es una barra oscura
        y -= 1
    pie = y + 1
    tinta = (a[:pie, 40:1000] < 170).sum(axis=1)   # se excluye el logo (x > 1000)
    ultimo = int(np.max(np.nonzero(tinta > 0))) if (tinta > 0).any() else 0
    filas.append((pie - ultimo, n, (tit.group(1) if tit else "")[:42]))

filas.sort()
for holgura, n, tit in filas[:6]:
    print(f"  {holgura:4d} px libres   diapositiva {n:2d}   {tit}")
malas = [n for holgura, n, _ in filas if holgura < 25]
print("\nSE DESBORDAN:", sorted(malas) if malas else "ninguna")
sys.exit(1 if malas else 0)
