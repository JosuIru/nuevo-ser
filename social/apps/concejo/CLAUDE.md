# Concejo — CLAUDE.md

App de la línea social (`social/`) para que un pueblo, un barrio o un colectivo **plantee sus asuntos, los debata con orden, los decida (también en papel) y siga si lo acordado se cumple**.

- **Ficha y decisiones de diseño**: `social/docs/04-concejo.md`. Leerla antes de tocar nada.
- **Criterios**: `social/docs/01-criterios.md`. Toda función nueva pasa por sus preguntas.
- **Origen**: `social/CLAUDE.md`.

## Estado

**v0.1.0 (2026-11-07): bloques F1C-1 a F1C-7.** Al abrirla se entra en un pueblo con la dirección y el código en papel, o se ve el pueblo de ejemplo (allí, el icono de cambiar de cuenta deja verla como vecina o como mesa). Funciona sin red y se sincroniza con el plugin `social/wp-plugin/concejo/`. 114 tests de Flutter y 149 comprobaciones de PHP en verde, analyze limpio, build web OK; probada contra un WordPress real (SQLite) con `test/servidor/servidor_real_test.dart`.

| Bloque | Contenido | Estado |
|---|---|---|
| F1C-1 | Esqueleto Flutter (Android, web, Linux), i18n es/eu, dominio puro con tests | ✅ |
| F1C-2 | Interfaz: lista por fases, ficha (información, debate, decidir, resultado) y «¿Se ha hecho?», con datos de ejemplo | ✅ |
| F1C-3 | Herramientas de la mesa: crear, editar, abrir y borrar borradores (con lo que falta para abrir a la vista); publicar o retirar aportaciones con motivo (queda el hueco); resumen del debate; integrar objeciones o declarar que no lo son, retirar la propia y cerrar vueltas; apuntar compromisos y marcarlos (en marcha, hecho, no se hará con motivo) | ✅ |
| F1C-4 | Canal en papel: hoja del asunto (tablón), papeletas para recortar (u hoja de objeciones) y hoja de recuento en PDF (`lib/documentos/`, letra del core); pantalla «Votos en persona» para anotar a quien vota en papel, dar de alta a quien no está y pasar el conteo firmado por dos de la mesa; la mesa recoge aportaciones y objeciones dichas en persona. El «modo asamblea» a mano alzada es esa misma pantalla | ✅ |
| F1C-5 | Acta en PDF con marca BORRADOR hasta que la firme la mesa | ✅ |
| F1C-6 | Servidor y sincronización: plugin de WordPress **aparte** (`social/wp-plugin/concejo/`, sin tocar Zunbeltz), reglas repetidas en PHP con test de paridad, cola de acciones sin red, entrar con código en papel, la mesa saca códigos e imprime la hoja | ✅ |
| F1C-7 | Avisos mínimos en la app («Para ti» y etiqueta «Nuevo») y resumen semanal por correo desde el plugin, con baja | ✅ |
| F1C-8 | APK de release y pueblo piloto | APK hecha (firma de pruebas); piloto ⏳ |
| F1C-9 | Asambleas: convocar (día, hora, lugar, orden del día con asuntos y puntos libres), cambiar o anular con motivo hasta que empieza; asistencia (con app y sin ella) y lo hablado en cada punto; convocatoria en PDF; aviso tres días antes y sección en el correo semanal | ✅ |

## Estructura

```
lib/
  dominio/      lógica pura, sin Flutter, con tests
    asunto.dart            asunto, tipo de decisión (§3), fases, reglas fijas al abrir
    reglas_decision.dart   las 4 formas de decidir, mayorías, quórum, secreto
    urna.dart              participaciones y papeletas separadas, voto presencial
    recuento.dart          recuento de votación, elección por aprobación y presupuesto
    consentimiento.dart    vueltas, objeciones razonadas y su resolución
    debate.dart            aportaciones en 4 columnas, un nivel de respuestas, anónimas moderadas
    compromiso.dart        qué/quién/cuándo y balance para «¿Se ha hecho?»
    persona.dart           roles rotativos con fecha de fin
    acta.dart              firmas del acta (dos de la mesa) y compromisos fijados al firmar
    sesion.dart            asambleas: convocatoria, orden del día, asistencia y notas
  documentos/   PDF: canal en papel (hoja del asunto, papeletas, recuento) y acta
  datos/        el estado en JSON (caché y servidor)
  estado/       EstadoConcejo, las acciones (AccionConcejo), los avisos y el pueblo de ejemplo
  servidor/     cliente HTTP, sincronizador (cola sin red) y almacén local
  pantallas/    interfaz
  l10n/         ARB es/eu y código generado (`flutter gen-l10n`)
```

