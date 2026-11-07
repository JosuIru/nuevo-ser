import 'package:flutter_test/flutter_test.dart';
import 'package:solera_monte/dominio/aprovechamientos.dart';
import 'package:solera_monte/dominio/incendios.dart';
import 'package:solera_monte/dominio/plan_gestion.dart';
import 'package:solera_monte/dominio/superficies.dart';
import 'package:solera_monte/modelos/actuacion_plan.dart';
import 'package:solera_monte/modelos/aprovechamiento.dart';
import 'package:solera_monte/modelos/ejecucion.dart';
import 'package:solera_monte/modelos/incendios.dart';
import 'package:solera_monte/modelos/monte.dart';
import 'package:solera_monte/modelos/rodal.dart';

int ms(int anyo, int mes, int dia) =>
    DateTime(anyo, mes, dia).millisecondsSinceEpoch;

void main() {
  group('superficies', () {
    final rodales = [
      Rodal(codigo: '1', especiePrincipalId: 'pino', superficieDeclaradaHa: 4),
      Rodal(codigo: '2', especiePrincipalId: 'haya', superficieDeclaradaHa: 6),
      Rodal(codigo: '3', especiePrincipalId: 'pino', superficieDeclaradaHa: 3),
      Rodal(codigo: '4', especiePrincipalId: 'roble'),
    ];

    test('por especie, de mayor a menor, sin los que no tienen superficie', () {
      expect(superficiePorEspecie(rodales), [('pino', 7.0), ('haya', 6.0)]);
      expect(superficieTotal(rodales), 13);
      expect(rodalesSinSuperficie(rodales).single.codigo, '4');
    });

    test('diferencia entre dibujada y declarada', () {
      expect(diferenciaDibujadaDeclarada(rodales.first), isNull);
      final dibujado = Rodal(
          codigo: '5',
          especiePrincipalId: 'pino',
          superficieDeclaradaHa: 0.5,
          contorno: const [
            (42.8, -1.6),
            (42.8009, -1.6),
            (42.8009, -1.59877),
            (42.8, -1.59877)
          ]);
      expect(diferenciaDibujadaDeclarada(dibujado), closeTo(1.0, 0.1));
    });
  });

  group('plan de gestión', () {
    final actuaciones = [
      ActuacionPlan(
          id: 1, anyoPrevisto: 2025, tipo: 'desbroce', superficiePrevistaHa: 3),
      ActuacionPlan(
          id: 2,
          anyoPrevisto: 2025,
          tipo: 'clara',
          volumenPrevistoM3: 50,
          superficiePrevistaHa: 5),
      ActuacionPlan(id: 3, anyoPrevisto: 2026, tipo: 'poda'),
      ActuacionPlan(
          id: 4, anyoPrevisto: 2026, tipo: 'clara', volumenPrevistoM3: 40),
      ActuacionPlan(
          id: 5,
          anyoPrevisto: 2026,
          tipo: 'repoblacion',
          cancelada: true,
          volumenPrevistoM3: 999),
    ];
    final ejecuciones = [
      Ejecucion(
          actuacionPlanId: 1,
          fechaMs: ms(2025, 3, 1),
          tipo: 'desbroce',
          superficieHa: 2.5),
      Ejecucion(
          actuacionPlanId: 3,
          fechaMs: ms(2026, 2, 1),
          tipo: 'poda',
          completa: false),
      Ejecucion(fechaMs: ms(2026, 4, 1), tipo: 'otra'),
    ];

    test('estado de cada actuación', () {
      EstadoActuacion estado(int id) => estadoActuacion(
          actuaciones.firstWhere((a) => a.id == id), ejecuciones, 2026);
      expect(estado(1), EstadoActuacion.ejecutada);
      expect(estado(2), EstadoActuacion.atrasada);
      expect(estado(3), EstadoActuacion.enCurso);
      expect(estado(4), EstadoActuacion.pendiente);
      expect(estado(5), EstadoActuacion.cancelada);
    });

    test('resumen por año: previsto frente a ejecutado', () {
      final resumen = resumenPlanPorAnyo(actuaciones, ejecuciones, 2026);
      expect(resumen.map((r) => r.anyo), [2025, 2026]);
      final de2025 = resumen.first;
      expect(
          (de2025.previstas, de2025.ejecutadas, de2025.atrasadas), (2, 1, 1));
      expect((de2025.superficiePrevistaHa, de2025.superficieEjecutadaHa),
          (8.0, 2.5));
      expect(de2025.grado, 0.5);
      final de2026 = resumen.last;
      expect((de2026.previstas, de2026.enCurso, de2026.canceladas), (2, 1, 1));
      expect(ejecucionesNoPrevistas(ejecuciones), hasLength(1));
    });

    test('volumen previsto frente a aprovechado, con estéreos a m³', () {
      final aprovechamientos = [
        Aprovechamiento(
            campanya: 2026,
            tipo: 'madera',
            fechaInicioMs: 1,
            cantidad: 30,
            unidad: 'm3'),
        Aprovechamiento(
            campanya: 2026,
            tipo: 'lena',
            fechaInicioMs: 1,
            cantidad: 20,
            unidad: 'estereos'),
        Aprovechamiento(
            campanya: 2026,
            tipo: 'biomasa',
            fechaInicioMs: 1,
            cantidad: 5,
            unidad: 'toneladas'),
        Aprovechamiento(
            campanya: 2026,
            tipo: 'pastos',
            fechaInicioMs: 1,
            cantidad: 100,
            unidad: 'hectareas'),
        Aprovechamiento(
            campanya: 2025,
            tipo: 'madera',
            fechaInicioMs: 1,
            cantidad: 99,
            unidad: 'm3'),
      ];
      final comparacion = compararVolumen(2026,
          actuaciones: actuaciones,
          aprovechamientos: aprovechamientos,
          m3PorEstereo: 0.5);
      expect(comparacion.previstoPlanM3, 40, reason: 'sin la cancelada');
      expect(comparacion.aprovechadoM3, 40);
      expect(comparacion.aprovechamientosSinVolumen, 1);
      expect((comparacion.diferenciaM3, comparacion.proporcion), (0.0, 1.0));
      expect(
          volumenM3(aprovechamientos[1], m3PorEstereo: 0.5, usarPrevisto: true),
          isNull);
    });
  });

  group('aprovechamientos', () {
    Aprovechamiento lena({
      double cantidad = 0,
      double? prevista,
      String unidad = 'estereos',
      String tramite = 'pendiente',
      bool comercializado = false,
      int? finMs,
      int? comunicadoMs,
    }) =>
        Aprovechamiento(
            campanya: 2026,
            tipo: 'lena',
            fechaInicioMs: ms(2026, 1, 10),
            fechaFinMs: finMs,
            cantidad: cantidad,
            cantidadPrevista: prevista,
            unidad: unidad,
            tramite: tramite,
            comercializado: comercializado,
            fechaComunicacionCuantiaMs: comunicadoMs);

    test('menor cuantía del art. 37.2: 20 estéreos o 10 m³ ya la superan', () {
      expect(superaMenorCuantia(lena(cantidad: 19.9)), isFalse);
      expect(superaMenorCuantia(lena(cantidad: 20)), isTrue);
      expect(superaMenorCuantia(lena(prevista: 25)), isTrue);
      expect(superaMenorCuantia(lena(cantidad: 9.9, unidad: 'm3')), isFalse);
      expect(superaMenorCuantia(lena(cantidad: 10, unidad: 'm3')), isTrue);
      expect(superaMenorCuantia(lena(cantidad: 500, unidad: 'toneladas')),
          isFalse);
      expect(
          superaMenorCuantia(Aprovechamiento(
              campanya: 1,
              tipo: 'hongos',
              fechaInicioMs: 1,
              cantidad: 500,
              unidad: 'm3')),
          isFalse);
    });

    test('plazo del art. 37.4: un mes desde el fin si se vende', () {
      expect(limiteComunicacionCuantia(lena(comercializado: true)), isNull);
      expect(
          limiteComunicacionCuantia(
              lena(comercializado: true, finMs: ms(2026, 3, 15))),
          DateTime(2026, 4, 15));
      expect(
          limiteComunicacionCuantia(
              lena(comercializado: true, finMs: ms(2026, 1, 31))),
          DateTime(2026, 2, 28));
      expect(
          limiteComunicacionCuantia(
              lena(comercializado: true, finMs: ms(2026, 12, 20))),
          DateTime(2027, 1, 20));
      expect(
          limiteComunicacionCuantia(lena(
              comercializado: true,
              finMs: ms(2026, 3, 15),
              comunicadoMs: ms(2026, 3, 20))),
          isNull);
      expect(limiteComunicacionCuantia(lena(finMs: ms(2026, 3, 15))), isNull);
    });

    test('avisos', () {
      expect(avisosAprovechamiento(lena(cantidad: 25), DateTime(2026, 2, 1)), [
        AvisoAprovechamiento.tramitePendiente,
        AvisoAprovechamiento.superaMenorCuantia
      ]);
      final vendida = lena(
          tramite: 'declaracion_responsable',
          comercializado: true,
          finMs: ms(2026, 3, 15));
      expect(avisosAprovechamiento(vendida, DateTime(2026, 4, 15, 20)),
          [AvisoAprovechamiento.comunicarCuantia]);
      expect(avisosAprovechamiento(vendida, DateTime(2026, 4, 16)),
          [AvisoAprovechamiento.comunicacionVencida]);
      expect(
          avisosAprovechamiento(
              Aprovechamiento(campanya: 1, tipo: 'pastos', fechaInicioMs: 1),
              DateTime(2026)),
          isEmpty,
          reason: 'los no maderables los regula la CA: sin avisos estatales');
    });

    test('totales por tipo y unidad, sin mezclar unidades', () {
      final totales = totalesPorTipoYUnidad([
        lena(cantidad: 10),
        lena(cantidad: 5),
        lena(cantidad: 2, unidad: 'm3'),
      ]);
      expect(totales[('lena', 'estereos')], 15);
      expect(totales[('lena', 'm3')], 2);
    });
  });

  group('incendios', () {
    final monte = Monte(inicioEpocaPeligroMes: 6, inicioEpocaPeligroDia: 1);
    final pista = InfraestructuraIncendios(id: 1, tipo: 'pista', nombre: 'P');
    final balsa =
        InfraestructuraIncendios(id: 2, tipo: 'punto_agua', nombre: 'B');
    final cortafuegos = InfraestructuraIncendios(
        id: 3, tipo: 'cortafuegos', nombre: 'C', activa: false);
    final revisiones = [
      RevisionIncendios(infraestructuraId: 1, fechaMs: ms(2025, 5, 1)),
      RevisionIncendios(
          infraestructuraId: 2,
          fechaMs: ms(2026, 4, 1),
          estado: 'necesita_mantenimiento'),
    ];

    test('estado de la campaña: solo cuentan las revisiones del año', () {
      expect(estadoCampanya(pista, revisiones, 2026),
          EstadoCampanyaIncendios.sinRevisar);
      expect(estadoCampanya(pista, revisiones, 2025),
          EstadoCampanyaIncendios.correcta);
      expect(estadoCampanya(balsa, revisiones, 2026),
          EstadoCampanyaIncendios.conTrabajoPendiente);
      final arreglada = [
        ...revisiones,
        RevisionIncendios(infraestructuraId: 2, fechaMs: ms(2026, 5, 2)),
      ];
      expect(estadoCampanya(balsa, arreglada, 2026),
          EstadoCampanyaIncendios.correcta,
          reason: 'cuenta la revisión más reciente');
    });

    test('aviso de la época de peligro', () {
      final infraestructuras = [pista, balsa, cortafuegos];
      expect(
          avisoEpocaPeligro(
              monte: Monte(),
              infraestructuras: infraestructuras,
              revisiones: revisiones,
              hoy: DateTime(2026, 5, 20)),
          isNull,
          reason: 'sin fecha apuntada, la app no se la inventa');
      expect(
          avisoEpocaPeligro(
              monte: monte,
              infraestructuras: infraestructuras,
              revisiones: revisiones,
              hoy: DateTime(2026, 3, 1)),
          isNull,
          reason: 'aún es pronto');
      final aviso = avisoEpocaPeligro(
          monte: monte,
          infraestructuras: infraestructuras,
          revisiones: revisiones,
          hoy: DateTime(2026, 5, 20, 18))!;
      expect(aviso.diasHastaInicio, 12);
      expect(aviso.sinRevisar.map((i) => i.nombre), ['P'],
          reason: 'el cortafuegos inactivo no cuenta');
      expect(aviso.conTrabajoPendiente.map((i) => i.nombre), ['B']);
      expect(aviso.hayPendientes, isTrue);
    });

    test('longitud de una traza abierta', () {
      // 0,009° de latitud ≈ 1000 m.
      expect(longitudTrazaMetros(const [(42.0, -1.0), (42.009, -1.0)]),
          closeTo(1000, 5));
      expect(longitudTrazaMetros(const [(42.0, -1.0)]), 0);
      expect(
          longitudInfraestructuraMetros(InfraestructuraIncendios(
              tipo: 'pista', nombre: 'x', longitudM: 350)),
          350);
    });
  });
}
