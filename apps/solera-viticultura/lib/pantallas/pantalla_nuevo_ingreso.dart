import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/tercero.dart';
import '../modelos/vinedo.dart';

/// Formulario de apunte de ingreso para viticultor/bodega. La
/// diferencia clave vs agro es que aquí distinguimos venta de UVA
/// (4% IVA general / 12% compensación REAGP) de venta de VINO (21%
/// IVA siempre — el vino es producto transformado por la bodega y
/// queda fuera del REAGP). El usuario puede sobrescribir cualquier
/// importe que la app sugiera.
class PantallaNuevoIngreso extends StatefulWidget {
  final ApunteIngreso? existente;
  PantallaNuevoIngreso({super.key, this.existente});

  @override
  State<PantallaNuevoIngreso> createState() => _PantallaNuevoIngresoState();
}

class _PantallaNuevoIngresoState extends State<PantallaNuevoIngreso> {
  static const _opcionesTipo = <_Opcion>[
    // El segundo campo es la clave de traducción del texto visible; el
    // tercero, la unidad que se guarda en BD (no se traduce).
    _Opcion('venta_uva', 'viti.ingreso_venta_uva', 'kg'),
    _Opcion('venta_vino_botella', 'viti.ingreso_venta_vino_botella_detalle', 'botellas'),
    _Opcion('venta_vino_granel', 'viti.ingreso_venta_vino_granel_detalle', 'l'),
    _Opcion('alquiler_terreno', 'viti.ingreso_alquiler_terreno', 'ha'),
    _Opcion('ayuda_pac', 'viti.ingreso_ayuda_pac', ''),
    _Opcion('subvencion_autonomica', 'viti.ingreso_subvencion_autonomica', ''),
    _Opcion('otro', 'viti.otro_ingreso', ''),
  ];

  final _claveFormulario = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _importeBase = TextEditingController();
  final _ivaRepercutido = TextEditingController();
  final _compensacionReagp = TextEditingController();
  final _cantidad = TextEditingController();
  final _numeroFactura = TextEditingController();
  final _loteVino = TextEditingController();
  final _notas = TextEditingController();

  String _tipoIngreso = 'venta_uva';
  DateTime _fecha = DateTime.now();
  int? _terceroId;
  int? _vinedoId;
  String _variedadId = '';
  String _rutaFoto = '';

  ConfiguracionFiscal _configFiscal = ConfiguracionFiscal();
  List<Tercero> _clientes = const [];
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
    final clientes = await db.listarTerceros(tipo: 'cliente');
    final vinedos = await db.listarVinedos();
    if (!mounted) return;

    final e = widget.existente;
    if (e != null) {
      _tipoIngreso = e.tipoIngreso;
      _fecha = DateTime.fromMillisecondsSinceEpoch(e.fechaMs);
      _concepto.text = e.concepto;
      _importeBase.text = _formatearCentimos(e.importeBaseCentimos);
      _ivaRepercutido.text = _formatearCentimos(e.ivaRepercutidoCentimos);
      _compensacionReagp.text = _formatearCentimos(e.compensacionReagpCentimos);
      // Coma decimal sin punto de millares, para que leerNumero lo relea igual.
      final cantidad = e.cantidad;
      _cantidad.text = cantidad == null
          ? ''
          : cantidad == cantidad.roundToDouble()
              ? cantidad.round().toString()
              : cantidad.toString().replaceAll('.', ',');
      _terceroId = e.terceroId;
      _vinedoId = e.vinedoId;
      _variedadId = e.variedadId;
      _rutaFoto = e.rutaFotoFactura;
      _numeroFactura.text = e.numeroFactura;
      _loteVino.text = e.loteVino;
      _notas.text = e.notas;
      _autocalcular = false;
    }

