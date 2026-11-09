import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;
import 'package:sqflite/sqflite.dart';
import 'package:solera_frutal/datos/base_datos.dart';
import 'package:solera_frutal/modelos/contrato_polinizacion.dart';
import 'package:solera_frutal/modelos/cosecha.dart';
import 'package:solera_frutal/modelos/fila_arboles.dart';
import 'package:solera_frutal/modelos/helada.dart';
import 'package:solera_frutal/modelos/observacion_plaga.dart';
import 'package:solera_frutal/modelos/parcela.dart';
import 'package:solera_frutal/modelos/riego.dart';
import 'package:solera_frutal/modelos/titular.dart';
import 'package:solera_frutal/modelos/tratamiento.dart';

import 'soporte_contrato_base_datos.dart';

/// Cambios de esquema desde la v1, para los tests de contrato.
const Map<int, CambioEsquema> historialMigracionesFrutal = {
  2: CambioEsquema(columnasNuevas: {
    'parcelas': ['contorno'],
  }),
};

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraFrutal.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea $nombreFicheroBaseDatosFrutal en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaFrutal);
    expect(
        File(entorno.ruta(nombreFicheroBaseDatosFrutal)).existsSync(), isTrue);
  });

  test('el esquema creado es el v1 más el historial de migraciones', () async {
    final db = await baseDatos.basedatos;
    final actuales = await leerColumnasPorTabla(db);
    expect(
        actuales,
        columnasDeclaradasEnVersion(
          columnasV1: await columnasDeEsquemaV1(sentenciasEsquemaFrutalV1),
          historial: historialMigracionesFrutal,
          columnasActuales: actuales,
          version: versionEsquemaFrutal,
        ));
    expect(historialMigracionesFrutal.keys.reduce((a, b) => a > b ? a : b),
        versionEsquemaFrutal);
  });

  test('migra desde la v1 sin perder filas y con el contorno vacío', () async {
    final filas = {
      'parcelas': {'nombre': 'Almendral', 'especie_id': 'almendro'},
    };
    await crearBaseDatosHistorica(
      ruta: entorno.ruta(nombreFicheroBaseDatosFrutal),
      version: 1,
      sentenciasEsquemaV1: sentenciasEsquemaFrutalV1,
      historial: historialMigracionesFrutal,
      columnasActuales: const {},
      filasPorTabla: filas,
    );
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaFrutal);
    await comprobarFilasConservadas(db, filas);
    final parcela = (await baseDatos.listarParcelas()).single;
    expect(parcela.contorno, '[]');
    expect(parcela.vertices, isEmpty);
  });

  test('el área de una parcela se guarda y se lee', () async {
    const area = [
      LatLng(42.0, -1.0),
      LatLng(42.0, -0.999),
      LatLng(42.001, -0.999),
    ];
    await baseDatos.guardarParcela(Parcela(
        nombre: 'Almendral',
        especieId: 'almendro',
        contorno: codificarContorno(area)));
    final guardada = (await baseDatos.listarParcelas()).single;
    expect(guardada.vertices, area);
    expect(guardada.copiarConUbicacion(42, -1).vertices, area);
  });

  test('el titular se guarda en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos
        .guardarTitular(Titular(nombre: 'Segunda', asesorNumeroRopo: 'ROPO-1'));
    final filas = await (await baseDatos.basedatos).query('titulares');
    expect(filas, hasLength(1));
    final titular = await baseDatos.obtenerTitular();
    expect(titular.nombre, 'Segunda');
    expect(titular.asesorNumeroRopo, 'ROPO-1');
  });

  test('parcela con filas, contratos y observaciones: borrado en cascada',
      () async {
    final parcela = await baseDatos.guardarParcela(
        Parcela(nombre: 'La Loma', especieId: 'almendro', superficieHa: 2));
    await baseDatos.guardarFilaArboles(FilaArboles(
        parcelaId: parcela, etiqueta: 'Filas 1-6', variedadId: 'guara'));
    await baseDatos.guardarContratoPolinizacion(ContratoPolinizacion(
        parcelaId: parcela,
        campania: 2027,
        apicultorNombre: 'Miren',
        numeroColmenas: 8));
    await baseDatos.guardarObservacionPlaga(ObservacionPlaga(
        parcelaId: parcela, fechaMs: 1, plagaId: 'eurytoma_amygdali'));
    expect(
        await baseDatos.listarFilasArboles(parcelaId: parcela), hasLength(1));
    expect(
        (await baseDatos.listarContratosPolinizacion(campania: 2027))
            .single
            .colmenasPorHectarea(2),
        4);
    await baseDatos.borrarParcela(parcela);
    expect(await baseDatos.listarFilasArboles(), isEmpty);
    expect(await baseDatos.listarContratosPolinizacion(), isEmpty);
    expect(await baseDatos.listarObservacionesPlaga(), isEmpty);
  });

  test('no se puede borrar una parcela con registros del cuaderno', () async {
    final parcela = await baseDatos
        .guardarParcela(Parcela(nombre: 'Avellanar', especieId: 'avellano'));
    await baseDatos.guardarTratamiento(Tratamiento(
        parcelaId: parcela, fechaMs: 10, sustanciaActivaId: 'azufre'));
    await expectLater(baseDatos.borrarParcela(parcela), throwsA(anything));
    expect(await baseDatos.listarParcelas(), hasLength(1));
  });

  test('registros filtrados por parcela y fechas, del más reciente', () async {
    final norte = await baseDatos
        .guardarParcela(Parcela(nombre: 'N', especieId: 'nogal'));
    final sur = await baseDatos
        .guardarParcela(Parcela(nombre: 'S', especieId: 'nogal'));
    for (final (parcela, fecha) in [(norte, 5), (sur, 15), (norte, 25)]) {
      await baseDatos.guardarRiego(
          Riego(parcelaId: parcela, fechaMs: fecha, volumenM3: 10));
    }
    expect(
        (await baseDatos.listarRiegos(parcelaId: norte))
            .map((riego) => riego.fechaMs),
        [25, 5]);
    expect(
        (await baseDatos.listarRiegos(desdeMs: 10, hastaMs: 20))
            .map((riego) => riego.fechaMs),
        [15]);
  });

  test('cosechas por campaña y lista de campañas', () async {
    final parcela = await baseDatos
        .guardarParcela(Parcela(nombre: 'Castañar', especieId: 'castano'));
    for (final campania in [2025, 2026, 2026]) {
      await baseDatos.guardarCosecha(Cosecha(
          parcelaId: parcela,
          campania: campania,
          fechaMs: campania,
          kgCascara: 100));
    }
    expect(await baseDatos.campaniasConCosecha(), [2026, 2025]);
    expect(await baseDatos.listarCosechas(campania: 2026), hasLength(2));
  });

  test('una helada de toda la explotación no tiene parcela', () async {
    final parcela = await baseDatos
        .guardarParcela(Parcela(nombre: 'P', especieId: 'almendro'));
    await baseDatos.guardarHelada(Helada(fechaMs: 3, temperaturaMinimaC: -2));
    await baseDatos.guardarHelada(Helada(parcelaId: parcela, fechaMs: 4));
    final heladas = await baseDatos.listarHeladas();
    expect(heladas.map((helada) => helada.parcelaId), [parcela, null]);
  });
}
