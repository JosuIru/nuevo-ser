// Integración: el ganado viaja entre coordinación y una tester a través del
// WordPress (plugin 0.8.0): lotes, animales, movimientos y curas; la tester
// mueve un lote ajeno pero no puede cambiarle el nombre. Se salta sin
// servidor:
//
//   SZS_URL=http://zunbeltz-app.local SZS_COORDINACION=<token> \
//     SZS_TESTER=<token> flutter test test/integracion_ganado_test.dart
//
// Al acabar borra el lote de prueba (queda como lápida en el servidor).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/ganado.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

import 'bd_en_memoria.dart';

void main() {
  final url = Platform.environment['SZS_URL'] ?? '';
  final tokenCoordinacion = Platform.environment['SZS_COORDINACION'] ?? '';
  final tokenTester = Platform.environment['SZS_TESTER'] ?? '';

  test('coordinación y una tester comparten el ganado', () async {
    final coordinacion = await abrirBdEnMemoria();
    final tester = await abrirBdEnMemoria();
    Future<ResultadoSyncZunbeltz> sincronizar(
            BaseDatosSoleraZunbeltz bd, String token) =>
        ClienteSyncZunbeltz(urlBase: url, token: token).sincronizar(bd);

    await sincronizar(coordinacion, tokenCoordinacion);
    final zonas = await coordinacion.listarZonas();
    final pasillo = zonas.firstWhere((zona) => zona.nombre == 'Pasillo');
    final avellanos =
        zonas.firstWhere((zona) => zona.nombre == 'Los Avellanos');

    final lote = await coordinacion.guardarLote(LoteGanado(
        nombre: 'Prueba de integración (borrar)',
        especie: 'ovino',
        cabezasSinIdentificar: 2));
    await coordinacion
        .guardarAnimal(Animal(identificacion: 'ES-PRUEBA-1', loteId: lote));
    await coordinacion.moverLote(
        loteId: lote,
        fechaMs: DateTime.now().millisecondsSinceEpoch - 86400000,
        tipo: tipoMovimientoEntrada,
        zonaDestinoId: pasillo.id);
    await coordinacion.guardarEventoGanado(EventoGanado(
        loteId: lote,
        fechaMs: DateTime.now().millisecondsSinceEpoch,
        sustanciaActiva: 'prueba',
        plazoSupresionCarneDias: 10));
    final subida = await sincronizar(coordinacion, tokenCoordinacion);
    expect(subida.rechazadasPorPermisos, 0);

    // La tester lo ve, en su pieza y en supresión.
    await sincronizar(tester, tokenTester);
    final enTester = (await tester.listarResumenLotes())
        .firstWhere((resumen) => resumen.lote.nombre.startsWith('Prueba'));
    final zonasTester = {
      for (final zona in await tester.listarZonas()) zona.id: zona.nombre
    };
    expect(zonasTester[enTester.zonaId], 'Pasillo');
    expect(enTester.cabezas, 3);
    expect(
        supresionVigente(
                await tester.listarEventosGanado(loteId: enTester.lote.id),
                DateTime.now())
            .hayAlguna,
        isTrue);

    // La mueve a Los Avellanos e intenta renombrarla.
    final avellanosTester =
        zonasTester.entries.firstWhere((e) => e.value == 'Los Avellanos').key;
    await tester.moverLote(
        loteId: enTester.lote.id!,
        fechaMs: DateTime.now().millisecondsSinceEpoch,
        tipo: tipoMovimientoTraslado,
        zonaDestinoId: avellanosTester);
    await tester.actualizarLote(enTester.lote.id!, {'nombre': 'Mío'});
    final deTester = await sincronizar(tester, tokenTester);
    expect(deTester.rechazadasPorPermisos, 1,
        reason: 'el renombre de un lote ajeno se rechaza');
    expect((await tester.obtenerLote(enTester.lote.id!))!.nombre,
        startsWith('Prueba'));

    // Coordinación ve el lote en su sitio nuevo.
    await sincronizar(coordinacion, tokenCoordinacion);
    final porZona = await coordinacion.lotesPorZona();
    expect(porZona[avellanos.id]?.map((resumen) => resumen.lote.id),
        contains(lote));

    // Y lo retira (el animal no se va con el lote: queda sin lote).
    for (final animal in await coordinacion.listarAnimales(loteId: lote)) {
      await coordinacion.borrarAnimal(animal.id!);
    }
    await coordinacion.borrarLote(lote);
    await sincronizar(coordinacion, tokenCoordinacion);
    await sincronizar(tester, tokenTester);
    expect(
        (await tester.listarLotes())
            .where((l) => l.nombre.startsWith('Prueba')),
        isEmpty);
  },
      skip: url.isEmpty || tokenCoordinacion.isEmpty || tokenTester.isEmpty
          ? 'sin SZS_URL / SZS_COORDINACION / SZS_TESTER'
          : false);
}
