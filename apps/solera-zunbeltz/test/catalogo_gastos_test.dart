// Gastos en los seis bloques de la hoja de seguimiento de Zunbeltz más una
// partida (material del 2026-10-13), y traducción de las categorías de
// antes de los bloques.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/constantes.dart';
import 'package:solera_zunbeltz/modelos/convenio.dart';
import 'package:solera_zunbeltz/modelos/desglose_gastos.dart';

void main() {
  test('los seis bloques, en el orden de la hoja', () {
    expect(categoriasGasto.map((opcion) => opcion.codigo), [
      'directos',
      'maquinaria',
      'transformacion',
      'mano_obra',
      'indirectos',
      'amortizacion',
    ]);
    for (final bloque in categoriasGasto) {
      expect(partidasDe(bloque.codigo), isNotEmpty,
          reason: 'cada bloque sugiere partidas');
    }
  });

  test('categorías antiguas → bloque y partida', () {
    expect(normalizarCategoriaGasto('ganado', '', false), ('directos', 'animales'));
    expect(normalizarCategoriaGasto('alimentacion', '', false),
        ('directos', 'compra_alimento'));
    expect(normalizarCategoriaGasto('infraestructuras', '', false),
        ('maquinaria', 'reparaciones_cercados'));
    // Una amortización va al bloque VI y pierde la partida que no es suya.
    expect(normalizarCategoriaGasto('infraestructuras', '', true),
        ('amortizacion', ''));
    // Lo que ya está en bloques no cambia.
    expect(normalizarCategoriaGasto('transformacion', 'sacrificio', false),
        ('transformacion', 'sacrificio'));
    // Una categoría desconocida no se pierde: va a costes directos.
    expect(normalizarCategoriaGasto('', '', false), ('directos', ''));
  });

  test('quién asume va por partida: animales, alimento y sanidad, la tester',
      () {
    expect(asumidoPorDefecto('animales'), asumidoPorTester);
    expect(asumidoPorDefecto('forraje'), asumidoPorTester);
    expect(asumidoPorDefecto('vacunas_veterinario'), asumidoPorTester);
    expect(asumidoPorDefecto('sacrificio'), asumidoPorZunbeltz);
    expect(asumidoPorDefecto(''), asumidoPorZunbeltz);
  });

  test('la partida escrita se guarda como código si es del catálogo', () {
    expect(codigoPartida('directos', 'Forraje'), 'forraje');
    expect(codigoPartida('directos', ' bazka '), 'forraje');
    expect(codigoPartida('directos', 'Paja de la cooperativa'),
        'Paja de la cooperativa');
    expect(etiquetaPartida('directos', 'forraje', 'eu'), 'Bazka');
    expect(etiquetaPartida('directos', 'Paja', 'es'), 'Paja');
  });

  test('un apunte del servidor con categoría antigua se lee traducido', () {
    final apunte = ApunteEconomico.fromMap({
      'finca_id': 1,
      'tipo': 'gasto',
      'categoria': 'sanidad',
      'importe_centimos': 100,
      'es_amortizacion': 0,
    });
    expect(apunte.categoria, 'directos');
    expect(apunte.partida, 'vacunas_veterinario');
    expect(apunte.esAmortizacion, isFalse);

    final cuota = ApunteEconomico.fromMap({
      'finca_id': 1,
      'tipo': 'gasto',
      'categoria': 'insumos',
      'es_amortizacion': 1,
    });
    expect(cuota.categoria, 'amortizacion');
    expect(cuota.esAmortizacion, isTrue);
    expect(cuota.toMap()['es_amortizacion'], 1,
        reason: 'el servidor sigue recibiendo la marca');

    final ingreso = ApunteEconomico.fromMap(
        {'finca_id': 1, 'tipo': 'ingreso', 'categoria': 'otros'});
    expect(ingreso.categoria, 'otros');

    final partida = PartidaPresupuesto.fromMap(
        {'proyecto_id': 1, 'categoria': 'alquiler', 'es_amortizacion': 0});
    expect((partida.categoria, partida.partida),
        ('directos', 'canon_arrendamiento'));
  });

  test('desglose: subtotales por bloque y partidas sin nombre al final', () {
    ApunteEconomico gasto(String bloque, String partida, int euros) =>
        ApunteEconomico(
            fincaId: 1,
            tipo: 'gasto',
            categoria: bloque,
            partida: partida,
            importeCentimos: euros * 100);
    final desglose = DesgloseGastos.calcular([
      gasto('amortizacion', 'instalaciones', 1147),
      gasto('directos', '', 10),
      gasto('directos', 'animales', 300),
      gasto('directos', 'Cama de paja', 30),
      gasto('directos', 'compra_alimento', 1417),
      ApunteEconomico(fincaId: 1, tipo: 'ingreso', importeCentimos: 99900),
    ]);
    expect(desglose.bloques, ['directos', 'amortizacion']);
    expect(desglose.totalDe('directos'), 175700);
    expect(desglose.partidasDe('directos').map((p) => p.key),
        ['animales', 'compra_alimento', 'Cama de paja', '']);
    expect(desglose.totalCentimos, 290400);
  });
}
