import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/dominio/escenas_arco_1.dart';
import 'package:las_versiones/dominio/escenas_arco_2.dart';
import 'package:las_versiones/dominio/escenas_arco_3.dart';
import 'package:las_versiones/dominio/escenas_arco_4.dart';
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

  final todasLasEscenas = [
    ...EscenasArco1.todas,
    ...EscenasArco2.todas,
    ...EscenasArco3.todas,
    ...EscenasArco4.todas,
  ];

  test('todas las escenas cortas son de escenas que existen', () {
    final idsExistentes = todasLasEscenas.map((e) => e.id).toSet();
    for (final id in EscenasCortas.ids) {
      expect(idsExistentes, contains(id), reason: id);
    }
  });

  final conVersionCorta =
      todasLasEscenas.where((e) => EscenasCortas.tieneVersionCorta(e.id)).toList();

  test('las escenas largas (más de 180 palabras) de los cuatro arcos tienen versión corta', () {
    for (final entera in todasLasEscenas) {
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

      test('termina igual: mismo cierre amable, o ninguno si la entera no lo tiene', () {
        final ultimoEntera = entera.planos.last;
        final ultimoCorta = corta.planos.last;
        if (ultimoEntera is PlanoCierreAmable) {
          expect(ultimoCorta, isA<PlanoCierreAmable>());
          expect((ultimoCorta as PlanoCierreAmable).textoBoton, ultimoEntera.textoBoton);
        } else {
          expect(ultimoCorta, isNot(isA<PlanoCierreAmable>()));
        }
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
