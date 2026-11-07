# Larrea Ganadera — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/ganadera.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | Dominio de ganado copiado de Zunbeltz (`92ade2b`) sin sync ni permisos; explotación, titular, piezas de pasto, visitas, calendario sanitario y apuntes. 10 tablas en la v1. Tabla UGM por trámite (PAC anexo V y Andalucía) como catálogo. 48 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas Hoy (dónde está cada rebaño con su carga, avisos de 14 días, primeros pasos), Rebaños (ficha con animales, movimientos y manejo; ficha del animal con su historia), Pastos (piezas con ocupación y UGM/ha), Manejo (calendario sanitario y visitas), Ajustes (titular y explotación). Lógica pura en `dominio/` (ocupación, calendario). 58 tests, 5 de pantalla |
| 4-5 Documentos oficiales PDF | pendiente | sello PROVISIONAL |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloques 4-5 (libro de registro, documento de movimiento e informe del eco-régimen en PDF).

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

- **2026-11-07 — Zonas → piezas de pasto**: en Zunbeltz el ganado se movía
  entre `zonas` de una finca; aquí la unidad es la `PiezaPasto` (recinto SIGPAC,
  tipo de pasto, titularidad, contorno). Columnas `pieza_origen_id`/`pieza_destino_id`.
- **2026-11-07 — Sin `titular_uid` ni `autor_uid`** (además de `uid` y
  `actualizado_ms`): son de la política de espacio de Zunbeltz; la F1 es de un
  solo dispositivo y de un solo titular.
- **2026-11-07 — Catálogos de códigos sin `OpcionCatalogo`**: los nombres
  visibles salen de las traducciones `gana.*` (cuatro idiomas), no de pares es/eu.
- **2026-11-07 — Altas y bajas parciales** (`alta_parcial`, `baja_parcial`):
  vender 10 corderos no saca al rebaño de su pieza. Solo traslado, entrada y
  salida cambian la ubicación.
- **2026-11-07 — Movimiento con los datos del documento de movimiento**
  (anexo de RD 728/2007 modificado por la DF 3.ª del RD 787/2023, leído en el
  BOE el 2026-11-07) y tratamiento con los del art. 108.2 del Reglamento (UE)
  2019/6 (al que remite el art. 41 del RD 666/2023): medicamento, proveedor,
  prueba de compra, duración, tiempo de espera aunque sea 0.
- **2026-11-07 — Tabla UGM por trámite como catálogo** (`content/ganadera/tabla_ugm.csv`):
  la de la PAC del anexo V del RD 1048/2022 (leída en el BOE) y la de Andalucía
  de Zunbeltz (sin revisar). En la PAC la hembra vacuna adulta cuenta 0,8
  («otras vacas»; la de leche sería 1,0) y la cerda adulta 0,5 (aproximación a
  «cerdas de cría >50 kg»). Las cabezas sin crotal cuentan como hembras adultas.
- **2026-11-07 — Integridad**: un rebaño o una pieza con movimientos no se borra
  (`ON DELETE RESTRICT`): se cierra o se desactiva. El libro debe conservarse 3
  años (RD 787/2023 art. 23.2) y el registro de tratamientos 5 (RD 666/2023 art. 41.4).
- **2026-11-07 — La v1 se amplió en el bloque 2** (nada publicado todavía).
- **2026-11-07 — Pantallas propias, no las de Zunbeltz**: `formularios_ganado.dart`
  y `ficha_lote.dart` de Zunbeltz (2.300 líneas) dependen de `PoliticaEspacio`,
  la sincronización y el sistema de idioma de Zunbeltz; se rehicieron con la forma
  de Obrador (`hoja_formulario`, `cambios_datos`, `SoleraL10n`).
- **2026-11-07 — Sin escáner del DIB en la F1**: necesitaría `mobile_scanner`
  (más peso y permisos de cámara). El crotal escrito se limpia con
  `interpretarCodigoCrotal` (de Zunbeltz). Pendiente para F2 junto al RFID.
- **2026-11-07 — Las pantallas cuentan la carga con la tabla de la PAC**
  (`tablaUgmPantallas`): es la que interesa para el eco-régimen; el informe deja
  elegir trámite.
- **2026-11-07 — Fechas con selector** en movimientos, eventos, tareas y visitas
  (en Obrador se apuntaba con la fecha actual).

## Datos técnicos

- Paquete `solera_ganadera`, BD `solera_ganadera.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/ganadera.csv` (claves `gana.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/ganadera/` → `dart run tool/compilar_catalogos.dart`.
