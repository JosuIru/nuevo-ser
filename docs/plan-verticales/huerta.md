# V5 — Larrea Huerta · ficha de encargo

> **Estado**: ficha, 2026-11-07. Encargo para el agente de V5 de `docs/plan-verticales-larrea.md`.
> **App**: `apps/solera-huerta/` · `scripts/nueva_vertical.sh huerta "Larrea Huerta" 4E7A2E F5EFE2 huer Huerta` · prefijo `solera-huerta:`.

## Para quién

Horticultura pequeña y diversificada (0,5-5 ha), casi siempre ecológica o en conversión, que vende en **cestas a grupos de consumo**, en mercados y a restaurantes. Muchas son personas que se incorporan desde espacios test.

## Diferencial

La huerta diversificada es un rompecabezas: decenas de cultivos, **rotaciones por bancal**, siembras escalonadas para que haya de todo en la cesta cada semana, y la certificación ecológica exige registrarlo todo. Larrea Huerta une el **plan de bancales y rotaciones** con las **cestas** que alimenta.

| Pieza | Base |
|---|---|
| Parcelas → **bancales** con su historial de cultivos (rotación por familias botánicas) | agro (parcelas) |
| Siembras, plantaciones y cosechas por bancal; **siembras escalonadas** planificadas | nuevo |
| Insumos y tratamientos permitidos en ecológico (registro para el certificador) | aceitera (tratamientos) |
| **Semillas propias** (variedades locales, banco de semillas) con su lote | lotes de Obrador |
| **Cestas por socio**: suscripción, composición semanal según cosecha prevista y real, entregas | módulo transversal T2: mientras no exista, en `lib/provisional_core/` |

## Normativa (verificar el texto vigente antes de cada PDF)

| Norma | Qué cubre la app | Nota |
|---|---|---|
| **Reglamento (UE) 2018/848** (producción ecológica) y su normativa de desarrollo | Registro de parcelas, rotaciones, insumos, semillas (ecológicas o con excepción) y cosechas para el certificador | Cada CA tiene su autoridad u organismo de control (CPAEN en Navarra, ENEEK en Euskadi…): formato **por verificar** |
| RD 1311/2012 y cuaderno de explotación | Cuaderno de tratamientos | como agro |
| Venta directa: RD 1086/2020 (flexibilidad de higiene en pequeñas producciones) y normativa autonómica de venta de proximidad | Avisos y datos de la cesta | **por verificar** (citado de memoria en la propuesta transversal) |

## Bloques (particularidades)

| Bloque | Contenido |
|---|---|
| 2 | `Huerta`, `Parcela`, `Bancal`, `Cultivo` (especie, familia botánica, variedad), `Siembra` y `Plantacion`, `Cosecha`, `Insumo` (con «permitido en ecológico»), `Tratamiento`, `LoteSemilla`, `Socio`, `Suscripcion`, `Cesta` y `LineaCesta`, `Entrega` |
| 2 (lógica) | **Rotación**: aviso si la misma familia vuelve al bancal antes de N años (N del catálogo). **Cesta**: reparto de la cosecha de la semana entre suscripciones. Lógica pura con tests |
| 4 | Cuaderno de campo para el certificador ecológico (parcelas, rotaciones, insumos, cosechas), PROVISIONAL |
| 5 | Hoja de cestas de la semana y de reparto (PDF) |
| 6 | `cultivos_huerta.csv` (familias, ciclo, marco), `rotacion.csv` (años mínimos por familia, con fuente), `insumos_ecologicos.csv` (categorías permitidas por el Reglamento 2018/848, anexos: **verificar**), `plagas_huerta.csv` |
| 7 | IA: plagas y carencias en hoja, con el cliente del core |
| 9 | REAGP, como agro |
| Branding | **verde hoja `#4E7A2E` + crema `#F5EFE2`** |

## Hard limits

La app no certifica nada como ecológico: registra lo que pide el certificador. Nada de fitosanitarios por marca ni de dosis.

## Bloqueos humanos previstos

Organismo de control ecológico de la CA (formato del cuaderno) · asesor fiscal · 2-3 huertas piloto con cestas · revisión nativa eu/ca/gl.
