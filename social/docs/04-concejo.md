# Concejo — ficha v0.1

> **Concejo** (nombre provisional; eu *Kontzejua*, provisional). App para que la gente de un pueblo o un barrio **plantee sus asuntos, los debata con orden, los decida y compruebe que lo acordado se cumple**. Ordenanzas, presupuestos, fiestas, el uso del comunal, la obra de la plaza.
>
> Estado: propuesta, 2026-11-06. Sin código. Necesita un pueblo piloto.

## 1. El problema

En un pueblo las decisiones se toman en el bar, en un grupo de WhatsApp donde se pierde todo o en una asamblea a la que van siempre los mismos. Pasa esto:

- La información no llega igual a todos. Lo que se presenta en el pleno ya viene decidido.
- Quien trabaja fuera, cuida de alguien o no se atreve a hablar en público no participa.
- Nadie sabe al cabo de seis meses qué se acordó ni si se hizo.

Los concejos abiertos, los batzarres y las juntas vecinales llevan siglos resolviéndolo en persona. **Concejo no los sustituye: les da memoria, alcance y orden.**

## 2. Para quién

| Quién | Cómo lo usaría |
|---|---|
| **Concejos de Navarra y entidades locales menores** (juntas vecinales, pedanías) | Preparar el batzarre o la junta: asuntos, documentación, debate previo, acta y seguimiento |
| **Municipios en concejo abierto** (art. 29 LBRL; menos de 100 habitantes o por tradición) | La asamblea vecinal es el órgano de gobierno: Concejo prepara y documenta sus sesiones |
| **Ayuntamientos pequeños** con presupuestos participativos o consultas no vinculantes | Proceso participativo con fases y seguimiento de la ejecución |
| **Comunidades de montes vecinales en mano común**, comunidades de regantes | Asambleas de comuneros: cuentas, aprovechamientos, reglas |
| **Asociaciones vecinales, colectivos y cooperativas** | Decisiones internas según sus estatutos |

Tamaño: de 10 a 300 personas. Si es más grande, se divide por barrios.

## 3. Qué vale jurídicamente (hay que decirlo claro en la app)

**Concejo no da validez legal a nada por sí solo.** Cada asunto dice en su cabecera qué tipo de decisión es:

| Tipo | Qué significa | Ejemplo |
|---|---|---|
| **Vinculante por el propio grupo** | El grupo decide sobre lo suyo según sus estatutos o normas | Una asociación cuyos estatutos admiten el voto a distancia; las reglas de uso del local vecinal |
| **Con compromiso previo** | El órgano formal (concejo, pleno, junta) **se compromete por escrito antes** a ejecutar lo que salga, si se cumplen unas condiciones de participación. Es lo que los libros llaman darle «dientes» | «La junta ejecutará la propuesta más votada del presupuesto participativo si participan al menos 40 vecinos» |
| **Consultiva** | Sirve para que el órgano formal sepa qué piensa la gente; decide él | Sondeo sobre el horario de las fiestas antes del pleno |

Matices legales que la app respeta (a revisar con secretaría municipal o asesoría jurídica):

- **No es una «consulta popular» del art. 71 LBRL.** Esas las tiene que autorizar el Estado, y un ayuntamiento no puede montarlas por su cuenta. Concejo hace **procesos de participación ciudadana**, que regulan los reglamentos de participación municipales y las leyes autonómicas de participación. Nunca usa la palabra «referéndum».
- **En concejo abierto**, la asamblea vecinal decide en su sesión y con su normativa. Concejo sirve para la convocatoria, el orden del día, la documentación, el debate previo, el registro de la sesión y el acta. **El voto formal se hace como diga la norma de esa entidad**, normalmente en persona.
- **Datos personales**: el censo de participantes lo gestiona la entidad, que es la responsable del tratamiento. Concejo guarda lo mínimo (nombre y contacto) y lo puede borrar.

## 4. Primer día útil (F1)

Una junta vecinal tiene que poder hacer esto la primera semana:

> Plantear «¿Cambiamos la fecha de las fiestas?», con la información a la vista; dejar diez días para que la gente opine con orden; votar (en la app o en papel en el bar o el concejo); sacar un acta en PDF; y que dentro de dos meses se vea si se hizo.

