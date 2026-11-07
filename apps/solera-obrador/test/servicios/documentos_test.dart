import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solera_obrador/dominio/composicion_receta.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:solera_obrador/modelos/registro_autocontrol.dart';
import 'package:solera_obrador/modelos/titular.dart';
import 'package:solera_obrador/servicios/generador_cuaderno_autocontrol_pdf.dart';
import 'package:solera_obrador/servicios/generador_ficha_tecnica_pdf.dart';

void main() {
  setUpAll(initializeDateFormatting);
  final ingredientes = {
    1: Ingrediente(id: 1, nombre: 'Harina', alergenos: {'gluten'}),
    2: Ingrediente(id: 2, nombre: 'Agua'),
    3: Ingrediente(id: 3, nombre: 'Sésamo', alergenos: {'sesamo'}),
  };
  final pan = Receta(id: 1, nombre: 'Pan de sésamo', piezasPorMasa: 2);
  final composicion = ComposicionReceta.calcular(
    recetaId: 1,
    recetas: {1: pan},
    lineasPorReceta: {
      1: [
        LineaReceta(recetaId: 1, ingredienteId: 2, gramos: 600),
        LineaReceta(recetaId: 1, ingredienteId: 1, gramos: 1000),
        LineaReceta(recetaId: 1, ingredienteId: 3, gramos: 30),
      ],
    },
    ingredientes: ingredientes,
  );
  final registros = [
    RegistroAutocontrol(
        tipo: 'temperatura', fechaMs: 0, elemento: 'Cámara', valor: 3),
    RegistroAutocontrol(
        tipo: 'temperatura',
        fechaMs: 1,
        elemento: 'Cámara',
        valor: 9,
        correcto: false),
    RegistroAutocontrol(tipo: 'limpieza', fechaMs: 2, elemento: 'Horno'),
  ];

  bool esPdf(List<int> bytes) => ascii.decode(bytes.take(4).toList()) == '%PDF';

  test('etiqueta: por peso y con los alérgenos en mayúsculas', () {
    expect(listaIngredientesEtiqueta(composicion, ingredientes),
        'HARINA, Agua, SÉSAMO');
  });

  test('cuaderno: una tabla por tipo con apuntes y la de incidencias', () {
    final tablas = tablasCuadernoAutocontrol(registros);
    expect(tablas, hasLength(3));
    expect(tablas[0].filas, hasLength(2));
    expect(tablas.last.filas.single.last, contains('Falta'));
  });

  test('cartel: contiene y puede contener por producto', () {
    final filas = filasCartelAlergenos({pan: composicion});
    expect(filas.single.first, 'Pan de sésamo');
    expect(filas.single[1], contains('Gluten'));
  });

  test('los tres documentos se generan como PDF', () async {
    final titular =
        Titular(nombre: 'Obrador de prueba', registroSanitario: '20.0000/NA');
    expect(
        esPdf(await generarCuadernoAutocontrolPdf(
            mes: DateTime(2026, 11), titular: titular, registros: registros)),
        isTrue);
    expect(
        esPdf(await generarFichaTecnicaPdf(
            receta: pan,
            composicion: composicion,
            ingredientes: ingredientes,
            titular: titular)),
        isTrue);
    expect(
        esPdf(await generarCartelAlergenosPdf(
            productos: {pan: composicion}, titular: titular)),
        isTrue);
  });
}
