import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../estado/clave_anthropic_aceitera.dart';
import '../../servicios/cliente_anthropic.dart';

/// Botón "Identificar plaga con IA" para usar dentro de un formulario.
/// Pide foto + observaciones, llama a Claude Vision, muestra el
/// diagnóstico en un diálogo y, si el usuario lo acepta, llama a
/// [alAceptar] con el resultado para que el formulario rellene los
/// campos pertinentes (típicamente plaga objetivo y/o observaciones).
///
/// Si la clave Anthropic no está configurada, abre la pantalla
/// la pantalla común de la clave directamente.
class BotonDiagnosticarPlagaIa extends StatefulWidget {
  /// Callback ejecutado cuando el usuario pulsa "Aceptar y pre-rellenar"
  /// en el diálogo de diagnóstico. El formulario usa el resultado para
  /// poblar sus campos.
  final void Function(ResultadoDiagnosticoPlaga resultado) alAceptar;

  /// Texto descriptivo opcional para guiar a la IA (síntomas que ve el
  /// usuario, ubicación de la lesión, etc.).
  final String observacionesIniciales;

  const BotonDiagnosticarPlagaIa({
    super.key,
    required this.alAceptar,
    this.observacionesIniciales = '',
  });

  @override
  State<BotonDiagnosticarPlagaIa> createState() =>
      _BotonDiagnosticarPlagaIaState();
}

class _BotonDiagnosticarPlagaIaState extends State<BotonDiagnosticarPlagaIa> {
  final _claveEstado = estadoClaveAnthropicAceitera;
  final _selectorFotos = ImagePicker();
  bool _analizando = false;

  Future<void> _pulsado() async {
    if (!await _claveEstado.tieneClave()) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => construirPantallaClaveAnthropicAceitera()),
      );
      if (!await _claveEstado.tieneClave()) return;
    }
    final foto = await _selectorFotos.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (foto == null) return;
    final observaciones = await _pedirObservaciones();
    if (observaciones == null) return;

    setState(() => _analizando = true);
    try {
      final clave = (await _claveEstado.cargar())!;
      final cliente = ClienteAnthropic(clave);
      final resultado = await cliente.diagnosticarPlaga(
        foto: File(foto.path),
        observacionesUsuario: observaciones,
      );
      if (!mounted) return;
      await _mostrarResultado(resultado);
    } on ErrorClaude catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
              duration: const Duration(seconds: 8),
              content: Text(e.mensaje)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    } finally {
      if (mounted) setState(() => _analizando = false);
    }
  }

  Future<String?> _pedirObservaciones() async {
    final ctrl =
        TextEditingController(text: widget.observacionesIniciales);
    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Observaciones para la IA'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Síntomas, parcela, fecha aproximada… (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Diagnosticar'),
          ),
        ],
      ),
    );
    return resultado;
  }

  Future<void> _mostrarResultado(ResultadoDiagnosticoPlaga r) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Diagnóstico de Claude'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (r.esDeclaracionObligatoria)
                _ChipBanner(
                  icono: Icons.warning,
                  color: Colors.red,
                  texto:
                      'Plaga de declaración obligatoria — avisa al servicio fitosanitario CCAA.',
                ),
              if (r.esDeclaracionObligatoria) const SizedBox(height: 8),
              Text(r.nombreComun,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              if (r.nombreCientifico.isNotEmpty)
                Text(r.nombreCientifico,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black54)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text('Tipo: ${r.tipo}')),
                  const SizedBox(width: 8),
                  if (r.severidad != null)
                    Chip(label: Text('Severidad: ${r.severidad}/5')),
                ],
              ),
              const SizedBox(height: 4),
              Text('Confianza: ${(r.confianza * 100).toStringAsFixed(0)} %'),
              const SizedBox(height: 4),
              if (r.validadoPorCatalogo)
                _ChipBanner(
                  icono: Icons.verified,
                  color: Colors.green,
                  texto:
                      'Coincide con el catálogo (id: ${r.idCatalogo}). '
                      'Catálogo todavía provisional.',
                )
              else
                _ChipBanner(
                  icono: Icons.help_outline,
                  color: Colors.amber,
                  texto:
                      'Diagnóstico libre — no coincide con el catálogo. Contrasta con un técnico.',
                ),
              const SizedBox(height: 12),
              if (r.manejoCultural.isNotEmpty) ...[
                const Text('Manejo cultural sugerido',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(r.manejoCultural),
              ],
              if (r.advertencia.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '⚠ ${r.advertencia}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              widget.alAceptar(r);
              Navigator.of(ctx).pop();
            },
            child: const Text('Aceptar y pre-rellenar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _analizando ? null : _pulsado,
      icon: _analizando
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.auto_awesome),
      label: const Text('Identificar plaga con IA'),
    );
  }
}

class _ChipBanner extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;

  const _ChipBanner({
    required this.icono,
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 12, color: color.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  Color get shade900 => Color.lerp(this, Colors.black, 0.5) ?? this;
}
