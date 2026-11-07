# 16 — Rediseño del bucle de diversión

**Estado**: propuesta v0.1 · 2026-07-08 · **Fase D1 implementada** (2026-07-08): encargo del día (dominio + persistencia + cazadero + mapa, es/eu/ca) y ritmo de sesión 1 protegido por test — la cadena 1.1→1.5 ya desembocaba en `kurz_1`; el umbral de Aprendiz II ya caía en día 1-2 (sin cambios). · **Fase D2 en curso**: taller de Rexán completo (2026-07-08 — 21 piezas, precio plano, gasto sin tocar lo ganado, piezas visibles en el escenario, nodo en el mapa) + raros de clima completos (2026-07-08 — 4 raros ligados a `ClimaDistrito`, payoff en el Cuaderno, tests de posibilidad real del clima). + 2 secretos espaciales (ventana del gato en Tejados, farolillo apagado en Canales — sin señalización, payoff en el Cuaderno). · **Fase D2 completa** con el Bestiario (2026-07-08 — pestaña en Mi Cuaderno, 6 fichas de familias con lore por tramos a 1/5/15 encuentros, derivado de `totalExposiciones` sin persistencia nueva). Queda de D2 solo la parte editorial: pistas crípticas de raros y secretos en ediciones futuras del Faro. Siguiente: **testear con niños** antes de la Fase D3 (verbo manipulativo).
**Origen**: feedback de campo — los niños juegan dos días y abandonan. Coincide con el incidente registrado en CLAUDE.md ("niños testers dicen 'es para clase'") y con el informe de testeo de Izan (2026-05-19): no vio ningún combate y no percibió que la ciudad se restaurase.
**Alcance**: qué cambiar para que Uno Roto sea divertido y motive volver, sin violar el doc 01. No propone contenido nuevo (escenas, habilidades): propone verbo, visibilidad y forma.

---

## 1. Diagnóstico

### 1.1 El minuto a minuto es un cuestionario con atmósfera

De las 76 habilidades del catálogo, prácticamente todas se juegan con el mismo verbo: **leer un enunciado y tocar 1 de 4 tarjetas**. La variedad es pedagógica (distractores curados a errores reales — eso está muy bien y no se toca), pero no mecánica. Un niño de 9-12 años detecta en dos sesiones que "cazar Fragmentos" envuelve "hacer fichas". La única excepción es el tutorial 1.2 (dividir un Pleno con gestos reales, `WidgetFragmentoTutorial`): esa es la promesa que el resto del juego no cumple.

### 1.2 Lo divertido existe pero el niño no lo ve

| Sistema | Estado | Problema |
|---|---|---|
| Combates (Kurz, Zafrán, Kai, Vorax) | Implementados y calibrados | Tan tarde en la progresión que un tester a fondo no vio **ninguno** |
| Restauración de la ciudad | Implementada (esquirlas → escenario) | Invisible: el propio tester anotó "no quedó claro si la ciudad se recompone" |
| Clima por distrito (`ClimaDistrito`) | Implementado, determinista, con carácter | Puramente cosmético: no cambia nada de lo que el niño puede hacer |
| Eventos de calendario (`CalendarioEventos`) | Implementados, anunciados en el Faro | Solo cambian el cielo; no hay nada que cazar distinto ese día |
| Atlas / Mi Cuaderno | Implementados | Registro pasivo; no generan "me falta uno" |

### 1.3 La progresión es opaca y la sesión no tiene forma

- Escenas latentes tras flags de maestría (`fr_05_competente`) que el niño no sabe cómo activar.
- Rangos a 30/100/250 esquirlas sin meta intermedia visible.
- El cazadero libre no tiene principio ni final: entras, tocas Fragmentos sueltos, sales. No hay un "hoy quiero X" ni un "hoy conseguí X".

**Tesis**: no falta contenido — sobra. Falta (a) que el verbo del puzzle sea manipular en vez de elegir, (b) que las recompensas que ya existen sean visibles y elegibles, y (c) que la sesión tenga forma.

---

## 2. Marco: motivar sin manipular (contrato con el doc 01)

El principio 3 ("la mesura es el sabor") y la regla "no crear agujeros de gamificación" prohíben el **casino**, no el **juego**. La línea divisoria:

**Prohibido** (mecánicas de ansiedad/pérdida):
- Puntos-euforia, confeti, combos, multiplicadores.
- Rachas que se pierden ("llevas 5 días… no lo rompas").
- Temporizadores de presión, energía que se agota, FOMO artificial.
- Recompensa de ratio variable (cajas, jackpots).

**Permitido y deseable** (mecánicas de curiosidad/dominio/pertenencia):
- Metas diegéticas cortas propuestas por personajes.
- Agencia: elegir qué restaurar, dónde cazar, qué completar.
- Colección con identidad (conocer, no acumular).
- Secretos y rareza (curiosidad, no escasez comercial).
- Manipulación directa: que las matemáticas se toquen.

**Regla de oro** para evaluar cada propuesta de aquí en adelante: *¿el niño vuelve por curiosidad, dominio o pertenencia — o por ansiedad de perder algo?* Solo lo primero entra.

