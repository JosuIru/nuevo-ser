"""Sprites de las máquinas de Rexán con flavor3d (fondo transparente,
una sola vista). Uso:

    python3 generar_sprites.py && for s in specs/*.yaml; do flavor3d run $s; done
    python3 copiar.py
"""
import os
import sys

import yaml

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'maquinas'))
from generar_specs import srgb  # noqa: E402


def material(color, rough=0.6, emision=None, fuerza=0.0):
    m = {'base_color': srgb(color), 'roughness': rough}
    if emision:
        m['emission_color'] = srgb(emision)
        m['emission_strength'] = fuerza
    return m


def prim(forma, nombre, loc, escala, mat, rot=None):
    e = {'type': 'primitive', 'shape': forma, 'name': nombre,
         'location': loc, 'scale': escala, 'material': mat}
    if rot:
        e['rotation'] = rot
    return e


LUCES = [
    {'type': 'light', 'kind': 'point', 'name': 'clave', 'location': [2.5, -3, 4],
     'energy': 900, 'color': srgb('#F2D58E')[:3]},
    {'type': 'light', 'kind': 'point', 'name': 'frente', 'location': [0, -4, 1.5],
     'energy': 500, 'color': srgb('#E8E2D0')[:3]},
    {'type': 'light', 'kind': 'point', 'name': 'contra', 'location': [-3, 2, 3],
     'energy': 700, 'color': srgb('#6668A8')[:3]},
]


def carro():
    """Carro de Puentes, de lado: caja de madera, ruedas y farolillo."""
    return [
        prim('cube', 'caja', [0, 0, 0.55], [0.7, 0.4, 0.3], material('#8A6353', 0.8)),
        prim('cube', 'borde', [0, 0, 0.88], [0.74, 0.44, 0.04], material('#4B3A2D', 0.8)),
        prim('cylinder', 'rueda_i', [-0.45, -0.42, 0.25], [0.24, 0.24, 0.05],
             material('#2B2F63', 0.5), rot=[1.5708, 0, 0]),
        prim('cylinder', 'rueda_d', [0.45, -0.42, 0.25], [0.24, 0.24, 0.05],
             material('#2B2F63', 0.5), rot=[1.5708, 0, 0]),
        prim('cylinder', 'poste', [0.62, 0, 1.15], [0.02, 0.02, 0.28], material('#6D6F78', 0.4)),
        prim('sphere', 'farol', [0.62, 0, 1.45], [0.09, 0.09, 0.09],
             material('#E8A857', 0.3, '#E8A857', 1.0)),
    ]


def fragmento():
    """El Fragmento del niño en Canales: núcleo ámbar y halo."""
    return [
        prim('sphere', 'nucleo', [0, 0, 0.5], [0.45, 0.45, 0.45],
             material('#D97E4F', 0.3, '#E8A857', 0.6)),
        prim('torus', 'halo', [0, 0, 0.5], [0.7, 0.7, 0.35],
             material('#C8A25B', 0.3, '#E8A857', 0.35), rot=[1.2, 0, 0.3]),
    ]


def sombra():
    """Sombra de los Canales: bulto encapuchado violeta, dos ojos cian."""
    return [
        prim('cone', 'capa', [0, 0, 0.55], [0.5, 0.5, 0.6], material('#2B2F63', 0.9)),
        prim('sphere', 'capucha', [0, 0, 1.05], [0.34, 0.34, 0.34], material('#16193D', 0.9)),
        prim('sphere', 'ojo_i', [-0.12, -0.3, 1.08], [0.05, 0.05, 0.05],
             material('#78D8E0', 0.3, '#78D8E0', 1.5)),
        prim('sphere', 'ojo_d', [0.12, -0.3, 1.08], [0.05, 0.05, 0.05],
             material('#78D8E0', 0.3, '#78D8E0', 1.5)),
    ]


SPRITES = {
    # nombre: (objetos, sujeto que encuadra, yaw de la cámara, inclinación)
    'carro': (carro, 'caja', 270, 12),
    'fragmento': (fragmento, 'halo', 270, 35),
    'sombra': (sombra, 'capa', 270, 20),
}

if __name__ == '__main__':
    os.makedirs('specs', exist_ok=True)
    for nombre, (objetos, sujeto, yaw, inclinacion) in SPRITES.items():
        spec = {
            'version': 0.1,
            'name': f'sprite_{nombre}',
            'render': {'quality_preset': 'preview', 'color_management': 'agx'},
            'scene': objetos() + LUCES + [
                {'type': 'sprite_sheet', 'name': nombre, 'subject': sujeto,
                 'output_dir': f'out/{nombre}',
                 'directions': [{'label': 'vista', 'yaw': yaw}],
                 'frames': [1], 'frame_size': [512, 512], 'film_transparent': True,
                 'camera': {'pitch': inclinacion, 'distance': 30,
                            # Holgado: el recorte por transparencia (copiar.py)
                            # quita luego el margen sobrante.
                            'auto_fit': {'padding': 0.9}}},
            ],
        }
        ruta = f'specs/sprite_{nombre}.yaml'
        with open(ruta, 'w') as f:
            yaml.safe_dump(spec, f, sort_keys=False, allow_unicode=True)
        print(ruta)
