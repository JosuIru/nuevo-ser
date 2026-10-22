# El Descifrador — CLAUDE.md

Cerebro persistente del juego. Se lee al inicio de cada sesión. Detalle exhaustivo en el paquete documental v0.1.

## Encuadre del programa

El Descifrador es el cuarto juego de la línea **Colección Nuevo Ser Kids**, tras Uno Roto, Las Versiones y El Cuaderno. La **Colección Nuevo Ser** madre es un proyecto editorial y de pensamiento más amplio (https://coleccion-nuevo-ser.com/). Cuando los docs dicen "la Colección" sin más, se refieren a Kids.

## Qué es El Descifrador

Juego de oficio civil para niños 11-14 años. Verbo motor: **descifrar**. El niño es aprendiz en la oficina de descifradores de **La Estafeta** — un puerto atlántico ficticio peninsular. Llegan papeles del mundo (cartas, panfletos, recetas, manifiestos, etiquetas) en distintas lenguas. El aprendiz los identifica, los entiende lo suficiente, decide qué hacer con ellos, y construye su cuaderno propio.

**No enseña una lengua entera**. Enseña a **leer en lenguas que no dominas con ayuda del contexto**. Es habilidad transferible, no curso de idiomas. Deliberadamente lo contrario de Duolingo.

Lenguas como **contenido nuclear**:
- Cuatro peninsulares cooficiales como L1 desde día uno: castellano, euskara, catalán, gallego.
- L2 lectura asistida: portugués, francés, italiano, inglés, alemán, latín fragmentario.
- Árabe: caso especial — se identifica, no se descifra (biblia §2.10).

## Estado actual

**Fase**: esqueleto técnico v0.1.0 (2026-05-13). Lo único implementado es:
- Estructura Flutter+Melos.
- Dependencias a `nuevo_ser_core` y `nuevo_ser_tutor` por path.
- Cuatro lenguas cooficiales cableadas (es/eu/ca/gl) con `flutter_localizations` + ARB.
- Pantalla esqueleto con mensaje único: *"La Estafeta te espera."*
- Test de humo verde.

Sin mecánica. Sin contenido. Sin assets. Sin motor. Sin corpus. La producción real comienza ahora.

## Documentos de diseño (paquete v0.1)

Vive fuera del monorepo en `~/Projects/juegos/el-descifrador-paquete-documental-v0.1/`. Doce documentos canónicos + catálogo seminal de muestra + propuesta de Fase 1.

Al empezar tarea → solo los relevantes (contexto limitado):

- `el-descifrador-00-propuesta-fase-1.md` — presentación al equipo editorial. Cumplimiento de manifiestos.
- `el-descifrador-01-biblia.md` — diez principios, mecánicas centrales, lo que el juego es y lo que no es.
- `el-descifrador-02-mundo-la-estafeta.md` — ciudad, oficina, personajes recurrentes.
- `el-descifrador-03-mecanica-nuclear.md` — seis operaciones (identificar / marcar / anotar / proponer / verificar / decidir), falsos amigos cómicos.
- `el-descifrador-04-mapa-habilidades.md` — 36 habilidades atómicas en 4 dominios + 5 transversales.
- `el-descifrador-05-lenguas-y-tratamiento.md` — postura anti-Duolingo, repertorio L2, caso árabe.
- `el-descifrador-06-cuaderno-del-jugador.md` — cuaderno persistente como progreso visible, sin XP.
- `el-descifrador-07-decisiones-humanas-pendientes.md` — bloqueantes; 12 resueltas el 2026-05-13.
- `el-descifrador-08-referencias-y-deudas.md` — Kingdom of Loathing / West of Loathing y otros referentes.
- `el-descifrador-09-voces-y-figuras.md` — voz del maestro coral (Antón + Aitziber) + seis remitentes.
- `el-descifrador-10-pedagogia-del-documento.md` — reglas innegociables/blandas/exclusión del corpus.
- `el-descifrador-11-guia-visual.md` — paleta, tipografía, iconografía, sellos.
- `el-descifrador-12-guia-sonora.md` — brevísima. El silencio es el contenido.
- `el-descifrador-13-flujos-de-usuario.md` — diez recorridos paso a paso.
- `el-descifrador-14-prompt-maestro-contenido.md` — para colaboradores humanos + IA como asistente.
- `el-descifrador-15-acompanamiento.md` — vista cuidador, profesor, materiales pedagógicos.
- `el-descifrador-16-arquitectura-tecnica.md` — stack, perfil P6 del motor, plataformas, roadmap.
- `el-descifrador-catalogo-seminal-muestra.md` — diez piezas concretas encarnando el juego.

## Decisiones cerradas (2026-05-13)

Doce decisiones de entrada a Fase 1 aprobadas por autor responsable:

1. Entrada a Fase 1 confirmada.
2. Producción técnica arranca **ya**.
3. Corpus seminal **mixto** (núcleo interno + colaboraciones por lengua).
4. Asesoría lingüística: **cuatro cooficiales primero** antes que L2.
5. IA texto: **asistente declarado** (no producción primaria).
6. Nombre del mundo: **La Estafeta** (definitivo).
7. Edad: **11-14**.
8. Maestro de oficina: **coral Antón + Aitziber**.
9. Plataformas v1.0: **tableta + escritorio Linux + móvil grande**.
10. IA imagen: igual que texto, asistente declarado.
11. Esqueleto técnico: **creado** ya en este monorepo.
12. Piloto Fase 4: **10-20 niños en 2-3 centros**.

## Bloqueos críticos pendientes

Ver `BLOQUEOS-PENDIENTES.md`.

## Stack técnico

Hereda decisiones del monorepo + Uno Roto:

- **Flutter 3.24+ / Dart 3.5** (Melos auto-discovery, sin Riverpod por defecto).
- **shared_preferences** con prefijo `nuevoser.descifrador.*` y `nuevoser.descifrador.perfil.<id>.*` (decisión del monorepo para juegos nuevos).
- **flutter_localizations + intl** con ARB en `lib/l10n/`. Cuatro lenguas cooficiales desde día uno.
- **`nuevo_ser_core`** y **`nuevo_ser_tutor`** por path.
- **Backend WordPress** via plugin `nuevo-ser-core`. Endpoints `/nuevo-ser/v1/descifrador/*`.
- **Tablas BD**: `wp_ns_descifrador_*` con `game_id = 'descifrador'`.

Detalles en `el-descifrador-16-arquitectura-tecnica.md`.

## Reglas de interacción

Heredadas del monorepo (`/CLAUDE.md`) + las del manifiesto Kids + las de este juego:

- **Nombres descriptivos en castellano** para variables/clases/archivos. Términos técnicos (widget, builder…) en original.
- **Commits pequeños**: <10 archivos salvo setup inicial.
- **Tests antes del código no visual**: motor de corpus, cuaderno, decisiones, sync.
- **Respetar tono**: si algo choca con biblia/manifiesto Kids/manifiesto madre → señalar antes de implementar.
- **Sin XP, sin rachas, sin estrellas** (manifiesto Kids §3, biblia §2.7). El progreso visible es **el cuaderno del niño**.
- **Voz del maestro sobria**: nada de "¡muy bien!", nada de emoticonos, nada de exclamaciones formularias. Doc 09 §4.
- **Cada documento del corpus** cumple las cinco reglas innegociables del doc 10 §1.
- **Asesoría lingüística obligatoria** antes de incluir pieza en cualquier lengua que el autor no domine profesionalmente.

## Comandos habituales

```bash
# Desde apps/el-descifrador/ del monorepo (raíz: /home/josu/Projects/monorepo-nuevo-ser/):
flutter analyze
flutter test
flutter run -d linux        # desktop debug

# Flutter path (no está en PATH del sistema):
export PATH="$HOME/flutter/bin:$PATH"
```

## Cosas que NO hacer

- No promete enseñar lenguas enteras. Anti-Duolingo es estructural (doc 05 §5).
- No XP, no estrellas, no rankings, no rachas (manifiesto Kids §3).
- No celebraciones del rendimiento ("¡muy bien!", "perfecto", emoticonos, exclamaciones formularias).
- No inventar voces fuera de las declaradas en doc 09 sin que el autor responsable las firme.
- No incluir pieza en lengua que el autor no domine profesionalmente sin asesoría.
- No poner palabras en boca de persona real histórica (manifiesto madre 3.10).
- No folklorizar ninguna cultura (manifiesto madre 3.8).
- No fingir descifrar árabe pleno (biblia §2.10).
- No usar IA para producción primaria de corpus — solo asistencia declarada (doc 14, decisión 5).

## Tono y voz

Toda voz dirigida al niño jugador (maestro, cuaderno, mensajes de sistema) cumple manifiesto Kids §9: sobria, adulta, respetuosa. Asumimos que el niño es inteligente, atento y digno. Frase corta, palabra precisa, broma cuando cabe, silencio cuando no hace falta decir más. Sin "¡muy bien!", sin emoticonos, sin exclamaciones formularias.

Las voces de los remitentes ficticios del corpus pueden tener cualquier tono — son personas concretas. Pero las voces de **sistema** (maestro de oficina, cuaderno, UI) son sobrias siempre.
