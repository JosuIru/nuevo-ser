import 'package:flutter_test/flutter_test.dart';
import 'package:solera_vivero/dominio/pasaporte.dart';
import 'package:solera_vivero/dominio/stock.dart';
import 'package:solera_vivero/dominio/trazabilidad.dart';
import 'package:solera_vivero/modelos/bandeja.dart';
import 'package:solera_vivero/modelos/lote_material.dart';
import 'package:solera_vivero/modelos/partida_planta.dart';
import 'package:solera_vivero/modelos/repicado.dart';
import 'package:solera_vivero/modelos/salida.dart';
import 'package:solera_vivero/modelos/siembra.dart';
import 'package:solera_vivero/modelos/vivero.dart';

PartidaPlanta _partida(int id,
        {int inicial = 100,
        int mermas = 0,
        int? siembraId,
        int? origenId,
        String especie = 'tomate',
        String formato = 'alveolo',
        bool lista = false}) =>
    PartidaPlanta(
        id: id,
        codigo: 'P26-000$id',
        especieId: especie,
        nombreBotanico: 'Solanum lycopersicum',
        formato: formato,
        cantidadInicial: inicial,
        mermas: mermas,
        siembraId: siembraId,
        partidaOrigenId: origenId,
        fechaAltaMs: 0,
        listaParaVenta: lista);

