# V8 — Larrea Aromáticas · ficha de encargo

> **Estado**: ficha, 2026-11-07. Encargo para el agente de V8 de `docs/plan-verticales-larrea.md`.
> **App**: `apps/solera-aromaticas/` · `scripts/nueva_vertical.sh aromaticas "Larrea Aromáticas" 6E5A8A F5EFE2 arom Aromaticas` · prefijo `solera-aromaticas:`.

## Para quién

Productores pequeños de plantas aromáticas y medicinales (lavanda, lavandín, romero, tomillo, salvia, orégano, manzanilla…) en cultivo o en **recolección silvestre**, que secan, venden planta seca o **destilan aceite esencial e hidrolato**. Muchos son de zonas de montaña y despoblación, y complementan otra actividad.

## Diferencial

Nadie lleva la cadena **parcela o zona de recolección → cosecha → secado o destilación → lote** con los rendimientos, que es lo que decide si la campaña sale a cuenta. Encaja con la línea social de la Colección (economía de la montaña).

| Pieza | Base |
|---|---|
| Parcelas de cultivo y **zonas de recolección silvestre** (con el permiso y su vigencia) | aceitera (parcelas) + GPS |
| Cosechas: kg frescos, fecha, estado fenológico (floración) | aceitera (recolección) |
| **Secado**: kg frescos → kg secos, días, método | nuevo (rendimiento) |
| **Destilación**: kg de planta → ml de aceite esencial + litros de hidrolato, duración, tipo de alambique | `Molturacion` de aceitera |
| Lotes de producto (planta seca, aceite esencial, hidrolato) con trazabilidad y pasaporte QR (T1) | lotes |
| Tratamientos (en cultivo) | aceitera |

## Normativa (casi toda **por verificar** en el bloque 1)

| Norma | Qué cubre la app | Nota |
|---|---|---|
| **Recolección silvestre**: Ley 42/2007 del Patrimonio Natural y la Biodiversidad y la **normativa de cada comunidad autónoma** (especies protegidas, autorizaciones, montes públicos) | Zona de recolección con su permiso, especie y cantidades | Una fuente del [proyecto SUDOE](https://pfcyl.es/sites/default/files/biblioteca/documentos/memoria_de_ejecucion_pam_sudoe.pdf) cita una ley de 2003 que parece **derogada**: no usarla. Localizar la vigente por CA |
| **Destino del producto**: alimento (especia o infusión), cosmético o medicamento: [la frontera entre medicamento y alimento](https://www.consumer.es/?p=17937) cambia el régimen | Campo «destino» por lote y sello PROVISIONAL en todo lo que dependa de él | El aceite esencial puede caer bajo la normativa de productos químicos (REACH/CLP): **por verificar**; [debate de 2023 en el sector](https://www.agronewscastillayleon.com/clara-aguilera-la-revision-de-la-normativa-de-productos-quimicos-debe-preservar-el-sector-de-los-aceites-esenciales) |
| RD 1311/2012 y cuaderno de explotación (en cultivo) | Cuaderno de tratamientos | como agro |
| Documentación técnica del sector ([fichas de especies del CTFC](https://apsb.ctfc.cat/docs/E%201.1.%20ES_valuepam%20fichas%20especies_final.pdf), [transformación](https://apsb.ctfc.cat/docs/ficha%20TRANSFORMACION%20PAM.pdf)) | **Fuente pública de los catálogos** de especies y rendimientos orientativos | — |

## Bloques (particularidades)

| Bloque | Contenido |
|---|---|
| 1 | Además del esqueleto: **resolver la normativa** (recolección por CA y destino del aceite) y apuntarla con enlaces en CLAUDE.md. Si no se aclara, los PDF salen con sello y la duda va a BLOQUEOS |
| 2 | `Explotacion`, `Parcela`, `ZonaRecoleccion` (permiso, vigencia, especies, límite), `Cosecha`, `Secado`, `Destilacion` (planta, aceite ml, hidrolato l, horas), `LoteProducto` (tipo, destino, cantidad), `Tratamiento` |
| 4 | Cuaderno de cosechas y recolección (por zona y permiso) |
| 5 | Libro de destilación y lotes (rendimientos), PROVISIONAL |
| 6 | `especies_pam.csv` (nombre científico, parte usada, época), `rendimientos_orientativos.csv` (planta → aceite, con fuente), `plagas_pam.csv` |
| 7 | IA: identificar la especie (la confusión entre especies parecidas es un riesgo real en recolección silvestre) y plagas en cultivo. **Siempre propuesta**, nunca afirmación para consumo |
| 9 | REAGP para la planta; la destilación puede ser transformación: **por verificar** |
| Branding | **lavanda oscuro `#6E5A8A` + crema `#F5EFE2`** |

## Hard limits

Ninguna propiedad medicinal ni terapéutica en ningún texto, etiqueta ni pasaporte. La identificación de especies por IA nunca habilita el consumo. No se anima a recolectar especies protegidas: el catálogo marca las que tienen protección y la app avisa.

## Bloqueos humanos previstos

Técnico de medio natural de la CA (recolección) · asesor de regulación de aceites esenciales (alimentario, cosmético o químico) · asesor fiscal · 2 productores piloto (cultivo y recolección) · revisión nativa eu/ca/gl.
