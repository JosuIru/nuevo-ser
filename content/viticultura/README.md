# Catálogos curados de Larrea Viticultura

> ⚠️ **DATOS PROVISIONALES SIN VALIDAR AGRONÓMICA/ENOLÓGICAMENTE.**
> Pre-rellenados a partir de fuentes públicas (MAPA, OIVE, FAO BBCH, manuales de viticultura) como punto de partida. **Antes de pasar a producción comercial deben ser validados por un enólogo + un agrónomo + descarga del Registro Oficial vigente del MAPA.**

## Qué hay aquí

| Fichero | Contenido | Filas | Validar con |
|---|---|---|---|
| `variedades.csv` | Variedades viníferas con sinonimias | ~40 | Enólogo |
| `portainjertos.csv` | Portainjertos con adaptación al suelo | ~10 | Enólogo |
| `plagas_vid.csv` | Plagas, enfermedades y trastornos abióticos | ~19 | Agrónomo |
| `materias_activas.csv` | Materias activas autorizadas para vid | ~17 | Agrónomo + descarga MAPA |
| `calendario_bbch.csv` | Calendario fenológico por variedad y zona | ~72 | Enólogo + estaciones de avisos CCAA |

## Flujo de validación

1. **Asesor edita los CSV directamente** (Excel, LibreOffice, Google Sheets — exportar como CSV UTF-8).
2. Cada fila tiene una columna `revisado_por` y `fecha_revision`. Cuando el asesor valida una fila, las rellena. Las filas sin revisar se cargan con un flag visible en la app.
3. **Regenerar los `.dart`**: desde la raíz del monorepo:
   ```bash
   dart run scripts/viticultura/compilar_catalogos.dart
   ```
   Esto genera los ficheros en `apps/solera-viticultura/lib/datos/catalogos_generados/`.
4. **Verificar**: `cd apps/solera-viticultura && flutter analyze && flutter test`.
5. Commit del CSV + el `.dart` regenerado en el mismo commit (atómico).

## Convenciones del CSV

- **Comentarios**: las líneas que empiezan por `#` son ignoradas por el compilador. Útiles para anotar fuentes o avisos.
- **Codificación**: UTF-8 sin BOM (Excel suele añadir BOM, el compilador lo tolera).
- **Delimitador**: coma (`,`) preferente; el compilador también acepta punto y coma (`;`) auto-detectado por la primera línea.
- **Sinonimias / listas**: separadas por `|` dentro de la celda, p. ej. `cencibel|tinto fino|tinta de toro`.
- **IDs**: snake_case sin tildes ni espacios. Una vez en producción no se cambian (rompería la BD del usuario).

## Avisos legales y diegéticos

- **Materias activas**: la lista oficial cambia cada pocos meses (retiradas, autorizaciones, ampliaciones). **No fiarse del snapshot embebido**: para v0.1 viene marcado como provisional; para producción comercial se debe descargar el Registro de Productos Fitosanitarios del MAPA antes de cada release.
- **Plazos de seguridad y dosis**: los del CSV son **orientativos**. Validar siempre contra la etiqueta del producto comercial y la BBDD MAPA.
- **Calendario BBCH**: las décadas son orientativas para una zona climática amplia. La variabilidad real entre parcelas dentro de la misma zona puede ser de ±2 décadas. La app debe permitir override por viñedo (pendiente F2).

## Fuentes consultadas para los datos provisionales

- [Registro de Variedades Comerciales del MAPA](https://www.mapa.gob.es/) — variedades autorizadas y sinonimias en España.
- [VIVC — Vitis International Variety Catalogue](https://www.vivc.de/) — sinonimias internacionales.
- FAO BBCH para vid (1995, edición canónica de la escala fenológica).
- Manuales clásicos de viticultura (Hidalgo, Reynier).
- Estaciones de Avisos Fitosanitarios de Castilla y León, Rioja, Galicia (calendario fenológico).

Si encuentras un error, edítalo directamente en el CSV correspondiente y regenera. Los datos provisionales son **borrador** — están aquí precisamente para que sean fáciles de corregir.
