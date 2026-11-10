import 'package:flutter_test/flutter_test.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_guia_fichas.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_guia_recetas.dart';
import 'package:solera_obrador/datos/catalogos_generados/catalogo_guia_recetas_ingredientes.dart';
import 'package:solera_obrador/dominio/comprobacion_denominacion.dart';
import 'package:solera_obrador/dominio/guia_obrador.dart';

/// Palabras que la guía no puede usar: promesas de salud o nutricionales,
/// declaraciones de alérgenos y tratamientos de conservas.
const List<String> _palabrasProhibidas = [
  'digestiv',
  'saludable',
  'salud',
  'sano',
  'sana ',
  'sin gluten',
  'celiac',
  'apto para',
  'apta para',
  'bajo en',
  'rico en',
  'rica en',
  'fibra',
  'nutritiv',
  'probiotic',
  'adelgaz',
  'colesterol',
  'vitamina',
  'esteriliz',
  'pasteuriz',
  'alergeno',
];

String _textoReceta(RecetaGuia receta) => [
      receta.nombre,
      receta.autolisis,
      receta.amasado,
      receta.primeraFermentacion,
      receta.formado,
      receta.fermentacionFinal,
      receta.coccion,
      receta.senalHecho,
      receta.notas,
      for (final linea in ingredientesDeRecetaGuia(receta.id)) linea.nota,
    ].join(' ');

