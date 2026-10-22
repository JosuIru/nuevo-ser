import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/finca.dart';
import '../modelos/tercero.dart';

/// Formulario de apunte de gasto agrícola. La complicación está en
/// `imputacion`: un mismo gasto puede afectar a una parcela
/// concreta (insumos comprados para una finca específica), a un
/// cultivo en general (abono comprado para todos los manzanos) o a
/// la explotación (seguro Agroseguro multicultivo).
///
/// Sinergia clave con el cuaderno MAPA: si el gasto es de tipo
/// `tratamientos_fitosanitarios`, el `tratamientoId` opcional liga
/// este apunte económico al apunte sanitario del cuaderno MAPA. Un
/// mismo evento, dos libros.
class PantallaNuevoGasto extends StatefulWidget {
  final ApunteGasto? existente;
  PantallaNuevoGasto({super.key, this.existente});

  @override
  State<PantallaNuevoGasto> createState() => _PantallaNuevoGastoState();
}

class _PantallaNuevoGastoState extends State<PantallaNuevoGasto> {
  static const _opcionesTipo = <_OpcionTipo>[
    _OpcionTipo('insumos', 'Insumos (semillas, plantones, fertilizantes, abonos)'),
    _OpcionTipo('tratamientos_fitosanitarios', 'Tratamientos fitosanitarios'),
    _OpcionTipo('maquinaria', 'Maquinaria (compra, alquiler, mantenimiento)'),
    _OpcionTipo('mano_obra', 'Mano de obra'),
    _OpcionTipo('combustible', 'Combustible'),
    _OpcionTipo('seguros', 'Seguros (Agroseguro, responsabilidad civil)'),
    _OpcionTipo('riego_agua', 'Riego / agua (canon, electricidad bombeo)'),
    _OpcionTipo('transporte', 'Transporte'),
    _OpcionTipo('veterinario_animal', 'Veterinario animal (ganado en dehesa)'),
    _OpcionTipo('certificacion', 'Certificación (DOP, IGP, ecológico)'),
    _OpcionTipo('otro', 'Otro gasto'),
  ];

  final _claveFormulario = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _importeBase = TextEditingController();
  final _ivaSoportado = TextEditingController();
  final _numeroFactura = TextEditingController();
  final _notas = TextEditingController();

  String _tipoGasto = 'insumos';
  DateTime _fecha = DateTime.now();
  String _imputacion = 'general';
  int? _fincaId;
  String _cultivoId = '';
  int? _terceroId;
  String _rutaFoto = '';

  ConfiguracionFiscal _configFiscal = ConfiguracionFiscal();
  List<Tercero> _proveedores = const [];
  List<Finca> _fincas = const [];
  bool _cargando = true;
  bool _guardando = false;
  bool _autocalcular = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosAgro.instancia;
    final cf = await db.obtenerConfiguracionFiscal();
    final proveedores = await db.listarTerceros(tipo: 'proveedor');
    final fincas = await db.listarFincas();
    if (!mounted) return;

    final e = widget.existente;
    if (e != null) {
      _tipoGasto = e.tipoGasto;
      _fecha = DateTime.fromMillisecondsSinceEpoch(e.fechaMs);
      _concepto.text = e.concepto;
      _importeBase.text = _formatearCentimos(e.importeBaseCentimos);
      _ivaSoportado.text = _formatearCentimos(e.ivaSoportadoCentimos);
      _imputacion = e.imputacion;
      _fincaId = e.fincaId;
      _cultivoId = e.cultivoId;
      _terceroId = e.terceroId;
      _rutaFoto = e.rutaFotoFactura;
      _numeroFactura.text = e.numeroFactura;
      _notas.text = e.notas;
      _autocalcular = false;
    }

