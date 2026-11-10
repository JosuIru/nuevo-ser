# Catálogos de Larrea Huerta

CSV curados que `apps/solera-huerta/tool/compilar_catalogos.dart` compila a Dart.
Convenciones de la suite: líneas `#` de comentario arriba con la fuente;
columna `revisado_por` (solo cuenta como firma humana si empieza por
`asesor:` o `persona:`; `fuente_publica` es revisión documental).

| Catálogo | Contenido |
|---|---|
| `cultivos_huerta.csv` | Hortalizas de cesta: familia, ciclo hasta la primera cosecha, semanas de cosecha, marco, si se reparte por piezas |
| `rotacion.csv` | Familias botánicas y años mínimos antes de volver al mismo bancal |
| `insumos_ecologicos.csv` | Categorías de los anexos I (fitosanitarios) y II (fertilizantes) del Reglamento de Ejecución (UE) 2021/1165 |
| `plagas_huerta.csv` | Plagas, enfermedades y carencias por familia, con síntomas y seguimiento |
| `guia_cultivos.csv` | Guía del huerto: una ficha por cultivo (calendario, siembra, riego, cosecha, asociaciones, plagas, curiosidad) |
| `guia_fauna.csv` | Guía: fauna auxiliar (qué hace, cómo reconocerla, cómo atraerla, plagas que controla) |
| `guia_plantas.csv` | Guía: flores para auxiliares, abonos verdes, coberturas y reservorios |
| `guia_tecnicas.csv` | Guía: técnicas y trucos (compost, semillero, riego, rotación…) |

Otras convenciones: ids en minúsculas sin tildes con `_`; listas internas
separadas por `|`; `familia_id` y `familias` usan los ids de `rotacion.csv`.
Nada de marcas comerciales, tratamientos ni dosis. Estado de la revisión:
`revision-2026-11-07.md`.

**Guía del huerto** (2026-11-10): contenido divulgativo solo en castellano (eu/ca/gl
pendientes), con columna `fuente` en cada fila y `revisado_por = revision-ia:` (no es firma).
Nada de productos, dosis ni propiedades de salud: lo vigila `test/dominio/guia_test.dart`.
Revisión y fuentes: `revision-2026-11-10-guia.md`.
