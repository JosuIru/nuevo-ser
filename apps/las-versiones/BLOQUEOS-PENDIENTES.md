# Bloqueos pendientes — Las Versiones

Registro de decisiones que se han tomado autónomamente (con sustitución
genérica equivalente) y que necesitan validación humana o del comité
asesor histórico (doc 16) antes de mergear a producción. Se mantiene
sincronizado con el tracker canónico (doc 17) y con las reglas del
CLAUDE.md raíz: cualquier afirmación histórica concreta no validada se
sustituye en el código por una formulación que preserva la pedagogía
sin afirmar lo que no se puede afirmar.

Cada entrada apunta al fichero del repo donde está la sustitución, lo
que dice el guion canónico, lo que se ha puesto en su lugar, y la
razón. Cuando el comité valide una entrada, basta con buscar las
referencias y revertir la sustitución.

---

## ÁTICO — El ático de Andrés y Tres fichas (F2-33, 2026-09-24)

Diseño en `docs/el-atico-de-andres.md`. No añade contenido histórico
(reutiliza afirmaciones, niveles canónicos y fuentes de las Brechas ya
cerradas), pero deja provisionales que necesitan ojos humanos:

- **Pigmentos y acentos por capa** (`lib/nucleo/pigmentos.dart`):
  aproximaciones del operador a los pigmentos del doc 11 §2.1-2.3.
  Pendiente: ilustrador.
- **Capa principal de cada Brecha** (`lib/dominio/capa_historica.dart`):
  cruce del lugar de cada Brecha con la tabla de capas del doc 05. Sólo
  decide color y fragmento musical, no se enseña como dato. Casos a
  mirar: 3.4 Roncesvalles → D-FORM (778) y 3.6 Tudela 1378 →
  D-DINASTIAS aunque sea del Arco 3.
- **Fragmentos musicales de capa** (`scripts/sonido/manifiesto_fragmentos.json`):
  bocetos con el motor de mesa-mezclas (Ravero), 17-22 s cada uno.
  Pendiente: escucha del operador y, después, compositor contratado
  (doc 12 §2.5). D-PROTO usa `celtic · harp-air`: vigilar folclorismo
  (doc 12 §1.2) con la asesoría.
- **Efectos y ambiente del ático** (`scripts/sonido/generar_sonidos_archivo.py`):
  sintetizados. Doc 12 §1.1.4 prefiere grabaciones reales (papel,
  pinza, mimbre, balanza, lluvia).
- **Voz de Andrés en el ático** (`lib/dominio/atico/voz_andres_atico.dart`):
  frases nuevas en castellano, sin revisión de voz (doc 04) ni eu/ca.
- **El documento roto**: las tiras son los propios `PropiedadesFuente` del catálogo; si un dato está mal en el catálogo, el oficio lo repite. Nada nuevo que validar aparte de eso.
- **Maestría**: El documento roto registra HF.02-05 (P1, primer intento de cada tira, dificultad 1.0 fija). Tres fichas NO registra todavía. Falta
  `P4Calibration.compute()` en el core y un `RegistroMaestriaArchivo`
  (doc del ático §6).

## TUDELA-1378 — Estación 3.6 entera (10 cinemáticas + Brecha jugable + Mosaico M3 + cinemáticas de cierre del arco)

**Tracker doc 17**: Prioridad 1 del comité provisional, **sin validar**. La validación crítica más sensible del MVP entero según el README v0.3.

**Guion canónico (doc 09 §3.6, §M3, §3.Z)**: Estación de cierre del Arco 3 que aborda el incendio del barrio judío de Tudela en noviembre de 1378 y la complicidad institucional del Concejo. Cubre el material más sensible del MVP — un acto de violencia antijudía medieval con pretensión de identificación nominal de responsables, encuadrado en el debate académico entre dos versiones publicadas previas (Isaura 2017, prudencia metodológica; Tasio/Resolutiva 2021, identificación nominal Sólido). La Brecha le exige a Maren producir una tercera versión propia que articula el silencio de tres semanas en las actas posteriores como afirmación independiente — la afirmación nueva que ni Isaura ni Tasio formularon.

**Estado**: implementación **completa** de las 10 cinemáticas de la Estación 3.6 (3.6.1 *Isaura presenta* a 3.6.10 *El silencio segundo*) + Brecha 3.6 jugable (`CatalogoBrechas.brecha36` con 7 fuentes y 9 afirmaciones canónicas) + Mosaico M3 ficha de museo (`MosaicoArco3` + `PantallaMosaicoArco3` con cartela de 6 líneas) + cinemática `M3.entrega` (Andrés en el ático archivando la cartela) + cinemática 3.Z *Aprendiz III* (cierre formal del arco con anuncio del Arco 4) + sincronizador `SincronizadorMosaicoArco3` (formato `ficha_museo_arco_3`). Todo el material del doc 09 v0.3 reproducido fielmente.

**PENDIENTE DE VALIDACIÓN MASIVA DEL COMITÉ ASESOR HISTÓRICO** — el contenido tiene puntos sensibles que requieren validación antes de exposición pública:

1. **Cifras concretas de víctimas**: "al menos dieciocho personas, según lo que se documenta", "cuatro casas destruidas completas, otras siete dañadas", "la sinagoga sufrió daños menores". Las cifras vienen del doc canónico — el comité debe validar si se ajustan a la documentación histórica conservada o si son aproximaciones del guion que requieren afinarse.

2. **Identificación nominal de tres miembros del Concejo**: la versión de Tasio/Resolutiva (2021) "identifica por nombre a tres miembros del Concejo del 1378 como responsables de la complicidad activa" (3.6.1 + afirmación 6 del catálogo jugable). Los **nombres concretos no figuran en el código** — sólo se alude a "tres miembros" sin nombrarlos. El comité debe validar si esa identificación nominal está sostenida por evidencia que el oficio acepte hoy, o si la afirmación 6 debe seguir Disputada (tal como la implementamos) o cambiarse a un nivel distinto.

3. **Carta del superviviente a un correligionario de Zaragoza**: pieza primaria diegética que carga el patrón "callar antes y no callar después". Identidad parcialmente conservada, pieza no atribuida nominalmente — el comité debe validar si existe una pieza así en archivos o si es composición pedagógica del guion.

4. **Fragmento de testimonio inquisitorial de seis años después**: pieza primaria diegética con un converso declarante anónimo que menciona a uno de los tres miembros señalados. El comité debe validar la verosimilitud de esta pieza en el aparato inquisitorial del s. XIV navarro.

5. **Excavación arqueológica del barrio**: el doc canónico menciona "excavación de 1989, niveles de incendio identificados, algunos restos óseos humanos en escombros". El código suaviza a "excavación arqueológica del s. XX" sin fecha exacta y sin afirmar restos óseos como hallazgo concreto. El comité debe validar si existe excavación documentada y qué se conservó.

6. **Correspondencia del rey Carlos II de Navarra al Concejo**: dos cartas posteriores al incendio. El doc canónico lo presenta como pieza primaria existente; el código lo recoge tal cual. El comité debe validar si se conservan esas dos cartas en el archivo real navarro.

7. **Cuatro nombres parcialmente conservados de víctimas**: "un Mosé ben con apellido fragmentado, una Dueña con apellido perdido, un niño Yosef con identificación parcial, una mujer Esther con casa identificada". Composición diegética verosímil basada en patrones onomásticos hebreos del periodo — los nombres son **explícitamente parciales** y la afirmación 9 del catálogo jugable los declara como "tarea pendiente de identificación nominativa". El comité debe validar si proceden de la documentación conservada o si son composición del guion.

8. **Casos comparativos peninsulares**: el doc menciona "Sevilla 1391, Toledo periódicamente". El código lo cita en la fuente "restos arqueológicos + comparación con casos análogos peninsulares del s. XIV". Material trazable bien establecido en historiografía antijudía peninsular medieval.

9. **Las dos reconstrucciones publicadas previas (Isaura 2017, Tasio/Resolutiva 2021)**: piezas internas del universo del juego, no pretenden ser publicaciones reales. El comité no necesita validar su existencia — son ficción narrativa del oficio del Archivo.

10. **Pieza del Mosaico M3 (piedra grabada del barrio mudéjar de Tudela con caracteres árabes parcialmente borrados)**: pieza explícitamente declarada anónima y no documentada por nombre en archivo. La cartela del M3 declara su procedencia ("muro reutilizado en una casa del antiguo barrio mudéjar de Tudela"), datación ("siglos XII-XIV, Probable") y reutilización ("documentada en muro del s. XVII") con todos los niveles de confianza visibles. El comité debe validar si la asociación al barrio mudéjar de Tudela y la datación epigráfica andalusí tardía o mudéjar inicial son adecuadas.

**Material trazable preservado sin sustitución**: año 1378 + Concejo de Tudela + judería real de Tudela + rey Carlos II de Navarra + Inquisición s. XIV + casos comparativos peninsulares (Sevilla 1391, Toledo).

**Cuando el comité valide TUDELA-1378**: revisar las 10 entradas anteriores. Posibles ajustes al catálogo jugable de la Brecha 3.6 (cifras de víctimas, calibración de la afirmación 6, atribución de las piezas primarias). El esqueleto narrativo (las 10 cinemáticas + M3.entrega + 3.Z) y la estructura jugable (catálogo de 7 fuentes + 9 afirmaciones canónicas + `minimoAfirmacionesParaConcilio: 7`) pueden mantenerse — sólo cambiar contenido textual de afirmaciones o calibraciones.

**Importante**: el flag `arco_3_iniciado` que se activa al cerrar la 3.0.1 incluye `tudela_1378_anunciada` desde F2-20a, así que la mención del incendio entró en el código en aquel slice anterior; lo que se añade ahora es el desarrollo entero de la Estación. El esqueleto del Arco 3 (5 Estaciones jugables + 1 pendiente) queda funcionalmente cerrado tras este slice; sólo la 3.2 Banu Qasi sigue marcada como narrativa-sin-Brecha-jugable a la espera de validación BANU-QASI.

---

## PIO-BELTRAN — autoría de "el libro de Beltrán" y "informe de 1973"

**Tracker doc 17**: pendiente.

**Guion canónico (doc 07)**:
- 1.0.1: "El del centro es Pío Beltrán, arqueólogo" (foto de 1958, Aralar).
- 1.0.3: "Te dejo el libro de Beltrán en tu mesa esta tarde."
- 1.1.2: "Una excavación de 1973" — implícitamente la de Pío Beltrán.
- 1.1.4: "Informe de 1973 (excavación de Pío Beltrán, con sesgos de la época — vocabulario diffusionista, comparaciones forzadas con culturas centroeuropeas)."
- 1.B: "El informe de Beltrán de 1973" + diálogo Andrés/Maren sobre Beltrán.

**Sustituciones aplicadas**:
- 1.0.1 (F2): "El del centro es Pío Beltrán, arqueólogo" → omitida; la foto se describe genéricamente sin afirmar identidad histórica concreta.
- 1.0.3 (F3): "el libro de Beltrán" → "el libro de la sierra".
- 1.1.2 (F4.1): "Una excavación de 1973" → "Una excavación de los años 70" (sin nombrar autor); "Una de 2018" → "Una más reciente" (sin nombrar autor).
- 1.B (F8.1): "El informe de Beltrán de 1973" → "El informe antiguo del dolmen"; "¿Qué te parece Beltrán?" → "¿Qué te parece el informe?". La línea pedagógicamente clave de Maren ("tiene cosas raras, pero también tiene cosas que no las tendríamos sin él") se preserva intacta — articula la postura del oficio frente a fuentes con sesgo sin requerir que el "él" sea Beltrán.

**Pendiente** para fases jugables (F6):
- En el catálogo de fuentes de la Brecha 1.1, el "Informe de 1973" + el "Informe de 2018" tendrán que aparecer como fuentes ficticias diegéticas — atribuidas a "un arqueólogo de los años 70" (anónimo) y "un equipo de revisión moderno" (anónimo). El sesgo diffusionista del primer informe se preserva como contenido pedagógico sin afirmar autoría.

**Aplicado en F6.2** (catálogo `Brecha.fuentes` de la 1.1):
- Las 5 fuentes son explícitamente ficticias y diegéticas. Sus `tipoVisible` y `descripcion` no afirman autoría real, ni dataciones C14 con desviaciones específicas (ver entrada ARALAR-DATACIONES), ni publicaciones identificables. La pedagogía (sesgo difusionista del informe antiguo, contraste con revisión moderna, fuente lingüística por topónimo, fuente material primaria) se preserva.

**Razón**: Pío Beltrán es nombre real que requiere validación del comité asesor (cuál Beltrán, qué publicaciones, qué reputación historiográfica). Hasta que el comité valide, no se puede afirmar identidad histórica concreta.

---

## EDIFICIO-ARCHIVO — verosimilitud arquitectónica del Archivo en calle Curia

**Tracker doc 17**: pendiente.

**Guion canónico (doc 07)**:
- 1.0.2: "El patio. Los capiteles del s. XII. El brocal del pozo es del XV."

**Sustitución aplicada**:
- 1.0.2 (F3): siglos concretos sustituidos por "Los capiteles tienen muchos siglos. El brocal del pozo, también. Aquí no se tira nada que sirva."

**Razón**: el edificio del Archivo en la calle Curia es ficticio en su forma concreta (verosímil pero no documentado). Afirmar siglos concretos para piezas arquitectónicas inventadas necesita validación del comité.

---

## ARALAR-DATACIONES — fechas C14 concretas para la Brecha 1.1

**Tracker doc 17**: Aralar y sus megalitos están **validados**, pero las dataciones C14 específicas que el guion menciona (4.300 ± 80 a.C. y 3.900 ± 60 a.C.) no están explícitamente en el tracker.

**Guion canónico (doc 07 §1.1.4)**:
- "Informe de 2018: revisión moderna con C14 sobre dos huesos: 4.300 ± 80 a.C. y 3.900 ± 60 a.C."

**Sustitución prevista (F6.2)**:
- Las dataciones se mantendrán como **datos plausibles** (rango neolítico para megalitismo en Aralar es arqueológicamente común) pero redondeadas y con margen de duda explícito. Concretamente: "hacia 4300 a.C." y "hacia 3900 a.C." sin las desviaciones específicas, presentadas como "datos de un informe moderno" sin afirmar laboratorio o autor concreto.

**Razón**: las cifras concretas (incluido el ± de error) sugieren un análisis específico. Hasta que el comité valide qué laboratorio/qué publicación, mejor mantener cifras redondeadas y plausibles.

**Aplicado en F8.1 (cinemática 1.A)**: el guion canónico dice en boca de Maren "las dos dataciones" al contarle a Eider lo del dolmen. Sustituido por "las dos fechas que no terminan de cuadrar" — léxico adolescente más natural que tampoco afirma laboratorio o autor del C14. La sensación de incertidumbre que la frase quiere transmitir se preserva.

---

## EIDER — amiga de Maren del instituto

**Tracker doc 17**: Eider no aparece como entrada de validación; es personaje ficticio del juego (no histórico).

**Guion canónico (doc 07 §1.A)**: Eider aparece con Maren en una cafetería del Casco Viejo. Diálogo natural sobre cómo le fue el dolmen.

**Estado**: implementada en F8.1 — `VozPersonaje.eider` añadida al elenco con tinta tenue (entorno íntimo no-institucional, igual que el resto de la familia). Cinemática 1.A "La merienda con Eider" en `EscenasArco1.laMeriendaConEider`. No es bloqueo histórico — Eider es ficticia y diegética.

---

## CAPILLA-SAKANA — anécdota de la primera Brecha de Isaura

**Tracker doc 17**: no está como entrada.

**Guion canónico (doc 07 §1.1.1)**:
- Isaura cuenta: "Una capilla en ruinas en la Sakana. Visigoda, posible. Resultó que era tardorromana."

**Sustitución aplicada**: ninguna — la anécdota es **diegética y ficticia** (no afirma una capilla histórica concreta), y la pedagogía (datación errada que se reabre) es lo que importa. La Sakana es comarca real validable; el resto es ficción del juego.

**Estado**: marcado como verosímil-aceptable, pero si el comité opina que afirmar "capilla visigoda/tardorromana en la Sakana" sin precisar puede inducir a malentendido histórico, se sustituye por una región más vaga. No urgente.

---

## Brecha 3.1 jugable — San Cernin y las tres lenguas (F2-28a)

**Estado**: catálogo jugable abierto. La narrativa del Arco 3 Estación 1 está preservada con material trazable real (Fuero de Pamplona-San Cernin de 1129, modelo de los tres burgos medievales, Privilegio de la Unión de 1423 de Carlos III el Noble, San Saturnino de Tolosa, sustrato toponímico vasco) — ningún ítem requiere validación crítica del comité asesor.

**Sustituciones diegéticas leves**:
- **`carta_concejo_navarreria_sancho_vi`** — Tipo documental real (cartas reales de queja de concejos al rey son género bien atestiguado en la cancillería navarra del s. XII), pero **sin afirmar pieza concreta catalogada y trazable**. Si el comité valida una pieza específica de la cancillería real navarra del s. XII en romance navarro con queja del concejo de la Navarrería, sustituir el id y el descriptor.
- **`reglamento_burgueses_san_cernin`** — Tipo documental real (reglamentos internos de cofradías y comunidades urbanas son género común en la documentación urbana medieval europea), pero **sin afirmar pieza concreta catalogada**. Si el comité valida un reglamento occitano gascón concreto del s. XIII con normas internas del barrio de San Cernin, sustituir.
- **`estudios_filologicos_plurilinguismo`** — Cuerpo bibliográfico genérico de filología histórica del s. XX-XXI sobre plurilingüismo navarro medieval, **sin atribuir a autores concretos**. Si el comité prefiere fijar referencias bibliográficas concretas (p. ej. trabajos de Frago Gracia, Martínez Pasamar, González Ollé, Ciérvide), añadirlas como subcategorías o reemplazar la fuente genérica.

