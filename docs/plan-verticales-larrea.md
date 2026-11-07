# Plan — nuevas verticales Larrea en paralelo y sin intervención

> **Estado**: plan, 2026-11-07. Sin lanzar.
> **Parte de**: `docs/propuestas/larrea-ganadera.md` y `docs/propuestas/larrea-modulos-transversales.md` (2026-11-06), que este plan **asume y no repite**.
> **Objetivo**: llevar 9 verticales nuevas y 4 módulos transversales hasta el mismo listón que `solera-aceitera` (F1 completa con sello PROVISIONAL, APK release, catálogos con fuente pública), trabajando en paralelo, con agentes y sesiones que **no se paran a preguntar**.

---

## 1. Qué se construye

### Verticales (apps nuevas)

| # | App (`apps/…`) | Para quién | Núcleo que digitaliza | Se apoya en | Coste relativo |
|---|---|---|---|---|---|
| V1 | `solera-obrador` — **Larrea Obrador** | **Panaderías artesanas, obradores caseros, repostería, conservas y mermeladas** | APPCC (temperaturas, limpieza, plagas, proveedores, formación) · **fichas técnicas de receta con escandallo** (coste por pieza y por hornada) · **14 alérgenos** y etiqueta (Reglamento 1169/2011) · lotes y trazabilidad · **masa madre** (refrescos, temperatura, actividad) · plan de hornadas y pedidos fijos (bares, tiendas, comedores) · registro sanitario (RGSEAA / registro autonómico de pequeñas producciones) | **Quesera casi entera** (`receta`, `lote_produccion`, `control_*`, `formacion`, `simulacion_trazabilidad`) | Bajo |
| V2 | `solera-sidra` — **Larrea Sagardoa** (sidra y txakoli) | Sagardotegis y bodegas de txakoli pequeñas | Pomaradas y variedades locales · cuaderno de fitosanitarios · molienda, kupelas, lotes, embotellado · DO Euskal Sagardoa / DOP Sidra de Asturias / DO de txakoli · temporada de txotx | **Aceitera** (cultivo y transformación) + **viticultura** (bodega) | Bajo |
| V3 | `solera-frutal` — **Larrea Frutal** (frutos secos y fruta) | Almendro, avellano, nogal, castaño, frutal de hueso y pepita | Cuaderno PAC · plagas · riego · cosecha y calibres · polinización (enlace con la apícola) | **Agro**: casi solo cambian los catálogos | Bajo |
| V4 | `solera-ganadera` — **Larrea Ganadera** | Extensivo pequeño y mixto | Ficha propia: `docs/propuestas/larrea-ganadera.md` (F1G-1…10) | **Copia** del dominio de ganado de Zunbeltz (ver §5, regla Z) | Medio |
| V5 | `solera-huerta` — **Larrea Huerta** | Horticultura ecológica y grupos de consumo | Rotaciones y bancales · cuaderno de certificación ecológica · semillas propias · **cestas por socio** | Agro + módulo transversal **T2 venta directa** | Medio |
| V6 | `solera-monte` — **Larrea Monte** | Montes particulares, juntas vecinales, comunales | Plan de gestión · rodales · aprovechamientos de leña y madera (lotes de suertes) · certificación PEFC/FSC · incendios (pistas, puntos de agua) | Arbolado urbano (inventario, QR) + Concejo (lo comunal, sin depender de su código) | Medio |
| V7 | `solera-vivero` — **Larrea Vivero** | Viveros de planta hortícola, forestal y ornamental | **Pasaporte fitosanitario** · registro de productores de vegetales (ROPVEG) · stock por lote y por bandeja · trazabilidad de semilla a planta vendida | Arbolado (QR) + quesera (lotes) | Medio |
| V8 | `solera-aromaticas` — **Larrea Aromáticas** | Plantas aromáticas y medicinales, destilación | Cultivo o recolección silvestre (permisos) · secado · destilación (rendimiento de esencia) · lotes | Aceitera (la transformación) | Bajo-medio |
| V9 | `solera-espacios-test` — **Larrea Espacios Test** | Otros espacios test agrarios (red RETA) | Proyectos por tester, convenio, rentabilidad, panel WP | **Zunbeltz**: solo diseño en este plan (ver decisión D1) | Medio |

### Módulos transversales (en `nuevo_ser_core`, una sola vía)

