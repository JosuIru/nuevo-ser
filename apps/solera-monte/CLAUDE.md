# Larrea Monte — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(`docs/plan-verticales/monte.md`) y `docs/plan-verticales-larrea.md`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ 2026-11-07 | Generado con `scripts/nueva_vertical.sh`; normativa resuelta abajo (Ley 43/2003, Ley 55/1980 y TRRL art. 75 leídos en el BOE; lo autonómico, por verificar) |
| 2 Modelos + BD | ✅ 2026-11-07 | 10 modelos (`Monte` de una fila con figura, CA, instrumento de gestión, certificación y época de peligro; `Rodal` con contorno; `ActuacionPlan`; `Ejecucion`; `Aprovechamiento`; `SorteoLena` + `LoteLena`; `InfraestructuraIncendios` + `RevisionIncendios`; `ArbolSingular`; `ApunteEconomico`), 12 tablas en la v1 (`sentenciasEsquemaMonteV1`). Geodesia copiada de Ganadera. Dominio puro: `sorteo_lena.dart` (SHA-256 de «semilla\|participante», orden de menor a mayor, huella de la lista, verificación), `superficies.dart` (por especie, total, dibujada frente a declarada), `plan_gestion.dart` (estado de cada actuación, previsto frente a ejecutado por año, volumen del plan frente a lo aprovechado), `aprovechamientos.dart` (menor cuantía y plazo de un mes del art. 37) e `incendios.dart` (estado de la campaña y aviso antes de la época de peligro). 43 tests |
| 3 Pantallas | ✅ 2026-11-07 | Pestañas: **Hoy** (primeros pasos; época de peligro: pide la fecha si falta, cuenta atrás y lista de infraestructuras sin revisar o con trabajo; trámites y plazos del art. 37 de la campaña actual y la anterior; plan pendiente o atrasado; sorteos sin hacer; banner de catálogos), **Monte** (rodales con superficie por especie y total, ficha con «Dibujar el contorno caminando»; árboles y parcelas de muestreo con «usar mi ubicación»; infraestructuras con estado de la campaña y ficha con revisiones, punto GPS o traza caminando; mapa OSM con polígonos, trazas y puntos), **Plan** (previsto por año con estado de cada actuación, resumen hechas/previstas y m³ previstos frente a aprovechados; hecho, con «no prevista»), **Aprovechamientos** (campaña año anterior/actual/siguiente; lista con avisos; sorteos de leña) y **Ajustes** (idioma y datos del monte). **Sorteo** en pantalla propia: lista → cerrar (huella SHA-256) → lotes → semilla y su origen → sortear con confirmación → resultado con clave de cada puesto, lista de espera y **comprobación automática** al abrir («Comprobado» o «no coincide»), más cómo repetirlo con `sha256sum`. Altas en hojas (`formularios.dart`) con `controladores:` liberados por la hoja. 58 tests (7 de pantalla, uno de traducciones dinámicas) |
| 4-5 Documentos oficiales PDF | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Documentos: **parte de aprovechamientos de la campaña** (año actual y anterior: qué y dónde con especie y nombre científico, fechas, prevista/obtenida, reparto y adjudicatario, trámite y expediente, fecha de comunicación de la cuantía; tabla aparte de avisos; totales por tipo y unidad con m³ orientativos; lotes vecinales; resumen con el texto del art. 37.2 y 37.4 cotejado en el BOE y el aviso de que no es la solicitud oficial), **estado del plan de gestión** (inventario de rodales con edad y superficie declarada/dibujada, superficie por especie, previsto frente a hecho por año, cada actuación con su estado y lo hecho, lo hecho fuera del plan, volumen previsto frente a aprovechado; certificación si la hay) y **hoja de revisión de incendios** (año actual y anterior: estado de cada infraestructura en la campaña con la última revisión y trabajos; revisiones del año; época de peligro). Además, **acta del sorteo de leña** desde la pantalla del sorteo (lista cerrada, huella, semilla y origen, lotes y adjudicatarios, orden completo con la clave SHA-256 en cuatro grupos, cómo repetirlo y líneas de firma). Tablas en funciones puras con test; PDF con `informe_periodico` del core; 4 generadores vigilados por el sello. 67 tests |
| 6 Catálogos | ✅ 2026-11-07 (antes que el 3) | `content/monte/`: `especies_forestales.csv` (41 especies con código y nombre científico del anexo 20 del documentador Sig del IFN4, MITECO; nombres comunes de las formaciones arboladas del mismo documento cuando los da), `unidades_volumen.csv` (m³, estéreo con **0,65 m³ sólidos por estéreo** de la tabla 2 de Padovani en FAO, tonelada sin conversión) y `plagas_forestales.csv` (19 agentes: procesionarias, lagartas, perforadores Ips y Tomicus, Cerambyx, Coraebus, balanino, avispilla y chancro del castaño, Phytophthora, banda marrón, Sphaeropsis, de la guía visual 2025 de ESMA con página; nematodo del pino como plaga prioritaria UE, Reg. Delegado 2019/1702; Monochamus de la ficha de Sanidad Forestal de Baleares). **Sin sustancias activas** a propósito. Compilador sobre la librería común; consultas en `dominio/catalogos.dart` (plagas por especie o por género). 50 tests |
| 7 IA visual | ✅ 2026-11-07 | Monte → icono de escáner: **plaga, enfermedad o daño por foto**. Se elige el rodal (su especie limita las plagas del catálogo, por especie o por género) u «otra especie» (todo el catálogo) → hasta 3 candidatas con confianza y motivo, «qué comprobar» en el árbol y «otra» (sequía, fuego, viento, fauna…). Aviso fijo si sale una **plaga prioritaria de la UE** (nematodo del pino: no mover madera y avisar a sanidad forestal de la CA) o una **urticante** (procesionaria). Solo informa: nunca abre ni sugiere tratamientos. Salida estructurada con `enum` de ids + «otra», modelo equilibrado del core, clave BYO (`estado/clave_anthropic_monte.dart`, Ajustes → Inteligencia artificial). La foto se borra siempre. 73 tests |
| 8 Branding + GPS | ✅ 2026-11-07 (placeholder) | Logo ImageMagick (dos abetos, crema y dorado, sobre círculo verde pino `#2F4F3A`, fondo crema `#F5EFE2`) en `assets/`, iconos de lanzador (`flutter_launcher_icons`, adaptativo), pantalla de arranque crema con el logo y logo en la cabecera de Hoy. GPS: contorno de rodales y trazas de pistas y cortafuegos caminando (bloque 3), «usar mi ubicación» en árboles y puntos de agua, mapa OSM. Permisos INTERNET y ubicación en el manifiesto, con test (`test/branding_test.dart`). 76 tests |
| 9 Economía | ✅ 2026-11-07 (PROVISIONAL) | Ajustes → Ingresos y gastos: régimen (sin elegir / particular en REAGP / particular en general / comunidad de montes / junta vecinal, concejo o ayuntamiento, estos dos «por verificar»); apuntes por categoría propia (venta de madera y de leña, cuotas de lotes vecinales, pastos, caza, setas, ayudas; trabajos selvícolas, prevención de incendios, pistas, repoblación, asistencia técnica, certificación, seguros, tasas, gestión de la comunidad), rodal opcional → margen por rodal; resumen del año y extracto PDF con sello. **Solo la venta de madera o leña de un particular lleva propuesta** (REAGP 12 %, general 21 % por verificar); pastos, caza, lotes y setas pueden ser cesión o arrendamiento: sin propuesta y con aviso. En comunidades y entidades locales, nada y aviso. Importes en céntimos. Guardarraíles en `test/dominio/economia_test.dart`. 83 tests |
| 10 Revisión con fuente pública | ✅ 2026-11-07 | Revisión en `content/monte/revision-2026-11-07.md`: las **63 filas** de los tres catálogos con fuente citada (62 `fuente_publica:` con documento y página, 1 `revision-ia:` del nematodo contra EUR-Lex); la tonelada ya con fuente (FAO, anexo 4). **`catalogosCompletamenteRevisados` sigue en `false`** y el banner se ve en Hoy. Normativa de los PDF cotejada en el BOE consolidado: Ley 43/2003 (arts. 6, 11, 33, 36, 37, 44, 48; act. 09/11/2024), Ley 55/1980 (arts. 1-7), TRRL art. 75 y Ley 37/1992 art. 130.Cinco.1.º (act. 07/10/2026, leída por esta vertical). Lo autonómico, «por verificar». `scripts/auditoria` no conoce la vertical (lista fija fuera de esta calle: BLOQUEOS). 83 tests |
| 11 APK + ayuda | ✅ 2026-11-07 | Ayuda in-app (Ajustes → Ayuda, 10 apartados en 4 idiomas, con el sorteo paso a paso y «lo que la app no hace»), README, APK release de **66,5 MB** firmada con la clave de depuración (como el resto de la suite; copia en `~/larrea-apks/solera-monte-release.apk`) y `flutter clean` después. 84 tests. **Sin build Linux** (como Frutal y Aromáticas; ahorra disco). **Release de GitHub sin publicar** (la publica la integración) |

