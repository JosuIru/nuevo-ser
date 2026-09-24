#!/usr/bin/env python3
"""Efectos de objeto y ambiente del ático de Las Versiones, sintetizados.

PROVISIONALES: la guía sonora (doc 12 §1.1.4) prefiere texturas
grabadas de verdad. Estos sonidos sirven hasta que se graben (papel,
pinza de madera, cartulina sobre mimbre, balanza de latón, lluvia en
una claraboya). Al sustituirlos basta con dejar el OGG grabado con el
mismo nombre.

Todo sale de ruido filtrado y envolventes: sin samples, composición
propia (CC-BY-SA 4.0 como el resto del contenido). Nada suena a
videojuego (§1.1.7): no hay tonos de acierto ni de error.

Uso (desde apps/las-versiones/):
    python3 scripts/sonido/generar_sonidos_archivo.py

Deja OGG en assets/sonido/efectos/ y assets/sonido/ambiente/ (ignorados
por git). Requiere numpy, scipy y ffmpeg. Los fragmentos musicales de
capa los hace generar_fragmentos_capa.py con mesa-mezclas.
"""
import os
import subprocess
import tempfile

import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, sosfilt

FS = 44100
AZAR = np.random.default_rng(1978)
RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')


def filtro(senal, tipo, corte, orden=2):
    sos = butter(orden, corte, btype=tipo, fs=FS, output='sos')
    return sosfilt(sos, senal)


def envolvente(n, ataque, caida):
    t = np.arange(n) / FS
    subida = np.clip(t / max(ataque, 1e-4), 0, 1)
    return subida * np.exp(-np.maximum(t - ataque, 0) / caida)


def silencio(segundos):
    return np.zeros(int(FS * segundos))


def ruido(segundos):
    return AZAR.uniform(-1, 1, int(FS * segundos))


def golpe_seco(segundos, banda, caida, brillo=0.0):
    """Golpe de objeto: ruido de banda estrecha con caída rápida."""
    base = filtro(ruido(segundos), 'bandpass', banda, orden=2)
    if brillo:
        base += brillo * filtro(ruido(segundos), 'highpass', 3000)
    return base * envolvente(len(base), 0.002, caida)


def normalizar(senal, pico=0.5):
    maximo = np.max(np.abs(senal)) or 1.0
    return senal / maximo * pico


# ─── Efectos ─────────────────────────────────────────────────────────

def papel_tomar():
    """Roce de papel: ráfagas de ruido agudo con pequeñas crepitaciones."""
    duracion = 0.45
    roce = filtro(ruido(duracion), 'bandpass', [1800, 7000])
    modulacion = np.abs(filtro(ruido(duracion), 'lowpass', 30))
    roce *= modulacion / (np.max(modulacion) or 1)
    roce *= envolvente(len(roce), 0.06, 0.18)
    return normalizar(roce, 0.35)


def papel_dejar():
    """Hoja que cae sobre la mesa: soplo corto y un toque sordo."""
    soplo = filtro(ruido(0.3), 'bandpass', [600, 3500]) * envolvente(
        int(FS * 0.3), 0.03, 0.08)
    toque = golpe_seco(0.3, [120, 500], 0.03)
    return normalizar(soplo * 0.6 + toque, 0.35)


def cartulina_en_mimbre():
    """Cartulina sobre una bandeja de mimbre: golpe blando y crujido."""
    golpe = golpe_seco(0.4, [200, 900], 0.04)
    crujido = np.concatenate([
        silencio(0.03),
        filtro(ruido(0.2), 'bandpass', [2500, 6000])
        * envolvente(int(FS * 0.2), 0.005, 0.05),
    ])
    crujido = np.pad(crujido, (0, len(golpe) - len(crujido)))
    return normalizar(golpe + 0.4 * crujido, 0.4)


def pinza_madera():
    """Pinza de tender: chasquido de muelle y clac de madera."""
    muelle = golpe_seco(0.08, [2500, 5000], 0.01)
    clac = golpe_seco(0.25, [700, 1800], 0.025, brillo=0.1)
    return normalizar(np.concatenate([muelle, silencio(0.04), clac]), 0.45)


