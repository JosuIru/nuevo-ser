import '../dominio/motor_maestria.dart';
import 'catalogo_habilidades.dart';
import 'repositorio_progreso.dart';

/// Motor de maestría para las máquinas de Rexán, montado igual que en
/// el cazadero: mismas reglas, misma persistencia y los mismos flags al
/// subir de nivel. Las máquinas sólo registran decisiones con acierto o
/// fallo claros — nunca inflan el progreso (doc 01, principio 5).
class RegistroMaestriaMinijuego {
  final RepositorioProgreso repositorio;
  MotorMaestria? _motor;

  RegistroMaestriaMinijuego(this.repositorio);

  Future<void> preparar() async {
    final catalogo = await CatalogoHabilidades.cargar();
    _motor = MotorMaestria(
      catalogo: catalogo,
      cargarEstado: repositorio.cargarEstadoHabilidad,
      guardarEstado: repositorio.guardarEstadoHabilidad,
      alSubirNivel: (idHabilidad, nivel) async {
        await repositorio.activarFlagNarrativo(
          MotorMaestria.flagDeMaestria(idHabilidad, nivel),
        );
      },
    );
  }

  /// Silencioso si el motor aún no está listo, como en el cazadero.
  Future<void> registrar({
    required String idHabilidad,
    required bool acierto,
    required double dificultad,
    required Duration duracion,
  }) async {
    final motor = _motor;
    if (motor == null) return;
    await motor.registrarResultado(
      idHabilidad: idHabilidad,
      acierto: acierto,
      dificultad: dificultad,
      duracionSegundos: duracion.inSeconds.clamp(1, 600),
    );
  }
}
