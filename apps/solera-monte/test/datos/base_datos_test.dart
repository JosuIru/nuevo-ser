import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_monte/datos/base_datos.dart';
import 'package:solera_monte/modelos/actuacion_plan.dart';
import 'package:solera_monte/modelos/aprovechamiento.dart';
import 'package:solera_monte/modelos/arbol_singular.dart';
import 'package:solera_monte/modelos/ejecucion.dart';
import 'package:solera_monte/modelos/incendios.dart';
import 'package:solera_monte/modelos/monte.dart';
import 'package:solera_monte/modelos/rodal.dart';
import 'package:solera_monte/modelos/sorteo_lena.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraMonte.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea $nombreFicheroBaseDatosMonte en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaMonte);
    expect(
        File(entorno.ruta(nombreFicheroBaseDatosMonte)).existsSync(), isTrue);
  });

  test('el esquema creado coincide con las sentencias v1', () async {
    final db = await baseDatos.basedatos;
    expect(await leerColumnasPorTabla(db),
        await columnasDeEsquemaV1(sentenciasEsquemaMonteV1));
  });

  test('el monte se guarda en una sola fila', () async {
    await baseDatos.guardarMonte(Monte(nombre: 'Primero'));
    await baseDatos.guardarMonte(Monte(
        nombre: 'Monte de la Junta',
        figura: 'comunal_junta_vecinal',
        comunidadAutonoma: 'Navarra'));
    final filas = await (await baseDatos.basedatos).query('montes');
    expect(filas, hasLength(1));
    final monte = await baseDatos.obtenerMonte();
    expect((monte.nombre, monte.figura, monte.esComunal),
        ('Monte de la Junta', 'comunal_junta_vecinal', true));
  });

  test('rodales: código único, ordenados por código, contorno guardado',
      () async {
    await baseDatos.guardarRodal(Rodal(
        codigo: '2a',
        especiePrincipalId: 'pinus_sylvestris',
        contorno: const [
          LatLng(42.8, -1.6),
          LatLng(42.8, -1.59),
          LatLng(42.79, -1.59)
        ]));
    await baseDatos.guardarRodal(
        Rodal(codigo: '1b', especiePrincipalId: 'fagus_sylvatica'));
    await expectLater(
        baseDatos.guardarRodal(Rodal(codigo: '2a', especiePrincipalId: 'otra')),
        throwsA(anything));
    final rodales = await baseDatos.listarRodales();
    expect(rodales.map((r) => r.codigo), ['1b', '2a']);
    expect(rodales.last.contorno, hasLength(3));
    expect(rodales.last.superficieCalculadaHa, greaterThan(0));
  });

  test('un rodal con plan o aprovechamientos no se borra', () async {
    final rodal = await baseDatos
        .guardarRodal(Rodal(codigo: 'R1', especiePrincipalId: 'x'));
    await baseDatos.guardarActuacion(
        ActuacionPlan(rodalId: rodal, anyoPrevisto: 2027, tipo: 'clara'));
    await expectLater(baseDatos.borrarRodal(rodal), throwsA(anything));
    final libre = await baseDatos
        .guardarRodal(Rodal(codigo: 'R2', especiePrincipalId: 'x'));
    await baseDatos.guardarAprovechamiento(Aprovechamiento(
        campanya: 2026, rodalId: libre, tipo: 'lena', fechaInicioMs: 1));
    await expectLater(baseDatos.borrarRodal(libre), throwsA(anything));
    final vacio = await baseDatos
        .guardarRodal(Rodal(codigo: 'R3', especiePrincipalId: 'x'));
    await baseDatos.borrarRodal(vacio);
    expect(await baseDatos.listarRodales(), hasLength(2));
  });

  test('plan: por años; borrar una actuación deja la ejecución sin plan',
      () async {
    final prevista = await baseDatos
        .guardarActuacion(ActuacionPlan(anyoPrevisto: 2026, tipo: 'desbroce'));
    await baseDatos
        .guardarActuacion(ActuacionPlan(anyoPrevisto: 2028, tipo: 'clara'));
    await baseDatos.guardarEjecucion(
        Ejecucion(actuacionPlanId: prevista, fechaMs: 10, tipo: 'desbroce'));
    expect(await baseDatos.listarActuaciones(desdeAnyo: 2027), hasLength(1));
    await baseDatos.borrarActuacion(prevista);
    final ejecucion = (await baseDatos.listarEjecuciones()).single;
    expect((ejecucion.actuacionPlanId, ejecucion.tipo), (null, 'desbroce'));
  });

  test(
      'sorteo: número de lote único, resultado en transacción, borrado en '
      'cascada', () async {
    final sorteo = await baseDatos.guardarSorteo(SorteoLena(
        campanya: 2026, participantes: const ['Casa Juana', 'Casa Pello']));
    final lote1 =
        await baseDatos.guardarLote(LoteLena(sorteoId: sorteo, numero: 1));
    await baseDatos.guardarLote(LoteLena(sorteoId: sorteo, numero: 2));
    await expectLater(
        baseDatos.guardarLote(LoteLena(sorteoId: sorteo, numero: 1)),
        throwsA(anything));
    final guardado = (await baseDatos.obtenerSorteo(sorteo))!;
    expect(guardado.participantes, ['Casa Juana', 'Casa Pello']);
    await baseDatos.guardarResultadoSorteo(
        guardado.copiarCon(semilla: 'S', realizado: true), [
      LoteLena(
          id: lote1, sorteoId: sorteo, numero: 1, adjudicatario: 'Casa Pello')
    ]);
    final lotes = await baseDatos.listarLotes(sorteoId: sorteo);
    expect(lotes.map((l) => l.adjudicatario), ['Casa Pello', '']);
    expect((await baseDatos.obtenerSorteo(sorteo))!.realizado, isTrue);
    await baseDatos.borrarSorteo(sorteo);
    expect(await baseDatos.listarLotes(), isEmpty);
  });

  test('incendios: revisiones por infraestructura; con revisiones no se borra',
      () async {
    final pista = await baseDatos.guardarInfraestructura(
        InfraestructuraIncendios(tipo: 'pista', nombre: 'Pista del alto'));
    final balsa = await baseDatos.guardarInfraestructura(
        InfraestructuraIncendios(
            tipo: 'punto_agua', nombre: 'Balsa', activa: false));
    await baseDatos.guardarRevision(
        RevisionIncendios(infraestructuraId: pista, fechaMs: 5));
    await baseDatos.guardarRevision(RevisionIncendios(
        infraestructuraId: balsa, fechaMs: 6, estado: 'no_utilizable'));
    expect(await baseDatos.listarRevisiones(infraestructuraId: pista),
        hasLength(1));
    expect(await baseDatos.listarInfraestructuras(soloActivas: true),
        hasLength(1));
    await expectLater(
        baseDatos.borrarInfraestructura(pista), throwsA(anything));
  });

  test('árboles: código único; borrar el rodal no se lleva el árbol', () async {
    final rodal = await baseDatos
        .guardarRodal(Rodal(codigo: 'R', especiePrincipalId: 'x'));
    await baseDatos.guardarArbol(
        ArbolSingular(codigo: 'AS-001', nombre: 'Roble', rodalId: rodal));
    await expectLater(baseDatos.guardarArbol(ArbolSingular(codigo: 'AS-001')),
        throwsA(anything));
    await baseDatos.borrarRodal(rodal);
    expect((await baseDatos.listarArboles()).single.rodalId, isNull);
  });

  test('régimen fiscal: sin elegir por defecto, una sola fila', () async {
    expect(await baseDatos.obtenerRegimenFiscal(), 'sin_elegir');
    await baseDatos.guardarRegimenFiscal('particular_reagp');
    await baseDatos.guardarRegimenFiscal('comunidad_montes');
    expect(await baseDatos.obtenerRegimenFiscal(), 'comunidad_montes');
  });
}
