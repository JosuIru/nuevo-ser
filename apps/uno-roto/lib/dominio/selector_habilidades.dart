import 'package:nuevo_ser_core/nuevo_ser_core.dart' as core;

import '../datos/catalogo_habilidades.dart';
import 'distrito.dart';
import 'mapeo_habilidades_puzzle.dart';
import 'nivel_escolar.dart';

/// Wrapper específico de Uno Roto sobre [core.SelectorHabilidades].
///
/// Mantiene la API histórica que `pantalla_caza` espera (Distrito +
/// dominioFiltrado) y se encarga de los acoplamientos juego-específicos
/// — catálogo concreto, conjunto de habilidades con puzzle implementado
/// — antes de delegar el algoritmo en la plataforma.
///
/// La pieza algorítmica vive en `packages/nuevo_ser_core/lib/src/mastery/
/// selector_habilidades.dart` con los tests caracterización del repo.
class SelectorHabilidades {
  SelectorHabilidades({
    required this.catalogo,
    required this.cargarEstado,
    int? semilla,
  }) : _selectorCore = core.SelectorHabilidades(
          cargarEstado: cargarEstado,
          semilla: semilla,
        );

  final CatalogoHabilidades catalogo;
  final Future<core.EstadoHabilidad?> Function(String idHabilidad) cargarEstado;
  final core.SelectorHabilidades _selectorCore;

  /// Elige la siguiente habilidad a practicar.
  ///
  /// En modo entrenamiento (`dominioFiltrado != null`) las candidatas se
  /// restringen al dominio elegido (FR/DEC/PROP/…) y la bonificación de
  /// pertenencia al distrito se desactiva — en entrenamiento el niño
  /// elige el dominio explícitamente, el distrito ambiental no manda.
  ///
  /// [rangoActual] es el nombre del rango del niño en formato JSON
  /// (p. ej. `'Aprendiz_II'`, `'Iniciado_I'`). Si no se proporciona,
  /// no se filtra por rango (comportamiento predeterminado).
  ///
  /// Devuelve `null` si el pool tras filtros tiene **menos de 2**
  /// candidatas. Eso garantiza variedad en distritos donde un solo
  /// `required_rank` permitido convertiría el cazadero en monotemático
  /// (el síntoma reportado en Puerto Silencioso 2026-05-19, donde solo
  /// DIV.01 cumplía rango y todos los Fragmentos salían de "múltiplos").
  /// El cazadero detecta el null y cae al reparto por `mezclaPuzzles`
  /// del distrito, que sí da variedad ambiental aunque el motor de
  /// maestría todavía no tenga skills suficientes en rango.
  ///
  /// Con [nivelEscolar] (el punto de partida del niño), se apartan las
  /// habilidades de dos o más cursos por debajo, salvo las que le estén
  /// costando (precisión baja con varios intentos). Si al apartarlas
  /// quedan menos de 2, se usan todas: el distrito sigue teniendo sus
  /// Fragmentos, sólo que más difíciles.
  Future<String?> elegirSiguienteHabilidad({
    required Distrito distrito,
    String? dominioFiltrado,
    String? rangoActual,
    NivelEscolar? nivelEscolar,
  }) async {
    var candidatas = (dominioFiltrado != null
            ? catalogo.delDominio(dominioFiltrado, rangoActual: rangoActual)
            : catalogo.delDistrito(distrito.identificador,
                rangoActual: rangoActual))
        .where((h) => puzzleDisponible(h.identificador))
        .toList();
    if (nivelEscolar != null) {
      final aSuAltura = [
        for (final habilidad in candidatas)
          if (!quedaMuyAtras(habilidad.curso, nivelEscolar) || await _leCuesta(habilidad.identificador))
            habilidad,
      ];
      if (aSuAltura.length >= 2) candidatas = aSuAltura;
    }
    if (candidatas.length < 2) return null;
    return _selectorCore.elegirSiguienteHabilidad(
      candidatas: candidatas,
      contextoBonusId: distrito.identificador,
      aplicarBonusContexto: dominioFiltrado == null,
    );
  }

  /// Una habilidad le cuesta si, tras varios intentos, acierta menos de
  /// la mitad: entonces vuelve a salir aunque sea de un curso anterior.
  Future<bool> _leCuesta(String idHabilidad) async {
    final estado = await cargarEstado(idHabilidad);
    return estado != null && estado.intentosRecientes.length >= 3 && estado.precision < 0.5;
  }
}
