import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/apiario.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/tercero.dart';

/// Formulario de apunte de gasto. La complicación apícola está en
/// `imputacion`: trashumancia compartida entre colmenares se resuelve
/// con reparto proporcional al número de colmenas activas en cada uno.
/// El cálculo del reparto vive en el resumen / extracto, no en el
/// apunte — aquí sólo declaramos la modalidad de imputación.
class PantallaNuevoGasto extends StatefulWidget {
  final ApunteGasto? existente;
  PantallaNuevoGasto({super.key, this.existente});

  @override
  State<PantallaNuevoGasto> createState() => _PantallaNuevoGastoState();
}

class _PantallaNuevoGastoState extends State<PantallaNuevoGasto> {
  static const _opcionesTipo = <_OpcionTipo>[
    _OpcionTipo('alimentacion', 'api.eco_gasto_alimentacion'),
    _OpcionTipo('sanidad_varroa', 'api.eco_gasto_sanidad_varroa'),
    _OpcionTipo('material', 'api.eco_gasto_material'),
    _OpcionTipo('transporte_trashumancia', 'api.eco_gasto_transporte_trashumancia'),
    _OpcionTipo('mano_obra', 'api.eco_gasto_mano_obra'),
    _OpcionTipo('veterinario', 'api.eco_gasto_veterinario'),
    _OpcionTipo('seguros', 'api.eco_gasto_seguros'),
    _OpcionTipo('combustible', 'api.eco_gasto_combustible'),
    _OpcionTipo('otro', 'api.eco_gasto_otro'),
  ];

  final _claveFormulario = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _importeBase = TextEditingController();
  final _ivaSoportado = TextEditingController();
  final _numeroFactura = TextEditingController();
  final _notas = TextEditingController();

  String _tipoGasto = 'material';
  DateTime _fecha = DateTime.now();
  String _imputacion = 'general';
  int? _apiarioId;
  int? _terceroId;
  String _rutaFoto = '';

  ConfiguracionFiscal _configFiscal = ConfiguracionFiscal();
  List<Tercero> _proveedores = const [];
  List<Apiario> _apiarios = const [];
  bool _cargando = true;
  bool _guardando = false;
  bool _autocalcular = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraApicola.instancia;
    final cf = await db.obtenerConfiguracionFiscal();
    final proveedores = await db.listarTerceros(tipo: 'proveedor');
    final apiarios = await db.listarApiarios();
    if (!mounted) return;

    final e = widget.existente;
    if (e != null) {
      _tipoGasto = e.tipoGasto;
      _fecha = DateTime.fromMillisecondsSinceEpoch(e.fechaMs);
      _concepto.text = e.concepto;
      _importeBase.text = _formatearCentimos(e.importeBaseCentimos);
      _ivaSoportado.text = _formatearCentimos(e.ivaSoportadoCentimos);
      _imputacion = e.imputacion;
      _apiarioId = e.apiarioId;
      _terceroId = e.terceroId;
      _rutaFoto = e.rutaFotoFactura;
      _numeroFactura.text = e.numeroFactura;
      _notas.text = e.notas;
      _autocalcular = false;
    }

