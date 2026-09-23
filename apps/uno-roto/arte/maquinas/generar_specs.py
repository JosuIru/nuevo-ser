"""Genera las specs de flavor3d de las máquinas de Rexán (encendidas y
apagadas) con la paleta de la guía visual (doc 11). Uso:

    python3 generar_specs.py && for s in specs/*.yaml; do flavor3d run $s; done
    python3 recortar.py   # recorta a la máquina y copia a assets/maquinas/
"""
import os

def srgb(hexa, alfa=1.0):
    """Hex sRGB → RGBA lineal (lo que espera Blender)."""
    h = hexa.lstrip('#')
    def lin(c):
        c = int(c, 16) / 255
        return round(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4, 4)
    return [lin(h[0:2]), lin(h[2:4]), lin(h[4:6]), alfa]

# Guía visual: azules nocturnos de base, neones cálidos apagados, luz de
# Fragmento reservada (cian) para la pantalla.
FONDO = '#0A0618'
MUEBLE = '#2B2F63'      # azul violeta
MADERA = '#4B3A2D'      # madera oscura (panel)
AMBAR = '#E8A857'
ROJO_TEJA = '#B45656'
VIOLETA = '#413F7A'

MAQUINAS = {
    # pantalla y marquesina de cada máquina
    'puentes': {'pantalla': '#E8A857', 'marquesina': '#D97E4F'},
    'encaje': {'pantalla': '#A67EC8', 'marquesina': '#E8A857'},
    'canales': {'pantalla': '#78D8E0', 'marquesina': '#F2D58E'},
}

def material(color, rough=0.6, emision=None, fuerza=0.0):
    m = {'base_color': srgb(color), 'roughness': rough}
    if emision:
        m['emission_color'] = srgb(emision)
        m['emission_strength'] = fuerza
    return m

def cubo(nombre, loc, escala, mat, rot=None):
    e = {'type': 'primitive', 'shape': 'cube', 'name': nombre,
         'location': loc, 'scale': escala, 'material': mat}
    if rot:
        e['rotation'] = rot
    return e

ANGULO_PANTALLA = -0.22

def en_pantalla(u, v, adelante=0.02):
    """Punto (u, v) de la pantalla inclinada → coordenadas del mundo."""
    import math
    s, c = math.sin(-ANGULO_PANTALLA), math.cos(-ANGULO_PANTALLA)
    return [u, -0.475 + v * s - adelante * c, 1.52 + v * c + adelante * s]

def pixel(nombre, u, v, ancho, alto, color, fuerza=1.6):
    return cubo(nombre, en_pantalla(u, v), [ancho, 0.006, alto],
                material(color, 0.4, color, fuerza), rot=[ANGULO_PANTALLA, 0, 0])

def juego_en_pantalla(nombre, color):
    """Lo que se ve en cada pantalla: el juego de esa máquina."""
    p = []
    if nombre == 'puentes':
        p += [pixel('orilla_i', -0.30, -0.16, 0.09, 0.12, '#6668A8', 0.8),
              pixel('orilla_d', 0.30, -0.16, 0.09, 0.12, '#6668A8', 0.8),
              pixel('tablon1', -0.10, -0.035, 0.105, 0.012, color),
              pixel('tablon2', 0.105, -0.035, 0.095, 0.012, '#D97E4F'),
              pixel('carro', -0.30, 0.0, 0.035, 0.02, '#A67EC8'),
              pixel('cota', 0.0, 0.12, 0.21, 0.004, '#E8E2D0', 0.8)]
    elif nombre == 'encaje':
        colores = ['#E8A857', '#78D8E0', '#A67EC8', '#9FD9B8']
        filas = [[(-0.40, 0.4, 0), (0.0, 0.4, 1)], [(-0.40, 0.27, 2), (-0.13, 0.27, 3)],
                 [(0.14, 0.26, 0)], [(-0.2, 0.2, 1)]]
        for i, fila in enumerate(filas):
            for j, (x0, largo, k) in enumerate(fila):
                p.append(pixel(f'barra{i}_{j}', x0 + largo / 2, -0.24 + i * 0.085,
                               largo / 2 - 0.008, 0.035, colores[k], 1.3))
        p.append(pixel('cayendo', 0.05, 0.2, 0.1, 0.035, '#E8A857', 1.8))
    else:  # canales
        for i, (u, v, a, b) in enumerate([(0, 0.25, 0.36, 0.012), (0, -0.25, 0.36, 0.012),
                                          (-0.36, 0, 0.012, 0.25), (0.36, 0, 0.012, 0.25),
                                          (-0.12, 0.08, 0.1, 0.012), (0.15, -0.08, 0.012, 0.1),
                                          (0.12, 0.12, 0.012, 0.08)]):
            p.append(pixel(f'muro{i}', u, v, a, b, '#6668A8', 0.9))
        for i, (u, v) in enumerate([(-0.25, 0.16), (-0.25, -0.05), (0.02, -0.16),
                                    (0.26, 0.16), (0.26, -0.16), (-0.02, 0.18)]):
            p.append(pixel(f'numero{i}', u, v, 0.018, 0.018, '#E8E2D0', 1.2))
        p.append(pixel('fragmento', -0.1, -0.16, 0.032, 0.032, '#E8A857', 2.0))
        p.append(pixel('sombra', 0.12, 0.02, 0.034, 0.034, '#413F7A', 0.9))
    return p

