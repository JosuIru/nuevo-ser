import 'catalogo_escenas.dart';
import 'desafio_kurz.dart';
import 'escena_cinematica.dart';
import 'variantes_entrenamiento.dart';
import 'variantes_era_dos.dart';
import 'variantes_maquinas.dart';
import 'variantes_puentes.dart';

/// Decisión pura sobre qué pantalla viene después de cerrar la
/// anterior. La capa visual (main.dart) lee la decisión y traduce a
/// `setState` + persistencia. Vivir aquí permite tests unitarios sin
/// montar el widget tree ni simular `SharedPreferences`.
sealed class DecisionOrquestador {
  const DecisionOrquestador();
}

/// Toca un combate jugable contra un Fragmento nombrado.
class CombateKurzPendiente extends DecisionOrquestador {
  final DesafioKurz desafio;
  const CombateKurzPendiente(this.desafio);
}

/// Toca reproducir una escena del catálogo principal.
class CinematicaPendiente extends DecisionOrquestador {
  final EscenaCinematica escena;
  const CinematicaPendiente(this.escena);
}

/// Toca una variante recurrente (entrenamiento, puentes o máquinas).
/// Si [poolReseteado] es `true`, el pool de variantes usadas estaba
/// agotado y la elegida es la primera de un pool reseteado: el caller
/// debe persistir el reset antes de marcar `variante.id` como usada.
class VariantePendiente extends DecisionOrquestador {
  final EscenaCinematica variante;
  final ArcoConVariantes arco;
  final bool poolReseteado;
  const VariantePendiente({
    required this.variante,
    required this.arco,
    required this.poolReseteado,
  });
}

/// No hay nada pendiente — la app debe ir al mapa del distrito.
class IrAlMapa extends DecisionOrquestador {
  const IrAlMapa();
}

/// Identifica de qué arco proviene una variante recurrente, para que
/// el caller sepa qué store de "usadas" persistir. `eraDos` cubre el
/// pool latente que se activa tras cerrar el Arco 4 (escena 4.14).
enum ArcoConVariantes { arco1, arco2, arco3, eraDos }

/// Cada combate jugable se desbloquea por una pareja
/// `(flag-disparador, flag-completado)`. La pareja vive aquí para que
/// cualquier nuevo combate se añada con una sola línea.
class _GateCombate {
  final String flagDisparador;
  final String flagCompletado;
  final DesafioKurz desafio;
  const _GateCombate({
    required this.flagDisparador,
    required this.flagCompletado,
    required this.desafio,
  });
}

class OrquestadorEscenas {
  static const List<_GateCombate> _combatesEnOrden = [
    _GateCombate(
      flagDisparador: 'escena_1_5_vista',
      flagCompletado: 'combate_kurz_1_completado',
      desafio: DesafioKurz.primero,
    ),
    _GateCombate(
      flagDisparador: 'escena_1_10_pre_vista',
      flagCompletado: 'combate_kurz_2_completado',
      desafio: DesafioKurz.segundo,
    ),
    _GateCombate(
      flagDisparador: 'escena_1_12_pre_vista',
      flagCompletado: 'combate_kurz_3_completado',
      desafio: DesafioKurz.tercero,
    ),
    _GateCombate(
      flagDisparador: 'escena_2_12_vista',
      flagCompletado: 'combate_zafran_completado',
      desafio: DesafioKurz.zafran,
    ),
    _GateCombate(
      flagDisparador: 'escena_3_3_vista',
      flagCompletado: 'combate_duel_kai_completado',
      desafio: DesafioKurz.duelKai,
    ),
    _GateCombate(
      flagDisparador: 'escena_4_8_fuego_vista',
      flagCompletado: 'combate_vorax_completado',
      desafio: DesafioKurz.vorax,
    ),
    _GateCombate(
      flagDisparador: 'escena_5_7_vista',
      flagCompletado: 'combate_velo_completado',
      desafio: DesafioKurz.velo,
    ),
  ];

  /// Devuelve el primer combate cuya escena disparadora se ha visto y
  /// cuyo combate aún no se ha completado, en orden narrativo.
  static DesafioKurz? combateKurzPendiente(Set<String> flagsActivos) {
    for (final gate in _combatesEnOrden) {
      if (flagsActivos.contains(gate.flagDisparador) &&
          !flagsActivos.contains(gate.flagCompletado)) {
        return gate.desafio;
      }
    }
    return null;
  }