void main() {
  group('stock', () {
    test('disponibles = inicial − mermas − repicadas − salidas', () {
      final partida = _partida(1, inicial: 100, mermas: 5);
      final repicados = [
        Repicado(
            partidaOrigenId: 1, partidaDestinoId: 2, fechaMs: 0, cantidad: 30),
        Repicado(
            partidaOrigenId: 9, partidaDestinoId: 3, fechaMs: 0, cantidad: 99),
      ];
      final salidas = [Salida(partidaId: 1, fechaMs: 0, cantidad: 20)];
      expect(
          plantasDisponibles(partida, repicados: repicados, salidas: salidas),
          45);
      expect(porcentajeMermas(partida), 5);
      expect(porcentajeMermas(_partida(2, inicial: 0)), isNull);
    });

    test('nunca negativo', () {
      expect(
          plantasDisponibles(_partida(1, inicial: 10, mermas: 4),
              repicados: const [],
              salidas: [Salida(partidaId: 1, fechaMs: 0, cantidad: 50)]),
          0);
    });

    test('resumen por especie y formato, sin partidas agotadas', () {
      final filas = resumenStock(
        partidas: [
          _partida(1, inicial: 50, lista: true),
          _partida(2, inicial: 30),
          _partida(3, inicial: 10, formato: 'maceta'),
          _partida(4, inicial: 5, especie: 'agotada'),
        ],
        repicados: const [],
        salidas: [Salida(partidaId: 4, fechaMs: 0, cantidad: 5)],
      );
      expect(filas.map((fila) => (fila.formato, fila.disponibles)),
          [('alveolo', 80), ('maceta', 10)]);
      expect(filas.first.listasParaVenta, 50);
      expect(filas.first.numeroPartidas, 2);
    });
  });

  group('trazabilidad', () {
    final lote = LoteMaterial(
        id: 7, codigo: 'SEM-1', especieId: 'tomate', fechaEntradaMs: 0);
    final bandeja = Bandeja(id: 3, codigoQr: 'VIV-B-0001');
    final siembra = Siembra(id: 5, loteMaterialId: 7, bandejaId: 3, fechaMs: 0);

    test('de la maceta al lote pasando por el repicado y la siembra', () {
      final cadena = reconstruirTrazabilidad(2, partidas: {
        1: _partida(1, siembraId: 5),
        2: _partida(2, origenId: 1, formato: 'maceta'),
      }, siembras: {
        5: siembra
      }, bandejas: {
        3: bandeja
      }, lotes: {
        7: lote
      });
      expect(cadena.completa, isTrue);
      expect(
          cadena.eslabones
              .map((e) => e.partida?.id ?? e.siembra?.id ?? e.lote?.id),
          [2, 1, 5, 7]);
      expect(cadena.eslabones[2].bandeja?.codigoQr, 'VIV-B-0001');
      expect(cadena.lote?.codigo, 'SEM-1');
    });

    test('incompleta si falta la siembra o el lote', () {
      final sinSiembra = reconstruirTrazabilidad(1,
          partidas: {1: _partida(1)}, siembras: {}, bandejas: {}, lotes: {});
      expect((sinSiembra.completa, sinSiembra.eslabones.length), (false, 1));
      expect(sinSiembra.lote, isNull);
      final sinLote = reconstruirTrazabilidad(1,
          partidas: {1: _partida(1, siembraId: 5)},
          siembras: {5: siembra},
          bandejas: {},
          lotes: {});
      expect((sinLote.completa, sinLote.eslabones.length), (false, 2));
    });

    test('corta los ciclos', () {
      final cadena = reconstruirTrazabilidad(1,
          partidas: {1: _partida(1, origenId: 2), 2: _partida(2, origenId: 1)},
          siembras: {},
          bandejas: {},
          lotes: {});
      expect((cadena.completa, cadena.eslabones.length), (false, 2));
    });
  });

  group('necesidad de pasaporte', () {
    Salida salida(
            {bool usuarioFinal = false,
            bool distancia = false,
            bool zp = false,
            bool propio = false}) =>
        Salida(
            partidaId: 1,
            fechaMs: 0,
            cantidad: 1,
            esUsuarioFinal: usuarioFinal,
            esVentaADistancia: distancia,
            destinoZonaProtegida: zp,
            esTrasladoPropioMismaComunidad: propio);

    test('entre profesionales, sí (anexo XIII, punto 1)', () {
      expect(
          evaluarNecesidadPasaporte(salida(), necesitaPasaporteEspecie: true),
          NecesidadPasaporte.necesario);
    });
    test('usuario final en persona, no (art. 81.1)', () {
      expect(
          evaluarNecesidadPasaporte(salida(usuarioFinal: true),
              necesitaPasaporteEspecie: true),
          NecesidadPasaporte.noUsuarioFinal);
    });
    test('usuario final a distancia, sí (art. 81.2)', () {
      expect(
          evaluarNecesidadPasaporte(salida(usuarioFinal: true, distancia: true),
              necesitaPasaporteEspecie: true),
          NecesidadPasaporte.necesario);
    });
    test('zona protegida manda, aunque sea usuario final', () {
      final necesidad = evaluarNecesidadPasaporte(
          salida(usuarioFinal: true, zp: true),
          necesitaPasaporteEspecie: true);
      expect(necesidad, NecesidadPasaporte.necesarioZonaProtegida);
      expect(necesidadExigePasaporte(necesidad), isTrue);
    });
    test('traslado propio en la misma comunidad, no (RD 1054/2021, 16.6)', () {
      expect(
          evaluarNecesidadPasaporte(salida(propio: true),
              necesitaPasaporteEspecie: true),
          NecesidadPasaporte.noTrasladoPropio);
    });
    test('especie sin dato: por verificar, nunca «no hace falta»', () {
      expect(
          evaluarNecesidadPasaporte(salida(), necesitaPasaporteEspecie: null),
          NecesidadPasaporte.porVerificar);
      expect(
          evaluarNecesidadPasaporte(salida(), necesitaPasaporteEspecie: false),
          NecesidadPasaporte.porVerificar);
      expect(necesidadExigePasaporte(NecesidadPasaporte.porVerificar), isFalse);
    });
  });

  group('datos del pasaporte', () {
    final vivero =
        Vivero(codigoRopveg: 'ES-15200001', autorizadoPasaporte: true);
    final partida = PartidaPlanta(
        id: 1,
        codigo: 'P26-0001',
        especieId: 'castano',
        nombreBotanico: 'Castanea sativa',
        variedad: 'Parede',
        cantidadInicial: 10,
        fechaAltaMs: 0);

    test('completos con autorización: no es borrador', () {
      final datos = prepararDatosPasaporte(
          vivero: vivero,
          partida: partida,
          salida: Salida(partidaId: 1, fechaMs: 0, cantidad: 8));
      expect(datos.faltan, isEmpty);
      expect(datos.esBorrador, isFalse);
      expect(datos.letraA, "Castanea sativa 'Parede'");
      expect(datos.codigoOperador, 'ES-15200001');
      expect(datos.codigoTrazabilidad, 'P26-0001');
      expect(datos.paisOrigen, 'ES');
      expect(datos.titulo, 'Plant Passport / Pasaporte fitosanitario');
      expect(contenidoQrPasaporte(datos),
          "PP|A=Castanea sativa 'Parede'|B=ES-15200001|C=P26-0001|D=ES");
    });

    test('sin autorización siempre es borrador', () {
      final datos = prepararDatosPasaporte(
          vivero: Vivero(codigoRopveg: 'ES-15200001'),
          partida: partida,
          salida: Salida(partidaId: 1, fechaMs: 0, cantidad: 8));
      expect(datos.faltan, isEmpty);
      expect(datos.esBorrador, isTrue);
    });

    test('ZP sin plagas y sin código de operador: faltan datos', () {
      final datos = prepararDatosPasaporte(
          vivero: Vivero(autorizadoPasaporte: true),
          partida: partida,
          salida: Salida(
              partidaId: 1,
              fechaMs: 0,
              cantidad: 8,
              destinoZonaProtegida: true,
              codigoTrazabilidad: 'PROPIO-9'));
      expect(datos.faltan, [
        DatoPasaporteFaltante.codigoOperador,
        DatoPasaporteFaltante.plagasZonaProtegida,
      ]);
      expect(datos.esBorrador, isTrue);
      expect(datos.codigoTrazabilidad, 'PROPIO-9');
      expect(datos.titulo, contains('ZP'));
      expect(contenidoQrPasaporte(datos), startsWith('PP-ZP|'));
    });
  });
}
