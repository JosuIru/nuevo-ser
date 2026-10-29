# Catálogos curados — Larrea Quesera

CSVs editables por el asesor quesero. Compilados a Dart mediante `tool/compilar_catalogos.dart`.

## CSVs

| Archivo | Filas | Revisadas | Descripción |
|---|---|---|---|
| `tipos_queso.csv` | 25 | 0 | Fresco, semicurado, curado, viejo, azul, pasta blanda, etc. |
| `razas_lecheras.csv` | 20 | 0 | Latxa, Manchega, Murciano-Granadina, Frisona, Alpina, etc. |
| `do_quesos.csv` | 26 | 0 | Denominaciones de Origen Protegidas de queso en España |
| `defectos_queso.csv` | 30 | 0 | Catálogo de defectos para IA visual y registro de incidencias |
| `parametros_analitica.csv` | 20 | 0 | Parámetros microbiológicos y físico-químicos estándar |

## Flujo

1. Asesor edita CSV en Excel/Sheets, exporta CSV UTF-8.
2. `dart run tool/compilar_catalogos.dart` (regenera los 5 `.dart`).
3. `flutter analyze && flutter test`.
4. Commit del CSV + `.dart` regenerado en el mismo commit.

Estado actual: **PROVISIONAL** — banner visible hasta que `catalogosCompletamenteRevisados == true`.
