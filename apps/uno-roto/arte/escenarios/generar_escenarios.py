"""Escenarios ilustrados de los distritos (cazadero) con flavor3d.

Vista frontal ortográfica con fondo TRANSPARENTE: el juego sigue pintando
detrás su cielo animado (lunas, estrellas, niebla y lluvia del clima) y
encima los Fragmentos. Cada distrito se renderiza dos veces con la misma
geometría: `apagado` (pocas ventanas) y `encendido` (muchas); el juego
las funde según `nivelRestauracion` (la ciudad se enciende al avanzar).
Moodboard: doc 11, "Distritos". Uso:

    python3 generar_escenarios.py && for s in specs/*.yaml; do flavor3d run $s; done
    python3 copiar.py
"""
import math
import os
import random
import sys

import yaml

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'maquinas'))
from generar_specs import srgb  # noqa: E402

SOLO = os.environ.get('SOLO')
TAMANO = [1080, 1200]
ALTO_VISTO = 12.0   # unidades de mundo en vertical (ortográfica)


class Escena:
    def __init__(self, semilla, encendido):
        self.azar = random.Random(semilla)
        self.encendido = encendido
        self.objetos = []
        self.n = 0

    def mat(self, color, rough=0.75, emision=None, fuerza=0.0):
        m = {'base_color': srgb(color), 'roughness': rough}
        if emision:
            m['emission_color'] = srgb(emision)
            m['emission_strength'] = fuerza
        return m

    def prim(self, forma, loc, escala, material, rot=None):
        self.n += 1
        e = {'type': 'primitive', 'shape': forma, 'name': f'o{self.n}',
             'location': loc, 'scale': escala, 'material': material}
        if rot:
            e['rotation'] = rot
        self.objetos.append(e)

    def caja(self, x, y, z, sx, sy, sz, color, rot=None, **kw):
        self.prim('cube', [x, y, z], [sx, sy, sz], self.mat(color, **kw), rot=rot)

    def luz(self, x, y, z, energia, color):
        self.n += 1
        self.objetos.append({'type': 'light', 'kind': 'point', 'name': f'l{self.n}',
                             'location': [x, y, z], 'energy': energia,
                             'color': srgb(color)[:3]})

    def ventanas(self, x, y_frente, ancho, alto, base=0.0, densidad=1.0, color='#E8A857'):
        """Ventanas en la cara que mira a la cámara. Cada una tiene su
        umbral fijo (misma semilla): apagado enciende pocas, encendido
        muchas, y siempre las mismas."""
        filas = max(1, int(alto / 0.45))
        columnas = max(1, int(ancho / 0.4))
        limite = (0.22 if not self.encendido else 0.8) * densidad
        for f in range(filas):
            for c in range(columnas):
                if self.azar.random() < limite:
                    self.caja(x - ancho / 2 + (c + 0.5) * ancho / columnas, y_frente - 0.02,
                              base + 0.35 + f * 0.45, 0.07, 0.02, 0.1,
                              color, rough=0.4, emision=color, fuerza=2.4)

    def edificio(self, x, y, ancho, fondo, alto, color, densidad=1.0, tejado=None):
        self.caja(x, y, alto / 2, ancho / 2, fondo / 2, alto / 2, color)
        self.ventanas(x, y - fondo / 2, ancho, alto, densidad=densidad)
        if tejado:
            # Tejado a dos aguas: prisma (cubo girado 45°) aplastado.
            self.caja(x, y, alto, ancho / 2 + 0.05, fondo / 2 * 0.72, fondo / 2 * 0.72,
                      tejado, rot=[math.pi / 4, 0, 0])

    def farolillo(self, x, y, z, color='#F2D58E', energia=18):
        self.prim('sphere', [x, y, z], [0.08, 0.08, 0.08],
                  self.mat(color, 0.3, color, 4.0))
        if self.encendido:
            self.luz(x, y - 0.3, z, energia, color)

    def montana_lejana(self, x=0.0, alto=6.5, nieve=True):
        # Cresta: un cono principal y dos hombros más bajos.
        self.prim('cone', [x, 40, alto / 2], [7, 3, alto / 2], self.mat('#2B2F63', 0.9))
        for dx, factor in ((-2.4, 0.78), (2.8, 0.7)):
            self.prim('cone', [x + dx, 40.5, alto * factor / 2], [5, 2.5, alto * factor / 2],
                      self.mat('#2B2F63', 0.9))
        if nieve:
            # Misma pendiente que la montaña (radio/alto = 7/alto): si no,
            # parece un gorro de papel.
            parte = 0.26
            self.prim('cone', [x, 39.9, alto * (1 - parte / 2)],
                      [7 * parte, 3 * parte, alto * parte / 2],
                      self.mat('#E8E2D0', 0.7, '#6668A8', 0.15))
        for dx, h in ((-6.5, 3.2), (6.2, 3.6)):
            self.prim('cone', [x + dx, 42, h / 2], [5, 2, h / 2], self.mat('#16193D', 0.95))


