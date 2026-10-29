# Guía de testeo — El Descifrador

Cuarto juego Kids de la Colección Nuevo Ser, en estado de esqueleto
avanzado / prototipo solo-lectura. Verbo motor: **descifrar**. Edad
diana 11-14. El niño es aprendiz en la oficina de descifradores de
**La Estafeta**, un puerto atlántico ficticio peninsular. Llegan
papeles del mundo en distintas lenguas (las cuatro cooficiales
peninsulares como L1 desde el día uno: castellano, euskara, catalán,
gallego). El niño los identifica, marca palabras, propone hipótesis y
decide qué hacer con ellos.

> **Aviso importante para el tester**: el juego está en una fase muy
> temprana. Hay menos que testear que en Fósiles o Larrea. El
> prototipo actual aburre — eso lo sabemos. Por eso necesitamos sobre
> todo **feedback honesto sobre la sensación**: qué te transmite el
> puerto, qué te hace sentir abrir un papel, dónde te aburres,
> dónde te pierdes, qué falta para que enganche.
>
> No buscamos bugs de funcionalidad avanzada (no hay funcionalidad
> avanzada). Buscamos primera impresión, atmósfera y qué harías tú.

**Versión a testear**: 0.1.0+1 (release `apks-2026-05-18`)
**Descarga**: https://github.com/JosuIru/nuevo-ser/releases/tag/apks-2026-05-18 → `el-descifrador-0.1.0+1.apk`
**Dispositivo recomendado**: Android 8+, tableta o móvil grande. La
estética y la lectura de documentos están pensadas para pantalla
cómoda — un móvil pequeño puede ser frustrante por puro tamaño de
texto.
**Perfil tester ideal**: chaval 11-14 + adulto que lo acompañe. Si
eres profesor de lengua, L2 o trabajas con las cuatro cooficiales,
hay una sección final dedicada — tu mirada vale doble aquí.

---

## Antes de empezar

- [ ] **Permisos**: la app no debería pedir ningún permiso del sistema
  en esta versión (sin cámara, sin GPS, sin notificaciones). Si pide
  alguno, anótalo como hallazgo raro.
- [ ] **Idioma del dispositivo**: la app está cableada a castellano en
  v0.1.0 aunque arranque en un móvil en euskara/catalán/gallego. Eso
  es esperado en esta versión. La selección de lengua de juego llegará
  con el sistema de perfiles.
- [ ] **Tiempo estimado**: 30-45 minutos. No es un testeo largo
  precisamente porque hay poco que recorrer. Si te quedas atascado,
  esa es la observación.
- [ ] **Cómo tomar notas**: ten algo cerca (papel, móvil, lo que sea)
  para apuntar **lo que sientes**, no solo lo que se rompe. Esa parte
  importa más que en otros juegos.

---

## Bloque 1 — Primer arranque

- [ ] La app instala sin avisos extraños.
- [ ] Al abrir, no se cierra ni muestra pantalla negra prolongada.
- [ ] La primera pantalla que ves es la **oficina** (vista cenital
  con una mesa, papeles, una frase del maestro arriba).
- [ ] Hay un texto introductorio o frase del maestro visible nada más
  entrar.
- [ ] Si la primera vez tarda más de 3-4 segundos en cargar, anótalo.

**Notas / hallazgos**:


---

## Bloque 2 — La oficina (mesa del aprendiz)

Esta es la pantalla principal. El niño verá esto casi siempre.

- [ ] El fondo de la oficina se ve completo (sin franjas negras a los
  lados, sin imagen estirada o cortada de mala manera).
- [ ] La frase del maestro (parte superior) es legible.
- [ ] Hay una **bandeja de entrada** arriba a la izquierda con uno o
  varios papeles.
- [ ] Hay un indicador de **archivo** arriba a la derecha (cuántas
  piezas has resuelto hoy).
- [ ] Hay un botón **"Tu cuaderno"** abajo a la derecha.
- [ ] Hay un botón **"Salir al puerto"** abajo a la izquierda (con
  icono de mapa).
