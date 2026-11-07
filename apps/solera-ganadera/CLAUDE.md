# Larrea Ganadera — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/ganadera.md`) y `docs/plan-verticales-larrea.md`.

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

Ganadería extensiva pequeña y mixta (20-400 cabezas de ovino, caprino, vacuno
de carne o porcino extensivo, a menudo varias especies a la vez y con pastos
repartidos en muchas piezas propias, arrendadas o comunales). Explotación
familiar, incorporación reciente y ecológico o en conversión. **Fuera**:
intensivo, leche con robot e integradoras.

Referencias (no se duplican aquí):
- Ficha de encargo: **`docs/plan-verticales/ganadera.md`** (regla Z).
- Propuesta completa con normativa enlazada, bloques F1G-3…10 y hard limits:
  **`docs/propuestas/larrea-ganadera.md`**. F1G-2 (extraer el dominio al core)
  **no se hace**: lo sustituye la regla Z.

Diferencial: **el pasto como centro** (dónde está cada rebaño, UGM/ha por pieza
y días de pastoreo) y el **informe del eco-régimen de pastoreo extensivo** con
los movimientos reales; multiespecie y ecológico de serie; es/eu/ca/gl y offline.

Normativa que digitaliza (todo PROVISIONAL, a validar por veterinario asesor):
- RD 787/2023, libro de registro de explotación y documento de movimiento:
  https://www.boe.es/eli/es/rd/2023/10/17/787/con
- RD 479/2004, REGA: https://www.boe.es/eli/es/rd/2004/03/26/479/con
- RD 666/2023, art. 41, registro de tratamientos (se apunta la receta):
  https://www.boe.es/eli/es/rd/2023/07/18/666/con
- Reglamento (UE) 2018/848, ecológico (supresión doble, mínimo 48 h):
  https://eur-lex.europa.eu/eli/reg/2018/848/oj
- Eco-régimen de pastoreo extensivo de la PAC (PEPAC): cargas mínimas por
  verificar en el BOE de la campaña.

Hard limits (propuesta §5): la app **no recomienda medicamentos, dosis ni
diagnósticos** (apunta la receta y avisa de plazos; catálogos con sustancias
activas, nunca marcas); **no sustituye SITRAN, la OCA ni PRESVET** (lo dice en
pantalla y en el PDF); el informe del eco-régimen es **una ayuda, no una
declaración**, y manda la tabla UGM del trámite; exportación completa de los
datos siempre disponible.

## Regla Z (Zunbeltz)

`apps/solera-zunbeltz/` está en producción: **solo se lee y se copia**, nunca se
modifica ni se compila. El dominio de ganado se copió del commit de Zunbeltz
**`92ade2b`** (`git log -1 --format=%h -- apps/solera-zunbeltz`, 2026-11-07),
quitando sincronización y permisos (`uid`, `actualizado_ms`, `PoliticaEspacio`).
Para comparar: `git diff 92ade2b -- apps/solera-zunbeltz/lib/modelos/`.

## Decisiones tomadas sin consultar

(Cada una con fecha y porqué.)

## Datos técnicos

- Paquete `solera_ganadera`, BD `solera_ganadera.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/ganadera.csv` (claves `gana.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/ganadera/` → `dart run tool/compilar_catalogos.dart`.
