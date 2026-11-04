import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/tercero.dart';
import '../modelos/vinedo.dart';

/// Formulario de apunte de gasto del viticultor/bodega. Categorías
/// específicas del ciclo vitivinícola (vendimia, embotellado,
/// etiquetado, barricas) además de las genéricas (insumos,
/// tratamientos, maquinaria, mano de obra…). Imputación a viñedo
/// concreto, variedad general (todas las parcelas con esa variedad)
/// o general de la explotación.
class PantallaNuevoGasto extends StatefulWidget {
  final ApunteGasto? existente;
  PantallaNuevoGasto({super.key, this.existente});

  @override
  State<PantallaNuevoGasto> createState() => _PantallaNuevoGastoState();
}

class _PantallaNuevoGastoState extends State<PantallaNuevoGasto> {
  static const _opcionesTipo = <_OpcionTipo>[
    // El segundo campo es la clave de traducción del texto visible.
    _OpcionTipo('insumos_vid', 'viti.gasto_insumos_vid_detalle'),
    _OpcionTipo('tratamientos_fitosanitarios', 'viti.gasto_tratamientos_fitosanitarios'),
    _OpcionTipo('vendimia', 'viti.gasto_vendimia_detalle'),
    _OpcionTipo('embotellado', 'viti.gasto_embotellado_detalle'),
    _OpcionTipo('etiquetado', 'viti.gasto_etiquetado'),
    _OpcionTipo('barricas', 'viti.gasto_barricas_detalle'),
    _OpcionTipo('maquinaria', 'viti.gasto_maquinaria_detalle'),
    _OpcionTipo('mano_obra', 'viti.gasto_mano_obra_detalle'),
    _OpcionTipo('combustible', 'viti.gasto_combustible'),
    _OpcionTipo('seguros', 'viti.gasto_seguros_detalle'),
    _OpcionTipo('transporte', 'viti.gasto_transporte'),
    _OpcionTipo('certificacion', 'viti.gasto_certificacion_detalle'),
    _OpcionTipo('otro', 'viti.otro_gasto'),
  ];

  final _claveFormulario = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _importeBase = TextEditingController();
  final _ivaSoportado = TextEditingController();
  final _numeroFactura = TextEditingController();
  final _notas = TextEditingController();

  String _tipoGasto = 'insumos_vid';
  DateTime _fecha = DateTime.now();
  String _imputacion = 'general';
  int? _vinedoId;
  String _variedadId = '';
  int? _terceroId;
  String _rutaFoto = '';

  ConfiguracionFiscal _configFiscal = ConfiguracionFiscal();
  List<Tercero> _proveedores = const [];
  List<Vinedo> _vinedos = const [];
  bool _cargando = true;
  bool _guardando = false;
  bool _autocalcular = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraViticultura.instancia;
    final cf = await db.obtenerConfiguracionFiscal();
    final proveedores = await db.listarTerceros(tipo: 'proveedor');
    final vinedos = await db.listarVinedos();
    if (!mounted) return;

    final e = widget.existente;
    if (e != null) {
      _tipoGasto = e.tipoGasto;
      _fecha = DateTime.fromMillisecondsSinceEpoch(e.fechaMs);
      _concepto.text = e.concepto;
      _importeBase.text = _formatearCentimos(e.importeBaseCentimos);
      _ivaSoportado.text = _formatearCentimos(e.ivaSoportadoCentimos);
      _imputacion = e.imputacion;
      _vinedoId = e.vinedoId;
      _variedadId = e.variedadId;
      _terceroId = e.terceroId;
      _rutaFoto = e.rutaFotoFactura;
      _numeroFactura.text = e.numeroFactura;
      _notas.text = e.notas;
      _autocalcular = false;
    }

