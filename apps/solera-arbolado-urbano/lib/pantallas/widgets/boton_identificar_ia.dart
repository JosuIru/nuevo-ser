import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/catalogos_generados/catalogo_plagas_urbanas.dart';
import '../../datos/catalogos_generados/flag_revision.dart';
import '../../servicios/cliente_anthropic.dart';

/// Resultado que devuelve el modal cuando el usuario confirma. La
/// pantalla anfitriona usa estos campos para pre-rellenar el formulario
/// de incidencia / tratamiento.
class DatosIncidenciaIA {
  final String tipoIncidencia;
  final String descripcion;
  final int? severidad;
  final String notasAuto;

  DatosIncidenciaIA({
    required this.tipoIncidencia,
    required this.descripcion,
    this.severidad,
    this.notasAuto = '',
  });
}

/// Botón que aparece en el formulario de incidencia. Sólo se muestra si:
///   1) hay al menos una foto adjunta,
///   2) el operario tiene clave Anthropic guardada en Ajustes.
///
/// Al pulsarlo lanza la llamada a Claude vision en modo "diagnosticar
/// plaga" con la primera foto. Modal con diagnóstico, banner rojo
/// automático si la IA marca declaración obligatoria o riesgo sanitario.
/// La revisión humana es **obligatoria** — nunca se rellenan campos sin
/// pasar por el modal.
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
  final _persistencia = estadoClaveAnthropic;
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
        const SnackBar(content: Text('No hay clave de Anthropic configurada. Ve a Ajustes → Identificación con IA.')),
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
    final cliente = ClienteAnthropic(clave);
    try {
      final resultado = await cliente.analizarFoto(
        foto: fichero,
        modo: ModoAnalisisIA.diagnosticarPlaga,
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
    } on ErrorIA catch (e) {
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

  String _formatearConfianza(double c) => '${(c * 100).round()} %';

  Color _colorConfianza(double c) {
    if (c >= 0.75) return Colors.green;
    if (c >= 0.45) return Colors.orange;
    return Colors.red;
  }

  /// El enum `tipo` de `Incidencia` distingue golpe_vehiculo / vandalismo
  /// / temporal / alcorque_danado / raices_acera / riesgo_caida / otro.
  /// Los diagnósticos sanitarios que devuelve la IA (insectos, hongos,
  /// abióticos…) no encajan en ninguna categoría salvo `otro` — la
  /// notación específica vive en la descripción y notas.
  static const _tipoIncidenciaPorDefecto = 'otro';

  @override
  Widget build(BuildContext context) {
    final coincidencia = plagaUrbanaPorBusquedaFuzzy(
      resultado.plagaNombreComun,
      resultado.plagaNombreCientifico,
    );
    final declaracionObligatoria = resultado.declaracionOficialSugerida ||
        (coincidencia?.declaracionOficial ?? false);
    final riesgoSanitario = resultado.riesgoSanitarioPublicoSugerido ||
        (coincidencia?.riesgoSanitarioPublico ?? false);
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
            if (declaracionObligatoria) ...[
              const BannerDeclaracionObligatoria(
                texto:
                    'PLAGA DE DECLARACIÓN OBLIGATORIA. Si confirmas el diagnóstico, debes notificarlo a los Servicios Fitosanitarios oficiales de tu CCAA.',
              ),
              const SizedBox(height: 12),
            ],
            if (riesgoSanitario) ...[
              const BannerRiesgoSanitarioPublico(),
              const SizedBox(height: 12),
            ],
            BannerCoincidenciaCatalogo(
              coincidencia: _estadoCoincidencia(coincidencia),
              nombreItemCoincidente: coincidencia?.nombreComun,
              mensajeLibre:
                  'Diagnóstico libre — no coincide con el catálogo curado de Larrea Arbolado Urbano. Revisa con criterio antes de aceptar.',
              mensajeProvisional:
                  'Coincide con catálogo provisional. El catálogo aún no ha sido validado por ingeniero técnico forestal — usa criterio.',
              mensajeValidado: 'Diagnóstico coincide con catálogo Larrea',
            ),
            const SizedBox(height: 16),
            _FilaInfo(etiqueta: 'Nombre común', valor: resultado.plagaNombreComun),
            if (resultado.plagaNombreCientifico.isNotEmpty)
              _FilaInfo(
                  etiqueta: 'Nombre científico',
                  valor: resultado.plagaNombreCientifico,
                  italica: true),
            _FilaInfo(etiqueta: 'Tipo', valor: resultado.tipoPlaga),
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
              Text(resultado.manejoCultural, style: const TextStyle(fontSize: 14)),
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
                      'La IA sugiere — tú decides. Antes de aplicar fitosanitarios, '
                      'consulta los pliegos técnicos de tu ayuntamiento y el carnet '
                      'de aplicador requerido. Larrea Arbolado Urbano no recomienda '
                      'productos comerciales en v0.1.',
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
                      if (resultado.plagaNombreCientifico.isNotEmpty) {
                        notasAuto.write(' — ${resultado.plagaNombreCientifico}');
                      }
                      if (resultado.manejoCultural.isNotEmpty) {
                        notasAuto.write('.\nManejo cultural sugerido: ${resultado.manejoCultural}');
                      }
                      if (declaracionObligatoria) {
                        notasAuto.write(
                            '.\n⚠ Plaga de DECLARACIÓN OBLIGATORIA — notificar a Servicios Fitosanitarios.');
                      }
                      if (riesgoSanitario) {
                        notasAuto.write(
                            '.\n⚠ RIESGO SANITARIO PÚBLICO — vigilar zona escolar/peatonal.');
                      }
                      Navigator.of(ctx).pop(DatosIncidenciaIA(
                        tipoIncidencia: _tipoIncidenciaPorDefecto,
                        descripcion: resultado.plagaNombreComun,
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

/// Mapea la coincidencia local (PlagaUrbana?) al estado genérico del
/// banner del core: libre si no coincide, validado si el catálogo está
/// completamente revisado, provisional en otro caso.
CoincidenciaCatalogo _estadoCoincidencia(PlagaUrbana? coincidencia) {
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