**Material trazable preservado sin necesidad de validación**:
- Fuero de Pamplona-San Cernin de 1129 otorgado por Alfonso I el Batallador (pieza individual catalogada, ampliamente estudiada).
- Modelo de los tres burgos medievales de Iruña (Navarrería, San Cernin, San Nicolás).
- Saturnino de Tolosa como santo titular y la genealogía fonética Saturnino → Sernin → Cernin.
- Guerra de la Navarrería de 1276 entre los tres burgos.
- Privilegio de la Unión de 1423 promulgado por Carlos III el Noble.
- Sustrato toponímico vasco del casco viejo y montes circundantes (atestiguado por filología histórica).

**Decisiones pedagógicas tomadas**:
- 7 afirmaciones canónicas, distribución 4 Sólido + 2 Probable + 1 Disputado, `minimoAfirmacionesParaConcilio: 5`.
- La presencia oral del euskera bajo el trilingüismo escrito es **Probable**, no Sólida — la documentación trilingüe es Sólida pero la inferencia oral por sustrato toponímico + glosas + menciones es indirecta. Es la lección clave de la Estación articulada por Maren ante Karim en el Concilio (3.1.4).
- Las causas concretas de la invisibilidad documental del euskera son **Disputado** — cuatro hipótesis (prestigio diferencial, ausencia de scriptoria propios, uso oral estamentalmente bajo, elección política consciente) plausibles y la documentación no las discrimina.
- HF.07 (plurilingüismo documental) hace su debut jugable expandido a tres lenguas + HF.10 (detección de omisiones del euskera) en su segundo uso jugable tras el Arco 2.

**Pendiente de revisión humana** (no bloquea el slice):
- Si el comité prefiere fijar referencias bibliográficas concretas de filología histórica navarra, sustituir la fuente genérica `estudios_filologicos_plurilinguismo` por entradas más específicas.
- Si el comité valida piezas concretas de la cancillería navarra del s. XII (cartas reales de queja) y de la documentación urbana medieval del s. XIII (reglamentos occitanos), sustituir las dos sustituciones diegéticas leves.
- Si la "guerra de la Navarrería de 1276" requiere matización en la afirmación 4 sobre el número exacto de conflictos armados, ajustar el texto canónico.

---

## Brecha 3.3 jugable — Leyre y la leyenda del abad Virila (F2-28b)

**Estado**: catálogo jugable abierto. La narrativa del Arco 3 Estación 3 (cinemáticas 3.3.1–3.3.6 + latente 3.C.1) está preservada con material trazable real (monasterio de San Salvador de Leyre, cripta románica del s. XI, reyes de Pamplona enterrados allí — Sancho I, García Sánchez I, Sancho II, García Sánchez II, leyenda de Virila documentada por primera vez en códice del s. XIII, abad Virila atestiguado en listas de abades del s. IX/principios del X) — ningún ítem requiere validación crítica del comité asesor.

**Sustituciones diegéticas leves**:
- **`codice_leyenda_virila_s_xiii`** — La existencia de un códice del s. XIII de Leyre con la primera versión documentada de la leyenda de Virila es ampliamente atestiguada por la tradición historiográfica del monacato hispanomedieval, pero **sin fijar la signatura concreta del manuscrito ni la edición específica**. Si el comité valida una pieza individual concreta (signatura archivística + edición de referencia del texto medieval), sustituir el descriptor.
- **`versiones_leyenda_s_xv_xvii`** — La existencia de versiones bajomedievales y modernas de la leyenda en recopilaciones hagiográficas y *mirabilia monasterii* es género ampliamente atestiguado, pero **sin afirmar piezas individuales concretas catalogadas con autoría y fecha de edición**. Si el comité valida obras específicas (p. ej. crónicas concretas del s. XV y s. XVII que incluyan la leyenda), sustituir.
- **`estudios_hagiograficos_medievales`** — Cuerpo bibliográfico genérico del s. XX-XXI sobre hagiografía y espiritualidad monástica medieval, **sin atribuir a autores concretos**. Si el comité prefiere fijar referencias bibliográficas concretas (medievalistas de hagiografía hispana, especialistas en monacato benedictino), añadirlas o reemplazar la fuente genérica.
- **`contexto_monastico_leyre_s_xiii`** — Documentación contextual sobre el declive político relativo de Leyre en el s. XIII (traslados regios a otros panteones, reformas cluniacenses, pérdida de centralidad institucional) — el cuerpo de literatura especializada sobre el monasterio existe, **sin fijar referencias bibliográficas concretas** en el descriptor. Si el comité prefiere precisar autores y obras (p. ej. trabajos de Goñi Gaztambide, García de Cortázar, especialistas en monacato navarro), sustituir.

**Material trazable preservado sin necesidad de validación**:
- Monasterio de San Salvador de Leyre como entidad histórica.
- Cripta románica del s. XI atestiguada arqueológicamente.
- Reyes de Pamplona enterrados en Leyre — Sancho I, García Sánchez I, Sancho II, García Sánchez II — documentados en cronística medieval.
- Leyenda del abad Virila documentada en códice del s. XIII (fecha de la primera versión documentada).
- Abad Virila atestiguado en listas de abades de Leyre del s. IX o principios del X.
- Reformas cluniacenses como factor de transformación litúrgica monástica.

**Decisiones pedagógicas tomadas**:
- 6 afirmaciones canónicas extraídas literalmente del doc 09 §3.3.4 — la cinemática las lista explícitamente, no son inferencia del implementador.
- Distribución pedagógica 3 Sólido + 3 Probable + 0 Disputado, `minimoAfirmacionesParaConcilio: 4`. La Brecha 3.3 deliberadamente no tiene Disputadas — el oficio en esta Estación se ejercita en el matiz Probable, no en la duda metodológica abierta. Las afirmaciones 4 (la leyenda como producto del s. XIII), 5 (los trescientos años significantes) y 6 (la leyenda informa sobre la espiritualidad del s. XIII) son las inferencias contextuales del PH.10.
- La afirmación 3 `conexion_virila_historico_legendario` declara el matiz **"Sólido (la incertidumbre)"** en el texto canónico, no como nivel nuevo del enum (preserva paridad Dart/PHP del core).
- La afirmación 5 `trescientos_anos_significantes` se declara Probable — la coincidencia entre los trescientos años del milagro y los trescientos años entre fundación y redacción del códice es interpretativa; Joana lo cuestiona explícitamente en el Concilio (3.3.5) y pide buscar paralelos en otras leyendas monásticas con cifras simbólicas para sostenerla más firmemente.
- La afirmación 6 `leyenda_informa_sobre_s_xiii` articula la lección integradora **PH.10 — la fuente como producto de su tiempo**: *"La leyenda de Virila no cuenta lo que pasó en el s. IX. Cuenta cómo Leyre del s. XIII se sentía mirando al s. IX."* (cita literal del doc 09).
- HF.10 (detección de omisiones — el códice no contextualiza su propio momento de redacción) en uso jugable continuado tras Arco 2 + Brecha 3.1.

**Pendiente de revisión humana** (no bloquea el slice):
- Si el comité valida la signatura concreta del manuscrito del s. XIII y la edición de referencia, fijarlas en el descriptor de `codice_leyenda_virila_s_xiii`.
- Si el comité valida obras específicas para las versiones del s. XV y s. XVII de la leyenda, sustituir el descriptor genérico de `versiones_leyenda_s_xv_xvii`.
- Si el comité prefiere fijar bibliografía concreta sobre monacato hispano-medieval e hagiografía, sustituir las dos fuentes secundarias genéricas.
- Si la datación del Virila histórico (s. IX o principios del X) requiere precisión adicional, ajustar la afirmación 2.

---

## Brecha 3.4 jugable — Roncesvalles (F2-28c)

**Estado**: catálogo jugable abierto. La narrativa del Arco 3 Estación 4 (cinemáticas 3.4.1–3.4.7 + latente 3.D.1) está preservada con material trazable real (paso pirenaico de Roncesvalles, colegiata real de Santa María, emboscada del 778 documentada, Carlomagno, Sulayman al-Arabi de Zaragoza, retaguardia carolingia, vascones como atacantes en las fuentes contemporáneas, Rolando conde de la Marca de Bretaña, *Vita Karoli* de Eginardo, *Annales Regni Francorum*, *Chanson de Roland* h. 1100, primera Cruzada predicada en 1095) — ningún ítem requiere validación crítica del comité asesor.

**Sustituciones diegéticas leves**:
- **`menciones_breves_fuentes_carolingias`** — Cuerpo bibliográfico genérico de menciones del episodio del 778 en otras fuentes carolingias del s. VIII-IX (anales menores, cronicones, biografías episcopales), **sin afirmar piezas individuales identificables con autoría/fecha de redacción concretas**. Si el comité valida fuentes específicas (p. ej. el *Chronicon Moissiacense*, los *Annales Mettenses Priores*, las *Vitae* de obispos contemporáneos), fijarlas en el descriptor.
- **`estudios_contexto_cruzado_s_xi_xii`** — Cuerpo bibliográfico genérico del s. XX-XXI sobre la *Chanson de Roland* y su contexto cruzado (medievalística e historia literaria), **sin atribuir a autores concretos**. Si el comité prefiere fijar referencias bibliográficas concretas (p. ej. trabajos clásicos de Joseph Bédier, Cesare Segre, o medievalistas contemporáneos sobre la Cruzada y su huella literaria), añadirlas o reemplazar la fuente genérica.

**Material trazable preservado sin necesidad de validación**:
- Paso pirenaico de Roncesvalles real (frontera entre Navarra y Francia).
- Colegiata real de Santa María de Roncesvalles.
- Emboscada del 778 documentada en las fuentes carolingias contemporáneas.
- Carlomagno, su campaña hispana del 778 aliada con Sulayman al-Arabi de Zaragoza.
- Retaguardia carolingia emboscada por **vascones** en las fuentes contemporáneas (no por sarracenos como dice la *Chanson*).
- Rolando, conde de la Marca de Bretaña, oficial caído en la emboscada según la *Vita Karoli*.
- *Vita Karoli* de Eginardo (h. 817-836).
- *Annales Regni Francorum* (s. VIII-IX).
- *Chanson de Roland* manuscrito de Oxford fechado en torno a 1100.
- Primera Cruzada predicada por Urbano II en 1095.

**Decisiones pedagógicas tomadas**:
- 8 afirmaciones canónicas extraídas literalmente del doc 09 §3.4.5 — la cinemática las lista explícitamente, no son inferencia del implementador.
- Distribución pedagógica 5 Sólido + 3 Probable + 0 Disputado, `minimoAfirmacionesParaConcilio: 5`. Los 5 Sólido incluyen el matiz **"Sólido como afirmación metodológica"** de la afirmación 8 sobre la distinción entre el evento del 778 y la *Chanson* como obra literaria del s. XII (igual que el matiz de la 2.4 sobre el techo metodológico de la reconstrucción del silencio vascón).
- La afirmación 8 `evento_y_chanson_planos_distintos` declara **Sólido como afirmación metodológica** en el texto canónico — la distinción entre los dos planos es la condición metodológica para sostener cualquier afirmación; vive en el texto, no como nivel nuevo del enum (preserva paridad Dart/PHP del core).
- La afirmación 5 `sustitucion_refleja_contexto_cruzado` se declara Probable y articula el corazón pedagógico de la Brecha: *"propaganda cruzada — no manipulación deliberada, sino aire respirado"*. Karim la aprueba con énfasis en el Concilio (3.4.6).
- **PH.10 ampliado a su forma más completa** hace su debut narrativo pleno: si en el Arco 2 la lección era el silencio vascón como dato y en la 3.3 el desplazamiento legendario (la leyenda como producto del s. XIII no del s. IX), aquí PH.10 se amplía a *"la leyenda reescribe identidades enteras para servir a una agenda contemporánea de su redacción"* — propaganda cruzada respirada, no manipulación deliberada.
- HF.10 (detección de omisiones — la *Chanson* borra el contexto político real de la campaña hispana y a los vascones como atacantes) en uso jugable continuado tras Arco 2 + Brechas 3.1 + 3.3.

**Pendiente de revisión humana** (no bloquea el slice):
- Si el comité valida fuentes carolingias específicas adicionales del s. VIII-IX que mencionen el episodio (más allá de la *Vita Karoli* y los *Annales*), fijarlas en el descriptor de `menciones_breves_fuentes_carolingias`.
- Si el comité prefiere bibliografía concreta sobre la *Chanson* y el contexto cruzado, sustituir el descriptor genérico de `estudios_contexto_cruzado_s_xi_xii`.
- Si la atribución a Turoldo (única en el verso final del manuscrito de Oxford) merece tratamiento específico en una afirmación adicional, expandir el catálogo.

---

## Brecha 3.5 jugable — Estella en su esplendor (F2-28d)

**Estado**: catálogo jugable abierto. Cuarta y última Brecha jugable implementada del Arco 3 — la única **Brecha de respiro** del Arco según el doc 09 §3.5 (*"Brecha más serena, casi de respiro"*). La narrativa del Arco 3 Estación 5 (cinemáticas 3.5.1–3.5.4) está preservada con material trazable real (Estella/Lizarra real, conjunto románico real, fundación de 1090 por Sancho Ramírez con carta puebla documentada, Camino de Santiago, palacio de los Reyes como uno de los pocos palacios civiles románicos europeos conservados) — ningún ítem requiere validación crítica del comité asesor.

**Sustituciones diegéticas leves**:
- **`documentacion_municipal_estella_s_xii`** — Cuerpo de documentación municipal real de Estella en el s. XII (fueros sucesivos, regulaciones del mercado, contratos de hospederías, ordenanzas de peregrinos y mercaderes), **sin afirmar piezas individuales identificables con autoría/fecha de redacción concretas**. Si el comité valida documentos específicos del Archivo Municipal de Estella o del Archivo General de Navarra, fijarlos en el descriptor.
- **`estudios_fundaciones_camino_santiago`** — Cuerpo bibliográfico moderno (s. XX-XXI) sobre las fundaciones urbanas del Camino de Santiago en los s. XI-XII, **sin atribuir a autores concretos**. Si el comité prefiere fijar referencias bibliográficas concretas (p. ej. Pascual Martínez Sopena, José Ángel García de Cortázar, Eloísa Ramírez Vaquero, Juan Carrasco Pérez sobre urbanismo medieval navarro), añadirlas o reemplazar la fuente genérica.

**Material trazable preservado sin necesidad de validación**:
- Estella/Lizarra como villa real navarra.
- Carta puebla de 1090 otorgada por Sancho Ramírez (pieza fundacional documentada).
- Conjunto románico de Estella con sus cuatro monumentos: iglesia del Santo Sepulcro, San Pedro de la Rúa con su claustro, palacio de los Reyes (uno de los pocos palacios civiles románicos conservados de Europa), iglesia de San Miguel.
- Modelo villa-Camino del s. XI-XII como patrón general de fundaciones jacobeas en pleno auge del Camino de Santiago.
- Población franca occitano-hablante atraída a las villas-Camino navarras por privilegios fiscales y jurídicos concretos.
- Convivencia con la población vasco-romance preexistente del valle.

**Decisiones pedagógicas tomadas**:
- 6 afirmaciones canónicas extraídas literalmente del doc 09 §3.5.2 — la cinemática las lista explícitamente.
- Distribución pedagógica 4 Sólido + 2 Probable + **0 Disputado**, `minimoAfirmacionesParaConcilio: 4`. La Brecha 3.5 deliberadamente **no tiene Disputadas ni matices metodológicos especiales** — es contraste con las Estaciones anteriores del Arco 3 (3.1 trilingüismo + 3.3 leyenda desplazada + 3.4 propaganda cruzada). Las dos Probables son las inferencias contextuales razonables (continuidad de la población vasco-romance preexistente + lectura del esplendor económico-cultural desde los monumentos). El oficio se ejercita en limpio sin disputa metodológica grande.
- **Lección pedagógica del oficio sostenible**: la 3.5.3 (Concilio) lo articula con Aitor *"Bien. Ya sabes que se pueden hacer Brechas que no acaban contigo"* y la 3.5.4 (Calle de la Rúa al anochecer) lo cierra con la voz del Cuaderno *"Hoy no hay nada que decir. Por una vez la Brecha era simple. Ha sido un alivio"* — contrapunto al *"Lo bonito miente"* de la 3.4.7 y al *"No sé qué hacer"* de la 3.D.1. La Brecha jugable encarna mecánicamente esta lección: la calibración limpia sin matices metodológicos especiales y el catálogo más simple del Arco 3 (4 fuentes vs 5 de las anteriores Brechas del Arco 3).
- **GH.04 — geografía urbana y trazado de villa-Camino, debut jugable en el Arco 3**: la Brecha 3.5 incorpora por primera vez el dominio de Geografía Histórica como habilidad ejercitada en el Arco 3. HF.07 (plurilingüismo: francos occitano-hablantes vs vasco-romance preexistente) en uso continuado tras Brecha 3.1.

**Pendiente de revisión humana** (no bloquea el slice):
- Si el comité valida documentación municipal específica de Estella del s. XII, fijar piezas individuales en el descriptor.
- Si el comité prefiere bibliografía concreta sobre fundaciones jacobeas del s. XI-XII, sustituir el descriptor genérico.
- Si la atribución del palacio de los Reyes (datación específica + función original) merece precisión adicional en una afirmación, expandir el catálogo.

---

## BANU-QASI — Estación 3.2 (Tudela y los Banu Qasi) (F2-20b)

**Tracker doc 17**: Prioridad 2 del comité provisional, **sin validar**. La validación crítica TUDELA-1378 (Estación 3.6) tiene prioridad sobre ésta.

**Guion canónico (doc 09 §3.2)**: 8 cinemáticas que cubren narrativamente el material de los Banu Qasi (dinastía muladí del s. VIII-X que gobernó la Ribera del Ebro, especialmente Tudela), el primer encuentro narrativo con Tasio en una cafetería del casco viejo de Tudela, y la conversación de Maren con Isaura dos días después en la 3.B.1 (latente). El núcleo pedagógico es la lectura crítica de fuentes árabes (Ibn Hayyán *Muqtabis* hostil cuando se rebelan + Al-Razi geográfica + crónica anónima + inscripciones árabes locales) contra fuentes cristianas hostiles (la *Crónica de Alfonso III* y otras) + material arqueológico (alcazaba, cerámica, monedas) — y declarar la identidad muladí como Sólido como afirmación metodológica (la dicotomía moderna *"musulmán vs hispano"* no aplica al periodo).

