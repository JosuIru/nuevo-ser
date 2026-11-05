import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/balance_convenio.dart';
import 'package:solera_zunbeltz/modelos/constantes.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';
import 'package:solera_zunbeltz/utiles/resumen_proyecto.dart';

int ms(int anio, int mes, int dia) =>
    DateTime(anio, mes, dia).millisecondsSinceEpoch;

void main() {
  group('mesDelTest', () {
    final proyecto = ProyectoTest(
        nombre: 'Ovino',
        fechaInicioMs: ms(2026, 3, 1),
        fechaFinMs: ms(2028, 3, 1));

    test('sin fecha de inicio no hay mes', () {
      expect(mesDelTest(ProyectoTest(nombre: 'x')), isNull);
    });

    test('el día de inicio es el mes 1', () {
      expect(mesDelTest(proyecto, ahora: DateTime(2026, 3, 1)),
          (mesActual: 1, mesesTotales: 24));
    });

    test('a mitad de noviembre va por el mes 9 de 24', () {
      expect(mesDelTest(proyecto, ahora: DateTime(2026, 11, 15)),
          (mesActual: 9, mesesTotales: 24));
    });

    test('antes de empezar, mes 0; pasado el fin, el último', () {
      expect(mesDelTest(proyecto, ahora: DateTime(2026, 1, 1))?.mesActual, 0);
      expect(mesDelTest(proyecto, ahora: DateTime(2029, 1, 1))?.mesActual, 24);
    });

    test('sin fin no hay total; un pico de días suma una casilla', () {
      final sinFin = ProyectoTest(nombre: 'x', fechaInicioMs: ms(2026, 9, 1));
      expect(mesDelTest(sinFin, ahora: DateTime(2026, 11, 5)),
          (mesActual: 3, mesesTotales: null));
      final conPico = ProyectoTest(
          nombre: 'x',
          fechaInicioMs: ms(2026, 9, 1),
          fechaFinMs: ms(2028, 3, 15));
      expect(
          mesDelTest(conPico, ahora: DateTime(2026, 9, 2))?.mesesTotales, 19);
    });
  });

  group('repartoDeGastos', () {
    BalanceConvenio balance(List<ApunteEconomico> apuntes) =>
        BalanceConvenio.calcular(
            proyecto: ProyectoTest(nombre: 'x'),
            apuntes: apuntes,
            ventas: const []);

    test('sin gastos no hay reparto', () {
      expect(repartoDeGastos(balance(const [])), isNull);
    });

    test('porcentajes que suman 100', () {
      final reparto = repartoDeGastos(balance([
        ApunteEconomico(
            fincaId: 1,
            tipo: 'gasto',
            fechaMs: 1,
            importeCentimos: 6200,
            asumidoPor: 'tester'),
        ApunteEconomico(
            fincaId: 1,
            tipo: 'gasto',
            fechaMs: 1,
            importeCentimos: 3800,
            asumidoPor: asumidoPorZunbeltz),
        ApunteEconomico(
            fincaId: 1, tipo: 'ingreso', fechaMs: 1, importeCentimos: 99999),
      ]));
      expect(reparto, (tester: 62, zunbeltz: 38));
    });
  });
}