---

## 3. Los seis ejes

### Eje A — El verbo: de elegir a manipular

**Impacto ⭐⭐⭐ · Coste alto · El cambio de fondo**

No convertir las 76 familias: pilotar **4-5** y medir. Candidatas por frecuencia de spawn y por potencia táctil:

| Familia | Mecánica manipulativa | Semilla existente |
|---|---|---|
| FR.01/FR.05 (unitario, comparación) | Partir un Pleno arrastrando el dedo; las mitades se desfragmentan | `WidgetFragmentoTutorial` (escena 1.2) ya lo hace |
| ALG.01 (ecuación lineal) | Balanza: arrastrar términos de un platillo a otro y ver el fiel moverse | `pantalla_ecuacion_lineal` (cambia la vista, no el generador) |
| FR.07 (comparar fracciones distintas) | La misma balanza con una fracción en cada platillo | Generador actual intacto |
| MED.04 (ángulos) | Girar el brazo del ángulo con el dedo hasta la categoría | `_PintorPoligono` como referencia de CustomPainter interactivo |
| GEO.03/GEO.04 (áreas) | Rellenar la figura arrastrando unidades cuadradas | Pintores de GEO existentes |

Reglas del piloto:
- El generador y los distractores **no cambian** — solo la capa de vista. La respuesta por candidatos queda como fallback (accesibilidad, dispositivos lentos).
- CustomPainter + GestureDetector bastan; **no** exige migrar a Flame (coherente con la decisión "migrar cuando haya razón real" — si el piloto funciona, esta será la razón).
- Medir con el testeo siguiente: ¿el niño describe el juego como "partir/pesar/girar" o como "acertar"?

### Eje B — La ciudad se restaura y el niño elige qué

**Impacto ⭐⭐⭐ · Coste medio · La recompensa a largo plazo, por fin visible**

- **Taller de restauración**: pantalla nueva (o sección del mapa) donde el niño gasta esquirlas en piezas concretas del distrito: una farola de los Canales, un toldo del Mercado, una grúa del Puerto. `PintorEscenario` ya pinta por capas — cada pieza pasa a tener estado `rota/restaurada` persistido por perfil (`uroto.perfil.<id>.ciudad.<pieza>`).
- **Antes/después**: al volver al cazadero tras restaurar, la pieza se enciende con un fade lento. Mesura: sin fanfarria, la luz basta.
- **Rexán como maestro del taller** (ya existe, ámbar, Arco 2): una línea suya por pieza restaurada. La ciudad agradece en voz baja.
- Las esquirlas dejan de ser un contador abstracto y pasan a ser **material con destino elegido por el niño**. El motor de maestría no se toca.
- Salvaguarda doc 01: precios planos y públicos, sin escasez artificial, sin piezas "premium". Es un pueblo, no una tienda.

### Eje C — El Atlas como bestiario con identidad

**Impacto ⭐⭐ · Coste medio-bajo**

- Cada familia de Fragmento gana ficha: silueta, nombre diegético, distrito donde habita, rareza (común/inusual/raro), y un texto de lore que se **completa por tramos** al capturar 1 / 5 / 15 ejemplares.
- La recompensa es conocimiento, no botín: el tramo nuevo cuenta algo del mundo (misma voz que el Faro). "Me falta uno" sin premios.
- Los Fragmentos nombrados (Kurz, Zafrán, Vorax, Eco) ya tienen voz, halo y personalidad — esto extiende esa dignidad hacia las familias comunes.
- Badge sobrio en el chip del Atlas cuando hay ficha nueva o tramo desbloqueado (mismo patrón "·" que el Faro).

### Eje D — La sesión con forma: el encargo del día

**Impacto ⭐⭐⭐ · Coste bajo · El cambio con mejor ratio de toda la propuesta**

- Al entrar al mapa, Sora (o Rexán, o el propio Faro) propone **un encargo pequeño y concreto**: "Hoy he visto tres Espejos en los Canales" / "Al taller le falta una pieza para la farola del puente". Capturas concretas o una restauración.
- Determinista por fecha y perfil (mismo patrón que `ClimaDistrito._semillaDelDia` — puro, testeable, sin reloj trucable).
- Al completarlo: un plano de cierre amable (el sistema `PlanoCierreAmable` / "HASTA MAÑANA" **ya existe**). La sesión tiene principio, objetivo y final digno en 10-15 minutos. Es el antídoto estructural del scroll infinito: el juego *termina bien* cada día.
- **Sin racha, sin pérdida**: si el niño no viene, no pasa nada. Mañana hay otro encargo. Nunca se acumulan ni caducan con culpa.
- Siempre opcional: el cazadero libre sigue abierto igual (no repetir el incidente "es para clase" — no volver a dictar sesiones).

### Eje E — Rareza, clima y secretos

**Impacto ⭐⭐ · Coste bajo · Los sistemas ya existen; falta darles consecuencia**