  /// Decide qué pantalla mostrar a continuación dada una snapshot del
  /// estado del juego. Pura — no toca repositorio, no llama a
  /// `setState`, no persiste nada.
  ///
  /// [varianteYaDisparadaEnEstaTransicion] se usa para no encadenar
  /// dos variantes seguidas en la misma transición de pantalla
  /// (entras al mapa entre una y la siguiente).
  DecisionOrquestador decidir({
    required Set<String> flagsActivos,
    required Set<String> variantesArco1Usadas,
    required Set<String> variantesArco2Usadas,
    required Set<String> variantesArco3Usadas,
    required Set<String> variantesEraDosUsadas,
    required bool varianteYaDisparadaEnEstaTransicion,
  }) {
    // 1. Combate jugable pendiente.
    final combate = combateKurzPendiente(flagsActivos);
    if (combate != null) return CombateKurzPendiente(combate);

    // 2. Escena del catálogo principal cuyos prerrequisitos se cumplan
    //    y que aún no se haya visto.
    for (final escena in CatalogoEscenas.todas) {
      if (flagsActivos.contains(escena.flagDeSalida)) continue;
      if (!escena.flagsRequeridos.every(flagsActivos.contains)) continue;
      return CinematicaPendiente(escena);
    }

    // 3. Variante recurrente del arco más reciente abierto.
    if (!varianteYaDisparadaEnEstaTransicion) {
      final variante = elegirVarianteRecurrente(
        flagsActivos: flagsActivos,
        arco1Usadas: variantesArco1Usadas,
        arco2Usadas: variantesArco2Usadas,
        arco3Usadas: variantesArco3Usadas,
        eraDosUsadas: variantesEraDosUsadas,
      );
      if (variante != null) return variante;
    }

    // 4. Nada pendiente: al mapa.
    return const IrAlMapa();
  }

  /// Elige la siguiente variante recurrente adecuada al arco en curso.
  /// Prioridad por arco más reciente: 3 → 2 → 1. Si el arco activo
  /// tiene su pool agotado, devuelve la primera del pool reseteado y
  /// marca [VariantePendiente.poolReseteado] = true. Devuelve `null`
  /// si ningún arco con variantes está abierto en el estado actual.
  ///
  /// Expuesto para tests — permite verificar la priorización entre
  /// arcos sin construir un escenario completo de catálogo de escenas.
  VariantePendiente? elegirVarianteRecurrente({
    required Set<String> flagsActivos,
    required Set<String> arco1Usadas,
    required Set<String> arco2Usadas,
    required Set<String> arco3Usadas,
    required Set<String> eraDosUsadas,
  }) {
    // Arco 3 — máquinas con Vadic — entre 3.6 y 3.18.
    final arco3Empezado = flagsActivos.contains('escena_3_6_vista');
    final arco3Cerrado = flagsActivos.contains('escena_3_18_vista');
    if (arco3Empezado && !arco3Cerrado) {
      return _elegirVarianteDePool(
        usadas: arco3Usadas,
        elegir: VariantesMaquinas.elegirSiguiente,
        arco: ArcoConVariantes.arco3,
      );
    }

    // Arco 2 — puentes con Rexán — entre 2.3 y 2.16.
    final arco2Empezado = flagsActivos.contains('escena_2_3_vista');
    final arco2Cerrado = flagsActivos.contains('escena_2_16_vista');
    if (arco2Empezado && !arco2Cerrado) {
      return _elegirVarianteDePool(
        usadas: arco2Usadas,
        elegir: VariantesPuentes.elegirSiguiente,
        arco: ArcoConVariantes.arco2,
      );
    }

    // Arco 1 — entrenamiento con Sora — entre 1.7 y 1.14.
    final arco1Empezado = flagsActivos.contains('escena_1_7_vista');
    final arco1Cerrado = flagsActivos.contains('escena_1_14_vista');
    if (arco1Empezado && !arco1Cerrado) {
      return _elegirVarianteDePool(
        usadas: arco1Usadas,
        elegir: VariantesEntrenamiento.elegirSiguiente,
        arco: ArcoConVariantes.arco1,
      );
    }

    // Era 2 — pool latente post-MVP. Activo desde el cierre del Arco 4
    // (4.14 vista) y sin horizonte de cierre: el niño puede recibir
    // estas variantes indefinidamente. Por orden de prioridad cae al
    // final, así que solo entra si los arcos 1/2/3 ya no aplican.
    final arco4Cerrado = flagsActivos.contains('escena_4_14_vista');
    if (arco4Cerrado) {
      return _elegirVarianteDePool(
        usadas: eraDosUsadas,
        elegir: VariantesEraDos.elegirSiguiente,
        arco: ArcoConVariantes.eraDos,
      );
    }

    return null;
  }

  VariantePendiente? _elegirVarianteDePool({
    required Set<String> usadas,
    required EscenaCinematica? Function(Set<String>) elegir,
    required ArcoConVariantes arco,
  }) {
    final primera = elegir(usadas);
    if (primera != null) {
      return VariantePendiente(
        variante: primera,
        arco: arco,
        poolReseteado: false,
      );
    }
    final reseteada = elegir(const {});
    if (reseteada == null) return null;
    return VariantePendiente(
      variante: reseteada,
      arco: arco,
      poolReseteado: true,
    );
  }
}
