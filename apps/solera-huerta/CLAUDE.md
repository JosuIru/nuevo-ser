# Larrea Huerta — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/huerta.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | pendiente | |
| 3 Pantallas | pendiente | |
| 4-5 Documentos oficiales PDF | pendiente | sello PROVISIONAL |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 2.

## Encuadre

Horticultura pequeña y diversificada (0,5-5 ha), casi siempre ecológica o en
conversión, que vende en **cestas a grupos de consumo**, en mercados y a
restaurantes; muchas personas llegan desde espacios test. Ficha completa:
**`docs/plan-verticales/huerta.md`** (es la referencia; no se duplica aquí).

**Diferencial**: une el **plan de bancales y rotaciones** (aviso si una familia
botánica vuelve al bancal antes de los años mínimos del catálogo) con las
**cestas por socio** (reparto de la cosecha de la semana entre suscripciones).
Las dos cosas, lógica pura con tests en `lib/dominio/` y `lib/provisional_core/`.

Normativa que digitaliza (texto vigente a verificar antes de cada PDF):
- Reglamento (UE) 2018/848 de producción ecológica:
  https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32018R0848
  (registro para el certificador: parcelas, rotaciones, insumos, semillas y
  cosechas). El formato del cuaderno de cada organismo de control autonómico
  (CPAEN, ENEEK…) va **por verificar**.
- RD 1311/2012, cuaderno de tratamientos:
  https://www.boe.es/buscar/act.php?id=BOE-A-2012-11605
- Venta directa: RD 1086/2020 y normativa autonómica de proximidad, **por verificar**.

Lo esencial que no se toca (hard limits):
- **La app no certifica nada como ecológico**: registra lo que pide el certificador.
- **Nada de fitosanitarios por marca ni de dosis** recomendadas.
- La rotación y el reparto de cestas son **orientativos**.

## Decisiones tomadas sin consultar

(Cada una con fecha y porqué.)

## Datos técnicos

- Paquete `solera_huerta`, BD `solera_huerta.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/huerta.csv` (claves `huer.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/huerta/` → `dart run tool/compilar_catalogos.dart`.
