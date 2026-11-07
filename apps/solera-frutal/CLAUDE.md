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
| 6 Catálogos | ✅ 2026-11-07 | `content/frutal/`: especies (7), variedades (22, sin revisar), plagas (20; las 13 de almendro y avellano con su guía GIP del MAPA), sustancias activas (38, contrastadas con el Registro MAPA del 06/11/2026 y la EU Pesticides DB: `revision-ia:`) y fenología (15, sin revisar). Compilador genérico sobre la librería común. En la app: autocompletado de variedad, plaga y sustancia filtrado por especie; plazo de seguridad máximo del registro como aviso (no se rellena); aviso si el uso no está en el catálogo; umbral de la guía al apuntar un muestreo; polinización en la ficha; avisos de helada en Hoy (previsión de 7 días × fenología); nombres del catálogo en listas y PDF. 57 tests |
| 7 IA visual | ✅ 2026-11-07 | Ficha de parcela → Seguimiento de plagas → icono de escáner: foto (cámara o galería) → hasta 3 candidatos del catálogo de **esa especie** con confianza y motivo (salida estructurada con `enum` de ids + «otra») → la persona elige y se abre el alta de un **muestreo** con la plaga rellena. Nunca propone tratamientos. Modelo equilibrado del core, clave BYO en `estado/clave_anthropic_frutal.dart` (Ajustes → Inteligencia artificial). La foto se borra al terminar. Intérprete puro testeado. 62 tests |
| 8 Branding + GPS | ✅ 2026-11-07 (placeholder) | Logo ImageMagick (almendra con hoja sobre crema) en `assets/`, iconos de lanzador (`flutter_launcher_icons`), pantalla de arranque crema con el logo y logo en la cabecera de Hoy. GPS: «Usar mi ubicación» al editar la parcela (geolocator) y mapa de parcelas (OSM) desde Parcelas. Permisos INTERNET y ubicación en el manifiesto. 41 tests |
| 9 Economía | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Ingresos y gastos: régimen de IVA (REAGP / general / sin elegir) en `configuraciones_fiscales`; apuntes con base, IVA o compensación REAGP (12 %, solo en venta de cosecha), parcela opcional → margen por parcela; resumen del año y extracto PDF con sello. Importes en céntimos. Guardarraíles fiscales en `test/dominio/economia_test.dart`. 49 tests |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 10 (revisión con fuente pública y cotejo de los PDF con el texto vigente); después el 11.

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
- **2026-11-07 — Ubicación = un punto por parcela** (de pie en ella con el GPS),
  no el polígono SIGPAC: basta para el mapa y la meteo; el recinto oficial va
  en el código SIGPAC.
- **2026-11-07 — Permiso INTERNET declarado** en el manifiesto principal: sin
  él la IA y la meteo no funcionan en la APK release (Obrador no lo declara; ver
  el informe al coordinador).
- **2026-11-07 — Economía mínima REAGP** (como Obrador, sin terceros ni
  facturas): en REAGP no factura el agricultor sino que el comprador paga la
  compensación; las facturas del core se dejan para cuando el asesor fiscal
  fije el régimen. Tabla `configuraciones_fiscales` (nombre de la mayoría de
  la suite, no el de aceitera). Venta de cosecha al 4 % en régimen general.
- **2026-11-07 — Sustancias activas sacadas del Registro MAPA, no de las
  guías GIP**: las guías de 2015 no nombran ninguna («productos autorizados en
  el Registro»). Una fila por sustancia con sus usos `especie:plaga`; las
  mezclas cuentan para cada componente. El plazo de seguridad es el **máximo**
  del registro (criterio de aceitera) y la nota da el rango; en la app es un
  aviso, nunca se rellena el campo (manda la etiqueta). Fuera: aceite de
  parafina sin CAS, parafina 97862-82-3 (dato UE incoherente), *B.
  amyloliquefaciens* FZB24 (no está en la base UE) y los alcoholes de las
  mezclas de feromona.
- **2026-11-07 — Variedades y fenología sin fuente leída** pero dentro del
  catálogo, con `revisado_por` vacío: sin ellas no hay autocompletado ni
  avisos. Los grupos de incompatibilidad se dejan vacíos a propósito (la app
  no dirá nunca «cubierta» sin fuente) y la temperatura crítica también (se
  avisa con el umbral genérico de 2 °C del core en los estados sensibles).
- **2026-11-07 — Avisos de helada con la previsión de la primera parcela con
  ubicación** para todas: explotaciones pequeñas y una sola llamada a la red.
- **2026-11-07 — Sin catálogo de plagas para frutal de hueso y pepita**: no se
  leyó ninguna guía; las parcelas de esas especies se apuntan con texto libre.
- **2026-11-07 — La IA propone un muestreo, no un tratamiento**, y solo entre
  las plagas del catálogo de la especie (más «otra»): así no puede sugerir
  sustancias ni dosis, y lo que apunta queda como observación revisable.
  Modelo equilibrado, como Obrador: un error de diagnóstico lleva a tratar mal.
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
