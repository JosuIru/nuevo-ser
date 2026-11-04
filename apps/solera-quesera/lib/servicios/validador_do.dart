import 'package:nuevo_ser_core/nuevo_ser_core.dart';

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

/// Resultado de validación de un lote contra una DO. Las etiquetas y
/// detalles salen en el idioma elegido (se enseñan en la ficha del lote);
/// los datos del pliego (zona, razas…) son del catálogo y van tal cual.
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
        etiqueta: SoleraL10n.t('ques.do_tipo_de_queso_dentro'),
        correcto: doQueso.tipo_leche.contains(tipoQueso.categoria) ||
            tipoQueso.do_id == doQueso.id,
        detalle: 'DO ${doQueso.nombre}: ${doQueso.tipo_leche} · '
            '${SoleraL10n.t('ques.receta')}: ${tipoQueso.categoria}',
      ));
    }

    // 2. Validar curación mínima
    final curacionMin = doQueso.curacionMinimaDiasInt;
    if (curacionMin > 0) {
      final edadLote = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lote.fechaMs))
          .inDays;
      checks.add(CheckDo(
        etiqueta: SoleraL10n.tf('ques.do_curacion_minima_dias', {'n': curacionMin}),
        correcto: edadLote >= curacionMin || lote.estado != 'lista',
        detalle: edadLote >= curacionMin
            ? SoleraL10n.tf('ques.do_curacion_superada',
                {'edad': edadLote, 'minimo': curacionMin})
            : SoleraL10n.tf('ques.do_curacion_pendiente', {
                'edad': edadLote,
                'minimo': curacionMin,
                'restantes': curacionMin - edadLote,
              }),
      ));
    } else {
      checks.add(CheckDo(
        etiqueta: SoleraL10n.t('ques.curacion_minima'),
        correcto: true,
        detalle: SoleraL10n.t('ques.do_no_especificada_pliego'),
      ));
    }

    // 3. Validar razas
    if (doQueso.razas.isNotEmpty) {
      checks.add(CheckDo(
        etiqueta: SoleraL10n.t('ques.razas_permitidas'),
        correcto: true,
        detalle: SoleraL10n.tf('ques.do_razas_validar',
            {'razas': doQueso.razas.join(', ')}),
      ));
    }

    // 4. Validar ahumado
    checks.add(CheckDo(
      etiqueta: SoleraL10n.t('ques.do_ahumado_permitido'),
      correcto: true,
      detalle: doQueso.ahumado_permitido == 'SÍ'
          ? SoleraL10n.t('ques.do_ahumado_si')
          : SoleraL10n.t('ques.do_ahumado_no'),
    ));

    // 5. Zona geográfica
    checks.add(CheckDo(
      etiqueta: SoleraL10n.t('ques.do_zona_de_produccion'),
      correcto: true,
      detalle: doQueso.zona_geografica,
    ));

    // 6. Organismo de control
    if (doQueso.organismo_control.isNotEmpty) {
      checks.add(CheckDo(
        etiqueta: SoleraL10n.t('ques.do_organismo_de_control'),
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