void main() {
  group('integridad', () {
    test('hay 10 recetas base y fichas en todas las secciones', () {
      expect(catalogoGuiaRecetas, hasLength(10));
      for (final seccion in seccionesGuiaObrador.skip(1)) {
        expect(fichasGuiaDeSeccion(seccion), isNotEmpty, reason: seccion);
      }
      expect(
          catalogoGuiaFichas
              .every((ficha) => seccionesGuiaObrador.contains(ficha.seccion)),
          isTrue);
    });

    test('ids únicos', () {
      expect(catalogoGuiaRecetas.map((receta) => receta.id).toSet(),
          hasLength(catalogoGuiaRecetas.length));
      expect(catalogoGuiaFichas.map((ficha) => ficha.id).toSet(),
          hasLength(catalogoGuiaFichas.length));
    });

    test('toda fila con fuente y revisión de IA (nunca firma de persona)', () {
      final filas = [
        for (final receta in catalogoGuiaRecetas)
          (receta.id, receta.fuente, receta.revisadoPor),
        for (final linea in catalogoGuiaRecetasIngredientes)
          (
            '${linea.recetaId}/${linea.ingredienteId}',
            linea.fuente,
            linea.revisadoPor
          ),
        for (final ficha in catalogoGuiaFichas)
          (ficha.id, ficha.fuente, ficha.revisadoPor),
      ];
      for (final (id, fuente, revisadoPor) in filas) {
        expect(fuente.trim(), isNotEmpty, reason: id);
        expect(revisadoPor, startsWith('revision-ia:'), reason: id);
      }
    });

    test('los ingredientes casan con ingredientes_base.csv', () {
      for (final linea in catalogoGuiaRecetasIngredientes) {
        expect(recetaGuiaPorId(linea.recetaId), isNotNull,
            reason: linea.recetaId);
        expect(ingredienteBasePorId(linea.ingredienteId), isNotNull,
            reason: '${linea.recetaId}: ${linea.ingredienteId}');
        expect(linea.porcentaje, greaterThan(0));
      }
    });

    test('porcentajes coherentes: harinas = 100 e hidratación = líquidos', () {
      for (final receta in catalogoGuiaRecetas) {
        expect(sumaHarinasRecetaGuia(receta.id), closeTo(100, 1e-9),
            reason: receta.id);
        final liquidos = ingredientesDeRecetaGuia(receta.id)
            .where((linea) => {'agua', 'leche', 'huevo', 'nata'}
                .contains(linea.ingredienteId))
            .fold<double>(0, (suma, linea) => suma + linea.porcentaje);
        expect(receta.hidratacionPorcentaje, closeTo(liquidos, 1e-9),
            reason: receta.id);
        expect(receta.mermaCoccionPorcentaje, inInclusiveRange(5, 25),
            reason: receta.id);
        expect(receta.temperaturaMasaGrados, inInclusiveRange(20, 30),
            reason: receta.id);
        final sal = ingredientesDeRecetaGuia(receta.id)
            .where((linea) => linea.ingredienteId == 'sal');
        expect(sal.single.porcentaje, inInclusiveRange(1, 2.5),
            reason: receta.id);
      }
    });

    test('solo la ficha de la temperatura del agua lleva calculadora', () {
      expect(
          catalogoGuiaFichas
              .where((ficha) => ficha.calculadora.isNotEmpty)
              .map((ficha) => (ficha.id, ficha.calculadora)),
          [('temperatura_agua', 'temperatura_agua')]);
    });
  });

  group('hard limits', () {
    test('sin promesas de salud, nutricionales ni de alérgenos', () {
      final textos = {
        for (final receta in catalogoGuiaRecetas)
          'receta ${receta.id}': _textoReceta(receta),
        for (final ficha in catalogoGuiaFichas)
          'ficha ${ficha.id}': [ficha.titulo, ...ficha.parrafos].join(' '),
      };
      textos.forEach((origen, texto) {
        final normalizado = normalizarTextoGuia(texto);
        for (final palabra in _palabrasProhibidas) {
          expect(normalizado.contains(palabra), isFalse,
              reason: '$origen contiene «$palabra»');
        }
      });
    });

    test('las conservas solo se remiten: ni una cifra en su ficha', () {
      final ficha = fichaGuiaPorId('conservas')!;
      expect(ficha.parrafos.join(' '), isNot(matches(RegExp(r'\d'))));
      expect(ficha.fuente, contains('AESAN'));
    });
  });

  group('denominaciones (RD 308/2019)', () {
    for (final receta in catalogoGuiaRecetas) {
      test('«${receta.nombre}» no promete lo que no cumple', () {
        expect(problemasDenominacionRecetaGuia(receta), isEmpty);
        if (receta.denominacion.isNotEmpty) {
          expect(denominacionPorId(receta.denominacion), isNotNull);
          expect(
              salSuperaMaximo(
                  composicionRecetaGuia(receta), receta.denominacion),
              isFalse);
        }
      });
    }

    RecetaGuia variante(RecetaGuia base,
            {String? nombre, String? denominacion}) =>
        RecetaGuia(
          id: base.id,
          nombre: nombre ?? base.nombre,
          denominacion: denominacion ?? base.denominacion,
          esSubreceta: base.esSubreceta,
          hidratacionPorcentaje: base.hidratacionPorcentaje,
          temperaturaMasaGrados: base.temperaturaMasaGrados,
          mermaCoccionPorcentaje: base.mermaCoccionPorcentaje,
          autolisis: '',
          amasado: '',
          primeraFermentacion: '',
          formado: '',
          fermentacionFinal: '',
          coccion: '',
          senalHecho: '',
          notas: '',
          fuente: '',
          revisadoPor: '',
        );

    test('la comprobación caza los nombres que prometen de más', () {
      final rustico = recetaGuiaPorId('rustico')!;
      expect(
          problemasDenominacionRecetaGuia(
              variante(rustico, nombre: 'Pan rústico integral')),
          isNotEmpty);
      expect(
          problemasDenominacionRecetaGuia(
              variante(rustico, nombre: 'Pan rústico de masa madre')),
          isNotEmpty,
          reason: 'lleva levadura y no masa madre');
      expect(
          problemasDenominacionRecetaGuia(
              variante(rustico, nombre: 'Pan de centeno')),
          isNotEmpty);
      expect(
          problemasDenominacionRecetaGuia(
              variante(rustico, nombre: 'Pan de larga fermentación')),
          isNotEmpty);
      expect(
          problemasDenominacionRecetaGuia(
              variante(rustico, denominacion: 'pan_integral')),
          isNotEmpty);
      final focaccia = recetaGuiaPorId('focaccia')!;
      expect(
          problemasDenominacionRecetaGuia(
              variante(focaccia, denominacion: 'pan_comun')),
          isNotEmpty,
          reason: 'el aceite no cabe en el pan común');
    });
  });

  group('cálculos', () {
    test('de % a gramos por harina y por masa total', () {
      final porHarina = gramosRecetaGuia('rustico', gramosHarina: 1000);
      expect(porHarina['harina_trigo'], closeTo(1000, 1e-9));
      expect(porHarina['agua'], closeTo(680, 1e-9));
      expect(porHarina['sal'], closeTo(18, 1e-9));
      final porMasa = gramosRecetaGuia('rustico', gramosMasa: 1713);
      expect(porMasa['harina_trigo'], closeTo(1000, 1e-9));
      expect(porMasa.values.fold<double>(0, (suma, gramos) => suma + gramos),
          closeTo(1713, 1e-9));
    });

    test('temperatura del agua: directa × 3 y con prefermento × 4', () {
      expect(
          temperaturaAguaParaMasa(
              objetivo: 24, harina: 20, ambiente: 22, friccion: 4),
          26);
      expect(
          temperaturaAguaParaMasa(
              objetivo: 24,
              harina: 20,
              ambiente: 22,
              friccion: 4,
              prefermento: 21),
          29);
      expect(factorFriccion(masa: 25, harina: 20, ambiente: 22, agua: 20), 13);
    });

    test('la búsqueda ignora mayúsculas y acentos', () {
      expect(recetasGuiaFiltradas(consulta: 'CENTENO').map((r) => r.id),
          contains('centeno'));
      expect(fichasGuiaDeSeccion('fermentacion', consulta: 'autolisis'),
          isNotEmpty);
      expect(recetasGuiaFiltradas(consulta: 'zzz'), isEmpty);
    });
  });
}