**Siguiente acción**: F1 completa salvo lo humano (`BLOQUEOS-PENDIENTES.md`).
Pendientes técnicos: dar de alta la vertical en `scripts/auditoria` y
`scripts/pendientes` (integración); llevar el plazo del art. 37.4 a
`content/solera/plazos.csv`; normativa autonómica de montes e incendios.

## Encuadre

Propietarios de **montes particulares** pequeños y **juntas vecinales,
concejos y comunidades de montes vecinales en mano común** que gestionan el
monte comunal: leña, madera, pastos, setas, prevención de incendios. Encaja
con la línea social de la Colección (los comunes). Ficha completa:
`docs/plan-verticales/monte.md`.

**Diferencial**: el monte comunal se gestiona hoy con papeles, la memoria de
los mayores y un técnico forestal que viene de vez en cuando. Larrea Monte
pone en el móvil el **inventario por rodales** (polígono en el mapa con
superficie calculada), el **plan de gestión** (previsto frente a ejecutado),
los **aprovechamientos** (con los lotes de leña vecinal, «suertes» o
«fogueras», **sorteados con semilla publicada**: el mismo resultado con la
misma semilla) y la **prevención de incendios** (infraestructuras y revisión
antes de la temporada).

### Hard limits (innegociables)

- **La app no autoriza aprovechamientos**: prepara la información para la
  declaración responsable, la comunicación o la autorización que tramita la
  comunidad autónoma. Nunca dice que un aprovechamiento «está autorizado» ni
  que «no necesita autorización».