# ─── Distritos ───────────────────────────────────────────────────────

def tejados(e):
    """Azotea de ciudad costera mediterránea, barrio popular, de noche."""
    e.montana_lejana()
    for fila, (y, alto_min, alto_max, color) in enumerate(
            [(14, 3.0, 5.2, '#16193D'), (8, 2.0, 3.6, '#2B2F63'), (3.5, 1.0, 1.8, '#413F7A')]):
        x = -6.2
        while x < 6.2:
            ancho = e.azar.uniform(1.0, 1.8)
            alto = e.azar.uniform(alto_min, alto_max)
            e.edificio(x + ancho / 2, y, ancho, 1.2, alto, color,
                       tejado='#76463A' if fila == 2 else None,
                       densidad=0.7 if fila == 0 else 1.0)
            if fila == 1 and e.azar.random() < 0.4:  # depósito o antena
                if e.azar.random() < 0.5:
                    e.prim('cylinder', [x + ancho / 2, y, alto + 0.3], [0.2, 0.2, 0.3],
                           e.mat('#6D6F78'))
                else:
                    e.prim('cylinder', [x + ancho / 2, y, alto + 0.6], [0.02, 0.02, 0.6],
                           e.mat('#6D6F78'))
            if fila == 2 and e.azar.random() < 0.5:  # chimenea
                e.caja(x + ancho * 0.3, y, alto + 0.35, 0.08, 0.08, 0.25, '#76463A')
            x += ancho + e.azar.uniform(0.05, 0.3)
    # Pretil de la azotea desde la que se mira (primer plano).
    e.caja(0, 0.6, -0.5, 7, 0.25, 0.75, '#16193D', rough=0.95)
    e.caja(0, 0.55, 0.3, 7, 0.32, 0.06, '#2B2F63', rough=0.9)
    e.luz(0, 0, 3, 120, '#E8A857')


def canales(e):
    """Piedra, agua y luz tenue, como un secreto. El canal cruza en primer
    plano; en la otra orilla, la hilera de casas; un puente en arco."""
    e.montana_lejana(alto=5.5)
    # Agua: franja horizontal delante, con reflejo cian.
    e.caja(0, 2.4, -0.02, 7, 1.7, 0.02, '#16193D', rough=0.1, emision='#5CB4C2', fuerza=0.35)
    # Reflejos de las ventanas: trazos verticales temblorosos en el agua.
    for _ in range(26 if e.encendido else 8):
        x = e.azar.uniform(-5.8, 5.8)
        e.caja(x, 1.2, 0.0, 0.03, 0.02, e.azar.uniform(0.05, 0.12), '#E8A857',
               rough=0.3, emision='#E8A857', fuerza=1.2)
    # Muro de piedra de la orilla de enfrente.
    e.caja(0, 4.3, 0.25, 7, 0.2, 0.3, '#6D6F78')
    # Hilera de casas de piedra.
    x = -6.2
    while x < 6.2:
        ancho = e.azar.uniform(1.1, 1.7)
        e.edificio(x + ancho / 2, 5.3, ancho, 1.6, e.azar.uniform(1.8, 3.4),
                   e.azar.choice(['#6D6F78', '#2B2F63', '#413F7A']), tejado='#4B3A2D')
        x += ancho + 0.08
    # Segunda hilera, más oscura, detrás.
    x = -6.0
    while x < 6.2:
        ancho = e.azar.uniform(1.3, 2.0)
        e.edificio(x + ancho / 2, 9, ancho, 1.6, e.azar.uniform(3.0, 4.6), '#16193D',
                   densidad=0.6)
        x += ancho + 0.1
    # Farolillos en el muro.
    for k in range(7):
        e.farolillo(-5.4 + k * 1.8, 4.1, 0.75)
    # Puente en arco que cruza el canal (el arco mira a la cámara).
    e.prim('torus', [-2.6, 2.4, 0.0], [1.3, 1.3, 1.3], e.mat('#6D6F78'),
           rot=[math.pi / 2, 0, 0])
    e.caja(-2.6, 2.4, 1.35, 1.5, 0.45, 0.08, '#6D6F78')


