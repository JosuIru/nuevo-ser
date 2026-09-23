import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/ambiente_cielo.dart';
import 'package:uno_roto/dominio/catalogo_distritos.dart';
import 'package:uno_roto/dominio/clima_distrito.dart';
import 'package:uno_roto/dominio/cuaderno.dart';
import 'package:uno_roto/dominio/fragmento_en_tejado.dart';
import 'package:uno_roto/dominio/fragmentos_de_clima.dart';

/// Tests de los raros de clima (doc 16, eje E): coherencia del
/// catálogo (que ningún raro sea imposible de encontrar), regla de
/// aparición y payoff en el Cuaderno.
void main() {
  group('CatalogoFragmentosDeClima — coherencia', () {
    test('ids únicos y distritos existentes', () {
      final ids = CatalogoFragmentosDeClima.todos.map((r) => r.id).toSet();
      expect(ids.length, CatalogoFragmentosDeClima.todos.length);
      final distritos =
          CatalogoDistritos.todos.map((d) => d.identificador).toSet();
      for (final raro in CatalogoFragmentosDeClima.todos) {
        expect(distritos.contains(raro.idDistrito), isTrue,
            reason: '${raro.id} apunta a un distrito inexistente');
      }
    });

    test('como mucho un raro por pareja (distrito, ambiente)', () {
      final parejas = CatalogoFragmentosDeClima.todos
          .map((r) => '${r.idDistrito}|${r.ambienteRequerido}')
          .toSet();
      expect(parejas.length, CatalogoFragmentosDeClima.todos.length,
          reason: 'Dos raros con la misma condición se pisarían: '
              'paraHoy solo devuelve el primero');
    });

    test('el clima requerido puede darse de verdad en su distrito', () {
      // Recorre dos años de días con ClimaDistrito (determinista) y
      // comprueba que el ambiente que pide cada raro toca al menos un
      // día. Sin esto, un raro podría ser matemáticamente imposible
      // de encontrar y nadie se enteraría.
      for (final raro in CatalogoFragmentosDeClima.todos) {
        var aparece = false;
        for (var dia = 0; dia < 730 && !aparece; dia++) {
          final fecha = DateTime(2026, 1, 1).add(Duration(days: dia));
          final ambiente = ClimaDistrito.delDia(
            idDistrito: raro.idDistrito,
            ahora: fecha,
          );
          if (ambiente == raro.ambienteRequerido) aparece = true;
        }
        expect(aparece, isTrue,
            reason: '${raro.id} exige ${raro.ambienteRequerido} en '
                '${raro.idDistrito}, pero ese clima no toca nunca allí');
      }
    });

    test('cada raro tiene su entrada del Cuaderno', () {
      final flagsDeEntradas =
          CatalogoCuaderno.todas.map((e) => e.flagDesbloqueo).toSet();
      for (final raro in CatalogoFragmentosDeClima.todos) {
        expect(flagsDeEntradas.contains(raro.flagCaptura), isTrue,
            reason: '${raro.id} no desbloquea ninguna entrada — el raro '
                'se quedaría sin recompensa de conocimiento (doc 16 §2)');
      }
    });
  });

  group('CatalogoFragmentosDeClima.paraHoy', () {
    test('devuelve el raro cuando distrito y ambiente coinciden', () {
      final raro = CatalogoFragmentosDeClima.paraHoy(
        idDistrito: 'puerto',
        ambiente: AmbienteCielo.niebla,
        flagsActivos: const {},
      );
      expect(raro?.id, 'la_lucerna');
    });

    test('null si el ambiente no acompaña o el distrito no tiene raro', () {
      expect(
        CatalogoFragmentosDeClima.paraHoy(
          idDistrito: 'puerto',
          ambiente: AmbienteCielo.nocheDespejada,
          flagsActivos: const {},
        ),
        isNull,
      );
      expect(
        CatalogoFragmentosDeClima.paraHoy(
          idDistrito: 'mercado',
          ambiente: AmbienteCielo.niebla,
          flagsActivos: const {},
        ),
        isNull,
      );
    });

    test('ya capturado → no vuelve a aparecer', () {
      final raro = CatalogoFragmentosDeClima.paraHoy(
        idDistrito: 'puerto',
        ambiente: AmbienteCielo.niebla,
        flagsActivos: const {'clima_la_lucerna_capturado'},
      );
      expect(raro, isNull);
    });
  });

  group('FragmentoEnTejado.conMarcaDeClima', () {
    test('copia campos y solo añade la marca', () {
      final base = FragmentoEnTejado(
        identificador: 'f1',
        numerador: 3,
        denominador: 4,
        xNormalizado: 0.5,
        yNormalizado: 0.6,
        instanteAparicion: DateTime(2026, 7, 8, 20),
        tiempoDeVida: const Duration(seconds: 20),
        tipo: TipoFragmentoEnTejado.espejo,
        dificultadSugerida: 2,
      );
      final marcado = base.conMarcaDeClima('la_lucerna');
      expect(marcado.esDeClima, isTrue);
      expect(marcado.idFragmentoDeClima, 'la_lucerna');
      expect(base.esDeClima, isFalse, reason: 'el original no se muta');
      expect(marcado.identificador, base.identificador);
      expect(marcado.tipo, base.tipo);
      expect(marcado.numerador, base.numerador);
      expect(marcado.denominador, base.denominador);
      expect(marcado.dificultadSugerida, base.dificultadSugerida);
      expect(marcado.tiempoDeVida, base.tiempoDeVida);
    });
  });
}