### 4.1 El pueblo y las personas

- Un **espacio** por pueblo, barrio o colectivo: nombre, idiomas y normas básicas (quién puede participar, quórum por defecto).
- **Altas sin papeleo**: dos personas de la mesa dan de alta a un vecino y le entregan un **código personal en papel** (o por correo o SMS). En un pueblo, la propia gente sabe quién es vecina: no hace falta pedir DNI.
- **Roles rotativos con fecha de fin**: *vecina* (participa), *mesa* (2-3 personas que abren asuntos, moderan, apuntan los votos en papel y firman el acta) y *coordinación*. La app avisa cuando un mandato se acaba.

### 4.2 Asuntos

Cada asunto tiene:

- **Resumen en tres líneas** arriba, en lectura fácil, y el texto completo y los documentos debajo (fotos, PDF del presupuesto, plano).
- **Qué se decide y qué tipo de decisión es** (§3), y quién se compromete a qué.
- **Coste**, si lo tiene.
- **Efecto sobre el entorno** (agua, monte, ruido, paisaje, animales): un campo obligatorio, aunque sea «ninguno». Es la forma práctica de dar voz a la naturaleza en las decisiones.
- **Calendario visible**: debate → decisión → seguimiento, con fechas.

### 4.3 Debate con orden (no un chat)

- Cada aportación se etiqueta: **a favor**, **en contra**, **duda** o **propuesta de cambio**. Se ven en columnas.
- Las respuestas tienen un solo nivel: sin hilos infinitos.
- **Sin «me gusta» ni contadores.** Para apoyar una aportación, se dice por qué.
- La mesa puede escribir un **resumen del debate** que se fija arriba. La gente puede discutirlo.
- Se puede aportar con el nombre visible o como «vecina del pueblo». **Lo anónimo lo modera la mesa.**

### 4.4 Decidir: cuatro formas, elegidas antes de abrir

Las reglas (forma, quórum y mayoría) **se fijan antes de abrir el asunto y no se pueden cambiar después**. Se ven desde el principio.

| Forma | Cuándo | Cómo |
|---|---|---|
| **Votación** | Sí o no claros | Sí / No / Abstención. Secreta o nominal. Quórum y mayoría configurables |
| **Elegir entre opciones** | Fechas, diseños, alternativas | Cada persona marca **todas las opciones que acepta** (voto por aprobación). Gana la más aceptada. Se explica en una línea y es difícil de manipular |
| **Consentimiento** | Reglas internas, acuerdos de grupo | Se aprueba si nadie plantea una **objeción razonada** («esto causa este daño»). Las objeciones se integran en la propuesta y se vuelve a preguntar. Si en dos vueltas no se resuelve, pasa a votación o a la asamblea en persona |
| **Presupuesto** | Presupuestos participativos | Bolsa de dinero y propuestas con su coste. Cada persona apoya las que quiera. Entran por orden de apoyos mientras haya bolsa. **La regla se publica antes** y el resultado se puede recalcular a mano |

**Voto secreto de verdad**: la lista de quién ha votado y las papeletas van en tablas separadas, sin identificador común, con la hora redondeada y el orden mezclado. Así se puede saber quién ha votado, pero no qué ha votado cada persona. La documentación dirá con honestidad que quien administra el servidor podría, con esfuerzo, intentar cruzar datos, y que la defensa está en el diseño y en que el servidor sea **del propio pueblo**.

### 4.5 El canal en papel (obligatorio, no opcional)

- **Hoja del asunto imprimible** (resumen, opciones y calendario) para el tablón del concejo, el bar o el consultorio.
- **Papeleta imprimible** y **voto presencial**: la mesa marca en la app «ha votado en persona» (para que nadie vote dos veces) y suma las papeletas al final, con un **acta de mesa** firmada por dos personas. Los votos presenciales se cuentan aparte y luego se suman, y así se ve.
- **Modo asamblea**: en una reunión en la plaza, la mesa apunta rápido las intervenciones y el resultado de la votación a mano alzada. Sirve de borrador del acta.
- **Correo semanal** con los asuntos abiertos para quien no use la app.

### 4.6 Acta y seguimiento