    setState(() {
      _configFiscal = cf;
      _proveedores = proveedores;
      _apiarios = apiarios;
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
    return (centimos / 100).toStringAsFixed(2);
  }

  /// Vacío o ilegible cuenta 0 (para el autocálculo); al guardar, el
  /// validador del campo ya ha avisado si no se entendía.
  int _parsearCentimos(String texto) => centimosDesdeTexto(texto) ?? 0;

  void _recalcular() {
    if (!_autocalcular) return;
    // Asunción provisional: 21% IVA general por defecto (la mayoría
    // de gastos profesionales). Productos veterinarios y servicios
    // veterinarios suelen ir al 21% también. Alimentación animal al
    // 10%. Combustible al 21%. El usuario sobrescribe si su factura
    // difiere.
    final base = _parsearCentimos(_importeBase.text);
    double tipo;
    switch (_tipoGasto) {
      case 'alimentacion':
        tipo = 0.10;
        break;
      default:
        tipo = 0.21;
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
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    if (_imputacion == 'colmenar_concreto' && _apiarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(SoleraL10n.t('api.eco_elige_apiario_imputacion')),
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
      apiarioId: _imputacion == 'colmenar_concreto' ? _apiarioId : null,
      terceroId: _terceroId,
      rutaFotoFactura: _rutaFoto,
      numeroFactura: _numeroFactura.text.trim(),
      tratamientoVarroaId: widget.existente?.tratamientoVarroaId,
      notas: _notas.text.trim(),
    );
    final db = BaseDatosSoleraApicola.instancia;
    if (apunte.id == null) {
      await db.guardarApunteGasto(apunte);
    } else {
      await db.actualizarApunteGasto(apunte.id!, apunte.toMap()..remove('id'));
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existente == null
            ? SoleraL10n.t('api.eco_nuevo_gasto')
            : SoleraL10n.t('api.eco_editar_gasto')),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipoGasto,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('api.eco_tipo_de_gasto'),
                border: OutlineInputBorder(),
              ),
              items: _opcionesTipo
                  .map((o) =>
                      DropdownMenuItem(value: o.codigo, child: Text(SoleraL10n.t(o.claveTitulo))))
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
              subtitle: Text(SoleraL10n.t('api.eco_fecha_de_la_factura')),
              trailing: TextButton(
                onPressed: _elegirFecha,
                child: Text(SoleraL10n.t('api.eco_cambiar')),
              ),
            ),
            TextFormField(
              controller: _concepto,
              decoration: InputDecoration(
                labelText: '${SoleraL10n.t('api.concepto')} *',
                hintText: SoleraL10n.t('api.eco_ejemplo_concepto_gasto'),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? SoleraL10n.t('api.eco_concepto_obligatorio') : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _importeBase,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${SoleraL10n.t('api.eco_importe_base_euros')} *',
                hintText: SoleraL10n.t('api.eco_sin_iva'),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return SoleraL10n.t('importe_obligatorio');
                if (centimosDesdeTexto(v!) == null) return SoleraL10n.t('numero_no_valido');
                if (_parsearCentimos(v) <= 0) return SoleraL10n.t('mayor_que_cero');
                return null;
              },
              onChanged: (_) {
                _recalcular();
                setState(() {});
              },
            ),
            SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _autocalcular,
              title: Text(SoleraL10n.t('api.eco_autocalcular_iva')),
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
                labelText: SoleraL10n.t('api.eco_iva_soportado_euros'),
                border: OutlineInputBorder(),
              ),
              validator: validarImporteOpcional,
            ),
            if (_configFiscal.regimenIva == 'reagp')
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  SoleraL10n.t('api.eco_aviso_reagp_iva_soportado'),
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            SizedBox(height: 16),
            Text(SoleraL10n.t('api.eco_imputacion_a_apiario'),
                style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _imputacion,
              onChanged: (v) => setState(() => _imputacion = v ?? 'general'),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'general',
                    title: Text(SoleraL10n.t('api.eco_imputacion_general')),
                    subtitle: Text(SoleraL10n.t('api.eco_imputacion_general_ayuda')),
                  ),
                  RadioListTile<String>(
                    value: 'colmenar_concreto',
                    title: Text(SoleraL10n.t('api.eco_imputacion_apiario_concreto')),
                    subtitle: Text(SoleraL10n.t('api.eco_imputacion_apiario_concreto_ayuda')),
                  ),
                  RadioListTile<String>(
                    value: 'reparto_proporcional',
                    title: Text(SoleraL10n.t('api.eco_imputacion_reparto')),
                    subtitle: Text(
                        SoleraL10n.t('api.eco_imputacion_reparto_ayuda')),
                  ),
                ],
              ),
            ),
            if (_imputacion == 'colmenar_concreto') ...[
              SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _apiarioId,
                decoration: InputDecoration(
                  labelText: '${SoleraL10n.t('api.eco_colmenar')} *',
                  border: OutlineInputBorder(),
                ),
                items: _apiarios
                    .map((a) =>
                        DropdownMenuItem(value: a.id, child: Text(a.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _apiarioId = v),
              ),
            ],
            SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _terceroId,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('proveedor'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(SoleraL10n.t('api.eco_sin_asociar'))),
                ..._proveedores.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.nombre +
                          (t.tieneNif ? ' · ${t.nif}' : ' · ${SoleraL10n.t('api.eco_sin_nif')}')),
                    )),
              ],
              onChanged: (v) => setState(() => _terceroId = v),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _numeroFactura,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('api.eco_numero_de_factura'),
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.existente?.tratamientoVarroaId != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  SoleraL10n.t('api.eco_aviso_vinculado_tratamiento'),
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            SizedBox(height: 16),
            Text(SoleraL10n.t('api.eco_foto_de_la_factura'),
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
                labelText: SoleraL10n.t('api.notas'),
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
    if (_tipoGasto == 'alimentacion') {
      return SoleraL10n.t('api.eco_iva_10_alimentacion_animal');
    }
    return SoleraL10n.t('api.eco_iva_21_general');
  }
}

class _OpcionTipo {
  final String codigo;
  /// Clave de traducción del nombre visible.
  final String claveTitulo;
  const _OpcionTipo(this.codigo, this.claveTitulo);
}
