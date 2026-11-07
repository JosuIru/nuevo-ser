import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_vivero/dominio/pasaporte.dart';
import 'package:solera_vivero/modelos/inspeccion_plagas.dart';
import 'package:solera_vivero/modelos/lote_material.dart';
import 'package:solera_vivero/modelos/partida_planta.dart';
import 'package:solera_vivero/modelos/pasaporte_emitido.dart';
import 'package:solera_vivero/modelos/salida.dart';
import 'package:solera_vivero/modelos/tratamiento.dart';
import 'package:solera_vivero/modelos/vivero.dart';
import 'package:solera_vivero/modelos/zona_cultivo.dart';
import 'package:solera_vivero/servicios/generador_cuaderno_tratamientos_pdf.dart';
import 'package:solera_vivero/servicios/generador_pasaporte_pdf.dart';

bool _esPdf(List<int> bytes) =>
    bytes.length > 500 && String.fromCharCodes(bytes.take(5)) == '%PDF-';

void main() {
  setUpAll(initializeDateFormatting);

  final vivero = Vivero(
      nombre: 'Vivero de prueba',
      codigoRopveg: 'ES-15200001',
      autorizadoPasaporte: true);
  final partida = PartidaPlanta(
      id: 4,
      codigo: 'P26-0004',
      especieId: 'castano',
      nombreBotanico: 'Castanea sativa',
      cantidadInicial: 50,
      fechaAltaMs: 0);

  group('cuaderno de tratamientos', () {
    final datos = DatosCuadernoTratamientos(
      anyo: 2026,
      vivero: vivero,
      zonas: [
        ZonaCultivo(id: 9, nombre: 'Nave', superficieM2: 400),
        ZonaCultivo(
            id: 2, nombre: 'Era', tipo: 'exterior', codigoSigpac: '1:2:3'),
      ],
      partidas: [partida],
      tratamientos: [
        Tratamiento(
            fechaMs: DateTime(2026, 6, 2).millisecondsSinceEpoch,
            partidaId: 4,
            zonaId: 9,
            sustanciaActivaId: 'azufre',
            nombreProducto: 'Producto X',
            numeroRegistroProducto: '12345',
            aplicadorNombre: 'Ane',
            carnetAplicador: 'C-1',
            eficacia: 'buena'),
        Tratamiento(
            fechaMs: DateTime(2026, 3, 1).millisecondsSinceEpoch, zonaId: 2),
      ],
      inspecciones: [
        InspeccionPlagas(
            fechaMs: DateTime(2026, 4, 1).millisecondsSinceEpoch,
            partidaId: 4,
            plagaId: 'cryphonectria_parasitica',
            resultado: 'sospecha',
            notificadaAutoridad: true),
      ],
      nombreEspecie: (id) => id == 'castano' ? 'Castaño' : id,
    );

    test(
        'tablas: datos generales, zonas con nº de orden, tratamientos en orden',
        () {
      final tablas = tablasCuadernoTratamientos(datos);
      expect(tablas, hasLength(4));
      expect(tablas[0].filas[2],
          [SoleraL10n.t('vive.codigo_ropveg'), 'ES-15200001']);
      expect(tablas[1].filas.map((fila) => fila.take(2).toList()), [
        ['1', 'Nave'],
        ['2', 'Era'],
      ]);
      final tratamientos = tablas[2].filas;
      expect(tratamientos.first[1], '2. Era', reason: 'del más antiguo');
      expect(tratamientos.last[1], '1. Nave · P26-0004');
      expect(tratamientos.last[2], 'Castaño');
      expect(tratamientos.last[10], 'Ane · C-1');
      expect(
          tablas[3].filas.single[5], SoleraL10n.t('vive.resultado_sospecha'));
    });

    test('PDF con sello', () async {
      expect(selloCuadernoTratamientos, 'PROVISIONAL');
      expect(_esPdf(await generarCuadernoTratamientosPdf(datos)), isTrue);
    });
  });

  group('pasaporte', () {
    final salida = Salida(
        id: 1,
        partidaId: 4,
        fechaMs: DateTime(2026, 10, 1).millisecondsSinceEpoch,
        cantidad: 20,
        clienteNombre: 'Jardines S. L.',
        clienteCodigoRopveg: 'ES-15200099');

    test('etiqueta: letras A-D en orden y avisos', () {
      final datos = prepararDatosPasaporte(
          vivero: vivero, partida: partida, salida: salida);
      expect(filasEtiquetaPasaporte(datos), [
        ('A', 'Castanea sativa'),
        ('B', 'ES-15200001'),
        ('C', 'P26-0004'),
        ('D', 'ES'),
      ]);
      final avisos = avisosEtiquetaPasaporte(datos);
      expect(avisos, hasLength(1));
      expect(avisos.single, startsWith('PROVISIONAL'));
    });

    test('etiqueta ZP y borrador: aviso de no válido', () {
      final datos = prepararDatosPasaporte(
          vivero: Vivero(codigoRopveg: 'ES-15200001'),
          partida: partida,
          salida: Salida(
              partidaId: 4,
              fechaMs: 0,
              cantidad: 1,
              destinoZonaProtegida: true),
          plagasZonaProtegida: 'Dryocosmus kuriphilus');
      expect(
          filasEtiquetaPasaporte(datos).last, ('ZP', 'Dryocosmus kuriphilus'));
      expect(avisosEtiquetaPasaporte(datos),
          contains(SoleraL10n.t('vive.pdf_borrador_no_valido')));
    });

    test('un registro borrador sigue siendo borrador en la etiqueta', () {
      final registro = PasaporteEmitido(
          salidaId: 1,
          fechaMs: 0,
          nombreBotanico: 'Castanea sativa',
          codigoOperador: 'ES-15200001',
          codigoTrazabilidad: 'P26-0004',
          paisOrigen: 'ES');
      expect(datosDesdeRegistro(registro, operadorAutorizado: true).esBorrador,
          isTrue);
      final firme = PasaporteEmitido(
          salidaId: 1,
          fechaMs: 0,
          nombreBotanico: 'Castanea sativa',
          codigoOperador: 'ES-15200001',
          codigoTrazabilidad: 'P26-0004',
          paisOrigen: 'ES',
          esBorrador: false);
      expect(datosDesdeRegistro(firme, operadorAutorizado: true).esBorrador,
          isFalse);
      expect(datosDesdeRegistro(firme, operadorAutorizado: false).esBorrador,
          isTrue);
    });

    test('registro: origen solo con material comprado, destino y pasaportes',
        () {
      final tablas = tablasRegistroPasaportes(
        lotesRecibidos: [
          LoteMaterial(
              codigo: 'COMPRADO',
              especieId: 'castano',
              proveedorNombre: 'Semillas Norte',
              proveedorCodigoRopveg: 'ES-15200050',
              pasaporteRecibido: 'L-778',
              fechaEntradaMs: 1),
          LoteMaterial(
              codigo: 'PROPIO',
              especieId: 'castano',
              esPropio: true,
              fechaEntradaMs: 2),
        ],
        salidas: [salida],
        pasaportes: [
          PasaporteEmitido(
              salidaId: 1,
              fechaMs: 5,
              nombreBotanico: 'Castanea sativa',
              codigoOperador: 'ES-15200001',
              codigoTrazabilidad: 'P26-0004',
              paisOrigen: 'ES',
              cantidad: 20,
              anulado: true),
        ],
        codigoPartidaPorId: {4: 'P26-0004'},
      );
      expect(tablas[0].filas.single[1], 'COMPRADO');
      expect(tablas[0].filas.single[5], 'L-778');
      expect(tablas[1].filas.single.sublist(1, 5),
          ['P26-0004', '20', 'Jardines S. L.', 'ES-15200099']);
      final registro = tablas[2].filas.single;
      expect(registro[1], 'Jardines S. L.');
      expect(registro.last, contains(SoleraL10n.t('vive.anulado')));
    });

    test('PDF de la etiqueta y del registro', () async {
      expect(selloPasaporte, 'PROVISIONAL');
      final datos = prepararDatosPasaporte(
          vivero: vivero, partida: partida, salida: salida);
      expect(_esPdf(await generarEtiquetaPasaportePdf(datos)), isTrue);
      expect(
          _esPdf(await generarRegistroPasaportesPdf(
              anyo: 2026,
              vivero: vivero,
              lotesRecibidos: const [],
              salidas: [salida],
              pasaportes: const [],
              codigoPartidaPorId: const {})),
          isTrue);
    });
  });
}
