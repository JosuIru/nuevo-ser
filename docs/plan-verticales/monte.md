# V6 — Larrea Monte · ficha de encargo

> **Estado**: ficha, 2026-11-07. Encargo para el agente de V6 de `docs/plan-verticales-larrea.md`.
> **App**: `apps/solera-monte/` · `scripts/nueva_vertical.sh monte "Larrea Monte" 2F4F3A F5EFE2 mont Monte` · prefijo `solera-monte:`.

## Para quién

Propietarios de **montes particulares** pequeños y **juntas vecinales, concejos y comunidades de montes vecinales en mano común** que gestionan el monte comunal: leña, madera, pastos, setas, prevención de incendios. Encaja con la línea social de la Colección (los comunes).

## Diferencial

El monte comunal se gestiona hoy con papeles, la memoria de los mayores y un técnico forestal que viene de vez en cuando. Larrea Monte pone en el móvil el **inventario por rodales**, el **plan de gestión**, los **aprovechamientos** (los lotes de leña vecinal, «suertes» o «fogueras», sorteados entre vecinos) y la **prevención de incendios**.

| Pieza | Base |
|---|---|
| Monte → **rodales** con especie principal, edad, superficie y estado (polígono en el mapa) | geodesia y zonas de Zunbeltz (**leer y copiar**, nunca tocar) |
| Inventario de árboles singulares o parcelas de muestreo con QR | Arbolado urbano |
| **Plan de gestión**: actuaciones previstas por año y rodal (claras, podas, desbroces) y su ejecución | tareas |
| **Aprovechamientos**: lotes de leña vecinal (sorteo, adjudicatario, m³ o estéreos), subastas de madera, pastos | nuevo |
| **Incendios**: pistas, puntos de agua, cortafuegos, revisiones antes de la temporada | autocontrol de Obrador |
| Certificación forestal (PEFC / FSC): registros que piden | nuevo |

## Normativa (verificar el texto vigente antes de cada PDF)

| Norma | Qué cubre la app | Nota |
|---|---|---|
| **Ley 43/2003 de Montes** y la ley forestal de cada CA | Plan o instrumento de gestión, aprovechamientos (autorización o comunicación según la CA) | **por verificar** por CA: Navarra, Euskadi, Galicia (montes vecinales en mano común) y Asturias primero |
| Montes vecinales en mano común (Ley 55/1980) y normativa gallega | Comunidad propietaria, asamblea y reparto | **por verificar** |
| PEFC / FSC (estándares de gestión forestal) | Registros de la certificación | Fuente: los estándares publicados por cada sistema |
| Prevención de incendios (normativa autonómica y épocas de peligro) | Calendario de revisión y avisos | **por verificar** |

## Bloques (particularidades)

| Bloque | Contenido |
|---|---|
| 2 | `Monte` (titular o comunidad, CA, figura), `Rodal` (polígono, especie, edad, superficie), `ActuacionPlan`, `Ejecucion`, `Aprovechamiento` (tipo, volumen, unidad, adjudicatario, fecha), `LoteLena` (sorteo vecinal), `InfraestructuraIncendios` (pista, punto de agua, cortafuegos), `RevisionIncendios`, `ArbolSingular` |
| 2 (lógica) | Superficie de rodales por especie, volumen aprovechado frente a lo previsto en el plan y **sorteo de lotes de leña** reproducible y justo (semilla publicada, como en Concejo). Tests |
| 4 | Parte de aprovechamientos de la campaña (para la autorización o comunicación de la CA), PROVISIONAL |
| 5 | Estado del plan de gestión (previsto frente a ejecutado) y hoja de revisión de incendios |
| 6 | `especies_forestales.csv`, `unidades_volumen.csv` (m³, estéreos, con conversión orientativa y fuente), `plagas_forestales.csv` (procesionaria, perforadores…) |
| 7 | IA: plagas y daños forestales por foto, con el cliente del core |
| 9 | Libro de ingresos y gastos de la comunidad (subastas, ayudas, trabajos); fiscalidad de las comunidades de montes **por verificar** |
| Branding | **verde pino `#2F4F3A` + crema `#F5EFE2`** |

## Hard limits

La app no autoriza aprovechamientos: prepara la información para el trámite. El sorteo de leña es transparente y verificable, nunca opaco. No sustituye al técnico forestal en el señalamiento.

## Bloqueos humanos previstos

Técnico forestal de la CA · secretaría de una junta o comunidad de montes piloto (Navarra o Galicia) · asesor fiscal · revisión nativa eu/ca/gl.
