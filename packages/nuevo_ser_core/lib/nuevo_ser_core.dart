/// Plataforma compartida de la Colección Nuevo Ser Kids.
///
/// Submódulos previstos en el plan de extracción (`coleccion-nuevo-ser/
/// plataforma/nuevo-ser-core-arquitectura.md` §8.2):
///   - `src/account/`   — autenticación, perfiles
///   - `src/sync/`      — cliente HTTP, last-write-wins, cola offline
///   - `src/mastery/`   — motor adaptativo, selector de habilidades
///   - `src/storage/`   — persistencia (shared_preferences hoy, Isar v1.5)
///   - `src/i18n/`      — utilidades de localización
///   - `src/audio/`     — capa sonora, descargador de paquetes
///   - `src/narrative/` — sistema de cinemáticas genérico
///   - `src/foto/`      — captura y persistencia de fotos del usuario
///   - `src/csv/`       — lectura y escritura de tablas CSV de bajo nivel
///   - `src/pdf/`       — plantillas de informes PDF con estilo consistente
///
/// Estado de la extracción tras F1.3:
///   - mastery:   modelos (`Habilidad`, `EstadoHabilidad`, `IntentoHabilidad`),
///                motor adaptativo (`MasteryEngine` + 4 `MasteryProfile`:
///                P1, P2, P3 y P4 funcionales).
///   - sync:      `ClienteApi`, `ExcepcionApi`.
///   - storage:   gestor de perfiles, repositorios de avatar, idioma,
///                habilidades, cuenta backend, preferencias de audio.
///   - audio:     enum `CapaAudio`, descargador, repositorios de versión
///                y sugerencia del paquete sonoro.
///   - narrative: contratos genéricos de cinemáticas — `VozPersonajeContrato`,
///                `AmbienteEscenaContrato` (+ `AmbienteEscenaNeutro`),
///                `OpcionEleccion`, `PlanoEscena` (+ `PlanoAmbiente`,
///                `PlanoDialogo`, `PlanoEleccion`, `PlanoCierreAmable`)
///                y `EscenaCinematica`. Cada juego añade sus voces y
///                planos específicos extendiendo los contratos.
library nuevo_ser_core;

export 'src/audio/capa_audio.dart';
export 'src/audio/descargador_audio.dart';
export 'src/audio/repositorio_sugerencia_paquete_audio.dart';
export 'src/audio/repositorio_version_paquete_audio.dart';
export 'src/csv/csv_io.dart';
export 'src/foto/gestor_fotos.dart';
export 'src/pdf/guardar_pdf.dart';
export 'src/pdf/informe_periodico.dart';
export 'src/pdf/widgets_pdf.dart';
// Nota: el módulo `calibration/` se expone por path explícito desde
// los juegos que lo necesitan, no desde este barrel — `NivelConfianza`
// es un nombre que otros juegos (p. ej. el-cuaderno) usan para
// conceptos no relacionados con calibración Brier, así que evitamos
// la colisión vía barrel. Los juegos que lo quieran hacen
// `import 'package:nuevo_ser_core/src/calibration/nivel_confianza.dart';`
// directamente.
export 'src/mastery/habilidad.dart';
export 'src/mastery/mastery_engine.dart';
export 'src/mastery/mastery_profile.dart';
export 'src/mastery/perfiles/p1_precision.dart';
export 'src/mastery/perfiles/p2_detection.dart';
export 'src/mastery/perfiles/p3_construction.dart';
export 'src/mastery/perfiles/p4_calibration.dart';
export 'src/mastery/perfiles/p5_compuesto.dart';
export 'src/mastery/selector_habilidades.dart';
export 'src/narrative/ambiente_escena.dart';
export 'src/narrative/escena_cinematica.dart';
export 'src/narrative/opcion_eleccion.dart';
export 'src/narrative/plano_escena.dart';
export 'src/narrative/voz_personaje.dart';
// Quiz de identificación genérico, extraído del de Fósiles: catálogo →
// preguntas con distractores por parecido, sesión de rondas fijas y
// calibración opcional de la confianza.
export 'src/quiz/calibracion_quiz.dart';
export 'src/quiz/generador_preguntas_quiz.dart';
export 'src/quiz/pregunta_quiz.dart';
export 'src/quiz/sesion_quiz.dart';
export 'src/storage/gestor_perfiles.dart';
export 'src/storage/repositorio_avatar_perfil.dart';
export 'src/storage/repositorio_cuenta_backend.dart';
export 'src/storage/repositorio_habilidades.dart';
export 'src/i18n/solera_l10n.dart';
export 'src/storage/repositorio_idioma_app.dart';
export 'src/storage/repositorio_preferencias_audio.dart';
export 'src/sync/cliente_api.dart';
export 'src/sync/fecha_mysql.dart';
// Widgets UI compartidos por la suite Solera (Viticultura, Apícola,
// Arbolado Urbano) y candidatos a otras apps que necesiten formularios
// con catálogo + IA.
export 'src/ui/accesos_directos.dart';
export 'src/ui/barra_busqueda.dart';
export 'src/ui/banner_coincidencia_catalogo.dart';
export 'src/ui/cruz_centro_mapa.dart';
export 'src/ui/campo_autocomplete_catalogo.dart';
export 'src/ui/dialogo_confirmacion.dart';
export 'src/ui/vista_quiz.dart';
export 'src/ui/galeria_imagenes.dart';
export 'src/ui/indicador_estado.dart';
export 'src/ui/selector_fotos.dart';
export 'src/ui/selector_idioma.dart';
export 'src/ui/tarjeta_observacion.dart';
export 'src/ui/tarjeta_resumen.dart';
export 'src/actualizaciones/banner_actualizacion.dart';
export 'src/actualizaciones/checker_actualizaciones.dart';
