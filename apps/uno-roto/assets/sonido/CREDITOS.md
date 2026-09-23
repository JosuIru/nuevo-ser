# Créditos sonoros — Uno Roto

Toda fuente de audio integrada en el juego debe ser **CC0** (dominio
público) o **CC-BY 4.0** (atribución requerida). Nada con cláusulas NC
o ND porque el juego es AGPL-3.0 + CC-BY-SA 4.0.

Este archivo se actualiza cada vez que se añade un asset y enumera la
licencia + atribución correspondiente. Si la pieza es CC-BY, el nombre
del autor + URL aparecen en pantalla de créditos del juego al final del
Arco 4 (pendiente).

## Estado

`v0.2` — primer lote integrado. **7 efectos + 4 ambient en disco**
(extraídos del pack OwlishMedia CC0). Quedan pendientes: `ambient_mercado`,
`ambient_puerto`, todas las músicas (capa 2), motivos y narrativos.

Archivos ya presentes en disco (NO commiteados — están en `.gitignore`):

```
efectos/
  acierto.ogg, error.ogg, tap.ogg, whoosh.ogg,
  fusion.ogg, ki_subiendo.ogg, fragmento_disuelto.ogg
ambient/
  tejados.ogg (record player loop · 5s × 8)
  canales.ogg (water tap loop · 11s × 4)
  industria.ogg (ticking clock loop · 4s × 12)
  afueras.ogg (night crickets · 82s, sin loop)
```

Para regenerarlos:

```bash
bash scripts/sonido/bajar_sonidos.sh    # baja el pack si no está
bash scripts/sonido/integrar_pack.sh    # copia + extiende loops
```

## Mapa de slots → fuente

El catálogo lógico (ver `lib/sonido/catalogo_sonidos.dart`) declara 33
identificadores. Algunos se pueden resolver con muestras del pack
OwlishMedia; otros requieren música compositiva específica.

### Capa 3 · Efectos (todos CC0, pack OwlishMedia tras `bajar_sonidos.sh`)

| Slot | Pieza recomendada del pack | Razón |
|------|---------------------------|-------|
| `efecto_acierto` | UI/Confirm o Glass/Light shimmer | Cristal rompiendo suavemente — doc 12 |
| `efecto_error` | UI/Back o Soft impact bajo | Tump grave, no estridente — doc 12 |
| `efecto_tap` | Water/Drop pequeño | Gota entrando en agua |
| `efecto_fusion` | Impact/Soft impact + reverb | Dos notas que se acercan |
| `efecto_ki_subiendo` | Sci-fi/Synth rising | Armónico creciente |
| `efecto_fragmento_disuelto` | Glass/Shatter suave | Notas altas dispersándose 0.8-1.2s |
| `efecto_whoosh` | Fabric rustle o air whoosh | Whoosh suave de UI |

### Capa 1 · Ambient por distrito

| Slot | Fuente recomendada | Notas |
|------|-------------------|-------|
| `ambient_tejados` | OwlishMedia → ambient/wind | Viento en azotea |
| `ambient_canales` | Mezcla viento + agua suave | Buscar en pack: water + ambient |
| `ambient_mercado` | Buscar **manualmente** en Freesound | "night market crowd far loop" CC0 |
| `ambient_industria` | OwlishMedia → technology/machine | Máquina lejana en bucle |
| `ambient_puerto` | Mezcla olas + viento + gaviota | Pack tiene water; gaviota requiere búsqueda |
| `ambient_afueras` | Buscar **manualmente** en Freesound | "crickets night countryside loop" CC0 |

### Capa 2 · Música por distrito y combate

Esta capa requiere **piezas compositivas** específicas en el mood del
doc 12. No se cubren con un solo pack. Recomendaciones por slot
(descarga manual desde el navegador):

