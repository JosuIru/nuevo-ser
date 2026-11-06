# Concejo — CLAUDE.md

App de la línea social (`social/`) para que un pueblo, un barrio o un colectivo **plantee sus asuntos, los debata con orden, los decida (también en papel) y siga si lo acordado se cumple**.

- **Ficha y decisiones de diseño**: `social/docs/04-concejo.md`. Leerla antes de tocar nada.
- **Criterios**: `social/docs/01-criterios.md`. Toda función nueva pasa por sus preguntas.
- **Origen**: `social/CLAUDE.md`.

## Estado

**v0.1.0 (2026-11-06): bloques F1C-1 y F1C-2.** Funciona en memoria con un pueblo de ejemplo. Todavía no hay servidor ni persistencia. 40 tests verdes, analyze limpio, build web OK.

| Bloque | Contenido | Estado |
|---|---|---|
| F1C-1 | Esqueleto Flutter (Android, web, Linux), i18n es/eu, dominio puro con tests | ✅ |
| F1C-2 | Interfaz: lista por fases, ficha (información, debate, decidir, resultado) y «¿Se ha hecho?», con datos de ejemplo | ✅ |
| F1C-3 | Herramientas de la mesa: crear y abrir asuntos en borrador, moderar anónimas, resumen del debate, cerrar vueltas de consentimiento y resolver objeciones, apuntar compromisos | ⏳ |
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

## Pendiente de revisar

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
