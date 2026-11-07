# Monorepo Colección Nuevo Ser Kids — CLAUDE.md

Cerebro persistente del monorepo. Se lee al inicio de cada sesión. Detalle por juego en `apps/<juego>/CLAUDE.md`.

## Encuadre del programa

Este monorepo aloja los juegos digitales pedagógicos de **Colección Nuevo Ser Kids**, la línea infantil/escolar (juegos para 9-14 años) de la **Colección Nuevo Ser**. La Colección madre es un proyecto editorial y de pensamiento más amplio (editorial de libros, plugins para colectivos y comunidades, herramientas para favorecer alternativas y pensamiento crítico y constructivo): https://coleccion-nuevo-ser.com/.

Cuando los docs de este repo dicen "la Colección" sin más, se refieren a Kids.

## Estructura

```
.
├── apps/
│   ├── uno-roto/         juego de matemáticas 9-14 (Kids, en producción, fase ~8-9 MVP)
│   ├── las-versiones/    juego de pensamiento histórico 10-14 (Kids, Fase 10)
│   ├── el-cuaderno/      cuaderno de campo digital 9-13 (Kids, Bloque B)
│   ├── el-descifrador/   juego de oficio civil para descifrar documentos 11-14 (Kids, esqueleto v0.1.0)
│   ├── agro/             Larrea — gestor de fincas (producto comercial)
│   ├── solera-viticultura/   Larrea Viticultura (bodegas pequeñas/medias)
│   ├── solera-apicola/       Larrea Apícola (apicultores 20-200 colmenas)
│   ├── solera-arbolado-urbano/ Larrea Arbolado Urbano (B2B ayuntamientos)
│   ├── solera-quesera/       Larrea Quesera (queserías artesanas, F1-5)
│   └── solera-aceitera/      Larrea Aceitera (almazaras pequeñas, F1-A1 esqueleto)
│
├── packages/
│   ├── nuevo_ser_core/        plataforma compartida (motor maestría, sync, audio, cinemáticas)
│   ├── nuevo_ser_companion/   acompañamiento (Cuaderno, Mosaicos, dashboards) — v1.5
│   └── nuevo_ser_tutor/       cliente Tutor IA con caché y filtros
│
├── social/               línea social (pueblos, barrios, colectivos, comunes): criterios, fuentes y fichas; ver social/CLAUDE.md
├── content/              JSON exportables de habilidades/brechas por juego
├── tests/                suites cross-package (paridad Dart/PHP)
├── wp-plugin/            plugin WordPress backend
├── scripts/              scripts dev/sonido
├── melos.yaml            gestión del monorepo
└── pubspec.yaml          workspace raíz (instala Melos)
```

## Estado de la plataforma

**Refactor `nuevo-ser-core`**: cerrado en `v0.2.0-platform` (commit `9e6b887`). Plan de 8 chunks ejecutado. 12 slices post-refactor extraídos (selector habilidades, multi-perfil, persistencia JSON, ServicioTutor, audio — CapaAudio/Descargador/Version/Sugerencia, CuentaBackend, IdiomaApp, AvatarPerfil). Detalle en `packages/nuevo_ser_core/README.md` y `~/.claude/plans/vast-soaring-glacier.md`.

**Las Versiones (Fase 10)**: MVP Arco 1 + Arco 2 jugable end-to-end. 65 habilidades en 7 dominios, 4 perfiles de medición (P1/P4 funcionales en core). Brechas 1.1, 2.1, 2.2, 2.3, 2.4 jugables con 5 fases. Mosaicos M1 (cómic) y M2 (audio-guía). Companion cableado. Detalle exhaustivo en `apps/las-versiones/CLAUDE.md`. Sustituciones diegéticas en `BLOQUEOS-PENDIENTES.md`.