def mercado(e):
    """Bazar nocturno vivo y cálido: la alegría dentro de la penumbra."""
    e.montana_lejana(alto=5)
    x = -6
    while x < 6:
        ancho = e.azar.uniform(1.4, 2.2)
        e.edificio(x + ancho / 2, 10, ancho, 1.5, e.azar.uniform(2.6, 4.2), '#2B2F63',
                   densidad=1.2)
        x += ancho + 0.1
    toldos = ['#D97E4F', '#C87C7C', '#8A2A2A', '#E8A857', '#A99885']
    for fila, y in enumerate((2.2, 5.0)):
        for i in range(6):
            x = -5.2 + i * 2.1 + (0.9 if fila else 0)
            e.caja(x, y, 0.45, 0.8, 0.5, 0.45, '#4B3A2D')
            e.caja(x, y - 0.25, 1.05, 0.95, 0.55, 0.05, e.azar.choice(toldos), rot=[0.35, 0, 0])
            e.farolillo(x, y - 0.8, 1.35, '#E8A857', 10)
    # Guirnaldas colgadas en catenaria.
    for y, z0 in ((3.6, 2.4), (6.4, 2.9)):
        for i in range(31):
            t = i / 30
            e.prim('sphere', [-6 + 12 * t, y, z0 - 0.5 * math.sin(math.pi * t)],
                   [0.045, 0.045, 0.045],
                   e.mat('#F2D58E', 0.3, '#F2D58E', 3.0 if e.encendido else 0.8))
    e.luz(0, 1, 3, 200, '#D97E4F')


def industria(e):
    """Zona industrial medio abandonada; las máquinas siguen por inercia."""
    e.montana_lejana(alto=5, nieve=False)
    for x, ancho, alto in ((-4.2, 3.2, 2.6), (-0.5, 3.6, 3.2), (3.6, 3.0, 2.2)):
        e.edificio(x, 7, ancho, 3, alto, '#6D6F78', densidad=0.45)
        e.caja(x, 7, alto + 0.05, ancho / 2, 1.5, 0.08, '#8A6353')
    for x, alto in ((-2.4, 6.2), (1.6, 7.0), (5.2, 5.4)):
        e.prim('cylinder', [x, 10, alto / 2], [0.28, 0.28, alto / 2], e.mat('#8A6353'))
        e.prim('sphere', [x, 10, alto + 0.08], [0.09, 0.09, 0.09],
               e.mat('#B45656', 0.3, '#B45656', 4.0))
    # Grúa.
    e.caja(4.8, 4, 2.6, 0.08, 0.08, 2.6, '#8A6353')
    e.caja(3.6, 4, 5.2, 1.6, 0.08, 0.08, '#8A6353')
    e.caja(2.3, 4, 4.2, 0.02, 0.02, 1.0, '#6D6F78')
    # Tuberías en primer plano.
    for z in (0.4, 0.8):
        e.prim('cylinder', [0, 1.5, z], [0.12, 0.12, 7], e.mat('#6D6F78'), rot=[0, math.pi / 2, 0])
    e.luz(0, 2, 3, 70, '#E8A857')


def puerto(e):
    """Un puerto donde apenas se ve el mar, pero se oye."""
    e.montana_lejana(alto=5)
    e.caja(0, 20, -0.02, 12, 20, 0.02, '#0B0E1F', rough=0.3, emision='#2B2F63', fuerza=0.25)
    e.caja(-1.6, 6, 0.3, 0.45, 6, 0.08, '#4B3A2D')        # muelle
    for i in range(6):
        e.prim('cylinder', [-1.6 + (0.4 if i % 2 else -0.4), 1.5 + i * 1.8, 0.15],
               [0.07, 0.07, 0.3], e.mat('#4B3A2D'))
        e.farolillo(-1.6 + (0.4 if i % 2 else -0.4), 1.5 + i * 1.8, 0.55, '#E8A857', 8)
    e.prim('cylinder', [3.8, 13, 1.8], [0.35, 0.35, 1.8], e.mat('#E8E2D0'))   # faro
    e.prim('sphere', [3.8, 13, 3.8], [0.3, 0.3, 0.3], e.mat('#E8A857', 0.3, '#E8A857', 5.0))
    e.luz(3.8, 12.5, 3.8, 160 if e.encendido else 60, '#E8A857')
    for x, y in ((1.2, 7), (-4.2, 10), (5.0, 5)):                              # barcas
        e.caja(x, y, 0.15, 0.7, 0.25, 0.15, '#2B2F63')
        e.caja(x, y, 0.75, 0.02, 0.02, 0.5, '#6D6F78')
    x = -6
    while x < -2.4:                                                            # casas del muelle
        ancho = e.azar.uniform(0.9, 1.3)
        e.edificio(x + ancho / 2, 2.2, ancho, 1.0, e.azar.uniform(1.0, 1.6), '#2B2F63',
                   tejado='#4B3A2D')
        x += ancho + 0.15


