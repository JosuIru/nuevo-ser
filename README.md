# Colección Nuevo Ser Kids — Monorepo

Monorepo de los juegos digitales pedagógicos de **Colección Nuevo Ser Kids**, la línea infantil/escolar (9-14 años) de la **Colección Nuevo Ser**.

> La Colección madre es un proyecto editorial y de pensamiento más amplio (editorial de libros, plugins para colectivos y comunidades, herramientas para favorecer alternativas y pensamiento crítico y constructivo): https://coleccion-nuevo-ser.gailu.net/. Aquí, "la Colección" se refiere a Kids salvo aviso.

## Estructura

```
.
├── apps/
│   ├── uno-roto/              juego de matemáticas (9-12) — pre-MVP, fase ~8-9
│   └── las-versiones/         juego de pensamiento histórico (10-14) — esqueleto, Fase 10
│
├── packages/
│   ├── nuevo_ser_core/        plataforma compartida (motor maestría, sync, audio, cinemáticas)
│   ├── nuevo_ser_companion/   acompañamiento (Cuaderno, Mosaicos, dashboards) — diferido a v1.5
│   └── nuevo_ser_tutor/       cliente Tutor IA con caché y filtros
│
├── content/                   JSON exportables de habilidades/brechas por juego
├── tests/                     suites cross-package (paridad Dart/PHP)
├── wp-plugin/                 plugin WordPress backend
├── scripts/                   dev/sonido (paquetes de audio, voces ElevenLabs)
├── melos.yaml                 gestión del monorepo
└── pubspec.yaml               workspace raíz (instala Melos)
```

## Empezar

```bash
# Flutter no está en PATH del sistema en este entorno:
export PATH="$HOME/flutter/bin:$PATH"

# 1. Instalar Melos (workspace tool)
dart pub get
# o:
dart pub global activate melos

# 2. Resolver dependencias en todos los paquetes
melos bootstrap

# 3. Análisis estático en todo el monorepo
melos run analyze

# 4. Tests por paquete con test/
melos run test
```

## Por juego

### Uno Roto

Juego educativo de matemáticas (fracciones, decimales, proporciones, geometría) para niños 9-12 años. Pre-MVP en Android. 66 habilidades atómicas implementadas, 4 arcos narrativos completos, tutor IA v0.2 cableado con Anthropic.

```bash
( cd apps/uno-roto && flutter run -d linux )
( cd apps/uno-roto && flutter test )
( cd apps/uno-roto && flutter build apk --debug )
```

Ver `apps/uno-roto/README.md` y `apps/uno-roto/CLAUDE.md` para detalle.

### Las Versiones

Juego de pensamiento histórico (oficio del historiador) para 10-14 años, ambientado en Nafarroa. Esqueleto vacío en este chunk; implementación entra en Fase 10 del roadmap.

```bash
( cd apps/las-versiones && flutter run -d linux )
```

## Refactor `nuevo-ser-core` en curso

Estamos extrayendo la plataforma compartida desde el monolito de Uno Roto. Plan de 9 chunks — ver `~/.claude/plans/vast-soaring-glacier.md` y `coleccion-nuevo-ser/plataforma/nuevo-ser-core-arquitectura.md` §8.2.

Rama de trabajo: `refactor/nuevo-ser-core`.

## Licencia

- **Código**: AGPL-3.0
- **Contenido**: CC-BY-SA 4.0

Marca "Colección Nuevo Ser" reservada (ver `coleccion-nuevo-ser/coleccion/01-manifiesto.md` §6).