- **El sorteo de leña es transparente y verificable, nunca opaco**: la
  semilla se fija y se publica antes de sortear, el algoritmo está escrito en
  la propia hoja del sorteo y cualquiera puede repetirlo. La app no decide
  quién tiene derecho a lote (lo dice la ordenanza, los estatutos o la
  costumbre): sortea entre la lista que da la junta.
- **No sustituye al técnico forestal en el señalamiento** ni en la redacción
  del instrumento de gestión (art. 33.4 de la Ley 43/2003: lo dirige un
  profesional con titulación forestal universitaria).
- No afirma que se «cumple» ninguna norma. Todos los PDF llevan sello
  PROVISIONAL. Nada de fitosanitarios por marca ni dosis.

### Normativa (resuelta en el bloque 1, 2026-11-07)

**Estatal, leída en el BOE el 2026-11-07.**
- **Ley 43/2003, de 21 de noviembre, de Montes** (texto consolidado,
  https://www.boe.es/buscar/act.php?id=BOE-A-2003-21339, última actualización
  publicada el 09/11/2024):
  - art. 6.i: los aprovechamientos forestales son «los maderables y leñosos,
    incluida la biomasa forestal, los de corcho, los de resina, pastos, caza,
    frutos, hongos, plantas aromáticas y medicinales, productos apícolas y los
    demás productos y servicios con valor de mercado característicos de los
    montes». La app usa esta lista como tipos de aprovechamiento.
  - art. 6.m: instrumentos de gestión forestal = proyectos de ordenación,
    planes dasocráticos, planes técnicos u otras figuras equivalentes.
  - art. 11.4: los montes vecinales en mano común son **montes privados** de
    naturaleza especial, sin cuotas, de los vecinos del grupo comunitario.
  - art. 33.4-5: el instrumento lo dirige un profesional con titulación
    forestal universitaria; la CA dice cuándo es obligatorio en montes
    privados no protectores.
  - art. 36.3: los aprovechamientos **no maderables** (pastos incluidos) los
    regula la comunidad autónoma.
  - **art. 37.2** (madera y leña en montes no gestionados por el órgano
    forestal): con instrumento de gestión, **declaración responsable** al
    órgano forestal de la CA; sin él, **autorización administrativa previa**,
    salvo turno corto (menos de 20 años) o domésticos de **menor cuantía**
    («inferiores a 10 metros cúbicos de madera o a 20 estéreos de leñas,
    salvo que las comunidades autónomas establezcan para su territorio
    cuantías menores»), que van con una nueva declaración responsable.
  - **art. 37.4**: si los productos se comercializan, comunicar la cuantía
    realmente obtenida al órgano forestal autonómico **en el plazo máximo de
    un mes** desde que acaba el aprovechamiento.
  - art. 44.3 y 48: las CA regulan las actividades con riesgo de incendio y
    aprueban planes anuales con las «épocas de mayor riesgo» (48.4.b).
