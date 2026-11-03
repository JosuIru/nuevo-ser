"""Icono pequeño de las notificaciones de Android a partir del logo.

Android pinta ese icono solo con su transparencia (silueta de un color):
lo verde del logo queda opaco y lo blanco (persona, manos, pasto, vaca),
transparente. Regenerar si cambia el logo:

    python3 -I tool/generar_icono_notificacion.py
"""
from pathlib import Path

from PIL import Image, ImageChops

RAIZ = Path(__file__).resolve().parent.parent
ORIGEN = RAIZ / "assets" / "icono-logo-zunbeltz.png"
RES = RAIZ / "android" / "app" / "src" / "main" / "res"
TAMANOS = {"mdpi": 24, "hdpi": 36, "xhdpi": 48, "xxhdpi": 72, "xxxhdpi": 96}

logo = Image.open(ORIGEN).convert("RGB")
rojo, verde, azul = logo.split()
canal_minimo = ImageChops.darker(rojo, ImageChops.darker(verde, azul))
# Cuánto se aparta del blanco: el verde más claro (la vaca) ronda 150.
silueta = canal_minimo.point(lambda valor: max(0, min(255, (255 - valor) * 255 // 80)))
caja = silueta.point(lambda valor: 255 if valor > 128 else 0).getbbox()
silueta = silueta.crop(caja)
lado = max(silueta.size)
# Android deja ~2 dp de margen en un lienzo de 24: el dibujo ocupa 20/24.
lienzo = round(lado * 24 / 22)
cuadrado = Image.new("L", (lienzo, lienzo))
cuadrado.paste(silueta, ((lienzo - silueta.width) // 2, (lienzo - silueta.height) // 2))
for densidad, tamano in TAMANOS.items():
    alfa = cuadrado.resize((tamano, tamano), Image.LANCZOS)
    icono = Image.new("RGBA", (tamano, tamano), (255, 255, 255, 0))
    icono.putalpha(alfa)
    destino = RES / f"drawable-{densidad}" / "ic_notificacion.png"
    icono.save(destino, optimize=True)
    print(destino.relative_to(RAIZ), tamano)