    setState(() {
      _configFiscal = cf;
      _clientes = clientes;
      _vinedos = vinedos;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _concepto,
      _importeBase,
      _ivaRepercutido,
      _compensacionReagp,
      _cantidad,
      _numeroFactura,
      _loteVino,
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

  _Opcion get _tipoActual =>
      _opcionesTipo.firstWhere((o) => o.codigo == _tipoIngreso,
          orElse: () => _opcionesTipo.last);

  bool get _esAyuda =>
      _tipoIngreso == 'ayuda_pac' || _tipoIngreso == 'subvencion_autonomica';

  bool get _esVentaUva => _tipoIngreso == 'venta_uva';
  bool get _esVentaVino =>
      _tipoIngreso == 'venta_vino_botella' ||
      _tipoIngreso == 'venta_vino_granel';
  bool get _esAlquiler => _tipoIngreso == 'alquiler_terreno';

  void _recalcular() {
    if (!_autocalcular || _esAyuda) return;
    final base = _parsearCentimos(_importeBase.text);
    if (_esAlquiler) {
      _ivaRepercutido.text = '';
      _compensacionReagp.text = '';
      return;
    }
    if (_esVentaUva && _configFiscal.regimenIva == 'reagp') {
      _compensacionReagp.text = _formatearCentimos((base * 0.12).round());
      _ivaRepercutido.text = '';
    } else if (_esVentaUva && _configFiscal.regimenIva == 'general') {
      _ivaRepercutido.text =
          _formatearCentimos((base * _configFiscal.tipoIvaVentaUva).round());
      _compensacionReagp.text = '';
    } else if (_esVentaVino) {
      _ivaRepercutido.text =
          _formatearCentimos((base * _configFiscal.tipoIvaVentaVino).round());
      _compensacionReagp.text = '';
    } else {
      _ivaRepercutido.text = _formatearCentimos((base * 0.21).round());
      _compensacionReagp.text = '';
    }
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
    setState(() => _guardando = true);
    final cantidadValor = leerNumero(_cantidad.text, nullSiAmbiguo: true);
    final apunte = ApunteIngreso(
      id: widget.existente?.id,
      fechaMs: _fecha.millisecondsSinceEpoch,
      concepto: _concepto.text.trim(),
      tipoIngreso: _tipoIngreso,
      importeBaseCentimos: _parsearCentimos(_importeBase.text),
      ivaRepercutidoCentimos:
          _esAyuda ? 0 : _parsearCentimos(_ivaRepercutido.text),
      compensacionReagpCentimos:
          _esAyuda ? 0 : _parsearCentimos(_compensacionReagp.text),
      cantidad: cantidadValor,
      unidad: _esAyuda ? '' : _tipoActual.unidad,
      terceroId: _terceroId,
      vinedoId: _vinedoId,
      variedadId: _variedadId,
      loteVino: _loteVino.text.trim(),
      rutaFotoFactura: _rutaFoto,
      numeroFactura: _numeroFactura.text.trim(),
      notas: _notas.text.trim(),
    );
    final db = BaseDatosSoleraViticultura.instancia;
    if (apunte.id == null) {
      await db.guardarApunteIngreso(apunte);
    } else {
      await db.actualizarApunteIngreso(
          apunte.id!, apunte.toMap()..remove('id'));
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
        title:
            Text(widget.existente == null ? SoleraL10n.t('viti.nuevo_ingreso') : SoleraL10n.t('viti.editar_ingreso')),
      ),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: textoOGuardando(SoleraL10n.t('guardar'),
              guardando: _guardando),
        ),
      ]),
      body: Form(
        key: _claveFormulario,
        child: CuerpoResponsivoSolera(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipoIngreso,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.tipo_de_ingreso'),
                border: OutlineInputBorder(),
              ),
              items: _opcionesTipo
                  .map((o) =>
                      DropdownMenuItem(value: o.codigo, child: Text(o.titulo)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _tipoIngreso = v ?? 'otro';
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
                hintText: SoleraL10n.t('viti.concepto_ingreso_ayuda'),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? SoleraL10n.t('viti.concepto_obligatorio') : null,
            ),
            SizedBox(height: separacionCamposSolera),
            if (_tipoActual.unidad.isNotEmpty)
              TextFormField(
                controller: _cantidad,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: SoleraL10n.tf('viti.cantidad_unidad', {'unidad': _tipoActual.unidadVisible}),
                  border: OutlineInputBorder(),
                ),
                validator: (texto) => validarNumeroOpcional(texto, nullSiAmbiguo: true),
              ),
            if (_tipoActual.unidad.isNotEmpty) SizedBox(height: separacionCamposSolera),
            TextFormField(
              controller: _importeBase,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.importe_base_obligatorio'),
                hintText: SoleraL10n.t('viti.sin_iva_ni_compensacion'),
                border: OutlineInputBorder(),
              ),
              validator: validarImporteObligatorio,
              onChanged: (_) {
                _recalcular();
                setState(() {});
              },
            ),
            if (!_esAyuda) ...[
              SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _autocalcular,
                title: Text(SoleraL10n.t('viti.autocalcular_iva_compensacion')),
                subtitle: Text(_textoAutocalculo()),
                onChanged: (v) {
                  setState(() => _autocalcular = v);
                  if (v) _recalcular();
                  setState(() {});
                },
              ),
              if (_esVentaUva && _configFiscal.regimenIva == 'reagp')
                TextFormField(
                  controller: _compensacionReagp,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_autocalcular,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('viti.compensacion_reagp_euros'),
                    border: OutlineInputBorder(),
                  ),
                  validator: validarImporteOpcional,
                ),
              if (!(_esVentaUva && _configFiscal.regimenIva == 'reagp'))
                TextFormField(
                  controller: _ivaRepercutido,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_autocalcular,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('viti.iva_repercutido_euros'),
                    border: OutlineInputBorder(),
                  ),
                  validator: validarImporteOpcional,
                ),
              if (_configFiscal.regimenIva == 'sin_elegir')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    SoleraL10n.t('viti.configura_regimen_iva_calculo'),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
            SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _terceroId,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.cliente'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(SoleraL10n.t('viti.sin_asociar'))),
                ..._clientes.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.nombre +
                          (t.tieneNif ? ' · ${t.nif}' : ' · ${SoleraL10n.t('viti.sin_nif')}')),
                    )),
              ],
              onChanged: (v) => setState(() => _terceroId = v),
            ),
            SizedBox(height: separacionCamposSolera),
            DropdownButtonFormField<int?>(
              initialValue: _vinedoId,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.imputar_vinedo_opcional'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(SoleraL10n.t('viti.general_parentesis'))),
                ..._vinedos.map((v) => DropdownMenuItem(
                      value: v.id,
                      child: Text(v.nombre),
                    )),
              ],
              onChanged: (v) => setState(() => _vinedoId = v),
            ),
            SizedBox(height: separacionCamposSolera),
            DropdownButtonFormField<String>(
              initialValue: _variedadId.isEmpty ? null : _variedadId,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.imputar_variedad_opcional'),
                hintText: SoleraL10n.t('viti.rentabilidad_por_variedad'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text(SoleraL10n.t('viti.sin_variedad'))),
                ...catalogoVariedades.map((v) => DropdownMenuItem(
                      value: v.id,
                      child: Text(v.nombreCanonico),
                    )),
              ],
              onChanged: (v) => setState(() => _variedadId = v ?? ''),
            ),
            SizedBox(height: 12),
            if (_esVentaVino)
              TextFormField(
                controller: _loteVino,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('viti.lote_anada_vino'),
                  hintText: SoleraL10n.t('viti.lote_anada_vino_ayuda'),
                  border: OutlineInputBorder(),
                ),
              ),
            if (_esVentaVino) SizedBox(height: separacionCamposSolera),
            TextFormField(
              controller: _numeroFactura,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.numero_de_factura'),
                border: OutlineInputBorder(),
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
          ],
        ),
        ),
      ),
    );
  }

  String _textoAutocalculo() {
    if (_esAlquiler) {
      return SoleraL10n.t('viti.autocalculo_alquiler');
    }
    if (_esVentaUva && _configFiscal.regimenIva == 'reagp') {
      return SoleraL10n.t('viti.autocalculo_reagp_uva');
    }
    if (_esVentaUva && _configFiscal.regimenIva == 'general') {
      return SoleraL10n.t('viti.autocalculo_general_uva');
    }
    if (_esVentaVino) {
      return SoleraL10n.t('viti.autocalculo_vino');
    }
    return SoleraL10n.t('viti.configura_regimen_iva');
  }
}

class _Opcion {
  final String codigo;
  final String claveTitulo;
  final String unidad;
  const _Opcion(this.codigo, this.claveTitulo, this.unidad);

  String get titulo => SoleraL10n.t(claveTitulo);

  /// Unidad tal como se enseña (la guardada en BD es [unidad]).
  String get unidadVisible => unidad == 'botellas' ? SoleraL10n.t('viti.unidad_botellas') : unidad;
}
