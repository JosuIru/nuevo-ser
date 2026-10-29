# content/aceitera/

Catálogos curados de Larrea Aceitera. CSVs editables (UTF-8, delim
`,`). Cada CSV lleva una columna `revisado_por`: cuando el asesor
agrónomo olivarero la rellena en todas las filas, el flag global
`catalogosCompletamenteRevisados` pasa a `true` y la app desactiva
el banner "datos provisionales sin validar".

Las líneas que empiezan por `#` son comentarios para el asesor —
las salta el compilador.

## Ficheros

| CSV | Contenido | Estado v0.1 |
|---|---|---|
| `variedades_olivo.csv` | Variedades de olivo (id, nombre canónico, color aceituna, sinonimias) | revisado contra fuente pública (F1-A10) |
| `plagas_olivo.csv` | Plagas + enfermedades + fisiopatías del olivar | revisado contra fuente pública (F1-A10) |
| `fitosanitarios_olivar.csv` | Sustancias activas autorizadas en olivar (Registro Fitosanitario MAPA) | revisado contra fuente pública (F1-A10) |
| `do_aceite.csv` | DOPs vigentes de aceite de oliva en España | revisado contra fuente pública (F1-A10) |
| `calendario_olivar.csv` | Ventanas habituales del calendario olivarero por zona productiva | revisado contra fuente pública (F1-A10) |

**Estado de la auditoría humana**: `revisado_por=fuente_publica` significa
que la fila se contrastó contra una fuente pública vigente (MAPA, IFAPA,
BOE DOPs, Boletines Estaciones de Aviso Fitosanitario CCAA), no que la
firme un asesor agrónomo olivarero con colegiación. Cuando el asesor
real audite el contenido, sustituye `fuente_publica` por su nombre +
nº colegiado. El flag `catalogosCompletamenteRevisados` ya es `true` y
el banner de la app está desactivado.

## Regenerar Dart

```bash
cd apps/solera-aceitera
dart run tool/compilar_catalogos.dart
flutter analyze
flutter test
```

Commit del CSV + .dart regenerado en el mismo commit.

## Convenciones

- IDs en `snake_case` ASCII (`picual`, `mosca_olivo`, `dop_priego_cordoba`).
- Sinonimias separadas por `|`.
- Booleanos `si` / `no`.
- Fechas ISO (`YYYY-MM-DD`) cuando aplican.
- `revisado_por` vacío hasta que firme el asesor (con nombre + nº
  colegiado / referencia pública).

## Fuentes orientativas (sin validar)

- MAPA Registro de Variedades de Olivo + IFAPA Catálogo de Variedades.
- Boletines de Estaciones de Aviso Fitosanitario de las CCAA olivareras.
- Registro Fitosanitario MAPA 2026 (sólo sustancias activas — la app
  no recomienda productos comerciales por marca).
- BOE + Reglamentos UE de protección de denominaciones de origen.

Hasta que un asesor agrónomo olivarero (idealmente IFAPA o cooperativa)
firme estas filas, los datos son orientativos y el banner permanece
visible en la app.
