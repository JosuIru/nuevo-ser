import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/parcela.dart';
import '../modelos/tercero.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../utiles/validacion_numeros.dart';

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

  static const _tipos = <String, String>{
    'venta_aceituna': 'Venta de aceituna',
    'venta_aceite_envasado': 'Venta de aceite envasado',
    'venta_aceite_granel': 'Venta de aceite a granel',
    'alquiler_terreno': 'Alquiler de terreno agrícola',
    'ayuda_pac': 'Ayuda PAC',
    'subvencion_autonomica': 'Subvención autonómica',
    'subproducto_alperujo': 'Venta de alperujo',
    'otro': 'Otro ingreso',
  };

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
      appBar: AppBar(title: const Text('Nuevo ingreso')),
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
              initialValue: _tipoIngreso,
              decoration: const InputDecoration(
                labelText: 'Tipo de ingreso',
                border: OutlineInputBorder(),
              ),
              items: _tipos.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) {
                setState(() => _tipoIngreso = v ?? 'venta_aceituna');
                _autocalcular();
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _conceptoCtrl,
              decoration: const InputDecoration(
                labelText: 'Concepto',
                hintText: 'Aceituna picual a cooperativa, etc.',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _baseCtrl,
              decoration: const InputDecoration(
                labelText: 'Importe base (€, sin IVA)',
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ivaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'IVA repercutido (€)',
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
                    decoration: const InputDecoration(
                      labelText: 'Compensación REAGP (€)',
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
              label: const Text('Recalcular IVA / compensación'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cantidadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
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
                    initialValue: _unidad,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'tn', child: Text('tn')),
                      DropdownMenuItem(value: 'l', child: Text('l')),
                      DropdownMenuItem(value: 'hl', child: Text('hl')),
                      DropdownMenuItem(
                          value: 'botellas', child: Text('botellas')),
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
              initialValue: _terceroSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Cliente (opcional)',
                border: OutlineInputBorder(),
                helperText: 'Sin tercero, no entra al modelo 347.',
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
            DropdownButtonFormField<Parcela?>(
              initialValue: _parcelaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Parcela (opcional)',
                border: OutlineInputBorder(),
                helperText:
                    'Para imputar el ingreso a una parcela concreta.',
              ),
              items: [
                const DropdownMenuItem<Parcela?>(
                  value: null,
                  child: Text('(general — sin imputar a parcela)'),
                ),
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
              label: const Text('Guardar ingreso'),
            ),
          ],
        ),
      ),
    );
  }
}
