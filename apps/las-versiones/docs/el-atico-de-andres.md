# El ático de Andrés: oficios del Archivo y encargos

> Plan de diseño, 2026-09-24. Borrador para revisar antes de construir.
> Equivalente en Las Versiones de las máquinas de Rexán
> (`apps/uno-roto/docs/maquinas-segunda-sala.md`), pero **no es una copia**: las guías
> visual (doc 11) y sonora (doc 12) de Las Versiones son mucho más estrictas que las de
> Uno Roto, y eso cambia el arte, la música y el ritmo.
>
> Estado de partida: 13 Brechas jugables (arcos 1-4, faltan 3.2 y 3.6 por validación).
> Las Versiones **todavía no registra maestría** (ningún archivo de `lib/` usa el motor)
> y **todavía no reproduce audio** (F2-27 dejó solo las preferencias por perfil).

## 0. Reglas que valen para todos los oficios

1. **Repasan, no enseñan.** Un oficio del ático se abre cuando la Cronista ha cerrado la
   Brecha cuyos materiales usa (flag de completado de la Brecha). Trabaja con las fuentes
   y afirmaciones que *ella ya ha tenido en la mano*.
2. **Cero contenido histórico nuevo en la primera tanda.** Los oficios de la tanda 1 solo
   reutilizan `Fuente`, `PropiedadesFuente` y `AfirmacionCanonica` de
   `catalogo_brechas.dart`, que ya tienen su propio estado de validación. Todo lo que añada
   hechos, fechas o textos nuevos pasa por el comité (doc 16) y queda en la tanda 2 o 3.
3. **Nunca humillar.** Sin puntos, vidas, cronómetro, récords ni «game over». Un error
   muestra por qué y se sigue. Bermellón solo para errores reales, y muy poco (doc 11 §2.2).
4. **Premiar juzgar bien, no acertar.** Es la misma regla que el Concilio. En los oficios
   de calibración, decir «Disputado» cuando es Disputado vale tanto como acertar un Sólido.
5. **Maestría honesta.** Solo registran las decisiones con respuesta clara y el primer
   intento. Hasta que se cablee el motor (§6) los oficios funcionan sin registrar nada.
6. **Cierre amable.** Cada visita dura 2-3 rondas y acaba con una frase de Andrés y un solo
   botón para volver. Nada de «una más».
7. **La interfaz es un objeto** (doc 11 §1.1.9). No hay botones de software: hay una mesa,
   pinzas, bandejas y fichas. Si algo parece un menú de videojuego, está mal.

**Anfitrión: Andrés Vidaurre**, archivero técnico, en el ático de las vitrinas
(doc 04: humor seco, cercano, gafas en la cabeza). Es a Las Versiones lo que Rexán es a
Uno Roto. No es Cronista y no evalúa: «yo solo guardo las cosas; tú sabrás qué dicen».

**Acceso:** un nodo nuevo, «El ático», en el menú del Archivo, que aparece después de la
Brecha 1.1. Cada oficio es un objeto del ático (una cuerda con pinzas, una mesa de luz, una
balanza). Lo que todavía no se ha abierto está tapado con una sábana: no hay candado ni
contador de lo que falta.

---

## 1. Tres fichas *(prioridad 1: el corazón del juego)*

- **Habilidades:** AH.03 (P4), repaso de AH.02 y AH.07.
- **Objeto:** una balanza de platillos sobre la mesa y tres bandejas de mimbre rotuladas a
  mano: **Sólido**, **Probable** y **Disputado**.
- **Contenido:** `AfirmacionCanonica.calibracionCorrecta` de las Brechas ya cerradas.
  **No hay que escribir nada nuevo.**

**Pantalla.** Andrés saca de una caja tarjetas de afirmaciones de investigaciones
anteriores. Cada tarjeta lleva debajo, cosidas con hilo, las fuentes que la anclan
(`idsFuentesAnclaje`), que se pueden abrir. Hay que arrastrar la tarjeta a su bandeja.

**Rondas.**
1. Afirmaciones de **una sola** Brecha cerrada, con sus fuentes a la vista.
2. Mezcla de dos Brechas de capas distintas. Aquí se ve si el criterio se mantiene al
   cambiar de época.