def balanza_laton():
    """Platillo de latón que se asienta: parciales inarmónicos que se
    apagan, sin tono de «premio»."""
    duracion = 1.4
    t = np.arange(int(FS * duracion)) / FS
    parciales = [(523.0, 1.0), (1187.0, 0.5), (1911.0, 0.3), (2803.0, 0.15)]
    sonido = sum(amplitud * np.sin(2 * np.pi * frecuencia * t)
                 * np.exp(-t * (2.5 + frecuencia / 900))
                 for frecuencia, amplitud in parciales)
    toque = golpe_seco(duracion, [300, 1200], 0.02)
    return normalizar(0.5 * sonido + toque, 0.3)


def caja_abrir():
    """Tapa de caja de cartón: roce y golpe hueco."""
    roce = filtro(ruido(0.35), 'bandpass', [400, 2500]) * envolvente(
        int(FS * 0.35), 0.08, 0.1)
    golpe = golpe_seco(0.35, [90, 350], 0.06)
    return normalizar(roce * 0.5 + golpe, 0.4)


# ─── Ambiente ────────────────────────────────────────────────────────

def ambiente_atico(segundos=40.0):
    """Lluvia fina en la claraboya y alguna viga que cruje. Muy bajo y
    quieto (§1.1.5). Cierra en bucle sin clic."""
    n = int(FS * segundos)
    solape = FS
    lluvia = filtro(AZAR.normal(0, 1, n + solape), 'bandpass', [900, 6000])
    lluvia *= 0.7 + 0.3 * np.abs(filtro(AZAR.normal(0, 1, n + solape),
                                         'lowpass', 0.3)) * 8
    gotas = np.zeros(n + solape)
    for _ in range(int(segundos * 6)):
        posicion = AZAR.integers(0, n + solape - FS // 10)
        gota = golpe_seco(0.05, [2000, 5000], 0.006)
        gotas[posicion:posicion + len(gota)] += gota * AZAR.uniform(0.1, 0.4)
    cama = filtro(AZAR.normal(0, 1, n + solape), 'lowpass', 180) * 0.6
    mezcla = 0.25 * lluvia / np.max(np.abs(lluvia)) + gotas + 0.15 * cama
    for _ in range(3):
        posicion = AZAR.integers(FS, n - 2 * FS)
        crujido = filtro(ruido(0.9), 'bandpass', [150, 600])
        crujido *= np.abs(np.sin(np.linspace(0, 9 * np.pi, len(crujido))))
        crujido *= envolvente(len(crujido), 0.3, 0.3) * 0.15
        mezcla[posicion:posicion + len(crujido)] += crujido
    rampa = np.linspace(0, 1, solape)
    mezcla[:solape] = mezcla[:solape] * rampa + mezcla[n:n + solape] * (1 - rampa)
    return normalizar(mezcla[:n], 0.25)


# ─── Salida ──────────────────────────────────────────────────────────

def a_ogg(senal, ruta_destino):
    os.makedirs(os.path.dirname(ruta_destino), exist_ok=True)
    estereo = np.stack([senal, senal], axis=1).astype(np.float32)
    with tempfile.NamedTemporaryFile(suffix='.wav') as temporal:
        wavfile.write(temporal.name, FS, estereo)
        subprocess.run(
            ['ffmpeg', '-y', '-loglevel', 'error', '-i', temporal.name,
             '-c:a', 'libvorbis', '-q:a', '4', ruta_destino],
            check=True)
    print('  ', os.path.relpath(ruta_destino, RAIZ))


def main():
    efectos = {
        'papel_tomar': papel_tomar,
        'papel_dejar': papel_dejar,
        'cartulina_en_mimbre': cartulina_en_mimbre,
        'pinza_madera': pinza_madera,
        'balanza_laton': balanza_laton,
        'caja_abrir': caja_abrir,
    }
    print('Efectos:')
    for nombre, generador in efectos.items():
        a_ogg(generador(), os.path.join(RAIZ, 'assets', 'sonido', 'efectos',
                                        f'{nombre}.ogg'))
    print('Ambiente:')
    a_ogg(ambiente_atico(), os.path.join(RAIZ, 'assets', 'sonido', 'ambiente',
                                         'ambiente_atico.ogg'))


if __name__ == '__main__':
    main()
