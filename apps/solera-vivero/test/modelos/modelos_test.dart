import 'package:flutter_test/flutter_test.dart';
import 'package:solera_vivero/modelos/bandeja.dart';
import 'package:solera_vivero/modelos/inspeccion_plagas.dart';
import 'package:solera_vivero/modelos/lote_material.dart';
import 'package:solera_vivero/modelos/partida_planta.dart';
import 'package:solera_vivero/modelos/pasaporte_emitido.dart';
import 'package:solera_vivero/modelos/repicado.dart';
import 'package:solera_vivero/modelos/salida.dart';
import 'package:solera_vivero/modelos/siembra.dart';
import 'package:solera_vivero/modelos/tratamiento.dart';
import 'package:solera_vivero/modelos/vivero.dart';
import 'package:solera_vivero/modelos/zona_cultivo.dart';

void main() {
  test('vivero: ida y vuelta, código ROPVEG normalizado y letra B', () {
    final vivero = Vivero.fromMap(Vivero(
            nombre: 'Vivero Txantxa',
            codigoRopveg: 'es 1520 0001',
            autorizadoPasaporte: true,
            personaContactoFitosanitaria: 'Ane')
        .toMap());
    expect(vivero.autorizadoPasaporte, isTrue);
    expect(vivero.codigoRopvegNormalizado, 'ES-15200001');
    expect(vivero.letraBPasaporte, 'ES-15200001');
    expect(Vivero.fromMap({}).autorizadoPasaporte, isFalse);
    expect(Vivero().letraBPasaporte, '');
  });

  test('forma del código ROPVEG (RD 1054/2021, art. 8)', () {
    expect(tieneFormaCodigoRopveg('ES-15200001'), isTrue);
    expect(tieneFormaCodigoRopveg('15200001'), isTrue, reason: 'añade ES-');
    expect(tieneFormaCodigoRopveg('ES-00FR0042'), isTrue);
    expect(tieneFormaCodigoRopveg('ES-1520'), isFalse);
    expect(tieneFormaCodigoRopveg(''), isFalse);
    expect(tieneFormaCodigoRopveg('ES-1520000A'), isFalse);
  });

  test('zona: ida y vuelta y ubicación', () {
    final zona = ZonaCultivo.fromMap(
        ZonaCultivo(nombre: 'Era de abajo', tipo: 'exterior', superficieM2: 900)
            .toMap());
    expect((zona.esExterior, zona.tieneUbicacion, zona.superficieM2),
        (true, false, 900));
    final ubicada = zona.copiarConUbicacion(43.2, -2.1);
    expect((ubicada.tieneUbicacion, ubicada.nombre), (true, 'Era de abajo'));
  });

  test('lote de material: ida y vuelta y perfil forestal', () {
    final lote = LoteMaterial.fromMap(LoteMaterial(
            codigo: 'QR-2026-01',
            tipo: 'semilla',
            especieId: 'quercus_robur',
            nombreBotanico: 'Quercus robur',
            proveedorNombre: 'Banco de semillas',
            fechaEntradaMs: 5,
            cantidad: 2.5,
            unidad: 'kg',
            categoriaForestal: 'identificado',
            regionProcedencia: 'Montaña de Navarra (RP 3)')
        .toMap());
    expect(lote.esForestal, isTrue);
    expect(lote.cantidad, 2.5);
    expect(lote.regionProcedencia, 'Montaña de Navarra (RP 3)');
    expect(lote.paisOrigen, 'ES');
    expect(
        LoteMaterial(codigo: 'x', especieId: 'y', fechaEntradaMs: 0).esForestal,
        isFalse);
  });

  test('bandeja: ida y vuelta y siguiente código QR', () {
    final bandeja = Bandeja.fromMap(
        Bandeja(codigoQr: 'VIV-B-0003', numeroAlveolos: 104, activa: false)
            .toMap());
    expect((bandeja.numeroAlveolos, bandeja.activa), (104, false));
    expect(Bandeja.fromMap({'codigo_qr': 'a'}).activa, isTrue);
    expect(siguienteCodigoBandeja([]), 'VIV-B-0001');
    expect(siguienteCodigoBandeja(['VIV-B-0009', 'VIV-B-0002', 'OTRO-77']),
        'VIV-B-0010');
  });

  test('siembra: unidades puestas', () {
    final siembra = Siembra.fromMap(Siembra(
            loteMaterialId: 1,
            bandejaId: 2,
            fechaMs: 3,
            alveolosOcupados: 96,
            unidadesPorAlveolo: 2)
        .toMap());
    expect(siembra.unidadesPuestas, 192);
    expect(siembra.metodo, 'siembra');
  });

  test('partida: ida y vuelta, copia y código del año', () {
    final partida = PartidaPlanta.fromMap(PartidaPlanta(
            codigo: 'P26-0001',
            especieId: 'tomate',
            nombreBotanico: 'Solanum lycopersicum',
            variedad: 'Feo de Tudela',
            cantidadInicial: 200,
            mermas: 4,
            siembraId: 1,
            fechaAltaMs: 9)
        .toMap());
    expect((partida.mermas, partida.siembraId, partida.listaParaVenta),
        (4, 1, false));
    final lista = partida.copiarCon(listaParaVenta: true, mermas: 6);
    expect((lista.listaParaVenta, lista.mermas, lista.codigo),
        (true, 6, 'P26-0001'));
    expect(siguienteCodigoPartida(['P26-0007', 'P25-0100'], 2026), 'P26-0008');
    expect(siguienteCodigoPartida([], 2027), 'P27-0001');
  });

  test('repicado, salida y pasaporte: ida y vuelta', () {
    expect(
        Repicado.fromMap(Repicado(
                    partidaOrigenId: 1,
                    partidaDestinoId: 2,
                    fechaMs: 3,
                    cantidad: 40)
                .toMap())
            .cantidad,
        40);
    final salida = Salida.fromMap(Salida(
            partidaId: 1,
            fechaMs: 2,
            cantidad: 50,
            esUsuarioFinal: true,
            esVentaADistancia: true,
            destinoZonaProtegida: true,
            esTrasladoPropioMismaComunidad: true,
            importeCentimos: 2500)
        .toMap());
    expect((
      salida.esUsuarioFinal,
      salida.esVentaADistancia,
      salida.destinoZonaProtegida,
      salida.esTrasladoPropioMismaComunidad,
      salida.importeCentimos
    ), (
      true,
      true,
      true,
      true,
      2500
    ));
    final pasaporte = PasaporteEmitido.fromMap(PasaporteEmitido(
            salidaId: 1,
            fechaMs: 2,
            nombreBotanico: 'Castanea sativa',
            codigoOperador: 'ES-15200001',
            codigoTrazabilidad: 'P26-0001',
            paisOrigen: 'ES',
            esBorrador: false)
        .toMap());
    expect((pasaporte.esBorrador, pasaporte.anulado), (false, false));
    expect(pasaporte.copiarAnulado().anulado, isTrue);
  });

  test('tratamiento e inspección: ida y vuelta y avisos', () {
    final tratamiento = Tratamiento.fromMap(Tratamiento(
            fechaMs: DateTime(2026, 5, 1).millisecondsSinceEpoch,
            partidaId: 1,
            plazoSeguridadDias: 3)
        .toMap());
    expect(tratamiento.finPlazoSeguridad, DateTime(2026, 5, 4));
    expect(Tratamiento(fechaMs: 0).finPlazoSeguridad, isNull);
    final inspeccion = InspeccionPlagas.fromMap(InspeccionPlagas(
            fechaMs: 1,
            zonaId: 2,
            plagaId: 'xylella_fastidiosa',
            resultado: 'sospecha')
        .toMap());
    expect(inspeccion.pendienteDeNotificar, isTrue);
    expect(InspeccionPlagas(fechaMs: 1, plagaId: 'x').pendienteDeNotificar,
        isFalse);
  });
}