def escena(nombre, colores, encendida):
    f = 1.0 if encendida else 0.0
    pantalla = colores['pantalla'] if encendida else '#16193D'
    elementos = [
        # telón de fondo y suelo, del color de fondo del juego
        cubo('telon', [0, 3, 2], [8, 0.05, 6], material(FONDO, 1.0)),
        cubo('suelo', [0, 0, -0.05], [8, 8, 0.05], material('#16193D', 0.9)),
        # mueble
        cubo('mueble', [0, 0, 1.0], [0.55, 0.45, 1.0], material(MUEBLE, 0.7)),
        # Apagada, la marquesina es cristal sin luz: violeta apagado.
        cubo('marquesina', [0, -0.40, 2.12], [0.56, 0.10, 0.14],
             material(colores['marquesina'] if encendida else VIOLETA, 0.4,
                      colores['marquesina'], 0.9 * f)),
        cubo('marco_pantalla', [0, -0.44, 1.52], [0.48, 0.03, 0.36],
             material('#0B0E1F', 0.5), rot=[-0.22, 0, 0]),
        cubo('pantalla', [0, -0.475, 1.52], [0.40, 0.01, 0.29],
             material('#16193D', 0.3, '#16193D', 0.6 * f), rot=[-0.22, 0, 0]),
        cubo('panel', [0, -0.62, 0.98], [0.56, 0.22, 0.05],
             material(MADERA, 0.8), rot=[0.35, 0, 0]),
        {'type': 'primitive', 'shape': 'cylinder', 'name': 'palanca',
         'location': [-0.22, -0.66, 1.08], 'scale': [0.025, 0.025, 0.09],
         'material': material('#6D6F78', 0.4)},
        {'type': 'primitive', 'shape': 'sphere', 'name': 'bola',
         'location': [-0.22, -0.66, 1.18], 'scale': [0.055, 0.055, 0.055],
         'material': material(ROJO_TEJA, 0.35)},
    ]
    for i, x in enumerate([0.08, 0.24]):
        elementos.append({'type': 'primitive', 'shape': 'cylinder', 'name': f'boton{i}',
                          'location': [x, -0.68, 1.03], 'scale': [0.045, 0.045, 0.02],
                          'rotation': [0.35, 0, 0],
                          'material': material(AMBAR, 0.3, AMBAR, 1.5 * f)})
    if encendida:
        elementos += juego_en_pantalla(nombre, colores['pantalla'])
    # tiras de neón en los laterales
    for i, x in enumerate([-0.56, 0.56]):
        elementos.append(cubo(f'tira{i}', [x, -0.35, 1.0], [0.012, 0.012, 0.9],
                              material(VIOLETA, 0.4, '#8A5CFF', 2.5 * f)))
    elementos += [
        {'type': 'light', 'kind': 'point', 'name': 'clave', 'location': [2.2, -2.6, 3.0],
         'energy': 260, 'color': srgb('#F2D58E')[:3]},
        {'type': 'light', 'kind': 'point', 'name': 'contra', 'location': [-2.0, 1.5, 2.6],
         'energy': 220, 'color': srgb('#6668A8')[:3]},
        {'type': 'light', 'kind': 'point', 'name': 'relleno', 'location': [-1.5, -3.0, 1.0],
         'energy': 50, 'color': srgb('#6668A8')[:3]},
        {'type': 'camera', 'location': [2.7, -4.6, 1.95], 'look_at': [0, 0, 1.12],
         'lens': '50mm'},
    ]
    return {
        'version': 0.1,
        'name': f'maquina_{nombre}_{"encendida" if encendida else "apagada"}',
        'output': {'path': f'out/{nombre}_{"on" if encendida else "off"}.glb', 'format': 'glb'},
        'render': {'preview': f'out/{nombre}_{"on" if encendida else "off"}.png',
                   'resolution': [512, 640], 'quality_preset': 'preview',
                   'color_management': 'agx'},
        # Estilo ilustrado (toon + contorno): más cerca del anime nocturno
        # de la guía visual que el render realista.
        'scene': elementos + [{'type': 'style', 'preset': 'arcane'}],
    }

if __name__ == '__main__':
    import yaml
    os.makedirs('specs', exist_ok=True)
    for nombre, colores in MAQUINAS.items():
        for encendida in (True, False):
            spec = escena(nombre, colores, encendida)
            ruta = f'specs/{spec["name"]}.yaml'
            with open(ruta, 'w') as f:
                yaml.safe_dump(spec, f, sort_keys=False, allow_unicode=True)
            print(ruta)