| # | Módulo | Detalle | Lo usan |
|---|---|---|---|
| T0 | **`BaseDatosSolera`** (deuda R5) + **plantilla de vertical** | §3 | Todas |
| T1 | **Pasaporte del producto** (QR al consumidor) | propuesta transversal §1 | Obrador, sidra, quesera, aceitera, ganadera, aromáticas |
| T2 | **Venta directa** (catálogo, pedidos, repartos, cestas, modo feria) | propuesta transversal §2 | Obrador (pedidos fijos), huerta (cestas), todas las de producto |
| T3 | **Biodiversidad y eco-regímenes** | propuesta transversal §3 | Ganadera, huerta, frutal, monte |
| T4 | **Campos SIEX** (revisión y exportador intermedio JSON/CSV) | propuesta transversal §5 | Todas las de cultivo |

La CUMA (propuesta transversal §4) queda fuera: hace falta un colectivo piloto.

---

## 2. Calles de trabajo (quién toca qué)

La regla para no pisarse: **cada calle es dueña de unas rutas, y nadie más escribe en ellas.**

| Calle | Dueña de | Quién la lleva |
|---|---|---|
| **N — Núcleo** | `packages/nuevo_ser_core/` (excepto `src/plazos/`, que es de apps-3a), `content/solera/` | **Una sola sesión o agente a la vez**, en la rama `nucleo-larrea` |
| **V1…V9 — una por vertical** | `apps/solera-<v>/`, `content/<v>/` y nada más | Un agente por vertical, en **worktree propio** (`.claude/worktrees/solera-<v>`, rama `vertical/solera-<v>`) |
| **I — Integración** | `main`, `CLAUDE.md` raíz, `melos.yaml`, `scripts/publicar_release.sh`, releases y este plan | La sesión coordinadora (la que lanza el plan) |
| **Externas (ya en marcha)** | apps-3a: `scripts/{pendientes,auditoria,traducciones,fichas,servidor-grupo}/`, `src/plazos/`, `content/solera/plazos.csv`, tests CRUD en `apps/*/test/` · apps-69: `social/apps/concejo` · solera-zunbeltz-ba: `apps/solera-zunbeltz/`, `wp-plugin/solera-zunbeltz-sync/` | Se respetan: el plan **no escribe** en ellas |

Consecuencias:
- **Una vertical que necesita algo del core no lo escribe.** Lo pide añadiendo una línea a `docs/plan-verticales/peticiones-nucleo.md` y, mientras tanto, lo implementa **dentro de su app** como `lib/provisional_core/<pieza>.dart`. Cuando N lo publica, la vertical migra y borra la copia. Así nunca se queda esperando.
- `melos.yaml` ya incluye `apps/*`, así que **las apps nuevas no tocan archivos compartidos**.
- El `CLAUDE.md` raíz solo lo edita I, al integrar cada vertical.

---

## 3. Fase 0 — cimientos (en serie, antes de abrir verticales)

Es lo único que va en serie, porque multiplica todo lo demás.