- [ ] Los papeles de la bandeja de entrada muestran: tipo del
  documento, remitente y un asomo del texto.
- [ ] La etiqueta de lengua dice "lengua sin identificar" en piezas
  que aún no has abierto.

### Sensación

Estas preguntas no tienen casilla — escribe en notas:

- ¿Qué te transmite la imagen de la oficina? (Atmósfera, época, tono.)
- ¿Te apetece tocar un papel? ¿O te quedas mirando sin saber qué
  hacer?
- ¿Echas algo en falta de manera evidente? (Movimiento, sonido,
  alguien presente.)

**Notas / hallazgos**:


---

## Bloque 3 — Abrir un documento

- [ ] Al tocar un papel de la bandeja, se abre la pantalla del
  documento.
- [ ] El documento ocupa la mayor parte de la pantalla.
- [ ] El texto es legible (tamaño y contraste razonables).
- [ ] Aparece algún panel o botón para **identificar la lengua**.
- [ ] Tras identificar la lengua, la app reacciona (visualmente o
  con un mensaje) — no se queda muda.
- [ ] Se pueden **tocar palabras** del texto para marcarlas
  (probablemente con colores: verde / amarillo / rojo).
- [ ] Al tocar una palabra aparece un diálogo donde se puede anotar
  una hipótesis o asignarle un color.
- [ ] Hay forma de **proponer una interpretación** (qué crees que
  dice el documento en conjunto).
- [ ] Hay forma de **pedir una pista** al maestro.
- [ ] Hay opciones de **decisión** al final: archivar / devolver al
  remitente / entregar al destinatario / publicar en el Boletín /
  esperar. (No todas aparecen en toda pieza — depende del documento.)
- [ ] Al tomar una decisión, se vuelve a la mesa y el papel pasa al
  archivo.

### Sensación

- ¿El primer documento que abres te interesa? ¿Lo lees entero o
  saltas a decidir sin entender?
- Si la lengua del documento NO es tu L1, ¿la app te da apoyo
  suficiente o te abandona?
- ¿Sientes que tu hipótesis importa, o tienes la sensación de que
  cualquier decisión vale igual?
- ¿La voz del maestro (en pistas, en frases) te parece sobria y
  digna, o paternalista, o vacía?

**Notas / hallazgos**:


---

## Bloque 4 — El cuaderno

- [ ] El botón "Tu cuaderno" abre la pantalla del cuaderno.
- [ ] El cuaderno tiene secciones: lenguas, personajes, vocabulario,
  interpretaciones, notas, documentos resueltos.
- [ ] Las páginas del cuaderno reflejan lo que has hecho (palabras
  marcadas, interpretaciones propuestas, piezas archivadas).
- [ ] **NO hay XP, ni barras de progreso, ni estrellas, ni rachas, ni
  niveles**. Si ves algo de eso, es un bug grave: anótalo.
- [ ] Se pueden añadir **notas libres** propias del niño.
- [ ] Lo que escribes se conserva al cerrar y volver a abrir el
  cuaderno.
- [ ] Tras resolver alguna pieza, pueden aparecer **sellos** sobrios
  en el cuaderno (sin fanfarria, sin emoticonos, sin "¡muy bien!").

### Sensación

- ¿El cuaderno te da sensación de progreso, aunque no haya números?
- ¿O te parece vacío y aburrido sin un contador?
- ¿Las notas libres invitan a escribir o intimidan?

**Notas / hallazgos**:


---

## Bloque 5 — El puerto (mapa y otras localizaciones)

La oficina no es el único sitio. El botón "Salir al puerto" abre un
mapa con destinos accesibles.

- [ ] El mapa muestra los destinos desde la oficina (debería verse al
  menos Calle Mayor).
- [ ] Desde Calle Mayor se accede a: despacho del maestro, muelle,
  Boletín.
