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
| 6 Catálogos | ✅ 2026-11-07 | `content/huerta/`: cultivos (42; ciclo, semanas de cosecha, marco, por piezas), rotación (12 familias con años mínimos), categorías de insumos de los anexos I y II del Reglamento de Ejecución (UE) 2021/1165 (68, leídas en EUR-Lex, consolidado a 01/01/2026) y plagas, enfermedades y carencias (32, guías GIP del MAPA). Compilador sobre la librería común del core. En la app: especie del catálogo con familia automática, rotación con los años del catálogo, ciclo para prever la cosecha, piezas en el reparto, categoría del anexo en los insumos, plagas por familia, banner de catálogos provisionales en Hoy. Tests de integridad referencial y de que no hay firma humana fingida |
| 7 IA visual | ✅ 2026-11-07 | Ficha de bancal → icono de escáner: elige cultivo (de lo que hay en el bancal), foto (cámara o galería) → hasta 3 candidatos del catálogo de **esa familia** (salida estructurada con `enum` de ids + «otra») → la persona elige y se abre una **observación** (nuevo modelo `ObservacionPlaga`, tabla `observaciones_plaga`). Nunca propone tratamientos. Modelo equilibrado del core, clave BYO en `estado/clave_anthropic_huerta.dart` (Ajustes → Inteligencia artificial). La foto se borra al terminar. Las observaciones salen en el cuaderno PDF como prueba de necesidad (anexo II, 1.10.2). 111 tests |
| 8 Branding + GPS | ✅ 2026-11-07 (placeholder) | Logo ImageMagick (brote de dos hojas sobre tres bancales, verde hoja y tierra sobre crema) en `assets/`, iconos de lanzador (`flutter_launcher_icons`, adaptativo con fondo crema), pantalla de arranque crema con el logo y logo en la cabecera de Hoy. GPS: «Usar mi ubicación» en el formulario de parcela (geolocator) y mapa de parcelas (OSM) desde Parcelas. Permisos INTERNET y ubicación en el manifiesto (con test). 94 tests |
| 9 Economía | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Ingresos y gastos: régimen de IVA (REAGP / general / sin elegir), apuntes en céntimos con **ventas por canal** (cestas, mercado, restaurantes y tiendas, otras), interruptor «comprador empresario o profesional» (en REAGP solo entonces hay compensación del 12 %), parcela opcional → margen por parcela; resumen del año y extracto PDF con sello. Guardarraíles fiscales en `test/dominio/economia_test.dart`. 91 tests |
| 10 Revisión con fuente pública | ✅ en parte (2026-11-07) | Revisión en `content/huerta/revision-2026-11-07.md`: insumos 68/68, rotación 10/12, cultivos 33/42 y plagas 27/32 con `fuente_publica:` (ninguna `revision-ia:`: no hay sustancias por cultivo que contrastar con un registro). **`catalogosCompletamenteRevisados` sigue en `false`** a propósito y el banner se ve en Hoy. Documentos cotejados: el cuaderno cita los puntos 1.8.5, 1.9.2, 1.9.3, 1.10.2 y 1.12 del anexo II, parte I, del Reglamento 2018/848 (texto original en EUR-Lex; el consolidado no abrió) y las columnas del RD 1311/2012; el extracto, la Ley 37/1992 consolidada (07/10/2026). **No hecho**: `scripts/auditoria` y `scripts/pendientes` aún no conocen la vertical huerta (su lista de verticales está fuera de esta calle: pedirlo a la calle N) |
| 11 APK + ayuda | ✅ 2026-11-07 | Ayuda in-app (Ajustes → Ayuda, 10 apartados en 4 idiomas, con «lo que la app no hace»), README, APK release de **66,1 MB** firmada con la clave de depuración (como el resto de la suite; copia en `~/larrea-apks/solera-huerta-release.apk`) y `flutter clean` después. 113 tests. **Sin build Linux** (como Frutal; ahorra disco). **Release de GitHub sin publicar** (la publica la integración). Revisión nativa: el propio `content/solera/traducciones/huerta.csv` (es/eu/ca/gl) es la hoja; no se exportó ARB porque las apps Larrea no usan ARB |

**Siguiente acción**: F1 completa salvo lo humano (`BLOQUEOS-PENDIENTES.md`).
Pendientes técnicos: subir las cestas al módulo T2 del core cuando exista
(sustituir `lib/provisional_core/venta_directa/`); que `scripts/auditoria` y
`scripts/pendientes` incluyan huerta (calle N); exportar al SIEX (módulo T4)
antes del 1-1-2027; verificar el Reglamento 2018/848 consolidado.

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
- **2026-11-07 — REAGP: compensación solo a empresarios o profesionales**
  (Ley 37/1992, art. 130.Tres.1.º, leído en el consolidado del BOE): a los
  socios de las cestas y en el mercado no se carga ni IVA ni compensación.
  En régimen general, 4 % (art. 91.Dos.1.1.º f, hortalizas como productos
  naturales). Si vender en un puesto fijo fuera de la explotación saca la
  actividad del REAGP queda para el asesor fiscal.
