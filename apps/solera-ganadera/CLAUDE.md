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
| 4-5 Documentos oficiales PDF | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Documentos: **libro de registro** por año (apartados 1-11 del anexo V del RD 787/2023 + tratamientos del art. 41 RD 666/2023) e **informe del eco-régimen de pastoreo** por campaña y tabla UGM (art. 30.2 RD 1048/2022). Desde la ficha del rebaño, el **documento de movimiento** de cada entrada o salida (anexo del RD 728/2007 según la DF 3.ª del RD 787/2023). Tablas puras con test, sello y marca de agua PROVISIONAL. 67 tests |
| 6 Catálogos | ✅ 2026-11-07 | `content/ganadera/`: tabla UGM por trámite, parámetros del eco-régimen, especies, razas (RD 45/2019 anexo I) y 24 sustancias activas **sin marcas, dosis ni tiempos de espera**, contrastadas con la API de CIMA Vet. Autocompletado de raza y sustancia; la clase de medicamento sale del catálogo si no se indica. Tests de integridad (cobertura de la tabla UGM, sin firmas falsas). 76 tests |
| 7 IA visual | ✅ 2026-11-07 | Ficha del rebaño → «Leer receta con IA»: foto de la **receta veterinaria** → transcripción estructurada (medicamento, sustancias, cantidad, duración, esperas, veterinario, n.º, fecha) → la persona la compara → el formulario del tratamiento se abre relleno. La sustancia se casa con el catálogo. Un plazo que no se lee queda vacío (−1 en el esquema). Modelo equilibrado del core, clave BYO (`estado/clave_anthropic_ganadera.dart`), la foto se borra. 80 tests |
| 8 Branding + GPS | ✅ 2026-11-07 (placeholder) | Logo ImageMagick (crotal rojo `#B8402A` sobre pasto, pardo lana y crema) en `assets/`, iconos del lanzador con `flutter_launcher_icons`, logo en la cabecera de Hoy. **GPS**: contorno de cada pieza caminando el linde (superficie y perímetro por exceso esférico, `geodesia.dart` de Zunbeltz) y coordenadas de la explotación; mapa de pastos con `flutter_map` (los contornos se ven sin cobertura). Permisos de Internet y ubicación en el manifiesto. 93 tests |
| 9 Economía | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Ingresos y gastos: apuntes con fecha, categoría ganadera y, en ingresos, REAGP (compensación editable, 10,5 % por verificar) o IVA; resumen del mes (resultado, compensación cobrada, IVA repercutido y soportado) y extracto PDF con sello. **Exportación completa**: un CSV por tabla desde Ajustes (hard limit 4). 98 tests |
| 10 Revisión con fuente pública | ✅ en parte (2026-11-07) | Normativa de los PDF cotejada con el texto vigente (lista en Encuadre). Catálogos: tabla UGM de la PAC y eco-régimen con `fuente_publica` (BOE), razas con `fuente_publica` (salvo 4 añadidas y «Cruce»), sustancias con `revision-ia:` (CIMA Vet). Sin revisar a propósito: especies (lista propia), la tabla de Andalucía y la cerda de cría. `catalogosCompletamenteRevisados = false` y el banner se ve. `scripts/auditoria` no conoce todavía `ganadera` (fuera de esta calle) |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 11 (ayuda in-app, README, APK release y build Linux).

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

Normativa que digitaliza (todo PROVISIONAL, a validar por veterinario asesor).
Textos leídos en el BOE o EUR-Lex el **2026-11-07** (bloque 10):
- RD 787/2023 (BOE-A-2023-22499, consolidado 24/12/2024), art. 23 y **anexo V**
  (contenido mínimo del libro de registro, puntos 1-11), art. 20-22 y **DF 3.ª**
  (datos mínimos del documento de movimiento, que reescribe el anexo del
  RD 728/2007): https://www.boe.es/eli/es/rd/2023/10/17/787/con
- RD 479/2004 (BOE-A-2004-6426, consolidado 24/12/2024), art. 5: código REGA =
  ES + 2 cifras de provincia + 3 de municipio (INE) + 7 de explotación:
  https://www.boe.es/eli/es/rd/2004/03/26/479/con
- RD 666/2023 (BOE-A-2023-16727, consolidado 03/09/2025), **art. 41**: registro
  de tratamientos con lo del art. 108 del Reglamento (UE) 2019/6 y el n.º de
  receta; 5 años: https://www.boe.es/eli/es/rd/2023/07/18/666/con
- Reglamento (UE) 2019/6, **art. 108.2** (fecha de la primera administración,
  medicamento, cantidad, proveedor, prueba de compra, animales, veterinario,
  tiempo de espera aunque sea cero, duración):
  https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32019R0006
- Reglamento (UE) 2018/848, anexo II, parte II, **1.5.2.4 y 1.5.2.5** (límite de
  tratamientos y espera doble, mínimo 48 h):
  https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32018R0848
