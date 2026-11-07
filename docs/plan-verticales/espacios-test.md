# V9 — Larrea Espacios Test · documento de diseño (sin código)

> **Estado**: diseño, 2026-11-07. Por decisión de Josu (D1 del plan), **no se escribe código**: Zunbeltz está en producción y no se toca. Este documento solo recoge qué habría que generalizar si algún día se ofrece a otros espacios test agrarios.

## Por qué solo diseño

Lo construido para Zunbeltz Elkartea (`apps/solera-zunbeltz/` y `wp-plugin/solera-zunbeltz-sync/`) resuelve el seguimiento de proyectos de test, la economía del convenio, el inventario, las tareas y los roles con el panel de WordPress. Convertirlo en producto plantea preguntas que no son técnicas:

1. **Acuerdo con Zunbeltz**: lo pagó una subvención suya; hay que hablar con ellas antes de ofrecerlo a otros.
2. **Red de espacios test (RETA)**: qué espacios tienen el mismo problema y quién lo financiaría.
3. **Mantenimiento**: dos clientes con el mismo código obligan a versionar el plugin y la app con cuidado.

## Qué es de Zunbeltz y qué sería común (lectura del código, sin tocarlo)

| Pieza | En Zunbeltz | Para un producto común |
|---|---|---|
| Proyectos de test por persona tester, convenio, reparto 25/75 o 50/50 y fianza | `modelos/proyecto_test.dart`, `convenio.dart`, `balance_convenio.dart` | Repartos y fianza configurables por espacio |
| Seis bloques de gasto de su hoja de seguimiento | `partidasGasto` | Bloques y partidas definidos por cada espacio, desde el panel |
| Indicadores del anexo IV de su convocatoria | `indicadores_seguimiento.dart` | Indicadores por convocatoria, como catálogo |
| Ganado, fincas, zonas y puntos | modelos propios | Pasan a **Larrea Ganadera** (V4, copia), y el espacio test los usaría desde allí |
| Panel WP, roles Coordinación y Tester, sincronización con revisión y lápidas | `wp-plugin/solera-zunbeltz-sync/` | Plugin con marca blanca, roles configurables y un espacio por instalación |
| Logos de entidades y RSS del sector | opciones del plugin | Ya son configurables |
| Textos es/eu | ARB propios | Pasar a `SoleraL10n` con las cuatro cooficiales |

## Camino posible (si se decide)

1. Hablar con Zunbeltz y con dos o tres espacios de la red.
2. Larrea Ganadera estable (V4), con su exportación e importación.
3. Fork de la app con marca blanca en `apps/solera-espacios-test/`, que no comparte código en caliente con Zunbeltz hasta que esté estable.
4. Plugin `solera-espacios-test` separado de `solera-zunbeltz-sync`.

## Lo que este documento no decide

Precio, quién lo vende, si Zunbeltz participa en los ingresos, ni cuándo empezar. Es una decisión de Josu.