| Bloque | Contenido | Criterio de cierre |
|---|---|---|
| **N0-0** | ✅ **Hecho por apps-3a (2026-11-07, `f8b8263`)**: la apícola pasa a esquema v3, así que las BD en v2 ya reciben `facturas`. Test de contrato sin `skip`; 79 tests verdes | — |
| **N0-1** | ✅ **Hecho por apps-3a (2026-11-07)**: tests de contrato en las 6 apps (`test/datos/contrato_base_datos_test.dart` + `soporte_contrato_base_datos.dart`, este último idéntico en las 6 y candidato a subir al core). Commits `4636600` agro, `43e7987` aceitera, `affaf94` viticultura, `8d71397` apícola, `40562b1` quesera, `7d1c761` arbolado | — |
| **N0-2** | ✅ **Hecho (2026-11-07)**: `BaseDatosSolera` en `nuevo_ser_core/src/datos/base_datos_solera.dart`, con apertura perezosa y cerrojo, FK, pasos de migración numerados que se comprueban al abrir, `guardarFilaUnica` en transacción y `cerrar()`. El core depende solo de `sqflite_common` (Dart puro), y cada app pasa `databaseFactory` de `package:sqflite`. 8 tests propios. Aceitera migrada: 105 tests verdes, los de contrato sin cambiar. **Pendiente**: subir `soporte_contrato_base_datos.dart` al core cuando migren las demás (N0-5) | — |
| **N0-3** | ✅ **Hecho en lo que compensa (2026-11-07)**. El cliente de IA y la clave de Anthropic **ya estaban** en el core (`src/ia/`): las verticales nuevas los usan. **Compilador de catálogos**: piezas comunes en `nuevo_ser_core/tool/catalogos/compilador_catalogos.dart` (Dart puro, importado por ruta relativa); la aceitera las usa y genera los mismos ficheros (`8a597c1`). Las otras cuatro apps conservan su copia, porque migrarlas no aporta a las verticales nuevas. **Permisos de GPS** y **test del sello**: van en la plantilla y no en el core, porque necesitan plugins (geolocator, permission_handler) que arrastrarían a los juegos Kids. **Libro económico REAGP**: no se sube; la vertical que lo necesite copia el de aceitera (el obrador, además, no es REAGP) | — |
| **N0-4** | ✅ **Hecho (2026-11-07)**: `scripts/nueva_vertical.sh <id> "<Nombre>" <primario> <crema> <prefijo> <Clase>`. Genera android/ y linux/, pubspec con el stack y el core, branding, Hoy y Ajustes (selector de idioma y titular), BD sobre `BaseDatosSolera`, permisos de GPS, compilador sobre la librería común, traducciones es/eu/ca/gl (las tres últimas en borrador), tests de BD y del sello, `CLAUDE.md` con la tabla de bloques y `BLOQUEOS-PENDIENTES.md`. Probado dos veces con `prueba`: analyze limpio, 3 tests verdes y APK debug; después se borró | — |
| **N0-5** | ✅ **Hecho (2026-11-07)**: agro, viticultura, apícola, quesera y arbolado heredan de `BaseDatosSolera` (commits `0ac39db`…`490f6df`), con los guardados de fila única en transacción. Tests verdes sin cambiar los de contrato: agro 81, viticultura 60, apícola 79, quesera 69, arbolado 63. Zunbeltz no se ha tocado y sigue compilando. **Diferencias que siguen sin unificar** (exigirían migrar datos): aceitera usa `configuracion_fiscal`/`anyo_fiscal_activo` y el resto `configuraciones_fiscales`/`ano_fiscal_activo`; la quesera guarda importes en REAL. Opcional: subir `soporte_contrato_base_datos.dart` al core | — |

**N0-5 no bloquea las verticales**, que pueden empezar en cuanto termina N0-4.
**Zunbeltz no se toca en la Fase 0** (BD sincronizable distinta y cliente en uso).

---

## 4. Fase 1 — verticales en paralelo

### Bloques estándar de cada vertical (`F1<X>-n`)

Son los 11 de aceitera ya probados, con la plantilla delante:

| Bloque | Contenido | Hecho cuando |
|---|---|---|
| 1 | `scripts/nueva_vertical.sh` + encuadre en `CLAUDE.md` (para quién, diferencial, normativa que digitaliza **con fuente oficial enlazada**, hard limits) | analyze limpio, smoke test verde |
| 2 | Modelos POJO + esquema sobre `BaseDatosSolera` | round-trip y casos límite de cada modelo con test |
| 3 | Pantallas básicas (Hoy, Mapa si aplica, listas, fichas, alta, Ajustes) + onboarding | analyze limpio, tests de widget de alta y lista |
| 4-5 | Los **dos documentos oficiales** de la vertical en PDF con `informe_periodico` + sello PROVISIONAL | guardrail del sello verde |
| 6 | Catálogos CSV en `content/<v>/` + compilador | tests de integridad referencial |
| 7 | IA visual (BYO key, `cliente_anthropic` del core) | tests del parser y del matching con el catálogo |
| 8 | Branding placeholder (ImageMagick) + GPS | icono y splash generados |
| 9 | Economía (REAGP o el régimen que toque) + facturas del core, PROVISIONAL | guardrails fiscales verdes |
| 10 | Catálogos revisados con **fuente pública** (`revisado_por=fuente_publica`) y documentos cotejados con el texto vigente en BOE/EUR-Lex | todas las filas con fuente citada; el flag `catalogosCompletamenteRevisados` **sigue en false** hasta la firma humana (`asesor:`/`persona:`), y el banner se ve |
| 11 | APK release + build Linux, ayuda in-app, `README.md` | APK firmado con la clave de pruebas, tamaño apuntado |

