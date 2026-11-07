import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aromaticas/dominio/recoleccion.dart';
import 'package:solera_aromaticas/dominio/rendimientos.dart';
import 'package:solera_aromaticas/dominio/trazabilidad.dart';
import 'package:solera_aromaticas/modelos/cosecha.dart';
import 'package:solera_aromaticas/modelos/destilacion.dart';
import 'package:solera_aromaticas/modelos/lote_producto.dart';
import 'package:solera_aromaticas/modelos/parcela.dart';
import 'package:solera_aromaticas/modelos/secado.dart';
import 'package:solera_aromaticas/modelos/zona_recoleccion.dart';

int ms(int anyo, int mes, int dia) =>
    DateTime(anyo, mes, dia).millisecondsSinceEpoch;

void main() {
  group('rendimientos', () {
    test('secado: kg secos por 100 kg frescos', () {
      expect(rendimientoSecadoPorcentaje(100, 25), 25);
      expect(rendimientoSecadoPorcentaje(0, 5), isNull);
      expect(
          Secado(fechaInicioMs: 0, especieId: 'x', kgFrescos: 40, kgSecos: 10)
              .rendimientoPorcentaje,
          25);
    });

    test('destilación: % v/p = ml por 100 g de planta', () {
      // 300 kg de lavandín y 3 litros de aceite → 1 % v/p.
      expect(rendimientoAceitePorcentaje(300, 3000), closeTo(1, 1e-9));
      expect(rendimientoAceitePorcentaje(0, 10), isNull);
      expect(hidrolatoPorKg(200, 100), 0.5);
      final destilacion = Destilacion(
          fechaMs: 0,
          especieId: 'romero',
          kgPlanta: 100,
          mlAceiteEsencial: 500);
      expect(destilacion.rendimientoAceite, closeTo(0.5, 1e-9));
    });

    test('comparación con el intervalo orientativo', () {
      expect(
          compararConOrientativo(1, 0.8, 1.5), ComparacionRendimiento.dentro);
      expect(compararConOrientativo(0.5, 0.8, 1.5),
          ComparacionRendimiento.porDebajo);
      expect(compararConOrientativo(2, 0.8, 1.5),
          ComparacionRendimiento.porEncima);
      expect(compararConOrientativo(1, null, 1.5),
          ComparacionRendimiento.sinReferencia);
      expect(compararConOrientativo(null, 1, 2),
          ComparacionRendimiento.sinReferencia);
    });

    test('resumen por especie ponderado por kg; fresca y seca aparte', () {
      final resumen = resumirDestilaciones([
        Destilacion(
            fechaMs: 0,
            especieId: 'lavandin',
            kgPlanta: 100,
            mlAceiteEsencial: 1000),
        Destilacion(
            fechaMs: 0,
            especieId: 'lavandin',
            kgPlanta: 300,
            mlAceiteEsencial: 1000),
        Destilacion(
            fechaMs: 0,
            especieId: 'lavandin',
            estadoPlanta: 'seca',
            kgPlanta: 10,
            mlAceiteEsencial: 300),
      ]);
      final fresca = resumen['lavandin|fresca']!;
      expect(fresca.numeroDestilaciones, 2);
      expect(fresca.rendimientoAceiteMedio, closeTo(0.5, 1e-9),
          reason: '2000 ml / 400 kg, no la media de 1 % y 0,33 %');
      expect(resumen['lavandin|seca']!.kgPlanta, 10);
    });
  });

  group('recolección frente al permiso', () {
    final zona = ZonaRecoleccion(
      id: 1,
      nombre: 'Comunal',
      numeroPermiso: 'P-1',
      inicioVigenciaMs: ms(2026, 5, 1),
      finVigenciaMs: ms(2026, 9, 30),
      especiesPermitidas: ['tomillo_comun'],
      limiteKg: 100,
    );
    final previas = [
      Cosecha(
          zonaRecoleccionId: 1,
          especieId: 'tomillo_comun',
          fechaMs: ms(2026, 6, 1),
          kgFrescos: 70),
      // Fuera de la vigencia: no cuenta para el límite.
      Cosecha(
          zonaRecoleccionId: 1,
          especieId: 'tomillo_comun',
          fechaMs: ms(2025, 6, 1),
          kgFrescos: 500),
      // De otra zona.
      Cosecha(
          zonaRecoleccionId: 2,
          especieId: 'tomillo_comun',
          fechaMs: ms(2026, 6, 1),
          kgFrescos: 500),
    ];

    test('kg dentro de la vigencia', () {
      expect(kgRecolectadosEnVigencia(zona, previas), 70);
    });

    test('todo en regla: sin avisos', () {
      expect(
          comprobarRecoleccion(
              zona: zona,
              especieId: 'tomillo_comun',
              fecha: DateTime(2026, 7, 1),
              kgNuevos: 30,
              previas: previas),
          isEmpty);
    });

    test('se pasa del límite, fuera de fecha y especie no incluida', () {
      expect(
          comprobarRecoleccion(
              zona: zona,
              especieId: 'romero',
              fecha: DateTime(2026, 10, 2),
              kgNuevos: 31,
              previas: previas),
          [
            AvisoRecoleccion.fueraDeVigencia,
            AvisoRecoleccion.especieNoIncluida,
            AvisoRecoleccion.superaLimite,
          ]);
    });

    test('sin permiso y especie con protección', () {
      expect(
          comprobarRecoleccion(
              zona: ZonaRecoleccion(nombre: 'Sin papeles'),
              especieId: 'x',
              fecha: DateTime(2026),
              kgNuevos: 1,
              previas: const [],
              especieConProteccion: true),
          [AvisoRecoleccion.especieConProteccion, AvisoRecoleccion.sinPermiso]);
    });

    test('permisos por vencer, del más urgente', () {
      final otra = ZonaRecoleccion(
          nombre: 'Otra', numeroPermiso: 'P-2', finVigenciaMs: ms(2026, 9, 25));
      final lejana = ZonaRecoleccion(
          nombre: 'Lejana',
          numeroPermiso: 'P-3',
          finVigenciaMs: ms(2027, 1, 1));
      expect(
          permisosPorVencer([zona, otra, lejana], DateTime(2026, 9, 20))
              .map((zona) => zona.nombre),
          ['Otra', 'Comunal']);
    });
  });

  test('trazabilidad: lote de aceite → destilación → zona y parcela', () {
    final lote = LoteProducto(
        id: 5,
        codigo: 'AE-2026-001',
        tipo: 'aceite_esencial',
        especieId: 'romero',
        fechaMs: ms(2026, 7, 2),
        cantidad: 500);
    final cosechas = [
      Cosecha(
          id: 1,
          zonaRecoleccionId: 10,
          especieId: 'romero',
          fechaMs: ms(2026, 6, 20),
          kgFrescos: 60),
      Cosecha(
          id: 2,
          parcelaId: 20,
          especieId: 'romero',
          fechaMs: ms(2026, 6, 1),
          kgFrescos: 40),
      Cosecha(id: 3, parcelaId: 21, especieId: 'romero', fechaMs: 0),
    ];
    final origen = origenDeLote(
      lote,
      secados: const [],
      destilaciones: [
        Destilacion(
            fechaMs: ms(2026, 7, 1),
            especieId: 'romero',
            cosechasUsadasIds: [1, 2],
            loteAceiteId: 5),
      ],
      cosechas: cosechas,
      parcelas: [
        Parcela(id: 20, nombre: 'Huerto', especieId: 'romero'),
        Parcela(id: 21, nombre: 'Otra', especieId: 'romero'),
      ],
      zonas: [ZonaRecoleccion(id: 10, nombre: 'Monte', numeroPermiso: 'P-9')],
    );
    expect(origen.tieneProceso, isTrue);
    expect(origen.cosechas.map((cosecha) => cosecha.id), [2, 1]);
    expect(origen.parcelas.single.nombre, 'Huerto');
    expect(origen.incluyeSilvestre, isTrue);
    expect(origen.kgFrescosCosechados, 100);
    expect(origen.intervaloCosecha, (ms(2026, 6, 1), ms(2026, 6, 20)));
    final qr = textoQrLote(
        lote: lote,
        nombreEspecie: 'Romero',
        nombreCientifico: 'Salvia rosmarinus',
        titular: 'Ane',
        origen: origen,
        formatearFecha: (fecha) => '$fecha');
    expect(qr, contains('AE-2026-001'));
    expect(qr, contains('permiso P-9'));
    expect(qr, contains('PROVISIONAL'));
  });

  test('un lote apuntado a mano no tiene origen', () {
    final origen = origenDeLote(
        LoteProducto(
            id: 1,
            codigo: 'x',
            tipo: 'planta_seca',
            especieId: 'x',
            fechaMs: 0),
        secados: [Secado(fechaInicioMs: 0, especieId: 'x', loteProductoId: 2)],
        destilaciones: const [],
        cosechas: const [],
        parcelas: const [],
        zonas: const []);
    expect((origen.tieneProceso, origen.intervaloCosecha), (false, null));
    expect(origen.cosechas, isEmpty);
  });
}
