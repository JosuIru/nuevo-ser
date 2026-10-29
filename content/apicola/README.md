# Catálogos curados de Larrea Apícola

> ⚠️ **DATOS PROVISIONALES SIN VALIDAR POR VETERINARIO APÍCOLA NI APICULTOR ASESOR.**
> Pre-rellenados a partir de bibliografía pública (textos sanitarios apícolas, manuales clásicos, boletines de organismos oficiales y de cooperativas) como punto de partida. **Antes de pasar a producción comercial deben ser validados por un veterinario apícola + un apicultor experimentado + descarga del Registro de Productos Zoosanitarios vigente del MAPA.**

## Qué hay aquí

| Fichero | Contenido | Filas | Validar con |
|---|---|---|---|
| `razas_abeja.csv` | Subespecies y líneas comerciales de *Apis mellifera* | ~7 | Apicultor experimentado |
| `sustancias_varroa.csv` | Sustancias activas autorizadas para varroosis | ~9 | Veterinario apícola + descarga MAPA |
| `plagas_apicolas.csv` | Patologías, parásitos, depredadores y abióticos | ~16 | Veterinario apícola |
| `calendario_apicola.csv` | Calendario por zona ibérica (norte / centro / sur) | ~36 | Apicultor asesor local |
| `tipos_colmena.csv` | Modelos de colmena habituales en la península | ~7 | Apicultor experimentado |

## Flujo de validación

1. **Asesor edita los CSV directamente** (Excel, LibreOffice, Google Sheets — exportar como CSV UTF-8).
2. Cada fila tiene `revisado_por` y `fecha_revision`. Cuando el asesor valida una fila, las rellena. Las filas sin revisar se cargan con un flag visible en la app.
3. **Regenerar los `.dart`**:
   ```bash
   cd apps/solera-apicola
   dart run tool/compilar_catalogos.dart
   ```
   Genera ficheros en `apps/solera-apicola/lib/datos/catalogos_generados/`.
4. **Verificar**: `cd apps/solera-apicola && flutter analyze && flutter test`.
5. Commit del CSV + el `.dart` regenerado en el mismo commit (atómico).

## Convenciones del CSV

- **Comentarios**: las líneas que empiezan por `#` son ignoradas por el compilador. Útiles para anotar fuentes o avisos.
- **Codificación**: UTF-8 sin BOM (Excel suele añadir BOM, el compilador lo tolera).
- **Delimitador**: coma (`,`) preferente; el compilador también acepta punto y coma (`;`) auto-detectado por la primera línea.
- **Listas dentro de celda**: separadas por `|`, p. ej. `mansa|productiva|baja enjambrazón`.
- **IDs**: snake_case sin tildes ni espacios. Una vez en producción no se cambian (rompería la BD del usuario).

## Avisos legales y diegéticos

- **Sustancias para varroa**: el catálogo lista **sustancias activas**, no marcas comerciales (compromiso legal de la app — ver `CLAUDE.md` § Hard limits). La lista oficial cambia con cada actualización del MAPA y normativa europea. **No fiarse del snapshot embebido**: para v0.1 viene marcado como provisional; para producción comercial se debe descargar el Registro de Productos Zoosanitarios del MAPA antes de cada release.
- **Loque americana y escarabajo de las colmenas** son **enfermedades de declaración obligatoria** en la UE — la app debe destacar visualmente la columna `declaracion_oficial` cuando se diagnostique.
- **Plazos de seguridad y dosis**: los del CSV son **orientativos**. Validar siempre contra la etiqueta del producto comercial y la BBDD del MAPA.
- **Calendario apícola**: las décadas son orientativas para una zona climática amplia. La variabilidad real entre comarcas dentro de la misma zona puede ser de ±2 décadas. La app debe permitir override por apiario (pendiente F2).

## Fuentes consultadas para los datos provisionales

- Bibliografía clásica de patología apícola (manuales de apicultura ibérica).
- Boletines OIE/WOAH y MAPA sobre sanidad apícola.
- Programa Nacional de Lucha contra la Vespa velutina (MITECO).
- Registro de Productos Zoosanitarios del MAPA (snapshot pre-validación).
- Manuales clásicos de apicultura: Hidalgo, Polo, Espina y Ordetx.

Si encuentras un error, edítalo directamente en el CSV correspondiente y regenera. Los datos provisionales son **borrador** — están aquí precisamente para que sean fáciles de corregir.
