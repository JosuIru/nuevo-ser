import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/dominio/escenas_arco_1.dart';
import 'package:las_versiones/dominio/escenas_cortas.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

Set<String> _flagsDeElecciones(EscenaCinematica escena) => {
      for (final plano in escena.planos)
        if (plano is PlanoEleccion)
          for (final opcion in plano.opciones) ...opcion.flagsAEstablecer,
    };

int _palabras(EscenaCinematica escena) {
  var total = 0;
  for (final plano in escena.planos) {
    final textos = <String?>[
      if (plano is PlanoDialogo) plano.texto,
      if (plano is PlanoAmbiente) plano.textoLectura,
      if (plano is PlanoEleccion) ...[
        plano.textoPrompt,
        for (final opcion in plano.opciones) ...[opcion.textoJugador, opcion.textoRespuesta],
      ],
    ];
    for (final texto in textos) {
      if (texto != null) total += texto.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length;
    }
  }
  return total;
}

void main() {
  final apertura = [
    EscenasArco1.laEvaluacion,
    EscenasArco1.elRecorrido,
    EscenasArco1.laPrimeraTardeEnCasa,
    EscenasArco1.caminoAAralar,
    EscenasArco1.elCampoDeDolmenes,
  ];

  test('toda la apertura hasta la Brecha 1.1 tiene versión corta', () {
    for (final entera in apertura) {
      expect(EscenasCortas.tieneVersionCorta(entera.id), isTrue, reason: entera.id);
    }
  });

  test('todas las escenas cortas son de escenas que existen', () {
    final idsArco1 = EscenasArco1.todas.map((e) => e.id).toSet();
    for (final id in EscenasCortas.ids) {
      expect(idsArco1, contains(id), reason: id);
    }
  });

  final conVersionCorta =
      EscenasArco1.todas.where((e) => EscenasCortas.tieneVersionCorta(e.id)).toList();

  test('las escenas largas del Arco 1 (más de 180 palabras) tienen versión corta', () {
    for (final entera in EscenasArco1.todas) {
      if (_palabras(entera) > 180) {
        expect(EscenasCortas.tieneVersionCorta(entera.id), isTrue,
            reason: '${entera.id} tiene ${_palabras(entera)} palabras');
      }
    }
  });

  for (final entera in conVersionCorta) {
    group('escena ${entera.id}', () {
      final corta = EscenasCortas.para(entera.id)!;

      test('mismos flags de entrada y salida, mismo ambiente', () {
        expect(corta.flagDeSalida, entera.flagDeSalida);
        expect(corta.flagsRequeridos, entera.flagsRequeridos);
        expect(identical(corta.ambiente, entera.ambiente), isTrue);
      });

      test('conserva todas las elecciones de la entera', () {
        expect(_flagsDeElecciones(corta), containsAll(_flagsDeElecciones(entera)));
      });

      test('termina con el mismo botón de cierre', () {
        final cierreEntera = entera.planos.last as PlanoCierreAmable;
        final cierreCorta = corta.planos.last as PlanoCierreAmable;
        expect(cierreCorta.textoBoton, cierreEntera.textoBoton);
      });

      test('es corta de verdad', () {
        expect(corta.planos.length, lessThanOrEqualTo(10));
        expect(corta.planos.length, lessThan(entera.planos.length));
      });
    });
  }

  test('la apertura corta cabe en ~350 palabras (la entera pasa de 1.000)', () {
    final cortas = apertura.map((e) => EscenasCortas.para(e.id)!);
    final palabrasCortas = cortas.fold<int>(0, (suma, e) => suma + _palabras(e));
    expect(palabrasCortas, lessThan(350));
  });

  test('la primera decisión llega en los tres primeros planos', () {
    final primera = EscenasCortas.para(EscenasArco1.laEvaluacion.id)!;
    final indice = primera.planos.indexWhere((p) => p is PlanoEleccion);
    expect(indice, inInclusiveRange(0, 2));
  });
}