3. *La tarjeta suelta:* una afirmación sin sus fuentes cosidas. Antes de clasificarla hay
   que ir a buscar sus anclajes al cajón. Esta ronda no puntúa: es para entrenar el hábito
   de mirar antes de juzgar.

**Devolución.** No hay acierto ni fallo en rojo. Al terminar, la balanza se inclina hacia
**sobreconfianza** o hacia **timidez** según las tarjetas que se hayan desviado, y Andrés
comenta una sola de ellas: «Esta la pusiste en Sólido. Tiene una fuente, y es de hace
cincuenta años. Yo la dejaría en Probable, pero tú verás».

**Medida.** `EvaluadorCalibracion` del core ya existe y da el Brier por afirmación.
`P4Calibration.compute()` sigue siendo un stub que lanza `UnimplementedError`, así que en
la v0.1 **no se registra maestría**, solo se devuelve la balanza. El registro llega con §6.

**Riesgo pedagógico.** Se parece a la fase de Reconstrucción. La diferencia es que aquí se
repasa en frío, fuera de la investigación y mezclando épocas. Si en las pruebas resulta
redundante, la ronda 2 es la que justifica el oficio.

**Tamaño:** S. Dominio muy pequeño; todo el trabajo está en la mesa y la balanza.

---

## 2. El documento roto

- **Habilidades:** HF.01 (tipo de fuente), HF.02 (primaria o secundaria), HF.03 (autoría),
  HF.04 (datación) y HF.05 (público). Todas son P1.
- **Objeto:** una mesa de luz con papeles rasgados.
- **Contenido:** `PropiedadesFuente` (`tipo`, `autor`, `fecha`, `publico`) y
  `Fuente.tipoVisible` de las Brechas cerradas. **No hay que escribir nada nuevo.**

**Pantalla.** Una humedad del ático ha separado las fichas de catalogación de sus
documentos. Arriba aparecen 2-3 documentos, cada uno con su `tipoVisible` y su
`descripcion`. Abajo, tiras rasgadas con autor, fecha y público. Cada tira tiene un borde
irregular que solo encaja con su ficha, pero el borde **no delata la respuesta**: todas las
fichas de una ronda comparten la forma del rasgado y lo que decide es el contenido.

**Rondas.**
1. Una Brecha, dos documentos, y decir si cada uno es primaria o secundaria (HF.02).
2. Tres documentos y sus tiras de autor y fecha (HF.03 y HF.04).
3. Aparece la tira de público (HF.05) y una **tira de sobra** de otra Brecha que no es de
   ninguno. Hay que dejarla en la caja.

**Errores típicos que sirven de distractores** (salen de los propios datos): confundir la
fecha del hecho con la fecha del documento. Es el caso del informe de los años 70 sobre
un enterramiento neolítico en la Brecha 1.1. Y confundir quién escribe con quién aparece
en el texto.

**Medida.** Cada tira colocada en su primer intento es acierto o fallo claro, con P1 por
habilidad. El registro llega con §6.

**Tamaño:** M. Lo nuevo es el pintor del papel rasgado (§5.2).

---

## 3. La cuerda del tiempo

- **Habilidades:** CC.01 (situar en una escala), CC.02 (leer líneas de tiempo), CC.03
  (periodizar) y, como extra, HF.04 y HF.12 (la fuente es también producto de su época).
- **Objeto:** **dos** cuerdas de tender cruzando el ático, con pinzas de madera. La de
  arriba es *cuándo pasó*; la de abajo, *cuándo se escribió*.
- **Contenido:** las fuentes de las Brechas cerradas **más un dato nuevo**: una franja
  numérica por fuente (`anioDesde`, `anioHasta`). Hoy `fecha` es texto libre (por ejemplo,
  «Años 70 del siglo XX» o «Cercana al uso del lugar, difícil de precisar»).

