import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/catalogos_generados/catalogo_plagas_apicolas.dart';
import '../../datos/catalogos_generados/flag_revision.dart';
import '../../servicios/cliente_anthropic.dart';

/// Resultado que devuelve el modal cuando el usuario confirma. La
/// pantalla anfitriona usa estos campos para pre-rellenar el formulario
/// de incidencia.
class DatosIncidenciaIA {
  final String tipo;
  final String diagnostico;
  final int? severidad;
  final String notasAuto;

  DatosIncidenciaIA({
    required this.tipo,
    required this.diagnostico,
    this.severidad,
    this.notasAuto = '',
  });
}

/// Botón que aparece en el formulario de incidencia. Sólo se muestra si:
///   1) hay al menos una foto adjunta,
///   2) el usuario tiene clave Anthropic guardada en Ajustes.
///
/// Al pulsarlo lanza la llamada a Claude vision con la primera foto y
/// abre un modal con el diagnóstico. Si el usuario "Aceptar y
/// pre-rellenar", la pantalla anfitriona recibe `DatosIncidenciaIA` y
/// rellena los campos. La revisión humana es **obligatoria**: nunca se
/// rellenan campos sin pasar por el modal.
///
/// **Diagnóstico libre v0.1**: hasta que el catálogo curado de plagas
/// apícolas (F1A-4) tenga validación veterinaria, todo diagnóstico se
/// marca explícitamente como "no validado por catálogo Larrea" en el
/// modal — el apicultor decide si lo acepta.
class BotonIdentificarIA extends StatefulWidget {
  final List<String> rutasFotos;
  final String observacionesUsuario;
  final ValueChanged<DatosIncidenciaIA> alAceptar;

  const BotonIdentificarIA({
    super.key,
    required this.rutasFotos,
    required this.alAceptar,
    this.observacionesUsuario = '',
  });

  @override
  State<BotonIdentificarIA> createState() => _BotonIdentificarIAState();
}

class _BotonIdentificarIAState extends State<BotonIdentificarIA> {
  final _estadoClave = estadoClaveAnthropicApicola;
  bool _comprobando = true;
  bool _hayClave = false;
  bool _ejecutando = false;

  @override
  void initState() {
    super.initState();
    _refrescarClave();
  }

  Future<void> _refrescarClave() async {
    final hay = await _estadoClave.tieneClave();
    if (!mounted) return;
    setState(() {
      _hayClave = hay;
      _comprobando = false;
    });
  }

  Future<void> _ejecutar() async {
    if (widget.rutasFotos.isEmpty) return;
    final clave = await _estadoClave.cargar();
    if (clave == null || clave.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('api.ia_sin_clave_configurada'))),
      );
      return;
    }
    final fichero = File(widget.rutasFotos.first);
    if (!fichero.existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('api.ia_foto_ya_no_existe'))),
      );
      return;
    }
    setState(() => _ejecutando = true);
    final cliente = ClienteAnthropic(clave);
    try {
      final resultado = await cliente.analizarFoto(
        foto: fichero,
        observacionesUsuario: widget.observacionesUsuario,
      );
      if (!mounted) return;
      setState(() => _ejecutando = false);
      final aceptado = await _mostrarModal(resultado);
      if (aceptado != null) {
        widget.alAceptar(aceptado);
      }
    } on ErrorClaude catch (error) {
      if (!mounted) return;
      setState(() => _ejecutando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.mensaje), duration: const Duration(seconds: 6)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _ejecutando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.tf('api.error_inesperado', {'error': e})), duration: const Duration(seconds: 6)),
      );
    }
  }

  Future<DatosIncidenciaIA?> _mostrarModal(ResultadoAnalisisIA r) async {
    return showModalBottomSheet<DatosIncidenciaIA>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ModalResultadoIA(resultado: r),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_comprobando || !_hayClave) {
      return const SizedBox.shrink();
    }
    if (widget.rutasFotos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                SoleraL10n.t('api.ia_adjunta_foto'),
                style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      );
    }
    return FilledButton.tonalIcon(
      icon: _ejecutando
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.auto_awesome),
      onPressed: _ejecutando ? null : _ejecutar,
      label: Text(_ejecutando ? SoleraL10n.t('api.ia_analizando_foto') : SoleraL10n.t('api.ia_identificar')),
    );
  }
}

class _ModalResultadoIA extends StatelessWidget {
  final ResultadoAnalisisIA resultado;
  const _ModalResultadoIA({required this.resultado});

  String _tipoLegible(String tipo) {
    switch (tipo) {
      case 'parasito':
        return SoleraL10n.t('api.ia_tipo_parasito');
      case 'infeccion':
        return SoleraL10n.t('api.ia_tipo_infeccion');
      case 'plaga_fisica':
        return SoleraL10n.t('api.ia_tipo_plaga_fisica');
      case 'depredador':
        return SoleraL10n.t('api.ia_tipo_depredador');
      case 'abiotico':
        return SoleraL10n.t('api.ia_tipo_abiotico');
      default:
        return SoleraL10n.t('api.ia_tipo_indeterminado');
    }
  }

