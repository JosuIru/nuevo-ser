import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show ErrorClaude;

import '../../datos/catalogo_cultivos.dart';
import '../../datos/catalogo_plagas.dart';
import '../../servicios/cliente_anthropic.dart';

/// Resultado que devuelve el modal cuando el usuario confirma. La
/// pantalla anfitriona usa estos campos para pre-rellenar el
/// formulario de incidencia.
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

/// Botón que aparece en el formulario de incidencia. Sólo se muestra
/// si:
///   1) hay al menos una foto adjunta,
///   2) el usuario tiene clave Anthropic guardada en Ajustes.
///
/// Al pulsarlo lanza la llamada a Claude vision con la primera foto y
/// abre un modal con el diagnóstico. Si el usuario "Aceptar y
/// pre-rellenar", la pantalla anfitriona recibe `DatosIncidenciaIA` y
/// rellena los campos. La revisión humana es **obligatoria**: nunca
/// se rellenan campos sin pasar por el modal.
class BotonIdentificarIA extends StatefulWidget {
  final List<String> rutasFotos;
  final String cultivoId;
  final String observacionesUsuario;
  final ValueChanged<DatosIncidenciaIA> alAceptar;

  const BotonIdentificarIA({
    super.key,
    required this.rutasFotos,
    required this.cultivoId,
    required this.alAceptar,
    this.observacionesUsuario = '',
  });

  @override
  State<BotonIdentificarIA> createState() => _BotonIdentificarIAState();
}

class _BotonIdentificarIAState extends State<BotonIdentificarIA> {
  final _persistencia = estadoClaveAnthropicAgro;
  bool _comprobando = true;
  bool _hayClave = false;
  bool _ejecutando = false;

  @override
  void initState() {
    super.initState();
    _refrescarClave();
  }

  Future<void> _refrescarClave() async {
    final hay = await _persistencia.tieneClave();
    if (!mounted) return;
    setState(() {
      _hayClave = hay;
      _comprobando = false;
    });
  }

  Future<void> _ejecutar() async {
    if (widget.rutasFotos.isEmpty) return;
    final clave = await _persistencia.cargar();
    if (clave == null || clave.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay clave Anthropic configurada. Ve a Ajustes → Identificación con IA.')),
      );
      return;
    }
    final fichero = File(widget.rutasFotos.first);
    if (!fichero.existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La foto adjunta ya no existe en el dispositivo.')),
      );
      return;
    }
    setState(() => _ejecutando = true);
    final analizador = AnalizadorFotoCultivo(claveApi: clave);
    final cultivo = cultivoPorId(widget.cultivoId);
    try {
      final resultado = await analizador.analizarFoto(
        foto: fichero,
        cultivoContexto: cultivo,
        observacionesUsuario: widget.observacionesUsuario,
      );
      if (!mounted) return;
      setState(() => _ejecutando = false);
      final aceptado = await _mostrarModal(resultado);
      if (aceptado != null) {
        widget.alAceptar(aceptado);
      }
    } on ErrorClaude catch (e) {
      if (!mounted) return;
      setState(() => _ejecutando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje), duration: const Duration(seconds: 6)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _ejecutando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e'), duration: const Duration(seconds: 6)),
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
                'Adjunta una foto para activar la identificación con IA.',
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
      label: Text(_ejecutando ? 'Analizando foto…' : 'Identificar con IA'),
    );
  }
}

class _ModalResultadoIA extends StatelessWidget {
  final ResultadoAnalisisIA resultado;
  const _ModalResultadoIA({required this.resultado});

  String _tipoLegible(String tipo) {
    switch (tipo) {
      case 'plaga':
        return 'Plaga';
      case 'enfermedad':
        return 'Enfermedad';
      case 'fisiologico':
        return 'Trastorno fisiológico';
      case 'abiotico':
        return 'Abiótico';
      default:
        return 'Indeterminado';
    }
  }

  /// El catálogo de la app sólo distingue plaga/enfermedad/estres/
  /// fisiologico/otro. La IA puede devolver además "abiotico" e
  /// "indeterminado": los mapeamos a "otro" para no romper el
  /// dropdown del formulario.
  String _tipoFormularioParaIncidencia(String tipoIA) {
    switch (tipoIA) {
      case 'plaga':
      case 'enfermedad':
      case 'fisiologico':
        return tipoIA;
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
    final coincide = resultado.coincidenciaCatalogo != null;
    Plaga? plagaCatalogo;
    if (coincide) {
      for (final p in catalogoPlagas) {
        if (p.id == resultado.coincidenciaCatalogo) {
          plagaCatalogo = p;
          break;
        }
      }
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
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
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text('Resultado de la IA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (coincide)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plagaCatalogo != null
                            ? 'Diagnóstico coincide con catálogo Solera: ${plagaCatalogo.nombreComun}'
                            : 'Diagnóstico coincide con catálogo Solera',
                        style: TextStyle(fontSize: 13, color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Diagnóstico libre — no coincide con el catálogo curado de Solera. Revisa con criterio antes de aceptar.',
                        style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _FilaInfo(etiqueta: 'Nombre común', valor: resultado.nombreComun),
            if (resultado.nombreCientifico.isNotEmpty)
              _FilaInfo(etiqueta: 'Nombre científico', valor: resultado.nombreCientifico, italica: true),
            _FilaInfo(etiqueta: 'Tipo', valor: _tipoLegible(resultado.tipo)),
            if (resultado.severidad != null)
              _FilaInfo(etiqueta: 'Severidad', valor: '${resultado.severidad} / 5'),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 110, child: Text('Confianza', style: TextStyle(color: Colors.grey))),
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
              const Text('Manejo cultural sugerido',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              // El sheet hereda el fondo del tema (claro en light, oscuro
              // en dark), pero el modal `showModalBottomSheet` puede
              // pintar fondo claro fijo en algunos temas y dejar el
              // texto blanco-en-blanco. Pintamos el manejo en un
              // recuadro verde claro con color de texto fijo.
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  resultado.manejoCultural,
                  style: TextStyle(fontSize: 14, color: Colors.green.shade900),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.gavel, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La IA sugiere — tú decides. Antes de aplicar productos fitosanitarios, consulta a tu técnico de cooperativa o ATRIA. Solera no recomienda productos comerciales en v1.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
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
                    child: const Text('Descartar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      final notasAuto = StringBuffer()
                        ..write('Diagnóstico sugerido por Claude AI')
                        ..write(' (confianza ${_formatearConfianza(resultado.confianza)})');
                      if (resultado.nombreCientifico.isNotEmpty) {
                        notasAuto.write(' — ${resultado.nombreCientifico}');
                      }
                      if (resultado.manejoCultural.isNotEmpty) {
                        notasAuto.write('.\nManejo cultural sugerido: ${resultado.manejoCultural}');
                      }
                      Navigator.of(ctx).pop(DatosIncidenciaIA(
                        tipo: _tipoFormularioParaIncidencia(resultado.tipo),
                        diagnostico: resultado.nombreComun,
                        severidad: resultado.severidad,
                        notasAuto: notasAuto.toString(),
                      ));
                    },
                    label: const Text('Aceptar y pre-rellenar'),
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