- **Spawns condicionados**: `GeneradorCaza` consulta `ClimaDistrito.delDia` y `CalendarioEventos.deHoy` (ya deterministas) — un Fragmento raro que solo aparece con niebla en el Puerto, otro solo el día del equinoccio menor. El clima deja de ser decorado y pasa a ser información de caza.
- **El Faro como mapa del tesoro**: las pistas se siembran en las ediciones de forma críptica (la E13 "Las tres lluvias" ya describe el clima de cada distrito — ya está medio hecho). Conecta la lectura semanal con la caza: el niño que lee, encuentra.
- **Secretos espaciales**: 2-3 puntos tocables no señalizados en los escenarios (un tejado concreto, un farolillo apagado) que abren una mini-escena o una entrada del Atlas. Los secretos son la mecánica de motivación más limpia que existe: cero euforia, pura curiosidad, y generan conversación entre niños ("¿tocaste el farolillo del puente?").

### Eje F — Los dos primeros días deciden todo

**Impacto ⭐⭐⭐ · Coste bajo · Recalibrado, no desarrollo**

La curva actual guarda lo mejor para quien ya se quedó. Invertirla:

- **Sesión 1**: combate `kurz_1` debe caer sí o sí (ya está calibrado a derrota — dramáticamente perfecto como gancho: el niño pierde y quiere revancha). Revisar los `flagsRequeridos` de la cadena 1.1→1.5 para que quepa en 15-20 min de juego real.
- **Sesión 1**: primera pieza restaurada, regalada por Rexán ("esta te la enseño yo") — el niño ve el antes/después el primer día.
- **Sesión 2**: primer avistamiento de un Fragmento raro de clima — visible, aunque se escape. Deseo, no ansiedad.
- Revisar el umbral de Aprendiz II (30 esquirlas): debería caer en el día 2-3, no después.

---

## 4. Priorización y fases

| Eje | Impacto | Coste | Depende de |
|---|---|---|---|
| D — Encargo del día | ⭐⭐⭐ | Bajo | — |
| F — Ritmo días 1-2 | ⭐⭐⭐ | Bajo | — |
| E — Rareza y secretos | ⭐⭐ | Bajo | — (mejor tras D) |
| B — Taller de restauración | ⭐⭐⭐ | Medio | — |
| C — Atlas bestiario | ⭐⭐ | Medio-bajo | mejor tras E (rarezas definidas) |
| A — Verbo manipulativo | ⭐⭐⭐ | Alto | — (piloto independiente) |

**Fase D1 — "que el segundo día enganche" (≈1 semana)**
Ejes D + F. Sin tocar puzzles ni motor: encargo diario, combate en sesión 1, pieza regalada, umbral de rango. Es la apuesta mínima que puede cambiar la retención por sí sola — y si no la cambia, es señal de que hay que ir directos al Eje A.

**Fase D2 — "que haya razones para volver" (≈2-3 semanas)**
Ejes B + E + C. Taller con 4-6 piezas por distrito, 3-4 Fragmentos de clima, 2 secretos espaciales, fichas de Atlas para las familias FR y DEC.

**Fase D3 — "que jugar sea tocar" (mayor, tras medir D1/D2)**
Eje A: piloto de 4-5 familias manipulativas. Si el testeo confirma, extender por oleadas y evaluar entonces (y solo entonces) la migración a Flame.

---

## 5. Medir sin vigilar

Coherente con "privacidad por diseño" (doc 01): **cero telemetría remota**. Todo local:

- Contador local de sesiones y días distintos jugados (`uroto.perfil.<id>.metrica.*`), visible solo en la pantalla debug y exportable con el `exportador_progreso` existente. En testeos presenciales o familiares se lee del dispositivo, con el adulto delante.
- **Métrica de éxito de la Fase D1**: en el siguiente testeo, que el niño vuelva por sí solo el día 7 (hoy: abandono en el día 2-3).
- Preguntas de la guía de testeo (añadir a `docs/testing/uno-roto-guia-testeo.md`): *"¿Qué querías hacer hoy al abrir el juego?"* (si no sabe responder, la sesión no tiene forma) y *"¿Qué te falta por conseguir?"* (si no sabe responder, la meta no es visible).

---

## 6. Riesgos y salvaguardas

- **Eje A se come el proyecto**: 76 familias manipulativas es un año de trabajo. Salvaguarda: piloto cerrado de 4-5, medir, y solo extender lo que funcione.
- **Eje B deriva en tienda**: si aparecen precios crecientes, piezas exclusivas o escasez, se ha cruzado la línea. Salvaguarda: precios planos, todo alcanzable, revisión contra doc 01 antes de cada pieza nueva.
- **Eje D deriva en deber**: si el encargo se acumula, caduca con culpa o condiciona el acceso a algo, es una racha disfrazada. Salvaguarda: un encargo por día, se completa o se evapora sin rastro.
- **Tono**: toda propuesta habla por boca de los personajes existentes (Sora seca, Rexán cálido, el Faro con la pluma de Maren). Nada de UI que grite. Si un texto no lo firmaría el doc 04, fuera.
- **El incidente fundacional**: el pivote que quitó las sesiones dictadas fue correcto. Nada de esta propuesta reintroduce obligación — añade **razones**, no deberes.