**`EstadoConcejo` es la costura**: las pantallas solo hablan con esa clase. Cada método que cambia algo genera una `AccionConcejo` (con los uid que crea), la aplica y la avisa por `alHacerAccion`; el `Sincronizador` la encola, la envía y, al bajar el estado, rehace encima las que faltan. El estado se recarga en su sitio (`cargarDesde`).

## Servidor (`social/wp-plugin/concejo/`)

- **Se suben acciones, no entidades**: así el servidor puede guardar la papeleta secreta aparte y dos personas que escriben a la vez no se pisan. Cada acción lleva un uid; el servidor no aplica dos veces la misma (si se corta la red a mitad, se reenvía sin daño).
- **Las reglas están dos veces** (Dart y PHP). `test/paridad_servidor_test.dart` genera `wp-plugin/concejo/tests/paridad.json` con lo que acepta o rechaza la app y `php tests/test_paridad.php` comprueba que el plugin decide lo mismo. **Si cambias una regla**: cámbiala en los dos lados, regenera con `CONCEJO_REGENERAR=1 flutter test test/paridad_servidor_test.dart` y pasa los tests de PHP. El primer pase destapó tres fallos de la app.
- **Lo que ve cada persona** lo filtra el servidor (`includes/vista.php`): borradores solo la mesa; anónimas sin autor para todos menos quien la escribió; de las retiradas, el hueco sin el texto; papeletas solo al cerrar la votación.
- **Papeleta secreta en el servidor: sin persona, sin hora y con clave al azar.** La hora en punto que guarda la app en local bastaría para identificar a quien vota sola en esa hora.
- **Códigos personales**: 12 caracteres sin los que se confunden, se guarda su huella; son el token de la API (`Authorization: Bearer`). La mesa los saca desde la app (pantalla Personas) o desde Ajustes → Concejo; se enseñan una vez.
- **Cerrojo**: las acciones se aplican de una en una con `GET_LOCK` de MySQL; en SQLite (que no lo tiene) se sigue sin él.
- **La app guarda el código en `shared_preferences`** (privado de la app en Android). Pendiente valorar `flutter_secure_storage`.
- **Los motivos de rechazo del servidor solo están en castellano.**

Probar contra un WordPress: `CONCEJO_SERVIDOR=http://… CONCEJO_CODIGO_MESA=… CONCEJO_CODIGO_VECINA=… flutter test test/servidor/servidor_real_test.dart` (escribe en ese servidor). Cómo montar uno desechable: `social/wp-plugin/concejo/README.md`.

## Avisos y correo (F1C-7)

- **Avisos en la app** (`lib/estado/avisos.dart`), calculados del estado, sin notificaciones del sistema: asunto nuevo (dos semanas), últimos dos días para decidir (solo a quien no ha votado; en consentimiento, a todo el mundo), resultado (dos semanas), compromiso que vence en tres días o vencido (a quien lo tiene y a la mesa) y fin de mandato (dos semanas antes).
  - Arriba, en «Para ti», solo lo que pide hacer algo; «nuevo» y «hay resultado» van como etiqueta en la tarjeta y se quitan al abrir el asunto.
  - Los quitados se recuerdan por persona en el teléfono (`concejo.avisos_vistos`).
  - **El responsable de un compromiso es texto libre**: se reconoce a la persona por su nombre (sin mayúsculas ni espacios de más). Si en el piloto hace falta, se añade un `responsableUid` opcional.
- **Resumen semanal** (`wp-plugin/concejo/includes/correo.php`): los lunes, en texto plano, a quien tiene correo apuntado en Ajustes → Concejo y no lo ha apagado. No se manda si no hay nada. La baja va por enlace firmado y botón. El correo de cada persona no baja nunca a la app. **Solo en castellano** por ahora.
- **Push al móvil**: no hay. Haría falta un servicio externo (FCM) y el criterio es avisar poco; queda para después del piloto si se echa en falta.

## Decisiones tomadas en el código (revisables con el piloto)

- **Asambleas**: la convocatoria se cambia o se anula (con motivo) solo antes de empezar; asistencia y notas, desde el día de la asamblea. La asistencia es pública para el espacio (como en un acta); la gente sin app se cuenta, no se nombra. Un punto puede enlazar un asunto **abierto**. Aún no hay acta de la sesión en PDF ni firma: lo hablado queda en la app y en la convocatoria.

- **Vale para cualquier grupo**, no solo para pueblos: concejos, asociaciones, colectivos, cooperativas, comunidades de montes. Las palabras visibles son neutras («tu espacio», «participante»; arriba sale siempre el nombre del espacio) y «mesa» se queda. **Los identificadores internos no cambian** (`Rol.vecina`, `'vecina'` en el JSON y en el servidor) para no romper datos ni la paridad. El ejemplo sigue siendo un pueblo.