- RD 1048/2022 (BOE-A-2022-23048, consolidado 08/07/2026), **art. 30.2**
  (eco-régimen de pastoreo: 120 días, reducibles a 90; 0,4-2 UGM/ha en húmedos y
  0,2-1,2 en mediterráneos, mínimos reducibles a 0,2 y 0,1) y **anexo V** (tabla
  de UGM): https://www.boe.es/eli/es/rd/2022/12/27/1048/con
- RD 45/2019 (BOE-A-2019-2859, consolidado 21/06/2023), anexo I: razas.
- CIMA Vet (AEMPS), API REST pública: sustancias activas con medicamentos
  autorizados. https://cimavet.aemps.es/cimavet/rest/medicamentos?practiv1=…
- **Por verificar**: el porcentaje de compensación REAGP de ganadería (Ley
  37/1992 art. 130: no se pudo leer en el BOE en esta sesión) y las fechas de
  cómputo de la carga de cada comunidad.

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
- **2026-11-07 — Tres documentos en vez de dos**: libro y documento de
  movimiento (los oficiales) y el informe del eco-régimen (el diferencial, F1G-7)
  en el mismo bloque; los tres con sello y marca de agua PROVISIONAL.
- **2026-11-07 — Eco-régimen calculado día a día**: el rebaño está en la pieza de
  su último movimiento (el día del movimiento ya cuenta en el destino); sus UGM
  son las de hoy escaladas por las cabezas de su último movimiento con cabezas.
  Se dan media, mínima y máxima de los días con ganado y se avisa con los
  mínimos generales del art. 30.2 (120 días; 0,4/0,2 UGM/ha; máximos 2/1,2). Las
  reducciones (90 días; 0,2/0,1) dependen de cada comunidad: están en el
  catálogo pero no se aplican solas. Las fechas de cómputo de cada CA (en
  Extremadura y Castilla-La Mancha, cuatro fechas de censo, según sus guías) no
  se han verificado en el BOE.
- **2026-11-07 — El documento de movimiento sale para entradas, salidas, altas
  y bajas parciales** (los traslados internos no lo necesitan) y deja en blanco
  las conformidades para firmar.
- **2026-11-07 — Sustancias activas sin tiempos de espera**: el plazo de
  supresión lo pone siempre la receta (hard limit 1). Cada fila se contrastó con
  la API REST pública de CIMA Vet (AEMPS) el 2026-11-07 (`revision-ia:`, con el
  número de medicamentos autorizados en la primera página). Se quitaron las que no
  daban ninguno autorizado (oxfendazol, netobimina, praziquantel, diazinón).
- **2026-11-07 — Razas sin clasificación** (de fomento, amenazada…): la lectura
  del anexo I del RD 45/2019 salió de un resumen automático y la clasificación era
  dudosa. Merina, Manchega, Castellana y Murciano-Granadina se añadieron sin verlas
  en ese texto (sin `revisado_por`). «Cruce» por especie, sin fuente.
- **2026-11-07 — La IA del bloque 7 lee recetas, no animales**: la propuesta
  deja la IA visual de cojeras o condición corporal para F3. Transcribir la receta
  respeta el hard limit (la app apunta lo que dice el veterinario) y ahorra
  teclear el registro del art. 41. El modelo equilibrado y no el rápido: un error
  en un tiempo de espera tiene consecuencias en la cadena alimentaria.
- **2026-11-07 — Contorno con el GPS, no dibujado a dedo**: en el monte se camina
  el linde; dibujar sobre teselas exige cobertura. Si la pieza no tiene superficie,
  se guarda la calculada (orientativa: la oficial es la de SIGPAC).
- **2026-11-07 — Sin caché de teselas**: Zunbeltz la tiene (`cache_teselas.dart`),
  pero arrastra servicios de sincronización. Sin cobertura se ven los contornos
  sobre fondo vacío. Pendiente para F2.
- **2026-11-07 — Economía mínima, sin facturas del core**: un libro de apuntes
  como Obrador, con régimen por apunte (REAGP o IVA) porque la explotación mixta
  vende a cooperativa (REAGP) y en directo (puede facturar con IVA). Las facturas
  (`facturacion/` del core) esperan a que el asesor fije el régimen. La
  compensación del 10,5 % para ganadería no se ha podido leer en el BOE (art. 130
  de la Ley 37/1992): queda editable y marcada «por verificar».
- **2026-11-07 — Exportación en CSV, no Excel**: un CSV por tabla con la hoja de
  compartir; sin dependencias nuevas. Importar desde Zunbeltz queda para F2.
- **2026-11-07 — Fechas con selector** en movimientos, eventos, tareas y visitas
  (en Obrador se apuntaba con la fecha actual).

## Datos técnicos

- Paquete `solera_ganadera`, BD `solera_ganadera.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/ganadera.csv` (claves `gana.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/ganadera/` → `dart run tool/compilar_catalogos.dart`.
