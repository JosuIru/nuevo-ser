# Catálogos curados de Larrea Arbolado Urbano

> ⚠️ **DATOS PROVISIONALES SIN VALIDAR POR INGENIERO TÉCNICO FORESTAL.**
> Pre-rellenados a partir de bibliografía pública (manuales de jardinería urbana, pliegos técnicos de ayuntamientos, boletines fitosanitarios autonómicos) como punto de partida. **Antes de pasar a producción comercial deben ser validados por un ingeniero técnico forestal o de jardinería con experiencia urbana + descarga del Registro de Productos Fitosanitarios vigente del MAPA.**

## Qué hay aquí

| Fichero | Contenido | Filas | Validar con |
|---|---|---|---|
| `especies_arboreas.csv` | Especies arbóreas frecuentes en arbolado urbano peninsular | ~40 | Ingeniero técnico forestal |
| `plagas_urbanas.csv` | Plagas, enfermedades y trastornos abióticos urbanos | ~19 | Ingeniero técnico forestal |
| `tipos_poda.csv` | Tipos de poda urbana | ~12 | Ingeniero técnico forestal + revisión de pliegos |
| `sustratos_alcorque.csv` | Tipos de alcorque y sustrato de plantación | ~7 | Ingeniero técnico forestal |
| `tareas_calendario.csv` | Calendario por zona ibérica (norte / centro / sur) | ~22 | Ingeniero técnico forestal local |

## Flujo de validación

1. **Asesor edita los CSV directamente** (Excel, LibreOffice, Google Sheets — exportar como CSV UTF-8).
2. Cada fila tiene `revisado_por` y `fecha_revision`. Cuando el asesor valida una fila, las rellena. Las filas sin revisar se cargan con un flag visible en la app.
3. **Regenerar los `.dart`**:
   ```bash
   cd apps/solera-arbolado-urbano
   dart run tool/compilar_catalogos.dart
   ```
   Genera ficheros en `apps/solera-arbolado-urbano/lib/datos/catalogos_generados/`.
4. **Verificar**: `cd apps/solera-arbolado-urbano && flutter analyze && flutter test`.
5. Commit del CSV + el `.dart` regenerado en el mismo commit (atómico).

## Convenciones del CSV

- **Comentarios**: las líneas que empiezan por `#` son ignoradas por el compilador. Útiles para anotar fuentes o avisos.
- **Codificación**: UTF-8 sin BOM (Excel suele añadir BOM, el compilador lo tolera).
- **Delimitador**: coma (`,`) preferente; el compilador también acepta punto y coma (`;`) auto-detectado por la primera línea.
- **Listas dentro de celda**: separadas por `|`, p. ej. `pino_pinonero|pino_carrasco`.
- **IDs**: snake_case sin tildes ni espacios. Una vez en producción no se cambian (rompería la BD del ayuntamiento).

## Avisos legales y diegéticos

- **Tratamientos fitosanitarios**: el catálogo **no lista productos comerciales**, sino tipos de plagas y manejo cultural. La aplicación de fitosanitarios concretos requiere carnet de aplicador y se registra en el `Tratamiento` del modelo de datos.
- **Plagas de declaración obligatoria** (picudo rojo, fuego bacteriano): la app destaca visualmente la columna `declaracion_oficial` y obliga a notificación a Servicios Fitosanitarios autonómicos. La regulación cambia — verificar la lista vigente del MAPA antes de cada release.
- **Riesgo sanitario público** (procesionaria del pino, lagarta peluda): en zonas escolares o paseos peatonales la vigilancia y actuación deben adelantarse. La app marca estas plagas con un flag específico para que el técnico pueda priorizar.
- **Riesgo VTA** *(Visual Tree Assessment)*: la app facilita el registro pero **NO emite dictámenes**. La decisión de tala o poda drástica es siempre humana y firmada por técnico cualificado.

## Fuentes consultadas para los datos provisionales

- Inventarios públicos de arbolado urbano: Madrid, Barcelona, Vitoria-Gasteiz, Iruña, Pamplona, Zaragoza, Sevilla.
- Registro Oficial de Productos Fitosanitarios (MAPA) — consulta vigente.
- Boletines de Avisos Fitosanitarios de servicios autonómicos.
- Programa Nacional de control del picudo rojo (MITECO).
- Bibliografía clásica: *Jardinería urbana* (Falcón Cantón), *Patología forestal* (Romanyk y Cadahía), pliegos técnicos de mantenimiento de arbolado de los ayuntamientos arriba citados.

Si encuentras un error, edítalo directamente en el CSV correspondiente y regenera. Los datos provisionales son **borrador** — están aquí precisamente para que sean fáciles de corregir.
