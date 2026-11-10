import 'package:flutter/material.dart';

import '../utiles/textos_visibles.dart';

import '../datos/base_datos.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/parcela.dart';
import '../modelos/tercero.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Alta de un apunte de ingreso. Autocálculo de IVA repercutido y
/// compensación REAGP según la configuración fiscal y el tipo de
/// ingreso elegido — el usuario puede sobrescribir cualquier valor
/// manualmente antes de guardar.
class PantallaNuevoIngreso extends StatefulWidget {
  const PantallaNuevoIngreso({super.key});

  @override
  State<PantallaNuevoIngreso> createState() => _PantallaNuevoIngresoState();
}

class _PantallaNuevoIngresoState extends State<PantallaNuevoIngreso> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoCtrl = TextEditingController();
  final _baseCtrl = TextEditingController();
  final _ivaCtrl = TextEditingController(text: '0');
  final _compensacionCtrl = TextEditingController(text: '0');
  final _cantidadCtrl = TextEditingController();
  final _facturaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  ConfiguracionFiscal _configuracion = ConfiguracionFiscal();
  List<Tercero> _terceros = const [];
  List<Parcela> _parcelas = const [];

  DateTime _fecha = DateTime.now();
  String _tipoIngreso = 'venta_aceituna';
  String _unidad = 'kg';
  Tercero? _terceroSeleccionado;
  Parcela? _parcelaSeleccionada;
  bool _cargando = true;
  bool _guardando = false;


  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final cfg = await bd.obtenerConfiguracionFiscal();
    final terceros = await bd.listarTerceros(tipo: 'cliente');
    final parcelas = await bd.listarParcelas();
    if (!mounted) return;
    setState(() {
      _configuracion = cfg;
      _terceros = terceros;
      _parcelas = parcelas;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    _conceptoCtrl.dispose();
    _baseCtrl.dispose();
    _ivaCtrl.dispose();
    _compensacionCtrl.dispose();
    _cantidadCtrl.dispose();
    _facturaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  /// Calcula IVA + compensación REAGP a partir de la base según el
  /// tipo de ingreso y la configuración fiscal. No se llama
  /// automáticamente en cada keystroke para no sorprender al
  /// usuario — sólo cuando pulsa "Recalcular" o cambia el tipo.
  void _autocalcular() {
    final baseCent = centimosDesdeTexto(_baseCtrl.text) ?? 0;
    int iva = 0;
    int comp = 0;
    switch (_tipoIngreso) {
      case 'venta_aceituna':
        iva = (baseCent * _configuracion.tipoIvaVentaAceituna).round();
        comp =
            (baseCent * _configuracion.tipoCompensacionReagpAceituna).round();
        break;
      case 'venta_aceite_envasado':
        iva = (baseCent * _configuracion.tipoIvaVentaAceiteEnvasado).round();
        break;
      case 'venta_aceite_granel':
        iva = (baseCent * _configuracion.tipoIvaVentaAceiteGranel).round();
        break;
      case 'alquiler_terreno':
        iva = (baseCent * _configuracion.tipoIvaAlquilerTerreno).round();
        break;
      case 'subproducto_alperujo':
        iva = (baseCent * 0.10).round();
        break;
      case 'ayuda_pac':
      case 'subvencion_autonomica':
        iva = 0;
        comp = 0;
        break;
    }
    setState(() {
      // Con coma decimal, como lo escribiría la persona.
      _ivaCtrl.text = (iva / 100).toStringAsFixed(2).replaceAll('.', ',');
      _compensacionCtrl.text =
          (comp / 100).toStringAsFixed(2).replaceAll('.', ',');
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final apunte = ApunteIngreso(
      fechaMs: _fecha.millisecondsSinceEpoch,
      concepto: _conceptoCtrl.text.trim(),
      tipoIngreso: _tipoIngreso,
      importeBaseCentimos: centimosDesdeTexto(_baseCtrl.text) ?? 0,
      ivaRepercutidoCentimos: centimosDesdeTexto(_ivaCtrl.text) ?? 0,
      compensacionReagpCentimos:
          centimosDesdeTexto(_compensacionCtrl.text) ?? 0,
      cantidad: leerNumero(_cantidadCtrl.text, nullSiAmbiguo: true),
      unidad: _unidad,
      terceroId: _terceroSeleccionado?.id,
      parcelaId: _parcelaSeleccionada?.id,
      numeroFactura: _facturaCtrl.text.trim(),
      notas: _notasCtrl.text.trim(),
    );
    await BaseDatosSoleraAceitera().insertarApunteIngreso(apunte);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _seleccionarFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(_fecha.year - 10),
      lastDate: DateTime(_fecha.year + 2),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acei.nuevo_ingreso'))),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: textoOGuardando(SoleraL10n.t('acei.guardar_ingreso'),
              guardando: _guardando),
        ),
      ]),
      body: Form(
        key: _formKey,
        child: CuerpoResponsivoSolera(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                  SoleraL10n.tf('acei.fecha_valor', {'fecha': '${_fecha.day}/${_fecha.month}/${_fecha.year}'})),
              trailing: TextButton(
                onPressed: _seleccionarFecha,
                child: Text(SoleraL10n.t('acei.cambiar')),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _tipoIngreso,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.tipo_de_ingreso'),
                border: OutlineInputBorder(),
              ),
              items: tiposIngresoAceitera
                  .map((tipo) => DropdownMenuItem(
                      value: tipo, child: Text(nombreTipoIngreso(tipo))))
                  .toList(),
              onChanged: (v) {
                setState(() => _tipoIngreso = v ?? 'venta_aceituna');
                _autocalcular();
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _conceptoCtrl,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.concepto'),
                hintText: SoleraL10n.t('acei.ejemplo_concepto_ingreso'),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? SoleraL10n.t('acei.obligatorio') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _baseCtrl,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.importe_base_sin_iva'),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = centimosDesdeTexto(v ?? '');
                if (n == null || n < 0) return SoleraL10n.t('acei.importe_no_valido_corto');
                return null;
              },
            ),
            const SizedBox(height: separacionCamposSolera),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ivaCtrl,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('acei.iva_repercutido_euros'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: validarImporteOpcional,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _compensacionCtrl,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('acei.compensacion_reagp_euros'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: validarImporteOpcional,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _autocalcular,
              icon: const Icon(Icons.calculate),
              label: Text(SoleraL10n.t('acei.recalcular_iva_compensacion')),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cantidadCtrl,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('acei.cantidad'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        validarNumeroOpcional(v, nullSiAmbiguo: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _unidad,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('acei.unidad'),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'tn', child: Text('tn')),
                      DropdownMenuItem(value: 'l', child: Text('l')),
                      DropdownMenuItem(value: 'hl', child: Text('hl')),
                      DropdownMenuItem(
                          value: SoleraL10n.t('acei.unidad_botellas'), child: Text(SoleraL10n.t('acei.unidad_botellas'))),
                      DropdownMenuItem(value: 'ha', child: Text('ha')),
                      DropdownMenuItem(value: '', child: Text('—')),
                    ],
                    onChanged: (v) => setState(() => _unidad = v ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Tercero?>(
              isExpanded: true,
              initialValue: _terceroSeleccionado,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.cliente_opcional'),
                border: OutlineInputBorder(),
                helperText: SoleraL10n.t('acei.sin_tercero_modelo_347'),
              ),
              items: [
                DropdownMenuItem<Tercero?>(
                  value: null,
                  child: Text(SoleraL10n.t('acei.sin_tercero')),
                ),
                for (final t in _terceros)
                  DropdownMenuItem<Tercero?>(
                    value: t,
                    child:
                        Text(t.nombre.isEmpty ? SoleraL10n.t('acei.sin_nombre') : t.nombre),
                  ),
              ],
              onChanged: (v) => setState(() => _terceroSeleccionado = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Parcela?>(
              isExpanded: true,
              initialValue: _parcelaSeleccionada,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.parcela_opcional'),
                border: OutlineInputBorder(),
                helperText:
                    SoleraL10n.t('acei.imputar_ingreso_parcela'),
              ),
              items: [
                DropdownMenuItem<Parcela?>(
                  value: null,
                  child: Text(SoleraL10n.t('acei.general_sin_imputar')),
                ),
                for (final p in _parcelas)
                  DropdownMenuItem<Parcela?>(
                    value: p,
                    child: Text(
                        p.nombre.isEmpty ? SoleraL10n.tf('acei.parcela_numero', {'id': p.id}) : p.nombre),
                  ),
              ],
              onChanged: (v) => setState(() => _parcelaSeleccionada = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _facturaCtrl,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.numero_de_factura'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notasCtrl,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.notas'),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        )),
      ),
    );
  }
}
