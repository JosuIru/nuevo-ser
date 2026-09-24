#!/usr/bin/env python3
"""Fragmentos musicales de capa histórica con el motor de mesa-mezclas.

Lee manifiesto_fragmentos.json, compone cada pieza con la CLI de
Ravero (`scripts/motor/componer.js`, Chrome headless; la CLI de Node
puro pide Node >= 22.12), recorta el tramo [desde, hasta], le pone
fundidos, normaliza a -20 LUFS (más bajo que Uno Roto: la guía pide
quietud) y la deja en assets/sonido/fragmentos/ como OGG.

No toca el repo mesa-mezclas: sólo llama a su CLI (regla acordada con
Anarkopia, docs/MOTOR-PARA-ANARKOPIA-2026-09-16.md de mesa-mezclas).

Uso (desde apps/las-versiones/):
    python3 scripts/sonido/generar_fragmentos_capa.py            # todos
    python3 scripts/sonido/generar_fragmentos_capa.py D-NEO      # uno
    MESA_MEZCLAS=/otra/ruta python3 ...                          # otra ruta
"""
import json
import os
import subprocess
import sys
import tempfile

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.join(AQUI, '..', '..')
MESA = os.environ.get('MESA_MEZCLAS',
                      os.path.expanduser('~/Projects/mesa-mezclas'))
FUNDIDO_ENTRADA = 1.5
FUNDIDO_SALIDA = 3.0


def id_fragmento(capa):
    return 'fragmento_' + capa.lower().replace('-', '_')


def generar(fragmento, directorio_temporal):
    wav_completo = os.path.join(directorio_temporal, f"{fragmento['capa']}.wav")
    subprocess.run(
        ['node', 'scripts/motor/componer.js',
         f"--genero={fragmento['genero']}",
         f"--cara={fragmento['cara']}",
         f"--semilla={fragmento['semilla']}",
         f"--compases={fragmento['compases']}",
         f'--wav={wav_completo}'],
        cwd=MESA, check=True)
    desde, hasta = fragmento['desde'], fragmento['hasta']
    duracion = hasta - desde
    destino = os.path.join(RAIZ, 'assets', 'sonido', 'fragmentos',
                           id_fragmento(fragmento['capa']) + '.ogg')
    filtros = (f'afade=t=in:st=0:d={FUNDIDO_ENTRADA},'
               f'afade=t=out:st={duracion - FUNDIDO_SALIDA}:d={FUNDIDO_SALIDA},'
               'loudnorm=I=-20:TP=-2:LRA=11')
    subprocess.run(
        ['ffmpeg', '-y', '-loglevel', 'error', '-ss', str(desde),
         '-t', str(duracion), '-i', wav_completo, '-af', filtros,
         '-ar', '44100', '-c:a', 'libvorbis', '-q:a', '5', destino],
        check=True)
    print('  ', os.path.relpath(destino, RAIZ))


def main():
    with open(os.path.join(AQUI, 'manifiesto_fragmentos.json')) as archivo:
        fragmentos = json.load(archivo)['fragmentos']
    elegidos = set(sys.argv[1:])
    if elegidos:
        fragmentos = [f for f in fragmentos if f['capa'] in elegidos]
    with tempfile.TemporaryDirectory() as directorio_temporal:
        for fragmento in fragmentos:
            print(f"{fragmento['capa']}: {fragmento['genero']} · "
                  f"{fragmento['cara']} · semilla {fragmento['semilla']}")
            generar(fragmento, directorio_temporal)


if __name__ == '__main__':
    main()