def afueras(e):
    """Campo abierto tranquilo: por primera vez se ve el cielo de verdad."""
    e.montana_lejana(alto=7)
    for x, y, r, h in ((-3.5, 9, 4.5, 1.2), (3.2, 7, 4.0, 1.6)):
        e.prim('sphere', [x, y, 0], [r, r * 0.6, h], e.mat('#2B2F63', 0.95))
    e.prim('cylinder', [3.2, 7, 1.9], [0.45, 0.45, 0.45], e.mat('#A99885'))   # observatorio
    e.prim('sphere', [3.2, 7, 2.35], [0.5, 0.5, 0.5], e.mat('#E8E2D0', 0.5))
    e.farolillo(3.2, 6.5, 1.8, '#F2D58E', 20)
    for _ in range(14):
        x = e.azar.uniform(-6, 6)
        y = e.azar.uniform(2.5, 9)
        e.prim('cone', [x, y, 0.9], [0.28, 0.28, 0.9], e.mat('#16193D', 0.9))
    for i in range(40):                                                       # ciudad lejana
        x = -6 + i * 0.3
        if e.azar.random() < (0.35 if not e.encendido else 0.8):
            e.prim('sphere', [x, 25, 0.9 + e.azar.random() * 0.4], [0.03, 0.03, 0.03],
                   e.mat('#E8A857', 0.3, '#E8A857', 4.0))


def montana(e):
    """La Montaña: cumbre nevada, sendero tenue."""
    e.prim('cone', [0, 16, 5], [8, 4, 5], e.mat('#413F7A', 0.9))
    e.prim('cone', [0, 15.8, 9.1], [1.4, 0.8, 0.95], e.mat('#E8E2D0', 0.6))
    for dx, h in ((-7, 3.5), (7.5, 4)):
        e.prim('cone', [dx, 18, h / 2], [4, 2, h / 2], e.mat('#2B2F63', 0.95))
    # Sendero tenue: pequeñas luces subiendo la ladera en zigzag.
    for k in range(16):
        subida = k / 15
        x = 1.4 * math.sin(subida * math.pi * 3) * (1 - subida)
        y = 4 + subida * 11
        z = subida * 8.6
        e.prim('sphere', [x, y - 0.3, z + 0.1], [0.05, 0.05, 0.05],
               e.mat('#F2D58E', 0.3, '#F2D58E', 3.0 if e.encendido or k < 5 else 0.6))
    for _ in range(10):
        e.prim('sphere', [e.azar.uniform(-5, 5), e.azar.uniform(1.5, 5), 0.2],
               [e.azar.uniform(0.3, 0.7)] * 2 + [0.35], e.mat('#2B2F63', 0.9))
    e.farolillo(-0.5, 2.6, 0.7, '#E8A857', 25)


DISTRITOS = {
    'tejados': tejados, 'canales': canales, 'mercado': mercado,
    'industria': industria, 'puerto': puerto, 'afueras': afueras, 'montana': montana,
}


def suelo(e):
    """Suelo oscuro hasta el borde inferior: sin hueco bajo la escena."""
    # Llega muy hacia la cámara: tapa lo que queda por debajo de z=0 (la
    # mitad inferior del arco del puente, de las colinas…).
    e.caja(0, -10, -0.06, 9, 34, 0.05, '#0B0E1F', rough=0.95)


def spec(nombre, construir, encendido):
    # Semilla estable (hash() de Python cambia entre ejecuciones).
    e = Escena(semilla=sum(ord(c) * (i + 1) for i, c in enumerate(nombre)),
               encendido=encendido)
    construir(e)
    suelo(e)
    etiqueta = 'on' if encendido else 'off'
    e.objetos += [
        {'type': 'light', 'kind': 'sun', 'name': 'luna', 'energy': 1.6,
         'rotation': [1.1, 0.0, 0.5], 'color': srgb('#6668A8')[:3]},
        # Un sujeto invisible no hace falta: la cámara lleva escala fija.
        {'type': 'sprite_sheet', 'name': f'{nombre}_{etiqueta}', 'subject': 'o1',
         'output_dir': f'out/{nombre}_{etiqueta}',
         'directions': [{'label': 'frente', 'yaw': 270}],
         'frames': [1], 'frame_size': TAMANO, 'film_transparent': True,
         'camera': {'pitch': 5, 'distance': 60, 'target': [0, 6, ALTO_VISTO / 2 - 0.9],
                    'ortho_scale': ALTO_VISTO}},
    ]
    return {'version': 0.1, 'name': f'escenario_{nombre}_{etiqueta}',
            'render': {'quality_preset': 'preview', 'color_management': 'agx'},
            'scene': e.objetos}


if __name__ == '__main__':
    os.makedirs('specs', exist_ok=True)
    for nombre, construir in DISTRITOS.items():
        if SOLO and nombre != SOLO:
            continue
        for encendido in (False, True):
            s = spec(nombre, construir, encendido)
            with open(f'specs/{s["name"]}.yaml', 'w') as f:
                yaml.safe_dump(s, f, sort_keys=False, allow_unicode=True)
            print(f'specs/{s["name"]}.yaml', len(s['scene']))
