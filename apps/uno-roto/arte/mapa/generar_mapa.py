"""Ilustración de fondo del mapa (la ciudad a la hora azul) con flavor3d.

Cada distrito se levanta en la posición relativa de su nodo en
`lib/dominio/catalogo_distritos.dart` (xMapa, yMapa). La cámara es
ortográfica con 55° de inclinación, así la relación suelo → pantalla es
lineal y el render cae debajo de los nodos. Uso:

    python3 generar_mapa.py && flavor3d run specs/mapa.yaml && python3 copiar.py
"""
import math
import os
import random
import sys

import yaml

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'maquinas'))
from generar_specs import srgb  # noqa: E402

AZAR = random.Random(7)
RESOLUCION = (1080, 2000)            # ~ proporción del lienzo del mapa
# Sin preset: con luz real la noche queda azul con charcos de luz cálida
# (arcane dejaba manchas en el suelo y ghibli la aplanaba).
ESTILO = os.environ.get('ESTILO', '')
INCLINACION = math.radians(55)
ANCHO = 9.0                          # mundo visible en horizontal
ALTO_VISTO = ANCHO * RESOLUCION[1] / RESOLUCION[0]
FONDO_SUELO = ALTO_VISTO / math.sin(INCLINACION)   # profundidad de suelo visible


def en_mapa(x_rel, y_rel):
    """(xMapa, yMapa) → (x, y) del suelo. y_rel = 0 arriba (lejos)."""
    return [(x_rel - 0.5) * ANCHO, (0.5 - y_rel) * FONDO_SUELO]


def mat(color, rough=0.7, emision=None, fuerza=0.0):
    m = {'base_color': srgb(color), 'roughness': rough}
    if emision:
        m['emission_color'] = srgb(emision)
        m['emission_strength'] = fuerza
    return m


N = [0]


def caja(x, y, z, sx, sy, sz, material, rot=None, forma='cube'):
    N[0] += 1
    e = {'type': 'primitive', 'shape': forma, 'name': f'o{N[0]}',
         'location': [x, y, z], 'scale': [sx, sy, sz], 'material': material}
    if rot:
        e['rotation'] = rot
    return e


def ventanas(x, y, ancho, alto, frente_y, densidad=0.45):
    """Ventanas encendidas (ámbar) en la cara que mira a la cámara."""
    salida = []
    filas = max(1, int(alto / 0.22))
    columnas = max(1, int(ancho / 0.2))
    for f in range(filas):
        for c in range(columnas):
            if AZAR.random() < densidad:
                salida.append(caja(x - ancho / 2 + (c + 0.5) * ancho / columnas,
                                   frente_y - 0.01, 0.15 + f * 0.22, 0.035, 0.01, 0.05,
                                   mat('#E8A857', 0.4, '#E8A857', 2.0)))
    return salida


def edificio(x, y, ancho, fondo, alto, color='#2B2F63', densidad=0.45):
    e = [caja(x, y, alto / 2, ancho / 2, fondo / 2, alto / 2, mat(color))]
    e += ventanas(x, y, ancho, alto, y - fondo / 2, densidad)
    return e


def farolillo(x, y, z=0.25, color='#F2D58E'):
    return caja(x, y, z, 0.035, 0.035, 0.035, mat(color, 0.3, color, 3.0), forma='sphere')


ESCALA = 1.6   # tamaño de los distritos respecto al primer boceto

# Centros de los distritos y nodos (para las calles y para dejar sitio).
CENTROS = [(0.5, 0.45), (0.22, 0.55), (0.78, 0.55), (0.5, 0.72), (0.5, 0.88),
           (0.22, 0.28), (0.5, 0.15), (0.84, 0.30), (0.84, 0.78)]


def calle(desde, hasta, ancho=0.07):
    """Calle recta entre dos nodos, un poco más clara que el suelo."""
    (x1, y1), (x2, y2) = en_mapa(*desde), en_mapa(*hasta)
    largo = math.hypot(x2 - x1, y2 - y1)
    angulo = math.atan2(y2 - y1, x2 - x1)
    return caja((x1 + x2) / 2, (y1 + y2) / 2, 0.005, largo / 2, ancho, 0.01,
                mat('#413F7A', 0.9, '#413F7A', 0.25), rot=[0, 0, angulo])