Particularidades que el agente de cada vertical **ya trae escritas en su encargo** (§7):
- **V1 Obrador**: el bloque 9 **no es REAGP** (actividad de transformación: estimación objetiva o directa, IVA general y reducido; **Verifactu sí puede aplicar**). Todo PROVISIONAL y anotado para el asesor fiscal. Bloques 4-5 = **plan APPCC + registros** y **ficha técnica con alérgenos y etiqueta**. Bloque 7 = IA de lectura de **etiquetas de ingredientes del proveedor** para sacar alérgenos (no de plagas). Masa madre y escandallo como lógica pura con tests. Norma de calidad del pan (RD 308/2019, límite de sal): **verificar el texto vigente** antes de usarla.
- **V2 Sidra**: bilingüe es/eu **desde el bloque 1**, con terminología marcada como borrador.
- **V4 Ganadera**: sigue los bloques F1G de su ficha y la **regla Z** (§5).
- **V5 Huerta**: hasta que T2 esté en el core, las cestas van en `lib/provisional_core/`.
- **V9 Espacios Test**: **solo el bloque 1 en modo diseño** (documento de qué se generaliza de Zunbeltz, sin código) hasta que se resuelva D1.

### Oleadas (limitadas por disco y RAM, no por ganas)

Máquina: 12 núcleos, 62 GB de RAM, **15 GB libres en `/home` (98 %)**. Un worktree con `build/` y un APK release ocupa ~2-4 GB, y Gradle consume ~4-6 GB de RAM por compilación.

| Oleada | Verticales | Por qué juntas |
|---|---|---|
| **0** | Fase 0 (calle N) | cimientos |
| **A** | V1 Obrador · V2 Sidra · V3 Frutal | las de más reutilización, y prueban la plantilla con tres perfiles distintos |
| **B** | V4 Ganadera · V8 Aromáticas · V7 Vivero | ganadera es la más larga y arranca cuando la plantilla ya está rodada |
| **C** | V5 Huerta · V6 Monte · (V9 diseño) | dependen de T2 y T3 |
| Paralela a A-C | Calle N: T1 Pasaporte → T2 Venta directa → T3 Biodiversidad → T4 SIEX | consumidas por B y C |

Reglas de recursos (las cumple cada agente):
1. **Como mucho 3 verticales activas a la vez + la calle N.**
2. **Un solo `flutter build apk` simultáneo** en toda la máquina: `flock /tmp/larrea-build-apk.lock flutter build apk --release`. `flutter test` y `analyze` sí van en paralelo.
3. Tras cada APK: `flutter clean` en el worktree y copiar el APK a `~/larrea-apks/` (fuera del repo).
4. Antes de empezar un bloque: `df --output=avail -BG /home`. **Con menos de 8 GB, la vertical se pausa** (escribe el estado en su `CLAUDE.md` y termina). La integración libera espacio (worktrees integrados, `build/` de apps quietas) y relanza.
5. **Antes de la oleada A, liberar espacio** (D4): los `build/` de las 20 apps del monorepo ya ocupan bastante.

---

## 5. Integración y reglas de convivencia

- **Commits pequeños** (<10 archivos) en la rama de la vertical, en castellano, con el prefijo `solera-<v>:`.
- **Integración por bloques, no al final**: cuando una vertical cierra un bloque, I hace `git rebase main` en su rama, pasa `flutter analyze` + `flutter test` de **esa app y del core**, y la fusiona en `main` (fast-forward). El árbol sucio de `main` (Concejo, wp-theme, el-cuaderno…) **no se toca ni se incluye**.
- **Cambios del core**: solo desde la calle N. Antes de fusionar un cambio del core, I pasa los tests de **todas** las apps que dependen de él (`melos run test` con filtro `--depends-on=nuevo_ser_core`). Si algo se rompe fuera de las verticales nuevas, el cambio no entra y vuelve a N.
- **Regla Z (Zunbeltz)**: la ganadera **copia** `modelos/ganado*.dart`, `carga_ganadera.dart`, `ganado_ecologico.dart`, `historial_animal.dart` y lo que arrastren, **sin modificar `apps/solera-zunbeltz/`**. Que Zunbeltz pase a depender del paquete común lo decide luego Josu con la sesión de Zunbeltz (F1G-2 de la ficha, fuera de este plan).
- **Traducciones**: cada vertical escribe solo en `content/solera/traducciones/<id>.csv` (claves con su prefijo). El generado `nuevo_ser_core/lib/src/i18n/solera_l10n.dart` lo tocan todas: si choca al integrar, se regenera con `dart run tool/compilar_traducciones_solera.dart` y **nunca se fusiona a mano**.
- **Avisos entre sesiones**: al arrancar cada oleada, I manda a las sesiones vivas del monorepo (`ListAgents`) qué rutas se van a tocar, igual que hizo apps-3a.
- **Releases**: al cerrar el bloque 11, I publica la release `solera-<v>-v0.1.0` con `echo s | scripts/publicar_release.sh` (permiso dado el 2026-11-04). Son releases de prueba, no Play Store.