**Estado**: las 9 cinemáticas (3.2.1–3.2.8 + 3.B.1) implementadas como narrativa, sin pantalla de Reconstrucción jugable. La Brecha 3.2 jugable real (con Mesa de Trabajo + declaración de afirmaciones con niveles de confianza sobre los Banu Qasi) queda **pendiente** — requiere validación BANU-QASI cerrada por el comité antes de implementarse, porque las 6 afirmaciones canónicas del catálogo jugable necesitan precisión histórica fina (especialmente las dataciones del s. VIII-X y la atribución del proyecto rebelde a Lubb ibn Muhammad).

**Material trazable preservado** (sin sustitución hoy):
- **Mezquita-catedral de Tudela** (Catedral de Santa María): construcción cristiana sobre la mezquita aljama tras la conquista de 1119, conservación parcial de elementos islámicos como hecho arqueológico documentado.
- **Banu Qasi** como dinastía muladí: descendientes de Casio (conde visigodo convertido al islam tras la invasión, según Ibn Hayyán que cita fuentes anteriores perdidas — declarado **Probable** en la cinemática 3.2.7, no Sólido).
- **Ibn Hayyán** y su *Muqtabis* (s. XI), **Al-Razi** (s. X), **Crónica de Alfonso III**: fuentes históricas reales y bien establecidas en la historiografía.
- **Lubb ibn Muhammad** y la rebelión del s. IX: figura histórica documentada, declarada en cinemática como "proyecto de soberanía local fronteriza, no movimiento religioso" con calibración **Probable**.
- **Derrota tras 920 + reabsorción + reorganización administrativa hasta la conquista cristiana de 1119**: marco cronológico preservado del doc 09.

**Pendiente de revisión humana**:
- ¿La caracterización de los Banu Qasi como "muladíes plenamente musulmanes en el s. IX aunque hispano-cristianos hace tres generaciones" es la lectura consensuada hoy en arabismo navarro? Posible matización si el comité prefiere una formulación más cauta sobre el ritmo de la conversión.
- ¿La derrota tras 920 puede datarse con más precisión? La cinemática usa "tras 920" sin fecha exacta; puede afinarse cuando el comité valide.
- Tono de Tasio en 3.2.5 (primer encuentro): material narrativo cerrado por el guion canónico, no requiere validación histórica del comité, pero sí queda pendiente de revisión por la Bíblia de Personajes (doc 04) cuando entre Tasio formalmente.
- **3.B.1 — relación romántica Isaura/Tasio**: la confesión final de Isaura *"Lo sigo queriendo"* es material narrativo del guion canónico, sin sustitución.

**Cuando el comité valide BANU-QASI**: se puede afinar la cronología de la rebelión, datar con precisión la derrota, validar la atribución a Lubb ibn Muhammad como cabeza del proyecto, y abrir la Brecha 3.2 jugable con las 6 afirmaciones canónicas calibradas.

---

## Mecánicas pedagógicas (F6) — decisiones tomadas sin consenso

Estas son decisiones de diseño pedagógico que normalmente pediría
consenso, pero que para no parar el desarrollo se han tomado
autónomamente. Quedan documentadas para revisión:

### Formulación de Preguntas (F6.1, PR.01/PR.02)
- **Criterio algorítmico**: longitud ≥3 palabras + signo de interrogación + al menos una palabra-pregunta de la lista canónica (qué/quién/cómo/cuándo/dónde/por qué/cuál/cuánto + sí/no/acaso). Score 0-3.
- **Limitación**: el guion (doc 07 §1.1.3) describe un sistema P3 con rúbrica de "investigabilidad, especificidad, relevancia, originalidad" — más sofisticado de lo que un algoritmo simple puede hacer sin LLM. La versión inicial usa el criterio algorítmico básico; cuando se conecte al tutor IA podrá hacer la rúbrica P3 real.

### Evaluación de Fuentes (F6.3, HF.01-09)
- **Criterio algorítmico**: cada fuente lleva 6 propiedades canónicas en JSON con respuestas predefinidas; el niño elige y se compara. P1 score por habilidad.
- **Limitación**: el guion describe un sistema más conversacional ("Considera: ¿el informe de 1973 fue producido en el momento del enterramiento, o lo interpreta?"). La versión inicial es de elección múltiple; el feedback conversacional puede llegar después con tutor IA.

### Reconstrucción + AH.03 (F6.4, P4 Brier)
- **Criterio algorítmico**: el niño elige entre afirmaciones precanónicas las que considera sostenidas y declara confianza (Sólido/Probable/Disputado). Brier invertido compara con calibración correcta declarada en el catálogo de la Brecha.
- **Limitación**: el guion permite que la Cronista escriba sus propias afirmaciones. La versión inicial sólo permite elegir entre precanónicas; escritura libre con evaluación llega cuando se conecte al tutor IA.

### Concilio (F6.5)
- **Criterio**: feedback automatizado por personaje basado en lo que el niño hizo. Sin ganar/perder. Tono cercano al guion 1.1.6.
- **Limitación**: el guion 1.1.6 es un diálogo orgánico Isaura-Maren basado en lo que la Cronista hizo. La versión inicial son ramas precanónicas según ranges de scores; el diálogo real con tutor IA llega después.

---

## Arco 2 — narrativa lineal completa: Estación 2.1 + latentes 2.A + Estación 2.2 + latente 2.B.1 + Estación 2.3 + latente 2.C.1 + Estación 2.4 + entrega Mosaico M2 + cierre 2.Z (F2-1 a F2-8)

**Tracker doc 17**: pendiente.

**Estado**: implementadas las 34 cinemáticas que cubren la apertura del Arco 2 (2.0.1), las cuatro Estaciones enteras (2.1 Pompaelo, 2.2 Calagurris, 2.3 domus de los mosaicos, 2.4 Wamba contra los vascones), las tres cinemáticas latentes post-Estación que cosen el arco emocionalmente (2.A.1 + 2.A.2 tras Pompaelo, 2.B.1 tras Calagurris, 2.C.1 tras la domus), la cinemática de entrega del Mosaico M2 (M2.entrega, doc 08 §M2: ático del Archivo, Andrés escucha la audio-guía de 90s con auriculares y la valida con la observación pedagógica clave — *"has dicho 'no sabemos' tres veces. Y 'probablemente' cuatro" / "está perfecto"*) y las dos cinemáticas del cierre del Arco 2 (2.Z.1 *Antonio y Wamba* en la cocina de casa con el paralelo entre los moriscos del Quijote y el silencio vascón + el aforismo del padre *"los oficios que tienes claros desde el principio suelen ser los que se acaban antes"* + la frase truncada *"Maren / Mmm. Olvídalo. Sigamos cocinando"*; 2.Z.2 *La grabación* en el cuarto de Maren — Maren había grabado a su padre en la cocina sin decírselo, escucha la grabación entera, la guarda con honestidad declarada para mañana, articula tres pensamientos del Cuaderno y apunta el silencio del padre como pregunta abierta *"como Isaura"*; cierre simbólico del arco con ARCO 2 — CERRADO + anuncio del Arco 3 *La forja del reino*). La línea epistémica clave del arco se fija en 2.4.5 (cocina del Archivo, conversación con Karim): **"el silencio vascón es el dato. No es ausencia de dato. Es dato. Es información sobre cómo funcionaba la maquinaria de la fuente"**. La Estación 2.4 se diferencia de las tres anteriores en que la asimetría documental es deliberadamente extrema: una sola perspectiva, la del productor visigodo (Julián de Toledo). El Concilio dividido (2.4.7) reproduce las cinco voces revisoras del Arco 2 — Karim Reformista, Aitor Constructor, Joana, Begoña, Isaura — con desacuerdo explícito sobre la calibración de la afirmación 8. La narrativa lineal del Arco 2 está completa; quedan pendientes la pantalla jugable del Mosaico M2 (formato audio-guía, distinto del M1 cómic) y las cuatro Brechas jugables 2.1/2.2/2.3/2.4 (requieren refactor previo de `FaseBrecha`).

El orquestador encadena Arco 1 → Arco 2 cruzando `arco_1_cerrado_por_la_cronista` (1.Z) y dentro del Arco 2 las 34 cinemáticas se encadenan por `flagsRequeridos`/`flagDeSalida`. La 2.4.1 requiere `escena_2_c_1_vista` (que la 2.C.1 activa); la 2.4.8 cierra activando `aprendiz_dos_alcanzado`, `arco_2_estacion_4_cerrada` y (provisional) `mosaico_arco_2_entregado`. La M2.entrega requiere `mosaico_arco_2_entregado` y activa `escena_m2_entrega_vista`. La 2.Z.1 requiere `escena_m2_entrega_vista` y activa `escena_2_z_1_vista`. La 2.Z.2 requiere `escena_2_z_1_vista` y activa `arco_2_cerrado_por_la_cronista` — hito que el Arco 3 requerirá como precondición. Tras cerrar la 2.Z.2 el orquestador cae al esqueleto porque las cinemáticas del Arco 3 todavía no están implementadas.

**Pendiente para próximas iteraciones**:
- Pantalla jugable del Mosaico M2 ("audio-guía de Pompaelo") — formato distinto al M1 según doc 08 §M2 (audio en lugar de cómic). Posible refactor del modelo `Mosaico` a una abstracción que admita varios formatos. Cuando entre, el flag `mosaico_arco_2_entregado` se mueve del cierre de la 2.4.8 al `_alEntregarMosaicoArco2` del orquestador (entrada F2-8 propia más abajo con detalle del cambio).
- Catálogo de Brechas del Arco 2 (`CatalogoBrechas` añade brecha21 + brecha22 + brecha23 + brecha24 jugables) — requiere refactor previo de `FaseBrecha` para admitir distintos números de afirmaciones por Brecha (entrada propia más abajo).
- Validación humana del comité asesor sobre el contenido histórico concreto del Arco 2 — sustituciones diegéticas residuales en secciones siguientes.

**Sin sustituciones diegéticas en 2.B.1 ni 2.C.1**: el cuaderno marrón de Isaura es ficticio del juego; en 2.C.1 la plaza del Castillo es lugar real validable de Iruña y la cinemática no nombra fechas, dataciones ni personajes históricos. Eider sigue siendo personaje ficticio del juego (validación humana sobre su voz registrada en la entrada EIDER existente).

---

## Mosaico M2 — disparador provisional + cierre 2.Z aplicado (F2-8)

**Tracker doc 17**: pendiente.

**Estado**: la cinemática de entrega del Mosaico M2 (`EscenasArco2.entregaDelMosaicoM2`, doc 08 §M2) y las dos del cierre del Arco 2 (`antonioYWamba` 2.Z.1 + `laGrabacion` 2.Z.2, doc 08 §2.Z.1–2.Z.2) están implementadas y encadenadas por flags. La pantalla jugable del Mosaico M2 (audio-guía de 90s con anclajes obligatorios y declaración verbal de niveles de confianza) **no** está implementada hoy.

**Disparador provisional aplicado**:
- La cinemática `aprendizDosLogrado` (2.4.8) activa al cerrar, además de `aprendiz_dos_alcanzado` y `arco_2_estacion_4_cerrada`, también `mosaico_arco_2_entregado`. Eso permite que la `M2.entrega` y, encadenadas, las dos del cierre 2.Z sean alcanzables hoy sin que exista la pantalla M2 jugable.
- Cuando entre la pantalla M2 jugable, el flag `mosaico_arco_2_entregado` se elimina del cierre de la 2.4.8 y se mueve al `_alEntregarMosaicoArco2` del orquestador (paralelo al `_alEntregarMosaicoArco1` que ya existe para el M1). Cambio trivial, ~3 líneas tocadas.
- Mismo patrón provisional que se aplicó en el Arco 1 con `arco_1_completado` cuando sólo la Brecha 1.1 estaba implementada.

**Sin sustituciones diegéticas en M2.entrega**: el diálogo se reproduce literalmente del doc 08 §M2 (Andrés observa que Maren ha dicho "no sabemos" tres veces y "probablemente" cuatro, cierra con "está perfecto"). El reconocimiento por gesto pequeño es simétrico al 1.M1.entrega del Arco 1 — pertenecer al oficio se mide en los silencios del aprendiz.

**Sin sustituciones diegéticas en 2.Z.1 ni 2.Z.2**: la conversación cocina con Antonio reproduce literalmente el doc 08 §2.Z.1, incluido el paralelo entre los moriscos del Quijote y el silencio vascón ("Cervantes habla mucho de moriscos. Pero los moriscos no aparecen escribiendo") + el aforismo del padre ("los oficios que tienes claros desde el principio suelen ser los que se acaban antes") + la frase truncada ("Maren / Mmm. Olvídalo. Sigamos cocinando") que la 2.Z.2 va a interrogar como pregunta abierta. La 2.Z.2 reproduce literalmente la voz íntima del Cuaderno con los cuatro pensamientos canónicos (grabar al padre sin permiso con declaración para mañana, oírse hablando con el padre como par, recordar el aforismo de los oficios, apuntar el silencio del padre como pregunta abierta usando explícitamente el modelo de Isaura). Cierre formal con ARCO 2 — CERRADO + anuncio del Arco 3 *La forja del reino*.

**Pendiente de revisión humana**:
- Tono de Antonio en 2.Z.1 — primera vez que el padre articula material narrativo largo desde la 1.B.1 y desde 2.A.2 (donde Antonio pasa el libro de Quintiliano). El paralelo Quijote/silencio vascón es propuesta intelectual fuerte que el doc 04 deja como abierta para Antonio. ¿Encaja con la voz fijada o requiere ajuste?
- Decisión narrativa de Maren en 2.Z.2 (grabar a su padre sin decírselo) — gesto cercano al límite ético que el juego articula explícitamente: Maren reconoce que "no es bonito hacerlo" y declara que "mañana se lo cuenta". ¿La forma encaja con el oficio que el juego enseña? Se ha mantenido literal del doc 08 v0.1 porque el material pedagógico clave es justo cómo Maren convive con la incomodidad ética declarándola, en lugar de evitarla. El comité podría proponer suavizarlo.
- Línea final del cierre del arco — "Continuará en Arco 3 — La forja del reino". Reproduce el subtítulo del Arco 3 del doc 08 v0.1, pendiente de confirmar con doc 09 cuando se aborde.

---

## Estación 2.4 (Wamba contra los vascones) — yacimiento sin nombre + nueve afirmaciones canónicas (F2-7)

**Tracker doc 17**: pendiente.

**Material trazable** (sin sustitución, ya en el tracker general o en publicaciones de referencia abierta):
- **Wamba** (rey visigodo) y **Julián de Toledo** (autor de la *Historia Wambae regis*) son figuras históricas reales y trazables. La fecha 673 d.C. para la campaña narrada por Julián está en bibliografía estándar.
- **La asimetría documental sobre el lado vascón** del periodo 5-7 d.C. es hecho historiográfico bien documentado: no hay fuentes producidas por las comunidades vascónicas para este periodo concreto. La pedagogía de la Estación se construye sobre esta ausencia documentada, no sobre una afirmación histórica novedosa.

**Sustitución diegética aplicada**:
- **2.4.3 — yacimiento vascón del norte sin nombre histórico en pantalla**. El doc 08 v0.2 §2.4.3 sugiere visitar un yacimiento vascónico real concreto. La cinemática se construye en un yacimiento del norte de Nafarroa **sin nombrarlo**: descripción genérica de poblamiento del periodo, ausencia de cerámica con inscripciones, sin paneles museográficos, ladera mirando al norte. La pedagogía (el silencio del lugar habla del silencio documental) se preserva sin afirmar yacimiento concreto hasta validación del comité asesor sobre cuál usar. Ambiente nuevo: `AmbienteArchivo.yacimientoVasconNorte`.

**Material diegético deliberadamente articulado**:
- **Las 9 afirmaciones canónicas de la Brecha 2.4** (declaradas en 2.4.6, *Reconstrucción honesta*) están calibradas con el mismo rigor que las 8 de la 2.3.5, y dos de ellas son experimentales:
  - **Afirmación 7** ("No se conservan fuentes producidas por los vascones de este periodo, contemporáneas o anteriores") declarada como **"Sólido (la ausencia)"** — paralela a la afirmación 6 de la Brecha 2.3 (la ausencia documental de las personas esclavizadas en la domus). La forma de calificación marca el aprendizaje del juego: la ausencia documentada **es** dato sólido, no incertidumbre.
  - **Afirmación 9** ("La reconstrucción del lado vascón tiene un techo metodológico determinado por la asimetría de las fuentes") declarada como **"Sólido como declaración metodológica"** — el aprendiz declara explícitamente el límite de su propia reconstrucción, marcando AH.03 (declaración de niveles de confianza) en su forma más madura del Arco 2.

**Voces nuevas del Concilio dividido (2.4.7)**:
- **Joana** aparece con material narrativo largo por primera vez en el juego. Su voz Anclada (doc 04) se fija aquí: pide más matices ("Sólido tirando a Probable alto" para la afirmación 8, defiende el "(la ausencia)" de la 7), no compite con Maren, busca reforzar la calibración. La voz Anclada de Joana se vio fugazmente en la 1.4.3 del Arco 1; aquí se consolida.
- **Begoña** aparece en el Concilio del Arco 2 por primera vez. Voz neutra, pide claridad sobre la afirmación 8 (¿"esta ausencia documental no es accidente" requiere matización para evitar argumento conspirativo?), recibe respuesta precisa de Maren.
- **Karim Reformista** marca su carácter explícito por primera vez con palabra de Cronista superior ("la afirmación 7 es la más importante de la Brecha. La ausencia es dato. Punto"). Coherente con el rasgo Reformista del doc 04 articulado en 2.4.5.
- **Aitor Constructor** vuelve a hacer su trabajo de presión: pide rebajar la afirmación 8 a Disputada porque "no es accidente" suena interpretativo. Maren no cede pero matiza la formulación. El desacuerdo se cierra sin consenso, registrado en el Concilio.