- **2026-11-07 — Economía mínima, sin facturas del core** (como Frutal y
  Obrador): el régimen lo fija antes el asesor fiscal.
- **2026-11-07 — Rotación a 4 años en casi todas las familias**: ninguna
  fuente pública leída da una tabla oficial; el 4 sale del plan de ejemplo del
  Ayto. de Madrid y las guías GIP dan cifras menores para problemas concretos
  (se toma el mayor). Es lo más conservador: avisa de más, no de menos.
- **2026-11-07 — `semanas_cosecha` es estimación propia** (salvo tomate) aunque
  la fila tenga `fuente_publica`: la cita respalda ciclo y marco. Sin ella no
  hay previsión de cestas; queda para el asesor.
- **2026-11-07 — Categorías de insumo, no productos**: 68 filas resumidas de
  los anexos I y II del Reglamento de Ejecución 2021/1165 con sus condiciones
  legales (p. ej. cobre 28 kg/ha en 7 años); no se cruzaron con el Registro
  del MAPA porque el catálogo no lleva sustancias por cultivo ni plazos.
- **2026-11-07 — Se añadió `ObservacionPlaga`** (no estaba en la ficha): la IA
  propone una observación y no un tratamiento, y el Reglamento pide registros
  que acrediten la necesidad de los fitosanitarios (anexo II, parte I, 1.10.2).
- **2026-11-07 — La IA ofrece solo las plagas de la familia del cultivo**
  (más «otra» y las que no indican familia), con el modelo equilibrado como
  Frutal y Obrador: un mal diagnóstico lleva a tratar mal.
- **2026-11-07 — Catálogos preparados por un subagente** con las mismas
  reglas (`revisado_por` solo `fuente_publica:` o vacío) y revisados por el
  test de integridad; la nota de revisión está en `content/huerta/revision-2026-11-07.md`.
- **2026-11-07 — La v1 se amplía durante la F1** (como en Frutal): no hay
  ninguna instalación publicada.
- **2026-11-09 — Área y punto de la parcela con `nuevo_ser_mapa`** (BD v2:
  `parcelas.contorno` TEXT JSON `[[lat,lng],…]`, por defecto `'[]'`). El
  formulario usa `CampoPunto` (GPS o marcar en el mapa) y `CampoArea`
  (dibujar, caminar o importar KML/GeoJSON/GPX/Shapefile), con «usar la
  superficie calculada» que rellena las ha solo si se pulsa. Si hay área y no
  punto, se guarda como punto el centro del área. El mapa pinta las áreas y
  cambia entre callejero y ortofoto. Fuera `utiles/permisos_gps.dart`.
  Bancales y siembras, sin área. El texto `huer.mapa_sin_ubicaciones` aún
  habla de «Usar mi ubicación» (pendiente de retocar en las traducciones).

- **2026-11-10 — Perfil «huerto de casa»** (`estado/perfil_huerta.dart`,
  preferencia `solera_huerta.perfil`; por defecto profesional). Para
  particulares: quita la pestaña Cestas, en Hoy las cestas y los pendientes
  del certificador, y en Ajustes los documentos, ingresos y gastos, titular,
  NIF, registro, comunidad, certificación y asesor. Se queda todo lo demás
  (bancales, rotación, siembras, cosechas, insumos con plazos de seguridad,
  IA de plagas). Solo cambia lo que se ve: los datos no se borran. Se elige
  en Ajustes y en la tarjeta «Primeros pasos» de Hoy.

- **2026-11-10 — Guía del huerto** (`pantallas/pantalla_guia.dart`,
  `dominio/guia.dart`, `content/huerta/guia_*.csv`): 42 fichas de cultivo
  (una por cultivo del catálogo: calendario semillero/directa/trasplante,
  siembra, riego, cosecha, asociaciones, plagas con enlace a la fauna que las
  combate y una curiosidad), 17 de fauna auxiliar, 15 plantas que ayudan y 15
  técnicas. Pensada sobre todo para el huerto de casa, vale para los dos
  perfiles. Accesos: icono de libro en la cabecera de Hoy (sin pestaña nueva),
  «Ver en la guía» en las acciones de una siembra del bancal, icono en cada
  observación de plaga (fauna auxiliar que la combate) y tarjeta «Esta semana
  en el huerto» al final de Hoy (hasta 3 cultivos que se siembran ese mes
  según las fichas, primero los que ya tiene la persona; rota cada semana).
  Apartado nuevo en la Ayuda. Sin fotos en la v1. **Contenido solo en
  castellano**: eu/ca/gl pendientes (los rótulos sí van en 4 idiomas, en
  `content/solera/traducciones/huerta_guia.csv`). Todas las filas
  `revision-ia: 2026-11-10` con fuente; aviso fijo en cada ficha. Las
  asociaciones de la tabla de Madrid se muestran como tradición sin ensayo y la
  nota separa lo que tiene respaldo (trébol entre coles, Lobularia, milpa). La
  ficha de técnica «Rotación» enseña los años mínimos del catálogo que usa la
  app. Hard limits vigilados en `test/dominio/guia_test.dart` (términos de
  dosis, productos, marcas y salud; los plaguicidas solo para desaconsejarlos).
  Revisión: `content/huerta/revision-2026-11-10-guia.md`. 149 tests.