  /// El catálogo de tipos de incidencia del modelo `IncidenciaApicola`
  /// distingue: sanitario / mortalidad / enjambrazon / robo / vespa_velutina
  /// / polilla_cera / otro. Mapeamos la salida de la IA, dando prioridad
  /// al id de la plaga del catálogo (que tiene reglas especiales para los
  /// 3 ids vespa_velutina/polilla_cera/robo).
  String _tipoFormularioParaIncidencia(String tipoIA, PlagaApicola? coincidencia) {
    if (coincidencia != null) {
      return tipoIncidenciaParaBd(coincidencia);
    }
    switch (tipoIA) {
      case 'parasito':
      case 'infeccion':
        return 'sanitario';
      case 'plaga_fisica':
      case 'depredador':
      case 'abiotico':
      case 'indeterminado':
      default:
        return 'otro';
    }
  }

  String _formatearConfianza(double c) {
    final pct = (c * 100).round();
    return '$pct %';
  }

  Color _colorConfianza(double c) {
    if (c >= 0.75) return Colors.green;
    if (c >= 0.45) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final coincidencia = plagaApicolaPorBusquedaFuzzy(
      resultado.nombreComun,
      resultado.nombreCientifico,
    );
    // Banner rojo de declaración obligatoria si la IA o el catálogo lo marca.
    final declaracionObligatoria = resultado.declaracionOficialSugerida ||
        (coincidencia?.declaracionOficial ?? false);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: margenHojaSegura(ctx, const EdgeInsets.all(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(SoleraL10n.t('api.ia_resultado'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (declaracionObligatoria) ...[
              BannerDeclaracionObligatoria(
                texto: SoleraL10n.t('api.ia_declaracion_obligatoria_banner'),
              ),
              const SizedBox(height: 12),
            ],
            BannerCoincidenciaCatalogo(
              coincidencia: _estadoCoincidencia(coincidencia),
              nombreItemCoincidente: coincidencia?.nombreComun,
              mensajeLibre: SoleraL10n.t('api.ia_diagnostico_libre'),
              mensajeProvisional: SoleraL10n.t('api.ia_coincide_provisional'),
              mensajeValidado: SoleraL10n.t('api.ia_coincide_validado'),
            ),
            const SizedBox(height: 16),
            _FilaInfo(etiqueta: SoleraL10n.t('api.nombre_comun'), valor: resultado.nombreComun),
            if (resultado.nombreCientifico.isNotEmpty)
              _FilaInfo(
                  etiqueta: SoleraL10n.t('api.nombre_cientifico'),
                  valor: resultado.nombreCientifico,
                  italica: true),
            _FilaInfo(etiqueta: SoleraL10n.t('api.tipo'), valor: _tipoLegible(resultado.tipo)),
            if (resultado.severidad != null)
              _FilaInfo(etiqueta: SoleraL10n.t('api.severidad'), valor: '${resultado.severidad} / 5'),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(width: 110, child: Text(SoleraL10n.t('api.confianza'), style: const TextStyle(color: Colors.grey))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _colorConfianza(resultado.confianza).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatearConfianza(resultado.confianza),
                    style: TextStyle(
                      color: _colorConfianza(resultado.confianza),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (resultado.advertencia.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        resultado.advertencia,
                        style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (resultado.manejoCultural.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(SoleraL10n.t('api.manejo_cultural_sugerido'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(resultado.manejoCultural, style: const TextStyle(fontSize: 14)),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      SoleraL10n.t('api.ia_sugiere_tu_decides'),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(SoleraL10n.t('api.descartar')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      final notasAuto = StringBuffer()
                        ..write(SoleraL10n.tf('api.ia_nota_diagnostico_sugerido', {
                          'confianza': _formatearConfianza(resultado.confianza),
                        }));
                      if (resultado.nombreCientifico.isNotEmpty) {
                        notasAuto.write(' — ${resultado.nombreCientifico}');
                      }
                      if (resultado.manejoCultural.isNotEmpty) {
                        notasAuto.write('.\n${SoleraL10n.t('api.manejo_cultural_sugerido')}: ${resultado.manejoCultural}');
                      }
                      if (declaracionObligatoria) {
                        notasAuto.write('.\n⚠ ${SoleraL10n.t('api.ia_nota_declaracion_obligatoria')}');
                      }
                      // Si la plaga viene del catálogo usamos su id (estable);
                      // si es texto libre persistimos el nombre común que devolvió la IA.
                      final diagnosticoFinal = coincidencia?.id ?? resultado.nombreComun;
                      Navigator.of(ctx).pop(DatosIncidenciaIA(
                        tipo: _tipoFormularioParaIncidencia(resultado.tipo, coincidencia),
                        diagnostico: diagnosticoFinal,
                        severidad: resultado.severidad,
                        notasAuto: notasAuto.toString(),
                      ));
                    },
                    label: Text(SoleraL10n.t('api.aceptar_y_rellenar')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Mapea la coincidencia local (PlagaApicola?) al estado genérico del
/// banner del core: libre si no coincide, validado si el catálogo está
/// completamente revisado, provisional en otro caso.
CoincidenciaCatalogo _estadoCoincidencia(PlagaApicola? coincidencia) {
  if (coincidencia == null) return CoincidenciaCatalogo.libre;
  if (catalogosCompletamenteRevisados) return CoincidenciaCatalogo.validado;
  return CoincidenciaCatalogo.provisional;
}

class _FilaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool italica;
  const _FilaInfo({required this.etiqueta, required this.valor, this.italica = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(etiqueta, style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                fontStyle: italica ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