- **Ley 55/1980, de 11 de noviembre, de montes vecinales en mano común**
  (consolidado, https://www.boe.es/buscar/act.php?id=BOE-A-1980-25463, sin
  modificaciones desde 21/11/1980): art. 2 (indivisibles, inalienables,
  imprescriptibles, inembargables; titularidad de los vecinos sin cuotas),
  art. 5.Tres (los aprovechamientos los acuerda la mayoría de los partícipes
  salvo estatutos), **art. 5.Cuatro** (los estatutos regulan la participación
  en los aprovechamientos de percepción directa «bajo el principio de la justa
  distribución entre los partícipes»), art. 7 («casa abierta con humos»: quién
  representa a cada casa).
- **Texto refundido de Régimen Local, RDLeg 781/1986, art. 75**
  (https://www.boe.es/buscar/act.php?id=BOE-A-1986-9865, consolidado
  09/11/2024): los bienes comunales de ayuntamientos y juntas vecinales se
  aprovechan preferentemente en común; si no, rige la costumbre u ordenanza
  y, en su defecto, **adjudicación de lotes o suertes** a los vecinos (75.2);
  75.4 admite condiciones de arraigo y cuantía máxima de las suertes fijadas
  en ordenanzas especiales. Es el marco de las suertes de leña de juntas y
  concejos (montes comunales públicos).

**Autonómica: por verificar** (no leída; la app guarda la CA del monte y no
aplica reglas por comunidad).
- Galicia: Lei 13/1989, de montes vecinais en man común (BOE-A-1990-3358,
  identificada, no leída) y la ley de montes de Galicia.
- Navarra, Euskadi (normas forales de montes de cada territorio histórico) y
  Asturias: leyes forestales, instrucciones de ordenación, umbrales de menor
  cuantía propios, autorización o comunicación de aprovechamientos.
- Prevención de incendios: épocas de peligro y prohibiciones de cada CA.

**Certificación forestal** (PEFC / FSC): registros que piden los estándares
publicados por cada sistema; **por verificar** contra el estándar vigente.

## Decisiones tomadas sin consultar

- **2026-11-07 — Tipos de aprovechamiento = art. 6.i de la Ley 43/2003**:
  es la única lista legal estatal; «otros» recoge lo demás.
- **2026-11-07 — Umbral de menor cuantía del art. 37.2 como aviso, no como
  regla**: la app avisa si un aprovechamiento de madera o leña pasa de
  10 m³ / 20 estéreos, pero recuerda que la CA puede fijar cuantías menores.
  Los no maderables (pastos, setas, caza…) no llevan avisos estatales: los
  regula la CA (art. 36.3).
- **2026-11-07 — `Monte` sustituye a `Titular`** (tabla de una fila): una
  instalación = un monte, como en el resto de la suite una explotación. Una
  junta con varios montes usa los rodales para separarlos (código «A-1»,
  «B-1») o una instalación por monte. Es lo más sencillo; si un piloto pide
  varios montes, migración aditiva.
- **2026-11-07 — Sorteo con SHA-256, no con `Random`**: `Random(semilla)` de
  Dart no está documentado como estable entre versiones ni se puede repetir
  fuera de la app. Con `SHA-256("semilla|participante")` y orden de menor a
  mayor cualquiera lo comprueba con `sha256sum`. Concejo no tiene sorteo con
  semilla (lo deja fuera de su F1): de su urna se toma la idea de azar
  inyectable y comprobado en tests.
- **2026-11-07 — Procedimiento del sorteo en tres pasos** (lista cerrada con
  huella → semilla pública posterior → sorteo) y bloqueo después: un sorteo
  realizado no se edita ni se borra desde la app. Los participantes
  repetidos (sin distinguir mayúsculas ni espacios) impiden sortear.
- **2026-11-07 — Lotes iguales, no proporcionales**: la app sortea qué lote
  toca a quién. El TRRL art. 75.2 habla de lotes «en proporción directa al
  número de familiares a su cargo e inversa a su situación económica» a
  falta de costumbre u ordenanza: el tamaño de cada lote lo fija la junta al
  crearlo (cantidad por lote), y la app no calcula proporciones.
