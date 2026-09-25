import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/catalogo_escenas.dart';
import 'package:uno_roto/dominio/escena_cinematica.dart';
import 'package:uno_roto/dominio/plano_escena.dart';
import 'package:uno_roto/dominio/variantes_entrenamiento.dart';
import 'package:uno_roto/dominio/variantes_maquinas.dart';
import 'package:uno_roto/dominio/variantes_puentes.dart';

/// Recorre el grafo narrativo completo y verifica que cada flag
/// requerido por una escena tiene un origen identificable: o bien
/// otra escena del catálogo lo produce como `flagDeSalida`, o lo
/// produce una elección, una variante recurrente, o pertenece a
/// la lista blanca conocida (combates jugables, niveles de maestría,
/// rangos narrativos).
///
/// Sin este test, renombrar una habilidad o quitar una escena puede
/// dejar gates huérfanos que bloquean silenciosamente partes de la
/// narrativa.
void main() {
  // Lista blanca de prefijos/patrones que el catálogo NO produce
  // pero el sistema sí, en runtime.
  //
  // Combate jugable (main.dart:_alTerminarCombateKurz / _alTerminarDuelKai
  // / _alTerminarCombateZafran / _alTerminarCombateVorax). Cada combate
  // produce un flag `combate_<id>_completado` y otro `victoria_<id>` o
  // `derrota_<id>`.
  const idsCombate = <String>{
    'kurz_1',
    'kurz_2',
    'kurz_3',
    'zafran',
    'vorax',
    'duel_kai',
    'velo',
  };
  final flagsDeCombate = <String>{
    for (final id in idsCombate) ...[
      'combate_${id}_completado',
      'victoria_$id',
      'derrota_$id',
    ],
  };

  // Maestría. `MotorMaestria.flagDeMaestria` produce
  // `<dominio>_<numero>_<nivel>`. Lista blanca por regex.
  final reMaestria = RegExp(
    r'^(fr|dec|prop|div|op|med|geo|est|ari|alg|fun)_\d+_'
    r'(introducida|en_desarrollo|competente|maestria)$',
  );

  // Rangos narrativos (rango_narrativo.dart).
  const flagsDeRango = <String>{
    'rango_aprendiz_i_alcanzado',
    'rango_aprendiz_ii_alcanzado',
    'rango_aprendiz_iii_alcanzado',
    'rango_iniciado_alcanzado',
  };

  Iterable<EscenaCinematica> todasLasEscenasNavegables() sync* {
    yield* CatalogoEscenas.todas;
    yield* VariantesEntrenamiento.todas;
    yield* VariantesPuentes.todas;
    yield* VariantesMaquinas.todas;
  }

  Set<String> recolectarFlagsProducidos() {
    final producidos = <String>{};
    for (final escena in todasLasEscenasNavegables()) {
      producidos.add(escena.flagDeSalida);
      for (final plano in escena.planos) {
        if (plano is PlanoEleccion) {
          for (final opcion in plano.opciones) {
            producidos.addAll(opcion.flagsAEstablecer);
          }
        }
      }
    }
    return producidos;
  }

  bool flagSeProduce(String flag, Set<String> producidos) {
    if (producidos.contains(flag)) return true;
    if (flagsDeCombate.contains(flag)) return true;
    if (flagsDeRango.contains(flag)) return true;
    if (reMaestria.hasMatch(flag)) return true;
    return false;
  }

  test('cada flag requerido tiene origen — sin gates huérfanos', () {
    final producidos = recolectarFlagsProducidos();
    final huerfanos = <String, List<String>>{};
    for (final escena in CatalogoEscenas.todas) {
      for (final flag in escena.flagsRequeridos) {
        if (!flagSeProduce(flag, producidos)) {
          huerfanos.putIfAbsent(escena.id, () => []).add(flag);
        }
      }
    }
    expect(
      huerfanos,
      isEmpty,
      reason: 'Las siguientes escenas requieren flags que nadie produce: '
          '$huerfanos. Si la habilidad cambió de id o se quitó una '
          'escena productora, el gate quedó colgando.',
    );
  });

  test('flagDeSalida único — salvo puntos de convergencia conocidos', () {
    // 1.10derrota y 1.10victoria comparten `escena_1_10_resuelta` para
    // que la 1.12pre tenga un único gate sea cual sea la rama del
    // combate. 4.9f, 4.9s y 4.9e comparten `prueba_completada` para
    // que la 4.10 (ceremonia) converja desde las tres ramas. El resto
    // de duplicados serían bug.
    const convergenciasPermitidas = <String>{
      'escena_1_10_resuelta',
      'prueba_completada',
      // 5.8victoria y 5.8derrota: la 5.9 sigue gane o pierda con Velo.
      'escena_5_8_vista',
    };
    final cuentas = <String, int>{};
    for (final escena in CatalogoEscenas.todas) {
      cuentas[escena.flagDeSalida] = (cuentas[escena.flagDeSalida] ?? 0) + 1;
    }
    final duplicadosNoPermitidos = {
      for (final entrada in cuentas.entries)
        if (entrada.value > 1 && !convergenciasPermitidas.contains(entrada.key))
          entrada.key: entrada.value,
    };
    expect(duplicadosNoPermitidos, isEmpty);
  });

  test('todas las escenas del catálogo principal son alcanzables desde 1.1',
      () {
    // Búsqueda en anchura: empezamos sin flags activos. La 1.1 no
    // requiere ninguno; tras "verla" activamos su flagDeSalida y
    // repetimos hasta que no se desbloquee nada nuevo. Las escenas
    // que necesitan flags fuera del catálogo (combate, maestría,
    // rango, elección) las consideramos alcanzables sustituyendo
    // esos flags por su origen.
    final flagsSimulados = <String>{};

    // Sembramos los flags fuera del catálogo: asumimos que el sistema
    // los produce a su tiempo. Si fallara la búsqueda solo por falta
    // de uno de estos, no es un bug del catálogo, es un cableado de
    // runtime.
    flagsSimulados.addAll(flagsDeCombate);
    flagsSimulados.addAll(flagsDeRango);
    // Los gates de maestría: añadimos los concretos referenciados.
    for (final escena in CatalogoEscenas.todas) {
      for (final flag in escena.flagsRequeridos) {
        if (reMaestria.hasMatch(flag)) flagsSimulados.add(flag);
      }
    }
    // Las elecciones: añadimos los flags producibles por opciones.
    for (final escena in CatalogoEscenas.todas) {
      for (final plano in escena.planos) {
        if (plano is PlanoEleccion) {
          for (final opcion in plano.opciones) {
            flagsSimulados.addAll(opcion.flagsAEstablecer);
          }
        }
      }
    }

    final vistas = <String>{};
    var hayProgreso = true;
    while (hayProgreso) {
      hayProgreso = false;
      for (final escena in CatalogoEscenas.todas) {
        if (vistas.contains(escena.id)) continue;
        if (escena.flagsRequeridos.every(flagsSimulados.contains)) {
          vistas.add(escena.id);
          flagsSimulados.add(escena.flagDeSalida);
          hayProgreso = true;
        }
      }
    }

    final inalcanzables = CatalogoEscenas.todas
        .where((e) => !vistas.contains(e.id))
        .map((e) => e.id)
        .toList();
    expect(
      inalcanzables,
      isEmpty,
      reason: 'Hay escenas inalcanzables incluso simulando combates, '
          'maestría, rangos y elecciones: $inalcanzables. Probable '
          'gate dependiendo de un flag que nadie produce.',
    );
  });
}
