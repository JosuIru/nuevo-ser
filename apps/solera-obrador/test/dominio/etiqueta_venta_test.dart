import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_obrador/dominio/composicion_receta.dart';
import 'package:solera_obrador/dominio/etiqueta_venta.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:solera_obrador/modelos/titular.dart';
import 'package:solera_obrador/servicios/generador_etiqueta_venta_pdf.dart';

void main() {
  final ingredientes = {
    1: Ingrediente(id: 1, nombre: 'Harina de trigo', alergenos: {'gluten'}),
    2: Ingrediente(id: 2, nombre: 'Agua'),
    3: Ingrediente(id: 3, nombre: 'Mantequilla', alergenos: {'lacteos'}),
    4: Ingrediente(id: 4, nombre: 'Nueces', alergenos: {'frutos_cascara'}),
    5: Ingrediente(id: 5, nombre: 'Sal', trazas: {'sesamo'}),
  };
  final pan = Receta(
      id: 1,
      nombre: 'Pan de nueces',
      denominacion: 'pan_especial',
      piezasPorMasa: 2,
      mermaCoccionPorcentaje: 20);
  final composicion = ComposicionReceta.calcular(
    recetaId: 1,
    recetas: {1: pan},
    lineasPorReceta: {
      1: [
        LineaReceta(recetaId: 1, ingredienteId: 2, gramos: 600),
        LineaReceta(recetaId: 1, ingredienteId: 1, gramos: 1000),
        LineaReceta(recetaId: 1, ingredienteId: 4, gramos: 150),
        LineaReceta(recetaId: 1, ingredienteId: 3, gramos: 50),
        LineaReceta(recetaId: 1, ingredienteId: 5, gramos: 20),
      ],
    },
    ingredientes: ingredientes,
  );
  final titular = Titular(
      nombre: 'Obrador Ejemplo', direccion: 'Calle Mayor 1, 31001 Iruña');

  ContenidoEtiqueta componer(ModoEtiqueta modo,
          {DatosEtiquetaReceta datos = const DatosEtiquetaReceta(),
          DateTime? fecha,
          String? lote,
          Receta? receta,
          bool cocido24h = false}) =>
      componerEtiqueta(
        modo: modo,
        receta: receta ?? pan,
        composicion: composicion,
        ingredientes: ingredientes,
        datos: datos,
        titular: titular,
        fechaElaboracion: fecha,
        codigoLote: lote,
        cocidoHaceMasDe24h: cocido24h,
      );

  group('lista de ingredientes (arts. 18 y 21)', () {
    test('por peso, con los alérgenos destacados', () {
      final lista = listaIngredientesDestacada(composicion, ingredientes);
      expect(lista.map((f) => f.texto).join(),
          'Harina de trigo, Agua, Nueces, Mantequilla (leche), Sal');
      expect(lista, [
        const FragmentoEtiqueta('Harina de trigo', destacado: true),
        const FragmentoEtiqueta(', Agua, '),
        const FragmentoEtiqueta('Nueces', destacado: true),
        const FragmentoEtiqueta(', Mantequilla ('),
        const FragmentoEtiqueta('leche', destacado: true),
        const FragmentoEtiqueta('), Sal'),
      ]);
    });

    test('el nombre que ya nombra la sustancia no repite el paréntesis', () {
      expect(nombreNombraAlergeno('Harina de Trigo', 'gluten'), isTrue);
      expect(nombreNombraAlergeno('Sésamo tostado', 'sesamo'), isTrue);
      expect(nombreNombraAlergeno('Mantequilla', 'lacteos'), isFalse);
      expect(nombreNombraAlergeno('Harina de fuerza', 'gluten'), isFalse);
    });

    test('porcentaje sobre el producto cocido (anexo VIII 4.a)', () {
      // 150 g de nueces en 1820 g de masa con 20 % de merma → 1456 g.
      expect(porcentajeIngrediente(composicion, 4), closeTo(10.30, 0.01));
      final lista = listaIngredientesDestacada(composicion, ingredientes,
          conPorcentaje: {4});
      expect(lista.map((f) => f.texto).join(), contains('Nueces (10 %)'));
    });

    test('si los porcentajes suman más de 100, en g por 100 g', () {
      final lista = listaIngredientesDestacada(composicion, ingredientes,
          conPorcentaje: {1, 2});
      expect(lista.map((f) => f.texto).join(), contains('g/100 g)'));
    });
  });

  group('envasado (art. 9)', () {
    test('desde una hornada: fecha, lote con «L» y obrador', () {
      final contenido = componer(ModoEtiqueta.envasado,
          datos: const DatosEtiquetaReceta(
              tipoFecha: TipoFechaEtiqueta.consumoPreferente,
              diasDuracion: 3,
              conservacion: 'En lugar fresco y seco'),
          fecha: DateTime(2026, 11, 30),
          lote: '20261130-1-1');
      final texto = contenido.textoPlano;
      expect(contenido.denominacion, 'Pan de nueces');
      expect(texto, contains('Ingredientes: Harina de trigo'));
      expect(texto, contains('Peso neto: 728 g'));
      expect(texto, contains('Consumir preferentemente antes del: 03/12/2026'));
      expect(texto, contains('Lote: L 20261130-1-1'));
      expect(texto, contains('Obrador Ejemplo · Calle Mayor 1'));
      expect(texto, contains('Conservación: En lugar fresco y seco'));
      expect(texto, isNot(contains('Puede contener')));
      expect(texto, isNot(contains('Información nutricional')));
    });

    test('desde la receta: huecos para escribir a mano', () {
      final texto = componer(ModoEtiqueta.envasado,
              datos: const DatosEtiquetaReceta(
                  tipoFecha: TipoFechaEtiqueta.caducidad, diasDuracion: 2))
          .textoPlano;
      expect(texto, contains('Fecha de caducidad: $huecoAMano'));
      expect(texto, contains('Lote: L $huecoAMano'));
    });

    test('sin fecha para lo que se consume en 24 h (anexo X 1.d)', () {
      final texto = componer(ModoEtiqueta.envasado).textoPlano;
      expect(texto, isNot(contains('preferentemente')));
      expect(texto, isNot(contains('caducidad')));
    });

    test('trazas: solo las que indica la persona', () {
      // La sal declara sésamo como traza, pero no se deduce.
      expect(componer(ModoEtiqueta.envasado).textoPlano,
          isNot(contains('Puede contener')));
      final texto = componer(ModoEtiqueta.envasado,
          datos: const DatosEtiquetaReceta(
              trazasIndicadas: {'sesamo', 'gluten'})).textoPlano;
      // El gluten ya está en «contiene»: no se repite como traza.
      expect(texto, contains('Puede contener: sésamo'));
      expect(texto, isNot(contains('Puede contener: cereales')));
    });

    test('información nutricional solo si la pone la persona, en orden', () {
      const info = InfoNutricional(
          energiaKj: 1050,
          energiaKcal: 250,
          grasas: 3,
          saturadas: 1,
          hidratos: 48,
          azucares: 2,
          proteinas: 9,
          sal: 1.2);
      final contenido = componer(ModoEtiqueta.envasado,
          datos: const DatosEtiquetaReceta(infoNutricional: info));
      expect(contenido.tablaNutricional.map((fila) => fila.$1).toList(), [
        'Valor energético',
        'Grasas',
        'de las cuales saturadas',
        'Hidratos de carbono',
        'de los cuales azúcares',
        'Proteínas',
        'Sal',
      ]);
      expect(contenido.tablaNutricional.first.$2, '1.050 kJ / 250 kcal');
      expect(InfoNutricional.deMapa({...info.aMapa(), 'sal': null}), isNull);
    });
  });

  group('granel / cartel (art. 44, RD 126/2015 art. 4)', () {
    test('denominación, «Contiene» y peso de la pieza del pan', () {
      final contenido = componer(ModoEtiqueta.granel);
      final texto = contenido.textoPlano;
      expect(texto,
          contains('Contiene: cereales con gluten, leche, frutos de cáscara'));
      expect(texto, contains('Peso de la pieza: 728 g'));
      expect(texto, isNot(contains('Ingredientes')));
      expect(texto, isNot(contains('Lote')));
      expect(
          contenido.lineas.first.fragmentos
              .every((f) => f.destacado || f.texto == ', '),
          isTrue);
    });

    test('sin denominación de pan no lleva peso de la pieza', () {
      final tarta = Receta(id: 1, nombre: 'Tarta', piezasPorMasa: 2);
      expect(componer(ModoEtiqueta.granel, receta: tarta).textoPlano,
          isNot(contains('Peso de la pieza')));
    });

    test('pan común de más de 24 h (RD 308/2019 art. 15.1)', () {
      final comun = Receta(
          id: 1, nombre: 'Barra', denominacion: 'pan_comun', piezasPorMasa: 2);
      expect(
          componer(ModoEtiqueta.granel, receta: comun, cocido24h: true)
              .textoPlano,
          contains('Cocido hace más de 24 horas'));
      expect(
          componer(ModoEtiqueta.granel, receta: pan, cocido24h: true)
              .textoPlano,
          isNot(contains('24 horas')));
    });
  });

  test('ninguna alegación nutricional ni de salud en la etiqueta', () {
    const prohibidas = [
      'saludable',
      'sano',
      'apto',
      'sin gluten',
      'sin lactosa',
      'sin alérgenos',
      'libre de',
      'bajo en',
      'rico en',
      'fuente de',
      'light',
      'ligero',
      'sin azúcar',
      'reduce',
      'previene',
      'cura',
      'beneficio',
      'natural',
      'digestivo',
      'adelgaza',
      'colesterol',
      'vitamina',
    ];
    final textos = <String>[
      for (final modo in ModoEtiqueta.values)
        componer(modo,
                datos: const DatosEtiquetaReceta(
                    tipoFecha: TipoFechaEtiqueta.caducidad,
                    diasDuracion: 1,
                    trazasIndicadas: {'sesamo'},
                    infoNutricional: InfoNutricional(
                        energiaKj: 1,
                        energiaKcal: 1,
                        grasas: 1,
                        saturadas: 1,
                        hidratos: 1,
                        azucares: 1,
                        proteinas: 1,
                        sal: 1)),
                fecha: DateTime(2026),
                lote: 'X',
                receta: Receta(
                    id: 1,
                    nombre: 'Barra',
                    denominacion: 'pan_comun',
                    piezasPorMasa: 2),
                cocido24h: true)
            .textoPlano
            .replaceAll('Barra', ''),
      // Y todos los textos que se imprimen, en los cuatro idiomas.
      ...File('../../content/solera/traducciones/obrador_etiqueta.csv')
          .readAsLinesSync()
          .where((linea) => linea.startsWith('obra.etiq_l_'))
          .map((linea) => linea.split(',').sublist(1).join(',')),
    ];
    for (final texto in textos) {
      for (final palabra in prohibidas) {
        expect(RegExp('\\b$palabra', caseSensitive: false).hasMatch(texto),
            isFalse,
            reason: '«$palabra» en: $texto');
      }
    }
  });

  group('rejilla A4', () {
    test('hojas necesarias', () {
      expect(hojasNecesarias(24, FormatoEtiqueta.rejilla3x8), 1);
      expect(hojasNecesarias(25, FormatoEtiqueta.rejilla3x8), 2);
      expect(hojasNecesarias(9, FormatoEtiqueta.rejilla2x4), 2);
      expect(hojasNecesarias(3, FormatoEtiqueta.suelta), 3);
      expect(hojasNecesarias(0, FormatoEtiqueta.suelta), 0);
    });

    test('celdas de 70 × 37,125 mm llenadas por filas', () {
      final cuarta = celdaEtiqueta(3, FormatoEtiqueta.rejilla3x8);
      expect(cuarta.hoja, 0);
      expect(cuarta.izquierdaMm, 0);
      expect(cuarta.arribaMm, closeTo(37.125, 0.001));
      expect(cuarta.anchoMm, 70);
      final ultima = celdaEtiqueta(23, FormatoEtiqueta.rejilla3x8);
      expect(ultima.izquierdaMm + ultima.anchoMm, closeTo(anchoA4Mm, 0.001));
      expect(ultima.arribaMm + ultima.altoMm, closeTo(altoA4Mm, 0.001));
      expect(celdaEtiqueta(24, FormatoEtiqueta.rejilla3x8).hoja, 1);
      final dosPorCuatro = celdaEtiqueta(1, FormatoEtiqueta.rejilla2x4);
      expect(dosPorCuatro.izquierdaMm, 105);
      expect(dosPorCuatro.altoMm, closeTo(74.25, 0.001));
    });

    test('la letra de cada formato da la altura de la x mínima (art. 13)', () {
      for (final formato in FormatoEtiqueta.values) {
        expect(
            alturaXMm(formato.tamanoLetraPt),
            greaterThanOrEqualTo(
                alturaXMinimaMm(superficieMenorDe80cm2: false)),
            reason: formato.name);
      }
    });

    test('una etiqueta con tabla nutricional no cabe en 3 × 8', () {
      final contenido = componer(ModoEtiqueta.envasado,
          datos: const DatosEtiquetaReceta(
              infoNutricional: InfoNutricional(
                  energiaKj: 1,
                  energiaKcal: 1,
                  grasas: 1,
                  saturadas: 1,
                  hidratos: 1,
                  azucares: 1,
                  proteinas: 1,
                  sal: 1)));
      expect(cabeEnEtiqueta(contenido, FormatoEtiqueta.rejilla3x8), isFalse);
      expect(cabeEnEtiqueta(contenido, FormatoEtiqueta.suelta), isTrue);
      expect(
          cabeEnEtiqueta(
              componer(ModoEtiqueta.granel), FormatoEtiqueta.rejilla3x8),
          isTrue);
    });
  });

  test('avisos: falta el titular, caducidad sin conservación', () {
    const datos = DatosEtiquetaReceta(tipoFecha: TipoFechaEtiqueta.caducidad);
    final avisos = avisosEtiqueta(
      modo: ModoEtiqueta.envasado,
      datos: datos,
      titular: Titular(),
      contenido: componer(ModoEtiqueta.envasado, datos: datos),
      formato: FormatoEtiqueta.suelta,
      tieneFechaYLote: false,
    );
    expect(
        avisos,
        containsAll([
          'obra.etiq_aviso_falta_titular',
          'obra.etiq_aviso_falta_duracion',
          'obra.etiq_aviso_caducidad_sin_conservacion',
          'obra.etiq_aviso_a_mano',
          'obra.etiq_aviso_sin_nutricional',
        ]));
    expect(
        avisosEtiqueta(
          modo: ModoEtiqueta.granel,
          datos: datos,
          titular: Titular(),
          contenido: componer(ModoEtiqueta.granel),
          formato: FormatoEtiqueta.suelta,
          tieneFechaYLote: false,
        ),
        isEmpty);
  });

  test('los datos de la etiqueta van y vuelven por JSON', () {
    const datos = DatosEtiquetaReceta(
      denominacion: 'Pan de nueces',
      cantidadNetaGramos: 500,
      tipoFecha: TipoFechaEtiqueta.consumoPreferente,
      diasDuracion: 4,
      conservacion: 'Fresco',
      ingredientesConPorcentaje: {4},
      trazasIndicadas: {'sesamo'},
    );
    final vuelta = DatosEtiquetaReceta.deJson(datos.aJson());
    expect(vuelta.aJson(), datos.aJson());
    expect(vuelta.infoNutricional, isNull);
  });

  test('el PDF sale con varias hojas y no se rompe si no cabe', () async {
    for (final formato in FormatoEtiqueta.values) {
      final bytes = await generarEtiquetaVentaPdf(
        contenido: componer(ModoEtiqueta.envasado,
            datos: const DatosEtiquetaReceta(
                conservacion: 'Texto muy largo de conservación que se repite '
                    'para que no quepa en la etiqueta más pequeña de todas.')),
        formato: formato,
        copias: 30,
      );
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    }
  });
}
