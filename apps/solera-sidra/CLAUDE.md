# Larrea Sagardoa — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/sidra.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | 11 modelos (`Titular`, `Sagardotegi`, `Pomarada`, `Manzano`, `Tratamiento`, `PartidaManzana`, `Prensado`, `Kupela`, `MedicionKupela`, `Trasiego`, `SesionTxotx`, `Embotellado`, `ApunteEconomico`), 15 tablas en la v1. Dominio: `campania.dart` (sep-ago, pliego F.1) y `saldo_kupelas.dart` (litros por kupela y origen por trasiegos). 22 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas Hoy (bienvenida/onboarding, litros en bodega, txotx de hoy, «por revisar»), Pomaradas (alta, ficha con tratamientos y manzanos marcados), Bodega (kupelas con ocupación; desde la cabecera: entradas de fruta, prensados, embotellados; ficha de kupela con medir, trasegar, embotellar y calificación), Txotx (temporada) y Ajustes (sagardotegi, titular, régimen). Hojas con selector de fecha. 38 tests, 5 de pantalla y 4 de claves de traducción |
| 4-5 Documentos oficiales PDF | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Documentos, por campaña (actual y anterior): **cuaderno de la pomarada** (parcelas con SIGPAC, tratamientos fitosanitarios con sustancia, n.º de registro, cantidad, aplicador, carné y eficacia; cosecha propia) y **libro de elaboración y embotellado** propio con los registros del ap. E del pliego (entrada de fruta, prensados con sus partidas, kupelas con entradas/salidas/saldo al cierre y calificación, trasiegos, txotx, embotellado con contraetiquetas numeradas y balance). Tablas en funciones puras con test; PDF con `informe_periodico` del core. 43 tests |
| 6 Catálogos | ✅ 2026-11-07 (adelantado al 3) | `content/sidra/`: 268 variedades de manzana (pliegos Euskal Sagardoa y Asturias), 11 de uva (DO de txakoli), 18 plagas, 61 sustancias activas (registro MAPA 06/11/2026 + EU Pesticides DB) y 8 productos DOP con sus límites. `dominio/catalogos.dart` y `comprobacion_dop.dart` (avisos de acidez volátil, grado, SO₂, densidad del mosto y rendimiento). Banner de provisionales en Hoy |
| 7 IA visual | ✅ 2026-11-07 | Ficha de la pomarada → ✨: foto de hoja, fruto o rama → propuesta de plaga **del catálogo** (salida estructurada con `enum` de los 18 ids + «ninguna» / «no identificada»), confianza, otras posibles y síntomas vistos. Si es del catálogo, ofrece «Apuntar tratamiento» con la plaga ya puesta (la sustancia la elige la persona). Aviso de organismo regulado (fuego bacteriano). Nunca productos ni dosis. Modelo equilibrado del core, clave BYO en `estado/clave_anthropic_sidra.dart` (Ajustes → IA). La foto se borra al terminar. 47 tests |
| 8 Branding + GPS | ✅ 2026-11-07 (placeholder) | Logo ImageMagick (manzana verde `#6B7A2E` con hoja sobre crema `#F5EFE2`) en `assets/`, iconos del lanzador con `flutter_launcher_icons` (adaptativo con fondo crema), logo en la cabecera de Hoy, etiqueta «Larrea Sagardoa» en Android. **GPS**: «Estoy aquí» en la pomarada guarda latitud y longitud (permisos de ubicación e INTERNET añadidos al manifiesto) |
| 9 Economía | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Ingresos y gastos: apuntes por mes con base, tipo de IVA o **compensación del REAGP (12 %)** en vez de IVA; la app propone tipo y compensación por categoría (`dominio/resumen_economico.dart`, LIVA arts. 91, 126 y 130 leídos en el BOE). El resumen separa venta de manzana (actividad agraria) de sidra, txakoli y txotx (transformación y servicios), con IVA y compensaciones orientativos, y extracto PDF con sello. Régimen fiscal del titular en Ajustes. 52 tests |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 10 (revisión con fuente pública de catálogos y documentos).

## Encuadre

**Para quién**: sagardotegis familiares y bodegas pequeñas de sidra natural y
de txakoli, con pomaradas o viñas propias, que compran manzana a vecinos,
elaboran en kupelas y venden en el txotx, en botella y a hostelería. Fuera:
sidra industrial y espumosa a gran escala. Detalle en
`docs/plan-verticales/sidra.md`.

**Diferencial**: la cadena completa pomarada → partida → prensado → kupela →
txotx / botella de una sagardotegi pequeña, en euskera y castellano desde el
inicio.

**Normativa leída** (2026-11-07):