| Slot | Compositor / pieza recomendada | Fuente | Licencia |
|------|-------------------------------|--------|----------|
| `musica_tejados` | **Kai Engel** — *Memorize* o *Snowfall* | freemusicarchive.org/music/Kai_Engel | CC-BY 4.0 |
| `musica_canales` | **Lee Rosevere** — *Featherlight* o *Quiet Place* | freemusicarchive.org/music/Lee_Rosevere | CC-BY 4.0 |
| `musica_mercado` | **Komiku** — pista de *It's time for adventure!* | freemusicarchive.org/music/Komiku | CC0 |
| `musica_industria` | **Chad Crouch** — *Algorithms* | freemusicarchive.org/music/Chad_Crouch | CC-BY-NC 3.0 ⚠ NO USAR (NC incompatible) |
| `musica_industria` (alt) | **Kai Engel** — *Sustains* | freemusicarchive.org/music/Kai_Engel | CC-BY 4.0 ✓ |
| `musica_puerto` | **Patrick Lee** — *Drifter* | freemusicarchive.org/music/Patrick_Lee | CC-BY 4.0 |
| `musica_afueras` | **Doctor Turtle** — *The Pyre* (acoustic, sparse) | freemusicarchive.org/music/Doctor_Turtle | CC-BY 4.0 |
| `musica_combate_cotidiano` | **Komiku** — pista lo-fi 90 BPM | FMA | CC0 |
| `musica_combate_kurz` | **Kai Engel** — *Modum* (sol mayor inquieto) | FMA | CC-BY 4.0 |
| `musica_combate_zafran` | **Lee Rosevere** — pieza tensa con cuerda | FMA | CC-BY 4.0 |
| `musica_combate_vorax` | **Kai Engel** — *Brand New World* (do# modal) | FMA | CC-BY 4.0 |
| `musica_ceremonia` | **Erik Satie** — *Gnossienne No. 1* (PD) | musopen.org / wikimedia commons | Dominio público |
| `musica_amanecer_final` | **Kai Engel** — *The Beauty of Maths* | FMA | CC-BY 4.0 |

⚠ **CC-BY-NC y CC-BY-ND son INCOMPATIBLES** con AGPL/CC-BY-SA. Verificar
licencia antes de añadir cualquier sample.

### Motivos y narrativos (cortos, requieren edición)

Estos son fragmentos de 3-8 segundos con identidad muy específica. Para
el MVP se pueden recortar de las piezas musicales arriba (con `ffmpeg
-ss` + `-t`) o componer aparte:

| Slot | Estrategia |
|------|-----------|
| `motivo_sora` | Extraer 8s de inicio de `musica_tejados` y aplicar fade out |
| `motivo_kai` | Extraer 3s de un acorde tenso de `musica_combate_kurz` |
| `motivo_montana` | Composición específica (3 notas de cuerda apagada) — pendiente |
| `motivo_eco` | Drone agudo corto (1.5-2s) con reverb largo y fade-in. Eco "llega por silencio" (doc 04) — debe sentirse como una presencia que aparece, no un golpe. Suena al disparar la oferta del tutor en `pantalla_caza._quizasOfrecerTutor`. Pendiente de componer |
| `narrativo_silbido_zafran` | Sample buscado en Freesound: "low whistle ghostly" + sub-bass añadido |
| `narrativo_voz_eco` | Drone agudo + reverb largo (sintético con ffmpeg o pieza ambient cortada) |
| `narrativo_mundo_baja` | No es un sonido — es un filtro low-pass aplicado a las capas 1-2 (manejado en código) |

## Atribuciones (rellenar conforme se añadan piezas)

Cada vez que se incorpore un archivo CC-BY, añadir aquí:

```
- [pieza] · [autor] · [URL] · CC-BY 4.0
```

(vacío al inicio — los efectos del pack OwlishMedia son CC0 y no
requieren atribución, pero se incluyen igualmente por trazabilidad)

### Pack base

- **Owlish Media Sound Effects Pack** · OwlishMedia · https://opengameart.org/content/sound-effects-pack · CC0

### Música real integrada

- `musica_ceremonia` — Erik Satie, *Gnossienne nº 1* (1890). Grabación PD subida a Wikimedia Commons como obra propia del subidor (PD declarado en metadatos). Fuente: https://commons.wikimedia.org/wiki/File:Satie_-_Gnossienne_1.ogg · Dominio público. Pieza completa de 3:38, recodificada a OGG q=3 stereo (~2.4 MB).

### Asignación actual de efectos (todos del pack OwlishMedia · CC0)

| Slot | Archivo origen del pack | Duración |
|------|-------------------------|----------|
| `efecto_tap` | `Impacts/hit.ogg` | 0.35 s |
| `efecto_acierto` | `UI/UI_025.ogg` | 0.88 s |
| `efecto_error` | `UI/UI_034.ogg` | 0.84 s |
| `efecto_whoosh` | `Impacts/scrape1.ogg` | 0.62 s |
| `efecto_fusion` | `UI/UI_011.ogg` | 1.47 s |
| `efecto_ki_subiendo` | `UI/UI_018.ogg` | 4.16 s |
| `efecto_fragmento_disuelto` | `UI/UI_017.ogg` | 3.75 s |

### Asignación actual de ambient (todos del pack OwlishMedia · CC0)

| Slot | Archivo origen | Tratamiento |
|------|----------------|-------------|
| `ambient_tejados` | `Technology/record_player_loop.ogg` | loop ×8 (~40 s, vinilo lo-fi) |
| `ambient_canales` | `Water/tap-water-1.ogg` | loop ×4 (~47 s, agua corriendo) |
| `ambient_industria` | `Ambience/loopable-ticking-clock.ogg` | loop ×12 (~48 s, ritmo de máquina) |
| `ambient_afueras` | `Ambience/night-crickets-ambience-on-rural-property.ogg` | directo (~82 s) |

⚠ Estas elecciones son **placeholder funcional** — son sonidos ambient
plausibles para que la app respire mientras llega el material final.
El record player y el agua de grifo no son las grabaciones que pediría
un compositor; sustituir cuando se pueda.

### Pendientes de buscar/componer

- `ambient_mercado` — Freesound CC0 query "night market crowd ambience"
- `ambient_puerto` — Freesound CC0 mezclar "harbor waves" + "foghorn"
- Toda la capa 2 (música) — placeholders sintéticos en disco; piezas
  finales pendientes (ver §Música y motivos).
- Motivos y narrativos — ver §Motivos abajo

### Música y motivos

**Estado actual: 12 placeholders sintéticos.** Los 12 slots musicales
(`tejados`, `canales`, `mercado`, `industria`, `puerto`, `afueras`,
`combate_cotidiano`, `combate_kurz`, `combate_zafran`, `combate_vorax`,
`ceremonia`, `amanecer_final`) están cubiertos por placeholders OGG
sintetizados con `ffmpeg` puro a partir de drones armónicos
diferenciados por mood. Generados por
`scripts/sonido/generar_placeholders_musica.sh`. ~80-130 KB cada uno,
~1.1 MB en total. Licencia: creación propia (CC-BY-SA 4.0).

Los placeholders permiten que la app respire con material plausible
mientras llega la música compositiva real. Cuando se incorporen las
piezas definitivas, se sobreescriben `assets/sonido/musica/<slot>.ogg`
sin tocar nada del resto del pipeline.

**Para descargar piezas reales** (Kai Engel, Satie, etc.) usa
`scripts/sonido/bajar_musica.sh`:

1. Navega a la fuente recomendada (FMA, Musopen, archive.org…) y
   confirma con tus ojos: licencia compatible (CC0, CC-BY 4.0,
   CC-BY-SA 4.0, dominio público) y mood adecuado al slot.
2. Pega la URL DIRECTA del `.mp3`/`.flac`/`.ogg` en la variable
   `URL_<slot>` del script + autor + licencia + fuente.
3. Lanza el script: descarga, verifica `nc`/`nd` en la URL/licencia,
   convierte a OGG q=3 stereo, deja en `assets/sonido/musica/`.
4. Anota la atribución aquí abajo en este archivo.

⚠ La fila "Kai Engel" del mapa Capa 2 de arriba está marcada como
CC-BY 4.0 pero **mucho de su catálogo está en CC-BY-NC** (Jamendo /
archive.org). Verifica pieza por pieza antes de bajar.

## Cómo probar la integración

1. Ejecutar el script: `bash scripts/sonido/bajar_sonidos.sh`
2. Examinar `app/assets/sonido/_pack_owlishmedia/` y elegir muestras
   para cada slot de la tabla §Capa 3 arriba.
3. Copiar (o symlink) cada elección al nombre que la app espera, p. ej.:
   ```
   cp _pack_owlishmedia/UI/confirm_001.ogg efectos/acierto.ogg
   ```
4. Lanzar la app: `flutter run -d linux` y entrar al cazadero.
5. Si suena: ✓. Si no suena pero la app no peta: el motor sonoro
   tolera la ausencia y la llamada es silenciosa.

## Nota sobre formato

El doc 12 pide WAV 44.1kHz 16-bit. `audioplayers` (el plugin) reproduce
WAV/MP3/OGG sin distinción funcional. Si un sample llega en MP3/OGG, se
puede dejar tal cual y actualizar la ruta en `catalogo_sonidos.dart` —
o convertir con `ffmpeg -i entrada.mp3 -acodec pcm_s16le -ar 44100
salida.ogg` para uniformizar.

## Máquinas de Rexán — composición propia (2026-09-23)

Sintetizado desde cero con `scripts/sonido/generar_musica_maquinas.py`
(numpy + scipy, sin ningún sample): licencia del contenido del juego,
CC-BY-SA 4.0, sin atribuciones de terceros.

| Id | Archivo | Qué es |
|---|---|---|
| `musica_maquina_puentes` | `musica/maquina_puentes.ogg` | Puerto: drones en fa menor, oleaje y campana del faro. 32 s en bucle |
| `musica_maquina_encaje` | `musica/maquina_encaje.ogg` | Tejados: lo-fi 70 BPM en mi menor, piano eléctrico FM y vinilo. 8 compases |
| `musica_maquina_canales` | `musica/maquina_canales.ogg` | Canales: 55 BPM en re menor, arpegio pulsado y gotas. 8 compases |
| `efecto_fila_completa` | `efectos/fila_completa.ogg` | Quinta que se cierra (doc 12, "equivaler") |
| `efecto_tablon` | `efectos/tablon.ogg` | Golpe de madera corto, por debajo del acierto |

Se descartó generar esta música con Ravero (`~/Projects/mesa-mezclas`):
su repertorio de lo-fi usa bancos con licencia aún sin verificar en su
`PROVENANCE.md` (rhodes, guitarra española, arpa, kalimba).