**La idea.** Cada fuente se cuelga **dos veces**: el hecho del que habla en la cuerda de
arriba y el momento en que se produjo en la de abajo. En una fuente primaria las dos pinzas
quedan casi una encima de otra. En una secundaria se separan, a veces miles de años, y
queda un hilo largo entre las dos. Es la mejor imagen de HF.02 que tenemos, y no hay que
explicarla.

**Pinzas anchas para lo incierto.** Si la franja es amplia («Neolítico final»), la pinza es
un cordel con dos pinzas que ocupa un tramo. Colgarla en cualquier punto dentro del tramo
es correcto. Esto cumple el principio del juego (convivir con la incertidumbre) sin
castigar la imprecisión honesta.

**Rondas.**
1. Solo la cuerda de arriba, con 3-4 fuentes de capas muy separadas. La escala es
   logarítmica visual: los milenios se comprimen hacia la izquierda.
2. Aparece la cuerda de abajo y las fuentes secundarias.
3. Periodizar (CC.03): colgar etiquetas de capa (D-NEO, D-ROMANA…) como banderines entre
   las pinzas.

**Bloqueo de contenido.** Las franjas numéricas son contenido histórico nuevo, aunque
salgan del texto de `fecha`. Van al catálogo con la marca `PROVISIONAL` y una entrada en
`BLOQUEOS-PENDIENTES.md` hasta que las valide el comité. Mientras tanto, el oficio puede
salir con solo las fuentes de fechas que no admiten duda (por ejemplo, el Fuero de 1129 o
la *Vita Karoli* h. 817-836).

**Medida.** La pinza en el primer intento es P1 (dentro o fuera de la franja). Los
banderines son P1 de CC.03.

**Tamaño:** M. El trabajo está en la escala comprimida y en la física de la cuerda.

---

## 4. Segunda y tercera tanda (necesitan contenido o arte nuevo)

| Oficio | Mecánica | Habilidades | Qué lo bloquea |
|---|---|---|---|
| **El subrayador** | Dos lápices sobre una crónica: verde para el hecho y siena para la opinión o el interés | HF.06, HF.09, HF.11, AH.05 (P2) | Marcar tramos de texto es contenido nuevo → comité |
| **Dominó causal** | Fichas causa→efecto en las que hay que distinguir causa, pretexto y coincidencia | CC.05, CC.06 (P2) | Cadenas causales nuevas → comité |
| **Capas de Iruña** | Papel vegetal sobre el plano actual, una hoja por capa; hay que situar calzada, murallas y burgos | GH.02, GH.03, GH.08 | Cartografía histórica → comité + ilustración |
| **Intrusos** | Una lámina de un año con 3-4 anacronismos escondidos | PH.01 (P2) | Láminas pintadas a mano → ilustrador |
| **Las voces que faltan** | Una fuente con huecos: ¿quién no aparece y por qué? | HF.07, PH.04 (P2) | Contenido nuevo → comité |

P2 **ya existe** en el core (`p2_detection.dart`), así que la tanda 2 solo está bloqueada por
el contenido, no por el código.

---

## 5. Gráficos

### 5.1 Lo que manda la guía visual (doc 11) y cómo cambia respecto a Uno Roto

| Uno Roto | Las Versiones |
|---|---|
| Recreativas en 3D renderizadas con flavor3d | **Nada de 3D ni render** (§1.1.1, §1.2). **flavor3d no se usa aquí** |
| Neón, chispas, sacudida de pantalla | Quietud: la cámara no se mueve y no hay partículas decorativas |
| Pixel art posible | Prohibido el pixel art (§1.2) |
| Paleta propia por distrito | Pigmentos históricos (§2.1), con la paleta de capa aplicada a los acentos |

### 5.2 Técnica: CustomPainter «pintado a mano»

Sin dependencias nuevas, con el mismo patrón que `fondo_ambiente.dart`:

- **Grano de papel:** una textura en mosaico (PNG de 256 px) generada una sola vez con un
  script de Python (ruido multiescala y fibras), y un `ImageShader` en `Paint`. Se hace una
  textura por soporte: pergamino, papel de trapo, papel moderno y madera de la mesa.
- **Línea de peso variable:** un helper `trazoAMano(Path, semilla)` que desplaza cada
  segmento con un ruido suave y varía el grosor a lo largo del trazo. Se usa para todos los
  contornos, rótulos de bandejas y cuerdas.
