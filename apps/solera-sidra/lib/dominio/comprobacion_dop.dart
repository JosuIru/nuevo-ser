import '../datos/catalogos_generados/catalogo_dop_sidra_txakoli.dart';
import '../modelos/kupela.dart';
import '../modelos/prensado.dart';

/// Un aviso al comparar lo apuntado con el pliego. **No es una
/// calificación**: la hace el órgano de control con su análisis.
class AvisoDop {
  const AvisoDop(this.codigo, this.valor, this.limite);

  /// `acidez_volatil_alta`, `grado_bajo`, `sulfuroso_alto`,
  /// `densidad_mosto_baja`, `rendimiento_alto`, `rendimiento_bajo`.
  /// El texto visible sale de `sidr.aviso_<codigo>`.
  final String codigo;
  final double valor;
  final double limite;

  @override
  bool operator ==(Object other) =>
      other is AvisoDop &&
      other.codigo == codigo &&
      other.valor == valor &&
      other.limite == limite;

  @override
  int get hashCode => Object.hash(codigo, valor, limite);

  @override
  String toString() => 'AvisoDop($codigo, $valor, $limite)';
}

/// Compara una medición con los límites del producto. El grado mínimo solo
/// se mira si la medición lo trae (durante la fermentación sube).
List<AvisoDop> avisosMedicion(MedicionKupela medicion, ProductoDop producto) {
  final avisos = <AvisoDop>[];
  final acidez = medicion.acidezVolatilGL;
  final maximoAcidez = producto.acidezVolatilMaxGL;
  if (acidez != null && maximoAcidez != null && acidez >= maximoAcidez) {
    avisos.add(AvisoDop('acidez_volatil_alta', acidez, maximoAcidez));
  }
  final grado = medicion.gradoAlcoholico;
  final minimoGrado = producto.gradoMin;
  if (grado != null && minimoGrado != null && grado <= minimoGrado) {
    avisos.add(AvisoDop('grado_bajo', grado, minimoGrado));
  }
  final sulfuroso = medicion.sulfurosoTotalMgL;
  final maximoSulfuroso = producto.sulfurosoTotalMaxMgL;
  if (sulfuroso != null &&
      maximoSulfuroso != null &&
      sulfuroso >= maximoSulfuroso) {
    avisos.add(AvisoDop('sulfuroso_alto', sulfuroso, maximoSulfuroso));
  }
  return avisos;
}

/// Compara un prensado con el pliego: densidad natural mínima del mosto y
/// rendimiento (límite o rango habitual, según el pliego).
List<AvisoDop> avisosPrensado(Prensado prensado, ProductoDop producto) {
  final avisos = <AvisoDop>[];
  final densidad = prensado.densidadMosto;
  final minimaDensidad = producto.densidadMostoMin;
  if (densidad != null && minimaDensidad != null && densidad < minimaDensidad) {
    avisos.add(AvisoDop('densidad_mosto_baja', densidad, minimaDensidad));
  }
  final rendimiento = prensado.rendimientoPorcentaje;
  if (rendimiento != null) {
    final maximo = producto.rendimientoMaxPct;
    final minimo = producto.rendimientoMinPct;
    if (maximo != null && rendimiento > maximo) {
      avisos.add(AvisoDop('rendimiento_alto', rendimiento, maximo));
    }
    if (minimo != null && rendimiento < minimo) {
      avisos.add(AvisoDop('rendimiento_bajo', rendimiento, minimo));
    }
  }
  return avisos;
}
