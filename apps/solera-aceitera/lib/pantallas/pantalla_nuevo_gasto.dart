import 'package:flutter/material.dart';

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

  static const _tipos = <String, String>{
    'insumos_olivar': 'Insumos olivar (abonos, herbicidas)',
    'fitosanitarios': 'Fitosanitarios',
    'recoleccion': 'Recolección (jornales)',
    'molturacion_externa': 'Molturación externa',
    'envasado': 'Envasado (botellas, cápsulas, etiquetado)',
    'analiticas': 'Analíticas (acidez, peróxidos, panel test)',
    'cuota_dop': 'Cuota DOP / Consejo Regulador',
    'maquinaria': 'Maquinaria (compra, mantenimiento)',
    'mano_obra': 'Mano de obra (jornales fuera de recolección)',
    'combustible': 'Combustible (gasoil agrícola)',
    'seguros': 'Seguros (agrario)',
    'transporte': 'Transporte',
    'certificacion': 'Certificación (ecológico, integrada, DOP)',
    'otro': 'Otro gasto',
  };

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
      appBar: AppBar(title: const Text('Nuevo gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                  'Fecha: ${_fecha.day}/${_fecha.month}/${_fecha.year}'),
              trailing: TextButton(
                onPressed: _seleccionarFecha,
                child: const Text('Cambiar'),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _tipoGasto,
              decoration: const InputDecoration(
                labelText: 'Tipo de gasto',
                border: OutlineInputBorder(),
              ),
              items: _tipos.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _tipoGasto = v ?? 'otro'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _conceptoCtrl,
              decoration: const InputDecoration(
                labelText: 'Concepto',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Importe base (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final n = centimosDesdeTexto(v ?? '');
                      if (n == null || n < 0) return 'Importe inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _ivaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'IVA soportado (€)',
                      border: OutlineInputBorder(),
                      helperText: 'Lee la cuota de IVA de la factura.',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: validarImporteOpcional,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Imputación',
                style: TextStyle(fontWeight: FontWeight.w600)),
            RadioListTile<String>(
              value: 'general',
              groupValue: _imputacion,
              title: const Text('General de la explotación'),
              onChanged: (v) => setState(() => _imputacion = v!),
            ),
            RadioListTile<String>(
              value: 'parcela_concreta',
              groupValue: _imputacion,
              title: const Text('A una parcela concreta'),
              onChanged: (v) => setState(() => _imputacion = v!),
            ),
            if (_imputacion == 'parcela_concreta')
              DropdownButtonFormField<Parcela?>(
                initialValue: _parcelaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Parcela',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final p in _parcelas)
                    DropdownMenuItem<Parcela?>(
                      value: p,
                      child: Text(
                          p.nombre.isEmpty ? 'Parcela #${p.id}' : p.nombre),
                    ),
                ],
                onChanged: (v) => setState(() => _parcelaSeleccionada = v),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Tercero?>(
              initialValue: _terceroSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Proveedor (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<Tercero?>(
                  value: null,
                  child: Text('(sin tercero)'),
                ),
                for (final t in _terceros)
                  DropdownMenuItem<Tercero?>(
                    value: t,
                    child:
                        Text(t.nombre.isEmpty ? '(sin nombre)' : t.nombre),
                  ),
              ],
              onChanged: (v) => setState(() => _terceroSeleccionado = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _facturaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nº de factura',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notasCtrl,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