- **Borde rasgado:** un paseo aleatorio con semilla por pieza, con fibras sueltas en el
  borde y una sombra suave. Es el único efecto «vistoso» y lo aporta el propio objeto.
- **Pigmentos como tokens:** ampliar `paleta_archivo.dart` (todavía provisional) con los
  diez pigmentos de doc 11 §2.1 y una función `paletaDeCapa(capa)` que devuelva los acentos
  de §2.3. Así cada oficio toma el color de la época del material que se está usando.
- **Luz como información** (§1.1.6): la mesa de luz del documento roto es la única fuente
  de luz del oficio; en los demás oficios, luz cenital de claraboya en el ático.

### 5.3 Qué pintar (lista corta)

Mesa de madera cenital, cuerda y pinzas, balanza de latón, tres bandejas de mimbre y una
caja de tarjetas. Andrés ya tiene retrato en `assets/personajes/`. Todo es CustomPainter
salvo las texturas. Cuando entre el ilustrador (bloqueo pendiente), sus piezas sustituyen a
estas sin tocar el dominio.

---

## 6. Maestría: el cableado que falta

Las Versiones todavía no tiene motor de maestría. Esto es un requisito de todos los oficios,
pero **no bloquea la v0.1**:

1. `RegistroMaestriaArchivo` montado como el de Uno Roto
   (`uno-roto/lib/datos/registro_maestria_minijuego.dart`), con namespace
   `nuevoser.lasversiones.perfil.<id>.*` y el catálogo de las 65 habilidades desde
   `content/`.
2. Oficios con P1 (documento roto, cuerda): se registran en cuanto exista el paso 1.
3. Tres fichas (P4): requiere implementar `P4Calibration.compute()` y extender
   `SessionPayload` con el nivel declarado y el canónico por intento, como ya anota
   `evaluador_calibracion.dart`. Es trabajo de core y lleva tests antes que el código.
4. Lo mismo servirá después para las cinco fases de las Brechas, que tampoco registran hoy.

---

## 7. Sonido y música

### 7.1 Lo que manda la guía sonora (doc 12). Aquí es donde más cambia respecto a Uno Roto

- **Sin bucle musical por oficio.** Doc 12 §1.2 prohíbe expresamente «loops continuos de
  fondo para concentración» y el lo-fi de estudio. Uno Roto tiene un bucle por máquina;
  aquí **no**.
- **Diegético antes que musical** (§1.1.2): el ático *suena a ático*. Viga que cruje, lluvia
  en la claraboya, un reloj lejano y el papel.
- **Sin sonidos de videojuego** (§1.1.7): la pinza suena a pinza, la tarjeta en la bandeja
  suena a cartulina sobre mimbre y la balanza, a latón. No hay chime de acierto. Un error
  no suena.
- **Silencio compositivo** (§1.1.1): durante la ronda, solo ambiente muy bajo.

### 7.2 Uso de mesa-mezclas (Ravero): fragmentos de capa y bocetos para el compositor

El motor encaja con §2.4 de la guía (**fragmentos de 10-30 s por capa histórica**, no fondo
continuo) y con la necesidad de *temp track* mientras no haya compositor contratado (§2.5).
Uso previsto:

- **Un único momento musical por visita:** al cerrar el oficio, cuando Andrés dice su
  frase, suena un fragmento de 15-25 s **de la capa del material usado**. Es la recompensa
  que no es recompensa: oír la época que se acaba de tocar.
- **Géneros y caras candidatas** (hay que escucharlas con `--stems` y descartar lo que
  suene a «Hollywood medieval» o lleve laúd genérico, §1.2):

