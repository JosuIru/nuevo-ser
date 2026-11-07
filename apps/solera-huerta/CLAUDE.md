# Larrea Huerta — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/huerta.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh` |
| 2 Modelos + BD | ✅ 2026-11-07 | 14 modelos (titular-huerta, parcela, bancal, cultivo, lote de semilla, siembra/plantación, cosecha, insumo, tratamiento; y en `lib/provisional_core/venta_directa/` socio, suscripción, cesta, línea de cesta, entrega), 14 tablas en la v1. Lógica pura: `dominio/rotacion.dart` (aviso por familia y años mínimos, familias bloqueadas por bancal), `dominio/siembras_escalonadas.dart`, `dominio/prevision_cosecha.dart` (cosecha prevista y real de la semana) y `provisional_core/venta_directa/reparto_cestas.dart` (reparto por partes con mayor resto, pasos de 50 g o piezas, turno rotatorio en empates). 65 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas: Hoy (primeros pasos sin parcelas o cultivos, siembras planificadas de los próximos 14 días o atrasadas con aviso de rotación, cestas de la semana, plazos de seguridad abiertos, pendientes para el certificador: semilla no ecológica sin autorización e insumo sin justificante), Parcelas → ficha de parcela con bancales y lo que tienen → ficha de bancal (plan de rotación: familias bloqueadas y hasta cuándo, siembras con acciones hecha/cosechar/levantar, cosechas), Cuaderno del año (siembras, cosechas, aplicaciones de insumos; menú con cultivos, banco de semillas e insumos), Cestas (semana, cosecha real y prevista, **proponer reparto**, cesta editable, entrega) y socios con suscripciones, Ajustes (datos de la huerta, organismo de control, asesor). Altas en hojas inferiores (`formularios_huerta.dart`), siembra con serie escalonada y aviso de rotación en vivo. 75 tests, 7 de pantalla |
| 4-5 Documentos oficiales PDF | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Documentos: **cuaderno de campo para el certificador ecológico** (año en curso y anterior: parcelas con situación y conversión, rotación por bancal en 4 años, siembras y plantaciones con su lote y el aviso de rotación, semillas usadas con la autorización si es no ecológica, insumos aplicados con su categoría y el justificante de «permitido», tratamientos fitosanitarios con las columnas del RD 1311/2012, cosechas y totales por cultivo) y **hoja de cestas y reparto** (esta semana y la siguiente: preparar por cultivo con cosechado/en cestas/sobra, y cesta por socio con punto de entrega, contenido, notas y casilla de entrega). Tablas puras con test. Recordatorio de leguminosas en la ficha del bancal (Reglamento 2018/848, anexo II, parte I, 1.9.2). 82 tests |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 6 (catálogos: los CSV de `content/huerta/` y regenerar `lib/datos/catalogos_generados/`, que ahora son marcadores vacíos).

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

- **2026-11-07 — `Titular` hace de `Huerta`**: una instalación = una huerta
  (como el resto de la suite). Lleva la cabecera de los cuadernos: NIF,
  registro, comunidad autónoma, **organismo de control** y código de operador
  ecológico, y el asesor con su ROPO.
- **2026-11-07 — `Plantacion` es una `Siembra` de tipo `plantacion`**: comparten
  todos los campos (bancal, cultivo, fecha, lote, cantidad) y la rotación las
  trata igual; dos tablas duplicarían consultas y PDF.
- **2026-11-07 — Siembra planificada = sin fecha real**: el plan de bancales y
  las siembras escalonadas son siembras con fecha prevista; al hacerlas se
  apunta la real. Las series comparten `serie_escalonada`.
- **2026-11-07 — La familia botánica se guarda en el `Cultivo`** (no se deduce
  solo del catálogo): la rotación funciona aunque la especie sea texto libre.
- **2026-11-07 — La rotación mira hacia atrás y hacia delante**: una siembra
  planificada más adelante de la misma familia también avisa. Sin regla en el
  catálogo, no se avisa y se dice «sin dato» (nunca «bien»).
