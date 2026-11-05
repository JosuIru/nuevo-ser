import 'package:flutter/material.dart';

import '../utiles/textos_visibles.dart';

import '../datos/base_datos.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/parcela.dart';
import '../modelos/tercero.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Alta de un apunte de gasto. Tipos olivar específicos y selector
/// de imputación a parcela/variedad/general. El IVA soportado se
/// introduce manualmente — la regulación de tipos en gastos agrícolas
/// es heterogénea (4% insumos, 21% maquinaria, 10% transporte, 0%
/// mano de obra) y no compensa autocalcular: el usuario lo lee de
/// la factura.
class PantallaNuevoGasto extends StatefulWidget {
  const PantallaNuevoGasto({super.key});

  @override
  State<PantallaNuevoGasto> createState() => _PantallaNuevoGastoState();
}

class _PantallaNuevoGastoState extends State<PantallaNuevoGasto> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoCtrl = TextEditingController();
  final _baseCtrl = TextEditingController();
  final _ivaCtrl = TextEditingController(text: '0');
  final _facturaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  List<Tercero> _terceros = const [];
  List<Parcela> _parcelas = const [];

  DateTime _fecha = DateTime.now();
  String _tipoGasto = 'insumos_olivar';
  String _imputacion = 'general';
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
    final terceros = await bd.listarTerceros(tipo: 'proveedor');
    final parcelas = await bd.listarParcelas();
    if (!mounted) return;
    setState(() {
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
    _facturaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final apunte = ApunteGasto(
      fechaMs: _fecha.millisecondsSinceEpoch,
      concepto: _conceptoCtrl.text.trim(),
      tipoGasto: _tipoGasto,
      importeBaseCentimos: centimosDesdeTexto(_baseCtrl.text) ?? 0,
      ivaSoportadoCentimos: centimosDesdeTexto(_ivaCtrl.text) ?? 0,
      imputacion: _imputacion,
      parcelaId:
          _imputacion == 'parcela_concreta' ? _parcelaSeleccionada?.id : null,
      terceroId: _terceroSeleccionado?.id,
      numeroFactura: _facturaCtrl.text.trim(),
      notas: _notasCtrl.text.trim(),
    );
    await BaseDatosSoleraAceitera().insertarApunteGasto(apunte);
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
      appBar: AppBar(title: Text(SoleraL10n.t('acei.nuevo_gasto'))),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: textoOGuardando(SoleraL10n.t('acei.guardar_gasto'),
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
              initialValue: _tipoGasto,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.tipo_de_gasto'),
                border: OutlineInputBorder(),
              ),
              items: tiposGastoAceitera
                  .map((tipo) => DropdownMenuItem(
                      value: tipo, child: Text(nombreTipoGasto(tipo))))
                  .toList(),
              onChanged: (v) => setState(() => _tipoGasto = v ?? 'otro'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _conceptoCtrl,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.concepto'),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? SoleraL10n.t('acei.obligatorio') : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseCtrl,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('acei.importe_base_euros'),
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
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _ivaCtrl,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('acei.iva_soportado_euros'),
                      border: OutlineInputBorder(),
                      helperText: SoleraL10n.t('acei.iva_soportado_ayuda'),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: validarImporteOpcional,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(SoleraL10n.t('acei.imputacion'),
                style: TextStyle(fontWeight: FontWeight.w600)),
            RadioListTile<String>(
              value: 'general',
              groupValue: _imputacion,
              title: Text(SoleraL10n.t('acei.imputacion_general')),
              onChanged: (v) => setState(() => _imputacion = v!),
            ),
            RadioListTile<String>(
              value: 'parcela_concreta',
              groupValue: _imputacion,
              title: Text(SoleraL10n.t('acei.imputacion_parcela')),
              onChanged: (v) => setState(() => _imputacion = v!),
            ),
            if (_imputacion == 'parcela_concreta')
              DropdownButtonFormField<Parcela?>(
                initialValue: _parcelaSeleccionada,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.parcela'),
                  border: OutlineInputBorder(),
                ),
                items: [
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
            DropdownButtonFormField<Tercero?>(
              initialValue: _terceroSeleccionado,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('acei.proveedor_opcional'),
                border: OutlineInputBorder(),
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
