import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/tercero.dart';
import '../modelos/vinedo.dart';
import '../utiles/validadores_numero.dart';

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
    _OpcionTipo('insumos_vid', 'Insumos vid (fertilizantes, sulfatos, abonos)'),
    _OpcionTipo('tratamientos_fitosanitarios', 'Tratamientos fitosanitarios'),
    _OpcionTipo('vendimia', 'Vendimia (mano de obra estacional)'),
    _OpcionTipo('embotellado', 'Embotellado (botella, corcho, cápsula)'),
    _OpcionTipo('etiquetado', 'Etiquetado'),
    _OpcionTipo('barricas', 'Barricas (compra, mantenimiento)'),
    _OpcionTipo('maquinaria', 'Maquinaria (compra, alquiler, mantenimiento)'),
    _OpcionTipo('mano_obra', 'Mano de obra (cuadrilla resto del año)'),
    _OpcionTipo('combustible', 'Combustible'),
    _OpcionTipo('seguros', 'Seguros (Agroseguro, responsabilidad civil)'),
    _OpcionTipo('transporte', 'Transporte'),
    _OpcionTipo('certificacion', 'Certificación (DOP/IGP/ecológico)'),
    _OpcionTipo('otro', 'Otro gasto'),
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
    return (centimos / 100).toStringAsFixed(2);
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
        content: Text('Elige un viñedo para imputación concreta'),
      ));
      return;
    }
    if (_imputacion == 'variedad_general' && _variedadId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Elige una variedad para imputación general'),
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
              title: Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
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
                hintText: 'Ej: Sulfato de cobre / 8 jornales vendimia',
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
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Importe obligatorio';
                if (validarImporteOpcional(v) != null) {
                  return textoNumeroNoValido;
                }
                if (_parsearCentimos(v!) <= 0) return 'Mayor que cero';
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
            Text('Imputación a viñedo / variedad',
                style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _imputacion,
              onChanged: (v) => setState(() => _imputacion = v ?? 'general'),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'general',
                    title: Text('General de la explotación'),
                    subtitle: Text('Sin asociar a viñedo ni variedad concreta'),
                  ),
                  RadioListTile<String>(
                    value: 'vinedo_concreto',
                    title: Text('Viñedo concreto'),
                    subtitle: Text('Todo el gasto se imputa a un solo viñedo'),
                  ),
                  RadioListTile<String>(
                    value: 'variedad_general',
                    title: Text('Variedad general'),
                    subtitle: Text(
                        'Compartido entre todas las parcelas con esa variedad'),
                  ),
                ],
              ),
            ),
            if (_imputacion == 'vinedo_concreto') ...[
              SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _vinedoId,
                decoration: InputDecoration(
                  labelText: 'Viñedo *',
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
                  labelText: 'Variedad *',
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
                  'Apunte vinculado a un tratamiento del libro PAC.',
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
      case 'insumos_vid':
        return '4% IVA reducido (insumo agrario)';
      case 'seguros':
        return 'Exento de IVA (art. 20 LIVA)';
      case 'vendimia':
      case 'mano_obra':
        return 'Mano de obra agrícola: típicamente sin IVA';
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
