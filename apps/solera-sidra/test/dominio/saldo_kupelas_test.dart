import 'package:flutter_test/flutter_test.dart';
import 'package:solera_sidra/dominio/campania.dart';
import 'package:solera_sidra/dominio/saldo_kupelas.dart';
import 'package:solera_sidra/modelos/embotellado.dart';
import 'package:solera_sidra/modelos/kupela.dart';
import 'package:solera_sidra/modelos/prensado.dart';
import 'package:solera_sidra/modelos/sesion_txotx.dart';

void main() {
  test('la campaña va de septiembre a agosto', () {
    expect(campaniaDe(DateTime(2026, 9, 1)), 2026);
    expect(campaniaDe(DateTime(2027, 8, 31)), 2026);
    expect(campaniaDe(DateTime(2027, 1, 20)), 2026);
    final rango = rangoCampania(2026);
    expect(
      DateTime.fromMillisecondsSinceEpoch(rango.desdeMs),
      DateTime(2026, 9),
    );
    expect(
      DateTime.fromMillisecondsSinceEpoch(rango.hastaMs + 1),
      DateTime(2027, 9),
    );
    expect(nombreCampania(2026), '2026-2027');
  });

  final prensados = [
    Prensado(fechaMs: 1, kupelaId: 1, kilosFruta: 1500, litrosMosto: 1000),
    Prensado(fechaMs: 2, kupelaId: 2, kilosFruta: 600, litrosMosto: 400),
  ];
  final trasiegos = [
    Trasiego(fechaMs: 3, kupelaOrigenId: 1, kupelaDestinoId: 3, litros: 300),
    Trasiego(fechaMs: 4, kupelaOrigenId: 1, litros: 20, motivo: 'lías'),
    Trasiego(fechaMs: 5, kupelaOrigenId: 2, kupelaDestinoId: 3, litros: 100),
  ];
  final sesiones = [SesionTxotx(fechaMs: 6, kupelaId: 1, litrosServidos: 150)];
  final embotellados = [
    Embotellado(
      fechaMs: 7,
      kupelaId: 3,
      codigoLote: 'L',
      botellas: 400,
      mililitrosBotella: 750,
    ),
  ];

  test('el saldo suma prensados y trasiegos y resta txotx y botellas', () {
    final saldo = SaldoKupelas.calcular(
      prensados: prensados,
      trasiegos: trasiegos,
      sesionesTxotx: sesiones,
      embotellados: embotellados,
    );
    expect(saldo.litrosEn(1), 1000 - 300 - 20 - 150);
    expect(saldo.litrosEn(2), 300);
    expect(saldo.litrosEn(3), 400 - 300);
    expect(saldo.litrosEn(99), 0);
    expect(saldo.movimientos[1]!.map((movimiento) => movimiento.tipo), [
      'prensado',
      'trasiego_salida',
      'retirada',
      'txotx',
    ]);
    final kupelas = [
      Kupela(id: 1, codigo: 'K1', capacidadLitros: 500),
      Kupela(id: 2, codigo: 'K2', capacidadLitros: 1000),
      Kupela(id: 3, codigo: 'K3', capacidadLitros: 0),
    ];
    expect(saldo.superaCapacidad(kupelas[0]), isTrue);
    expect(saldo.superaCapacidad(kupelas[2]), isFalse); // sin capacidad
    expect(saldo.litrosTotales(kupelas), 530 + 300 + 100);
  });

  test('hasta una fecha: lo posterior no cuenta', () {
    final saldo = SaldoKupelas.calcular(
      prensados: prensados,
      trasiegos: trasiegos,
      sesionesTxotx: sesiones,
      embotellados: embotellados,
      hastaMs: 3,
    );
    expect(saldo.litrosEn(1), 700);
    expect(saldo.litrosEn(3), 300);
  });

  test('una kupela vacía de la que sale algo queda en negativo', () {
    final saldo = SaldoKupelas.calcular(
      prensados: const [],
      trasiegos: const [],
      sesionesTxotx: [SesionTxotx(fechaMs: 1, kupelaId: 4, litrosServidos: 5)],
      embotellados: const [],
    );
    expect(saldo.quedaEnNegativo(4), isTrue);
  });

  test('origen de una kupela siguiendo trasiegos hacia atrás', () {
    final cadena = [
      ...trasiegos,
      Trasiego(fechaMs: 8, kupelaOrigenId: 3, kupelaDestinoId: 4, litros: 50),
      // Ciclo: no debe colgarse.
      Trasiego(fechaMs: 9, kupelaOrigenId: 4, kupelaDestinoId: 3, litros: 10),
    ];
    expect(kupelasDeOrigen(4, cadena), {1, 2, 3, 4});
    expect(kupelasDeOrigen(3, cadena, hastaMs: 4), {1, 3});
    expect(kupelasDeOrigen(1, cadena), {1});
  });
}