- **2026-11-07 — Época de peligro sin valor por defecto**: la fija cada CA
  (art. 48); sin fecha apuntada no hay aviso. El aviso empieza 45 días antes
  (decisión de la app).
- **2026-11-07 — Una revisión de incendios cuenta para la campaña de su año
  natural**, y vale la más reciente. Un estado desconocido se lee como
  «necesita mantenimiento» (nunca se da por bueno).
- **2026-11-07 — Economía en la v1 desde el bloque 2** (tablas de apuntes y
  régimen fiscal), para no migrar antes de publicar; el modelo de régimen
  llega en el bloque 9.
- **2026-11-07 — Bloque 6 antes que el 3**: las pantallas necesitan los
  nombres de las especies y la conversión de estéreos.
- **2026-11-07 — Sin sustancias activas en las plagas forestales**: el
  encargo pide contrastarlas con el Registro de Productos Fitosanitarios del
  MAPA; la app no recomienda tratamientos y el catálogo solo sirve para
  apuntar lo observado y para la IA. Quedan fuera y en BLOQUEOS.
- **2026-11-07 — Plagas por género además de por especie** (columna
  `generos`, que casa con el principio del id de la especie): las fichas
  hablan de «Géneros afectados: Pinus», y así una especie nueva del catálogo
  hereda sus plagas sin tocar el CSV de plagas.
- **2026-11-07 — Estéreo = 0,65 m³ sólidos** como único factor (FAO): es
  orientativo y solo sirve para comparar lo aprovechado con lo previsto en
  el plan; las toneladas no se convierten.
- **2026-11-07 — Cinco pestañas** (Hoy, Monte, Plan, Aprovechamientos,
  Ajustes): Monte agrupa rodales, árboles e incendios en sub-pestañas, y
  Aprovechamientos, la campaña y los sorteos.
- **2026-11-07 — Contorno y traza caminando ya en el bloque 3** (es el
  corazón del rodal); el bloque 8 añade el branding, los permisos del
  manifiesto y su test.
- **2026-11-07 — El sorteo se comprueba solo cada vez que se abre**: repite
  el sorteo con la lista y la semilla guardadas y compara lote a lote y la
  huella; si alguien tocara la BD, se vería «no coincide».
- **2026-11-07 — Un sorteo sin hacer se puede borrar; uno hecho, no** (desde
  la app). Los lotes de un sorteo hecho no se editan.
- **2026-11-07 — El parte de aprovechamientos no imita ningún modelo
  autonómico**: no hay modelo estatal y cada CA tiene el suyo (por
  verificar). Reúne lo que piden los arts. 37.2 y 37.4 de la Ley 43/2003
  (texto cotejado en el BOE consolidado, actualización del 09/11/2024) y
  dice que no es la solicitud.
- **2026-11-07 — Cuarto PDF, el acta del sorteo**: la transparencia del
  sorteo pide algo que colgar en el tablón; lleva el mismo sello.
- **2026-11-07 — Guion corto en las celdas vacías de los PDF**: la letra
  del tema PDF no tiene la raya (—), la semirraya (–) ni los puntos
  suspensivos (…) y salían como cuadros; se vio al renderizar los PDF.
  Posible fallo igual en otras verticales que usan «—» (Aromáticas): fuera
  de esta calle, apuntado en BLOQUEOS como aviso para la integración.
- **2026-11-07 — La IA de plagas no apunta nada**: no hay registro de
  observaciones sanitarias en la F1 y la propuesta no debe acabar en un
  tratamiento; se lee y se cierra. Modelo equilibrado (como Frutal y
  Aromáticas): confundir perforadores o hongos de acícula es el riesgo real.
- **2026-11-07 — Economía mínima como Frutal y Aromáticas** (libro de
  ingresos y gastos, sin facturas del core): una junta vecinal lleva
  contabilidad pública y una comunidad de montes tiene un régimen propio
  (por verificar); la app no finge ninguna de las dos. Lo conservador en lo
  dudoso: sin propuesta de impuesto fuera de la venta de madera o leña de un
  particular.

## Datos técnicos

- Paquete `solera_monte`, BD `solera_monte.db` sobre `BaseDatosSolera` del core.
- Traducciones: `content/solera/traducciones/monte.csv` (claves `mont.*`), y
  regenerar con `cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart`.
  eu/ca/gl son **borrador** hasta la revisión nativa (`scripts/traducciones/`).
- Catálogos: `content/monte/` → `dart run tool/compilar_catalogos.dart`.