**Pendiente de revisión humana**:
- ¿La elección de **no nombrar el yacimiento concreto** del norte (sustitución diegética en 2.4.3) es la correcta, o el comité asesor prefiere anclar la Estación a un yacimiento real documentado (con bibliografía y limitaciones explícitas)? La elección actual es coherente con el espíritu de la Estación (el silencio del lugar es el dato), pero pierde la trazabilidad arqueológica que sí preserva el resto del Arco 2.
- ¿La calibración de la **afirmación 8** ("esta ausencia documental no es accidente: refleja la dirección desigual del poder narrativo") está bien como **Sólido**? El Concilio interno del juego ya tensiona la pregunta (Joana propone Sólido tirando a Probable alto, Aitor propone Disputada). Se ha mantenido como Sólido porque la asimetría del poder narrativo de la Antigüedad Tardía frente a las poblaciones vascónicas está bien establecida en historiografía estándar, pero el comité podría preferir Probable o Sólido (limitado a la generalización metodológica). La forma "no es accidente" es deliberadamente directa para enseñar a no rebajar afirmaciones bien fundadas por timidez.
- **Tono de Karim Reformista** en 2.4.5 cuando le dice a Maren "el silencio vascón es el dato" — primera articulación pedagógica explícita de Karim en posición casi tutorial (hasta ahora ha funcionado más como revisor de Concilio). ¿Encaja con la voz fijada en doc 04? El Reformismo se hace explícito en la frase de cierre ("¿Eso es Reformismo? — Eso es honestidad. El Reformismo es nombrar de dónde viene la ausencia").
- **Voz de Joana** consolidada — primera vez con material narrativo largo. ¿Encaja con la entrada de Joana en doc 04 o requiere ajuste?
- **Voz de Begoña** estrenada en el Concilio del Arco 2 — primera aparición jugable larga (apuntes previos cortos en doc 04). ¿Encaja con su perfil de Cronista superior cauta?
- **Línea de cierre de Maren en 2.4.7** ante el desacuerdo ("acepto el desacuerdo. La afirmación queda como Sólido en mi reconstrucción y Disputada en la lectura de Aitor") — primera vez que el aprendiz declara explícitamente que dos calibraciones distintas pueden coexistir como lectura del Concilio. El doc 14 §6.5 prescribe que el Concilio NO premia tener razón sino haber juzgado bien con lo disponible; la formulación encaja, pero el comité podría afinarla.
- **Continuidad pedagógica con la Estación 2.3**: la afirmación 7 de 2.4 ("la ausencia es dato") es paralela funcional a la afirmación 6 de 2.3 (la ausencia documental de las personas esclavizadas). ¿La repetición consciente del recurso pedagógico es la elección correcta o el comité prefiere variación? La repetición se ha hecho deliberadamente para consolidar el aprendizaje cruzado de Estaciones distintas con el mismo recurso epistémico.

**Sin sustituciones en el resto de la Estación**: 2.4.1 (encargo en el despacho de Isaura), 2.4.2 (lectura crítica de Julián de Toledo en la biblioteca del Archivo), 2.4.4 (frustración interna en la mesa de trabajo), 2.4.6 (declaración de las 9 afirmaciones), 2.4.7 (Concilio), 2.4.8 (Aprendiz II en el patio del Archivo) no nombran yacimientos concretos, dataciones específicas ni publicaciones identificables más allá de Wamba + Julián + el año 673.

---

## Estación 2.3 (domus de los mosaicos) — material diegético + sustitución por edificio del Archivo (F2-5)

**Tracker doc 17**: pendiente.

**Material diegético de la Brecha 2.3** (registro):
- **La domus subterránea** bajo el casco viejo de Iruña accesible vía galería técnica desde el sótano del Archivo es ficticia diegética del juego. Pamplona/Pompaelo tiene domus romanas documentadas en yacimientos urbanos parciales, pero la conexión galería ↔ Archivo es invención narrativa. El mosaico geométrico del s. II y la habitación durante doscientos años son verosímiles para domus hispanorromanas.
- **La familia Cornelia** (un Cornelio magistrado local con praenomen perdido, esposa con nombre incompleto, hijos no documentados, dos personas esclavizadas mencionadas como número en las cuentas) es **explícitamente ficticia diegética**. Cornelius es gentilicio común romano usado deliberadamente como dispositivo pedagógico, no como afirmación histórica sobre una familia concreta de Pompaelo.
- **Las 8 afirmaciones canónicas** reproducen la calibración del doc 08 §2.3.5 sin sustitución. La afirmación 6 (la ausencia documentada de las personas esclavizadas) calificada como **Sólido (la ausencia)** es el corazón pedagógico de la Estación.
- **"Las grietas también hablan"** — frase del pasillo de los Reformistas, ficticia del juego. Funciona como dispositivo narrativo que articula la dicotomía Tasio/Karim sobre cómo se interpreta la frase.

**Sustitución diegética aplicada**:
- 2.3.3 (la crisis): "el capitel del s. XII" → "el capitel del patio" (sin afirmar siglo). Misma sustitución que se aplica en 1.0.2 y 1.4.4, registrada en la entrada EDIFICIO-ARCHIVO de este mismo documento. La pedagogía (Maren mira algo del patio mientras procesa la crisis) se preserva sin afirmar dato arquitectónico no validado.

**Pendiente de revisión humana**:
- ¿La caracterización de la domus como ficticia diegética accesible "vía galería técnica desde el Archivo" funciona, o el comité asesor prefiere anclar la Estación a una domus real documentada (con su yacimiento, su bibliografía y sus limitaciones)? La elección actual es deliberada porque permite controlar las fuentes catalogadas con propósito pedagógico (la asimetría entre el propietario y los esclavos es matemáticamente clara), pero pierde la trazabilidad arqueológica.
- Tono de Maren en 2.3.3 (la crisis) — primera vez que la Cronista articula rabia explícita en pantalla. La frase "soy cómplice" es fuerte. ¿Encaja con la voz fijada en doc 04? Para el oficio del juego es importante que el aprendiz pueda sentir incomodidad ética en algunos casos sin que eso se trate como "fallo de profesionalidad".
- Tono de la lección de Isaura en 2.3.4 — la dicotomía neutralidad/comprensión es el mensaje pedagógico más explícito que el juego hace hasta ahora. ¿La articulación es lo bastante cuidadosa para que un aprendiz de 11-12 años la lea sin malentendido (interpretarla como permiso para juzgar todo lo histórico desde el siglo XXI)? La condición "tu valoración está fuera, la de ellos está dentro" se incluye explícitamente para acotar.
- Voz de Karim en 2.3.6 con la frase de pasillo — "la afirmación 6 es de las que me hacen tener esperanza con esta institución" es declaración política (crítica institucional desde dentro) que el juego pone en boca de un Cronista superior. ¿El comité valida esa formulación? Es coherente con el carácter Reformista de Karim (doc 04) pero merece confirmación.

**Sin sustituciones diegéticas en 2.A.1 ni 2.A.2**: Quintiliano de Calagurris y la edición de Cousin (Jean Cousin, *Quintilien — Institution oratoire*, Les Belles Lettres) son referencias reales y trazables que pasan el filtro del comité sin revisión. Marina sólo nombra términos ya validados ("inscripción", "huesos", "polen", "Aralar", "Calahorra"). La frase pedagógica clave de Antonio ("habla menos de sí mismo de lo que parece") es comentario crítico genérico, no afirmación histórica.

---

## Estación 2.2 (Calagurris) — referencias trazables y datos pendientes de validación fina (F2-3)

**Tracker doc 17**: pendiente.

**Estado**: la Estación 2.2 se implementa preservando el contenido del doc 08 §2.2.1–2.2.6 sin sustituciones globales — la pedagogía sobre fuentes textuales, omisiones y peso interpretativo cabe en información histórica establecida sobre Quintiliano de Calagurris. La voz `VozPersonaje.arqueologa` (femenina, etiqueta funcional "Arqueóloga", tinta tenue) se añade simétrica al `arqueologo` masculino del yacimiento de Irulegi — el doc 08 decide explícitamente no nombrar a la arqueóloga local de Calahorra.

**Datos preservados sin sustitución (verificables)**:
- **Quintiliano de Calagurris** (Marco Fabio Quintiliano, ~35–~100 d.C.) — biografía histórica establecida.
- **Calagurris fue navarra hasta 1076** — fecha histórica establecida (muerte de Sancho IV de Pamplona "el de Peñalén" tras la conjura de Peñalén; tras su asesinato Calahorra pasa a la Corona de Castilla bajo Alfonso VI). Pío Beltrán en su día y la historiografía riojana posterior fijan la fecha. Maren la repite con la cabeza y luego la siente — articula la pedagogía del oficio (saber un dato vs sentirlo).
- **Pasajes A-D de la *Institutio Oratoria***: I prooemium 6, II llegada a Roma, IV prefacio (dedicatoria a Vitorio Marcelo), VI prefacio (lamento por la muerte del hijo). Los cuatro pasajes son reales y bien establecidos en la edición crítica. **Vitorio Marcelo** (Victorius Marcellus, dedicatario del Libro IV) es histórico.
- **Estatua moderna en el museo de Calahorra** + sala dedicada — el museo de la Romanización en Calahorra existe; describir la sala como dedicada a Quintiliano con estatua moderna y placa es verosímil-aceptable sin afirmar contenido específico de la museografía.

**Pendiente de revisión humana**:
- ¿La fecha 1076 debe revertirse a "siglo XI" si el comité prefiere conservadurismo, o se mantiene? El doc 08 la usa como dispositivo pedagógico y la fecha está bien establecida; mantenerla sirve la pedagogía mejor. Si el comité aporta matiz historiográfico (por ejemplo, "1076 marca el cambio formal pero la transición de pertenencia identitaria fue más gradual"), se incorpora como matiz de la frase de Isaura sin tocar el dato.
- Voz de la arqueóloga de Calahorra — primera aparición con material narrativo largo. ¿El tono de "voz de territorio" (cercana, técnica pero accesible, sin protocolo del Archivo) encaja con la Bíblia de Personajes?
- Mecánica HF.10 (detección de omisiones) — debutará jugable cuando se aborde el refactor de `FaseBrecha` para Brecha 2.2 jugable (mismo bloqueo que Brecha 2.1: el modelo de 3 afirmaciones canónicas con calibración fija no encaja con 7 afirmaciones que mezclan evidencia directa e indirecta). Hoy la pedagogía se enseña narrativamente.
- Frase de Isaura "lo que fue navarro fue navarro de verdad. Lo que es riojano hoy es riojano de verdad. Las dos cosas son ciertas" — la formulación es deliberadamente no-confrontativa con identidades territoriales actuales. ¿Encaja con la postura editorial de la Colección sobre identidades sucesivas? Probable Sí, pero merece confirmación humana.

---

## Estación 2.1 — sustituida por POMPAELO-INSCRIPCION validada (F2-17)

**Tracker doc 17**: validada en revisión v0.3 del paquete documental — `coleccion-nuevo-ser-paquete-documental-v0.3/cambios-pendientes-v0.3/escenas-1200-y-final-arco-4.md` recoge la sustitución del modelo literario "inscripción de Licinio cónsul" por la **ara funeraria real de Aelio Attiano** publicada por García-Barberena, Unzu y Velaza en *Epigraphica* 76 (2014).

**Estado**: cerrada como sustitución por material validado. Las cinemáticas de la Estación 2.1 (`escenas_arco_2.dart`, 2.1.1–2.1.6) y la Brecha 2.1 jugable (`catalogo_brechas.dart::CatalogoBrechas.brecha21`) usan el ara real de Aelio Attiano. El catálogo expone 4 fuentes diegéticas (ara primaria oficialista, publicación Velaza 2014 secundaria, tablillas de Arre primarias con CIL II 2958-2960 ancla la forma *Pompelo*, datos de la muralla bajoimperial primarios) y 10 afirmaciones canónicas con la calibración doble del doc validado: el error del lapicida en par hecho/causa (Sólido/Disputado) y la reutilización en muralla en par hecho/contexto (Sólido/Probable). `minimoAfirmacionesParaConcilio: 7`. Se preserva la pedagogía del oficio honesto declarando muchas Disputado/Probable cuando la fuente textual lleva propaganda y huecos no rellenables.

**Cambio terminológico global Pompaelo → Pompelo**: las tablillas hospitalarias de Arre (CIL II 2958-2960) anclan la forma local *Pompelo* (no *Pompaelo*) como atestiguada en epigrafía hispanorromana. Aplicado en `escenas_arco_1.dart`, `escenas_arco_2.dart`, `ambiente_archivo.dart` (con renombre del identifier `pompaeloSubterranea` → `pompeloSubterranea` y de la cadena de persistencia `'pompelo_subterranea'`), `mosaico_arco_2.dart` (los dos fragmentos del Arco 2 sobre la Estación 2.1 reescritos con la nueva terminología y las nuevas IDs `pompelo_ara_dos_caras` + `pompelo_error_lapicida_y_muralla`), `widget_test.dart` y `catalogo_brechas.dart`. Se preservan las menciones al *Itinerario de Antonino* (que sí grafía *Pompaelone*) en su contexto literario original.

**Material validado preservado**: ara funeraria de doble inscripción (cara A s. I dedicada a Aelio Attiano por su padre, cara B s. III reutilizando la pieza), error del lapicida en la cara A (latín agramatical en una zona donde lo previsible sería una élite hablando latín culto), reutilización de la pieza en la muralla bajoimperial de Pompelo, tres hipótesis canónicas para el desfase cronológico entre las dos inscripciones, datación amplia s. I-III, las dos preguntas que el ara mutilada por la reutilización deja sin respuesta (vínculo familiar exacto del difunto y ocupación que justifique el ara doble). Material trazable: García-Barberena/Unzu/Velaza *Epigraphica* 76 (2014), CIL II 2958-2960, *Prosopographia Imperii Romani* (PIR) como herramienta canónica.

**Cinemáticas 2.1.1–2.1.6 reescritas (F2-18)**: las seis cinemáticas narrativas de la Estación 2.1 (`escenas_arco_2.dart`) reproducen ahora el contenido validado del doc v0.3 — bajada al sótano + descubrimiento del ara funeraria con corona moldurada (no fragmento de mármol), las dos caras con sus textos epigráficos literales (cara A `· D · M · S ·`, cara B con las 6 líneas del ara real incluido el error gramatical del lapicida en línea 5), Karim explicando paleografía + las tres hipótesis canónicas del desfase cronológico s. I/s. III + el error del lapicida como información que escapa a la propaganda + la traducción consensuada del ara, Karim contextualizando la reutilización en la muralla bajoimperial + Maren articulando la lección clave + Karim sonriendo pequeño *"Eso lo digo yo a estudiantes universitarios..."*, Concilio formal con las dos preguntas de Begoña (causalidad histórica + por qué le ha dado importancia al error) y el asentimiento de Karim de tres segundos largos que Begoña nota *"¿Te has portado bien? / No demasiado. Pero ella sí."*, y el apunte del Cuaderno cerrando el día con las dos lecciones articuladas. Material trazable preservado: García-Barberena/Unzu/Velaza *Epigraphica* 76 (2014), CIL II 2958-2960 anclando la forma *Pompelo*, calle Merced + excavaciones 2004-2005.

**Sustituciones diegéticas residuales**: ninguna. La voz de Karim como epigrafista revisor está cerrada por el guion canónico — no requiere validación adicional del comité.

**Anteriores entradas cerradas**: las dos entradas previas "Estación 2.1 — sustituciones diegéticas e inscripción ficticia (F2-1)" y "Brecha 2.1 jugable — catálogo + cableado al orquestador (F2-10a)" se sustituyen por esta entrada de cierre. La inscripción ficticia de "Licinio cónsul" + el repertorio de paralelos epigráficos de Pompaelo ya no aparecen en el código.

---

## Karim Belkacem — color de voz pendiente de migrar a `tintaTenue`

**Tracker doc 17**: no aplica (decisión visual del juego, no contenido histórico).

**Estado**: la voz `VozPersonaje.karim` en `voz_personaje.dart` lleva hoy `colorNombre: PaletaArchivo.textoPrincipal`. Karim es **Cronista del Archivo** (epigrafista revisor, doc 08 §2.1.2), no aspirante — alinearlo con el resto de Cronistas no-mentores (Andrés `tintaTenue`) sería lo coherente con la convención de la paleta provisional: ámbar para mentores institucionales (Isaura, Begoña, Aitor, Joana), tinta tenue para Cronistas técnicos cercanos (Andrés, Karim cuando se migre), texto principal para los aspirantes (Maren, Tasio, Sira) y voces íntimas familiares (Iratxe, Antonio, Naia, Eider en `tintaTenue` por el otro motivo: entorno no-institucional).

**Por qué no se cambia ahora**: el cambio rompería el test caracterización `los tres aspirantes (Maren, Tasio, Karim) llevan tinta principal` en `voz_personaje_test.dart`, que aún asume el modelo viejo donde Karim era aspirante. Hay que migrar en un slice dedicado: actualizar el test (sacar Karim del grupo de aspirantes, añadirlo a un nuevo grupo de Cronistas técnicos), cambiar el color, regenerar la entrada del Cuaderno si menciona el color.

**Pendiente**: slice corto de migración, no urgente. Hasta entonces, la docstring de `karim` ya documenta la inconsistencia.

---

## Brecha 2.2 jugable — Calagurris + Quintiliano (F2-10b)

**Tracker doc 17**: pendiente.

**Estado**: la segunda Brecha jugable del Arco 2 está implementada en `CatalogoBrechas.brecha22` y cableada al orquestador. Se dispara con `omisiones_quintiliano_estudiadas` (flag que la cinemática 2.2.4 *Lo que omite* activa al cerrar) y se interpone entre la 2.2.4 y la 2.2.5 *El Concilio en Calahorra* — ahora la 2.2.5 requiere `brecha_2_2_completada` en lugar del previo `escena_2_2_4_vista`. La 2.2.5 sigue siendo cinemática (videollamada con Aitor + voz de Begoña por mensaje) según el doc 08 §2.2.5; lo jugable es la mesa de trabajo previa donde Maren declara qué afirma la *Institutio Oratoria* directamente vs. qué se infiere de sus omisiones.