| Norma | Qué saca la app | Fuente |
|---|---|---|
| Pliego de la DOP Euskal Sagardoa (jul-2024) | Registros del ap. E (cultivo: polígono, parcela, recinto, superficie, n.º de manzanos, edad, variedad; cosecha: registro de entrada con proveedor, cantidad, fecha de recolección, estado y entrega; elaboración: día de envasado, cantidad, partida, día de etiquetado, n.º de etiquetas y numeraciones, destino; balance de existencias al final de campaña). Campaña sep-ago (F.1). Densidad mínima del mosto 1045 a 20 °C (F.2). Rendimiento del prensado 40-75 % (F.3). Cada depósito es una partida (F.4). Límites de los tres productos (C.3). Entidad de control: Fundación HAZI (H). Etiquetas numeradas del órgano de control (I) | [pliego](https://www.euskadi.eus/contenidos/informacion/calidad_diferenciada_dopigp/es_def/adjuntos/Pliego-de-condiciones-Euskal-Sagardoa_20240719.pdf) |
| Pliego de la DOP Sidra de Asturias | Límites de sidra natural y espumosa, variedades por clasificación tecnológica, rendimiento máx. 75 % (rápido) / 80 % (lento) | [pliego (asturias.es)](https://www.asturias.es/documents/4911212/4919930/DOP-Sidra-Normal25.pdf/dc24402b-e4a8-ff38-fc8c-24838b3296dd) |
| Pliegos de Bizkaiko, Getariako y Arabako Txakolina | Variedades y límites analíticos por tipo, rendimientos | [Bizkaia 2024](https://www.euskadi.eus/contenidos/informacion/dop_txakoli_bizkaia/es_dapa/adjuntos/BIZKAIKO-TXAKOLINAren-pliegoak-20241128-consolidado.pdf) · [Araba 2024](https://www.euskadi.eus/contenidos/informacion/dop_txakoli_araba/es_dapa/adjuntos/Pliego-Arabako-Tx-20241219-consolidado.pdf) · [Getaria 2011, **por verificar si hay versión posterior**](https://euskadi.eus/contenidos/informacion/dop_txakoli_getaria/eu_dapa/adjuntos/PLIEGO-CR-GT_29-06-2011.pdf) |
| RD 1311/2012 (cuaderno de fitosanitarios) y registro electrónico | Cuaderno de la pomarada | RD 34/2025 ([BOE](https://www.boe.es/eli/es/rd/2025/01/21/34)); aplazamiento opcional al 1-ene-2027 según [nota del MAPA de 18-nov-2025](https://www.mapa.gob.es/dam/mapa/contenido/prensa/notas-de-prensa/documentos/documentos-2025/25-11-18-cm-bases-reguladoras-ayudas-intercambio-conocimiento.pdf): **por verificar en BOE** |

**Libro de bodega**: el pliego no exige un libro con formato propio, sino los
registros del ap. E y el balance de fin de campaña. El bloque 5 es por eso un
«libro de elaboración y embotellado» propio con esos campos, PROVISIONAL, y el
formato que pida HAZI está en BLOQUEOS.

**Hard limits**: nada de fitosanitarios por marca ni de dosis propuestas por la
app; la app **no certifica** que una sidra cumpla la DOP (compara y avisa);
ningún texto ni el pasaporte promociona el consumo de alcohol.

## Decisiones tomadas sin consultar

- **2026-11-07 — La rama se avanzó a `main` (fast-forward)** antes de empezar:
  se creó desde un `main` anterior al cierre de Obrador, que es la referencia.
- **2026-11-07 — Una sola tabla de parcelas para pomaradas y viñas**
  (`pomaradas.cultivo` = `manzano`/`vid`) y una sola de entradas de fruta
  (`partidas_manzana.fruta` = `manzana`/`uva`): el txakoli es un segundo
  perfil y así no duplica pantallas.
- **2026-11-07 — Kupela física, no por campaña**: su contenido se calcula de
  los movimientos (`SaldoKupelas`). Es una cuenta, no una medida: la merma se
  apunta como trasiego sin destino («retirada»).
- **2026-11-07 — Tratamientos con n.º de registro y cantidad en texto libre**:
  el cuaderno los exige, pero la app no los propone ni guarda marcas; la
  sustancia activa sale del catálogo.
- **2026-11-07 — El registro DOP de pomaradas y proveedores lo declara la
  persona** (casilla): no hay registro público que consultar.
- **2026-11-07 — La v1 se amplió en el bloque 2** con la tabla de apuntes del
  bloque 9: no hay ninguna instalación publicada.
- **2026-11-07 — Importes en céntimos** (como aceitera y obrador).
- **2026-11-07 — Bloque 6 antes que el 3**: las pantallas eligen variedades,
  plagas, sustancias y productos DOP del catálogo; hacerlo al revés obligaba a
  poner campos de texto libre y rehacerlos.
- **2026-11-07 — Catálogo de fitosanitarios generado del registro del MAPA**
  (no a mano): plaga objetivo y plazo de seguridad **máximo** del registro por
  sustancia; fuera las que la EU Pesticides DB no da por aprobadas a fecha de
  hoy. Método en `content/sidra/README.md`.
- **2026-11-07 — Los catálogos van solo en castellano** (nombres de variedades
  y plagas tal como salen en los pliegos y el registro), como en obrador: no hay
  fuente pública con los nombres en las cuatro lenguas.
- **2026-11-07 — La sagardotegi elige una denominación** (`dopId`) y cada kupela
  un producto DOP con el que se comparan sus mediciones: un pliego tiene varios
  productos (sidra, gazi-gozoa, espumosa) con límites distintos.
- **2026-11-07 — El rango de rendimiento 40-75 % de Euskal Sagardoa avisa como
  «habitual»**, no como límite: el pliego lo describe («oscila»), no lo fija. El
  de Asturias (75 % rápido / 80 % lento) sí es límite; la app avisa con el 80.
- **2026-11-07 — Onboarding como tarjeta de bienvenida en Hoy** que abre los
  datos de la sagardotegi (los mismos que en Ajustes), en vez de un asistente
  de varias pantallas: son cuatro campos.
- **2026-11-07 — La pestaña Txotx se ve siempre**; la casilla «abro txotx» solo
  quita el bloque de Hoy. Esconder una pestaña cambia los índices del
  IndexedStack y no aporta.
- **2026-11-07 — Las hojas liberan sus controladores al desaparecer**: liberarlos
  justo después del `await` (como en obrador) rompe la animación de cierre; lo
  cazó el test de pantalla.
- **2026-11-07 — El libro de bodega es propio** («libro de elaboración y
  embotellado»): el pliego de Euskal Sagardoa enumera los registros (ap. E) y el
  balance de fin de campaña, pero no un formato; no se encontró uno de HAZI ni
  del Consejo Regulador. Sello PROVISIONAL y bloqueo apuntado.
- **2026-11-07 — Documentos por campaña (sep-ago)**, no por mes: es el ciclo
  del pliego y del balance de existencias.
- **2026-11-07 — IA con el modelo equilibrado** (como obrador): una propuesta
  equivocada lleva a tratar contra lo que no es.
- **2026-11-07 — La IA propone la plaga, nunca la sustancia**: el formulario
  del tratamiento filtra las sustancias con uso autorizado contra esa plaga y
  la persona elige; así la IA no «recomienda» nada.
- **2026-11-07 — Permiso INTERNET en el manifiesto**: la plantilla no lo trae y
  sin él la IA no funciona en la APK release (en debug sí, por eso no se ve).
  **Obrador tampoco lo tiene**: avisado en el informe, no se toca (otra app).
- **2026-11-07 — GPS de un punto, sin mapa**: la pomarada guarda dónde está
  la persona al pulsar «Estoy aquí». El polígono lo da el SIGPAC (polígono,
  parcela, recinto), que es lo que pide el pliego; un mapa no aporta en F1.
- **2026-11-07 — Economía en un solo libro de apuntes** (como obrador), con la
  compensación del REAGP como casilla: venta de manzana propia (12 %, LIVA art.
  130.Cinco.1.º) frente a sidra y txotx (transformación, fuera del REAGP por el
  art. 126.Uno.1.º). Sin facturas ni impuestos especiales hasta el asesor.
- **2026-11-07 — Tipos de IVA propuestos y editables**: manzana 4 %, sidra y
  txakoli 21 % (bebidas alcohólicas, fuera del 10 %), txotx 10 % (comidas y
  bebidas para consumir en el acto), fitosanitarios 10 %. Leídos en la LIVA
  consolidada; los confirma el asesor.
- **2026-11-07 — Borrar un apunte pide confirmación** (pulsación larga + diálogo).

## Datos técnicos

- Paquete `solera_sidra`, BD `solera_sidra.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/sidra.csv` (claves `sidr.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/sidra/` → `dart run tool/compilar_catalogos.dart`.
- Lógica pura en `lib/dominio/` (sin Flutter, con tests).
- Tests de pantalla: `pantallaAlta(tester)` agranda la vista para que los
  formularios quepan sin desplazar; las claves de traducción las vigila
  `test/i18n/claves_sidra_test.dart` (el test del core no recorre esta app).
- Las hojas (`mostrarHojaFormulario`) reciben sus `controladores` y los liberan
  al desaparecer: no liberarlos a mano después del `await`.