| Capa | Candidato Ravero | Qué pide doc 12 §2.4 |
|---|---|---|
| D-PALEO / D-NEO | `ambient` · `bruma` / `nocturno` (muy despojado) | tambor apagado, voz sin palabras, txistu lejano |
| D-PROTO | `celtic` · `alala` / `harp-air` (a revisar con asesoría: riesgo de folclorismo) | vientos pastorales, alboka |
| D-ROMANA | `medieval` · `organum` o `classical` · `camara` | cuerda, lira ocasional |
| D-ANTIQ | `medieval` · `canto-llano` | voz monástica sola, ascética |
| D-FORM | `medieval` · `cantiga` | salterio, voz solista |
| D-PLENA | `medieval` · `trovador` / `estampie` | trío de cuerda, voz sola |
| D-DINASTIAS | `medieval` · `ars-nova` | cuerda y piano, cortesano sin pompa |
| D-ANDALUSI | `arabic` · `andalusi` | oud; **bloqueado por la asesoría andalusí** |
| El ático (entrada, 1 vez) | `palimpsesto` · `biblioteca` / `primera-tinta` | solo como boceto, nunca en bucle |

- **Cómo se genera.** Desde `mesa-mezclas`, solo con su CLI y sin tocar ese repo (la misma
  regla que para Anarkopia, `docs/MOTOR-PARA-ANARKOPIA-2026-09-16.md`):
  ```sh
  cd ~/Projects/mesa-mezclas
  node scripts/motor/componer.js --genero=medieval --cara=canto-llano \
    --semilla=<N> --compases=8 --wav=/tmp/lv-antiq.wav --stems=/tmp/lv-antiq-stems
  ```
  La CLI sin Chrome (`scripts/motor/node/componer-node.js`) pide Node ≥ 22.12, y en esta
  máquina hay **Node 18**. Mientras no se actualice, se usa `componer.js`, que usa Chrome
  headless. Después, un script `scripts/sonido/generar_fragmentos_capa.py` en
  las-versiones recorta el fragmento, le pone fundidos, normaliza a −20 LUFS (más bajo que
  Uno Roto, por la quietud) y lo pasa a OGG. **El asset es la semilla**: un
  `scripts/sonido/manifiesto_fragmentos.json` con `{capa, genero, cara, semilla, compases,
  desde, hasta}` que se commitea, como en Anarkopia.
- **Marca provisional.** Todo lo que sale de Ravero aparece en créditos como *boceto
  provisional* hasta que el compositor contratado lo sustituya o lo valide (§2.5, paso 4).
  Los bancos de Ravero son CC0 desde el 2026-09-16; hay que revisar
  `docs/LICENCIAS-SUSTITUTOS-2026-09-16.md` antes de publicar.

### 7.3 Efectos: grabados mejor que sintetizados

Doc 12 §1.1.4 prefiere texturas reales. Para los efectos, **lo mejor y más barato es
grabarlos con el móvil**: pinza de madera, cartulina, papel rasgado, balanza, lluvia en una
claraboya. Unos 15 archivos cortos. Si no se pueden grabar, se sintetizan con un script como
`uno-roto/scripts/sonido/generar_musica_maquinas.py` (ruido filtrado y envolventes), sin
Ravero, que es un motor musical.

### 7.4 El cableado que falta

Las Versiones no reproduce nada todavía. Antes de los oficios hace falta un
`ServicioSonoroArchivo` con `audioplayers` (el mismo paquete que Uno Roto) que respete
`RepositorioPreferenciasAudio` y las cuatro `CapaAudio` del core (Ambiente, Música,
Efectos, Narrativos), incluido el modo silencio por perfil. Es una pieza pequeña y sirve
para todo el juego, no solo para el ático.

---

## 8. Encargos (misiones paralelas)

Investigaciones pequeñas que llegan al Archivo desde fuera. Son **2 fases** en lugar de 5
(Recolección y Reconstrucción, con un Concilio de una sola frase de Isaura). Se desbloquean
por arco, como las variantes de máquinas de Uno Roto.

Ejemplos de tono, **todos pendientes de comité**:
- Una familia trae una carta del bisabuelo: ¿de cuándo es y quién la escribió?
  (HF.03, HF.04; D-CONT, por tanto fuera del MVP de capas: revisar si cabe).
- Un vecino jura que su portal «es romano». Hay que comprobarlo con lo que se sabe
  (GH.08, AH.03).
- Sira publica en el tablón una versión con una fuente mal leída. Hay que encontrar el
  fallo sin humillarla (HF.08, AH.04).

