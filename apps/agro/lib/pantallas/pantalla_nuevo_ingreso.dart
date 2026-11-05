import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/finca.dart';
import '../modelos/tercero.dart';

/// Formulario de apunte de ingreso (alta o edición). El bloque más
/// delicado es el cálculo de IVA y compensación REAGP — el régimen
/// fiscal del titular determina qué columna se rellena: en REAGP el
/// comprador paga 12% de compensación, en general repercute IVA.
/// Los importes son sobrescribibles manualmente porque el redondeo
/// de la factura real puede diferir un céntimo de lo calculado.
class PantallaNuevoIngreso extends StatefulWidget {
  final ApunteIngreso? existente;
  PantallaNuevoIngreso({super.key, this.existente});

  @override
  State<PantallaNuevoIngreso> createState() => _PantallaNuevoIngresoState();
}

class _PantallaNuevoIngresoState extends State<PantallaNuevoIngreso> {
  static const _opcionesTipo = <_Opcion>[
    _Opcion('venta_cosecha', 'agro.venta_de_cosecha', 'kg'),
    _Opcion('venta_lena_madera', 'agro.venta_de_lena_madera', 'm3'),
    _Opcion('alquiler_terreno', 'agro.alquiler_de_terreno', 'ha'),
    _Opcion('ayuda_pac', 'agro.ayuda_pac', ''),
    _Opcion('subvencion_autonomica', 'agro.subvencion_autonomica', ''),
    _Opcion('otro', 'agro.otro_ingreso', ''),
  ];

  final _claveFormulario = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _importeBase = TextEditingController();
  final _ivaRepercutido = TextEditingController();
  final _compensacionReagp = TextEditingController();
  final _cantidad = TextEditingController();
  final _numeroFactura = TextEditingController();
  final _notas = TextEditingController();

  String _tipoIngreso = 'venta_cosecha';
  DateTime _fecha = DateTime.now();
  int? _terceroId;
  int? _fincaId;
  String _cultivoId = '';
  String _rutaFoto = '';

  ConfiguracionFiscal _configFiscal = ConfiguracionFiscal();
  List<Tercero> _clientes = const [];
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
    final clientes = await db.listarTerceros(tipo: 'cliente');
    final fincas = await db.listarFincas();
    if (!mounted) return;

    final e = widget.existente;
    if (e != null) {
      _tipoIngreso = e.tipoIngreso;
      _fecha = DateTime.fromMillisecondsSinceEpoch(e.fechaMs);
      _concepto.text = e.concepto;
      _importeBase.text = _formatearCentimos(e.importeBaseCentimos);
      _ivaRepercutido.text = _formatearCentimos(e.ivaRepercutidoCentimos);
      _compensacionReagp.text = _formatearCentimos(e.compensacionReagpCentimos);
      _cantidad.text = e.cantidad == null ? '' : numeroParaEditar(e.cantidad!);
      _terceroId = e.terceroId;
      _fincaId = e.fincaId;
      _cultivoId = e.cultivoId;
      _rutaFoto = e.rutaFotoFactura;
      _numeroFactura.text = e.numeroFactura;
      _notas.text = e.notas;
      _autocalcular = false;
    }

