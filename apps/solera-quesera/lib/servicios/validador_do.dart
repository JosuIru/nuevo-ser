import '../datos/catalogos_generados/do_quesos.dart';
import '../datos/catalogos_generados/tipos_queso.dart';
import '../modelos/lote_produccion.dart';

// Helpers para DoQueso (getters no incluidos en el archivo generado).
extension _DoQuesoHelpers on DoQueso {
  int get curacionMinimaDiasInt => int.tryParse(curacion_minima_dias) ?? 0;
  List<String> get razas => razas_permitidas
      .split(';')
      .map((r) => r.trim())
      .where((r) => r.isNotEmpty)
      .toList();
}

/// Resultado de validación de un lote contra una DO.
class ResultadoValidacionDo {
  final String doId;
  final String doNombre;
  final bool valido;
  final List<CheckDo> checks;

  const ResultadoValidacionDo({
    required this.doId,
    required this.doNombre,
    required this.valido,
    required this.checks,
  });
}

class CheckDo {
  final String etiqueta;
  final bool correcto;
  final String detalle;

  const CheckDo({
    required this.etiqueta,
    required this.correcto,
    required this.detalle,
  });
}

/// Valida lotes de producción contra los requisitos de una DO.
class ValidadorDo {
  /// Valida un lote contra su DO asociada.
  ResultadoValidacionDo? validar(LoteProduccion lote) {
    if (lote.doId == null || lote.doId!.isEmpty) return null;

    final doQueso = todosDoQuesos.where((d) => d.id == lote.doId).firstOrNull;
    if (doQueso == null) return null;

    final checks = <CheckDo>[];

    // 1. Validar tipo de leche
    final tipoQueso = todosTipoQuesos
        .where((t) => t.id == lote.tipoQuesoId)
        .firstOrNull;
    if (tipoQueso != null) {
      // Si la receta define tipo de leche, comprobamos coherencia
      checks.add(CheckDo(
        etiqueta: 'Tipo de queso dentro de la DO',
        correcto: doQueso.tipo_leche.contains(tipoQueso.categoria) ||
            tipoQueso.do_id == doQueso.id,
        detalle: 'DO ${doQueso.nombre}: ${doQueso.tipo_leche} · '
            'Receta: ${tipoQueso.categoria}',
      ));
    }

    // 2. Validar curación mínima
    final curacionMin = doQueso.curacionMinimaDiasInt;
    if (curacionMin > 0) {
      final edadLote = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lote.fechaMs))
          .inDays;
      checks.add(CheckDo(
        etiqueta: 'Curación mínima (${curacionMin} días)',
        correcto: edadLote >= curacionMin || lote.estado != 'lista',
        detalle: edadLote >= curacionMin
            ? 'Superada: $edadLote días ≥ $curacionMin requeridos'
            : 'Pendiente: $edadLote días < $curacionMin requeridos '
                '(${curacionMin - edadLote} días restantes)',
      ));
    } else {
      checks.add(CheckDo(
        etiqueta: 'Curación mínima',
        correcto: true,
        detalle: 'No especificada en el pliego de condiciones',
      ));
    }

    // 3. Validar razas
    if (doQueso.razas.isNotEmpty) {
      checks.add(CheckDo(
        etiqueta: 'Razas permitidas',
        correcto: true,
        detalle: '${doQueso.razas.join(", ")} (valídalas con tus proveedores)',
      ));
    }

    // 4. Validar ahumado
    checks.add(CheckDo(
      etiqueta: 'Ahumado permitido',
      correcto: true,
      detalle: doQueso.ahumado_permitido == 'SÍ'
          ? 'Permitido (haya, abedul, espino, cerezo, roble)'
          : 'No permitido por el pliego de condiciones',
    ));

    // 5. Zona geográfica
    checks.add(CheckDo(
      etiqueta: 'Zona de producción',
      correcto: true,
      detalle: doQueso.zona_geografica,
    ));

    // 6. Organismo de control
    if (doQueso.organismo_control.isNotEmpty) {
      checks.add(CheckDo(
        etiqueta: 'Organismo de control',
        correcto: true,
        detalle: doQueso.organismo_control,
      ));
    }

    final valido = checks.every((c) => c.correcto);

    return ResultadoValidacionDo(
      doId: doQueso.id,
      doNombre: doQueso.nombre,
      valido: valido,
      checks: checks,
    );
  }
}
