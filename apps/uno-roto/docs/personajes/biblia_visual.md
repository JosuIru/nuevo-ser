# Biblia visual de personajes — Uno Roto

Referencia canónica para los pintores Flutter (`SoraPresencia`,
`KaiPresencia`, `OrynPresencia`…) y para cualquier arte futuro
(profesional, IA generativa, pixel-art). Las paletas se documentan
con hex exactos para que pueden replicarse fuera de la app.

Concept-art original (escaneado de los dibujos manuales del autor):
`concept-art/kai.pdf`, `concept-art/kai-hablando.pdf`,
`concept-art/oryn.pdf`. Si la implementación se aleja de la
referencia, vuelve a ellos antes de inventar.

---

## Estilo común

Todos los avatares siguen el patrón `_PintorSilueta` introducido por
`SoraPresencia`:

- **Lienzo** 70×90 lógicos, alineados al borde inferior de la franja
  de 120px que ocupa la presencia en pantalla.
- **Silueta** rellena con un tono muy oscuro (casi negro) tintado al
  color dominante del personaje — así la figura "lee" sin necesidad
  de detalle facial.
- **Contorno** con el color de marca del personaje, opacidad ~0.85.
- **Acentos** (1-2 trazos): elementos icónicos que distinguen al
  personaje de un vistazo (cremallera mostaza en Sora, capucha azul
  en Kai…).
- **Bocadillo** lateral con borde y glow del color de marca,
  esquinas asimétricas (puntiaguda en el lado de la silueta).

---

## SORA — Aprendiz / guía del jugador

Implementado en `vista/sora_presencia.dart` desde el inicio del juego.

- **Silueta**: oscura violeta (`0xFF0F0826`).
- **Contorno**: violeta neón (`PaletaNeon.violetaNeon`, opacidad 0.85).
- **Acentos**: cremallera y ribete mostaza (`0xFFB89A4E`) en la
  cazadora. Mechón asimétrico cayendo por la izquierda de la cabeza.
- **Posición**: esquina inferior izquierda.
- **Bocadillo**: a su derecha, borde violeta.

Voz `VozPersonaje.sora` → `PaletaNeon.azulNeon`. La tensión entre
silueta violeta y voz azul es intencional: la presencia es más
"acompañante" que protagonista; el azul es el color con el que el
niño la oye.

---

## KAI — El rival amistoso

Concept-art: `concept-art/kai.pdf` (de pie) y
`concept-art/kai-hablando.pdf` (brazos cruzados, boca abierta).

Implementado en `vista/kai_presencia.dart`. Esta versión sustituye
desde 2026-05-19 la paleta anterior (rojo bermellón + dorado) que
nunca llegó a alinearse con el concept-art.

**Descripción canónica del dibujo**:

- Niño de la edad del jugador (10-13). Cara redondeada, tez clara.
- **Pelo**: morado-borgoña (`0xFF6F2247`) en picos cortos, estilo
  rebelde. El flequillo no le tapa los ojos.
- **Expresión**: ceño marcado, boca recta o entreabierta cuando
  habla. Nunca sonríe en estas láminas.
- **Cuello**: collar fino de cuentas oscuras (apenas perceptible).
- **Sudadera con capucha**: azul cielo (`0xFF3FA9DE`), holgada, le
  llega a media pierna. Cordones cayendo. Capucha visible en la
  espalda.
- **Pantalón**: morado oscuro (`0xFF5A2A4B`), corto o tres cuartos.
- **Zapatillas**: turquesa (`0xFF65D9C7`) con suela clara.
- **Postura**: brazos a los costados (lámina 1) o cruzados frente al
  pecho (lámina 2). Hombros caídos pero firmes; no es agresivo.

**Color de marca**:
- Silueta: oscura azul-violeta (`0xFF1B0C2A`).
- Contorno: azul cielo (`0xFF3FA9DE`, opacidad 0.85).
- Acento principal: mechón borgoña + capucha azul cielo.

**Voz** `VozPersonaje.kai` → `PaletaNeon.rosaAcento`. Se mantiene
por compatibilidad narrativa (las cinemáticas existentes asumen ese
tono cálido); la silueta azul cielo y la voz rosa no chocan porque
nunca se ven a la vez en el bocadillo (el nombre va arriba en rosa,
la silueta debajo en azul).

