import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/dominio/avisos_tiempo.dart';
import 'package:solera_huerta/dominio/catalogos.dart';
import 'package:solera_huerta/modelos/bancal.dart';
import 'package:solera_huerta/modelos/cultivo.dart';
import 'package:solera_huerta/modelos/parcela.dart';
import 'package:solera_huerta/modelos/siembra.dart';

void main() {
  final ahora = DateTime(2026, 4, 20, 18); // lunes por la tarde
  DateTime dia(int desdeHoy) => DateTime(2026, 4, 20 + desdeHoy);

  final bancales = {
    1: Bancal(id: 1, parcelaId: 1, nombre: 'B1'),
    2: Bancal(id: 2, parcelaId: 1, nombre: 'Inv', invernadero: true),
  };
  final cultivos = {
    1: Cultivo(id: 1, especieId: 'tomate', familiaId: 'solanaceas'),
    2: Cultivo(id: 2, especieId: 'ajo', familiaId: 'amarilidaceas'),
    3: Cultivo(id: 3, especieId: 'melon', familiaId: 'cucurbitaceas'),
    4: Cultivo(id: 4, especieId: 'Tupinambo', familiaId: 'asteraceas'),
    5: Cultivo(id: 5, especieId: 'pimiento', familiaId: 'solanaceas'),
    6: Cultivo(
        id: 6, especieId: 'tomate', familiaId: 'solanaceas', variedad: 'Rosa'),
  };
  final hecha = DateTime(2026, 4, 10).millisecondsSinceEpoch;
  Siembra plantada(int id, int cultivoId,
          {int bancalId = 1, bool levantada = false, bool realizada = true}) =>
      Siembra(
        id: id,
        bancalId: bancalId,
        cultivoId: cultivoId,
        fechaPrevistaMs: hecha,
        fechaRealMs: realizada ? hecha : null,
        fechaLevantadaMs: levantada ? hecha : null,
      );

  DiaPrevisto previsto(int desdeHoy,
          {double? minima = 8, double? maxima = 22, double? lluvia = 3}) =>
      (
        fecha: dia(desdeHoy),
        minimaC: minima,
        maximaC: maxima,
        lluviaMm: lluvia
      );

  AvisosTiempoHuerta calcular(
          List<DiaPrevisto> prevision, List<Siembra> siembras,
          {DateTime? momento}) =>
      calcularAvisosTiempo(
        prevision: prevision,
        siembras: siembras,
        cultivos: cultivos,
        bancales: bancales,
        ahora: momento ?? ahora,
      );

  group('catálogo', () {
    test('sensibles con fuente; sin dato queda null', () {
      for (final id in [
        'tomate',
        'pimiento',
        'berenjena',
        'patata',
        'calabacin',
        'calabaza',
        'pepino',
        'judia_verde'
      ]) {
        expect(especiePorId(id)!.sensibleHelada, isTrue, reason: id);
        expect(especiePorId(id)!.fuenteHelada, isNotEmpty, reason: id);
      }
      expect(especiePorId('ajo')!.sensibleHelada, isFalse);
      expect(especiePorId('melon')!.sensibleHelada, isNull);
      expect(especiePorId('puerro')!.sensibleHelada, isNull);
    });
  });

  group('helada', () {
    test('nombra solo lo sensible en tierra y al aire libre, sin repetir', () {
      final avisos = calcular([
        previsto(0),
        previsto(1),
        previsto(2, minima: 1.5),
        previsto(3, minima: -2),
      ], [
        plantada(1, 1),
        plantada(2, 2), // ajo: aguanta
        plantada(3, 3), // melón: sin dato
        plantada(4, 4), // especie libre: sin dato
        plantada(5, 5, bancalId: 2), // pimiento en invernadero
        plantada(6, 6), // otro tomate
        plantada(7, 5, levantada: true),
        plantada(8, 5, realizada: false),
      ]);
      final helada = avisos.helada!;
      expect(helada.fecha, dia(2));
      expect(helada.minimaC, 1.5);
      expect(helada.diasDesdeHoy, 2);
      expect(helada.cultivosSensibles, ['Tomate']);
    });

    test('umbral: 2 °C avisa, 2,1 no', () {
      expect(calcular([previsto(1, minima: 2)], [plantada(1, 1)]).helada,
          isNotNull);
      expect(calcular([previsto(1, minima: 2.1)], [plantada(1, 1)]).helada,
          isNull);
    });

    test('helada sin nada sensible: avisa sin nombrar', () {
      final helada =
          calcular([previsto(1, minima: -1)], [plantada(2, 2)]).helada!;
      expect(helada.cultivosSensibles, isEmpty);
    });

    test('la de esta madrugada ya pasó por la tarde, no de madrugada', () {
      final prevision = [previsto(0, minima: -3)];
      expect(calcular(prevision, [plantada(1, 1)]).helada, isNull);
      final madrugada = calcular(prevision, [plantada(1, 1)],
          momento: DateTime(2026, 4, 20, 4));
      expect(madrugada.helada!.diasDesdeHoy, 0);
    });

    test('mínima sin dato se salta', () {
      expect(calcular([previsto(1, minima: null)], [plantada(1, 1)]).helada,
          isNull);
    });
  });

  group('calor', () {
    test('un día a 35 °C avisa; tres seguidos es ola', () {
      final suelto =
          calcular([previsto(1, maxima: 35), previsto(2)], [plantada(1, 1)])
              .calor!;
      expect(suelto.esOla, isFalse);
      expect(suelto.fecha, dia(1));
      final ola = calcular([
        previsto(1, maxima: 34),
        previsto(2, maxima: 36),
        previsto(3, maxima: 38),
        previsto(4, maxima: 35),
      ], [
        plantada(1, 1)
      ]).calor!;
      expect(ola.esOla, isTrue);
      expect(ola.fecha, dia(2));
      expect(ola.maximaC, 38);
    });

    test('34,9 °C no avisa', () {
      expect(calcular([previsto(1, maxima: 34.9)], [plantada(1, 1)]).calor,
          isNull);
    });
  });

  group('sin lluvia', () {
    test('5 días seguidos desde hoy con menos de 1 mm', () {
      final secos = [
        for (var i = 0; i < 7; i++) previsto(i, lluvia: i == 6 ? 4 : 0.5),
      ];
      expect(calcular(secos, [plantada(1, 1)]).diasSinLluvia, 6);
    });

    test('4 días no bastan y un día sin dato corta la cuenta', () {
      final cuatro = [
        for (var i = 0; i < 4; i++) previsto(i, lluvia: 0),
        previsto(4, lluvia: 1),
        previsto(5, lluvia: 0),
      ];
      expect(calcular(cuatro, [plantada(1, 1)]).diasSinLluvia, isNull);
      final hueco = [
        for (var i = 0; i < 7; i++) previsto(i, lluvia: i == 2 ? null : 0),
      ];
      expect(calcular(hueco, [plantada(1, 1)]).diasSinLluvia, isNull);
    });
  });

  test('sin previsión o sin nada en tierra: ningún aviso', () {
    expect(calcular(const [], [plantada(1, 1)]).vacio, isTrue);
    expect(
        calcular([previsto(1, minima: -5, maxima: 40, lluvia: 0)],
            [plantada(1, 1, levantada: true)]).vacio,
        isTrue);
  });

  group('ubicación', () {
    test(
        'punto de la parcela, o centro del área, primero la que tiene siembras',
        () {
      final sinNada = Parcela(id: 1, nombre: 'Sin ubicación');
      final conArea = Parcela(
          id: 2,
          nombre: 'Área',
          contorno: '[[42.0,-2.0],[42.2,-2.0],[42.2,-1.8]]');
      final conPunto =
          Parcela(id: 3, nombre: 'Punto', latitud: 43, longitud: -3);
      expect(ubicacionParaElTiempo(parcelas: [sinNada]), isNull);
      final centro = ubicacionParaElTiempo(parcelas: [sinNada, conArea])!;
      expect(centro.latitude, closeTo(42.1333, 0.001));
      expect(centro.longitude, closeTo(-1.9333, 0.001));
      expect(ubicacionParaElTiempo(parcelas: [conArea, conPunto])!.latitude,
          closeTo(42.1333, 0.001));
      expect(
          ubicacionParaElTiempo(
                  parcelas: [conArea, conPunto], parcelasConSiembras: {3})!
              .latitude,
          43);
    });
  });

  test('recordatorio a las 20:00 de la víspera, nunca en pasado', () {
    expect(momentoRecordatorioHelada(dia(2), ahora), DateTime(2026, 4, 21, 20));
    expect(momentoRecordatorioHelada(dia(1), ahora), DateTime(2026, 4, 20, 20));
    expect(
        momentoRecordatorioHelada(dia(1), DateTime(2026, 4, 20, 21)), isNull);
  });
}