---

## 6. Contrato de autonomía («sin intervención»)

Cada agente trabaja con estas reglas, que van en su encargo.

**Decide solo y apunta** (en `apps/solera-<v>/CLAUDE.md`, sección «Decisiones tomadas sin consultar», con el porqué):
- alcance dentro de su ficha, nombres, estructura y pantallas;
- contenido de catálogos a partir de **fuentes públicas citadas** (`revisado_por=fuente_publica`);
- formato de los PDF oficiales a partir del texto legal vigente consultado (**con enlace y fecha**), siempre con sello PROVISIONAL;
- textos eu/ca/gl como **borrador** marcado;
- branding placeholder;
- ante una duda, **la opción más conservadora** (menos alcance, menos afirmaciones legales, más sellos) y seguir.

**No hace nunca, y lo apunta en `BLOQUEOS-PENDIENTES.md` en vez de pararse**:
- retirar un sello PROVISIONAL (exige asesor humano);
- afirmar que la app «cumple» una norma;
- recomendar medicamentos, fitosanitarios por marca o dosis;
- tocar rutas de otra calle, `main`, Zunbeltz, Concejo o el árbol sucio;
- publicar fuera de GitHub Releases (Play Store, webs, correos, contactar con nadie);
- gastar dinero, contratar servicios o crear cuentas;
- `git push --force`, borrar ramas ajenas, `reset --hard` sobre trabajo ajeno.

**Si se atasca** (un test que no sale en 3 intentos razonables, una API de Flutter que no se puede verificar): lo apunta como bloqueo técnico, deja el bloque a medias **compilando** y pasa al siguiente bloque que no dependa de él.

**Traspaso entre agentes**: cada bloque lo hace un agente nuevo que **solo** lee el `CLAUDE.md` de la vertical, su ficha (§7) y este plan. Por eso el `CLAUDE.md` se actualiza al cerrar **cada** bloque con el estado, lo que queda y la siguiente acción. Ningún bloque depende de la memoria de una conversación.

**Herramientas ya disponibles (apps-3a, 2026-11-07)**, que cada vertical usa en vez de reinventarlas: los plazos legales van a `content/solera/plazos.csv` (solo plazos leídos en la fuente); en el bloque 10, `scripts/auditoria/` saca la lista de comprobación por asesor (solo cuenta como firma humana un `revisado_por` que empiece por `asesor:` o `persona:`); en el bloque 11, `scripts/traducciones/` exporta los ARB eu/ca/gl para la revisión nativa; y al cerrar, la vertical aparece en el tablero de `scripts/pendientes/`.

**Verificación de cada bloque por otro agente** (barata, solo lectura): analyze + tests + `grep` del sello + que no haya archivos fuera de las rutas de la calle. Si falla, el bloque se reabre una vez; si vuelve a fallar, se apunta y se sigue.

---

## 7. Fichas de encargo

Antes de la oleada A, I escribe `docs/plan-verticales/<v>.md` por vertical (una página): para quién, diferencial frente a lo que ya hay en el mercado (**con búsqueda real, no de memoria**), normativa con enlaces BOE/EUR-Lex verificados, modelos de datos previstos, los dos documentos oficiales, catálogos y sus fuentes, branding propuesto, hard limits y particularidades de los bloques. La ganadera ya la tiene (`docs/propuestas/larrea-ganadera.md`).

Esas fichas son lo único que distingue un encargo de otro, así que se escriben con calma y se revisan juntas: **son el punto de mayor apalancamiento del plan**.

---

## 8. Cómo se ejecuta

Mecanismo: el **tool Workflow** (orquestación de subagentes con `isolation: worktree`), lanzado por oleadas desde la sesión de integración:

```
oleada(verticales):
  en paralelo por vertical (máx. 3):
    por cada bloque 1..11 en orden:
      agente constructor (worktree de la vertical)  → commits del bloque
      agente verificador (solo lectura)             → OK / reabrir una vez
      integración: rebase + tests + fast-forward a main
  calle N en paralelo: siguiente módulo T pendiente
```

Coste aproximado, para decidirlo con los ojos abiertos: unos **2 agentes por bloque × 11 bloques × 9 verticales ≈ 200 agentes**, más ~25 de la calle N. Por oleadas son ~70 agentes cada una. Es mucho más que el tamaño por defecto de un workflow (<10 agentes), así que **cada oleada se lanza con permiso explícito** o se sube el límite en `/config` (Dynamic workflow size).

