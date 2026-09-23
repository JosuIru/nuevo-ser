#!/usr/bin/env python3
"""Música y efectos de las máquinas de Rexán, sintetizados desde cero.

Sin samples: todo sale de osciladores, ruido y filtros, así que es
composición propia y va con la licencia del contenido del juego
(CC-BY-SA 4.0). Sigue la guía sonora (doc 12): lo-fi nocturno,
contenido, sin épica; bucles cerrados sin clic; el error más corto y
bajo que el acierto.

Uso (desde apps/uno-roto/):
    python3 scripts/sonido/generar_musica_maquinas.py

Deja OGG en assets/sonido/musica/ y assets/sonido/efectos/ (ignorados
por git, como el resto del audio: se regeneran con este script).
Requiere numpy, scipy y ffmpeg.
"""
import os
import subprocess
import tempfile

import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, sosfilt

FS = 44100
AZAR = np.random.default_rng(2026)
RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')


# ─── Utilidades ──────────────────────────────────────────────────────

def nota(nombre):
    """'E3' → Hz (La4 = 440)."""
    orden = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    equivalentes = {'Db': 'C#', 'Eb': 'D#', 'Gb': 'F#', 'Ab': 'G#', 'Bb': 'A#'}
    letra, octava = nombre[:-1], int(nombre[-1])
    letra = equivalentes.get(letra, letra)
    semitonos = orden.index(letra) - 9 + (octava - 4) * 12
    return 440.0 * 2 ** (semitonos / 12)


def filtro(senal, tipo, corte, orden=2):
    sos = butter(orden, corte, btype=tipo, fs=FS, output='sos')
    return sosfilt(sos, senal)


def ruido_circular(n, tipo, corte, gaussiano=False):
    """Ruido filtrado que cierra en bucle: se genera medio segundo de más
    y ese sobrante se funde con el principio."""
    solape = FS // 2
    base = AZAR.normal(0, 1, n + solape) if gaussiano else AZAR.uniform(-1, 1, n + solape)
    ruido = filtro(base, tipo, corte)
    rampa = np.linspace(0, 1, solape)
    ruido[:solape] = ruido[:solape] * rampa + ruido[n:n + solape] * (1 - rampa)
    return ruido[:n]


def envolvente(n, ataque, caida):
    """Ataque lineal y caída exponencial (segundos)."""
    t = np.arange(n) / FS
    ataque_muestras = max(1, int(ataque * FS))
    env = np.exp(-t / max(caida, 1e-3))
    env[:ataque_muestras] *= np.linspace(0, 1, ataque_muestras)
    return env


def sumar_circular(pista, inicio_s, senal):
    """Suma [senal] en [pista] desde [inicio_s], dando la vuelta al final:
    las colas que sobran caen al principio y el bucle cierra sin salto."""
    n = len(pista)
    indices = (int(inicio_s * FS) + np.arange(len(senal))) % n
    np.add.at(pista, indices, senal)


# ─── Instrumentos ────────────────────────────────────────────────────

def piano_fm(frecuencia, duracion, volumen=0.18):
    """Piano eléctrico FM (tipo Rhodes): el brillo del golpe se apaga."""
    n = int(duracion * FS)
    t = np.arange(n) / FS
    indice = 1.6 * np.exp(-t / 0.35) + 0.25
    moduladora = np.sin(2 * np.pi * frecuencia * t)
    portadora = np.sin(2 * np.pi * frecuencia * t + indice * moduladora)
    tremolo = 1 + 0.06 * np.sin(2 * np.pi * 4.2 * t)
    return volumen * portadora * tremolo * envolvente(n, 0.006, duracion * 0.45)