def relleno():
    """Casas y árboles sueltos lejos de los distritos: que sea ciudad."""
    e = []
    for _ in range(90):
        xr, yr = AZAR.uniform(0.04, 0.96), AZAR.uniform(0.22, 0.82)
        if min(math.hypot(xr - cx, (yr - cy) * 1.8) for cx, cy in CENTROS) < 0.17:
            continue
        x, y = en_mapa(xr, yr)
        if AZAR.random() < 0.55:
            e.append(caja(x, y, 0.2, 0.09, 0.09, 0.2, mat('#2B2F63'), forma='cone'))
        else:
            alto = AZAR.uniform(0.15, 0.35)
            e += edificio(x, y, 0.22, 0.2, alto, '#2B2F63', 0.25)
    return e


def escena():
    e = []
    # Suelo, mar y telón.
    e.append(caja(0, 0, -0.05, 9, 16, 0.05, mat('#1C2050', 0.95)))
    e.append(caja(0, FONDO_SUELO / 2 + 2, 3, 12, 0.1, 8, mat('#0B0E1F', 1.0)))
    puerto = en_mapa(0.5, 0.88)
    # Mar mate: con poca rugosidad el faro dejaba un reflejo quemado.
    e.append(caja(0, puerto[1] - 3.2, -0.02, 9, 3.4, 0.03,
                  mat('#0B0E1F', 0.95, '#2B2F63', 0.25)))

    # Montaña (arriba del todo), con nieve.
    x, y = en_mapa(0.5, 0.15)
    e.append(caja(x, y + 1.4, 1.5, 1.9, 1.9, 1.5, mat('#413F7A'), forma='cone'))
    e.append(caja(x, y + 1.4, 2.62, 0.48, 0.48, 0.38, mat('#E8E2D0', 0.6, '#E8E2D0', 0.25),
                  forma='cone'))
    for dx, alto in ((-2.4, 0.9), (2.3, 1.0), (-1.3, 0.6), (1.4, 0.7)):
        e.append(caja(x + dx, y + 1.9, alto, 1.3, 1.3, alto, mat('#2B2F63'), forma='cone'))

    # Afueras: prado lavanda, observatorio y arboleda.
    x, y = en_mapa(0.22, 0.28)
    e.append(caja(x, y, 0.0, 1.4, 1.4, 0.02, mat('#2B2F63', 0.9), forma='cylinder'))
    e.append(caja(x + 0.3, y + 0.2, 0.3, 0.28, 0.28, 0.3, mat('#A99885'), forma='cylinder'))
    e.append(caja(x + 0.3, y + 0.2, 0.62, 0.3, 0.3, 0.3, mat('#E8E2D0', 0.5), forma='sphere'))
    e.append(farolillo(x + 0.3, y + 0.05, 0.4))
    for i in range(7):
        e.append(caja(x - 0.9 + AZAR.random() * 1.0, y - 0.3 + AZAR.random() * 0.7, 0.3,
                      0.14, 0.14, 0.3, mat('#413F7A'), forma='cone'))

    # Tejados del centro: la ciudad vieja, ventanas ámbar.
    x, y = en_mapa(0.5, 0.45)
    for i in range(12):
        dx = (i % 4 - 1.5) * 0.62 + AZAR.uniform(-0.08, 0.08)
        dy = (i // 4 - 1) * 0.62
        alto = AZAR.uniform(0.6, 1.3)
        e += edificio(x + dx, y + dy, 0.52, 0.42, alto, AZAR.choice(['#2B2F63', '#413F7A']))
        # Tejado a dos aguas: un cubo girado 45° y aplastado.
        e.append(caja(x + dx, y + dy, alto, 0.27, 0.15, 0.15,
                      mat('#76463A'), rot=[math.pi / 4, 0, 0]))

    # Canales: agua con reflejo cian, casas bajas y farolillos.
    x, y = en_mapa(0.22, 0.55)
    for dy in (-0.55, 0.45):
        e.append(caja(x, y + dy, 0.0, 1.6, 0.12, 0.02, mat('#2B4DA6', 0.1, '#5CB4C2', 0.5)))
    for dx in (-0.6, 0.5):
        e.append(caja(x + dx, y, 0.0, 0.1, 0.55, 0.02, mat('#2B4DA6', 0.1, '#5CB4C2', 0.5)))
    for i in range(10):
        e += edificio(x - 1.3 + (i % 5) * 0.6, y + (0.85 if i < 5 else -0.05) - 0.3,
                      0.4, 0.34, AZAR.uniform(0.35, 0.7), '#6D6F78', 0.35)
    for i in range(8):
        e.append(farolillo(x - 1.4 + i * 0.4, y - 0.4, 0.2))

    # Mercado de la Luz: puestos con toldos y guirnaldas.
    x, y = en_mapa(0.78, 0.55)
    colores = ['#D97E4F', '#C87C7C', '#8A2A2A', '#E8A857']
    for i in range(12):
        px = x - 1.0 + (i % 4) * 0.6
        py = y - 0.5 + (i // 4) * 0.55
        e.append(caja(px, py, 0.15, 0.18, 0.16, 0.15, mat('#4B3A2D')))
        e.append(caja(px, py, 0.34, 0.24, 0.2, 0.04, mat(colores[i % 4], 0.6)))
    for fila in (-0.22, 0.33):
        for i in range(16):
            e.append(farolillo(x - 1.2 + i * 0.16, y + fila, 0.5 + 0.06 * math.sin(i),
                               '#E8A857'))

    # Zona Industrial: naves, chimeneas y una grúa.
    x, y = en_mapa(0.5, 0.72)
    for dx in (-0.9, 0.0, 0.9):
        e += edificio(x + dx, y, 0.8, 0.6, AZAR.uniform(0.5, 0.8), '#6D6F78', 0.25)
    for dx in (-0.6, 0.35):
        e.append(caja(x + dx, y + 0.25, 0.9, 0.08, 0.08, 0.9, mat('#8A6353'), forma='cylinder'))
    e.append(caja(x + 1.4, y + 0.1, 1.1, 0.04, 0.04, 1.1, mat('#8A6353')))
    e.append(caja(x + 1.0, y + 0.1, 2.15, 0.5, 0.04, 0.04, mat('#8A6353')))

    # Puerto Silencioso: muelle largo y faro.
    x, y = en_mapa(0.5, 0.88)
    e.append(caja(x - 0.4, y - 0.6, 0.05, 0.12, 1.1, 0.05, mat('#4B3A2D')))
    e.append(caja(x + 1.3, y - 0.4, 0.55, 0.13, 0.13, 0.55, mat('#E8E2D0'), forma='cylinder'))
    e.append(caja(x + 1.3, y - 0.4, 1.18, 0.1, 0.1, 0.1, mat('#E8A857', 0.3, '#E8A857', 3.0),
                  forma='sphere'))
    for i in range(3):
        e += edificio(x - 1.6 + i * 0.55, y + 0.25, 0.45, 0.35, 0.45, '#2B2F63', 0.3)

    # Taller de Rexán y las máquinas: dos casitas con rótulo cálido.
    for x_rel, y_rel in ((0.84, 0.30), (0.84, 0.78)):
        x, y = en_mapa(x_rel, y_rel)
        e += edificio(x, y + 0.15, 0.5, 0.4, 0.45, '#4B3A2D', 0.6)

    centro = (0.5, 0.45)
    for destino in CENTROS[1:]:
        if destino != (0.5, 0.15):
            e.append(calle(centro, destino))
    e.append(calle((0.5, 0.72), (0.5, 0.88)))
    e += relleno()

    # Luz: luna fría, rellenos cálidos por distritos.
    e.append({'type': 'light', 'kind': 'sun', 'name': 'luna', 'energy': 2.2,
              'rotation': [0.8, 0.2, 0.4], 'color': srgb('#6668A8')[:3]})
    for x_rel, y_rel, color, energia in [(0.5, 0.45, '#E8A857', 120), (0.22, 0.55, '#F2D58E', 70),
                                         (0.78, 0.55, '#D97E4F', 90), (0.5, 0.88, '#E8A857', 40),
                                         (0.22, 0.28, '#6668A8', 60)]:
        x, y = en_mapa(x_rel, y_rel)
        e.append({'type': 'light', 'kind': 'point', 'name': f'luz{x_rel}{y_rel}',
                  'location': [x, y - 0.8, 1.6], 'energy': energia,
                  'color': srgb(color)[:3]})

    # Cámara: ortográfica, mirando al norte desde el sur, 55° hacia abajo.
    e.append({'type': 'iso_camera', 'name': 'camara', 'pitch': 55, 'yaw': 270,
              'target': [0, 0, 0], 'distance': 40, 'ortho_scale': ALTO_VISTO,
              'clip_end': 200})
    if ESTILO:
        e.append({'type': 'style', 'preset': ESTILO})
    return e


if __name__ == '__main__':
    os.makedirs('specs', exist_ok=True)
    spec = {
        'version': 0.1,
        'name': 'mapa',
        'render': {'preview': os.environ.get('SALIDA', 'out/mapa.png'),
                   'resolution': [int(v * float(os.environ.get('ESCALA_RES', 1)))
                                  for v in RESOLUCION],
                   'quality_preset': 'preview', 'color_management': 'agx'},
        'scene': escena(),
    }
    with open('specs/mapa.yaml', 'w') as f:
        yaml.safe_dump(spec, f, sort_keys=False, allow_unicode=True)
    print('specs/mapa.yaml', len(spec['scene']), 'elementos')