- **Voto secreto**: la `Participacion` (quién ha votado) y la `Papeleta` (qué se ha votado) no comparten identificador. En la app, la papeleta secreta lleva la hora redondeada a la hora en punto (en el servidor, ninguna) y entra **en una posición al azar** de la lista: si fuera al final, la papeleta n.º 5 sería la de la quinta persona en participar. En voto nominal la papeleta sí lleva persona.
- **Mayorías**:
  - **simple**: síes > noes, sin contar las abstenciones;
  - **absoluta**: síes > la mitad de los emitidos, abstenciones incluidas;
  - **dos tercios**: síes ≥ 2/3 de síes + noes.
  - El empate en simple es rechazo.
- **Quórum**: cuenta **personas que han participado**, en la app o en persona.
- **Elección entre opciones**: voto por aprobación. **Un empate se enseña y no se sortea**: lo resuelve la mesa o una segunda vuelta.
- **Presupuesto**: las propuestas se ordenan por apoyos, a igualdad la más barata y luego por orden en el asunto. Entran mientras quepan, y la que no cabe se salta. Sin apoyos no entra ninguna.
- **Consentimiento**:
  - nunca secreto: la objeción lleva nombre y motivo obligatorio;
  - la mesa puede integrarla, quien objetó puede retirarla, o la mesa marcarla como «no es objeción» con motivo;
  - si al acabar las vueltas queda alguna viva, pasa a votación o a la asamblea en persona.
- **Compromisos**: vencen al día siguiente de la fecha límite. «No se hará» exige motivo.
- **Roles**: el cargo de mesa caduca solo al pasar la fecha de fin.
- **Efecto sobre el entorno**: obligatorio para abrir un asunto, aunque sea «ninguno».
- **Permisos**: lo de la mesa lo comprueba `EstadoConcejo` (lanza `StateError`), no solo la interfaz. El servidor tendrá que repetir esas comprobaciones. Retirar una objeción solo puede hacerlo quien la planteó; integrarla o declarar que no lo es, solo la mesa.
- **Un asunto abierto antes de la fecha de debate** ya está en debate: la fecha de inicio es informativa.
- **Anónimas**: la mesa tampoco ve el nombre en pantalla, aunque se guarda para evitar abusos.
- **Plazo**: se vota (en la app o anotando en persona) solo en fase de decisión; el conteo de las papeletas en papel se puede pasar también después del cierre, porque se cuentan al cerrar.
- **Conteo**: lo firman la persona de la mesa que lo pasa y otra persona de la mesa distinta. Si las papeletas contadas no cuadran con las personas anotadas, se avisa pero no se bloquea: queda a la vista para el acta.
- **Acta**: es borrador (marca BORRADOR en cada página y aviso arriba) hasta que la firman **dos personas distintas de la mesa**, y solo se firma con el asunto decidido: acabado el plazo y, en consentimiento, con la vuelta cerrada. Cualquiera la descarga, también en borrador.
  - **Con una firma puesta, lo que recoge queda quieto**: no se pasan más conteos, no se cambia el resumen del debate ni se cierran vueltas. Para corregir, quien firmó retira su firma; con las dos, ya no se toca.
  - Los **compromisos** del acta se fijan al firmarla; los que se apunten después siguen en «¿Se ha hecho?» sin cambiar el acta.
  - El resultado sale en una tabla **app / papel / total** por opción, para rehacerlo a mano, con los conteos firmados y el aviso si no cuadran. Las fechas llevan año.
- **Recoger en persona**: lo que la mesa apunta en nombre de alguien queda con el nombre de esa persona. Pendiente decidir con el piloto si además debe constar «recogido por la mesa».

## Pendiente de revisar

- **La mesa no puede corregir un asunto ya abierto** (ni una errata). Habrá que decidir con el piloto si se permite editar el texto sin tocar las reglas, dejando constancia del cambio.

- **El euskera de `app_eu.arb` es borrador propio.** Pendiente de revisión nativa, igual que en Zunbeltz.
- **El nombre «Concejo / Kontzejua» es provisional.**
- **Las cuestiones legales** (`social/docs/04-concejo.md` §3) están pendientes de una secretaría municipal o una asesoría.

## Comandos

```bash
export PATH="$HOME/flutter/bin:$PATH"
cd social/apps/concejo
flutter gen-l10n          # tras tocar los ARB
flutter test
flutter analyze
flutter run -d linux      # o -d chrome
flutter build web --release
```