**Catálogo de la Brecha 2.2**:
- 4 fuentes diegéticas: pasajes seleccionados de la *Institutio Oratoria* (primaria, sesgo invisibilizador — núcleo pedagógico de HF.10 *detección de omisiones*), restos arqueológicos de Calagurris (primaria), comparación arqueológica Calagurris/Pompaelo (secundaria) y testimonio de una arqueóloga local (secundaria).
- 7 afirmaciones canónicas distribuidas pedagógicamente 4 Sólido + 1 Probable + 2 Disputado: la *Institutio Oratoria* es texto rico en datos directos sobre lo que Quintiliano dice (origen Calagurris, magisterio en Roma, mecenazgo de Vitorio Marcelo, autoridad pedagógica), pero la pedagogía clave de la Estación 2.2 — articulada por Aitor en la 2.2.5 — es declarar las inferencias **por omisión** como Probable o Disputado (la identidad cultural predominante de Quintiliano cuando escribe; las razones de su silencio sobre Calagurris; el peso real de Calagurris en su formación).
- `minimoAfirmacionesParaConcilio: 5` — declarar al menos 5 de 7 obliga a tocar al menos una de las inferencias sobre omisiones, no escaparse declarando sólo los 4 datos directos. El parámetro lo introduce F2-9.
- **HF.10 detección de omisiones — debut jugable**: el doc 02 lista HF.10 como habilidad de Análisis de Fuentes con perfil P2 (Detección F1). En la Brecha 2.2 hace su primera aparición jugable real — no como mecánica explícita "marca lo que falta" (que requeriría P2 funcional en core, hoy stub), sino como parte de la calibración Brier P4: las 3 afirmaciones por omisión (1 Probable + 2 Disputado) **son** la mecánica de detección de omisiones encarnada en el modelo de calibración existente. Cuando P2 entre en core con metadata por intento, se podrá medir HF.10 separadamente.

**Material trazable** (sin sustitución):
- **Quintiliano de Calagurris**: figura histórica documentada por su propia obra y por Suetonio. Los pasajes citados en el catálogo (autopresentación como hispano, omisión de detalles biográficos sobre Calagurris, mecenazgo de Vitorio Marcelo) están en la *Institutio Oratoria* y son trazables por capítulo. No se reproducen citas literales en latín.
- **Vitorio Marcelo y Galieno**: nombres históricos documentados como mecenas y dedicatarios de la *Institutio Oratoria*. La existencia del libro y el patronazgo son hechos históricos.
- **Cátedra de retórica de Vespasiano**: el establecimiento por Vespasiano de la primera cátedra de retórica latina remunerada en Roma, ocupada por Quintiliano, está documentado por Suetonio y por la propia obra. Trazable.

**Sustituciones diegéticas adicionales aplicadas en el catálogo**:
- **Restos arqueológicos de Calagurris**: descritos genéricamente como "fragmentos de cerámica, basas de columna, pavimentos de mosaico geométrico" en la sala romana del Museo de Calahorra (Calagurris Iulia Nassica). No se afirma yacimiento concreto ni pieza catalogada en CALA o en repertorios museísticos específicos. Calahorra tiene yacimientos romanos reales documentados, pero el dossier específico de la Brecha es selección diegética, no catálogo museístico real.
- **Sala dedicada del Museo Romano**: el Museo de la Romanización (Calahorra) existe; la "sala dedicada a Quintiliano" como dispositivo narrativo de la Brecha es presentación pedagógica, no necesariamente reflejo de la museografía actual de la institución.
- **Comparación arqueológica Calagurris/Pompaelo**: el dossier comparativo que la Brecha presenta (densidad de inscripciones honoríficas, vías, dotaciones) es composición pedagógica para el ejercicio. Calahorra y Pamplona/Pompaelo tienen registros arqueológicos parcialmente comparables, pero el cuadro específico no se reproduce de un estudio comparado real publicado.
- **Testimonio de la arqueóloga local**: figura ficticia diegética sin nombre histórico. Encarna la voz de la arqueología contemporánea local sin afirmar identidad concreta.

**Pendiente de revisión humana**:
- ¿La distribución 4 Sólido + 1 Probable + 2 Disputado encaja con la pedagogía que el doc 08 §2.2.4 / §2.2.5 prescribe para la Estación? El doc subraya que la lección clave es declarar lo que **se infiere de la omisión** como Probable/Disputado. La distribución actual da 3 niveles "no Sólido" (1P+2D) sobre 7 — un 43% del catálogo encarna la lección de omisión. Posible ajuste si el comité prefiere mayor peso (p.ej. 3 Sólido + 2 Probable + 2 Disputado).
- ¿La afirmación Probable única (`identidad_romana_predominante`) es la inferencia correcta a calibrar como Probable? El doc 08 §2.2.5 sitúa esta inferencia como ejemplo central de la lección de Aitor ("Quintiliano probablemente se sentía romano predominantemente cuando escribía, no calagurritano. Pero esto es **inferencia por omisión**, no afirmación textual"). Mantener Probable preserva la lección.
- ¿Las dos Disputadas (`razones_omision_calagurris`, `peso_calagurris_formacion`) son las preguntas correctas a marcar como genuinamente abiertas? Son las dos inferencias donde el silencio de la *Institutio* impide ir más allá: por qué omite Calagurris (¿pudor social? ¿estrategia retórica? ¿mero formato?) y cuánto peso tuvo Calagurris en su formación intelectual real. El doc 08 las sostiene como Disputadas explícitas.

**Cuando el comité valide**: se pueden citar pasajes literales de la *Institutio Oratoria* (con referencia al libro/capítulo), nombrar piezas concretas del Museo de la Romanización con su número de inventario, sustituir el dossier comparativo Calagurris/Pompaelo por estudios académicos publicados (si existen), y reemplazar el testimonio ficticio de la arqueóloga local por entrevista validada.

---

## Brecha 2.3 jugable — La domus de los mosaicos (F2-10c)

**Tracker doc 17**: pendiente.

**Estado**: la tercera Brecha jugable del Arco 2 está implementada en `CatalogoBrechas.brecha23` y cableada al orquestador. Se dispara con `comprender_sin_justificar_aprendido` (flag que la cinemática 2.3.4 *Comprender sin justificar* activa al cerrar — la lección epistémica de Isaura sobre la diferencia entre neutralidad y comprensión queda aprendida en 2.3.4) y se interpone entre la 2.3.4 y la 2.3.5 *Reconstrucción* (puesta en limpio narrativa) — ahora la 2.3.5 requiere `brecha_2_3_completada` en lugar del previo `escena_2_3_4_vista`. La Brecha jugable es donde Maren produce las 8 afirmaciones canónicas con calibración Brier (incluida la afirmación 6 *"Sólido (la ausencia)"* sobre las personas esclavizadas no nombradas — corazón pedagógico del Arco 2); la 2.3.5 cinemática reproduce narrativamente esas 8 afirmaciones como puesta en limpio dictada por Maren días después; la 2.3.6 *Concilio de la domus* (cinemática) cierra la Estación con la pregunta clave de Karim sobre por qué se declara una ausencia.

**Catálogo de la Brecha 2.3**:
- 4 fuentes diegéticas: la inscripción honorífica del propietario (primaria, sesgo oficialista — fuente epigráfica que registra al cabeza de familia varón con cargo cívico), la tablilla con cuentas domésticas (primaria, sesgo invisibilizador — registra a las personas esclavizadas como "servis II", número sin nombre), los restos materiales del yacimiento (primaria — cerámica, herramientas, fragmentos óseos animales, restos de combustión, mosaico geométrico), y la comparación con domus análogas hispanorromanas (secundaria, repertorio académico).
- 8 afirmaciones canónicas distribuidas pedagógicamente 5 Sólido + 2 Probable + 1 Disputado: la pedagogía de la Estación 2.3 es que cuando la fuente es rica para la élite que la produce y silenciosa para las personas que sostienen su mundo material, **la ausencia es información** — declararla como Sólido (la ausencia) es la operación clave del oficio. Las 5 Sólido cubren propiedad, propietario, número de esclavizados, **el silencio sobre sus identidades** (afirmación 6 con texto especial "Sólido (la ausencia)"), y mosaico fechado. Las 2 Probable cubren el nombre incompleto de la esposa y la vida cotidiana inferida de domus análogas. La 1 Disputado cubre la existencia de hijos no documentados directamente.
- `minimoAfirmacionesParaConcilio: 6` — declarar al menos 6 de 8 obliga a tocar al menos una afirmación no Sólido (las dos Probable o la Disputado), evitando que el jugador escape sólo con las cinco Sólido. Con 5 ya cubriría todo el "lado fácil" del catálogo y no se obligaría a entrar en las inferencias.

**El matiz "Sólido (la ausencia)"** vive en el `texto` de la `AfirmacionCanonica` `ausencia_nombrar_esclavizadas` (concretamente: *"...y este silencio no es accidente del registro: es estructura de la sociedad romana esclavista que producía las fuentes. Sólido (la ausencia)."*), NO como nivel nuevo del enum `NivelConfianza`. El jugador declara `NivelConfianza.solido` que es la calibración correcta (la ausencia documentada **es** Sólido); el matiz pedagógico ("la ausencia es información, no olvido neutro") es contenido textual de la afirmación que la pantalla muestra y el Concilio comenta — sin que el motor Brier lo interprete. Preserva la paridad Dart/PHP del core. Esta decisión está documentada también en la entrada *Pantalla de Reconstrucción jugable — preparada para Arco 2 (F2-9)*.

**Sustituciones diegéticas aplicadas en el catálogo** (no requiere validación adicional — la Estación 2.3 es ficción diegética declarada):
- **Familia Cornelia**: figura ficticia diegética del juego. La *gens Cornelia* es real (era una de las grandes gentes patricias romanas que produjo cónsules a lo largo del Imperio), pero la familia concreta de la domus de los mosaicos no se identifica con una familia Cornelia histórica documentada. La elección del nomen *Cornelia* preserva verosimilitud onomástica romana sin afirmar identidad histórica concreta.
- **"Cornelio magistrado, mediados del siglo II"**: figura ficticia diegética. El praenomen "perdido en la mutilación" de la inscripción es dispositivo narrativo deliberado para que el catálogo no afirme un nombre completo no validado.
- **Domus subterránea bajo Iruña**: modelo literario verosímil basado en domus romanas conocidas en yacimientos hispanorromanos (Mérida, Itálica, Empúries, Bilbilis), no una domus catalogada real bajo Pamplona. La capa romana de Iruña/Pompaelo está parcialmente documentada arqueológicamente; la domus específica de la Brecha es composición pedagógica.
- **"Servis II" en las cuentas domésticas**: formulación administrativa romana plausible (las tablillas latinas usan abreviaciones para inventarios y raciones), pero la tablilla concreta y su contenido específico son ficticios diegéticos.
- **Repertorio de domus análogas hispanorromanas**: el dossier comparativo es composición pedagógica para el ejercicio. Existen estudios académicos sobre domus hispanorromanas, pero el dossier específico de la Brecha no se reproduce de un repertorio real publicado.

**Material trazable preservado** (sin sustitución):
- La *gens Cornelia* es real como onomástica romana; nombrarla preserva verosimilitud sin afirmar familia concreta.
- La estructura general de una domus romana (atrio, cocina, archivo doméstico, mosaicos, personal esclavizado documentado en cuentas) está bien documentada arqueológica y filológicamente.
- La práctica de inscripciones honoríficas reutilizadas como peldaño en construcciones tardías es fenómeno arqueológico real y frecuente.
- La estructura social romana esclavista y la lógica administrativa que reduce a las personas esclavizadas a número es conocimiento histórico consolidado.

**Pendiente de revisión humana**:
- ¿La distribución 5 Sólido + 2 Probable + 1 Disputado encaja con cómo el doc 08 §2.3.5 detalla las "8 afirmaciones" de Maren? El doc canónico tiene exactamente esta distribución (1S+1S+1P+1D+1S+1S(la ausencia)+1S+1P para las 8 afirmaciones), que el catálogo reproduce fielmente.
- ¿La afirmación 6 *"Sólido (la ausencia)"* es lo bastante clara textualmente para que el jugador entienda que no es un nivel nuevo del enum sino un matiz interpretativo de Sólido? El texto incluye la frase literal *"Sólido (la ausencia)"* al final, replicando la convención del doc 08 §2.3.5 ("el 'Sólido (la ausencia)' lo escribe a mano, sin abreviar"). Posible mitigación adicional: añadir una entrada del Cuaderno de la Cronista que explicite la convención antes de la Brecha.
- ¿La distinción Concilio interno (jugable, mesa con Karim+Aitor+Isaura como revisores activos en la Brecha) y Concilio formal (cinemática 2.3.6 con la afirmación 6 articulada por Maren ante la pregunta de Karim) se preserva? La Brecha jugable cierra con la pantalla de Concilio actual del juego (feedback automatizado por rangos de score Brier); la 2.3.6 cinemática reproduce el diálogo canónico del doc 08 que sella la afirmación 6 explícitamente. Posible ajuste si el comité prefiere que el Concilio formal sea jugable en algún momento futuro.

**Cuando el comité valide**: se puede sustituir la familia Cornelia ficticia por una familia romana concreta documentada en epigrafía hispanorromana (si el comité considera que es preferible y tiene caso real verosímil), o mantener la ficción declarada. La domus subterránea puede sustituirse por una real catalogada o mantener el modelo literario.

---

## Brecha 2.4 jugable — Wamba contra los vascones (F2-10d)

**Tracker doc 17**: pendiente.

**Estado**: la cuarta y última Brecha jugable del Arco 2 está implementada en `CatalogoBrechas.brecha24` y cableada al orquestador. Se dispara con `silencio_es_dato_aprendido` (flag que la cinemática 2.4.5 *El silencio es el dato* activa al cerrar — Karim articula la lección epistémica clave del Arco 2: *"el silencio vascón es el dato. No es ausencia de dato"*) y se interpone entre la 2.4.5 y la 2.4.6 *Reconstrucción honesta* (puesta en limpio narrativa) — ahora la 2.4.6 requiere `brecha_2_4_completada` en lugar del previo `escena_2_4_5_vista`. Además, F2-10d retira el flag `brecha_2_4_completada` del cierre de la cinemática 2.4.7 *El Concilio dividido* (era provisional desde F2-7 cuando aún no había Brecha jugable; ahora ya lo activa la Brecha jugable antes incluso que la 2.4.6 se pueda ver). El test `Concilio 2.4.7 activa concilio_2_4_cerrado al cerrar` se ajusta para confirmar tanto la presencia de `concilio_2_4_cerrado` como la **ausencia explícita** de `brecha_2_4_completada` en el cierre de la 2.4.7.

**Catálogo de la Brecha 2.4** (catálogo más amplio del MVP):
- 4 fuentes (3 trazables + 1 explícitamente diegética sin nombre): la *Historia Wambae regis* de Julián de Toledo (primaria, sesgo oficialista — propaganda dinástica visigoda hagiográfica, fuente principal sobre la campaña), menciones en otras fuentes visigodas (primaria, sesgo oficialista — cronografía y legislación), yacimiento vascón del norte **deliberadamente sin nombre histórico** (primaria material, fuente muda), y comparación con campañas anteriores (Suintila, Recaredo) y posteriores (secundaria, marco académico).
- 9 afirmaciones canónicas distribuidas pedagógicamente 5 Sólido + 2 Probable + 2 Disputado (3 Sólido directos + 1 Sólido (la ausencia) + 1 Sólido como declaración metodológica): la pedagogía de la Estación 2.4 — la *"Brecha de un solo lado"* del encargo de Isaura en 2.4.1 — es que cuando la asimetría documental es estructural y no circunstancial, **la ausencia y el techo metodológico son declaraciones positivas del oficio**. Las 5 Sólido cubren la campaña en 673, la propaganda dinástica de Julián, la presuposición visigoda de "rebelión", la ausencia documental del lado vascón (afirmación 7 *"Sólido (la ausencia)"*) y el techo metodológico estructural de la reconstrucción (afirmación 9 *"Sólido como declaración metodológica"*). Las 2 Probable cubren el enfrentamiento militar localizable y la ausencia documental como estructura social. Las 2 Disputado cubren el estatus previo de los vascones y el alcance real de la "pacificación".
- `minimoAfirmacionesParaConcilio: 7` — declarar al menos 7 de 9 obliga a tocar al menos una afirmación no Sólido (las dos Probable o las dos Disputado), evitando que el jugador escape sólo con las cinco Sólido del catálogo (que cubren los datos visigodos y los dos Sólidos especiales) sin tocar las inferencias sobre el silencio.

**Material trazable preservado** (sin sustitución):
- **Wamba** (rey visigodo, reinado 672-680 d.C.) y la **campaña de 673 contra los vascones**: figuras y eventos históricos documentados. Trazables.
- **Julián de Toledo** y la ***Historia Wambae regis*** (también conocida como *Historia regis Wambae*): obispo y obra históricos documentados, con edición moderna disponible. La obra y su carácter hagiográfico-propagandístico son consenso académico. Se cita por su nombre canónico sin reproducir traducciones literales.
- **Aproximadamente 730 d.C. como datación de Julián**: cronología consensuada (Julián de Toledo escribió en torno a las décadas finales del s. VII; el "sesenta años después de los hechos" del juego es aproximación pedagógica que el doc 08 sostiene).
- **Suintila y Recaredo** como reyes visigodos anteriores con campañas registradas: figuras históricas documentadas. Las campañas recurrentes vasconas son consenso historiográfico.

**Sustituciones diegéticas residuales aplicadas en el catálogo**:
- **Yacimiento vascón del norte**: deliberadamente **sin nombre histórico** hasta validación del comité asesor. El doc 08 §2.4.3 explícitamente lo deja sin nombrar; el catálogo respeta esa decisión. La descripción ("estructuras de habitación modestas, fragmentos cerámicos hechos a mano sin torno, herramientas, ninguna inscripción propia") es modelo arqueológico verosímil para un asentamiento vascón del periodo, pero el yacimiento concreto — si existe uno catalogable que el comité valide para el juego — no se afirma.
- **Afirmaciones específicas sobre presuposiciones visigodas, "rebeldía", legitimidad**: la formulación textual de las 9 afirmaciones canónicas reproduce conceptualmente lo que el doc 08 §2.4.6 sostiene, sin afirmar como cita literal traducciones específicas de Julián que no se han validado lingüísticamente.

