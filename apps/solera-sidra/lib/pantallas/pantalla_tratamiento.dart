import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/catalogos_generados/catalogo_plagas_manzano.dart';
import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';

/// Apunte de un tratamiento ya hecho, para el cuaderno de la pomarada.
/// **No recomienda**: la sustancia se elige de las que tienen uso autorizado
/// contra la plaga, y el n.º de registro y la cantidad se copian de lo que
/// se aplicó.
class PantallaEditarTratamiento extends StatefulWidget {
  const PantallaEditarTratamiento({
    super.key,
    required this.pomaradaId,
    this.tratamiento,
    this.plagaInicial,
  });

  final int pomaradaId;
  final Tratamiento? tratamiento;

  /// Plaga propuesta (p. ej. por la IA); la persona puede cambiarla.
  final String? plagaInicial;

  @override
  State<PantallaEditarTratamiento> createState() =>
      _PantallaEditarTratamientoState();
}

class _PantallaEditarTratamientoState extends State<PantallaEditarTratamiento> {
  late final Tratamiento? _original = widget.tratamiento;
  late int _fechaMs =
      _original?.fechaMs ?? DateTime.now().millisecondsSinceEpoch;
  late String _plaga = _original?.plagaObjetivoId ?? widget.plagaInicial ?? '';
  late String _sustancia = _original?.sustanciaActivaId ?? '';
  late String _eficacia = _original?.eficacia ?? '';
  late final _registro =
      TextEditingController(text: _original?.numeroRegistroProducto);
  late final _cantidad =
      TextEditingController(text: _original?.cantidadAplicada);
  late final _superficie = TextEditingController(
      text: _original?.superficieTratadaHa == null
          ? ''
          : formatearNumero(_original!.superficieTratadaHa!, decimales: 2));
  late final _aplicador = TextEditingController(text: _original?.aplicador);
  late final _carnet = TextEditingController(text: _original?.carnetAplicador);
  late final _notas = TextEditingController(text: _original?.notas);

  @override
  void dispose() {
    for (final controlador in [
      _registro,
      _cantidad,
      _superficie,
      _aplicador,
      _carnet,
      _notas,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    await BaseDatosSoleraSidra.instancia.guardarTratamiento(Tratamiento(
      id: _original?.id,
      pomaradaId: widget.pomaradaId,
      fechaMs: _fechaMs,
      sustanciaActivaId: _sustancia,
      numeroRegistroProducto: _registro.text.trim(),
      cantidadAplicada: _cantidad.text.trim(),
      plagaObjetivoId: _plaga,
      superficieTratadaHa: leerNumero(_superficie.text),
      aplicador: _aplicador.text.trim(),
      carnetAplicador: _carnet.text.trim(),
      eficacia: _eficacia,
      notas: _notas.text.trim(),
    ));
    avisarCambioDatos();
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _borrar() async {
    await BaseDatosSoleraSidra.instancia.borrarTratamiento(_original!.id!);
    avisarCambioDatos();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final sustancias = sustanciasParaPlaga(_plaga);
    final elegida = sustanciaPorId(_sustancia);
    if (elegida != null &&
        !sustancias.any((sustancia) => sustancia.id == _sustancia)) {
      // Sustancia elegida para otra plaga: se conserva en la lista.
      sustancias.insert(0, elegida);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t(_original == null
            ? 'sidr.nuevo_tratamiento'
            : 'sidr.editar_tratamiento')),
        actions: [
          if (_original != null)
            IconButton(
              tooltip: SoleraL10n.t('borrar'),
              icon: const Icon(Icons.delete_outline),
              onPressed: _borrar,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SelectorFecha(
            etiqueta: SoleraL10n.t('sidr.fecha'),
            fechaMs: _fechaMs,
            alCambiar: (fecha) => setState(() => _fechaMs = fecha ?? _fechaMs),
          ),
          campoDesplegable<String>(
            etiqueta: SoleraL10n.t('sidr.plaga_objetivo'),
            valor: _plaga,
            opciones: [
              ('', SoleraL10n.t('sidr.preventivo')),
              for (final PlagaManzano plaga in catalogoPlagasManzano)
                (plaga.id, plaga.nombre),
            ],
            alCambiar: (valor) => setState(() => _plaga = valor ?? ''),
          ),
          if (plagaPorId(_plaga)?.organismoRegulado == true)
            TarjetaAviso(SoleraL10n.t('sidr.organismo_regulado_aviso'),
                icono: Icons.report_outlined),
          campoDesplegable<String>(
            key: ValueKey('sustancia-$_plaga'),
            etiqueta: SoleraL10n.t('sidr.sustancia_activa'),
            valor: sustancias.any((sustancia) => sustancia.id == _sustancia)
                ? _sustancia
                : null,
            opciones: [
              for (final sustancia in sustancias)
                (sustancia.id, sustancia.nombre),
            ],
            alCambiar: (valor) => setState(() => _sustancia = valor ?? ''),
          ),
          if (elegida != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                SoleraL10n.tf('sidr.sustancia_resumen', {
                  'ps': elegida.plazoSeguridadMaxDias == null
                      ? SoleraL10n.t('sidr.no_procede')
                      : '${elegida.plazoSeguridadMaxDias}',
                  'ue': elegida.aprobadaUeHasta,
                }),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          campoTexto(_registro, SoleraL10n.t('sidr.numero_registro'),
              ayuda: SoleraL10n.t('sidr.numero_registro_ayuda')),
          campoTexto(_cantidad, SoleraL10n.t('sidr.cantidad_aplicada'),
              ayuda: SoleraL10n.t('sidr.cantidad_aplicada_ayuda')),
          campoNumero(_superficie, SoleraL10n.t('sidr.superficie_tratada'),
              sufijo: 'ha'),
          campoTexto(_aplicador, SoleraL10n.t('sidr.aplicador')),
          campoTexto(_carnet, SoleraL10n.t('sidr.carnet_aplicador')),
          campoDesplegable<String>(
            etiqueta: SoleraL10n.t('sidr.eficacia'),
            valor: _eficacia,
            opciones: [
              for (final eficacia in eficaciasTratamiento)
                (eficacia, nombreValor('eficacia', eficacia)),
            ],
            alCambiar: (valor) => setState(() => _eficacia = valor ?? ''),
          ),
          campoTexto(_notas, SoleraL10n.t('sidr.notas')),
          const SizedBox(height: 8),
          Text(SoleraL10n.t('sidr.aviso_no_recomienda'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
