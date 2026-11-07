# Larrea Aromáticas — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/aromaticas.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | 10 modelos (titular-explotación, parcela, zona de recolección con permiso, cosecha de parcela **o** zona, secado, destilación, lote de producto, tratamiento, apunte económico, configuración fiscal), 10 tablas en la v1 (`sentenciasEsquemaAromaticasV1`). Dominio puro: `rendimientos.dart` (secado %, aceite % v/p, hidrolato l/kg, comparación con el orientativo, resumen ponderado por especie), `recoleccion.dart` (avisos frente al permiso: sin permiso, fuera de vigencia, especie no incluida, límite de kg, especie protegida; permisos por vencer) y `trazabilidad.dart` (lote → proceso → cosechas → parcela/zona, texto del QR). 26 tests |
| 3 Pantallas | pendiente | |
| 4-5 Documentos oficiales PDF | pendiente | sello PROVISIONAL |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 3 (pantallas).

## Encuadre

Productores pequeños de plantas aromáticas y medicinales (lavanda, lavandín,
romero, tomillo, salvia, orégano, manzanilla…) en **cultivo** o en
**recolección silvestre**, que secan, venden planta seca o **destilan aceite
esencial e hidrolato**. Muchos en zonas de montaña y despoblación, como
actividad complementaria. Ficha completa: `docs/plan-verticales/aromaticas.md`.

**Diferencial**: la cadena entera con sus rendimientos — parcela o zona de
recolección (con su permiso y vigencia) → cosecha (kg frescos, floración) →
secado (kg frescos → kg secos) o destilación (kg de planta → ml de aceite
esencial + l de hidrolato, con la estructura de `Molturacion` de aceitera) →
lote con trazabilidad hacia atrás y pasaporte QR.

### Hard limits (innegociables)

- **Ninguna propiedad medicinal ni terapéutica** en ningún texto, etiqueta,
  pasaporte, catálogo, ayuda ni prompt de la IA. Los catálogos describen
  botánica, parte recolectada, época y rendimiento; nada de usos de salud.
  Hay un test (`test/hard_limits_test.dart`) que busca vocabulario
  terapéutico en el CSV de traducciones, en `content/aromaticas/` y en `lib/`.
- **La identificación de especies por IA nunca habilita el consumo**: es una
  propuesta para comprobar con clave botánica o persona experta, y el aviso
  se muestra siempre junto al resultado.
- **No se anima a recolectar especies protegidas**: el catálogo marca las que
  tienen alguna figura de protección o recolección regulada y la app avisa al
  apuntar una cosecha silvestre de esa especie.
- El destino «medicamento» **no existe** en la app: un medicamento a base de
  plantas exige autorización de la AEMPS, fuera de una app de explotación.
- La app no afirma que se «cumple» ninguna norma. Todos los PDF llevan sello
  PROVISIONAL.

### Normativa (resuelta en el bloque 1, 2026-11-07)

**Recolección silvestre.**
- **Ley 42/2007, del Patrimonio Natural y de la Biodiversidad** (consolidado
  BOE, https://www.boe.es/buscar/act.php?id=BOE-A-2007-21490, leído el
  2026-11-07): art. 56 crea el *Listado de Especies Silvestres en Régimen de
  Protección Especial*; **art. 57.1.a** prohíbe, para plantas del Listado,
  «recogerlas, cortarlas, mutilarlas, arrancarlas o destruirlas
  intencionadamente en la naturaleza»; art. 58 es el *Catálogo Español de
  Especies Amenazadas*; **art. 61** permite excepciones «previa autorización
  administrativa» (61.1.f: «explotación prudente de determinadas especies no
  incluidas en el Listado»); art. 80.1.m tipifica como infracción «el arranque
  y corta de especies de flora en aquellos supuestos en que sea necesaria
  autorización administrativa». La autorización la da **la comunidad
  autónoma**: la app guarda el permiso tal como lo da el órgano autonómico
  (número, órgano, vigencia, especies y límite) y no decide si hace falta.
- **Ley 43/2003, de Montes** (consolidado BOE,
  https://www.boe.es/buscar/act.php?id=BOE-A-2003-21339, actualizado el
  09/11/2024, **vigente**): el art. 6 incluye las «plantas aromáticas y
  medicinales» entre los aprovechamientos forestales. Que en monte público
  haga falta licencia o adjudicación (art. 36) y cómo lo regula cada
  comunidad: **por verificar**.