**Pendiente de revisión humana**:
- ¿La distribución 5 Sólido + 2 Probable + 2 Disputado encaja con la pedagogía que el doc 08 §2.4.6–2.4.7 prescribe? El doc tiene esta distribución exacta; el catálogo la reproduce fielmente. La afirmación 8 *(estructura social que produce la asimetría documental)* es **explícitamente Probable** según el doc 08 §2.4.7 — donde Joana (Anclada), Karim (Reformista) y Aitor (Constructor) convergen en Probable desde distintos lados ("exactamente lo que el oficio celebra"). Mantener Probable preserva la lección de las tres escuelas.
- ¿Las dos afirmaciones Sólido especiales (`ausencia_fuentes_vasconas` *Sólido (la ausencia)* y `techo_metodologico_reconstruccion` *Sólido como declaración metodológica*) son lo bastante claras textualmente para que el jugador entienda que no son niveles nuevos del enum sino matices interpretativos de Sólido? Los textos incluyen las frases literales al final, replicando la convención del doc 08 §2.4.6. Mismo patrón que la afirmación 6 de la Brecha 2.3.
- ¿Es razonable que la Brecha 2.4 cierre antes que la cinemática 2.4.6 *Reconstrucción honesta*? El doc 08 §2.4.6 reproduce las 9 afirmaciones que Maren produce en la mesa — la Brecha jugable es donde Maren las declara con calibración Brier, y la 2.4.6 es la puesta en limpio narrativa. Mismo patrón que 2.3 (Brecha jugable + 2.3.5 cinemática). El Concilio formal con cinco voces revisoras de la 2.4.7 sigue siendo cinemática (no jugable), preservando el contraste con el Concilio jugable de la Brecha. Posible ajuste si el comité prefiere otra disposición.

**Cuando el comité valide**: se puede dar nombre histórico al yacimiento vascón del norte (el comité podrá decidir si conviene un asentamiento real catalogable o mantener la abstracción diegética), citar pasajes literales de la *Historia Wambae regis* con referencia precisa, sustituir el marco comparativo genérico por estudios académicos publicados específicos, o mantener la formulación actual con la trazabilidad histórica que ya preserva (Wamba + 673 + Julián + propaganda dinástica visigoda).

---

## Mosaico M2 audio-guía — pantalla jugable (F2-11)

**Tracker doc 17**: pendiente.

**Estado**: la pantalla jugable del Mosaico del Arco 2 (`PantallaMosaicoArco2` en `lib/vista/pantalla_mosaico_arco_2.dart`) está implementada y cableada al orquestador. Reemplaza el flag provisional `mosaico_arco_2_entregado` que F2-8 había puesto en el cierre de la cinemática 2.4.8 — ahora la 2.4.8 sólo activa `aprendiz_dos_alcanzado` + `arco_2_estacion_4_cerrada` (este último es el flag de arco completado del M2), la `PantallaMosaicoArco2` se muestra entre la 2.4.8 y la cinemática `M2.entrega`, y al pulsar ENTREGAR LA AUDIO-GUÍA el orquestador (`_alEntregarMosaicoArco2`) activa `mosaico_arco_2_entregado` y encadena con la cinemática `M2.entrega` (ático del Archivo, Andrés con auriculares).

**Formato audio-guía** (doc 08 §M2): mientras el Mosaico del Arco 1 fue un *cómic mudo de 8 viñetas* con código de confianza visual por viñeta, el del Arco 2 cambia de soporte a una **audio-guía de aproximadamente 90 segundos**: 8 fragmentos pre-escritos de declaración leída en voz alta, cada uno marcado con código de confianza (Sólido / Probable / Disputado) por la Cronista. Los formatos son distintos a propósito: el M1 reconoce el oficio de **mirar**; el M2 reconoce el oficio de **decir** lo que se ha mirado. La audio-guía recoge la voz de Maren articulando declaraciones honestas, mezcladas, y Andrés (en `M2.entrega`) escucha y observa: *"has dicho 'no sabemos' tres veces. Y 'probablemente' cuatro" / "está perfecto"*. El reconocimiento del oficio bien hecho NO está en haber afirmado con certeza, sino en haber **declarado la incertidumbre con precisión**.

**Catálogo de los 8 fragmentos**: 2 fragmentos por cada Estación del Arco 2 (2.1, 2.2, 2.3, 2.4), anclados a las afirmaciones canónicas o fuentes de la Brecha correspondiente. Los fragmentos clave del oficio del arco articulan los matices "Sólido (la ausencia)" y "Sólido como declaración metodológica":
- 2.3 fragmento 2 (`domus_la_familia_que_no_aparece`): articula la afirmación 6 *Sólido (la ausencia)* sobre las personas esclavizadas no nombradas — *"Y este silencio no es accidente del registro: es estructura de la sociedad romana esclavista que producía las fuentes. Lo declaro sólido — sólido como ausencia."*.
- 2.4 fragmento 2 (`wamba_el_silencio_y_el_techo`): articula la afirmación 7 *Sólido (la ausencia)* sobre la ausencia de fuentes producidas por los vascones del periodo y la afirmación 9 *Sólido como declaración metodológica* sobre el techo estructural de la reconstrucción — *"La reconstrucción del lado vascón tiene un techo metodológico estructural — y eso lo declaro sólido. Como declaración metodológica."*.

**Mínimo de fragmentos para entregar**: 6 de 8 (mismo patrón que el M1). La Cronista puede dejar 2 fragmentos sin marcar (típicamente los de Estaciones que sintió menos suyas) y aún así entregar.

**Reutilización del repositorio del M1**: `RepositorioMosaico` ya era genérico por `idArco` desde su origen — se reutiliza tal cual con `MosaicoArco2.idArco = 'arco_2'`, persistiendo bajo la clave `nuevoser.lasversiones.mosaico.arco_2` (separada de `nuevoser.lasversiones.mosaico.arco_1` del M1, evita pisar marcas).

**Pendiente** (acoplado al cableado al companion en F2-12):
- Sincronizar el Mosaico M2 con `POST /companion/mosaicos` con `format='audio_guia_arco_2'` (paralelo al `format='comic_8_vinetas_confianza'` del M1). El orquestador prepara el espacio para encadenarlo en segundo plano tras la entrega local — mismo patrón que `_alEntregarMosaicoArco1` con `_sincronizarMosaicoEnSegundoPlano`. El sincronizador concreto del M2 entra en F2-12.
- La observación pedagógica de Andrés *"has dicho 'no sabemos' tres veces. Y 'probablemente' cuatro"* en la cinemática `M2.entrega` es texto fijo del doc 08 — no se computa dinámicamente contra las marcas reales de la Cronista. Si en el futuro se quisiera computar, habría que pasar el conteo de niveles del Mosaico al estado narrativo.

**No requiere validación humana adicional**: el formato audio-guía y los 8 fragmentos son composición pedagógica del juego que reproduce conceptualmente lo que el doc 08 §M2 describe. Las declaraciones de los fragmentos derivan textualmente de las afirmaciones canónicas de las 4 Brechas del arco (ya validadas o en BLOQUEOS individualmente). No se introduce material histórico nuevo ni cita literal de fuentes que no estén ya en el catálogo de las Brechas.

---

## Mosaico M2 — sincronización con `/companion/mosaicos` (F2-12)

**Tracker doc 17**: no aplica (acoplamiento técnico, no contenido histórico).

**Estado**: cableado. `lib/datos/sincronizador_mosaico.dart` añade la clase `SincronizadorMosaicoArco2` paralela a la `SincronizadorMosaicoArco1` (mismo diseño: opt-in, sin reintento automático, sin cola persistente, lee el token al construir el payload). El orquestador (`_alEntregarMosaicoArco2`) llama al sincronizador en segundo plano tras la entrega local — sin bloquear la cinemática `M2.entrega` que entra justo después. Si no hay token JWT, devuelve `SyncMosaicoSinToken` sin tocar red; si hay token y el backend responde 201, devuelve `SyncMosaicoExito`; los errores HTTP/timeout/socket caen en `SyncMosaicoError`.

El payload incluye:
- `game_id = 'las-versiones'` (el mismo que el M1 — sembrado en `ns_games` por `class-ns-esquema.php`).
- `arc_id = MosaicoArco2.idArco = 'arco_2'` (distinto del `'arco_1'` del M1; el backend los archiva como dos mosaicos separados).
- `format = 'audio_guia_arco_2'` (constante `formatoAudioGuiaArco2`, distinta de `formatoMosaicoV2 = 'comic_8_vinetas_confianza'` del M1; el adulto acompañante en la futura vista del cuidador podrá distinguir el formato y presentar la vista correspondiente).
- `required_anchors`: ids de los 8 fragmentos (todos llevan anclaje obligatorio en el M2 — la audio-guía ancla cada declaración a evidencia documental o material; en el M1 había una viñeta sin anclaje obligatorio, `cromlech_dialogo_con_sira`, pero el M2 no tiene equivalente).
- `fulfilled_anchors`: ids de los fragmentos marcados, ordenados alfabéticamente.
- `content_meta`: mapa `idFragmento → 'solido'|'probable'|'disputado'`.

**Pendiente humano**: igual que el M1, hace falta una pantalla de login para alimentar `RepositorioCuentaBackend` con un token JWT real. Hasta entonces el sincronizador del M2 se queda en `SyncMosaicoSinToken` cuando se llama tras la entrega — el Mosaico se preserva en local.

**No requiere bumpear el plugin WP**: el endpoint `POST /companion/mosaicos` ya acepta `format` como string libre (lo guarda crudo en LONGTEXT). No hace falta añadir `'audio_guia_arco_2'` a una lista de formatos válidos en PHP — el backend acepta cualquier string. La distinción de formato es responsabilidad del cliente que lee el mosaico (el cuidador en su vista futura, o el propio juego si añade una vista de "mis mosaicos").

---

## Pantalla de Reconstrucción jugable — preparada para Arco 2 (F2-9)

**Tracker doc 17**: no aplica (decisión técnica del motor de juego).

**Estado**: la pantalla `FaseReconstruccion` (`fase_reconstruccion.dart`) ya admite Brechas con cualquier número de afirmaciones canónicas — itera sobre `widget.brecha.afirmacionesCanonicas.length` y no hardcodea 3. El refactor F2-9 retira el `static const _minimoAfirmacionesDeclaradas = 3` interno y lo sustituye por `widget.brecha.minimoAfirmacionesParaConcilio` (campo nuevo del modelo `Brecha` con default 3). Cada Brecha decide su mínimo: las del Arco 1 (1.1–1.4, 4 afirmaciones canónicas cada una) usan el default 3; las del Arco 2 con catálogos más amplios podrán pedir 5+ (2.1: 6 afirmaciones; 2.2: 7; 2.3: 8; 2.4: 9). Test caracterización añadido: una Brecha con `minimoAfirmacionesParaConcilio=5` mantiene el CTA "AL CONCILIO" bloqueado hasta declarar 5 (no las 3 del default).

**Sobre los matices de Sólido del Arco 2**:
- Las afirmaciones de la 2.3 ("Sólido (la ausencia)" para la afirmación 6 sobre las personas esclavizadas no nombradas) y de la 2.4 ("Sólido (la ausencia)" para la afirmación 7 + "Sólido como declaración metodológica" para la afirmación 9 sobre el techo de la reconstrucción) **no requieren niveles nuevos del enum** `NivelConfianza`. El matiz vive en el `texto` de la `AfirmacionCanonica` — el jugador declara `NivelConfianza.solido` que es la calibración correcta, y el matiz pedagógico ("la ausencia es información", "esto es declaración metodológica del techo") es contenido textual que la pantalla muestra sin que el motor Brier lo interprete. La calibración Brier sigue siendo 3-clase (Sólido/Probable/Disputado), preservando la paridad Dart/PHP del core.

**Pendiente para Brechas jugables del Arco 2**:
- Catálogos `brecha21`, `brecha22`, `brecha23`, `brecha24` en `CatalogoBrechas` con sus fuentes diegéticas + afirmaciones canónicas calibradas contra el doc 08 — sustituciones diegéticas explícitas para el material no validado por el comité.
- Cada catálogo declarará su `minimoAfirmacionesParaConcilio` apropiado (probablemente 4 para 2.1 con 6 afirmaciones, 5 para 2.2 con 7, 5 para 2.3 con 8, 6 para 2.4 con 9).
- Hoy la pedagogía de las cuatro Estaciones del Arco 2 se enseña narrativamente en sus cinemáticas — cubre el contenido sin la mecánica jugable.

---

## Mosaico Arco 1 v2 — sincronización con `/companion/mosaicos` (P2)

**Tracker doc 17**: no aplica (acoplamiento técnico, no contenido histórico).

**Estado**: cableado. `lib/datos/sincronizador_mosaico.dart` instancia el endpoint `POST /companion/mosaicos` del companion. El orquestador (`_alEntregarMosaicoArco1`) llama al sincronizador en segundo plano tras la entrega local — sin bloquear la cinemática 1.M1.entrega que entra justo después. Si no hay token JWT, devuelve `SyncMosaicoSinToken` sin tocar red; si hay token y el backend responde 201, devuelve `SyncMosaicoExito`; los errores HTTP/timeout/socket caen en `SyncMosaicoError`.

El payload incluye:
- `game_id = 'las-versiones'` (sembrado en `ns_games` por `class-ns-esquema.php` — plugin WP v0.9.0).
- `arc_id = MosaicoArco1.idArco`.
- `format = 'comic_8_vinetas_confianza'`.
- `required_anchors`: ids de las 7 viñetas con anclaje obligatorio (todas excepto `cromlech_dialogo_con_sira` que es relacional).
- `fulfilled_anchors`: ids de las viñetas marcadas, ordenados alfabéticamente.
- `content_meta`: mapa `idVineta → 'solido'|'probable'|'disputado'`.

**Pendiente humano**:
- Cuando llegue la pantalla de login (memoria ítem 11 de El Cuaderno — auth de profesor/cuidador no decidida), las Versiones podrá guardar el token JWT y la sincronización deja de ser silenciosa. Hoy `_urlBaseBackend = 'https://nuevoser.example.org'` en `main.dart` es provisional — cambia con la decisión del dominio definitivo.
- Tests cubren los caminos críticos (sin token, 201, 500, timeout, socket, payload vacío) pero no hay piloto end-to-end contra un Local WP — bloqueado por la auth.

---

## Mosaico Arco 1 v2 — pregunta abierta y formulación de las viñetas (F8.7)

**Tracker doc 17**: pendiente de revisión humana.

**Guion canónico (doc 07 §M1, v0.1)**: el doc fue escrito asumiendo que el Arco 1 era sólo Aralar, así que la pregunta abierta del Mosaico es "¿Cómo era de verdad un día cualquiera en Aralar hace 6.000 años?" y los **5 anclajes obligatorios** (al menos 3 de 5) son todos del dolmen: dataciones C14 + análisis de polen + cerámica campaniforme + herramientas líticas + paisaje. Formato: cómic mudo de **8 viñetas**, cada una con código de color por confianza (azul Sólido / ámbar Probable / rojo claro Disputado).

**Estado**: implementado en F8.7 con generalización del v0.1 al arco ampliado del v0.2 (cuatro Estaciones).
- **Pregunta abierta sustituida**: "¿Cómo era de verdad un día cualquiera en Aralar hace 6.000 años?" → "¿Cómo se hace el oficio del cronista — qué he aprendido en este primer arco?". La nueva formulación cubre las cuatro Brechas (no sólo Aralar) y mantiene la apertura del original. La pregunta pedagógica sigue siendo la misma — qué se aprende del oficio en el arco — pero sin atar al lugar concreto que era el único cuando se redactó el v0.1.
- **8 viñetas pre-descritas**, 2 por Estación, cada una anclada a fuentes ya catalogadas en `CatalogoBrechas`:
  - 1.1 — `aralar_dolmen_visita` (anclajes: huesos in situ, lítico, informe antiguo, informe moderno) + `aralar_paisaje_y_toponimo` (anclajes: informe moderno, topónimo local).
  - 1.2 — `cromlech_banquete` (anclajes: cerámica fragmentaria, C14 única, lítico escaso) + `cromlech_dialogo_con_sira` (sin anclaje arqueológico — viñeta pedagógica de relación con un par).
  - 1.3 — `cueva_grabados_parietales` (anclajes: grabados in situ, comparativa otras cuevas) + `cueva_covacho_habitacion` (anclajes: covacho con carbones, informe excavación).
  - 1.4 — `irulegi_casa_y_enlosado` (anclajes: casa con escaleras, enlosado colapsado, cerámica mixta, armas) + `irulegi_la_mano` (anclajes: pieza, cartela museo dos lecturas, monográfico FLV 136).
- **Mínimo de viñetas marcadas para entregar**: 6 de 8. Equivale a la regla del v0.1 ("3 de 5 anclajes obligatorios") aplicada al nuevo conjunto: la Cronista puede dejar 2 viñetas sin marcar (típicamente las de la Estación que sintió menos suya) y aún así entregar.
- **Color de los códigos**: azul Sólido (`Color(0xFF7AAFD8)`), ámbar Probable (`PaletaArchivo.ambarLacre`), rojo claro Disputado (`Color(0xFFD08A82)`). Los tonos exactos quedan provisionales hasta cerrar la paleta del juego (doc 11) — anotados en la entrada existente DOC-11-PALETA.