**Companion v0.1**: 6 endpoints reales de 9 (`POST/GET /companion/cuaderno/entries`, `POST/GET /companion/mosaicos`, `POST /classrooms/{code}/join`, `POST /companion/aggregates/weekly`). 3 pendientes por auth profesor/cuidador. Plugin WP v0.9.0. Detalle en `packages/nuevo_ser_companion/README.md`.

**El Descifrador (esqueleto v0.1.0)**: cuarto juego Kids aprobado el 2026-05-13 a Fase 1. Verbo motor: *descifrar*. Edad 11-14. Mundo: La Estafeta — puerto atlántico ficticio peninsular. Materia: lengua + idiomas L2 lectura asistida + pensamiento crítico + redacción. Las cuatro cooficiales (es/eu/ca/gl) como contenido nuclear desde día uno. Esqueleto Flutter+Melos creado, smoke test verde. Paquete documental v0.1 con 18 documentos fuera del monorepo en `~/Projects/games/el-descifrador-paquete-documental-v0.1/`. 12 decisiones cerradas, 13 bloqueos pendientes (asesoría lingüística cuatro cooficiales primero, corpus seminal mixto, ilustrador, compositor). Sin mecánica todavía. Ver `apps/el-descifrador/CLAUDE.md` y `apps/el-descifrador/BLOQUEOS-PENDIENTES.md`.

## Apps del operador — extraídas a `cuadernos-de-campo/`

`fosiles` y `naturaleza` (apps de operador para adulto aficionado) se separaron de este monorepo el **2026-05-19** y viven ahora en el repo `~/Projects/juegos/cuadernos-de-campo/` (también accesible por el enlace `~/Projects/games`). Mantienen su historia git completa vía `git subtree split`.

**Dependencia que sigue viva**: ambas apps importan `packages/nuevo_ser_core` de ESTE repo vía `path: ../../../nuevo-ser/packages/nuevo_ser_core` en sus pubspec.yaml; esa ruta resuelve por el enlace `~/Projects/juegos/nuevo-ser → ~/Projects/monorepo-nuevo-ser` (creado el 2026-10-22: sin él no compilan). Cuando se actualiza `nuevo_ser_core` aquí, las apps del otro repo lo recogen al hacer `flutter pub get`.

**Backend de Fósiles Comunidad**: el wp-plugin (`wp-plugin/nuevo-ser-core/`, clases `class-ns-fosiles-comunidad.php` y `class-ns-fosiles-admin.php`) y el seed JSON (`wp-plugin/nuevo-ser-core/seeds/fosiles_formaciones.json`) **siguen en este repo**, ride sobre la infraestructura compartida del plugin (NS_Esquema, NS_Activacion, NS_Auth_Adulto). El cliente Flutter del módulo está en cuadernos-de-campo, el servidor aquí.

**Si actualizas el catálogo de formaciones** desde cuadernos-de-campo (regenerar JSON), el path relativo del test escribe a `../../../nuevo-ser/wp-plugin/...` — para que el seed siga sincronizado.

## Producto comercial — Larrea (apps/agro)

`apps/agro/` es **producto comercial general** (no Kids, no operador). Branded como **Larrea**: gestor de fincas agrícolas para Iberia. Modelo: planta con identidad persistente. Estado: F0+F1 cerrado, F1.A en curso, F1.B-F4 pendientes. Diferenciador: modo trufas único en mercado + cuaderno MAPA. Detalle en `apps/agro/CLAUDE.md`.

## Suite Larrea — verticales especializadas

Cinco forks de Larrea por vertical. Comparten widgets (`CampoAutocompleteCatalogo`, `SelectorFotos`, banners) y servicios (`gestor_fotos`, `csv_io`, `informe_periodico_pdf`) en `nuevo_ser_core/src/ui/`. Catálogos en CSVs en `content/<vertical>/` compilados a Dart.