    setState(() {
      _configFiscal = cf;
      _clientes = clientes;
      _fincas = fincas;
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

  _Opcion get _tipoActual =>
      _opcionesTipo.firstWhere((o) => o.codigo == _tipoIngreso,
          orElse: () => _opcionesTipo.last);

  bool get _esAyuda =>
      _tipoIngreso == 'ayuda_pac' || _tipoIngreso == 'subvencion_autonomica';

  bool get _esAlquilerTerreno => _tipoIngreso == 'alquiler_terreno';

  bool get _esCosechaOLena =>
      _tipoIngreso == 'venta_cosecha' || _tipoIngreso == 'venta_lena_madera';

  void _recalcular() {
    if (!_autocalcular || _esAyuda) return;
    final base = _parsearCentimos(_importeBase.text);
    if (_esAlquilerTerreno) {
      // Alquiler agrícola exento de IVA por defecto. Si es para uso
      // no agrícola el usuario sobrescribe con 21%.
      _ivaRepercutido.text = '';
      _compensacionReagp.text = '';
      return;
    }
    if (_configFiscal.regimenIva == 'reagp' && _esCosechaOLena) {
      _compensacionReagp.text = _formatearCentimos((base * 0.12).round());
      _ivaRepercutido.text = '';
    } else if (_configFiscal.regimenIva == 'general' && _tipoIngreso == 'venta_cosecha') {
      _ivaRepercutido.text =
          _formatearCentimos((base * _configFiscal.tipoIvaVentaCosecha).round());
      _compensacionReagp.text = '';
    } else if (_tipoIngreso == 'venta_lena_madera') {
      // Madera al 21% general (no es alimento de primera necesidad).
      _ivaRepercutido.text = _formatearCentimos((base * 0.21).round());
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
    // Antes el guardado fallaba en silencio si validate() devolvía
    // false (el botón quedaba habilitado pero "no pasaba nada") o si
    // la BD lanzaba (FK violation, tabla inexistente, etc.). El
    // tester (2026-05-15) reportó "los ingresos/gastos no se
    // guardan" justo por esto: el flujo terminaba sin feedback.
    if (!(_claveFormulario.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SoleraL10n.t('agro.faltan_datos_obligatorios')),
        ),
      );
      return;
    }
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
      fincaId: _fincaId,
      cultivoId: _cultivoId,
      rutaFotoFactura: _rutaFoto,
      numeroFactura: _numeroFactura.text.trim(),
      notas: _notas.text.trim(),
    );
    final db = BaseDatosAgro.instancia;
    try {
      if (apunte.id == null) {
        await db.guardarApunteIngreso(apunte);
      } else {
        await db.actualizarApunteIngreso(apunte.id!, apunte.toMap()..remove('id'));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SoleraL10n.t(apunte.id == null ? 'agro.ingreso_guardado' : 'agro.ingreso_actualizado')),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${SoleraL10n.t('agro.error_al_guardar_el_ingreso')}: $e'),
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
        title: Text(SoleraL10n.t(widget.existente == null ? 'agro.nuevo_ingreso' : 'agro.editar_ingreso')),
      ),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: textoOGuardando(SoleraL10n.t('guardar'), guardando: _guardando),
        ),
      ]),
      body: Form(
        key: _claveFormulario,
        child: CuerpoResponsivoSolera(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipoIngreso,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.tipo_de_ingreso'),
                border: OutlineInputBorder(),
              ),
              items: _opcionesTipo
                  .map((o) =>
                      DropdownMenuItem(value: o.codigo, child: Text(SoleraL10n.t(o.claveTitulo))))
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
              title: Text(
                  '${_fecha.day}/${_fecha.month}/${_fecha.year}'),
              subtitle: Text(SoleraL10n.t('agro.fecha_de_la_factura')),
              trailing: TextButton(
                onPressed: _elegirFecha,
                child: Text(SoleraL10n.t('agro.cambiar')),
              ),
            ),
            TextFormField(
              controller: _concepto,
              decoration: InputDecoration(
                labelText: '${SoleraL10n.t('agro.concepto')} *',
                hintText: SoleraL10n.t('agro.ejemplo_concepto_ingreso'),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? SoleraL10n.t('agro.concepto_obligatorio') : null,
            ),
            SizedBox(height: 12),
            if (_tipoActual.unidad.isNotEmpty)
              TextFormField(
                controller: _cantidad,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: SoleraL10n.tf('agro.cantidad_unidad', {'unidad': _tipoActual.unidad}),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => validarNumeroOpcional(v, nullSiAmbiguo: true),
              ),
            if (_tipoActual.unidad.isNotEmpty) SizedBox(height: 12),
            TextFormField(
              controller: _importeBase,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '${SoleraL10n.t('agro.importe_base_euros')} *',
                hintText: SoleraL10n.t('agro.sin_iva_ni_compensacion'),
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
                title: Text(SoleraL10n.t('agro.autocalcular_iva_compensacion')),
                subtitle: Text(_textoAutocalculo()),
                onChanged: (v) {
                  setState(() => _autocalcular = v);
                  if (v) _recalcular();
                  setState(() {});
                },
              ),
              if (_configFiscal.regimenIva == 'reagp' && _esCosechaOLena)
                TextFormField(
                  controller: _compensacionReagp,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_autocalcular,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.compensacion_reagp_euros'),
                    border: OutlineInputBorder(),
                  ),
                  validator: validarImporteOpcional,
                ),
              if (!(_configFiscal.regimenIva == 'reagp' && _esCosechaOLena))
                TextFormField(
                  controller: _ivaRepercutido,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_autocalcular,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.iva_repercutido_euros'),
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
                    SoleraL10n.t('agro.configura_regimen_iva_calculo'),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
            SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _terceroId,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.cliente'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(SoleraL10n.t('agro.sin_asociar_parentesis'))),
                ..._clientes.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.nombre +
                          (t.tieneNif ? ' · ${t.nif}' : ' · ${SoleraL10n.t('agro.sin_nif')}')),
                    )),
              ],
              onChanged: (v) => setState(() => _terceroId = v),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _fincaId,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.imputar_a_parcela_opcional'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(SoleraL10n.t('agro.general_parentesis'))),
                ..._fincas.map((f) => DropdownMenuItem(
                      value: f.id,
                      child: Text(f.nombre),
                    )),
              ],
              onChanged: (v) => setState(() => _fincaId = v),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _cultivoId.isEmpty ? null : _cultivoId,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.imputar_a_cultivo_opcional'),
                hintText: SoleraL10n.t('agro.para_ver_rentabilidad_por_cultivo'),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text(SoleraL10n.t('agro.sin_cultivo_parentesis'))),
                ...catalogoCultivos.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.nombreVisible),
                    )),
              ],
              onChanged: (v) => setState(() => _cultivoId = v ?? ''),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _numeroFactura,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('agro.numero_de_factura'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(SoleraL10n.t('agro.foto_de_la_factura'),
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
                labelText: SoleraL10n.t('agro.notas'),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        )),
      ),
    );
  }

  String _textoAutocalculo() {
    if (_esAlquilerTerreno) {
      return SoleraL10n.t('agro.autocalculo_alquiler_exento');
    }
    if (_configFiscal.regimenIva == 'reagp' && _esCosechaOLena) {
      return SoleraL10n.t('agro.autocalculo_reagp_12');
    }
    if (_tipoIngreso == 'venta_lena_madera') {
      return SoleraL10n.t('agro.autocalculo_madera_21');
    }
    if (_configFiscal.regimenIva == 'general' && _tipoIngreso == 'venta_cosecha') {
      return SoleraL10n.t('agro.autocalculo_general_cosecha_4');
    }
    return SoleraL10n.t('agro.configura_regimen_iva_en_ajustes');
  }
}

class _Opcion {
  final String codigo;
  /// Clave de SoleraL10n del nombre visible (se traduce en build).
  final String claveTitulo;
  final String unidad;
  const _Opcion(this.codigo, this.claveTitulo, this.unidad);
}
