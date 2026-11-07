import 'package:flutter_test/flutter_test.dart';
import 'package:solera_obrador/modelos/alergenos.dart';
import 'package:solera_obrador/modelos/hornada.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/masa_madre.dart';
import 'package:solera_obrador/modelos/pedido_fijo.dart';
import 'package:solera_obrador/modelos/registro_autocontrol.dart';

void main() {
  test('hay 14 alérgenos y se codifican en el orden del anexo II', () {
    expect(alergenosObligatorios, hasLength(14));
    expect(codificarAlergenos({'sesamo', 'gluten'}), 'gluten|sesamo');
    expect(
        decodificarAlergenos('sesamo|inventado||gluten'), {'gluten', 'sesamo'});
    expect(decodificarAlergenos(null), isEmpty);
  });

  test('ingrediente: ida y vuelta por el mapa', () {
    final ingrediente = Ingrediente(
        id: 3,
        nombre: 'Sésamo',
        alergenos: {'sesamo'},
        trazas: {'frutos_cascara'},
        precioCentimosPorKg: 900,
        salGramosPor100g: 0.1);
    final vuelta = Ingrediente.fromMap(ingrediente.toMap());
    expect(vuelta.alergenos, {'sesamo'});
    expect(vuelta.trazas, {'frutos_cascara'});
    expect(vuelta.precioCentimosPorKg, 900);
    expect(vuelta.salGramosPor100g, 0.1);
  });

  test('refresco de masa madre: hidratación y proporción', () {
    final refresco = RefrescoMasaMadre(
        masaMadreId: 1,
        fechaMs: 0,
        gramosMasaMadre: 50,
        gramosHarina: 100,
        gramosAgua: 75);
    expect(refresco.hidratacionPorcentaje, 75);
    expect(refresco.proporcion, '1:2:1.5');
    expect(
        RefrescoMasaMadre(
                masaMadreId: 1,
                fechaMs: 0,
                gramosMasaMadre: 0,
                gramosHarina: 1,
                gramosAgua: 1)
            .proporcion,
        '—');
  });

  test('pedidos fijos: días de la semana y piezas del día', () {
    final pedidos = [
      PedidoFijo(
          cliente: 'Bar', recetaId: 1, piezas: 10, diasSemana: {1, 3, 5}),
      PedidoFijo(cliente: 'Tienda', recetaId: 1, piezas: 5, diasSemana: {1}),
      PedidoFijo(
          cliente: 'Comedor',
          recetaId: 2,
          piezas: 30,
          diasSemana: {1},
          activo: false),
    ];
    final lunes = DateTime(2026, 11, 9);
    expect(piezasPedidasPara(lunes, pedidos), {1: 15});
    expect(piezasPedidasPara(lunes.add(const Duration(days: 1)), pedidos),
        isEmpty);
    final vuelta =
        PedidoFijo.fromMap(pedidos.first.toMap()..['dias_semana'] = '5,1,9,x');
    expect(vuelta.diasSemana, {1, 5});
  });

  test('autocontrol: incorrecto sin acción correctora se señala', () {
    final registro = RegistroAutocontrol(
        tipo: 'temperatura',
        fechaMs: 0,
        elemento: 'Cámara 1',
        valor: 9,
        correcto: false);
    expect(registro.faltaAccionCorrectora, isTrue);
    expect(RegistroAutocontrol.fromMap(registro.toMap()).valor, 9);
  });

  test('código de lote de hornada', () {
    expect(codigoLoteHornada(DateTime(2026, 3, 7), 12, 2), '20260307-12-2');
  });
}