- **`apps/solera-viticultura/`** — bodegas 5-30 ha. Cuaderno PAC móvil (RD 1311/2012) + IA vid. F1-1 a F1-10 cerradas (provisional). Branding burdeos+crema.
- **`apps/solera-apicola/`** — apicultores 20-200 colmenas. Libro REGA + gestión varroa + IA apícola. F1A-1 a F1A-8 cerradas (provisional). Branding ámbar+crema.
- **`apps/solera-arbolado-urbano/`** — B2B ayuntamientos. QR chapa + VTA + multi-operario. F1U-1 a F1U-8 cerradas (provisional). Branding verde+crema.
- **`apps/solera-quesera/`** — queserías artesanas. Cuaderno APPCC + curación + trazabilidad lotes. F1-5 (catálogos provisionales). Branding dorado+crema.
- **`apps/solera-aceitera/`** — almazaras pequeñas y medianas (100-2000 hl/campaña). Cuaderno PAC olivar (RD 1311/2012) + libro de movimientos del aceite (RD 760/2021 + AICA) + DOP olivar + IA visual plagas olivar + cierre fiscal REAGP. **F1-A1 a F1-A11 cerradas** (esqueleto + 18 modelos POJO + sqflite v2 + 20 pantallas + 3 generadores PDF con sello PROVISIONAL R1 + 5 catálogos revisados contra fuente pública con compilador CSV→Dart (flag `catalogosCompletamenteRevisados=false` desde el 2026-11-07: solo una firma `asesor:`/`persona:` lo pone a true, `fuente_publica` no) + IA Claude Vision BYO key + branding placeholder + GPS captura + libro económico REAGP olivar PROVISIONAL completo + target Android `com.coleccionnuevoser.solera_aceitera` con APK release de 56 MB + 83 tests). Auditoría humana final del asesor agrónomo + técnico OCA + auditor AICA + asesor fiscal pendiente para retirar sellos. Branding verde oliva+crema.

Detalle de cada una en su `CLAUDE.md` + `BLOQUEOS-PENDIENTES.md`.

**Contabilidad**: planificado por vertical (agro/viticultura/apícola como gastos REAGP, arbolado como facturación B2B Facturae). Bloqueado por asesor fiscal humano.

**Deuda técnica conocida — refactor BD compartida (auditoría 2026-05-12 R5)**: las 6 apps Larrea (`agro` + 5 verticales) tienen `lib/datos/base_datos.dart` con el mismo patrón (singleton lazy, `openDatabase` sobre `<app>.db` — sin sufijo de versión —, migraciones aditivas) pero tablas distintas y estilos de migración distintos (solo agro usa `_aplicarMigraciones(desde:, hasta:)`; el resto, `if (vieja < N)` en `onUpgrade`). **Hecho el 2026-11-07**: las 6 heredan de `BaseDatosSolera` (`nuevo_ser_core/src/datos/base_datos_solera.dart`: apertura perezosa con cerrojo, FK, pasos de migración `{versión: paso}` comprobados al abrir, `guardarFilaUnica` en transacción). Cada app aporta solo el fichero, la versión, el esquema inicial y los pasos. Para una vertical nueva, heredar de ella. Además, cada app tiene `test/datos/contrato_base_datos_test.dart` (singleton, esquema nuevo, migración desde cada versión sin perder filas, CRUD por la API pública) y un `soporte_contrato_base_datos.dart` común que puede subir al core con el refactor. El fallo que destaparon (solera-apicola: `facturas` en el paso `< 3` con la versión declarada en 2) se corrigió subiendo a v3 (`f8b8263`). Ya no puede repetirse: `BaseDatosSolera` exige al abrir un paso por cada versión de 2 a `versionEsquema` y ninguno por encima (si no, `StateError`). Ver `docs/auditoria-2026-05-12.md` riesgo R5.

## Decisiones cerradas

