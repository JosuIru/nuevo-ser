# Larrea Obrador — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/obrador.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | 9 modelos, 11 tablas en la v1, `ComposicionReceta`; 16 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas: Hoy, Recetas, Ingredientes (con lotes recibidos), Autocontrol, Ajustes. Desde la cabecera de Hoy: Hornadas (propone las piezas pedidas y el código de lote; marca los lotes usados de los ingredientes directos), Pedidos fijos y Masa madre. 19 tests, 3 de pantalla |
| 4-5 Documentos oficiales PDF | pendiente | sello PROVISIONAL |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloques 4-5. (4) Cuaderno de autocontrol mensual en PDF con `informe_periodico` del core y sello PROVISIONAL, con la guía vasca como referencia de columnas. (5) Ficha técnica (ingredientes por peso, alérgenos en negrita, sal estimada) + cartel de alérgenos del mostrador. Ver aceitera `servicios/generador_cuaderno_pac_pdf.dart` como modelo.

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
- **2026-11-07 — Lotes en la hornada**: solo se ofrecen los de los ingredientes *directos* de la receta; los de una base se apuntan al hacer la base (pendiente: hornada de subreceta).
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