Alternativa más barata: **una sesión interactiva por vertical** (como se hizo con aceitera) con esta ficha y este plan como encargo, y la sesión de integración fusionando. Más lenta, pero se ve todo.

---

### Estado de las verticales (2026-11-07): las 8 con código, terminadas

| Vertical | Estado |
|---|---|
| V1 Obrador | ✅ bloques 1-11 (38 tests, APK release de 65 MB). Release de GitHub pendiente de push |
| V2 Sidra | ✅ bloques 1-11, hechos por un agente e integrados (53 tests, APK release de 67,4 MB) |
| V4 Ganadera | ✅ bloques 1-11, hechos por un agente e integrados (99 tests, APK release de 68,2 MB; build de Linux bloqueado por falta de `lld-21`). Copiado de Zunbeltz 92ade2b sin tocarla |
| V7 Vivero | ✅ bloques 1-11, hechos por un agente e integrados (75 tests, APK release de 80,3 MB) |
| V8 Aromáticas | ✅ bloques 1-11, hechos por un agente e integrados (67 tests, APK release de 66,3 MB) |
| V5 Huerta | ✅ bloques 1-11, hechos por un agente e integrados (113 tests, APK release de 66,1 MB). Cestas en `lib/provisional_core/venta_directa/` hasta que exista T2 |
| V6 Monte | ✅ bloques 1-11, hechos por un agente e integrados (84 tests, APK release de 66,5 MB) |
| V3 Frutal | ✅ bloques 1-11, hechos por un agente en worktree e integrados (65 tests, APK release de 67,6 MB) |

### Presupuesto de tokens (2026-11-07)

A Josu le queda el ~25 % de la cuota semanal hasta el **lunes 9-nov por la tarde**. Hasta entonces **no se lanza ningún workflow ni oleada**. Solo pasos baratos, de uno en uno: fichas de encargo (§7) y como mucho un bloque de la Fase 0. Las oleadas empiezan con la cuota renovada, **una oleada por semana de cuota** como mucho, y cerrando la anterior antes de abrir la siguiente.

## 9. Decisiones previas (con la opción por defecto si no hay respuesta)

| # | Decisión | Por defecto |
|---|---|---|
| D1 | ~~¿Producto a partir de Zunbeltz?~~ **Resuelta (2026-11-07, Josu)**: Zunbeltz está en producción y en uso, **no se toca** (ni código, ni `build/`, ni su plugin). Sirve como **referencia** de diseño y de código: se puede leer y copiar | V9 = solo documento de diseño; V4 copia, nunca mueve |
| D2 | ¿Mecanismo de ejecución: workflow por oleadas o sesiones por vertical? | Workflow, oleada A primero, revisión, y luego las demás |
| D3 | Nombres visibles (Larrea Obrador, Sagardoa, Frutal, Huerta, Monte, Vivero, Aromáticas) | Los de la tabla §1 |
| D4 | ~~Liberar disco~~ **Hecho (2026-11-07)**: borrados los `build/` de agro, aceitera, apícola, arbolado, quesera, viticultura, fósiles y naturaleza, más las cachés de Gradle 9.3.1 (ningún proyecto la usa) y `build-cache-1`. Los APK release se guardaron en `~/larrea-apks/`. De 15 a 39 GB libres. No se tocaron Zunbeltz ni Concejo (en uso). Quedan por decidir: el emulador `~/.android/avd` (8,7 GB), las revisiones viejas de snap (15 GB, necesita sudo) y `~/Descargas` (9 GB) | — |
| D5 | ¿Las releases de las verticales nuevas se publican en GitHub según se cierran? | Sí, como prerelease |

## 10. Criterio de «terminado» de todo el plan

- 9 fichas escritas y V1-V8 con los 11 bloques cerrados en `main`; V9 con su documento de diseño.
- T0-T4 en el core, consumidos por al menos dos verticales cada uno, y sin copias en `lib/provisional_core/`.
- `melos run analyze` y `melos run test` verdes en todo el monorepo.
- Cada vertical con su release `solera-<v>-v0.1.0`, su `CLAUDE.md` al día y sus `BLOQUEOS-PENDIENTES.md` con la lista de asesores humanos necesarios para retirar los sellos.
- `CLAUDE.md` raíz actualizado con la suite ampliada.
