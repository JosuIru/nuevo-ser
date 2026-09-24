# nuevo_ser_core

Plataforma compartida de la **Colección Nuevo Ser Kids**.

## Estado de la extracción

Avance acumulado desde el Chunk 5 — el paquete re-exporta vía `package:nuevo_ser_core/nuevo_ser_core.dart`:

```
lib/src/
├── audio/
│   ├── capa_audio.dart                          ← enum 4 capas (ambient/musica/efectos/narrativos) + defaultsPorClave
│   ├── descargador_audio.dart                   ← cliente paquete sonoro (manifest + descarga + sha256 + descompresión) con callbacks invertidos
│   ├── repositorio_sugerencia_paquete_audio.dart ← bool del banner "¿descargar paquete?" (global, una vez visto no reaparece)
│   └── repositorio_version_paquete_audio.dart   ← versión instalada del paquete (global, pareja del descargador)
├── mastery/
│   ├── habilidad.dart                  ← Habilidad, NivelMaestria, IntentoHabilidad, EstadoHabilidad
│   ├── mastery_engine.dart             ← motor adaptativo Strategy (C6)
│   ├── mastery_profile.dart            ← contrato MasteryProfile + SessionPayload (C6)
│   ├── perfiles/p1_precision.dart      ← P1 funcional (C6)
│   ├── perfiles/p2_detection.dart      ← stub (C6)
│   ├── perfiles/p3_construction.dart   ← stub (C6)
│   ├── perfiles/p4_calibration.dart    ← stub (C6)
│   └── selector_habilidades.dart       ← selector adaptativo genérico
├── quiz/
│   ├── pregunta_quiz.dart              ← ElementoQuiz (catálogo), OpcionQuiz, PreguntaQuiz
│   ├── generador_preguntas_quiz.dart   ← distractores por parecido (confundibles > mismo grupo > resto), semilla, sin reposición
│   ├── sesion_quiz.dart                ← rondas fijas, un solo intento por pregunta, callback para el motor de maestría
│   └── calibracion_quiz.dart           ← confianza declarada (alta/media/baja) + Brier binario + tendencia (sobreconfianza/timidez)
├── storage/
│   ├── gestor_perfiles.dart                ← multi-perfil sobre SharedPreferences + PerfilInfo
│   ├── repositorio_avatar_perfil.dart      ← ruta a la imagen-avatar del niño (por perfil)
│   ├── repositorio_cuenta_backend.dart     ← token JWT + email del backend (global, no por-perfil)
│   ├── repositorio_habilidades.dart        ← persistencia JSON de EstadoHabilidad por perfil + exportarParaSync
│   ├── repositorio_idioma_app.dart         ← código de idioma elegido en el primer arranque (global)
│   └── repositorio_preferencias_audio.dart ← modo silencio + volumen por capa, por perfil
└── sync/
    ├── cliente_api.dart                ← ClienteApi, ExcepcionApi (REST con plugin WP)
    └── fecha_mysql.dart                ← formato YYYY-MM-DD HH:MM:SS UTC
```

**Quiz de identificación** (`quiz/` + `ui/vista_quiz.dart`): extraído del quiz de Fósiles (cuadernos-de-campo). Cualquier juego o app lo monta sobre su propio catálogo. En Kids: sin marcador ni rojo por defecto (`ColoresDevolucionQuiz`) e imágenes locales vía `constructorImagen`. Las apps de adulto pueden activar el marcador y los colores verde/rojo. Diseño de uso por juego en `apps/las-versiones/docs/el-atico-de-andres.md` §11.

Los demás submódulos previstos (`account/`, `i18n/`, `narrative/`) siguen vacíos a la espera de la próxima ronda de extracción.

## Deuda de extracción pendiente

| Pieza candidata | Por qué se queda en `apps/uno-roto/` | Plan |
|---|---|---|
| Resto de `repositorio_progreso.dart` (~550 LOC) | Concepts juego-específicos (arco, rango narrativo, ritmo, distrito, esquirlas, flags, variantes de entrenamiento, audio por capa). Convierte el shape del backend en lecturas/escrituras de SharedPreferences. | Definir un `RepositorioJuego` específico de uno-roto que use el `GestorPerfiles` del core; el repositorio actual queda como ese específico. |
| `escena_cinematica.dart`, `plano_escena.dart` | Dependen de `voz_personaje` y `ambiente_cielo` (modelos de Uno Roto). | Definir modelos abstractos en `narrative/` y dejar la capa específica en la app. |
| `servicio_sonoro.dart`, `catalogo_sonidos.dart` y resto de `lib/sonido/` | `servicio_sonoro` depende de `repositorio_progreso`; los catálogos son del juego concreto. | Salen detrás de `repositorio_progreso`. |
| `localizador_audio.dart` | Depende del catálogo del juego (`CatalogoSonidos`) para mapear ids lógicos a rutas concretas en cache + asset bundle. | Sale detrás del catálogo de sonidos. |

El motor adaptativo, el selector de habilidades, la gestión multi-perfil y la persistencia JSON de habilidades/tutor ya tienen su núcleo aquí; lo que queda en `apps/uno-roto/` son facades/wrappers finos que inyectan los acoplamientos juego-específicos (catálogo, distritos, conjunto de habilidades con puzzle implementado, claves globales del juego concreto) y delegan en la plataforma.

Mantener la separación cuesta menos que extraer y luego revertir: el principio aquí es "mover solo lo genuinamente reutilizable hoy".

## Submódulos previstos

```
lib/src/
├── account/    autenticación, perfiles
├── sync/       cliente HTTP, last-write-wins, cola offline      ← parcial
├── mastery/    motor adaptativo, selector de habilidades        ← parcial
├── storage/    persistencia
├── i18n/       utilidades de localización
├── audio/      capa sonora, descargador de paquetes
└── narrative/  sistema de cinemáticas genérico
```

## Deuda técnica explícita

- **Persistencia**: Uno Roto sigue usando `shared_preferences` con whitelist global y prefijos por perfil (`uroto.perfil.<id>.<sufijo>`). El doc de arquitectura prescribe Isar (`coleccion-nuevo-ser/plataforma/nuevo-ser-core-arquitectura.md` §3.1). **Migración a Isar diferida a v1.5** — no entra en este refactor para no inflar el alcance ni romper la promesa "tests existentes pasan idénticos" del Chunk 8.
- **Claves de persistencia**: el prefijo `uroto.*` se mantiene para Uno Roto. Juegos nuevos (Las Versiones, El Cuaderno) usarán `nuevoser.<juego>.*`. Renombrado uniforme diferido a v1.5.

## Licencia

AGPL-3.0 — coherente con el resto de la Colección Nuevo Ser.
