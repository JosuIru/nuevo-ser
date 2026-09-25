import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../dominio/motor_maestria.dart';
import '../dominio/nivel_escolar.dart';
import 'catalogo_habilidades.dart';
import 'repositorio_progreso.dart';

/// Fija el punto de partida de un perfil (prueba de nivel o adulto) y
/// da por sabido lo de los cursos anteriores: esas habilidades pasan a
/// «competente», así lo que depende de ellas se abre y el selector
/// prioriza lo nuevo.
///
/// - No toca lo que ya esté en competente o maestría (lo ha demostrado).
/// - No inventa exposiciones: el bestiario cuenta encuentros de verdad.
/// - Si más tarde falla en algo dado por sabido, el motor de maestría
///   lo baja como siempre y vuelve a salir.
///
/// Devuelve cuántas habilidades se han dado por sabidas.
Future<int> aplicarNivelDePartida(
  RepositorioProgreso repositorio,
  NivelEscolar nivel, {
  required String origen,
  CatalogoHabilidades? catalogo,
  DateTime? ahora,
}) async {
  await repositorio.guardarNivelEscolar(nivel, origen: origen);
  final habilidades = (catalogo ?? await CatalogoHabilidades.cargar()).habilidades.values;
  final momento = ahora ?? DateTime.now();
  var sembradas = 0;
  for (final habilidad in habilidades) {
    if (!seDaPorSabida(habilidad.curso, nivel)) continue;
    final actual = await repositorio.cargarEstadoHabilidad(habilidad.identificador) ??
        EstadoHabilidad.inicial(habilidad.identificador);
    if (actual.nivel.index >= NivelMaestria.competente.index) continue;
    await repositorio.guardarEstadoHabilidad(actual.copiarCon(
      nivel: NivelMaestria.competente,
      precision: actual.precision < 0.8 ? 0.8 : actual.precision,
      sesionesConsecutivasBuenas:
          actual.sesionesConsecutivasBuenas < 3 ? 3 : actual.sesionesConsecutivasBuenas,
      ultimaPractica: momento,
    ));
    sembradas++;
  }
  await asegurarFlagsDeMaestria(repositorio, catalogo: catalogo);
  return sembradas;
}

/// Activa los flags narrativos de maestría (`fr_05_competente`…) de
/// cada habilidad hasta el nivel que tiene. El motor los activa al
/// subir de nivel; lo sembrado por el punto de partida no ha subido,
/// y sin ellos las escenas que esperan esos flags (la 1.9, la 2.6…)
/// no llegarían nunca. Idempotente: se puede llamar en cada arranque.
Future<void> asegurarFlagsDeMaestria(RepositorioProgreso repositorio, {CatalogoHabilidades? catalogo}) async {
  final habilidades = (catalogo ?? await CatalogoHabilidades.cargar()).habilidades.keys;
  final activos = await repositorio.flagsNarrativosActivos();
  for (final idHabilidad in habilidades) {
    final estado = await repositorio.cargarEstadoHabilidad(idHabilidad);
    if (estado == null) continue;
    for (final nivel in NivelMaestria.values) {
      if (nivel == NivelMaestria.inexplorada || nivel.index > estado.nivel.index) continue;
      final flag = MotorMaestria.flagDeMaestria(idHabilidad, nivel);
      if (!activos.contains(flag)) await repositorio.activarFlagNarrativo(flag);
    }
  }
}
