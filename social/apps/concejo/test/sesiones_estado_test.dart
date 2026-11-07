import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/dominio/sesion.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

/// El ejemplo con un reloj que se puede mover.
EstadoConcejo _pueblo(String personaUid, DateTime Function() reloj) {
  final ejemplo = estadoDeEjemplo(hoy: _hoy);
  return instantaneaDesdeJson(instantaneaAJson(ejemplo),
      personaActualUid: personaUid, reloj: reloj);
}

Sesion _convocatoria({String lugar = 'Local vecinal', String? asuntoUid}) =>
    Sesion(
      uid: 'nueva',
      titulo: 'Asamblea extraordinaria',
      inicio: DateTime(2026, 11, 14, 19),
      lugar: lugar,
      puntos: [
        PuntoOrdenDia(
            uid: 'p1', texto: 'Leña del comunal', asuntoUid: asuntoUid),
        const PuntoOrdenDia(uid: 'p2', texto: 'Ruegos y preguntas'),
      ],
    );

void main() {
  test('solo la mesa convoca, y con puntos de asuntos abiertos', () {
    expect(() => _pueblo('maite', () => _hoy).convocarSesion(_convocatoria()),
        throwsStateError);

    final mesa = _pueblo('ane', () => _hoy);
    expect(
        () => mesa.convocarSesion(_convocatoria(lugar: '')), throwsStateError);
    expect(() => mesa.convocarSesion(_convocatoria(asuntoUid: 'no-existe')),
        throwsStateError);

    mesa.convocarSesion(_convocatoria(asuntoUid: 'comunal'));
    expect(mesa.sesion('nueva').convocadaPorUid, 'ane');
    expect(mesa.sesion('nueva').puntos.first.asuntoUid, 'comunal');
  });

  test('se cambia y se anula antes; después, asistencia y notas', () {
    var ahora = _hoy;
    final mesa = _pueblo('ane', () => ahora)
      ..convocarSesion(_convocatoria())
      ..convocarSesion(_convocatoria(lugar: 'Frontón'));
    expect(mesa.sesion('nueva').lugar, 'Frontón');
    expect(() => mesa.anotarAsistencia('nueva', 'maite', presente: true),
        throwsStateError);

    ahora = DateTime(2026, 11, 14, 20);
    expect(() => mesa.convocarSesion(_convocatoria()), throwsStateError);
    expect(() => mesa.anularSesion('nueva', 'Tarde'), throwsStateError);
    mesa
      ..anotarAsistencia('nueva', 'maite', presente: true)
      ..anotarAsistentesSinApp('nueva', 4)
      ..anotarNotasPunto('nueva', 'p2', 'Arreglar la fuente');
    expect(mesa.sesion('nueva').asistentes, 5);
    expect(() => mesa.anotarAsistencia('nueva', 'nadie', presente: true),
        throwsStateError);
  });

  test('las acciones viajan y se rehacen igual', () {
    final acciones = <AccionConcejo>[];
    final mesa = _pueblo('ane', () => _hoy)
      ..alHacerAccion = acciones.add
      ..convocarSesion(_convocatoria())
      ..anularSesion('nueva', 'Coincide con el funeral');

    final otra = _pueblo('ane', () => _hoy);
    for (final accion in acciones) {
      otra.rehacer(AccionConcejo.desdeJson(accion.aJson()));
    }
    expect(otra.sesion('nueva').anulada, isTrue);
    expect(otra.sesion('nueva').motivoAnulacion, 'Coincide con el funeral');
    expect(
        instantaneaAJson(otra)['sesiones'], instantaneaAJson(mesa)['sesiones']);
  });
}