def pad(frecuencias, duracion, volumen=0.05, brillo=1800):
    """Colchón cálido: parciales suaves, ataque lento, filtrado."""
    n = int(duracion * FS)
    t = np.arange(n) / FS
    senal = np.zeros(n)
    for f in frecuencias:
        for desafinado in (-0.12, 0.12):
            for armonico in range(1, 5):
                senal += np.sin(2 * np.pi * f * armonico * t * 2 ** (desafinado / 12)
                                + AZAR.uniform(0, 6.28)) / armonico ** 1.6
    senal = filtro(senal, 'lowpass', brillo)
    ataque = min(duracion * 0.35, 2.5)
    env = np.minimum(1, t / ataque) * np.minimum(1, (duracion - t) / ataque)
    return volumen * senal * env / len(frecuencias)


def pulsada(frecuencia, duracion, volumen=0.22, brillo=0.5):
    """Cuerda pulsada Karplus-Strong."""
    n = int(duracion * FS)
    periodo = int(FS / frecuencia)
    buffer = AZAR.uniform(-1, 1, periodo)
    salida = np.zeros(n)
    for i in range(n):
        salida[i] = buffer[i % periodo]
        buffer[i % periodo] = brillo * (buffer[i % periodo] + buffer[(i + 1) % periodo])
    return volumen * filtro(salida, 'lowpass', 3500)


def bombo(volumen=0.5):
    n = int(0.45 * FS)
    t = np.arange(n) / FS
    frecuencia = 45 + 70 * np.exp(-t / 0.04)
    fase = 2 * np.pi * np.cumsum(frecuencia) / FS
    return volumen * np.sin(fase) * envolvente(n, 0.002, 0.16)


def escobilla(volumen=0.12, duracion=0.22):
    n = int(duracion * FS)
    ruido = filtro(AZAR.uniform(-1, 1, n), 'bandpass', [1800, 6000])
    return volumen * ruido * envolvente(n, 0.004, duracion * 0.35)


def charles(volumen=0.05):
    n = int(0.05 * FS)
    return volumen * filtro(AZAR.uniform(-1, 1, n), 'highpass', 7000) * envolvente(n, 0.001, 0.015)


def bajo(frecuencia, duracion, volumen=0.2):
    n = int(duracion * FS)
    t = np.arange(n) / FS
    # Con 2.º y 3.er armónico: el altavoz del móvil no da la fundamental,
    # pero el oído la reconstruye a partir de ellos.
    senal = (np.sin(2 * np.pi * frecuencia * t) + 0.6 * np.sin(4 * np.pi * frecuencia * t)
             + 0.25 * np.sin(6 * np.pi * frecuencia * t))
    return volumen * senal * envolvente(n, 0.01, duracion * 0.6)


def campana(frecuencia, volumen=0.08):
    """Campana lejana (faro): parciales inarmónicos, caída larga."""
    n = int(5.0 * FS)
    t = np.arange(n) / FS
    senal = sum(a * np.sin(2 * np.pi * frecuencia * r * t) * np.exp(-t / d)
                for r, a, d in [(1, 1, 3.0), (2.76, 0.4, 1.6), (5.4, 0.2, 0.8)])
    return volumen * senal * np.minimum(1, t / 0.004)


def gota(volumen=0.07):
    n = int(0.12 * FS)
    t = np.arange(n) / FS
    frecuencia = 700 + 1300 * t / 0.12
    fase = 2 * np.pi * np.cumsum(frecuencia) / FS
    return volumen * np.sin(fase) * envolvente(n, 0.001, 0.03)


