import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:solera_monte/modelos/actuacion_plan.dart';
import 'package:solera_monte/modelos/apunte_economico.dart';
import 'package:solera_monte/modelos/aprovechamiento.dart';
import 'package:solera_monte/modelos/arbol_singular.dart';
import 'package:solera_monte/modelos/ejecucion.dart';
import 'package:solera_monte/modelos/incendios.dart';
import 'package:solera_monte/modelos/monte.dart';
import 'package:solera_monte/modelos/rodal.dart';
import 'package:solera_monte/modelos/sorteo_lena.dart';

void main() {
  test('monte: ida y vuelta, valores raros a lo seguro, época de peligro', () {
    final monte = Monte.fromMap(Monte(
      nombre: 'Monte Común',
      figura: 'vecinal_mano_comun',
      instrumentoGestion: 'plan_dasocratico',
      certificacion: 'pefc',
      inicioEpocaPeligroMes: 6,
      inicioEpocaPeligroDia: 1,
    ).toMap());
    expect(
        (monte.esComunal, monte.tieneInstrumentoGestion, monte.estaCertificado),
        (true, true, true));
    expect(monte.inicioEpocaPeligroEn(2027), DateTime(2027, 6, 1));
    expect(
        Monte(inicioEpocaPeligroMes: 2, inicioEpocaPeligroDia: 31)
            .inicioEpocaPeligroEn(2027),
        isNull);
    expect(Monte().inicioEpocaPeligroEn(2027), isNull);
    final raro = Monte.fromMap(
        {'figura': 'xx', 'certificacion': 'yy', 'instrumento_gestion': 'zz'});
    expect((raro.figura, raro.certificacion, raro.instrumentoGestion),
        ('otro', 'ninguna', 'otro'));
    expect(Monte(figura: 'particular').esComunal, isFalse);
  });

  test('contorno y traza: JSON defensivo al leer la fila', () {
    expect(Rodal.fromMap(const {'contorno': 'no es json'}).contorno, isEmpty);
    expect(Rodal.fromMap(const {'contorno': '[[1],[2,"a"],[3,4]]'}).contorno,
        const [LatLng(3, 4)]);
    expect(Rodal.fromMap(const {}).contorno, isEmpty);
    expect(
        InfraestructuraIncendios.fromMap(const {'traza': '[[42.1,-1.5]]'})
            .traza,
        const [LatLng(42.1, -1.5)]);
  });

  test('rodal: superficie declarada o dibujada, edad, etiqueta', () {
    // Cuadrado de ~100 m de lado a 42,8° N: ~1 ha.
    const lado = 0.0009;
    const contorno = [
      LatLng(42.8, -1.6),
      LatLng(42.8 + lado, -1.6),
      LatLng(42.8 + lado, -1.6 + lado / 0.7337),
      LatLng(42.8, -1.6 + lado / 0.7337),
    ];
    final rodal = Rodal.fromMap(Rodal(
      codigo: '3c',
      nombre: 'Hayedo',
      especiePrincipalId: 'fagus_sylvatica',
      especiesSecundarias: const ['quercus_robur'],
      anyoOrigen: 1960,
      contorno: contorno,
    ).toMap());
    expect(rodal.superficieCalculadaHa, closeTo(1.0, 0.03));
    expect(rodal.superficieHa, rodal.superficieCalculadaHa);
    final declarado = Rodal(
        codigo: '3c', especiePrincipalId: 'x', superficieDeclaradaHa: 1.2);
    expect(declarado.superficieHa, 1.2);
    expect(declarado.tieneContorno, isFalse);
    expect(rodal.edadEn(2026), 66);
    expect(rodal.edadEn(1950), isNull);
    expect(rodal.etiqueta, '3c · Hayedo');
    expect(rodal.especiesSecundarias, ['quercus_robur']);
    expect(Rodal.fromMap({'estado_masa': 'raro'}).estadoMasa, 'fustal');
    expect(rodal.conContorno(const []).tieneContorno, isFalse);
  });

  test('actuación y ejecución: ida y vuelta', () {
    final actuacion = ActuacionPlan.fromMap(ActuacionPlan(
            rodalId: 2,
            anyoPrevisto: 2027,
            tipo: 'clara',
            volumenPrevistoM3: 80,
            cancelada: true)
        .toMap());
    expect((actuacion.volumenPrevistoM3, actuacion.cancelada), (80, true));
    expect(
        ActuacionPlan.fromMap({'anyo_previsto': 1, 'tipo': '?'}).tipo, 'otra');
    final ejecucion = Ejecucion.fromMap(Ejecucion(
            actuacionPlanId: 4,
            fechaMs: 9,
            tipo: 'poda',
            completa: false,
            ejecutor: 'Vereda')
        .toMap());
    expect((ejecucion.completa, ejecucion.ejecutor, ejecucion.actuacionPlanId),
        (false, 'Vereda', 4));
  });

  test('aprovechamiento: ida y vuelta, maderable o no', () {
    final aprovechamiento = Aprovechamiento.fromMap(Aprovechamiento(
      campanya: 2026,
      tipo: 'lena',
      fechaInicioMs: 1,
      fechaFinMs: 2,
      cantidad: 30,
      unidad: 'estereos',
      modalidad: 'lotes_vecinales',
      tramite: 'declaracion_responsable',
      comercializado: true,
    ).toMap());
    expect((
      aprovechamiento.esMaderableOLenoso,
      aprovechamiento.terminado,
      aprovechamiento.comercializado
    ), (
      true,
      true,
      true
    ));
    expect(
        Aprovechamiento(campanya: 1, tipo: 'hongos', fechaInicioMs: 1)
            .esMaderableOLenoso,
        isFalse);
    final raro = Aprovechamiento.fromMap({
      'campanya': 1,
      'fecha_inicio_ms': 1,
      'tipo': 'x',
      'unidad': 'y',
      'tramite': 'z'
    });
    expect(
        (raro.tipo, raro.unidad, raro.tramite), ('otros', 'unidades', 'otro'));
    expect(tiposAprovechamiento, hasLength(12),
        reason: 'los 11 del art. 6.i de la Ley 43/2003 más «otros»');
  });

  test('sorteo y lote: ida y vuelta, lista defensiva', () {
    final sorteo = SorteoLena.fromMap(SorteoLena(
      campanya: 2026,
      participantes: const ['Casa Juana', 'Casa Pello'],
      semilla: '12345',
      realizado: true,
    ).toMap());
    expect(sorteo.participantes, ['Casa Juana', 'Casa Pello']);
    expect((sorteo.semilla, sorteo.realizado), ('12345', true));
    expect(leerParticipantes('{roto'), isEmpty);
    expect(leerParticipantes('[1, "Ana"]'), ['Ana']);
    final lote =
        LoteLena.fromMap(LoteLena(sorteoId: 1, numero: 3, cantidad: 8).toMap());
    expect((lote.numero, lote.unidad, lote.adjudicado), (3, 'estereos', false));
    expect(lote.conAdjudicatario('Ana').adjudicado, isTrue);
  });

  test('infraestructura y revisión: ida y vuelta, traza, lineal', () {
    final pista = InfraestructuraIncendios.fromMap(InfraestructuraIncendios(
        tipo: 'pista',
        nombre: 'Pista',
        traza: const [LatLng(1, 2), LatLng(3, 4)]).toMap());
    expect((pista.esLineal, pista.traza.length), (true, 2));
    final balsa = InfraestructuraIncendios(
            tipo: 'punto_agua', nombre: 'Balsa', capacidadM3: 50)
        .conUbicacion(42, -1);
    expect((balsa.esLineal, balsa.tieneUbicacion), (false, true));
    final revision = RevisionIncendios.fromMap(RevisionIncendios(
            infraestructuraId: 1, fechaMs: 5, estado: 'necesita_mantenimiento')
        .toMap());
    expect(revision.pideTrabajo, isTrue);
    expect(
        RevisionIncendios.fromMap(
                {'infraestructura_id': 1, 'fecha_ms': 1, 'estado': '?'})
            .pideTrabajo,
        isTrue,
        reason: 'un estado desconocido nunca se da por bueno');
  });

  test('árbol singular: ida y vuelta y texto del QR sin URL', () {
    final arbol = ArbolSingular.fromMap(ArbolSingular(
            codigo: 'AS-001',
            nombre: 'Roble de la fuente',
            especieId: 'quercus_robur',
            perimetroCm: 420)
        .toMap());
    expect(arbol.perimetroCm, 420);
    final qr = arbol.textoQr('Monte Común');
    expect(qr, contains('AS-001'));
    expect(qr, isNot(contains('http')));
    expect(ArbolSingular.fromMap({'tipo': '?'}).tipo, 'arbol_singular');
  });

  test('apunte: total con IVA o compensación', () {
    final apunte = ApunteEconomico.fromMap(ApunteEconomico(
            esIngreso: true,
            fechaMs: 1,
            concepto: 'Subasta',
            categoria: 'venta_madera',
            baseCentimos: 100000,
            tipoIvaPorcentaje: 21,
            aprovechamientoId: 3)
        .toMap());
    expect((apunte.cuotaIvaCentimos, apunte.totalCentimos), (21000, 121000));
    expect(apunte.aprovechamientoId, 3);
  });
}