**Posición**: esquina inferior derecha (espejo de Sora). Aparece
puntualmente para interrumpir sesiones — biblia §4.3.

---

## ORYN — Maestro de Sora

Concept-art: `concept-art/oryn.pdf`.

Implementado en `vista/oryn_presencia.dart` desde 2026-05-19.

**Descripción canónica del dibujo**:

- Adulto joven, físicamente preparado. Cuerpo musculado pero
  ligero.
- **Cabeza**: completamente envuelta en vendas blancas con sombras
  lavanda (`0xFFE6DCEF` base, `0xFF9988B5` sombras). Solo se ve **un
  ojo**, intenso, verde-ámbar (`0xFF9FBC4A`). El resto del rostro
  queda oculto.
- **Torso**: traje ceñido azul (`0xFF2C5BB6`) con sombras violeta
  (`0xFF6B3F8F`) en pectorales y costados. Bordes negros marcados.
- **Bandolera**: cinta negra cruzada del hombro derecho a la cadera
  izquierda con una **cartuchera/funda** sobre la cadera izquierda
  (objeto sin identificar — un libro, un cuaderno).
- **Guantes**: azul mismo del torso, cubren hasta media muñeca.
- **Pantalón**: rojo terroso (`0xFFA0432B`), con **franja verde
  oliva** (`0xFF6A8F3E`) por el lateral exterior de cada pierna.
- **Botas**: altas hasta media pantorrilla, negras
  (`0xFF1B1B1B`) con caña gris (`0xFF6E6E6E`) en la parte inferior.
- **Postura**: de guardia marcial — puños cerrados, brazo derecho
  adelantado, brazo izquierdo a la altura del rostro. Pies abiertos.

**Color de marca**:
- Silueta: oscura azul (`0xFF0B1A33`).
- Contorno: verde-ámbar tenue (`PaletaNeon.exitoSuave`, opacidad
  0.85) — el ojo visible le da el tono.
- Acento principal: vendas blanco-lavanda en la cabeza + bandolera
  negra cruzada al torso.

**Voz** `VozPersonaje.oryn` → `PaletaNeon.exitoSuave`. Maestro
silencioso, voz rara en cinemáticas (aparece en arco 4 y como
mención de Naini en arco 3). Cuando aparece, presencia centrada.

**Posición**: centrada al pie de la pantalla (no izquierda como
Sora, no derecha como Kai) — su rol no es de compañero ni rival
sino de figura tutelar.

---

## Retratos PROVISIONALES (2026-09-23)

Hasta que lleguen los dibujos a mano, `lib/vista/personajes/retratos.dart`
resuelve el retrato de cada voz por orden de preferencia:

1. **Dibujo a mano** (`assets/personajes/<id>.png`, cuerpo entero): Kai, Oryn.
2. **Retrato ilustrado provisional** (`assets/personajes/retratos/<id>.webp`,
   busto circular): acuarelas de Las Versiones (DALL-E 3, relicenciadas
   CC-BY-SA como contenido de la Colección) viradas a la noche de Uno Roto
   con `arte/personajes/importar_de_las_versiones.py`. Asignación por
   parecido con el doc 04: Sora ← eider, Irune ← isaura, Rexán ← andres,
   Naini ← iratxe, Vadic ← arqueologo, Brina ← arqueologa, Ari ← sira.
   Ojo: son las mismas caras que en Las Versiones.
3. **Silueta provisional** (`PintorSilueta`), con el patrón de "Estilo común":
   hoy sólo Niko.

Se descartaron los personajes 3D de flavor3d: la primitiva da figuras de
bloques tipo Roblox, que chocan con el principio 4 del doc 01.

Al llegar el dibujo de alguien: PNG en `assets/personajes/<id>.png` y su id
en `personajesConDibujo`.

---

## Cómo añadir un personaje nuevo

1. Concept-art al directorio `concept-art/` (PDF o PNG escaneado).
2. Sección en este documento con los hex de cada parte de la
   indumentaria + descripción de la postura.
3. `vista/<nombre>_presencia.dart` con el patrón de Sora/Kai/Oryn:
   `_AvatarXxx` + `_PintorSiluetaXxx` + `_BocadilloXxx`.
4. `VozPersonaje.xxx` en `dominio/voz_personaje.dart` con color de
   marca elegido (que NO colisione con los existentes).
5. Cablear el avatar en las pantallas donde aparezca (combate,
   caza, cierre, escenas guiadas).
