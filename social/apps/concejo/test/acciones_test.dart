import 'dart:convert';

import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/dominio/debate.dart';
import 'package:concejo/dominio/urna.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  test('cada cambio sale como acción, y rehecha da el mismo estado', () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    final acciones = <AccionConcejo>[];
    estado.alHacerAccion = acciones.add;
    final antes = instantaneaAJson(estado);

    estado
      ..votar('fiestas', {votoSi})
      ..aportar('fiestas', TipoAportacion.duda, '¿Y la charanga?')
      ..anadirCompromiso(
          asuntoUid: 'txoko',
          que: 'Cartel',
          responsable: 'Iker',
          fechaLimite: DateTime(2026, 12, 1))
      ..firmarActa('txoko');
    final maritxu = estado.darDeAlta('Maritxu');
    estado.anotarVotoPresencial('fiestas', maritxu.uid);
    expect(acciones.map((a) => a.tipo), [
      TipoAccion.votar,
      TipoAccion.aportar,
      TipoAccion.anadirCompromiso,
      TipoAccion.firmarActa,
      TipoAccion.darDeAlta,
      TipoAccion.anotarVotoPresencial,
    ]);

    // Otra copia del estado de partida, con las acciones pasadas por JSON
    // como si hubieran estado en la cola sin red.
    final copia = instantaneaDesdeJson(
        jsonDecode(jsonEncode(antes)) as Map<String, dynamic>,
        personaActualUid: 'ane',
        reloj: () => _hoy);
    for (final accion in acciones) {
      copia.rehacer(AccionConcejo.desdeJson(
          jsonDecode(jsonEncode(accion.aJson())) as Map<String, dynamic>));
    }
    final esperado = instantaneaAJson(estado);
    final obtenido = instantaneaAJson(copia);
    // Las papeletas secretas entran en posición al azar: se comparan aparte.
    for (final json in [esperado, obtenido]) {
      for (final urna in json['urnas'] as List) {
        (urna as Map)['papeletas'] = (urna['papeletas'] as List).length;
      }
    }
    expect(jsonEncode(obtenido), jsonEncode(esperado));
  });

  test('una acción que falla no sale ni cambia nada', () {
    final estado = estadoDeEjemplo(hoy: _hoy)..verComo('maite');
    final acciones = <AccionConcejo>[];
    estado.alHacerAccion = acciones.add;
    expect(() => estado.firmarActa('txoko'), throwsStateError);
    expect(acciones, isEmpty);
  });

  test('no se rehacen acciones de otra persona', () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    final ajena = AccionConcejo(
      uid: 'x',
      tipo: TipoAccion.votar,
      autorUid: 'maite',
      momento: _hoy,
      datos: const {
        'asunto_uid': 'fiestas',
        'opciones': [votoSi]
      },
    );
    expect(() => estado.rehacer(ajena), throwsStateError);
  });
}
