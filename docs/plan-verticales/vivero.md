# V7 — Larrea Vivero · ficha de encargo

> **Estado**: ficha, 2026-11-07. Encargo para el agente de V7 de `docs/plan-verticales-larrea.md`.
> **App**: `apps/solera-vivero/` · `scripts/nueva_vertical.sh vivero "Larrea Vivero" 3F6B4A F5EFE2 vive Vivero` · prefijo `solera-vivero:`.

## Para quién

Viveros pequeños y medianos de planta hortícola, forestal, frutal y ornamental, incluidos los viveros de semilla local y los de proyectos de reforestación comunitaria. **Fuera**: grandes viveros industriales con ERP propio.

## Diferencial

Trazabilidad **de la semilla o la estaquilla a la planta vendida** y **pasaporte fitosanitario** sin papel, en el móvil y en la nave, con bandejas y lotes identificados por QR. Es la parte cara de llevar a mano.

| Pieza | Base |
|---|---|
| Lotes de semilla o material de partida (origen, proveedor, fecha, código) | lotes de Obrador |
| Siembras y repicados en **bandejas o contenedores** con QR; ubicación en la nave o la parcela | QR de Arbolado urbano |
| Plantas listas por especie, variedad y formato (alveolo, maceta…) y stock | nuevo |
| Salidas (venta o entrega) con el **pasaporte fitosanitario** de la partida | nuevo |
| Tratamientos y cuaderno fitosanitario | aceitera / agro |
| Inspecciones de plagas reguladas y su resultado | autocontrol de Obrador |

## Normativa (verificar el texto vigente antes de cada PDF)

| Norma | Qué cubre la app | Nota |
|---|---|---|
| **Reglamento (UE) 2016/2031** (sanidad vegetal), cap. VII sección 2: pasaporte fitosanitario | Datos de la partida para el pasaporte (código de operador, código de trazabilidad, especie, país de origen) y registro de los emitidos | El **formato** del pasaporte lo fija un reglamento de ejecución de diciembre de 2017: localizarlo y citarlo. La app **prepara** los datos; emitir pasaportes exige estar autorizado |
| **RD 1054/2021** (ROPVEG): [texto en el BOE](https://boe.gob.es/boe/dias/2021/12/16/pdfs/BOE-A-2021-20730.pdf) | Código de operador ROPVEG del vivero en cabeceras y pasaportes | Requisitos para autorizarse a emitir pasaportes, según [Aragón](https://www.aragon.es/tramitador/-/tramite/autorizacion-expedicion-pasaportes-fitosanitarios): inscripción, conocimientos, persona de contacto, plan por instalación e inspecciones de plagas cuarentenarias y RNQP |
| Reglamento de ejecución de 2019, anexos XIII/XIV (productos que necesitan pasaporte; zonas protegidas) | Marca de «necesita pasaporte» por especie en el catálogo | Las excepciones autonómicas (traslado entre instalaciones propias) se verifican por CA |
| RD 1311/2012 y cuaderno de explotación | Cuaderno de tratamientos | como agro |
| Material forestal de reproducción (normativa propia: **por verificar**) | Perfil forestal: origen y región de procedencia del lote | Bloque 1: localizar el RD vigente |

## Bloques (particularidades)

| Bloque | Contenido |
|---|---|
| 2 | `Vivero` (ROPVEG, autorización de pasaporte sí/no), `LoteMaterial` (semilla, esqueje, planta madre), `Bandeja` (QR, alveolos, ubicación), `Siembra`, `Repicado`, `PartidaPlanta` (especie, variedad, formato, cantidad viva, mermas), `Salida` (cliente, cantidad, código de trazabilidad), `PasaporteEmitido`, `Tratamiento`, `InspeccionPlagas` |
| 4 | Cuaderno de tratamientos (copiado de agro o aceitera) |
| 5 | **Datos del pasaporte fitosanitario** por salida (etiqueta PDF imprimible con los campos del formato oficial) y registro de pasaportes emitidos, con sello PROVISIONAL |
| 6 | `especies_vivero.csv` (con «necesita pasaporte» y «zona protegida» según los anexos), `plagas_reguladas.csv` (cuarentenarias y RNQP relevantes), `fitosanitarios_vivero.csv` (sustancias activas, sin marcas) |
| 7 | IA: plagas y enfermedades en planta joven, con el cliente del core |
| 8 | Etiquetas y QR de bandeja (reutilizar el patrón QR de Arbolado), GPS de las parcelas de cultivo exterior |
| 9 | REAGP si el vivero es agrario; si no, libro como el de Obrador. **Por verificar** con el asesor fiscal |
| Branding | **verde planta `#3F6B4A` + crema `#F5EFE2`** |

## Hard limits

La app no emite pasaportes en nombre de nadie: prepara los datos para el operador autorizado. No da por sana una partida: registra las inspecciones que hace la persona o el inspector.

## Bloqueos humanos previstos

Técnico de sanidad vegetal de la CA (formato del pasaporte, plagas reguladas) · asesor fiscal · 2 viveros piloto (hortícola y forestal) · revisión nativa eu/ca/gl.