- **2026-11-07 — `Tratamiento` = aplicación de cualquier `Insumo`**
  (fitosanitario, abono o enmienda): el certificador pide el registro de todos
  los insumos y el cuaderno de tratamientos solo los fitosanitarios; el tipo
  lo da el insumo. Bancal opcional (toda la parcela si falta).
- **2026-11-07 — «Permitido en ecológico» lo marca la persona con justificante**
  (etiqueta, listado del organismo, certificado del proveedor): la app no lo
  decide; avisa si falta el justificante.
- **2026-11-07 — Cestas en `lib/provisional_core/venta_directa/`**: el módulo
  transversal T2 del plan no existe aún en el core. Modelos y reparto viven
  ahí sin depender de nada de la app (solo `semanas.dart`); las tablas, en la
  BD de la app. Cuando T2 suba al core, se sustituye esta carpeta por el
  import y se migran las tablas si el core define otras.
- **2026-11-07 — Reparto por «partes»** (pequeña 2, mediana 3, grande 4) y
  **mayor resto**: nunca se reparte más de lo que hay; lo que no cabe en el
  redondeo (pasos de 50 g o piezas enteras) queda como sobrante a la vista. En
  empates rota el turno con el número de semana para no castigar siempre a
  la misma cesta. Es una propuesta: se retoca a mano.
- **2026-11-07 — Una cesta por suscripción y semana** (UNIQUE), con la semana
  como su lunes; la quincenal va en semanas alternas desde la de inicio.
- **2026-11-07 — Integridad**: siembras, cosechas, tratamientos y cestas
  impiden borrar lo que citan (`RESTRICT`); bancales y socios se desactivan.
  Borrar una cesta se lleva sus líneas y entregas.
- **2026-11-07 — Onboarding = tarjeta «Primeros pasos» en Hoy** mientras no
  haya parcelas o cultivos (como Frutal): no hay que recordar si ya se vio.
- **2026-11-07 — Cultivos, semillas e insumos en el menú del Cuaderno**, no
  como pestañas: se dan de alta una vez y luego solo se eligen.
- **2026-11-07 — Reparto con la cosecha real si hay alguna con destino
  «cestas» esa semana; si no, con la prevista** (`dominio/composicion_cestas.dart`).
  No se mezclan las dos para no contar dos veces. Repartir de nuevo sustituye
  los productos de las cestas de la semana (con confirmación).
- **2026-11-07 — Sin indicador de carga**: SQLite local responde al momento y
  la rueda animada bloqueaba `pumpAndSettle` en los tests de pantalla.
- **2026-11-07 — El cuaderno de tratamientos del RD 1311/2012 va dentro del
  cuaderno ecológico** (tabla propia, solo si hay fitosanitarios), no como un
  tercer PDF: la huerta ecológica trata poco y el certificador pide los dos.
- **2026-11-07 — El cuaderno solo recoge siembras hechas** (con fecha real):
  lo planificado no es un registro.
- **2026-11-07 — La hoja de cestas no dice «ecológico»** ni pone sello de
  certificación: solo el nombre de la huerta, porque la app no certifica.
- **2026-11-07 — La v1 se amplía durante la F1** (como en Frutal): no hay
  ninguna instalación publicada.

## Normativa y fuentes consultadas (2026-11-07)

- **Reglamento (UE) 2018/848**, texto en EUR-Lex
  (https://eur-lex.europa.eu/legal-content/ES/TXT/HTML/?uri=CELEX:32018R0848),
  anexo II, parte I: 1.8.5 (material de reproducción no ecológico: autorización
  antes de sembrar, 1.8.5.4), 1.9.2.a (rotación plurianual con leguminosas),
  1.9.3 (registro del uso de fertilizantes y acondicionadores), 1.10.2
  (registros que acrediten la necesidad de fitosanitarios) y 1.12 (registros
  de parcelas y cantidad de cosecha). Leído el texto original; la versión
  consolidada no abrió (404) y queda **por verificar** si hay cambios.

## Datos técnicos

- Paquete `solera_huerta`, BD `solera_huerta.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/huerta.csv` (claves `huer.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/huerta/` → `dart run tool/compilar_catalogos.dart`.