- [ ] Cada localización tiene su propio fondo renderizado.
- [ ] Cada localización tiene un texto narrativo breve que la
  presenta.
- [ ] Se puede volver a la oficina con el botón "Volver a tu mesa".
- [ ] El movimiento por el mapa se conserva — si cierras y vuelves a
  abrir la app desde otro sitio, debería seguir ahí (no obligar a
  empezar siempre en la oficina).
- [ ] **Importante**: las localizaciones del puerto en esta versión
  están casi vacías. El despacho del maestro, el muelle y el Boletín
  son más decorado que mecánica. ¿Qué sientes al visitarlos?

### Sensación

- ¿Las imágenes del puerto te dan ganas de explorar?
- ¿Te decepciona llegar al muelle y que no haya nada que hacer?
- ¿Qué te gustaría poder hacer en cada lugar? (Lista libre.)

**Notas / hallazgos**:


---

## Bloque 6 — Lenguas del documento

El juego tiene las cuatro cooficiales peninsulares como contenido
nuclear. Aunque en v0.1.0 el corpus es muy pequeño (un par de piezas
de muestra), conviene observar.

- [ ] Si una pieza está en una lengua que NO es tu L1, ¿puedes
  acercarte a ella con las herramientas de la app (marcar palabras,
  pedir pista, proponer hipótesis)?
- [ ] El juego **no intenta enseñarte la lengua entera**. ¿Notas eso
  como alivio o como falta?
- [ ] Si tu L1 es una de las cuatro cooficiales distinta de
  castellano, anota qué se siente trabajar con un documento en
  castellano (o al revés).

**Notas / hallazgos**:


---

## Bloque 7 — Persistencia básica

- [ ] Cerrar la app y volver a abrirla: lo que habías marcado /
  decidido / escrito sigue ahí.
- [ ] Tras decidir una pieza, no vuelve a aparecer en la bandeja de
  entrada al reabrir.
- [ ] Las notas libres del cuaderno se conservan.
- [ ] Si cambias de localización (puerto) y matas la app, vuelves al
  mismo sitio al reabrir (o al menos a la oficina sin perder nada).

**Notas / hallazgos**:


---

## Bloque 8 — Pruebas de robustez

Probar cosas que pueden romperlo:

- [ ] Girar el dispositivo entre vertical y horizontal: la app no se
  rompe, los papeles siguen accesibles.
- [ ] Resolver todas las piezas disponibles (solo hay dos en v0.1.0):
  ¿qué pasa cuando la bandeja queda vacía? ¿Hay mensaje, hay vacío
  triste, hay invitación a volver mañana?
- [ ] Tocar un papel muy rápido varias veces seguidas: no debería
  abrir dos pantallas a la vez ni crashear.
- [ ] Abrir y cerrar el cuaderno repetidamente: no debería ralentizar
  la app.
- [ ] Modo avión: la app debería funcionar (no requiere red en esta
  versión).
- [ ] Si dejas la app en background un rato y vuelves: el estado se
  conserva.

**Notas / hallazgos**:


---

## Bloque 9 — Sensación general: qué falta para que enganche

Esta es la sección **más importante** del informe. El prototipo
actual aburre, lo sabemos. Necesitamos saber por qué y qué harías
tú.

Por favor escribe en texto libre. No es necesario marcar casillas
aquí.

### Lo que te ha gustado

(Aunque sea poco: una imagen, una palabra, una sensación. Sirve.)

### Lo que te ha aburrido

(Sé crudo. ¿En qué momento exacto perdiste interés? ¿Por qué?)

### Lo que has echado en falta

Algunas preguntas para arrancar:

- ¿Esperabas más papeles? ¿Más variedad?
- ¿Esperabas algún personaje que te hable de verdad y no solo una
  frase pintada?
- ¿Te falta sonido? ¿Qué tipo?
- ¿Te falta una sorpresa, un giro, alguien que llame a la puerta?
- ¿Te falta saber para qué descifras los documentos —
  consecuencia, comunidad, algo que cambie en la ciudad por tu
  trabajo?