    setState(() {
      _configFiscal = cf;
      _proveedores = proveedores;
      _vinedos = vinedos;
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
    // Coma decimal; leerNumero/centimosDesdeTexto la entienden al guardar.
    return formatearNumero(centimos / 100, decimales: 2);
  }

  /// Vacío o ilegible → 0; el validador del campo avisa si no se entiende.
  int _parsearCentimos(String texto) => centimosDesdeTexto(texto) ?? 0;

  void _recalcular() {
    if (!_autocalcular) return;
    final base = _parsearCentimos(_importeBase.text);
    double tipo;
    switch (_tipoGasto) {
      case 'insumos_vid':
        tipo = 0.04; // Insumos agrarios al 4% reducido típicamente
        break;
      case 'seguros':
        tipo = 0.0; // Exentos (art. 20 LIVA)
        break;
      case 'vendimia':
      case 'mano_obra':
        tipo = 0.0; // Mano de obra agrícola sin IVA típicamente
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
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    if (_imputacion == 'vinedo_concreto' && _vinedoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(SoleraL10n.t('viti.elige_vinedo_imputacion')),
      ));
      return;
    }
    if (_imputacion == 'variedad_general' && _variedadId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(SoleraL10n.t('viti.elige_variedad_imputacion')),
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
      vinedoId: _imputacion == 'vinedo_concreto' ? _vinedoId : null,
      variedadId: _imputacion == 'variedad_general' ? _variedadId : '',
      terceroId: _terceroId,
      rutaFotoFactura: _rutaFoto,
      numeroFactura: _numeroFactura.text.trim(),
      tratamientoId: widget.existente?.tratamientoId,
      notas: _notas.text.trim(),
    );
    final db = BaseDatosSoleraViticultura.instancia;
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
        title: Text(widget.existente == null ? SoleraL10n.t('viti.nuevo_gasto') : SoleraL10n.t('viti.editar_gasto')),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipoGasto,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.tipo_de_gasto'),
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
              title: Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
              subtitle: Text(SoleraL10n.t('viti.fecha_de_la_factura')),
              trailing: TextButton(
                onPressed: _elegirFecha,
                child: Text(SoleraL10n.t('viti.cambiar')),
              ),
            ),
            TextFormField(
              controller: _concepto,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.concepto_obligatorio_etiqueta'),
                hintText: SoleraL10n.t('viti.concepto_gasto_ayuda'),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? SoleraL10n.t('viti.concepto_obligatorio') : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _importeBase,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.importe_base_obligatorio'),
                hintText: SoleraL10n.t('viti.sin_iva'),
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
              title: Text(SoleraL10n.t('viti.autocalcular_iva')),
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
                labelText: SoleraL10n.t('viti.iva_soportado_euros'),
                border: OutlineInputBorder(),
              ),
              validator: validarImporteOpcional,
            ),
            if (_configFiscal.regimenIva == 'reagp')
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  SoleraL10n.t('viti.reagp_iva_soportado_no_recuperable'),
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            SizedBox(height: 16),
            Text(SoleraL10n.t('viti.imputacion_vinedo_variedad'),
                style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _imputacion,
              onChanged: (v) => setState(() => _imputacion = v ?? 'general'),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'general',
                    title: Text(SoleraL10n.t('viti.imputacion_general')),
                    subtitle: Text(SoleraL10n.t('viti.imputacion_general_ayuda')),
                  ),
                  RadioListTile<String>(
                    value: 'vinedo_concreto',
                    title: Text(SoleraL10n.t('viti.imputacion_vinedo_concreto')),
                    subtitle: Text(SoleraL10n.t('viti.imputacion_vinedo_concreto_ayuda')),
                  ),
                  RadioListTile<String>(
                    value: 'variedad_general',
                    title: Text(SoleraL10n.t('viti.imputacion_variedad_general')),
                    subtitle: Text(SoleraL10n.t('viti.imputacion_variedad_general_ayuda')),
                  ),
                ],
              ),
            ),
            if (_imputacion == 'vinedo_concreto') ...[
              SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _vinedoId,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('viti.vinedo_obligatorio_etiqueta'),
                  border: OutlineInputBorder(),
                ),
                items: _vinedos
                    .map((v) =>
                        DropdownMenuItem(value: v.id, child: Text(v.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _vinedoId = v),
              ),
            ],
            if (_imputacion == 'variedad_general') ...[
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _variedadId.isEmpty ? null : _variedadId,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('viti.variedad_obligatoria_etiqueta'),
                  border: OutlineInputBorder(),
                ),
                items: catalogoVariedades
                    .map((v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(v.nombreCanonico),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _variedadId = v ?? ''),
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
                    value: null, child: Text(SoleraL10n.t('viti.sin_asociar'))),
                ..._proveedores.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.nombre +
                          (t.tieneNif ? ' · ${t.nif}' : ' · ${SoleraL10n.t('viti.sin_nif')}')),
                    )),
              ],
              onChanged: (v) => setState(() => _terceroId = v),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _numeroFactura,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.numero_de_factura'),
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.existente?.tratamientoId != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  SoleraL10n.t('viti.apunte_vinculado_tratamiento'),
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            SizedBox(height: 16),
            Text(SoleraL10n.t('viti.foto_de_la_factura'),
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
                labelText: SoleraL10n.t('viti.notas'),
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
      case 'insumos_vid':
        return SoleraL10n.t('viti.autocalculo_insumos');
      case 'seguros':
        return SoleraL10n.t('viti.autocalculo_seguros');
      case 'vendimia':
      case 'mano_obra':
        return SoleraL10n.t('viti.autocalculo_mano_obra');
      default:
        return SoleraL10n.t('viti.autocalculo_general');
    }
  }
}

class _OpcionTipo {
  final String codigo;
  final String claveTitulo;
  const _OpcionTipo(this.codigo, this.claveTitulo);

  String get titulo => SoleraL10n.t(claveTitulo);
}