**Pendiente de revisión humana**:
- ¿La sustitución de la pregunta abierta es aceptable? La nueva formulación es deliberadamente meta ("¿qué he aprendido del oficio?") en lugar de reconstructiva ("¿cómo era ese día?"). El guion v0.1 prefería la segunda — más imaginativa, más concreta. Posible alternativa: dejar que la Cronista elija una de las cuatro Estaciones como "el día" sobre el que reconstruye. Eso preservaría el espíritu del v0.1 dentro de un arco más amplio.
- ¿Las dos viñetas por Estación son las acertadas? Otras combinaciones posibles: en la 1.2 podría entrar la voz del Cuaderno con la "C14 sola" en lugar del diálogo con Sira; en la 1.4 la Mano podría ir sola y la otra ser una viñeta del Concilio.
- La viñeta `cromlech_dialogo_con_sira` no tiene anclaje arqueológico (es relacional). ¿Debe contar o no para el mínimo de marcadas? Hoy cuenta — la regla pide marcar 6 sin distinguir el tipo. Si el comité prefiere "al menos N de las que tienen anclaje", la regla cambia.
- Color de los niveles de confianza — provisional hasta cerrar doc 11.

---

## Mosaico Arco 1 — disparador del flag (cerrado en F8.6 y F8.7)

**Tracker doc 17**: el Mosaico es categoría no-atomizada (doc 15 §3) — los prompts actuales son provisionales y deberá revisarlos quien valide el material pedagógico cuando entren más Brechas al arco.

**Estado actual (tras F8.6)**:
- El catálogo del Arco 1 tiene las cuatro Brechas implementadas (1.1, 1.2, 1.3, 1.4). El disparador del Mosaico (`arco_1_completado`) se ha movido a su sitio canónico — se activa al cerrar la cinemática 1.4.4 ("Aprendiz I"), que es el cierre real del arco según el doc 07 §M1 ("Activa: tras 1.4, en los días siguientes").
- Los tres prompts del Mosaico (`que_te_llevas`, `que_te_queda`, `que_cambiarias`) **siguen hablando en singular del "dolmen"** — esto es contenido pendiente de F8.7. El doc 07 v0.2 §M1 prescribe un formato distinto: 8 viñetas con código de confianza (Sólido/Probable/Disputado) más feedback escrito a piezas seleccionadas, sustituyendo los 3 prompts de texto. Hasta que F8.7 reescriba la pantalla del Mosaico, los prompts singulares del "dolmen" siguen activos.

**Pendiente para F8.7**: reescritura completa de `pantalla_mosaico_arco_1.dart` al formato v0.2 — 8 viñetas con código de confianza por viñeta + feedback breve por viñeta seleccionada. Los `MosaicoArco1.flagDeArcoCompletado` y `flagDeMosaicoEntregado` se mantienen (sólo cambia el contenido visual y el repositorio de respuestas).

---

## Brecha 1.2 (crómlech) + cinemática 1.2.fin con Sira — fuentes diegéticas y cierre canónico (F8.4)

**Tracker doc 17**: pendiente de revisión humana.

**Guion canónico (doc 07 §1.2)**: Aralar segunda visita. Esta vez con **Sira Goizueta** (Aprendiz II Constructora, 15 años) en lugar de Isaura. Crómlech vecino, restos de banquete funerario sin enterramiento óseo claro, material muy fragmentado, una sola C14 disponible. Lección epistémica: cronología relativa sin datación absoluta sólida — **Probable** se vuelve protagonista. Conflicto entre Maren y Sira (Sira más rápida y menos cauta, Maren la frena). Concilio con Aitor como revisor — aprueba la versión cauta. Cierre: caminata de regreso con la línea "tenías razón / no siempre la tendré / ya, pero hoy sí" + voz del Cuaderno esa noche.

**Estado**: implementada en `CatalogoBrechas.brecha12` (5 fuentes diegéticas + 6 afirmaciones canónicas) + cinemática `EscenasArco1.cierreCromlechConSira` (1.2.fin). El flujo del orquestador queda:
- `1.B` ahora activa `cromlech_aralar_alcanzado` (antes activaba `arco_1_completado` directo, lo que adelantaba el Mosaico — corregido en F8.4).
- La Brecha 1.2 se dispara automáticamente, recorre las 5 fases jugables, cierra con `brecha_1_2_completada`.
- La 1.2.fin se reproduce como cinemática post-Brecha (mismo patrón que 1.1.7 tras la 1.1).
- La 1.B.1 latente, anclada a `brecha_1_2_completada`, se dispara después automáticamente.

**Sin sustituciones diegéticas en el contenido jugable**: las 5 fuentes catalogadas son explícitamente ficticias y diegéticas (cerámica fragmentaria, una sola C14, material lítico mínimo, informe comparativo, topónimo del círculo). No afirman C14 con cifra concreta, no atribuyen autoría real, no nombran publicaciones identificables.

**Pendiente de revisión humana**: voz de Sira (la línea "ya, pero hoy sí" debe encajar con el tono adolescente fijado en doc 04 — Sira como par de Maren, no como autoridad), el equilibrio de las 6 afirmaciones canónicas (¿demasiadas Probables? ¿la Disputada del C14 absoluto está bien calibrada?), y la decisión de no implementar cinemática introductoria 1.2.0 (Maren conociendo a Sira en el coche o en el campo). El doc 07 no detalla esa entrada — la Brecha arranca directamente cuando el orquestador la abre.

---

## Cinemática 1.4.4 "Aprendiz I" — sustituciones revertidas en F8.6

**Tracker doc 17**: pendiente de revisión humana.

**Guion canónico (doc 07 §1.4.4)**: cierre del Arco 1 en el patio del Archivo. Maren e Isaura solas tras el gran Concilio de la Estación 4. Validación amable, mención de los gestos de Begoña, anuncio del Arco 2 (Pompaelo). Aparece flotante "APRENDIZ I" — Maren asciende de rango.

**Estado**: implementada en `EscenasArco1.aprendizI`. Tras F8.6, la precondición pasa de `{brecha_1_4_completada}` a `{escena_1_4_3_vista}` — la Brecha 1.4 cierra antes que la cinemática 1.4.3 (gran Concilio), y la 1.4.4 se encadena tras la 1.4.3.

**Sustituciones revertidas en F8.6** (Brecha 1.4 ya implementada):
- "Reformularías sobre la violencia romana" — recupera su forma canónica. El doc 07 §1.4.3 (gran Concilio) articula explícitamente la matización (Karim pregunta a Maren si está minimizando la violencia romana, Maren reformula), así que la frase de Isaura tiene ahora su anclaje narrativo dentro del juego.
- "Otra Brecha sin haber visto la Mano y haber tenido que defenderte sobre ella" — recupera su forma canónica. El jugador ha trabajado la Mano en la fase jugable de la Brecha 1.4 y la ha defendido en el Concilio.

**Sustitución residual**:
- "El capitel del s. XII y el brocal del pozo" → "el capitel y el brocal del pozo" (entrada EDIFICIO-ARCHIVO, simétrica a la sustitución ya aplicada en 1.0.2). Sigue activa hasta que el comité valide los siglos.

**Pompaelo y la transición vascón → romano** se preservan en su forma canónica — Pompaelo está validada como entrada (ya aparece en 1.0.2) y la frase de Isaura ("lo que pudo haber sido un asentamiento vascón previo") declara explícitamente la incertidumbre, encajando con el oficio.

**Pendiente de revisión humana**: confirmación de que el patrón pedagógico de Begoña (sólo sonríe cuando el aprendiz reconoce sus límites o se compromete a reformular) se mantiene legible.

---

## Brecha 1.4 (yacimiento de Irulegi y la Mano) + 3 cinemáticas internas (F8.6)

**Tracker doc 17**: pendiente de revisión humana. La capa Irulegi/Mano está validada explícitamente en el header v0.2 del doc 07 (entrada YACIMIENTO-CELTIBERICO/VASCON) como yacimiento principal de la Estación 1.4 — Irulegi (Aranguren), datación de abandono ~70 a.C. en el contexto de las guerras sertorianas, Mano de Irulegi como pieza central. La Custodia (Viana) queda como mención narrativa para futuras Brechas, no aparece aquí.

**Guion canónico (doc 07 §1.4)**: 5-6 semanas tras inicio del juego. Maren visita el monte Irulegi con Isaura (1.4.1) — el arqueólogo del yacimiento la recibe, le explica las casas vascónicas tardías con escaleras de piedra, le anuncia el Concilio entero del día siguiente. Isaura le menciona la Mano (que verán por la tarde en el Museo de Navarra) y, con cuidado, la presencia de un perinatal cercano. La 1.4.2 cubre el día completo de trabajo: yacimiento por la mañana (casa con escaleras, enlosado romano colapsado, cerámica mixta, armas del ataque, huesos animales), Museo de Navarra por la tarde (la Mano + cartela con dos lecturas distintas + paneles de contexto). Voz larga del Cuaderno articulando la postura epistémica ante el debate académico abierto. Fase jugable de la Brecha 1.4 (recolección + evaluación + reconstrucción + concilio algorítmico). 1.4.3 reproduce el diálogo concreto del gran Concilio — preguntas de Aitor (afirmación 5), Joana (afirmaciones 8 y 9), Begoña (contacto vs romanización), Karim (sobrepeso simbólico de la Mano + violencia romana). Cierre con Begoña pronunciando "Aprendiz I". Marina aplaude sin protocolo. Maren sonríe.

**Estado**: implementada en `CatalogoBrechas.brecha14` (7 fuentes diegéticas + 9 afirmaciones canónicas — 5 Sólidas + 2 Probables + 2 Disputadas) + 3 cinemáticas en `EscenasArco1` (`viajeAYacimientoIrulegi`, `materialCongelado`, `granConcilio`). El flujo del orquestador queda:
- 1.4.1 se encadena con `escena_1_3_7_vista` (apunte largo del Cuaderno tras el primer Concilio formal de la 1.3).
- 1.4.2 se encadena con 1.4.1 y al cerrarla activa `material_irulegi_recogido`, que el catálogo reconoce como disparador de la fase jugable de la Brecha 1.4.
- Tras `brecha_1_4_completada`, el orquestador encadena 1.4.3 (gran Concilio narrativo) — la fase F6.5 jugable ya dio el feedback algorítmico; la 1.4.3 añade el contenido específico que el algoritmo no genera.
- Tras `escena_1_4_3_vista`, el orquestador encadena 1.4.4 (patio del Archivo, "Aprendiz I"), que activa `arco_1_completado` y dispara el Mosaico de fin de arco.

**Sin sustituciones diegéticas en el contenido jugable de la Brecha**: las 7 fuentes son ficticias y diegéticas en su descripción (no afirman C14 con cifra concreta ni autoría real para el material excavado), pero referencian la Mano de Irulegi por su nombre canónico — está validada en doc 17. La cartela del Museo de Navarra y el monográfico de **Fontes Linguae Vasconum 136 (2023)** son referencias **reales y trazables** — información pública verificable, no se diegetizan. Las 9 afirmaciones canónicas reproducen literalmente la calibración del doc 07 §1.4.3 (5 Sólidas + 2 Probables + 2 Disputadas).

**Sin sustituciones en el diálogo de la 1.4.3**: el Concilio reproduce literalmente el guion canónico. La voz de Joana (Anclada — distingue Disputado de "no establecido") y la de Karim (Reformista — pilla a Maren dos veces, sobre la Mano y sobre la violencia romana) se fijan aquí por primera vez con material narrativo largo. La frase pedagógica clave de Maren sobre la relación lengua vascónica/euskera ("Yo declaro Probable la relación porque es plausible. Pero declaro Disputada como afirmación metodológica porque el oficio honesto no me permite afirmarla con la rotundidad que algunas voces dentro y fuera del debate quieren") se reproduce intacta — es el corazón pedagógico del Arco 1.

**Decisión sobre el arqueólogo del yacimiento**: el guion canónico decide explícitamente no nombrar al arqueólogo en pantalla, sólo "el arqueólogo". La voz `VozPersonaje.arqueologo` lleva el `nombreVisible: 'Arqueólogo'` siguiendo la decisión.

**Pendiente de revisión humana**:
- Voces de Joana y Karim — primera aparición con material narrativo largo. ¿El tono encaja con la Bíblia de Personajes (doc 04, hoy aún sin entradas detalladas para ellos)?
- ¿La calibración de la afirmación 6 (la Mano como objeto apotropaico colgado en dintel) está bien como Probable? El doc 07 v0.2 propone Probable porque la función protectora se infiere por contexto de hallazgo + paralelos mediterráneos; el comité podría argumentar Sólido si los paralelos son robustos, o Disputado si el comité prefiere reservar el juicio.
- Tono de la voz del Cuaderno en la 1.4.2 — primera vez que el Cuaderno articula explícitamente la postura epistémica ("voy a tener que sostener la incertidumbre") en primera persona larga.
- Presencia narrativa del perinatal en la 1.4.1 — Isaura lo menciona "para que sepas" y el guion canónico cierra con "la Brecha no se centra en él". ¿La forma como Maren "se queda quieta" un segundo y dice "Vale" es suficiente respeto pedagógico? ¿O necesita un tratamiento más extenso en alguna entrada del Cuaderno?
- ¿La frase de Karim sobre el sobrepeso simbólico de la Mano ("ha sido mucho más que pieza arqueológica desde 2022") encaja con la prudencia del juego sobre afirmaciones políticas? El monográfico de Fontes Linguae Vasconum es público; el sobrepeso simbólico es observable.

---

## Brecha 1.3 (cueva del Pirineo) + 7 cinemáticas internas — sustituciones diegéticas (F8.5)

**Tracker doc 17**: pendiente de revisión humana. La capa Cueva-Pirineo está validada como entrada general en el doc 17 (datación canónica ~13.000 años, Magdaleniense), pero los nombres concretos del doc 07 v0.2 NO lo están: Alkerdi I (literaria), Berroberria, Barandiarán, Isturitz, Lezia, Lexotoa.

**Guion canónico (doc 07 §1.3)**: Maren visita una cueva paleolítica con Isaura tras tres semanas dentro del oficio. Cinco cinemáticas concatenadas (viaje al Pirineo → boca de la cueva → covacho de habitación → sala con grabados parietales → vuelta y silencio) que abren la fase jugable de la Brecha 1.3, seguidas de dos cinemáticas post-Brecha (primer Concilio formal con revisores académicos + apunte largo en el Cuaderno). Lección epistémica: cómo declarar **disputada** la afirmación clave (significado del arte parietal) sin caer en relativismo, y cómo formular "no podemos determinar con la evidencia disponible" frente a "no se sabe".

**Estado**: implementada en `CatalogoBrechas.brecha13` (5 fuentes diegéticas + 7 afirmaciones canónicas) + 7 cinemáticas en `EscenasArco1` (`viajeAlPirineo`, `laBocaDeLaCueva`, `dentroDeLaCueva`, `laPared`, `vueltaYSilencio`, `elPrimerConcilioFormal`, `elApunteLargo`). El flujo del orquestador queda:
- 1.B.1 (latente desde F8.2) ahora se dispara automáticamente al cerrar la Brecha 1.2 — su `flagDeSalida` (`escena_1_b1_vista`) actúa como precondición de 1.3.1.
- 1.3.1-1.3.5 se encadenan por `flagDeSalida` y al cerrar 1.3.5 se activa `cueva_pirineo_visitada`, que el catálogo reconoce como disparador de la fase jugable de la Brecha 1.3.
- Tras `brecha_1_3_completada`, el orquestador encadena 1.3.6 (Concilio formal) y 1.3.7 (apunte largo), y luego la 1.C (latente desde F8.2).

**Sustituciones diegéticas aplicadas**:
- **Yacimiento concreto**: el doc 07 v0.2 caracteriza la cueva como "Alkerdi I literaria, modelo verosímil basado en lo real". El código no nombra ningún yacimiento real — la cueva queda diegética. Los nombres del v0.2 (Alkerdi, Berroberria, Isturitz, Lezia, Lexotoa) no aparecen en código.
- **Investigador**: "Barandiarán" (nombre real con peso historiográfico) sustituido por "equipos académicos de varias generaciones" / "un equipo académico de prehistoria". La pedagogía (informes con vocabulario hoy revisado, reinterpretación posible a la luz de campañas más recientes) se preserva.
- **Datación C14 específica**: el guion 1.3 v0.2 menciona dataciones concretas. Sustituidas por "Magdaleniense Inferior o Medio (~13.000 años antes del presente)" — rango canónico ya validado en doc 17 para la capa, sin laboratorio ni publicación específica.
- **Significado del arte parietal**: la afirmación canónica clave (`significado_arte_parietal`) se formula como **Disputada** con el texto "Podemos determinar con la evidencia disponible el significado del arte parietal magdaleniense" — formulación deliberadamente ambigua que el jugador debe rechazar ("no podemos") al asignarle nivel Disputado. Lección pedagógica del doc 07.

**Sin afirmar contenido sobre vivencias o creencias** de las personas paleolíticas (prohibición del CLAUDE.md): la sala con grabados se describe en términos materiales (luz natural no llega, técnica de grabado, paralelismos estilísticos), las afirmaciones canónicas no asumen función simbólica concreta, y la afirmación `autores_grabados_y_covacho` (¿son las mismas personas que habitaron el covacho contiguo?) está calificada como **Disputada**, no afirmando identidad.

**Pendiente de revisión humana**: 
- ¿La afirmación `luz_artificial` debe ser **Probable** o **Sólida**? (Hoy es Probable porque inferimos la lámpara/antorcha por ausencia de luz natural; el comité puede argumentar que la inferencia es lo bastante directa para Sólido.)
- ¿La afirmación `losas_sellaron_posteriormente` está bien calibrada como **Probable**? (Hoy lo es porque "técnica y desgaste" sugieren posterioridad sin confirmarla; ¿es suficiente o debería ser Disputada?)
- Tono de Joana en la 1.3.6 — primera revisora académica de Maren, voz aún no fijada en doc 04 (apuntada en Bíblia de Personajes pero sin entrada propia).
- ¿Aitor encaja como guía del Concilio formal en 1.3.6? El doc 07 v0.2 lo nombra; voz pendiente de fijar.

**Cuando el comité valide los nombres**: revertir Barandiarán + nombrar el yacimiento concreto si se valida + opcionalmente añadir cifra de C14 con su laboratorio si el comité aporta referencia.

---

## Cinemática 1.Z del cierre del arco — implementada en F8.8

**Tracker doc 17**: pendiente de revisión humana.