- **Acta en PDF** al cerrar: asunto, reglas, participación, resultado y resumen del debate, con la marca **BORRADOR** hasta que la firme la mesa (patrón de Zunbeltz).
- Cada acuerdo genera **compromisos**: qué, quién y para cuándo. Estado: pendiente / en marcha / hecho / no se hará (con motivo).
- **Página «¿Se ha hecho?»** con todos los acuerdos del año y su estado. Es la que más confianza da y la que pide el libro: que la participación no sea teatro.
- Aviso a la persona responsable cuando vence un compromiso.

### 4.7 Avisos y salida

- Solo avisa de: asunto nuevo, últimos dos días para opinar o votar, resultado y compromiso que vence (a la persona responsable).
- Todo lo demás va al resumen semanal, que cada cual puede apagar.
- **Exportar todo** (CSV y PDF de actas) en cualquier momento.

## 5. Fuera de la F1

- Delegación de voto por tema.
- Sorteo para comisiones.
- Buzón anónimo y retrospectiva.
- Federación entre pueblos (asuntos comarcales).
- Traducción automática.
- Resúmenes con IA (posible en F2, siempre revisados por la mesa y marcados como tales).
- Voto sin conexión.

## 6. Técnica

| Pieza | Decisión | De dónde sale |
|---|---|---|
| App | Flutter: Android + web (la web sirve para el ordenador del concejo) | Patrón de la suite |
| Servidor | **Plugin de WordPress** que aloja el propio pueblo (hosting barato o el de la diputación o la mancomunidad) | `wp-plugin/solera-zunbeltz-sync/`: personas con token, roles, revisiones, panel, correos e i18n |
| Base común | Extraer de Zunbeltz las personas, los roles, la sync, los avisos y el correo a un paquete compartido (ver `03-catalogo-apps.md`) | Zunbeltz |
| PDF | `nuevo_ser_core/src/pdf/` + marca BORRADOR | Core + Zunbeltz |
| Voto | Tablas separadas de participación y papeletas; recuento reproducible con test | Nuevo |
| Sin conexión | Leer asuntos y debate sin red; para votar hace falta red (o papel) | — |
| Idiomas | es/eu en la F1; ca/gl con revisión nativa | — |

Tests antes del código no visual: el recuento de las cuatro formas de decidir, el quórum, la separación del voto secreto, la suma de votos presenciales y el estado de los compromisos.

## 7. Estimación

**~3 semanas** de trabajo efectivo, gracias a lo que ya hay en Zunbeltz:

| Bloque | Tiempo |
|---|---|
| Extraer la base común | 1 semana |
| Asuntos, debate y las cuatro formas de decidir | 1 semana |
| Canal en papel, acta, seguimiento, pruebas y piloto | 1 semana |

## 8. Bloqueos y preguntas abiertas

1. **Pueblo piloto.** Mejor un concejo de Navarra o una junta vecinal con alguien con ganas en la mesa.
2. **Revisión legal** por una secretaría municipal o una asesoría: qué tipos de decisión (§3) encajan en cada figura (concejo, concejo abierto, junta vecinal, asociación) y la ley de participación de cada comunidad autónoma.
3. **Nombre definitivo** y su forma en euskera, revisada por una persona nativa.
4. **Quién mantiene los servidores** de los pueblos que no puedan alojarse solos: ¿la mancomunidad, la Colección, una cooperativa de servicios?

## Fuentes

- Ley 7/1985 (LBRL): art. 29 (concejo abierto) y art. 71 (consultas populares), comprobados en fuentes secundarias el 2026-11-06. **Verificar el texto consolidado en el BOE**:
  - [art. 29 (Gobierto)](https://contratos.gobierto.es/normativa/ley-bases-regimen-local/29)
  - [art. 71 (Gobierto)](https://contratos.gobierto.es/normativa/ley-bases-regimen-local/71)
  - [consultas al margen del art. 71 (derecholocal.es)](https://derecholocal.es/?p=2196)
  - [concejo abierto (glosario)](https://redopositor.com/glosario/concejo-abierto/)
- Libros de la Colección: ver `02-fuentes-coleccion.md` (consentimiento, presupuestos con «dientes», roles rotativos, participación que no sea teatro, voz de la naturaleza).