- ¿Te falta un objetivo de sesión claro (hoy hay X papeles) o
  prefieres ritmo libre?

### Qué cambiarías mañana si fueras el diseñador

(Una sola cosa. La que más impacto tendría según tú.)

---

## Bloque 10 — Perspectiva profe de lengua / L2 / cuatro cooficiales

*Si trabajas con lengua o L2 (especialmente con las cuatro
cooficiales peninsulares), esta sección está pensada para ti. El
resto de testers puede saltarla.*

El Descifrador NO quiere enseñar una lengua entera. La postura es
deliberadamente anti-Duolingo: enseñar a **leer en lenguas que no
dominas con ayuda del contexto** como habilidad transferible.

### Postura general

- [ ] ¿La distinción "leer asistido vs. aprender" se nota en lo que
  has visto, o el juego acaba pareciendo un Duolingo más?
- [ ] ¿Te parece sólida la idea de marcar palabras (verde/amarillo/rojo)
  + hipótesis sin obligar a traducción literal?
- [ ] ¿La opción de "lengua sin identificar" como estado válido al
  empezar te parece pedagógicamente honesta?

### Cuatro cooficiales como L1

- [ ] ¿Te convence cablear las cuatro cooficiales como L1 desde el
  día uno, antes incluso de tocar L2 (portugués, francés, italiano,
  inglés, alemán, latín fragmentario)?
- [ ] Si trabajas con una de ellas (euskara, catalán, gallego):
  ¿qué expectativas tienes sobre tratamiento? (Registro,
  variedad dialectal, didáctica.)
- [ ] **Especialmente para euskara**: la tradición pedagógica propia
  pide cuidado. ¿Qué señalas como innegociable?

### Materiales de corpus

(En v0.1.0 solo hay dos piezas de muestra. La pregunta es estructural.)

- [ ] Los seis "operadores" de la mecánica nuclear son: identificar
  lengua, marcar palabras, anotar hipótesis, proponer interpretación,
  pedir verificación, decidir destino. ¿Crees que esos seis cubren
  el ejercicio lector que quieres ver en aula?
- [ ] ¿Falta alguna operación que en clase te parece imprescindible?
- [ ] ¿La decisión final (archivar / devolver / entregar / publicar /
  esperar) como cierre de ejercicio te parece pedagógicamente
  potente o forzada?

### Voz del maestro

- [ ] La voz del maestro de oficina (coral Antón + Aitziber) en
  pistas y saludos debe ser sobria, sin "¡muy bien!", sin
  emoticonos. ¿Se respeta eso en lo que has visto?
- [ ] ¿La voz te parece adecuada para 11-14?

### Anti-folklorización

- [ ] El manifiesto madre prohíbe folklorizar ninguna cultura.
  ¿Detectas algún riesgo de folklorización en cómo se presentan las
  lenguas o el puerto?

### Sugerencias estructurales libres

- ¿Cómo medirías el progreso lector de un niño con este juego sin
  caer en métricas que el manifiesto Kids prohíbe (sin XP, sin
  rachas)?
- ¿Cómo lo integrarías en una sesión de aula de 45 minutos?
- ¿Te interesaría como herramienta de aula, o solo de uso
  individual?

**Comentarios libres del profesional de lengua / L2**:


---

## Feedback general

Espacio libre para lo que no encaje en los bloques anteriores:
funcionalidades que faltan, comparaciones con otros juegos que
conoces, prioridades de qué arreglar primero, cosas que te
inquietaron.

**Comentarios libres**:


---

## Información del tester

- **Nombre / alias**:
- **Perfil** (chaval 11-14 / adulto acompañante / profesor de
  lengua / profesor de L2 / lingüista / programador / otro):
- **Lengua materna principal**:
- **Otras lenguas que lees con soltura**:
- **Dispositivo**:
- **Versión Android**:
- **Fecha del informe**:
- **Tiempo aproximado dedicado al testeo**:
