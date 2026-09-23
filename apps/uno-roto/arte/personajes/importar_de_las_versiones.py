"""Retratos PROVISIONALES para Uno Roto tomados de Las Versiones.

Los retratos de `apps/las-versiones/assets/personajes/` (acuarela,
generados con DALL-E 3 y relicenciados como contenido de la Colección,
CC-BY-SA 4.0) se reutilizan para los personajes de Uno Roto que aún no
tienen dibujo, eligiendo el que mejor encaja con la biblia (doc 04).
Se viran a la paleta nocturna de Uno Roto (doc 11) y se recortan en
círculo con el borde difuminado. Uso:

    python3 importar_de_las_versiones.py
"""
import os

import numpy as np
from PIL import Image, ImageFilter

ORIGEN = os.path.join(os.path.dirname(__file__), '..', '..', '..', 'las-versiones',
                      'assets', 'personajes')
DESTINO = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'personajes',
                       'retratos')

# Uno Roto → retrato de Las Versiones (por parecido con la biblia).
ASIGNACION = {
    'sora': 'eider',        # 13, seria, chaqueta oscura de cremallera
    'irune': 'isaura',      # pelo plateado recogido, broche antiguo al cuello
    'rexan': 'andres',      # barba entrecana, calidez
    'naini': 'iratxe',      # pelo recogido, tonos tierra
    'vadic': 'arqueologo',  # gafas metálicas, aire metódico
    'brina': 'arqueologa',  # investigadora de campo
    'ari': 'sira',          # niña amable con cuaderno
}

# Virado nocturno: sombras azul medianoche, medios lavanda, luces ámbar vela.
PARADAS = [(0.0, (11, 14, 31)), (0.45, (60, 58, 115)), (0.8, (150, 138, 178)),
           (1.0, (226, 200, 150))]


def virar(imagen):
    gris = np.asarray(imagen.convert('L'), dtype=np.float32) / 255
    # Estira el contraste: la acuarela sepia es muy plana.
    bajo, alto = np.percentile(gris, [2, 98])
    gris = np.clip((gris - bajo) / (alto - bajo + 1e-6), 0, 1)
    # Viñeta: la cara queda iluminada y el papel del fondo se hunde en la
    # noche (si no, domina un disco claro).
    alto_px, ancho_px = gris.shape
    y, x = np.ogrid[:alto_px, :ancho_px]
    radio = np.sqrt(((x - ancho_px / 2) / (ancho_px / 2)) ** 2
                    + ((y - alto_px * 0.42) / (alto_px / 2)) ** 2)
    gris = gris * np.clip(1.15 - 0.75 * np.clip(radio - 0.35, 0, 1) ** 1.2, 0.3, 1)
    salida = np.zeros(gris.shape + (3,), dtype=np.float32)
    for canal in range(3):
        salida[..., canal] = np.interp(gris, [p for p, _ in PARADAS],
                                       [c[canal] for _, c in PARADAS])
    return Image.fromarray(salida.astype(np.uint8)).convert('RGB')


def circulo(imagen, lado=400):
    imagen = imagen.resize((lado, lado), Image.LANCZOS)
    mascara = Image.new('L', (lado, lado), 0)
    y, x = np.ogrid[:lado, :lado]
    distancia = np.sqrt((x - lado / 2) ** 2 + (y - lado / 2) ** 2) / (lado / 2)
    alfa = np.clip((0.97 - distancia) / 0.1, 0, 1) * 255
    mascara = Image.fromarray(alfa.astype(np.uint8)).convert('L').filter(
        ImageFilter.GaussianBlur(2))
    salida = imagen.convert('RGBA')
    salida.putalpha(mascara)
    return salida


if __name__ == '__main__':
    os.makedirs(DESTINO, exist_ok=True)
    for id_personaje, fuente in ASIGNACION.items():
        original = Image.open(os.path.join(ORIGEN, f'{fuente}.jpg'))
        # Recorte al óvalo del retrato (el marco de papel queda fuera).
        ancho, alto = original.size
        recorte = original.crop((int(ancho * 0.12), int(alto * 0.06),
                                 int(ancho * 0.88), int(alto * 0.82)))
        retrato = circulo(virar(recorte))
        ruta = os.path.join(DESTINO, f'{id_personaje}.webp')
        retrato.save(ruta, quality=86, method=6)
        print(f'{id_personaje:6s} ← {fuente:11s} {os.path.getsize(ruta) // 1024} KB')