- **Persistencia local**: shared_preferences con prefijo `uroto.*` y `uroto.perfil.<id>.*` para Uno Roto. Juegos nuevos: `nuevoser.<juego>.*`. Migración a Isar diferida a v1.5.
- **Tablas BD**: prefijo `wp_ns_*` + `game_id`. Renombrado semántico diferido a v1.5.
- **Endpoints**: `/nuevo-ser/v1/*` canónico; `/uno-roto/v1/*` alias deprecado hasta v1.5.
- **Workspace tool**: Melos ^6.0.0 (Dart 3.5).

## Comandos habituales

```bash
# Desde la raíz del monorepo:
dart pub get                                  # instala Melos local
dart pub global activate melos                # alternativa: instala Melos global
melos bootstrap                               # resuelve dependencias en todos los paquetes
melos run analyze                             # flutter analyze por paquete
melos run test                                # flutter test por paquete con test/

# Por paquete:
( cd apps/uno-roto && flutter run -d linux )
( cd apps/uno-roto && flutter test )
( cd apps/uno-roto && flutter build apk --debug )
```

```bash
# Flutter no está en PATH del sistema:
export PATH="$HOME/flutter/bin:$PATH"

# Build Android requiere Java 17 (forzado en apps/uno-roto/android/gradle.properties).
```

## Reglas de interacción

- **Nombres descriptivos en castellano** para variables/clases/archivos. Términos técnicos (widget, builder…) en original.
- **Commits pequeños**: <10 archivos salvo setup inicial.
- **Tests antes del código no visual**: motor, sync, API, persistencia.
- **Verificar antes de inventar**: APIs Flutter/Melos/WordPress confirmadas o preguntadas.
- **Respetar tono**: si algo choca con `coleccion-nuevo-ser/coleccion/01-manifiesto.md` → señalar antes de implementar.

## Utilidades (`scripts/`)

Paquetes Dart o scripts independientes (fuera de Melos), creados el 2026-11-07. Cada uno tiene su README.

- `scripts/pendientes/` — tablero de todo lo que espera a una persona: `BLOQUEOS-PENDIENTES.md`, sellos `PROVISIONAL` en código y catálogos sin firma, agrupado por responsable (`dart run bin/pendientes.dart`).
- `scripts/auditoria/` — lista de comprobación en PDF por vertical y asesor, `firmar` catálogos (`revisado_por=asesor: …`) y `comprobar` qué falta para retirar sellos. **Convención**: solo cuenta como firma humana un `revisado_por` que empiece por `asesor:` o `persona:`; `fuente_publica` o una cita no lo son. `revision-ia:` anota una revisión de Claude con informe y fuentes: se cuenta aparte, no es firma ni retira sellos.
- `scripts/traducciones/` — exporta ARB a CSV para revisión nativa e importa solo las filas `revisado`, validando placeholders e ICU.
- `scripts/servidor-grupo/` — zip del plugin social, `montar-servidor.sh` (instala, activa y comprueba; nunca crea personas ni códigos; `--solo-comprobar` para WordPress con datos vivos) y guía en papel.
- `scripts/fichas/` — fichas A4 imprimibles para el aula sin pantallas a partir de `apps/uno-roto/assets/data/skills.json` (102 de 106 habilidades; generadores deterministas con semilla). Explicaciones escritas por Claude; revisión de IA del 2026-11-07 aplicada (2 errores graves y 22 mejoras, informe en `scripts/fichas/revision-2026-11-07.md`): falta la revisión de una persona docente.
- `nuevo_ser_core/src/plazos/` + `content/solera/plazos.csv` — plazos legales de Larrea con fuente BOE (PROVISIONAL). Solo entra un plazo leído en la fuente.

## Detalle por juego

Cada app mantiene su propio cerebro persistente:

- `apps/uno-roto/CLAUDE.md` — estado actual del juego en producción (fase, mecánicas implementadas, gap frente a doc 03, backlog).
- `apps/las-versiones/CLAUDE.md` — encuadre, mapa de habilidades, hard limits, decisiones, estado actual.
- `apps/agro/CLAUDE.md` — Larrea: encuadre, posicionamiento, modelo de datos, roadmap por fases.