def vinilo(n, volumen=0.012):
    """Crepitar de vinilo: siseo muy bajo y chasquidos dispersos."""
    siseo = ruido_circular(n, 'bandpass', [1500, 7000], gaussiano=True) * 0.25
    chasquidos = np.zeros(n)
    posiciones = AZAR.integers(0, n, n // (FS // 3))
    chasquidos[posiciones] = AZAR.uniform(-1, 1, len(posiciones))
    return volumen * (siseo + filtro(chasquidos, 'highpass', 1500) * 3)


def mar(n, segundos, volumen=0.05):
    """Oleaje: ruido grave con respiración periódica (cierra el bucle)."""
    ruido = ruido_circular(n, 'lowpass', 900, gaussiano=True)
    t = np.arange(n) / FS
    respiracion = 0.55 + 0.45 * np.sin(2 * np.pi * (4 / segundos) * t) ** 2
    return volumen * ruido * respiracion


# ─── Piezas ──────────────────────────────────────────────────────────

def encaje():
    """Tejados · lo-fi, 70 BPM, mi menor. 8 compases."""
    negra = 60 / 70
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    acordes = [
        ('E2', ['E3', 'G3', 'B3', 'D4', 'F#4']),   # Em9
        ('C2', ['C3', 'E3', 'G3', 'B3']),           # Cmaj7
        ('A1', ['A2', 'C4', 'E4', 'G4', 'B4']),    # Am9
        ('B1', ['A3', 'B3', 'E4', 'F#4']),         # B7sus4
    ]
    for c in range(8):
        inicio = c * compas
        raiz, voces = acordes[c % 4]
        for i, voz in enumerate(voces):  # acorde rasgueado, un poco perezoso
            sumar_circular(pista, inicio + 0.02 * i, piano_fm(nota(voz), compas * 0.95, 0.12))
        sumar_circular(pista, inicio, bajo(nota(raiz) * 2, negra * 1.8, 0.09))
        sumar_circular(pista, inicio + 2.5 * negra, bajo(nota(raiz) * 2, negra * 1.2, 0.06))
        sumar_circular(pista, inicio, bombo(0.28))
        sumar_circular(pista, inicio + 2.5 * negra, bombo(0.2))
        for tiempo in (1, 3):
            sumar_circular(pista, inicio + tiempo * negra + 0.015, escobilla())
        for corchea in range(8):  # swing
            desfase = 0.58 * negra if corchea % 2 else 0
            sumar_circular(pista, inicio + (corchea // 2) * negra + desfase,
                           charles(0.045 if corchea % 2 else 0.03))
    # Motivo de 3 notas en los compases 4 y 8, como una pregunta sin prisa.
    for c in (3, 7):
        for i, voz in enumerate(['B4', 'D5', 'A4']):
            sumar_circular(pista, c * compas + (1.5 + i * 0.75) * negra,
                           piano_fm(nota(voz), negra * 2, 0.13))
    pista += vinilo(len(pista))
    return pista


def canales():
    """Canales · 55 BPM, re menor. Arpegio pulsado y gotas. 8 compases."""
    negra = 60 / 55
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    acordes = [
        ['D3', 'F3', 'A3', 'C4'],      # Dm7
        ['A#2', 'D3', 'F3', 'A3'],     # Bbmaj7
        ['G2', 'A#2', 'D3', 'F3'],     # Gm7
        ['A2', 'D3', 'E3', 'G3'],      # A7sus4
    ]
    for c in range(8):
        voces = acordes[c % 4]
        inicio = c * compas
        sumar_circular(pista, inicio, pad([nota(v) for v in voces], compas * 1.15, 0.035, 1200))
        arpegio = voces + [voces[2], voces[1]] + [voces[3], voces[2]]
        for i, voz in enumerate(arpegio):
            sumar_circular(pista, inicio + i * negra / 2,
                           pulsada(nota(voz) * 2, 1.6, 0.11 if i % 2 else 0.14))
    segundos = len(pista) / FS
    for instante in AZAR.uniform(0, segundos, 14):
        sumar_circular(pista, instante, gota(AZAR.uniform(0.03, 0.07)))
    pista += 0.6 * mar(len(pista), segundos, 0.03)
    return pista


def puentes():
    """Puerto · sin tempo, fa menor. Drones, oleaje y el faro. 32 s."""
    segundos = 32
    pista = np.zeros(segundos * FS)
    sumar_circular(pista, 0, pad([nota(v) for v in ['F3', 'G#3', 'C4', 'D#4']], 17, 0.07, 1800))
    sumar_circular(pista, 16, pad([nota(v) for v in ['C#3', 'F3', 'G#3', 'C4']], 17, 0.07, 1800))
    sumar_circular(pista, 0, bajo(nota('F2'), 16, 0.06))
    sumar_circular(pista, 16, bajo(nota('C#2'), 16, 0.06))
    for instante, voz in [(6, 'G#4'), (22, 'C5')]:
        sumar_circular(pista, instante, campana(nota(voz)))
    pista += mar(len(pista), segundos, 0.06)
    return pista


def percusion_mano(volumen=0.18, grave=True):
    """Golpe de cajón o bongó suave: tono corto con piel."""
    n = int(0.2 * FS)
    t = np.arange(n) / FS
    frecuencia = (110 if grave else 240) * (1 + 0.5 * np.exp(-t / 0.01))
    fase = 2 * np.pi * np.cumsum(frecuencia) / FS
    piel = filtro(AZAR.uniform(-1, 1, n), 'bandpass', [800, 3000]) * np.exp(-t / 0.006)
    return volumen * (np.sin(fase) * envolvente(n, 0.001, 0.07) + 0.3 * piel)


def parejas():
    """Mercado · 88 BPM, sol mayor con toques frigios. Guitarra pulsada y
    percusión de mano, cálido. 8 compases."""
    negra = 60 / 88
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    acordes = [
        ('G2', ['G3', 'B3', 'D4']),
        ('E2', ['E3', 'G3', 'B3']),
        ('C2', ['C3', 'E3', 'G3', 'B3']),
        ('D2', ['D3', 'F#3', 'A3', 'C4']),
    ]
    for c in range(8):
        inicio = c * compas
        raiz, voces = acordes[c % 4]
        # Guajeo: acorde pulsado a contratiempo, a lo son.
        for tiempo in (0, 1.5, 2.5, 3.5):
            for i, voz in enumerate(voces):
                sumar_circular(pista, inicio + tiempo * negra + 0.012 * i,
                               pulsada(nota(voz) * 2, 0.9, 0.07))
        sumar_circular(pista, inicio, bajo(nota(raiz) * 2, negra * 1.4, 0.1))
        sumar_circular(pista, inicio + 2.5 * negra, bajo(nota(raiz) * 3, negra, 0.07))
        for tiempo, grave in [(0, True), (1, False), (1.5, False), (2, True),
                              (3, False), (3.5, False)]:
            sumar_circular(pista, inicio + tiempo * negra, percusion_mano(0.14, grave))
    # Un giro frigio (la bemol) al final, un guiño del Mercado.
    for i, voz in enumerate(['D5', 'C5', 'G#4', 'G4']):
        sumar_circular(pista, 7 * compas + (2 + i * 0.5) * negra,
                       piano_fm(nota(voz), negra, 0.09))
    return pista


def minas():
    """Industria · 64 BPM, do# modal. Pulso de máquina, metal y
    reverberación: estructurado, casi inhumano. 8 compases."""
    negra = 60 / 64
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    for c in range(8):
        inicio = c * compas
        sumar_circular(pista, inicio,
                       pad([nota(v) for v in ['C#3', 'G#3', 'D#4']], compas * 1.1, 0.05, 1400))
        sumar_circular(pista, inicio, bajo(nota('C#2'), compas * 0.9, 0.08))
        for corchea in range(8):  # tic metálico constante, como una prensa
            sumar_circular(pista, inicio + corchea * negra / 2,
                           charles(0.05 if corchea % 2 == 0 else 0.025))
        sumar_circular(pista, inicio + negra, percusion_mano(0.12, True))
        sumar_circular(pista, inicio + 3 * negra, percusion_mano(0.12, True))
    # Golpe de metal lejano cada dos compases (campana grave, sin afinar).
    for c in range(0, 8, 2):
        sumar_circular(pista, c * compas + 2 * negra, campana(nota('C#3'), 0.05))
    return pista


def marimba(frecuencia, volumen=0.16):
    """Láminas de madera: fundamental + 4.º armónico, caída corta."""
    n = int(0.6 * FS)
    t = np.arange(n) / FS
    senal = (np.sin(2 * np.pi * frecuencia * t)
             + 0.35 * np.sin(2 * np.pi * frecuencia * 4 * t) * np.exp(-t / 0.03))
    return volumen * senal * envolvente(n, 0.002, 0.18)


def maraca(volumen=0.05):
    n = int(0.07 * FS)
    ruido = filtro(AZAR.uniform(-1, 1, n), 'bandpass', [3000, 9000])
    return volumen * ruido * envolvente(n, 0.008, 0.025)


def taco_madera(frecuencia, volumen=0.12):
    """Tic-tac de péndulo: golpe de madera afinado, muy corto."""
    n = int(0.12 * FS)
    t = np.arange(n) / FS
    return volumen * np.sin(2 * np.pi * frecuencia * t) * envolvente(n, 0.001, 0.02)


def sonar(volumen=0.08):
    """Ping de sonar lejano: tono puro que cae un poco, con cola larga."""
    n = int(2.5 * FS)
    t = np.arange(n) / FS
    frecuencia = 1180 - 60 * (1 - np.exp(-t / 0.5))
    fase = 2 * np.pi * np.cumsum(frecuencia) / FS
    eco = np.sin(fase) * np.exp(-t / 0.7)
    retardo = int(0.32 * FS)
    eco[retardo:] += 0.35 * eco[:-retardo]
    return volumen * eco * np.minimum(1, t / 0.003)


def serpiente():
    """Juguetona sin euforia · 92 BPM, la menor dórico. Marimba sincopada,
    maraca y bajo. 8 compases."""
    negra = 60 / 92
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    acordes = [
        ('A2', ['A3', 'C4', 'E4', 'G4']),      # Am7
        ('D2', ['D4', 'F#4', 'A4', 'C5']),     # D7 (la sexta mayor, dórica)
        ('A2', ['A3', 'C4', 'E4', 'B4']),      # Am(add9)
        ('G2', ['G3', 'B3', 'D4', 'F#4']),     # Gmaj7
    ]
    # Patrón sincopado de corcheas (1 = suena).
    patron = [1, 0, 1, 1, 0, 1, 0, 1]
    for c in range(8):
        inicio = c * compas
        raiz, voces = acordes[c % 4]
        paso = 0
        for corchea, suena in enumerate(patron):
            if suena:
                voz = voces[(paso * 2 + c) % len(voces)]
                sumar_circular(pista, inicio + corchea * negra / 2, marimba(nota(voz)))
                paso += 1
        sumar_circular(pista, inicio, bajo(nota(raiz) * 2, negra * 1.5, 0.1))
        sumar_circular(pista, inicio + 2.5 * negra, bajo(nota(raiz) * 3, negra * 0.8, 0.07))
        for semicorchea in range(16):
            sumar_circular(pista, inicio + semicorchea * negra / 4,
                           maraca(0.05 if semicorchea % 4 == 2 else 0.025))
        sumar_circular(pista, inicio, percusion_mano(0.12, True))
        sumar_circular(pista, inicio + 1.5 * negra, percusion_mano(0.08, False))
    return pista


def balanza():
    """Pensar despacio · 60 BPM, re mayor con suspensiones. Piano y un
    tic-tac de péndulo que va y viene. 8 compases."""
    negra = 60 / 60
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    acordes = [
        ['D3', 'G3', 'A3', 'E4'],     # Dsus4(add9)
        ['D3', 'F#3', 'A3', 'E4'],    # D(add9): se resuelve
        ['B2', 'E3', 'F#3', 'A3'],    # Bm7sus4
        ['G2', 'D3', 'A3', 'B3'],     # Gmaj9 sin 3.ª
    ]
    for c in range(8):
        inicio = c * compas
        voces = acordes[c % 4]
        sumar_circular(pista, inicio, pad([nota(v) for v in voces], compas * 1.1, 0.04, 1500))
        for i, voz in enumerate(voces):
            sumar_circular(pista, inicio + 0.03 * i, piano_fm(nota(voz), compas * 0.9, 0.08))
        # El péndulo: tic (agudo) y tac (grave), una negra cada uno.
        for tiempo in range(4):
            sumar_circular(pista, inicio + tiempo * negra,
                           taco_madera(1250 if tiempo % 2 == 0 else 940, 0.07))
    # Una nota sola que pregunta, al final de cada vuelta de cuatro.
    for c in (3, 7):
        sumar_circular(pista, c * compas + 2.5 * negra, piano_fm(nota('F#5'), negra * 2, 0.09))
    return pista


def flota():
    """Alta mar · 72 BPM, sol menor. Pad, bajo ostinato, oleaje y un ping
    de sonar lejano en cada compás. 8 compases."""
    negra = 60 / 72
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    acordes = [
        ['G3', 'A#3', 'D4', 'F4'],     # Gm7
        ['D#3', 'G3', 'A#3', 'D4'],    # Ebmaj7
        ['C3', 'D#3', 'G3', 'A#3'],    # Cm7
        ['D3', 'F#3', 'A3', 'C4'],     # D7: vuelve a sol
    ]
    ostinato = ['G2', 'G2', 'D3', 'G2']
    for c in range(8):
        inicio = c * compas
        sumar_circular(pista, inicio,
                       pad([nota(v) for v in acordes[c % 4]], compas * 1.1, 0.05, 1300))
        raiz = ['G2', 'D#2', 'C2', 'D2'][c % 4]
        for i, _ in enumerate(ostinato):
            sumar_circular(pista, inicio + i * negra,
                           bajo(nota(raiz) * (1.5 if i == 2 else 1), negra * 0.8, 0.08))
        sumar_circular(pista, inicio + 0.5 * negra, sonar(0.06))
    pista += mar(len(pista), len(pista) / FS, 0.04)
    return pista


def sinte_arpegio(frecuencia, duracion, volumen=0.07):
    """Onda cuadrada suave (pocos armónicos impares) con filtro."""
    n = int(duracion * FS)
    t = np.arange(n) / FS
    senal = sum(np.sin(2 * np.pi * frecuencia * k * t) / k for k in (1, 3, 5, 7))
    return volumen * filtro(senal, 'lowpass', 2600) * envolvente(n, 0.004, duracion * 0.5)


def salto():
    """Corredor sin épica · 100 BPM, mi menor. Bombo suave a negras,
    charles a contratiempo, arpegio de sinte y bajo en corcheas."""
    negra = 60 / 100
    compas = 4 * negra
    pista = np.zeros(int(8 * compas * FS))
    acordes = [
        ('E2', ['E4', 'G4', 'B4', 'D5']),
        ('C2', ['C4', 'E4', 'G4', 'B4']),
        ('A1', ['A3', 'C4', 'E4', 'G4']),
        ('B1', ['B3', 'D#4', 'F#4', 'A4']),
    ]
    for c in range(8):
        inicio = c * compas
        raiz, voces = acordes[c % 4]
        for tiempo in range(4):
            sumar_circular(pista, inicio + tiempo * negra, bombo(0.22))
            sumar_circular(pista, inicio + (tiempo + 0.5) * negra, charles(0.045))
        for tiempo in (1, 3):
            sumar_circular(pista, inicio + tiempo * negra, escobilla(0.08, 0.15))
        orden = [0, 1, 2, 3, 2, 1, 2, 3]
        for corchea in range(8):
            sumar_circular(pista, inicio + corchea * negra / 2,
                           sinte_arpegio(nota(voces[orden[corchea]]), negra * 0.45))
            sumar_circular(pista, inicio + corchea * negra / 2,
                           bajo(nota(raiz) * 2, negra * 0.4, 0.06 if corchea % 2 else 0.08))
    return pista


# ─── Efectos ─────────────────────────────────────────────────────────

def efecto_fila():
    """Fila completa del Encaje: una quinta que se cierra (doc 12, "equivaler":
    armonía perfecta de dos notas, círculo cerrado)."""
    n = int(1.3 * FS)
    senal = np.zeros(n)
    senal[:] += piano_fm(nota('E5'), 1.3, 0.16)
    tarde = int(0.09 * FS)
    senal[tarde:] += piano_fm(nota('B5'), 1.3, 0.13)[: n - tarde]
    return senal


def efecto_tablon():
    """Tablón encajado: golpe de madera hueco, corto."""
    n = int(0.18 * FS)
    t = np.arange(n) / FS
    tono = np.sin(2 * np.pi * 185 * t) + 0.5 * np.sin(2 * np.pi * 410 * t)
    golpe = filtro(AZAR.uniform(-1, 1, n), 'bandpass', [600, 2500]) * np.exp(-t / 0.008)
    return 0.3 * (tono * np.exp(-t / 0.05) + golpe)


# ─── Salida ──────────────────────────────────────────────────────────

def guardar(senal, ruta, rms_db=-20.0, es_bucle=False):
    """Normaliza por sonoridad (RMS) con techo de pico en -1 dBFS. En la
    música quita lo que hay por debajo de 70 Hz: el altavoz del móvil no
    lo da y sólo roba margen."""
    senal = senal - np.mean(senal)
    if es_bucle:
        senal = filtro(senal, 'highpass', 70)
    rms = np.sqrt(np.mean(senal ** 2)) + 1e-9
    senal = senal * 10 ** (rms_db / 20) / rms
    pico = np.max(np.abs(senal))
    if pico > 10 ** (-1 / 20):
        senal = senal * 10 ** (-1 / 20) / pico
    if not es_bucle:
        cola = min(len(senal), int(0.01 * FS))
        senal[-cola:] *= np.linspace(1, 0, cola)
    estereo = np.stack([senal, senal], axis=1)
    if es_bucle:
        # Un poco de anchura: el canal derecho va 11 ms detrás (circular).
        estereo[:, 1] = np.roll(senal, int(0.011 * FS))
    with tempfile.NamedTemporaryFile(suffix='.wav') as temporal:
        wavfile.write(temporal.name, FS, (estereo * 32767).astype(np.int16))
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', temporal.name,
                        '-c:a', 'libvorbis', '-q:a', '5', ruta], check=True)
    print(f'{os.path.relpath(ruta, RAIZ)}  {len(senal) / FS:.1f} s  '
          f'{os.path.getsize(ruta) // 1024} KB')


