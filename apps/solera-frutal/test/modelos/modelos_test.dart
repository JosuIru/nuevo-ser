import 'package:flutter_test/flutter_test.dart';
import 'package:solera_frutal/modelos/abonado.dart';
import 'package:solera_frutal/modelos/contrato_polinizacion.dart';
import 'package:solera_frutal/modelos/cosecha.dart';
import 'package:solera_frutal/modelos/fila_arboles.dart';
import 'package:solera_frutal/modelos/helada.dart';
import 'package:solera_frutal/modelos/observacion_plaga.dart';
import 'package:solera_frutal/modelos/parcela.dart';
import 'package:solera_frutal/modelos/riego.dart';
import 'package:solera_frutal/modelos/titular.dart';
import 'package:solera_frutal/modelos/tratamiento.dart';

void main() {
  test('parcela: ida y vuelta; secano sin sistema de riego', () {
    final parcela = Parcela(
        id: 1,
        nombre: 'La Loma',
        especieId: 'almendro',
        variedadPrincipalId: 'guara',
        superficieHa: 3.5,
        marcoPlantacion: '7x6',
        anyoPlantacion: 2019,
        sistemaRiego: 'goteo',
        latitud: 41.6,
        longitud: -0.9);
    final vuelta = Parcela.fromMap(parcela.toMap());
    expect(vuelta.nombre, 'La Loma');
    expect(vuelta.superficieHa, 3.5);
    expect(vuelta.anyoPlantacion, 2019);
    expect(vuelta.regadio, isFalse);
    expect(vuelta.sistemaRiego, '', reason: 'en secano no se guarda');
    expect(vuelta.tieneUbicacion, isTrue);
    final movida = vuelta.copiarConUbicacion(42, -1);
    expect(
        (movida.latitud, movida.longitud, movida.nombre), (42, -1, 'La Loma'));
  });

  test('marco de plantación → árboles por hectárea', () {
    expect(arbolesPorHectareaDesdeMarco('7x6')!.round(), 238);
    expect(arbolesPorHectareaDesdeMarco('5 × 4'), 500);
    expect(arbolesPorHectareaDesdeMarco('6,5x4')!.round(), 385);
    expect(arbolesPorHectareaDesdeMarco('5 m x 2 m'), 1000);
    expect(arbolesPorHectareaDesdeMarco(''), isNull);
    expect(arbolesPorHectareaDesdeMarco('7'), isNull);
    expect(arbolesPorHectareaDesdeMarco('0x5'), isNull);
    expect(arbolesPorHectareaDesdeMarco('marco real'), isNull);
  });

  test('fila de árboles y titular: ida y vuelta', () {
    final fila = FilaArboles.fromMap(FilaArboles(
            parcelaId: 2,
            etiqueta: 'Lindero',
            variedadId: 'marcona',
            numeroArboles: 40,
            esPolinizadora: true)
        .toMap());
    expect((fila.esPolinizadora, fila.numeroArboles), (true, 40));
    final titular = Titular.fromMap(
        Titular(nombre: 'Ana', registroExplotacion: 'ES-1').toMap());
    expect(titular.registroExplotacion, 'ES-1');
    expect(Titular.fromMap({}).nombre, '');
  });

  test('contrato de polinización: colmenas por hectárea y presencia', () {
    final contrato = ContratoPolinizacion(
        parcelaId: 1,
        campania: 2027,
        apicultorNombre: 'Miren',
        numeroColmenas: 12,
        fechaEntradaMs: 100,
        fechaSalidaMs: 200,
        precioCentimosPorColmena: 3500);
    expect(contrato.colmenasPorHectarea(4), 3);
    expect(contrato.colmenasPorHectarea(0), isNull);
    expect(contrato.importeTotalCentimos, 42000);
    expect(contrato.estaEnParcela(150), isTrue);
    expect(contrato.estaEnParcela(250), isFalse);
    expect(
        ContratoPolinizacion(parcelaId: 1, campania: 1, apicultorNombre: '')
            .estaEnParcela(1),
        isFalse);
    expect(ContratoPolinizacion.fromMap(contrato.toMap()).fechaSalidaMs, 200);
  });

  test('tratamiento: plazo de seguridad y campos opcionales', () {
    final fecha = DateTime(2027, 6, 1);
    final tratamiento = Tratamiento(
        parcelaId: 1,
        fechaMs: fecha.millisecondsSinceEpoch,
        sustanciaActivaId: 'azufre',
        plazoSeguridadDias: 5,
        eficacia: 'buena');
    expect(tratamiento.finPlazoSeguridad, DateTime(2027, 6, 6));
    final vuelta = Tratamiento.fromMap(tratamiento.toMap());
    expect((vuelta.plazoSeguridadDias, vuelta.eficacia), (5, 'buena'));
    expect(Tratamiento(parcelaId: 1, fechaMs: 0).finPlazoSeguridad, isNull);
  });

  test('cosecha: kilos de grano solo con rendimiento', () {
    final cosecha = Cosecha(
        parcelaId: 1,
        campania: 2026,
        fechaMs: 0,
        kgCascara: 1000,
        rendimientoGranoPorcentaje: 28,
        humedadPorcentaje: 6);
    expect(cosecha.kgGrano, closeTo(280, 1e-9));
    expect(Cosecha.fromMap(cosecha.toMap()).humedadPorcentaje, 6);
    expect(Cosecha(parcelaId: 1, campania: 1, fechaMs: 0, kgCascara: 5).kgGrano,
        isNull);
  });

  test('abonado, riego, helada y observación: ida y vuelta', () {
    expect(
        Abonado.fromMap(Abonado(
                    parcelaId: 1,
                    fechaMs: 0,
                    tipoAbono: 'Estiércol',
                    metodo: 'cobertera',
                    cantidadKgPorHa: 2000)
                .toMap())
            .metodo,
        'cobertera');
    final riego = Riego(parcelaId: 1, fechaMs: 0, volumenM3: 30, horas: 2.5);
    expect(riego.litrosPorArbol(300), 100);
    expect(riego.litrosPorArbol(0), isNull);
    expect(Riego.fromMap(riego.toMap()).horas, 2.5);
    final helada = Helada.fromMap(Helada(
            fechaMs: 1,
            temperaturaMinimaC: -3.5,
            esPedrisco: true,
            comunicadaAlSeguro: true)
        .toMap());
    expect((helada.parcelaId, helada.temperaturaMinimaC, helada.esPedrisco),
        (null, -3.5, true));
    final observacion = ObservacionPlaga.fromMap(ObservacionPlaga(
            parcelaId: 1,
            fechaMs: 0,
            plagaId: 'curculio_nucum',
            recuento: 3,
            superaUmbral: true)
        .toMap());
    expect((observacion.recuento, observacion.superaUmbral), (3, true));
  });
}
