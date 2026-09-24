import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Perfil de medición de cada habilidad (doc 02 de Las Versiones,
/// asignación copiada del CLAUDE.md del juego).
const Map<String, String> perfilDeHabilidadArchivo = {
  // P1 — identificación.
  'HF.01': idPerfilP1, 'HF.02': idPerfilP1, 'HF.03': idPerfilP1,
  'HF.04': idPerfilP1, 'HF.05': idPerfilP1,
  'CC.01': idPerfilP1, 'CC.02': idPerfilP1, 'CC.03': idPerfilP1,
  'GH.01': idPerfilP1, 'GH.02': idPerfilP1, 'GH.03': idPerfilP1,
  'GH.04': idPerfilP1, 'GH.06': idPerfilP1, 'GH.07': idPerfilP1,
  'GH.08': idPerfilP1, 'PR.02': idPerfilP1,
  'CF.01': idPerfilP1, 'CF.02': idPerfilP1, 'CF.03': idPerfilP1,
  'CF.04': idPerfilP1, 'CF.05': idPerfilP1, 'CF.06': idPerfilP1,
  'CF.07': idPerfilP1, 'CF.08': idPerfilP1, 'CF.09': idPerfilP1,
  'CF.10': idPerfilP1, 'CF.11': idPerfilP1, 'CF.12': idPerfilP1,
  // P2 — detección (clasificación esto-sí / esto-no).
  'HF.06': idPerfilP2, 'HF.07': idPerfilP2, 'HF.08': idPerfilP2,
  'HF.09': idPerfilP2, 'HF.11': idPerfilP2, 'HF.12': idPerfilP2,
  'CC.05': idPerfilP2, 'CC.06': idPerfilP2,
  'PH.01': idPerfilP2, 'PH.04': idPerfilP2, 'PH.05': idPerfilP2,
  'PH.10': idPerfilP2, 'AH.04': idPerfilP2, 'AH.05': idPerfilP2,
  'PR.03': idPerfilP2,
  // P4 — calibración epistémica.
  'AH.03': idPerfilP4,
};

/// Perfiles que el core calcula de verdad hoy. P4 sigue siendo un stub
/// que lanza `UnimplementedError`: hasta que exista, sus habilidades no
/// se registran (mejor no apuntar que apuntar mal, principio 5).
const Set<String> perfilesOperativos = {idPerfilP1, idPerfilP2};

const Map<String, ProfileConfig> _configuracionDePerfil = {
  idPerfilP1: ProfileConfig.defaultP1,
  idPerfilP2: ProfileConfig.defaultP2,
};

/// Motor de maestría de Las Versiones: el `MasteryEngine` del core con
/// la persistencia por perfil de `RepositorioHabilidades`
/// (`nuevoser.lasversiones.perfil.<id>.habilidad.<HF.02>`).
///
/// Sólo se llama con decisiones de acierto o fallo claros y en su
/// primer intento. Los registros se encadenan en orden para que dos
/// seguidos de la misma habilidad no se pisen al leer y escribir.
class RegistroMaestriaArchivo {
  RegistroMaestriaArchivo({
    required this.repositorio,
    MasteryEngine? motor,
    DateTime Function()? reloj,
  })  : _motor = motor ?? MasteryEngine(),
        _reloj = reloj ?? DateTime.now;

  final RepositorioHabilidades repositorio;
  final MasteryEngine _motor;
  final DateTime Function() _reloj;
  Future<void> _cola = Future.value();

  /// `true` si [idHabilidad] tiene perfil asignado y el core lo calcula.
  static bool registrable(String idHabilidad) =>
      perfilesOperativos.contains(perfilDeHabilidadArchivo[idHabilidad]);

  /// Apunta un intento. Devuelve el estado nuevo, o `null` si la
  /// habilidad no es registrable todavía.
  ///
  /// Las habilidades P2 necesitan [senalEsperada] (¿el caso era de la
  /// clase «sí»?) y [clasePredicha] (¿qué dijo la Cronista?); sin ellas
  /// no se apuntan. En P2 el acierto es que coincidan.
  Future<EstadoHabilidad?> registrar({
    required String idHabilidad,
    required bool acierto,
    required Duration duracion,
    double dificultad = 1.0,
    bool? senalEsperada,
    bool? clasePredicha,
  }) {
    if (!registrable(idHabilidad)) return Future.value(null);
    final idPerfil = perfilDeHabilidadArchivo[idHabilidad]!;
    final esDeteccion = idPerfil == idPerfilP2;
    if (esDeteccion && (senalEsperada == null || clasePredicha == null)) {
      return Future.value(null);
    }
    final resultado = _cola.then((_) async {
      final previo =
          await repositorio.cargar(idHabilidad) ?? EstadoHabilidad.inicial(idHabilidad);
      final nuevo = _motor.actualizarMaestria(
        previo: previo,
        idPerfil: idPerfil,
        config: _configuracionDePerfil[idPerfil]!,
        payload: SessionPayload(
          acierto: esDeteccion ? senalEsperada == clasePredicha : acierto,
          senalEsperada: esDeteccion ? senalEsperada : null,
          clasePredicha: esDeteccion ? clasePredicha : null,
          dificultad: dificultad.clamp(0.5, 2.0),
          duracionSegundos: duracion.inSeconds,
          instante: _reloj(),
        ),
      );
      await repositorio.guardar(nuevo);
      return nuevo;
    });
    _cola = resultado.then((_) {}, onError: (_) {});
    return resultado;
  }
}