if __name__ == '__main__':
    musica = os.path.join(RAIZ, 'assets', 'sonido', 'musica')
    efectos = os.path.join(RAIZ, 'assets', 'sonido', 'efectos')
    os.makedirs(musica, exist_ok=True)
    os.makedirs(efectos, exist_ok=True)
    guardar(puentes(), os.path.join(musica, 'maquina_puentes.ogg'), -19, es_bucle=True)
    guardar(encaje(), os.path.join(musica, 'maquina_encaje.ogg'), -19, es_bucle=True)
    guardar(canales(), os.path.join(musica, 'maquina_canales.ogg'), -19, es_bucle=True)
    guardar(parejas(), os.path.join(musica, 'maquina_parejas.ogg'), -19, es_bucle=True)
    guardar(minas(), os.path.join(musica, 'maquina_minas.ogg'), -19, es_bucle=True)
    guardar(serpiente(), os.path.join(musica, 'maquina_serpiente.ogg'), -19, es_bucle=True)
    guardar(balanza(), os.path.join(musica, 'maquina_balanza.ogg'), -19, es_bucle=True)
    guardar(flota(), os.path.join(musica, 'maquina_flota.ogg'), -19, es_bucle=True)
    guardar(salto(), os.path.join(musica, 'maquina_salto.ogg'), -19, es_bucle=True)
    # A la altura del acierto existente, no por encima (doc 12).
    guardar(efecto_fila(), os.path.join(efectos, 'fila_completa.ogg'), -27)
    # El tablón es un gesto menor: más bajo que el acierto.
    guardar(efecto_tablon(), os.path.join(efectos, 'tablon.ogg'), -30)