**Guion canónico (doc 07 §1.Z)**: la noche de la entrega del Mosaico. Maren en su mesa con el cuaderno, ventana al castaño con hojas amarillas (noviembre). Voz interna que cierra el arco: ha entregado el Mosaico, Andrés le ha dicho que la mayoría no se atreve a marcar roja la viñeta del banquete, Marina dice que ya es del club, ha aprendido cosas, Eider le dijo que tiene cara rara últimamente, el lunes empieza el Arco 2 (Pompaelo, debajo de la calle Curia, foro romano). "No sé qué voy a encontrar. Pero tengo ganas." Maren cierra el cuaderno, apaga la luz. Aparece "ARCO 1 — CERRADO". Continuará en Arco 2.

**Estado**: implementada en `EscenasArco1.cierreDelArco`. Se dispara automáticamente tras la cinemática 1.M1.entrega (Andrés + Marina). Al cerrarla activa `arco_1_cerrado_por_la_cronista`.

**Sustitución diegética aplicada (única)**:
- "He visto manos pintadas hace catorce mil años" → "He visto grabados en la roca de hace trece mil años — bisontes, un ciervo, un caballo". El v0.1 del guion asumía una Estación 1.3 con manos en negativo del Auriñaciense; el v0.2 reescribe la 1.3 a fauna magdaleniense grabada (~13.000 años, validado en doc 17 para la capa Cueva-Pirineo). La sustitución alinea la voz del Cuaderno con lo que Maren ha visto en el juego implementado.

**Sin más sustituciones**: las referencias a la viñeta del banquete (la del crómlech vecino, calibrada como Probable o Disputada en la Brecha 1.2 — la afirmación 4 `banquete_ritual` está calificada como Disputada en el catálogo, encajando con el "no se atreve" de Andrés), a Marina ("ya soy del club" — coherente con el aplauso fuera de protocolo en la 1.4.3), a Pompaelo bajo la calle Curia (validado en 1.0.2), y a Eider (personaje ficticio del entorno cotidiano, doc 04) se preservan literalmente.

**Pendiente de revisión humana**:
- Tono de la voz íntima del Cuaderno cerrando el arco — primera vez que el Cuaderno articula explícitamente la postura "no sé qué voy a encontrar pero tengo ganas". ¿Encaja con el oficio que el juego enseña? Funciona en clave pedagógica (curiosidad sin certeza), pero el comité podría leerlo como demasiado ligero.
- Línea final "Continuará en Arco 2 — La llegada de las palabras" — reproduce el subtítulo del Arco 2 del doc 07 v0.1, pendiente de confirmar con doc 08 cuando se aborde.

---

## Cinemáticas latentes 1.B.1 y 1.C — ancladas a Brechas no implementadas (F8.2)

**Tracker doc 17**: pendiente de revisión humana.

**Guion canónico (doc 07)**:
- 1.B.1 "Conversación con el padre" — cocina familiar, ~10-12 días tras cerrar la Estación 2. Antonio le devuelve a Maren su propia frase ("el oficio cuenta las cosas como pasaron") corregida ("no es como pasaron"); Maren llega sola a "como pueden haber pasado, con la mejor honestidad posible".
- 1.C "Naia pregunta" — cena familiar tras la Estación 3. Naia pregunta a Maren si los huesos viejos le dan miedo. Maren contesta "porque eran personas".

**Estado**: implementadas en `EscenasArco1` con `flagsRequeridos: {brecha_1_2_completada}` y `{brecha_1_3_completada}` respectivamente. Como las Brechas 1.2 y 1.3 no están todavía en el catálogo del juego, **el orquestador no las disparará** — quedan latentes en el catálogo, listas para activarse automáticamente cuando entren las Brechas correspondientes. Mismo patrón que mantuvo la 1.1.7 mientras la Brecha 1.1 era esqueleto.

**Sin sustituciones diegéticas aplicadas**: las dos cinemáticas no nombran fechas, lugares, autores ni dataciones específicas — el contenido del guion canónico se preserva tal cual.

**Pendiente de revisión humana**: confirmación de que el tono de Maren articulando la postura epistémica del oficio en 1.B.1 ("como pueden haber pasado, con la mejor honestidad posible") encaja con la voz fijada en doc 04, y de que la respuesta humanizadora a Naia en 1.C ("eran personas") no entra en colisión con la prohibición de afirmaciones sobre vivencias o creencias de poblaciones prehistóricas — la frase humaniza al sujeto histórico sin afirmar nada sobre cómo se sentían respecto a su muerte.

---

## Cinemáticas 1.A y 1.B — sustituciones diegéticas aplicadas (F8.1)

**Tracker doc 17**: pendiente de revisión humana.

**Guion canónico (doc 07)**:
- 1.A "La merienda con Eider" — cafetería del Casco Viejo, ~3 días después del cierre de la Estación 1. Diálogo natural sobre cómo le fue el dolmen. Eider es personaje ficticio del juego.
- 1.B "El ático" — Maren sube al ático del Archivo a buscar un informe; Andrés le hace una pregunta clave sobre cómo trata fuentes con sesgo. Activa `arco_1_completado` al cerrar (se mueve a 1.4.4 cuando entren las Estaciones 1.2-1.4 al catálogo).

**Estado**: implementadas con sustituciones diegéticas que preservan la pedagogía sin afirmar contenido histórico no validado. Las dos cinemáticas se reproducen en orden tras la 1.1.7 y antes del Mosaico, siguiendo el flujo del doc 07.

**Sustituciones aplicadas (registradas también en las entradas PIO-BELTRAN y ARALAR-DATACIONES)**:
- 1.A: "las dos dataciones" → "las dos fechas que no terminan de cuadrar" (no afirmar laboratorio o autor C14).
- 1.B: "el informe de Beltrán de 1973" → "el informe antiguo del dolmen"; "¿qué te parece Beltrán?" → "¿qué te parece el informe?" (no afirmar autoría hasta validación del comité).

**Pendiente de revisión humana**: voz de Eider (adolescente bilbaína-pamplonica del entorno de Maren — ¿el tono encaja con cómo se quiere retratar a esa generación en la Colección?), tono de Andrés en su pregunta a Maren (¿la pregunta debe sonar a "examen" o a "conversación entre colegas"?), y confirmación de que el reconocimiento mínimo de Andrés ("vas bien") encaja con la voz fijada en doc 04. Si el comité valida el apellido Beltrán + las dataciones, el contenido del 1.B + 1.A se puede revertir al canónico sin tocar la estructura.

---

## Doc 11 — paleta visual del juego pendiente de cerrar

`paleta_archivo.dart` es **provisional** — sepia/papel/tinta + ámbar
lacre. Cuando se cierre el doc 11 (guía visual del Archivo), se
revisan colores de personajes, ambientes y UI.

---

## Atmósferas fotográficas — coberturas pendientes

A partir de F2-22 las cinemáticas usan fotos libres de Wikimedia
Commons como fondo atmosférico (capa al ~45% de opacidad, veladura
oscura encima). 18 ficheros cubren ~30 ambientes. Quedan huecos
donde sigue el motivo procedural — apuntados como mejoras pendientes
para evaluar cuando entre la fase visual del juego (doc 11):

- ~~**Coches en viaje** (`coche_isaura`, `coche_aitor`, `coche_marina`).
  Sin foto. El procedural neutro (gradiente radial sutil) cumple,
  pero podría mejorarse con un interior de coche en movimiento /
  paisaje a través de ventana lateral.~~ **Cerrado en F2-29** con un
  motivo procedural específico `interiorCoche` (ventanilla lateral
  derecha con marco ámbar + horizonte tenue + tres cumbres lejanas
  + cuatro postes verticales sugiriendo paisaje desplazándose). No
  reemplaza una foto real, pero diferencia ya visualmente el coche
  del resto de espacios neutros. Si llega fase visual con
  presupuesto, se puede sustituir por foto encargada/stock sin
  romper el call-site.

- **`yacimiento_vascon_norte`**. Deliberadamente sin lugar concreto
  por validación pendiente del comité asesor (la Estación 2.4
  trabaja con un yacimiento vascón altomedieval del norte sin nombre
  histórico hasta que el comité valide candidato). Wikimedia no
  cubre bien "yacimiento vascón altomedieval anónimo" — se queda en
  procedural `paisajeMontana` hasta validación. Cuando el comité
  elija el yacimiento concreto, se descarga foto del lugar real.

- **`iglesia_san_cernin`**. Hoy usa la Plaza Consistorial de
  Pamplona como sustituto (la iglesia tiene torres altas y todas
  las tomas en Commons son verticales). Si aparece foto horizontal
  de la fachada de San Saturnino con calidad suficiente, sustituir.

- **`cuarto_casa_maren`**. Hoy usa un dormitorio de la Casa-Museo
  de Manuel de Falla — funciona bajo el velo pero no es literal de
  cuarto de adolescente con escritorio. Mejora pendiente si entra
  fase visual con presupuesto para foto encargada o ilustración.

- **Avatares de personaje**. ~~Hoy procedurales (CustomPainter con
  inicial + color + estilo de borde por estamento)~~ **F2-30 abre el
  modo ilustrado dual**: `AvatarPersonaje` ahora soporta retrato
  ilustrado por voz vía mapping `_avataresIlustrados` indexado por
  `nombreVisible`. Las voces con PNG/JPEG en `assets/personajes/`
  más entrada en el mapping pasan al modo `Image.asset` recortada
  con `ClipOval` y borde por estamento superpuesto. Las voces sin
  retrato siguen cayendo al procedural sin tocar nada del
  call-site. Generadas con OpenAI ChatGPT (DALL-E 3) bajo prompts
  coherentes con la PaletaArchivo (acuarela sepia + halo ámbar
  lacre). Migración progresiva: 4 retratos cableados de inicio
  (Maren, Isaura, Aitor, Karim); el resto siguen procedurales hasta
  que se generen y se añada una sola línea al mapping. Atribución y
  política de licencias en `PantallaCreditos`. Pendiente todavía:
  (a) generar y cablear los 12 personajes restantes de la rejilla
  maestra `assets/personajes/master/todos.png`, (b) validación
  pedagógica humana de cada retrato (ningún parecido identificable
  con persona real), (c) si en algún momento llega ilustración
  humana encargada, sustituir reemplazando los JPEG sin tocar
  código.

- ~~**Atribuciones GFDL adicional en `cueva_pindal.jpg`**. La foto
  del Pindal está doble-licenciada CC-BY 3.0 + GFDL 1.2+. La
  PantallaCreditos sólo nombra CC-BY 3.0~~ **Cerrado en F2-29**: la
  ficha de la cueva del Pindal en `PantallaCreditos` ahora declara
  `CC-BY 3.0 / GFDL 1.2+` con nota explicativa *"Imagen
  doble-licenciada por su autor: cumple bajo cualquiera de las dos
  licencias"*. El inventario de `CREDITOS.md` ya reflejaba la doble
  licencia.



## Arco 4 — sustituciones diegéticas activas (F2-32)

El Arco 4 entero (`escenas_arco_4.dart` + `catalogo_brechas.dart`
brechas 4.1 y 4.B + `mosaico_arco_4.dart`) reproduce el doc 10 v0.1
con sustituciones diegéticas en los puntos no validados por el comité
asesor histórico. La estructura jugable y la pedagogía (Aprendiz III
avanzado donde la Cronista determina el sujeto + caso pequeño como
ventana a la cotidianidad + doble cartela paralela como Mosaico
integrador del MVP) están preservadas; cuando el comité valide se
ajustan los nombres y detalles concretos sin tocar la estructura.

### REFORMULACION-1512 — final del Arco 4 reformulado por el comité provisional

El comité asesor provisional propuso en sesión del 29 abril 2026
(documentada en `coleccion-nuevo-ser-paquete-documental-v0.3/cambios-pendientes-v0.3/`)
una reformulación del final del Arco 4: añadir Estaciones 4.4 (La
conquista) + 4.5 (La guerra) + 4.6 (Amaiur), nuevo Concilio de
graduación a Cronista (4.Z.1-4 con defensa metodológica frente a
Karim, presentación de los siete territorios herederos, pregunta
final de Begoña), y reescritura del 4.A.2 *"para cuando seas mayor"*
+ 4.H.1/4.H.2 + 4.Z. La implementación actual sigue el doc 10 v0.1
*vigente* hasta consolidación: el cierre del MVP es la cinemática
4.Z (`elPatioVacio`) según doc 10 v0.1. Cuando se consolide la
reformulación, las cinemáticas 4.A.2, 4.H.1, 4.H.2 y 4.Z se
sustituyen y se añaden las cinco cinemáticas nuevas
(4.4 + 4.5 + 4.6 + 4.Z.1-4) sin tocar las Estaciones 4.1, 4.A.1,
4.B y los días-Archivo 4.C/D/E/F/G ya implementados.

### JOANA-DE-RONCAL — Brecha 4.1 jugable (Aprendiz III avanzado)

Material trazable preservado: palacio de Olite real, Carlos III el
Noble + Leonor + las cuatro infantas (Juana, María, Beatriz, Blanca)
como personajes históricamente documentados, valle de Roncal real,
prácticas administrativas de cortes peninsulares del s. XV
documentadas, edad típica de entrada al servicio de doncella de
cámara, prácticas matrimoniales del estamento (mayoría se casaba
antes de los veinticinco), terminación frecuente del servicio por
matrimonio o muerte joven.

Sustituciones diegéticas declaradas: **Joana de Roncal como persona
concreta es figura ficticia diegética** — los detalles de su
biografía (entrada al palacio en 1402 con dieciocho años, servicio
sucesivo a Leonor y Blanca, viaje a Tudela 1405 y a Estella, gasto
de tela de 1408, desaparición de los registros en 1412, mención de
"limosnas a la familia de Roncal por la pérdida de su hija") son
modelo literario verosímil construido como composición pedagógica a
partir de tipos documentales reales del periodo. "Pedro de Roncal"
como hermano que paga el viaje al palacio en 1402 también ficticio.

Cuando el comité valide o sustituya por figura real documentada
(p. ej. Marina de Sagasti — doncella de cámara real de la corte de
Carlos III según la nómina de palacio publicada por Castro Álava en
*Catálogo del Archivo General de Navarra*, sección Comptos —, o
Beltrana de Echauz, o cualquier otra figura concreta de las nóminas
de palacio realmente documentadas), se sustituyen el nombre, las
fechas y los detalles concretos sin tocar la estructura jugable
(8 afirmaciones canónicas con distribución 5S + 2P + 1D, las dos
Probables — apellido del valle + familia hidalga modesta — la
Disputada — el gasto de tela de 1408 con tres lecturas plausibles —
y el mínimo 6 para Concilio).

### PARED-MEDIANERA-1394 — Brecha 4.B jugable (caso pequeño como ventana)

Material trazable preservado: Estella/Lizarra real, modelo de
villa-Camino con tres comunidades documentadas (cristiana,
mudéjar/musulmana, judía) en el s. XIV, prácticas jurídicas de
pleitos por paredes medianeras como tipo documental real del
periodo bajomedieval peninsular, responsa rabínicos como género
jurídico real producido por juristas judíos del s. XIV-XV con
identidades nominalmente documentadas en el corpus, marcos jurídicos
compartidos entre comunidades como patrón general triangulable en
los estudios académicos contemporáneos.

Sustituciones diegéticas declaradas: el pleito concreto y los
nombres "Pedro Garaicoa" (cristiano), "Yusuf al-Tudelí" (mudéjar) y
"Mohammed" (testigo mudéjar) son figuras ficticias diegéticas —
modelo literario verosímil construido a partir de tipos documentales
reales (pleitos por paredes medianeras conservados en archivos
municipales peninsulares del periodo). Las cinco Sólidas del
catálogo (pleito documentado, Yusuf acude al tribunal cristiano sin
objeciones, testigo mudéjar bajo juramento mudéjar respetado,
cristianos no descalifican por religión, veredicto parcialmente
favorable a Yusuf con cumplimiento sin apelaciones) reproducen el
patrón estructural del género documental real; sólo los nombres y
la fecha concreta son ficticios. La afirmación 7 (vecindad funcional
con tensiones como caracterización general inferida) y la 8 (el
caso pequeño como afirmación metodológica del oficio) se anclan
adicionalmente en los responsa rabínicos y los estudios secundarios
sobre convivencia en villas peninsulares del periodo.

Cuando el comité valide o sustituya por pleito real documentado
(p. ej. los pleitos del *Libro Rubro* del Concejo de Estella, o las
sentencias del tribunal municipal de Tudela conservadas en el
Archivo Municipal, o los pleitos con testigo judío recogidos en los
*Responsa* de Solomon ben Adret o Isaac bar Sheshet — RIBASH —),
se sustituyen los nombres, la fecha concreta y la materia disputada
sin tocar la estructura jugable (8 afirmaciones canónicas con
distribución 5S + 2P + 1S metodológica, la metodológica vive en el
texto preservando la paridad Dart/PHP del core, mínimo 6 para
Concilio).

### MOSAICO-M4 — doble cartela paralela como proyecto integrador

Material trazable preservado: el primer dolmen de Aralar como pieza
de la Brecha 1.1 (sustituciones residuales del Arco 1 ya registradas
bajo ARALAR-DATACIONES) y el ara funeraria romana de Pompelo como
pieza de la Brecha 2.1 (sustitución POMPAELO-INSCRIPCION ya validada
en F2-17 con el ara real de Aelio Attiano publicada en *Epigraphica*
76 (2014) por García-Barberena/Unzu/Velaza).

Las dos cartelas paralelas reproducen fielmente las observaciones de
Maren a lo largo del MVP sobre las dos piezas (procedencia, datación,
lengua, función original, reutilización, lo que la pieza dice). Las
datacioness aproximadas y atribuciones específicas siguen el patrón
de sustituciones diegéticas registrado para cada Brecha
correspondiente — las afirmaciones del Mosaico no introducen material
nuevo sin validar, sólo articulan en formato museográfico lo que las
Brechas jugables ya produjeron. Por tanto el M4 cierra cuando se
cierran ARALAR-DATACIONES + POMPAELO-INSCRIPCION (esta última ya
cerrada en F2-17).