- **La «ley de 2003» que cita la memoria SUDOE** (pfcyl.es, p. 10) es la
  **Ley 8/2003, de 28 de octubre, de la flora y la fauna silvestres de
  Andalucía** (art. 31: el aprovechamiento de especies silvestres requiere
  autorización de la Consejería; la recogida esporádica en pequeñas cantidades
  no). El encargo decía que parecía derogada, pero el **BOE la da como vigente**
  (consolidado BOE-A-2003-21941, última actualización 20/03/2026,
  https://www.boe.es/buscar/act.php?id=BOE-A-2003-21941), solo con
  derogaciones parciales (art. 47.3 y art. 64). Por el encargo **no se usa**
  en ningún PDF ni texto de la app; queda anotada en BLOQUEOS para que el
  técnico de medio natural confirme. Es solo de Andalucía.
- **Normativa de cada comunidad autónoma** (catálogos regionales de flora
  amenazada, especies de recolección regulada, autorizaciones en montes):
  **por verificar** comunidad a comunidad. La app guarda la comunidad de la
  zona y el permiso, sin reglas por comunidad.

**Destino del producto** (campo `destino` por lote; todo **por verificar** y
con sello PROVISIONAL).
- **Planta seca para infusión**: RD 3176/1983, reglamentación
  técnico-sanitaria de especies vegetales para infusiones de uso en
  alimentación (consolidado BOE, https://www.boe.es/eli/es/rd/1983/11/16/3176/con,
  última modificación localizada 29/03/2013): **por verificar** vigencia y
  lista de especies. Especias y condimentos: RD 2242/1984, **por verificar**.
- **Plantas de venta restringida**: Orden SCO/190/2004 (BOE 06/02/2004,
  https://www.boe.es/boe/dias/2004/02/06/pdfs/A05061-05065.pdf) prohíbe la
  venta al público de las plantas de su anexo por toxicidad. Cruce con el
  catálogo de especies: **por verificar** (no se ha leído el anexo entero).
- **Aceite esencial como químico**: REACH (Reglamento (CE) 1907/2006) obliga
  a registrar una sustancia a partir de 1 t/año por fabricante (art. 6), y la
  clasificación y el etiquetado CLP (Reglamento (CE) 1272/2008) se aplican a
  lo que se comercializa como sustancia. La revisión del CLP (Reglamento (UE)
  2024/2865) mantiene una excepción para las sustancias de más de un componente
  extraídas de plantas no modificadas químicamente (ficha del MITECO
  «Modificaciones CLP parte 2, aplicables en 2026»,
  https://www.miteco.gob.es/content/dam/miteco/es/calidad-y-evaluacion-ambiental/documentos-portal-reach/Modificaciones%20CLP_Parte%202_aplicables%20en%202026.pdf);
  las fechas las cambió el Reglamento (UE) 2025/2439. **Por verificar**: si
  el pequeño destilador es «fabricante», qué umbral le aplica y qué etiqueta
  CLP lleva su aceite. La app **no genera etiquetas CLP**.
- **Aceite esencial o hidrolato para cosmética**: Reglamento (CE) 1223/2009
  aplica al producto cosmético acabado; el productor que vende materia prima a
  un fabricante cae en REACH/CLP. **Por verificar**.
- **Aceite esencial como aromatizante alimentario**: Reglamento (CE)
  1334/2008. **Por verificar**.
- **Medicamento a base de plantas**: fuera de la app (hard limit). Frontera
  alimento/medicamento: https://www.consumer.es/?p=17937 (divulgativa).

**Cultivo**: RD 1311/2012 y cuaderno de explotación (como frutal: registro
electrónico desde el 1-1-2027, RD 1039/2025). Fiscalidad en el bloque 9.

## Decisiones tomadas sin consultar

- **2026-11-07 — La Ley 8/2003 de Andalucía no se usa** aunque el BOE la da
  vigente: lo pide el encargo; se apunta la discrepancia en BLOQUEOS en vez
  de decidir (opción conservadora: menos afirmaciones legales).
- **2026-11-07 — Sin destino «medicamento»**: el destino de un lote es «sin
  decidir», «alimentario», «cosmético (materia prima)» u «otros usos
  (químico)». El medicamento a base de plantas exige la AEMPS.
- **2026-11-07 — `Titular` hace de `Explotacion`** (como el resto de la
  suite): una instalación = una explotación. Añade comunidad autónoma y
  registro sanitario (opcional, la app no dice si hace falta).
- **2026-11-07 — Una cosecha viene de una parcela o de una zona, nunca de las
  dos** (assert en el modelo y CHECK en la BD): así el cuaderno de
  recolección por permiso y el de cultivo no se mezclan.
- **2026-11-07 — Secado y destilación como la molturación de aceitera**:
  lista de cosechas usadas en JSON y FK al lote o lotes que salen (la
  destilación genera dos: aceite y hidrolato). Borrar un lote deja el proceso
  sin lote (SET NULL); una parcela o zona con cosechas no se borra (RESTRICT).
- **2026-11-07 — Rendimiento del aceite en % v/p** (ml por 100 g de planta),
  la unidad habitual de las fichas técnicas; ponderado por kg en los
  resúmenes. Planta fresca y seca no se mezclan en el resumen.
- **2026-11-07 — Límite del permiso en kg frescos totales de la vigencia**
  (todas las especies juntas): es el caso sencillo; si un permiso fija
  límites por especie, se apunta en notas. La app avisa, no bloquea.
- **2026-11-07 — Unidades de lote fijas por tipo**: planta en kg, aceite en
  ml, hidrolato en l.

## Datos técnicos

- Paquete `solera_aromaticas`, BD `solera_aromaticas.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/aromaticas.csv` (claves `arom.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/aromaticas/` → `dart run tool/compilar_catalogos.dart`.
