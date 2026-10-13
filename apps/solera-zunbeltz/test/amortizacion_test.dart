// Inventario de amortizaciones: cuotas como la hoja «Listado-amortización»
// de Zunbeltz (2026-10-13), imputadas a cada proyecto con los meses del
// test.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/amortizacion.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/balance_convenio.dart';
import 'package:solera_zunbeltz/modelos/desglose_gastos.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';

import 'bd_en_memoria.dart';

void main() {
  // Test avícola de la hoja: del 1 de junio al 1 de octubre de 2026.
  final proyecto = ProyectoTest(
    id: 1,
    nombre: 'Pollos',
    fechaInicioMs: DateTime(2026, 6, 1).millisecondsSinceEpoch,
    fechaFinMs: DateTime(2026, 10, 1).millisecondsSinceEpoch,
  );
  // Fila de la hoja: bebedero colgante, 20,94 € × 10, IVA 21 %, 72 meses.
  final bebedero = BienAmortizable(
      id: 7,
      nombre: 'Bebedero colgante',
      precioUnidadCentimos: 2094,
      unidades: 10,
      vidaUtilMeses: 72);

  test('total con IVA y cuota mensual, como la hoja', () {
    expect(bebedero.totalCentimos, 25337); // 253,374 €
    expect(bebedero.cuotaMensualCentimos, closeTo(351.9, 0.01)); // 3,519 €
    expect(BienAmortizable(precioUnidadCentimos: 100, vidaUtilMeses: 0)
        .cuotaMensualCentimos, 0, reason: 'sin vida útil no se amortiza');
  });

  test('meses del test: de calendario más la fracción de días', () {
    expect(mesesEntre(DateTime(2026, 6, 1), DateTime(2026, 10, 1)), 4);
    expect(mesesEntre(DateTime(2026, 6, 1), DateTime(2026, 6, 16)), 0.5);
    expect(mesesEntre(DateTime(2026, 1, 31), DateTime(2026, 3, 1)), 1.03);
    expect(mesesEntre(DateTime(2026, 6, 1), DateTime(2026, 5, 1)), 0);
    expect(mesesDelProyecto(proyecto), 4);
    expect(mesesDelProyecto(ProyectoTest(nombre: 'Sin fechas')), 0);
    // Sin fin, hasta hoy.
    expect(
        mesesDelProyecto(
            ProyectoTest(
                nombre: 'En curso',
                fechaInicioMs: DateTime(2026, 6, 1).millisecondsSinceEpoch),
            ahora: DateTime(2026, 8, 1)),
        2);
  });

  test('cuota imputada: mensual × meses del test × porcentaje', () {
    final uso = UsoBien(proyectoId: 1, bienId: 7);
    // 3,519 € × 4 meses = 14,08 € (la hoja multiplicaba por 3 por error).
    expect(cuotaImputadaCentimos(bebedero, uso, proyecto), 1408);
    // Con meses propios y la mitad del bien.
    final mitad = UsoBien(
        proyectoId: 1, bienId: 7, imputacionPorcentaje: 50, duracionMeses: 3);
    expect(cuotaImputadaCentimos(bebedero, mitad, proyecto), 528);
  });

  test('en un periodo, la parte proporcional de los días del test', () {
    const cuota = 1200;
    expect(cuotaEnPeriodoCentimos(cuota, proyecto), cuota);
    final mitadDelTest =
        DateTime(2026, 6, 1).add(const Duration(days: 61)).millisecondsSinceEpoch;
    expect(
        cuotaEnPeriodoCentimos(cuota, proyecto,
            desdeMs: DateTime(2026, 1, 1).millisecondsSinceEpoch,
            hastaMs: mitadDelTest),
        closeTo(600, 6));
    // Un periodo fuera del test no carga nada.
    expect(
        cuotaEnPeriodoCentimos(cuota, proyecto,
            desdeMs: DateTime(2026, 11, 1).millisecondsSinceEpoch,
            hastaMs: DateTime(2026, 12, 1).millisecondsSinceEpoch),
        0);
  });

  test('las cuotas entran como gasto del bloque VI que asume Zunbeltz', () {
    final apuntes = apuntesDeAmortizacion(
      proyecto: proyecto,
      usos: [
        UsoBien(proyectoId: 1, bienId: 7),
        UsoBien(proyectoId: 1, bienId: 99), // bien borrado: no cuenta
      ],
      bienesPorId: {7: bebedero},
      fincaId: 1,
    );
    expect(apuntes, hasLength(1));
    final cuota = apuntes.single;
    expect(cuota.esAmortizacion, isTrue);
    expect(cuota.partida, 'material_ganadero');
    expect(cuota.asumidoPor, 'zunbeltz');

    final balance = BalanceConvenio.calcular(
        proyecto: proyecto, apuntes: apuntes, ventas: const []);
    expect(balance.amortizacionesCentimos, 1408);
    expect(balance.balanceTestCentimos, 0,
        reason: 'el balance del test no lleva amortizaciones');
    expect(balance.balanceProyectoCentimos, -1408);

    final desglose = DesgloseGastos.calcular(apuntes);
    expect(desglose.partidasDe('amortizacion').single.key, 'material_ganadero');
  });

  group('en la BD', () {
    late BaseDatosSoleraZunbeltz bd;
    late int proyectoId;

    setUp(() async {
      bd = await abrirBdEnMemoria();
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
      proyectoId = await bd.guardarProyecto(ProyectoTest(
        nombre: 'Pollos',
        fincaId: fincaId,
        fechaInicioMs: proyecto.fechaInicioMs,
        fechaFinMs: proyecto.fechaFinMs,
      ));
    });

    test('la cuota entra en la rentabilidad y en el desglose del proyecto',
        () async {
      final bienId = await bd.guardarBien(BienAmortizable(
          nombre: 'Bebedero colgante',
          precioUnidadCentimos: 2094,
          unidades: 10,
          vidaUtilMeses: 72));
      await bd.guardarUsoBien(UsoBien(proyectoId: proyectoId, bienId: bienId));

      expect((await bd.listarBienes()).single.unidades, 10);
      final rentabilidad = await bd.rentabilidadProyecto(proyectoId);
      expect(rentabilidad.gastosCentimos, 1408);
      final desglose = await bd.desgloseGastos(proyectoId: proyectoId);
      expect(desglose.totalDe('amortizacion'), 1408);

      // Editar el bien recalcula sin tocar el uso.
      final bien = (await bd.listarBienes()).single;
      await bd.actualizarBien(BienAmortizable(
          id: bien.id,
          nombre: bien.nombre,
          precioUnidadCentimos: 4188,
          unidades: 10,
          vidaUtilMeses: 72));
      expect((await bd.rentabilidadProyecto(proyectoId)).gastosCentimos,
          2815); // 506,75 € ÷ 72 × 4
    });

    test('bienes y usos viajan con la sincronización; borrar el bien borra su uso',
        () async {
      final bienId = await bd.guardarBien(BienAmortizable(nombre: 'Manga'));
      await bd.guardarUsoBien(UsoBien(proyectoId: proyectoId, bienId: bienId));
      final entidades = await bd.entidadesPendientesDeSubir(0);
      final uso = entidades.firstWhere((e) => e['tipo'] == 'uso_bien');
      expect((uso['datos'] as Map)['bien_uid'],
          await bd.uidDeFila('bienes_amortizables', bienId));
      expect(uso['proyecto_uid'], await bd.uidDeFila('proyectos_test', proyectoId));
      expect(entidades.map((e) => e['tipo']), contains('bien_amortizable'));

      await bd.borrarBien(bienId);
      expect(await bd.listarUsosBienes(proyectoId), isEmpty);
    });
  });
}
