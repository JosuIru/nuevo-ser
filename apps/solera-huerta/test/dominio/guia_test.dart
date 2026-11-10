// Guía del huerto: integridad de content/huerta/guia_*.csv, límites de
// contenido (nada de productos, dosis ni promesas de salud) y lógica pura.

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_cultivos.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_guia_cultivos.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_guia_fauna.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_guia_plantas.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_guia_tecnicas.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_plagas.dart';
import 'package:solera_huerta/dominio/guia.dart';

void main() {
  final idsCultivo = {for (final cultivo in catalogoCultivos) cultivo.id};
  final idsPlaga = {for (final plaga in catalogoPlagas) plaga.id};
  final idsFauna = {for (final ficha in catalogoGuiaFauna) ficha.id};

  /// Todo el texto que la guía enseña, con la ficha de la que sale.
  final textos = <(String, String)>[
    for (final ficha in catalogoGuiaCultivos)
      for (final texto in textosFichaCultivo(ficha))
        ('cultivo ${ficha.id}', texto),
    for (final ficha in catalogoGuiaFauna)
      for (final texto in textosFichaFauna(ficha)) ('fauna ${ficha.id}', texto),
    for (final ficha in catalogoGuiaPlantas)
      for (final texto in textosFichaPlanta(ficha))
        ('planta ${ficha.id}', texto),
    for (final ficha in catalogoGuiaTecnicas)
      for (final texto in textosFichaTecnica(ficha))
        ('técnica ${ficha.id}', texto),
  ];

  group('integridad', () {
    test('tamaño de cada sección', () {
      expect(catalogoGuiaCultivos, hasLength(catalogoCultivos.length));
      expect(catalogoGuiaFauna.length, greaterThanOrEqualTo(12));
      expect(catalogoGuiaPlantas.length, greaterThanOrEqualTo(12));
      expect(catalogoGuiaTecnicas.length, greaterThanOrEqualTo(10));
    });

    test('una ficha por cultivo del catálogo, sin repetir', () {
      final ids = catalogoGuiaCultivos.map((ficha) => ficha.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.toSet(), idsCultivo);
    });

    test('ids únicos en fauna, plantas y técnicas', () {
      for (final ids in [
        catalogoGuiaFauna.map((ficha) => ficha.id).toList(),
        catalogoGuiaPlantas.map((ficha) => ficha.id).toList(),
        catalogoGuiaTecnicas.map((ficha) => ficha.id).toList(),
      ]) {
        expect(ids.toSet(), hasLength(ids.length), reason: '$ids');
      }
    });

    test('las plagas citadas existen en plagas_huerta.csv', () {
      for (final ficha in catalogoGuiaCultivos) {
        expect(idsPlaga, containsAll(ficha.plagas), reason: ficha.id);
      }
      for (final ficha in catalogoGuiaFauna) {
        expect(idsPlaga, containsAll(ficha.plagas), reason: ficha.id);
      }
      for (final ficha in catalogoGuiaPlantas) {
        expect(idsPlaga, containsAll(ficha.plagas), reason: ficha.id);
      }
    });

    test('la fauna y los cultivos citados por las plantas existen', () {
      for (final ficha in catalogoGuiaPlantas) {
        expect(idsFauna, containsAll(ficha.fauna), reason: ficha.id);
        if (ficha.cultivoId.isNotEmpty) {
          expect(idsCultivo, contains(ficha.cultivoId), reason: ficha.id);
        }
        expect([
          'flor_auxiliares',
          'abono_verde',
          'cobertura',
          'reservorio'
        ], contains(ficha.tipo), reason: ficha.id);
      }
    });

    test('asociaciones: id de cultivo o nombre propio con mayúscula', () {
      for (final ficha in catalogoGuiaCultivos) {
        for (final valor in [
          ...ficha.asociacionesFavorables,
          ...ficha.asociacionesDesfavorables,
        ]) {
          final esId = idsCultivo.contains(valor);
          final esNombre = valor[0] == valor[0].toUpperCase() &&
              valor[0] != valor[0].toLowerCase();
          expect(esId || esNombre, isTrue, reason: '${ficha.id}: $valor');
          expect(valor, isNot(ficha.id), reason: 'se asocia consigo mismo');
        }
        // Una planta no puede ser a la vez favorable y desfavorable.
        expect(
            ficha.asociacionesFavorables.toSet()
              ..retainAll(ficha.asociacionesDesfavorables),
            isEmpty,
            reason: ficha.id);
      }
    });

    test('meses bien escritos (1-12, rangos a-b)', () {
      final formato = RegExp(r'^(1[0-2]|[1-9])(-(1[0-2]|[1-9]))?$');
      for (final ficha in catalogoGuiaCultivos) {
        for (final rango in [
          ...ficha.mesesSemillero,
          ...ficha.mesesDirecta,
          ...ficha.mesesTrasplante,
        ]) {
          expect(formato.hasMatch(rango), isTrue,
              reason: '${ficha.id}: $rango');
        }
      }
    });

    test('toda fila tiene fuente y revisado_por es revision-ia: o vacío', () {
      final filas = <(String, String, String)>[
        for (final ficha in catalogoGuiaCultivos)
          (ficha.id, ficha.fuente, ficha.revisadoPor),
        for (final ficha in catalogoGuiaFauna)
          (ficha.id, ficha.fuente, ficha.revisadoPor),
        for (final ficha in catalogoGuiaPlantas)
          (ficha.id, ficha.fuente, ficha.revisadoPor),
        for (final ficha in catalogoGuiaTecnicas)
          (ficha.id, ficha.fuente, ficha.revisadoPor),
      ];
      for (final (id, fuente, revisadoPor) in filas) {
        expect(fuente.trim(), isNotEmpty, reason: '$id sin fuente');
        expect(revisadoPor.isEmpty || revisadoPor.startsWith('revision-ia:'),
            isTrue,
            reason: '$id: «$revisadoPor» (nunca asesor: ni persona:)');
      }
    });

    test('cada ficha de cultivo dice algo útil', () {
      for (final ficha in catalogoGuiaCultivos) {
        expect(ficha.siembra, isNotEmpty, reason: ficha.id);
        expect(ficha.cosecha, isNotEmpty, reason: ficha.id);
        expect(ficha.curiosidad, isNotEmpty, reason: ficha.id);
      }
    });
  });

  group('límites del contenido (hard limits)', () {
    final terminosProhibidos = <String, RegExp>{
      'dosis': RegExp(r'\bdosis\b', caseSensitive: false),
      'concentración por volumen o superficie': RegExp(
          r'\d\s*(ml|cc|cm3|g|gr|kg|l)\s*/\s*(l|litro|hl|ha|m2|m²)\b',
          caseSensitive: false),
      'mililitros o cc':
          RegExp(r'\b(\d+\s*)?(ml|cc|mililitros?)\b', caseSensitive: false),
      'por litro':
          RegExp(r'(por|cada|en)\s+(\d+\s+)?litros?\b', caseSensitive: false),
      'diluir': RegExp(r'\b(dilu|disolv)', caseSensitive: false),
      'pulverizar o fumigar':
          RegExp(r'\b(pulveriz|fumig|espolvore|asperj)', caseSensitive: false),
      'productos concretos': RegExp(
          r'(caldo bordel|jab[oó]n|neem|bacillus|thuringiensis|azufre|cobre|'
          r'piretr|spinosad|aceite de parafina|pur[ií]n|extracto de|maceraci|'
          r'infusi[oó]n de|decocci)',
          caseSensitive: false),
      'marcas': RegExp(r'[®™]'),
      'promesas de salud': RegExp(
          r'(medicinal|curativ|\bcura[rn]?\b|remedio|sanar|antiinflam|'
          r'diur[eé]tic|depurativ|digestiv|saludable|vitamina|adelgaz|'
          r'antioxidante|beneficios? para la salud|propiedades)',
          caseSensitive: false),
    };

    test('ningún texto de la guía tiene términos prohibidos', () {
      for (final (origen, texto) in textos) {
        for (final MapEntry(key: motivo, value: patron)
            in terminosProhibidos.entries) {
          expect(patron.hasMatch(texto), isFalse,
              reason: '$origen ($motivo): «$texto»');
        }
      }
    });

    test('los plaguicidas solo se nombran para desaconsejarlos', () {
      final plaguicida = RegExp(r'(insectic|fungic|herbic|plaguic|acaric)',
          caseSensitive: false);
      for (final (origen, texto) in textos) {
        for (final frase in texto.split(RegExp(r'[.|]'))) {
          if (!plaguicida.hasMatch(frase)) continue;
          expect(frase.trim().toLowerCase(), startsWith('evita'),
              reason: '$origen: «$frase»');
        }
      }
    });

    test('las asociaciones avisan cuando son tradición', () {
      // La pantalla añade siempre el aviso de tradición; aquí se comprueba
      // que ninguna nota de asociaciones las vende como seguras.
      final promesa = RegExp(r'(garantiza|siempre funciona|elimina la plaga)',
          caseSensitive: false);
      for (final ficha in catalogoGuiaCultivos) {
        expect(promesa.hasMatch(ficha.notaAsociaciones), isFalse,
            reason: ficha.id);
      }
    });
  });

  group('lógica', () {
    test('meses de rangos, también cruzando el año', () {
      expect(mesesDeRangos(['2-4']), {2, 3, 4});
      expect(mesesDeRangos(['8-1']), {8, 9, 10, 11, 12, 1});
      expect(mesesDeRangos(['2', '7-8']), {2, 7, 8});
      expect(mesesDeRangos(['13-2', 'x']), isEmpty);
    });

    test('calendario del tomate: semillero en febrero, trasplante en mayo', () {
      final calendario = calendarioDe(fichaGuiaCultivo('tomate')!);
      expect(calendario[FormaSiembra.semillero], contains(2));
      expect(calendario[FormaSiembra.trasplante], contains(5));
      expect(calendario.containsKey(FormaSiembra.directa), isFalse);
    });

    test('sugerencias del mes: como mucho 3, coherentes con las fichas', () {
      for (var mes = 1; mes <= 12; mes++) {
        final sugerencias = sugerenciasDelMes(mes);
        expect(sugerencias.length, lessThanOrEqualTo(3));
        for (final sugerencia in sugerencias) {
          final calendario =
              calendarioDe(fichaGuiaCultivo(sugerencia.cultivoId)!);
          expect(calendario[sugerencia.forma], contains(mes),
              reason: '$mes ${sugerencia.cultivoId}');
        }
      }
      expect(sugerenciasDelMes(3), isNotEmpty);
    });

    test('sugerencias: primero lo que ya cultiva la persona', () {
      final sugerencias =
          sugerenciasDelMes(10, especiesPropias: {'haba'}, giro: 5);
      expect(sugerencias.first.cultivoId, 'haba');
      expect(sugerencias.first.forma, FormaSiembra.directa);
    });

    test('el giro cambia las sugerencias sin repetir cultivo', () {
      final primera = sugerenciasDelMes(4, giro: 0);
      final otra = sugerenciasDelMes(4, giro: 3);
      expect(
          primera.map((s) => s.cultivoId).toSet(), hasLength(primera.length));
      expect(primera, isNot(equals(otra)));
    });

    test('auxiliares de una plaga y plantas que atraen a la fauna', () {
      final contraPulgon = auxiliaresDePlaga('pulgones').map((f) => f.id);
      expect(contraPulgon, containsAll(['mariquitas', 'sirfidos', 'crisopas']));
      expect(auxiliaresDePlaga('no_existe'), isEmpty);
      expect(
          plantasParaFauna('sirfidos').map((p) => p.id), contains('lobularia'));
      expect(cultivosConPlaga('tuta_absoluta'), contains('tomate'));
    });

    test('búsqueda sin acentos ni mayúsculas', () {
      expect(
          buscarCultivos('CALABACIN').map((f) => f.id), contains('calabacin'));
      expect(buscarFauna('sirfido').map((f) => f.id), contains('sirfidos'));
      expect(buscarPlantas('facelia').map((f) => f.id), contains('facelia'));
      expect(buscarTecnicas('compost').map((f) => f.id), contains('compost'));
      expect(buscarCultivos(''), hasLength(catalogoGuiaCultivos.length));
      expect(buscarCultivos('zzzz'), isEmpty);
    });

    test('nombres de asociaciones: del catálogo o tal cual', () {
      expect(nombreAsociacion('judia_verde'), 'Judía verde');
      expect(nombreAsociacion('Albahaca'), 'Albahaca');
      expect(asociacionConFicha('tomate'), isTrue);
      expect(asociacionConFicha('Albahaca'), isFalse);
    });

    test('citas separadas por punto y coma', () {
      expect(citasDe('a; b ;; c'), ['a', 'b', 'c']);
    });
  });
}
