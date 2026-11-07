# V2 — Larrea Sagardoa (sidra y txakoli) · ficha de encargo

> **Estado**: ficha, 2026-11-07. Encargo para el agente de V2 de `docs/plan-verticales-larrea.md`.
> **App**: `apps/solera-sidra/` · `scripts/nueva_vertical.sh sidra "Larrea Sagardoa" 6B7A2E F5EFE2 sidr Sidra` · prefijo de commits `solera-sidra:`.

## Para quién

Sagardotegis familiares y bodegas pequeñas de sidra natural y de txakoli: tienen pomaradas o viñas propias, compran manzana a vecinos, elaboran en kupelas y venden en el txotx, en botella y a hostelería. **Fuera**: sidra industrial y espumosa a gran escala.

## Diferencial

Nadie digitaliza la cadena completa **pomarada → kupela → botella** de una sagardotegi pequeña en euskera. El modelo de aceitera (cultivo, partida, transformación y lote) encaja casi tal cual:

| Pieza | Base |
|---|---|
| Pomaradas y variedades locales, cuaderno de fitosanitarios | Aceitera (parcelas, tratamientos, cuaderno PAC) |
| Partidas de manzana propias y compradas (proveedor, variedad, kg, procedencia registrada) | `PartidaAceituna` de aceitera |
| Molienda y prensado → mosto → **kupela** (volumen, fecha, densidad, temperatura, trasiegos) | `Molturacion` + `LoteAceite` |
| **Temporada de txotx**: qué kupela se abre cada día, litros servidos | nuevo |
| Embotellado por lote, contraetiqueta de la DOP, pasaporte QR (T1) | lotes + T1 |
| Txakoli como segundo perfil: vendimia → depósito → embotellado | viticultura |

## Normativa (verificar el texto vigente antes de cada PDF)

| Norma | Qué cubre la app | Nota |
|---|---|---|
| **DOP Euskal Sagardoa / Sidra Natural del País Vasco**: [pliego vigente (jul-2024)](https://www.euskadi.eus/contenidos/informacion/calidad_diferenciada_dopigp/es_def/adjuntos/Pliego-de-condiciones-Euskal-Sagardoa_20240719.pdf) y [documento único](https://www.euskadi.eus/contenidos/informacion/calidad_diferenciada_dopigp/es_def/adjuntos/Documento%20Unico%20EUSKAL%20SAGARDOA.pdf). Transfronteriza: [Navarra e Iparralde se suman](https://orain.eus/es/actualidad/economia/2024/01/19/navarra-e-iparralde-se-sumaran-a-denominacion-de-origen-transfronteriza-euskal-sagardoa/) | Manzana del territorio procedente de **manzanales registrados**; características fisicoquímicas de los tres productos amparados. La app **comprueba** procedencia y variedades contra el pliego y **avisa**; no certifica | Leer el pliego entero en el bloque 1 |
| DOP Sidra de Asturias | Segundo perfil de DOP, como las DOP de aceitera | Bloque 6 |
| DO de txakoli (Getariako, Bizkaiko, Arabako) | Perfil txakoli | Bloque 6 |
| Cuaderno de fitosanitarios (RD 1311/2012) y cuaderno digital (registro electrónico obligatorio aplazado al **1-ene-2027**, según [agronews](https://www.agronewscastillayleon.com/aplazamiento-cuaderno); **verificar en BOE**) | Cuaderno de la pomarada | El mismo generador que aceitera |
| Libro registro de bodega / declaraciones (sidra y vino) | **Por confirmar**: no se encontró qué libro exige la entidad de control a la sagardotegi. Bloque 1: buscarlo en el pliego y en el Consejo Regulador; si no aparece, el bloque 5 se queda en «libro de elaboración y embotellado» propio, con sello PROVISIONAL y apuntado en BLOQUEOS | — |

## Bloques (particularidades)

| Bloque | Contenido |
|---|---|
| 1 | Además del esqueleto: **es/eu desde el inicio**, con terminología propia (kupela, txotx, sagardotegi, upel) marcada como borrador |
| 2 | `Sagardotegi`, `Pomarada`, `Manzano` (opcional), `PartidaManzana`, `Prensado`, `Kupela`, `MedicionKupela` (densidad, temperatura, acidez volátil), `Trasiego`, `SesionTxotx`, `Embotellado`, `Tratamiento` |
| 4 | Cuaderno de la pomarada (fitosanitarios), copiado de aceitera |
| 5 | Libro de elaboración y embotellado por campaña (partidas → kupelas → botellas), PROVISIONAL |
| 6 | `variedades_manzana.csv` (las del pliego), `plagas_manzano.csv`, `fitosanitarios_manzano.csv` (solo sustancias activas), `dop_sidra_txakoli.csv` |
| 7 | IA de plagas y enfermedades del manzano (moteado, carpocapsa, pulgón ceniciento, chancro) con el cliente del core |
| 9 | REAGP como agro y aceitera: venta de manzana a otra sagardotegi frente a venta de sidra (actividad de transformación). PROVISIONAL |
| Branding | **verde manzana oscuro `#6B7A2E` + crema `#F5EFE2`** |

## Hard limits

Nada de fitosanitarios por marca ni de dosis. La app no certifica que una sidra cumpla la DOP. El consumo de alcohol no se promociona en ningún texto ni en el pasaporte.

## Bloqueos humanos previstos

Consejo Regulador o entidad de control de la DOP (libro y contraetiqueta) · técnico de la pomarada (cuaderno) · asesor fiscal · 2 sagardotegis piloto · revisión nativa eu.
