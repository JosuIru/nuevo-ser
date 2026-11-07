# Larrea Obrador — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/obrador.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | 9 modelos, 11 tablas en la v1, `ComposicionReceta`; 16 tests |
| 3 Pantallas | ✅ 2026-11-07 (parte A) | Hoy, Recetas (lista, ficha con composición, editor de líneas), Ingredientes (alérgenos y trazas), Autocontrol (mes + alta en hoja), Ajustes (NIF y registro sanitario). 2 tests de pantalla. **Falta (parte B)**: masa madre, pedidos fijos, hornadas con los lotes usados, lotes de ingrediente |
| 4-5 Documentos oficiales PDF | pendiente | sello PROVISIONAL |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 3 parte B (masa madre, pedidos fijos, hornadas y lotes de ingrediente; Hoy ya muestra masa madre y pedidos si existen). Después, bloques 4-5 (cuaderno de autocontrol mensual y ficha técnica en PDF).

## Encuadre

Panaderías artesanas, obradores caseros, repostería y conservas. Diferencial,
normativa con fuentes y hard limits: **`docs/plan-verticales/obrador.md`** (es la
referencia; no se duplica aquí). Lo esencial que no se toca: la app **no declara
un producto apto** para alérgicos ni celíacos, y la sal y los nutrientes son
**estimaciones**.

## Decisiones tomadas sin consultar

- **2026-11-07 — Un solo registro de autocontrol** (`registros_autocontrol` con
  `tipo`) en vez de las cinco tablas `control_*` de la quesera: el cuaderno
  mensual sale de una consulta y añadir un tipo no exige migración.
- **2026-11-07 — La v1 se amplió en el bloque 2** en lugar de añadir una v2: no
  había ninguna instalación (nada publicado).
- **2026-11-07 — Subrecetas** desplegadas en proporción a los gramos usados
  (`ComposicionReceta`); una receta que se contiene a sí misma es un error.
- **2026-11-07 — Integridad**: no se puede borrar un ingrediente ni un lote en
  uso (`ON DELETE RESTRICT`); borrar una receta se lleva sus líneas.
- **2026-11-07 — Importes en céntimos** (como aceitera), no en REAL como la quesera.

## Datos técnicos

- Paquete `solera_obrador`, BD `solera_obrador.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/obrador.csv` (claves `obra.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Recarga entre pestañas: `estado/cambios_datos.dart` (`avisarCambioDatos()` tras guardar).
- **Ojo**: `setState(() => _futuro = cargar())` devuelve el Future y Flutter lo rechaza; usar cuerpo con llaves. Lo cazó el test de pantalla.
- Lógica pura en `lib/dominio/` (sin Flutter, con tests).
- Catálogos: `content/obrador/` → `dart run tool/compilar_catalogos.dart`.
