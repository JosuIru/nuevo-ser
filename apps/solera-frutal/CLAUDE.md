# Larrea Frutal — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/frutal.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | 10 modelos (titular-explotación, parcela, fila de árboles, contrato de polinización, tratamiento, abonado, riego, cosecha, helada, observación de plaga), 10 tablas en la v1. Dominio puro: `resumen_cosecha.dart` (parte por parcela y campaña, plazo de seguridad abierto) y `polinizacion.dart` (polinizadora compatible en la parcela). 24 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas: Hoy (primeros pasos si no hay parcelas, plazos de seguridad abiertos, colmenas puestas, alta rápida de helada), Parcelas (lista, alta/edición con marco → árboles/ha, ficha con filas y variedades, polinización, seguimiento de plagas y últimos tratamientos), Cuaderno (tratamientos, abonados, riegos y heladas del año), Cosecha (parte por parcela y entregas; aviso si se cosecha dentro del plazo de seguridad), Ajustes (titular y asesor). Altas en hojas inferiores con selector de fecha (`formularios_registros.dart`). 34 tests, 5 de pantalla y un guardarraíl propio de traducciones |
| 4-5 Documentos oficiales PDF | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Documentos, año en curso y anterior: **cuaderno de explotación** (datos generales y asesor, identificación de parcelas con nº de orden, tratamientos, fertilización, riegos si los hay y cosecha comercializada) y **parte de cosecha y rendimientos** (por parcela, entregas, heladas y pedrisco para el seguro). Tablas en funciones puras con test; PDF con `informe_periodico` del core. 39 tests. Cotejo de columnas con el modelo andaluz v8 en el bloque 10 |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 6 (catálogos CSV y compilador).

## Encuadre

Explotaciones pequeñas y medianas de almendro, avellano, nogal, castaño,
pistachero y frutal de hueso y pepita, muchas en secano y en zonas de nueva
plantación. Fuera: centrales hortofrutícolas y cooperativas grandes.
Diferencial, normativa con sus enlaces y bloqueos previstos:
**`docs/plan-verticales/frutal.md`** (es la referencia; no se duplica aquí).

Lo esencial que no se toca (hard limits):
- **Nada de marcas ni dosis recomendadas**: los catálogos llevan sustancias
  activas; el producto y la dosis los apunta la persona, copiados de la etiqueta.
- El cuaderno **no sustituye la firma del asesor** ni afirma que se «cumple» una norma.
- Los avisos de helada y de polinización son **orientativos**.
- El seguro agrario solo se recuerda (heladas y pedrisco apuntados); la app no tramita.

## Decisiones tomadas sin consultar

- **2026-11-07 — `Titular` hace de `Explotacion`**: una instalación = una
  explotación (como el resto de la suite). Lleva los datos de cabecera del
  cuaderno: NIF, registro de explotación, municipio y asesor GIP con su ROPO.
- **2026-11-07 — `FilaArboles` y no `Arbol`**: en frutos secos se gestiona
  por filas o bloques de una variedad (dónde están las polinizadoras); el árbol
  individual multiplicaría el trabajo de alta sin aportar al cuaderno.
- **2026-11-07 — Variedades en el catálogo, no en la BD**: la parcela y la fila
  guardan el id del catálogo o un nombre libre si no está.
- **2026-11-07 — Integridad**: una parcela con tratamientos, abonados, riegos o
  cosechas **no se puede borrar** (`ON DELETE RESTRICT`: son registros del
  cuaderno); sus filas, contratos y observaciones se van con ella. Una helada
  sin parcela es de toda la explotación.
- **2026-11-07 — Dosis como texto** tal como la escribe la persona: la app no
  la calcula ni la valida (hard limit de dosis).
- **2026-11-07 — Polinización por grupo de incompatibilidad + época de
  floración** (solape si están a un paso como mucho). Si falta el grupo de
  alguna, queda «por confirmar», nunca «cubierta». Es orientación.
- **2026-11-07 — Se añadió `ObservacionPlaga`** (no estaba en la ficha): el
  seguimiento de plagas clave de la ficha necesita un apunte de muestreo, y la
  IA del bloque 7 propone una observación, no un tratamiento.
- **2026-11-07 — Onboarding = tarjeta «Primeros pasos» en Hoy** mientras no
  haya parcelas, en vez de una pantalla aparte: no hay que recordar si ya se vio.
- **2026-11-07 — Fecha elegible en todos los registros** (en Obrador quedó
  pendiente): el cuaderno se rellena a menudo días después.
- **2026-11-07 — Riegos solo en parcelas de regadío**; borrar un registro es
  pulsación larga con confirmación.
- **2026-11-07 — Guardarraíl de traducciones propio** (`test/traducciones_test.dart`):
  el test del core aún no recorre `apps/solera-frutal/lib`. Pedirlo a la calle N.
- **2026-11-07 — Un cuaderno por año natural** y la cosecha por campaña
  (= año de cosecha), los dos en el mismo PDF: en frutos secos la campaña y el
  año coinciden. Las parcelas se citan por nº de orden, como en el modelo.
- **2026-11-07 — Encabezados de los PDF en el idioma de la app** (como Obrador);
  la versión que se entregue a la administración debería ir en castellano o en
  la cooficial que acepte cada comunidad: lo decide el asesor.
- **2026-11-07 — La v1 se amplía durante la F1** (como en Obrador): no hay
  ninguna instalación publicada.

## Datos técnicos

- Paquete `solera_frutal`, BD `solera_frutal.db` sobre `BaseDatosSolera` del core.
  El esquema v1 está en `sentenciasEsquemaFrutalV1` (lo usa el test de contrato).
- Lógica pura en `lib/dominio/` (sin Flutter, con tests).
- Traducciones: `content/solera/traducciones/frutal.csv` (claves `frut.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/frutal/` → `dart run tool/compilar_catalogos.dart`.