Aparecen en el Cuaderno de la Cronista como entradas propias, no como lista de tareas.
Todas llevan contenido nuevo, así que **van después de la tanda 1**.

---

## 9. Orden de construcción propuesto

Commits pequeños (< 10 archivos), con los tests del dominio antes que la vista:

1. `ServicioSonoroArchivo` + efectos grabados o sintetizados (§7.3-7.4).
2. Helpers gráficos: texturas, `trazoAMano`, borde rasgado y pigmentos en la paleta (§5.2).
3. Nodo «El ático», escena y Andrés; catálogo de oficios con apertura por flag de Brecha.
4. **Tres fichas**: dominio + tests → pantalla → cierre con fragmento de capa.
5. **El documento roto**: dominio + tests → pantalla.
6. Primeros fragmentos de capa con Ravero (§7.2): manifiesto + script + escucha.
7. `RegistroMaestriaArchivo` con P1 (§6.1-6.2).
8. **La cuerda del tiempo**: solo con fechas seguras y franjas `PROVISIONAL` en
   `BLOQUEOS-PENDIENTES.md`.
9. P4 en core (§6.3), aparte y con tests.

Textos es/eu/ca desde el primer commit (eu/ca pendientes de revisión nativa, como el resto).

## 10. Preguntas abiertas para el operador

1. ¿Andrés y el ático como anfitrión, o prefieres a otro personaje o espacio?
2. ¿Fragmento musical al cerrar cada visita, o solo al cerrar la primera visita de cada
   capa? (La guía pide música escasa; la segunda opción es más fiel.)
3. ¿Grabas tú los efectos o se sintetizan?
4. ¿Se actualiza Node a 22 en esta máquina para usar la CLI de Ravero sin Chrome?

---

## 11. Preguntas de Andrés: el quiz compartido (añadido el 2026-09-24)

Patrón sacado del quiz de identificación de Fósiles (cuadernos-de-campo) y **ya extraído a
`nuevo_ser_core`** (`src/quiz/` + `src/ui/vista_quiz.dart`, con tests). Monta preguntas
sobre cualquier catálogo, sin escribir preguntas a mano:

- Distractores por parecido: primero los confundibles declarados (errores típicos),
  después los del mismo grupo y por último el resto. La dificultad (1-3) sube cuando son
  cercanos.
- Partida de N preguntas con cierre y un único intento por pregunta.
  `alResponder(resultado)` entrega la habilidad, el acierto, la dificultad y la duración
  al motor de maestría del juego.
- **Modo con confianza:** se elige la opción, se declara la confianza y solo entonces se
  revela. `resumenCalibracion()` da el Brier binario y la tendencia (sobreconfianza,
  timidez o equilibrada). Esa tendencia es la «balanza» de Tres fichas, reutilizada.
- Por defecto **sin marcador y sin rojo**; las imágenes las carga el juego (asset local
  en Kids).

**En Las Versiones:** un oficio más del ático, «Preguntas de Andrés», siempre con
confianza y con las etiquetas Sólido, Probable y Disputado. Catálogos que ya existen: la
capa de cada fuente (CC.03), si es primaria o secundaria (HF.02) y la autoría (HF.03),
con `grupo` = capa de la Brecha. No necesita contenido nuevo.

**En los demás juegos:**
- **El Cuaderno, «¿Te acuerdas?»:** el catálogo son las propias observaciones del niño
  (`fotoRutaLocal`, `creesQueEs`). La «correcta» es lo que escribió aquel día, así que
  no hay fallo posible: si elige otra cosa, «Aquel día escribiste X. ¿Sigues
  pensándolo?». Solo datos locales. Requiere una revisión de voz (doc 04) antes de
  construirlo.
- **Fósiles:** puede migrar su `pantalla_quiz.dart` al core y ganar los distractores por
  parecido y el modo con confianza. Allí sí caben el marcador y el verde/rojo.
- **Solera (apícola, aceitera…):** un «modo formación» para identificar plagas y
  enfermedades.
- **El Descifrador:** cuando tenga mecánica.