- **2026-11-10 — Avisos del tiempo en Hoy** (`dominio/avisos_tiempo.dart`,
  `servicios/tiempo_huerta.dart`, `pantallas/tarjeta_tiempo.dart`). Previsión
  de 7 días con `ServicioMeteoAgro` del core (Open-Meteo, como Frutal) en el
  punto de la parcela o el centroide de su área (primero las parcelas con
  algo en tierra); caché en memoria de 1 h por lugar (el servicio no cachea).
  Sin ubicación: una línea discreta; sin red, sin previsión o sin nada en
  tierra (siembra hecha y sin levantar): nada. Umbrales sencillos y
  orientativos, constantes en el dominio: **helada** mínima ≤ 2 °C (el de
  `riesgoHelada` del core y Frutal; la de esta madrugada no se avisa después
  de las 6:00), **calor** máxima ≥ 35 °C y «ola» con 3 días seguidos (no es la
  definición de AEMET), **riego** con 5 días seguidos de < 1 mm desde hoy (un
  día sin dato corta la cuenta). La helada nombra lo sensible plantado al
  aire libre (los bancales de invernadero no se nombran) según la columna
  nueva `sensible_helada` + `fuente_helada` de `cultivos_huerta.csv`: «si» en
  tomate, pimiento, berenjena, patata, calabacín, calabaza, pepino y judía
  verde; «no» en ajo, cebolla, cebolleta, haba, guisante, repollo, coliflor,
  lombarda y col de Bruselas; vacío (no se nombra) en el resto, también
  melón y sandía (las fichas no hablan de heladas) y puerro (Madrid dice que
  su plantel no las soporta, pero hay variedades de invierno). Fuentes: Ayto.
  Madrid, «Curso Huerto urbano ecológico» 2023, pp. 35-39, y Ayto. Zaragoza,
  pp. 2 y 6, leídas el 2026-11-10. Atribución «Open-Meteo.com (CC BY 4.0)» al
  pie de la tarjeta (Frutal no la pone: pendiente allí). **Recordatorio de
  helada** con `nuevo_ser_avisos` (Ajustes → «Avisarme de heladas», apagado
  por defecto, pide permiso): clave fija `huerta.helada`, la víspera a las
  20:00, solo si hay algo sensible que nombrar; se cancela y reprograma cada
  vez que Hoy carga la previsión; sin red se deja el que hubiera. Apartado
  nuevo en la Ayuda; textos `huer.tiempo_*` en
  `content/solera/traducciones/huerta_tiempo.csv`. 171 tests.

## Normativa y fuentes consultadas (2026-11-07)

- **Reglamento (UE) 2018/848**, texto en EUR-Lex
  (https://eur-lex.europa.eu/legal-content/ES/TXT/HTML/?uri=CELEX:32018R0848),
  anexo II, parte I: 1.8.5 (material de reproducción no ecológico: autorización
  antes de sembrar, 1.8.5.4), 1.9.2.a (rotación plurianual con leguminosas),
  1.9.3 (registro del uso de fertilizantes y acondicionadores), 1.10.2
  (registros que acrediten la necesidad de fitosanitarios) y 1.12 (registros
  de parcelas y cantidad de cosecha). Leído el texto original; la versión
  consolidada no abrió (404) y queda **por verificar** si hay cambios.

- **Ley 37/1992 del IVA**, consolidado del BOE (última actualización
  07/10/2026): https://www.boe.es/buscar/pdf/1992/BOE-A-1992-28740-consolidado.pdf
  — art. 130.Tres.1.º y Cinco.1.º (compensación del 12 % en entregas a
  empresarios o profesionales) y art. 91.Dos.1.1.º f) (4 % en hortalizas).

## Datos técnicos

- Paquete `solera_huerta`, BD `solera_huerta.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/huerta.csv` (claves `huer.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/huerta/` → `dart run tool/compilar_catalogos.dart`.
  Revisión: `content/huerta/revision-2026-11-07.md`.