    setState(() {
      _configFiscal = cf;
      _proveedores = proveedores;
      _fincas = fincas;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _concepto,
      _importeBase,
      _ivaSoportado,
      _numeroFactura,
      _notas,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatearCentimos(int centimos) {
    if (centimos == 0) return '';
    return (centimos / 100).toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Importe escrito a la española («1.200,50») → céntimos. Vacío o no
  /// entendido → 0; lo no entendido ya lo para el validador del campo.
  int _parsearCentimos(String texto) => centimosDesdeTexto(texto) ?? 0;

  void _recalcular() {
    if (!_autocalcular) return;
    // Asunción provisional: 21% IVA general por defecto. Excepciones:
    // insumos agrícolas (semillas, plantones, fertilizantes) al 4%
    // si son producto agrario, mano de obra agrícola REAGP exenta,
    // seguros exentos. El usuario sobrescribe si la factura difiere.
    final base = _parsearCentimos(_importeBase.text);
    double tipo;
    switch (_tipoGasto) {
      case 'insumos':
        tipo = 0.04; // Insumos agrarios típicamente al 4% reducido
        break;
      case 'seguros':
        tipo = 0.0; // Seguros exentos de IVA (art. 20 LIVA)
        break;
      case 'mano_obra':
        tipo = 0.0; // Mano de obra agrícola normalmente no lleva IVA
        break;
      case 'riego_agua':
        tipo = 0.10; // Suministro de agua para riego al 10% reducido
        break;
      default:
        tipo = 0.21; // Resto al 21% general
    }
    _ivaSoportado.text = _formatearCentimos((base * tipo).round());
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    // Patrón defensivo idéntico al de pantalla_nuevo_ingreso: si la
    // validación falla avisamos en lugar de quedarnos en silencio,
    // y envolvemos el guardado en try/catch con snackbar para que
    // cualquier error de BD (FK violation, tabla inexistente…)
    // sea visible en lugar de dejar al usuario pensando que no ha
    // pasado nada.
    if (!(_claveFormulario.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faltan datos obligatorios — revisa los campos marcados en rojo.',
          ),
        ),
      );
      return;
    }
    if (_imputacion == 'finca_concreta' && _fincaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Elige una parcela para imputación concreta'),
      ));
      return;
    }
    if (_imputacion == 'cultivo_general' && _cultivoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Elige un cultivo para imputación general por cultivo'),
      ));
      return;
    }
    setState(() => _guardando = true);
    final apunte = ApunteGasto(
      id: widget.existente?.id,
      fechaMs: _fecha.millisecondsSinceEpoch,
      concepto: _concepto.text.trim(),
      tipoGasto: _tipoGasto,
      importeBaseCentimos: _parsearCentimos(_importeBase.text),
      ivaSoportadoCentimos: _parsearCentimos(_ivaSoportado.text),
      imputacion: _imputacion,
      fincaId: _imputacion == 'finca_concreta' ? _fincaId : null,
      cultivoId: _imputacion == 'cultivo_general' ? _cultivoId : '',
      terceroId: _terceroId,
      rutaFotoFactura: _rutaFoto,
      numeroFactura: _numeroFactura.text.trim(),
      tratamientoId: widget.existente?.tratamientoId,
      notas: _notas.text.trim(),
    );
    final db = BaseDatosAgro.instancia;
    try {
      if (apunte.id == null) {
        await db.guardarApunteGasto(apunte);
      } else {
        await db.actualizarApunteGasto(apunte.id!, apunte.toMap()..remove('id'));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apunte.id == null ? 'Gasto guardado.' : 'Gasto actualizado.'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardando gasto: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existente == null ? 'Nuevo gasto' : 'Editar gasto'),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipoGasto,
              decoration: InputDecoration(
                labelText: 'Tipo de gasto',
                border: OutlineInputBorder(),
              ),
              items: _opcionesTipo
                  .map((o) =>
                      DropdownMenuItem(value: o.codigo, child: Text(o.titulo)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _tipoGasto = v ?? 'otro';
                  _autocalcular = true;
                });
                _recalcular();
                setState(() {});
              },
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.event),
              title: Text(
                  '${_fecha.day}/${_fecha.month}/${_fecha.year}'),
              subtitle: Text('Fecha de la factura'),
              trailing: TextButton(
                onPressed: _elegirFecha,
                child: Text('Cambiar'),
              ),
            ),
            TextFormField(
              controller: _concepto,
              decoration: InputDecoration(
                labelText: 'Concepto *',
                hintText: 'Ej: Sulfato de cobre 5 kg / Diésel cosechadora',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Concepto obligatorio' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _importeBase,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Importe base (€) *',
                hintText: 'Sin IVA',
                border: OutlineInputBorder(),
              ),
              validator: validarImporteObligatorio,
              onChanged: (_) {
                _recalcular();
                setState(() {});
              },
            ),
            SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _autocalcular,
              title: Text('Autocalcular IVA'),
              subtitle: Text(_textoAutocalculo()),
              onChanged: (v) {
                setState(() => _autocalcular = v);
                if (v) _recalcular();
                setState(() {});
              },
            ),
            TextFormField(
              controller: _ivaSoportado,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              enabled: !_autocalcular,
              decoration: InputDecoration(
                labelText: 'IVA soportado (€)',
                border: OutlineInputBorder(),
              ),
              validator: validarImporteOpcional,
            ),
            if (_configFiscal.regimenIva == 'reagp')
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'En REAGP el IVA soportado NO es recuperable — se computa '
                  'como mayor coste en el extracto.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            SizedBox(height: 16),
            Text('Imputación a parcela / cultivo',
                style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _imputacion,
              onChanged: (v) => setState(() => _imputacion = v ?? 'general'),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'general',
                    title: Text('General de la explotación'),
                    subtitle: Text('Sin asociar a parcela ni cultivo concreto'),
                  ),
                  RadioListTile<String>(
                    value: 'finca_concreta',
                    title: Text('Parcela concreta'),
                    subtitle: Text('Todo el gasto se imputa a una sola finca'),
                  ),
                  RadioListTile<String>(
                    value: 'cultivo_general',
                    title: Text('Cultivo general'),
                    subtitle: Text(
                        'Compartido entre todas las parcelas con ese cultivo'),
                  ),
                ],
              ),
            ),
            if (_imputacion == 'finca_concreta') ...[
              SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _fincaId,
                decoration: InputDecoration(
                  labelText: 'Parcela *',
                  border: OutlineInputBorder(),
                ),
                items: _fincas
                    .map((f) =>
                        DropdownMenuItem(value: f.id, child: Text(f.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _fincaId = v),
              ),
            ],
            if (_imputacion == 'cultivo_general') ...[
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _cultivoId.isEmpty ? null : _cultivoId,
                decoration: InputDecoration(
                  labelText: 'Cultivo *',
                  border: OutlineInputBorder(),
                ),
                items: catalogoCultivos
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nombreVisible),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _cultivoId = v ?? ''),
              ),
            ],
            SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _terceroId,
              decoration: InputDecoration(
                labelText: 'Proveedor',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text('(sin asociar)')),
                ..._proveedores.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.nombre +
                          (t.tieneNif ? ' · ${t.nif}' : ' · sin NIF')),
                    )),
              ],
              onChanged: (v) => setState(() => _terceroId = v),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _numeroFactura,
              decoration: InputDecoration(
                labelText: 'Nº de factura',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.existente?.tratamientoId != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Apunte vinculado a un tratamiento del cuaderno MAPA — el '
                  'sincronizador mantiene los dos consistentes.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            SizedBox(height: 16),
            Text('Foto de la factura',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SelectorFotos(
              rutas: _rutaFoto.isEmpty ? const [] : [_rutaFoto],
              alCambiar: (rutas) => setState(
                  () => _rutaFoto = rutas.isEmpty ? '' : rutas.first),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notas,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.check),
              label: Text(SoleraL10n.t('guardar')),
            ),
          ],
        ),
      ),
    );
  }

  String _textoAutocalculo() {
    switch (_tipoGasto) {
      case 'insumos':
        return '4% IVA reducido (insumo agrario)';
      case 'seguros':
        return 'Exento de IVA (art. 20 LIVA)';
      case 'mano_obra':
        return 'Mano de obra agrícola: típicamente sin IVA';
      case 'riego_agua':
        return '10% IVA reducido (suministro agua para riego)';
      default:
        return '21% IVA general';
    }
  }
}

class _OpcionTipo {
  final String codigo;
  final String titulo;
  const _OpcionTipo(this.codigo, this.titulo);
}
