import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/estado/avisos.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:concejo/servidor/almacen_local.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

/// El pueblo de ejemplo (fechas desde [_hoy]) con un reloj que se mueve.
EstadoConcejo _pueblo(String personaUid, DateTime Function() reloj) {
  final ejemplo = estadoDeEjemplo(hoy: _hoy);
  return EstadoConcejo(
    nombreEspacio: ejemplo.nombreEspacio,
    personaActual: ejemplo.personas.firstWhere((p) => p.uid == personaUid),
    personas: ejemplo.personas,
    asuntos: ejemplo.asuntos,
    urnas: ejemplo.urnas,
    debates: ejemplo.debates,
    consentimientos: ejemplo.consentimientos,
    compromisos: ejemplo.compromisos,
    actas: ejemplo.actas,
    sesiones: ejemplo.sesiones,
    tareas: ejemplo.tareas,
    reloj: reloj,
  );
}

List<String> _claves(EstadoConcejo estado) =>
    [for (final aviso in avisosPara(estado)) aviso.clave];

void main() {
  test('a una vecina: asuntos nuevos en debate y resultados recientes', () {
    final estado = _pueblo('maite', () => _hoy);
    expect(_claves(estado), [
      'nuevo:presupuesto',
      'nuevo:comunal',
      'resultado:txoko',
    ]);
  });

  test('los últimos días para votar, solo a quien no ha votado', () {
    // «fiestas» cierra el 15 a las 0:00: el 13 a mediodía queda día y medio.
    final estado = _pueblo('maite', () => DateTime(2026, 11, 13, 12));
    expect(_claves(estado), contains('ultimos:fiestas:2026-11-15'));
    expect(avisosPara(estado).first.tipo, TipoAviso.ultimosDias);

    estado.votar('fiestas', {'si'});
    expect(_claves(estado), isNot(contains('ultimos:fiestas:2026-11-15')));
  });

  test('el compromiso vencido, a quien lo tiene y a la mesa', () {
    // c1 es de «Mikel» y venció el día 7.
    expect(_claves(_pueblo('mikel', () => _hoy)),
        contains('vencido:c1:2026-11-07'));
    expect(
        _claves(_pueblo('ane', () => _hoy)), contains('vencido:c1:2026-11-07'));
    expect(_claves(_pueblo('maite', () => _hoy)),
        isNot(contains('vencido:c1:2026-11-07')));
    // c2 está hecho: no avisa a nadie.
    expect(_claves(_pueblo('ane', () => _hoy)).where((c) => c.contains('c2')),
        isEmpty);
  });

  test('el fin de mandato se avisa dos semanas antes', () {
    // Ane está en la mesa hasta el 20 de diciembre.
    expect(
        _claves(_pueblo('ane', () => _hoy))
            .where((c) => c.startsWith('mandato')),
        isEmpty);
    expect(_claves(_pueblo('ane', () => DateTime(2026, 12, 10))),
        contains('mandato:ane:2026-12-20'));
  });

  test('pasadas dos semanas, lo nuevo deja de ser nuevo', () {
    final estado = _pueblo(
        'maite', () => DateTime(2026, 11, 10).add(const Duration(days: 30)));
    expect(_claves(estado).where((c) => c.startsWith('nuevo')), isEmpty);
    expect(_claves(estado), isNot(contains('resultado:txoko')));
  });

  group('avisos quitados', () {
    test('se recuerdan por persona y sobreviven a cerrar la app', () async {
      final almacen = AlmacenEnMemoria();
      final estado = _pueblo('maite', () => _hoy);
      final avisos = avisosPara(estado);
      final vistos = AvisosVistos(almacen: almacen);

      await vistos.quitar('maite', [avisos.first], avisos);
      expect(vistos.pendientes('maite', avisos), hasLength(avisos.length - 1));
      expect(vistos.pendientes('ane', avisos), hasLength(avisos.length));

      final otraVez = AvisosVistos(almacen: almacen);
      expect(otraVez.pendientes('maite', avisos), hasLength(avisos.length - 1));
    });

    test('se olvidan los que ya no salen', () async {
      final almacen = AlmacenEnMemoria();
      final vistos = AvisosVistos(almacen: almacen);
      final antes = avisosPara(_pueblo('maite', () => _hoy));
      await vistos.quitar('maite', [antes.first], antes);

      final despues =
          avisosPara(_pueblo('maite', () => DateTime(2026, 12, 20)));
      await vistos.quitar(
          'maite', [despues.isEmpty ? antes.last : despues.first], despues);
      expect(
          almacen.leer(AvisosVistos.clave), isNot(contains(antes.first.clave)));
    });
  });

  test('la asamblea se avisa en los tres días anteriores, y si se anula', () {
    // «noviembre» es el 14 a las 19:00.
    expect(
        _claves(_pueblo('maite', () => _hoy))
            .where((c) => c.startsWith('asamblea')),
        isEmpty);
    final cerca = _pueblo('ane', () => DateTime(2026, 11, 12, 12));
    expect(
        _claves(cerca), contains('asamblea:noviembre:2026-11-14T19:00:00.000'));
    cerca.anularSesion('noviembre', 'Funeral');
    expect(
        _claves(cerca), contains('anulada:noviembre:2026-11-14T19:00:00.000'));
    expect(
        _claves(_pueblo('maite', () => DateTime(2026, 11, 14, 20)))
            .where((c) => c.contains('noviembre')),
        isEmpty);
  });

  test('a quien va a una tarea se le recuerda dos días antes, y si se anula',
      () {
    // «local» es el 14 a las 17:00 y va Pili.
    expect(
        _claves(_pueblo('pili', () => _hoy)), isNot(contains('tarea:local')));
    final cerca = _pueblo('pili', () => DateTime(2026, 11, 13, 12));
    expect(_claves(cerca), contains('tarea:local'));
    expect(_claves(_pueblo('maite', () => DateTime(2026, 11, 13, 12))),
        isNot(contains('tarea:local')),
        reason: 'Maite no va');
    final mesa = _pueblo('ane', () => DateTime(2026, 11, 13, 12))
      ..anularTarea('local', 'Se ha roto la cerradura');
    final pili = instantaneaDesdeJson(instantaneaAJson(mesa),
        personaActualUid: 'pili', reloj: () => DateTime(2026, 11, 13, 12));
    expect(_claves(pili), contains('tarea-anulada:local'));
  });
}
