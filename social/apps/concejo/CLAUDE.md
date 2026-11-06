# Concejo — CLAUDE.md

App de la línea social (`social/`) para que un pueblo, un barrio o un colectivo **plantee sus asuntos, los debata con orden, los decida (también en papel) y siga si lo acordado se cumple**.

- **Ficha y decisiones de diseño**: `social/docs/04-concejo.md`. Leerla antes de tocar nada.
- **Criterios**: `social/docs/01-criterios.md`. Toda función nueva pasa por sus preguntas.
- **Origen**: `social/CLAUDE.md`.

## Estado

**v0.1.0 (2026-11-06): bloques F1C-1, F1C-2 y F1C-3.** Funciona en memoria con un pueblo de ejemplo; el menú de la barra superior (icono de cambiar de cuenta) deja verla como vecina o como mesa. Todavía no hay servidor ni persistencia. 52 tests verdes, analyze limpio, build web OK.

| Bloque | Contenido | Estado |
|---|---|---|
| F1C-1 | Esqueleto Flutter (Android, web, Linux), i18n es/eu, dominio puro con tests | ✅ |
| F1C-2 | Interfaz: lista por fases, ficha (información, debate, decidir, resultado) y «¿Se ha hecho?», con datos de ejemplo | ✅ |
| F1C-3 | Herramientas de la mesa: crear, editar, abrir y borrar borradores (con lo que falta para abrir a la vista); publicar o retirar aportaciones con motivo (queda el hueco); resumen del debate; integrar objeciones o declarar que no lo son, retirar la propia y cerrar vueltas; apuntar compromisos y marcarlos (en marcha, hecho, no se hará con motivo) | ✅ |
| F1C-4 | Canal en papel: hoja del asunto y papeleta en PDF, anotar voto presencial, conteo firmado por dos, modo asamblea | ⏳ |
| F1C-5 | Acta en PDF con marca BORRADOR hasta que la firme la mesa | ⏳ |
| F1C-6 | Persistencia local y servidor: plugin de WordPress del propio pueblo (base común extraída de Zunbeltz), altas con código en papel, sincronización | ⏳ |
| F1C-7 | Avisos mínimos y correo semanal | ⏳ |
| F1C-8 | APK de release y pueblo piloto | ⏳ |

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
  estado/       EstadoConcejo (ChangeNotifier en memoria) y el pueblo de ejemplo
  pantallas/    interfaz
  l10n/         ARB es/eu y código generado (`flutter gen-l10n`)
```

**`EstadoConcejo` es la costura**: las pantallas solo hablan con esa clase. En F1C-6 se le pone detrás la persistencia y la sincronización sin tocar las pantallas.

## Decisiones tomadas en el código (revisables con el piloto)

- **Voto secreto**: la `Participacion` (quién ha votado) y la `Papeleta` (qué se ha votado) no comparten identificador. La papeleta secreta lleva la hora redondeada a la hora en punto y entra **en una posición al azar** de la lista: si fuera al final, la papeleta n.º 5 sería la de la quinta persona en participar. En voto nominal la papeleta sí lleva persona.
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
