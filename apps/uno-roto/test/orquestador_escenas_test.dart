import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/catalogo_escenas.dart';
import 'package:uno_roto/dominio/desafio_kurz.dart';
import 'package:uno_roto/dominio/orquestador_escenas.dart';

/// Tests del orquestador puro. Sin `SharedPreferences`, sin widgets.
/// Solo flags de entrada → decisión de salida.
///
/// El orquestador es la lógica más sensible del juego: si una escena
/// queda "saltada" o se encadena un combate antes de su prólogo, el
/// niño se pierde. Antes vivía dentro de `_AppEstado` en main.dart y
/// no tenía cobertura.
void main() {
  late OrquestadorEscenas orquestador;

  setUp(() {
    orquestador = OrquestadorEscenas();
  });

  DecisionOrquestador decidir({
    Set<String> flagsActivos = const {},
    Set<String> variantesArco1Usadas = const {},
    Set<String> variantesArco2Usadas = const {},
    Set<String> variantesArco3Usadas = const {},
    Set<String> variantesEraDosUsadas = const {},
    bool varianteYaDisparadaEnEstaTransicion = false,
  }) =>
      orquestador.decidir(
        flagsActivos: flagsActivos,
        variantesArco1Usadas: variantesArco1Usadas,
        variantesArco2Usadas: variantesArco2Usadas,
        variantesArco3Usadas: variantesArco3Usadas,
        variantesEraDosUsadas: variantesEraDosUsadas,
        varianteYaDisparadaEnEstaTransicion:
            varianteYaDisparadaEnEstaTransicion,
      );

  group('combate Kurz pendiente', () {
    test('estado virgen → no hay combate pendiente', () {
      expect(OrquestadorEscenas.combateKurzPendiente({}), isNull);
    });

    test('1.5 vista pero combate kurz_1 sin completar → primero', () {
      expect(
        OrquestadorEscenas.combateKurzPendiente({'escena_1_5_vista'}),
        DesafioKurz.primero,
      );
    });

    test('1.5 + completado → ya no pendiente', () {
      expect(
        OrquestadorEscenas.combateKurzPendiente(
          {'escena_1_5_vista', 'combate_kurz_1_completado'},
        ),
        isNull,
      );
    });

    test('orden narrativo: 1.10pre se evalúa después de 1.5', () {
      // Avanzado a 1.10pre con kurz_1 ya cerrado: toca el segundo.
      expect(
        OrquestadorEscenas.combateKurzPendiente({
          'escena_1_5_vista',
          'combate_kurz_1_completado',
          'escena_1_10_pre_vista',
        }),
        DesafioKurz.segundo,
      );
    });

    test('Zafrán pendiente desde 2.12', () {
      expect(
        OrquestadorEscenas.combateKurzPendiente({'escena_2_12_vista'}),
        DesafioKurz.zafran,
      );
    });

    test('duelo Kai pendiente desde 3.3', () {
      expect(
        OrquestadorEscenas.combateKurzPendiente({'escena_3_3_vista'}),
        DesafioKurz.duelKai,
      );
    });

    test('Vorax pendiente desde 4.8 fuego', () {
      expect(
        OrquestadorEscenas.combateKurzPendiente(
          {'escena_4_8_fuego_vista'},
        ),
        DesafioKurz.vorax,
      );
    });

    test('todos los combates cerrados → null', () {
      expect(
        OrquestadorEscenas.combateKurzPendiente({
          'escena_1_5_vista', 'combate_kurz_1_completado',
          'escena_1_10_pre_vista', 'combate_kurz_2_completado',
          'escena_1_12_pre_vista', 'combate_kurz_3_completado',
          'escena_2_12_vista', 'combate_zafran_completado',
          'escena_3_3_vista', 'combate_duel_kai_completado',
          'escena_4_8_fuego_vista', 'combate_vorax_completado',
        }),
        isNull,
      );
    });
  });

  group('decisión de la siguiente pantalla', () {
    test('estado virgen → la primera escena del catálogo (1.1)', () {
      // La 1.1 no requiere ningún flag previo, así que arrancando con
      // flags vacíos toca esa.
      final primera = CatalogoEscenas.todas.first;
      expect(primera.flagsRequeridos, isEmpty);
      final decision = decidir();
      expect(decision, isA<CinematicaPendiente>());
      final cine = decision as CinematicaPendiente;
      expect(cine.escena.id, primera.id);
    });

    test('combate pendiente gana sobre cinemática pendiente', () {
      // Activamos el flag disparador del primer combate Kurz. El
      // orquestador NO debe mirar el catálogo de escenas; el combate
      // tiene prioridad.
      final decision = decidir(flagsActivos: {'escena_1_5_vista'});
      expect(decision, isA<CombateKurzPendiente>());
      final combate = decision as CombateKurzPendiente;
      expect(combate.desafio, DesafioKurz.primero);
    });

    test('escenas vistas se omiten en busca de la siguiente', () {
      // Marcamos varias escenas como vistas (su flagDeSalida activo).
      // El orquestador debe avanzar a la primera no vista cuyos
      // prerrequisitos se cumplan.
      final flagsHastaUnos = <String>{};
      for (final escena in CatalogoEscenas.todas.take(3)) {
        flagsHastaUnos.add(escena.flagDeSalida);
      }
      final decision = decidir(flagsActivos: flagsHastaUnos);
      // Debe escoger una escena posterior (con flagDeSalida no presente)
      // o, si la siguiente requiere un flag fuera del catálogo (rango,
      // maestría, combate), una variante / mapa. Lo que no debe es
      // devolver una de las 3 ya vistas.
      if (decision is CinematicaPendiente) {
        expect(
          flagsHastaUnos.contains(decision.escena.flagDeSalida),
          isFalse,
        );
      }
    });

    test(
        'catálogo cerrado y arco 4 cerrado → variante recurrente de Era 2',
        () {
      // Cargamos como vistas todas las del catálogo principal y todos
      // los combates cerrados. `escena_4_14_vista` está incluido (es
      // el flagDeSalida del cierre del Arco 4) — eso activa el pool
      // latente de Era 2, que mantiene al niño con contenido aunque
      // la línea principal del MVP haya terminado.
      final flags = <String>{
        for (final e in CatalogoEscenas.todas) e.flagDeSalida,
        'combate_kurz_1_completado',
        'combate_kurz_2_completado',
        'combate_kurz_3_completado',
        'combate_zafran_completado',
        'combate_duel_kai_completado',
        'combate_vorax_completado',
      };
      final decision = decidir(flagsActivos: flags);
      expect(decision, isA<VariantePendiente>(),
          reason: 'Con Arco 4 cerrado, Era 2 sigue ofreciendo variantes.');
      final variante = decision as VariantePendiente;
      expect(variante.arco, ArcoConVariantes.eraDos);
    });

    test('catálogo cerrado + variante ya disparada → al mapa', () {
      // Mismo escenario pero con la variante ya disparada en la
      // transición actual: no se encadenan dos variantes seguidas.
      final flags = <String>{
        for (final e in CatalogoEscenas.todas) e.flagDeSalida,
        'combate_kurz_1_completado',
        'combate_kurz_2_completado',
        'combate_kurz_3_completado',
        'combate_zafran_completado',
        'combate_duel_kai_completado',
        'combate_vorax_completado',
      };
      final decision = decidir(
        flagsActivos: flags,
        varianteYaDisparadaEnEstaTransicion: true,
      );
      expect(decision, isA<IrAlMapa>());
    });
  });

  group('variantes recurrentes', () {
    // No simulamos un catálogo completo (sería frágil ante cambios en
    // la cadena de prerrequisitos entre escenas). Probamos directamente
    // la función pura `elegirVarianteRecurrente` que es donde vive la
    // priorización entre arcos y la semántica del reset de pool.

    test('arco 1 abierto, pool vacío → primera variante (sin reset)', () {
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: const {'escena_1_7_vista'},
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNotNull);
      expect(variante!.arco, ArcoConVariantes.arco1);
      expect(variante.poolReseteado, isFalse);
    });

    test('arco 1 cerrado → ningún arco abierto, devuelve null', () {
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: const {
          'escena_1_7_vista',
          'escena_1_14_vista',
        },
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNull);
    });

    test('pool agotado → reset implícito y poolReseteado=true', () {
      // Los 6 IDs reales del pool del Arco 1 (variantes 1.8a..1.8f
      // del Doc 07 + la del Faro de Azula). Si todos están "usados",
      // el orquestador debe devolver la primera del pool reseteado.
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: const {'escena_1_7_vista'},
        arco1Usadas: const {'1.8a', '1.8b', '1.8c', '1.8d', '1.8e', '1.8f'},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNotNull);
      expect(variante!.poolReseteado, isTrue,
          reason: 'Con todos los IDs usados, debe resetear el pool '
              'y devolver la primera de cero.');
    });

    test('variante ya disparada → decidir suprime variante y va al mapa', () {
      // En `decidir` con varianteYaDisparadaEnEstaTransicion=true,
      // pase lo que pase en la fase de variantes, debe ir al mapa
      // siempre que no haya combate ni cinemática pendiente. Damos un
      // estado mínimo: arco 1 abierto pero variante ya disparada.
      // Necesitamos también que el catálogo NO encuentre cinemática
      // pendiente — para eso, marcamos como vistas todas las que se
      // disparan tras 1.7 vista (1.11 es la principal). Como esto es
      // frágil, sólo verificamos el principio: si hay variante
      // disparable y se suprime, no debe devolver VariantePendiente.
      final decision = decidir(
        flagsActivos: const {
          'escena_1_1_vista', 'escena_1_2_vista', 'escena_1_3_vista',
          'escena_1_4_vista', 'escena_1_5_vista', 'escena_1_6_vista',
          'escena_1_7_vista',
          'combate_kurz_1_completado',
        },
        varianteYaDisparadaEnEstaTransicion: true,
      );
      expect(decision, isNot(isA<VariantePendiente>()),
          reason: 'Con varianteYaDisparada=true, no se debe disparar '
              'una variante aunque el arco esté abierto.');
    });

    // Para verificar la priorización entre arcos en variantes
    // recurrentes no nos interesa simular un catálogo completo (que
    // arrastra dependencias finas entre escenas). Lo que probamos aquí
    // es la función pura `elegirVarianteRecurrente`, que es donde vive
    // toda la decisión de prioridad.

    test('arco 3 prioriza sobre arco 2 y arco 1', () {
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: {
          'escena_1_7_vista',
          'escena_2_3_vista',
          'escena_3_6_vista',
        },
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNotNull);
      expect(variante!.arco, ArcoConVariantes.arco3);
    });

    test('arco 2 prioriza sobre arco 1 cuando arco 3 no está abierto', () {
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: {
          'escena_1_7_vista',
          'escena_2_3_vista',
        },
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNotNull);
      expect(variante!.arco, ArcoConVariantes.arco2);
    });

    test('arco 3 cerrado deja de elegir variantes de máquinas', () {
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: {
          'escena_3_6_vista',
          'escena_3_18_vista', // arco 3 cerrado
        },
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNull,
          reason: 'Sin arcos 1/2 abiertos y arco 3 cerrado, no hay pool '
              'de variantes activo (sin Era 2).');
    });

    test('arco 4 cerrado activa el pool latente de Era 2', () {
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: const {'escena_4_14_vista'},
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNotNull);
      expect(variante!.arco, ArcoConVariantes.eraDos);
      expect(variante.poolReseteado, isFalse);
    });

    test('Era 2 con pool agotado → reset implícito y poolReseteado=true', () {
      // Las 6 IDs reales del pool de Era 2 (variantes E2.a..E2.f). Si
      // todos están "usados", el orquestador debe devolver la primera
      // del pool reseteado.
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: const {'escena_4_14_vista'},
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {'E2.a', 'E2.b', 'E2.c', 'E2.d', 'E2.e', 'E2.f'},
      );
      expect(variante, isNotNull);
      expect(variante!.arco, ArcoConVariantes.eraDos);
      expect(variante.poolReseteado, isTrue);
    });

    test('arcos 1/2/3 abiertos prevalecen sobre Era 2 latente', () {
      // Si por la razón que sea el flag escena_4_14_vista convive con
      // un arco previo aún abierto (no debería ocurrir narrativamente,
      // pero la lógica debe ser robusta), la prioridad sigue siendo el
      // arco más reciente abierto. Era 2 es la red de seguridad final.
      final variante = orquestador.elegirVarianteRecurrente(
        flagsActivos: const {
          'escena_3_6_vista', // arco 3 abierto
          'escena_4_14_vista',
        },
        arco1Usadas: const {},
        arco2Usadas: const {},
        arco3Usadas: const {},
        eraDosUsadas: const {},
      );
      expect(variante, isNotNull);
      expect(variante!.arco, ArcoConVariantes.arco3);
    });
  });

  group('contrato sealed de DecisionOrquestador', () {
    test('switch exhaustivo cubre los 4 subtipos', () {
      // Si en el futuro se añade un subtipo (p. ej. PantallaTransicion),
      // este test forzará a actualizar todos los call-sites.
      final decisiones = <DecisionOrquestador>[
        const CombateKurzPendiente(DesafioKurz.primero),
        CinematicaPendiente(CatalogoEscenas.todas.first),
        VariantePendiente(
          variante: CatalogoEscenas.todas.first,
          arco: ArcoConVariantes.arco1,
          poolReseteado: false,
        ),
        const IrAlMapa(),
      ];
      for (final d in decisiones) {
        // Tipo concreto del switch — el analizador exige que cada caso
        // se cubra; si añades un subtipo nuevo, este código deja de
        // compilar (lo que es justo lo que queremos).
        final etiqueta = switch (d) {
          CombateKurzPendiente() => 'combate',
          CinematicaPendiente() => 'cinematica',
          VariantePendiente() => 'variante',
          IrAlMapa() => 'mapa',
        };
        expect(etiqueta, isNotEmpty);
      }
    });
  });

  group('ritmo de la sesión 1 (doc 16, eje F)', () {
    test('desde estado virgen se llega al combate kurz_1 sin cierres', () {
      // Simula la primera sesión completa: el orquestador encadena
      // decisiones y nosotros hacemos lo que hace main.dart al cerrar
      // cada cinemática (activar su flagDeSalida). El contrato de
      // ritmo del doc 16: el primer combate jugable debe caer en la
      // sesión 1, sin que ningún cierre amable corte la cadena antes.
      // Si alguien añade una escena con esCierreAmable=true (o una
      // puerta de maestría) entre 1.1 y 1.5, este test lo detecta.
      final flags = <String>{};
      var pasos = 0;
      while (pasos < 20) {
        pasos++;
        final decision = decidir(flagsActivos: flags);
        if (decision is CombateKurzPendiente) {
          expect(decision.desafio.identificador, 'kurz_1',
              reason: 'El primer combate de la sesión 1 debe ser kurz_1.');
          return; // Objetivo del test alcanzado.
        }
        expect(decision, isA<CinematicaPendiente>(),
            reason: 'Antes del combate solo debe haber escenas '
                'encadenables (paso $pasos).');
        final escena = (decision as CinematicaPendiente).escena;
        expect(escena.esCierreAmable, isFalse,
            reason: 'La escena ${escena.id} cortaría la sesión 1 antes '
                'del combate con Kurz — el niño se iría sin haber '
                'jugado nada (doc 16, eje F).');
        flags.add(escena.flagDeSalida);
      }
      fail('En 20 pasos no se alcanzó el combate kurz_1 — la cadena '
          'de la sesión 1 está rota o tiene una puerta nueva.');
    });

    test('tras el combate, la 1.6 cierra la sesión de forma amable', () {
      // La secuencia canónica del día 1 termina en la 1.6 (derrota
      // narrada + cierre). Verificamos que tras completar kurz_1 la
      // siguiente decisión es la 1.6 y que ES un cierre amable — el
      // día 1 debe terminar bien, no en una madeja de escenas.
      final flags = <String>{
        'escena_1_1_vista', 'escena_1_2_vista', 'escena_1_3_vista',
        'escena_1_4_vista', 'escena_1_5_vista',
        'combate_kurz_1_completado', 'derrota_kurz_1',
      };
      final decision = decidir(flagsActivos: flags);
      expect(decision, isA<CinematicaPendiente>());
      final escena = (decision as CinematicaPendiente).escena;
      expect(escena.id, '1.6');
      expect(escena.esCierreAmable, isTrue,
          reason: 'La 1.6 es el "hasta mañana" del día 1.');
    });
  });
}
