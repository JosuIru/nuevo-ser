import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/constantes.dart';
import 'package:solera_zunbeltz/modelos/convenio.dart';
import 'package:solera_zunbeltz/utiles/comparativa_partidas.dart';

void main() {
  final directos = categoriasGasto.first.codigo;
  final catalogo = partidasDe(directos);

  test('todos los bloques del catálogo, en orden, aunque estén vacíos', () {
    final bloques = compararPartidas(presupuesto: const [], apuntes: const []);
    expect(bloques.map((bloque) => bloque.bloque),
        categoriasGasto.map((opcion) => opcion.codigo));
    expect(bloques.every((bloque) => bloque.vacio), isTrue);
  });

  test('previsto y real por partida; los ingresos no cuentan', () {
    final primera = catalogo.first.codigo;
    final segunda = catalogo[1].codigo;
    final bloques = compararPartidas(
      presupuesto: [
        PartidaPresupuesto(
            proyectoId: 1,
            categoria: directos,
            partida: segunda,
            importeCentimos: 60000),
        PartidaPresupuesto(
            proyectoId: 1,
            categoria: directos,
            partida: primera,
            importeCentimos: 240000),
      ],
      apuntes: [
        ApunteEconomico(
            fincaId: 1,
            tipo: 'gasto',
            categoria: directos,
            partida: primera,
            importeCentimos: 100000),
        ApunteEconomico(
            fincaId: 1,
            tipo: 'gasto',
            categoria: directos,
            partida: primera,
            importeCentimos: 89000),
        ApunteEconomico(
            fincaId: 1,
            tipo: 'gasto',
            categoria: directos,
            partida: '',
            importeCentimos: 5000),
        ApunteEconomico(
            fincaId: 1,
            tipo: 'gasto',
            categoria: directos,
            partida: 'Leña propia',
            importeCentimos: 700),
        ApunteEconomico(
            fincaId: 1,
            tipo: 'ingreso',
            categoria: directos,
            partida: primera,
            importeCentimos: 999999),
      ],
    );
    final bloque = bloques.first;
    expect(bloque.partidas.map((fila) => fila.partida),
        [primera, segunda, 'Leña propia', ''],
        reason: 'catálogo, propias y al final sin partida');
    expect(bloque.partidas.first.previsto, 240000);
    expect(bloque.partidas.first.real, 189000);
    expect(bloque.previsto, 300000);
    expect(bloque.real, 194700);
  });

  test('un bloque que no conoce esta versión va al final', () {
    final bloques = compararPartidas(presupuesto: const [], apuntes: [
      ApunteEconomico(
          fincaId: 1, tipo: 'gasto', categoria: 'futuro', importeCentimos: 100),
    ]);
    expect(bloques.last.bloque, 'futuro');
    expect(bloques.last.real, 100);
  });
}
