import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../utiles/numeros_formulario.dart';
import '../datos/base_datos.dart';
import '../modelos/apiario.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/tercero.dart';

/// Formulario de apunte de ingreso (alta o edición). El bloque más
/// delicado es el cálculo de IVA y compensación REAGP — el régimen
/// fiscal del titular determina qué columna se rellena: en REAGP el
/// comprador paga 12% de compensación, en general repercute IVA.
/// El usuario puede sobrescribir manualmente cualquier importe que
/// la app sugiera porque el redondeo de la factura real puede
/// diferir un céntimo de lo calculado.
class PantallaNuevoIngreso extends StatefulWidget {
  final ApunteIngreso? existente;
  PantallaNuevoIngreso({super.key, this.existente});

  @override
  State<PantallaNuevoIngreso> createState() => _PantallaNuevoIngresoState();
}

class _PantallaNuevoIngresoState extends State<PantallaNuevoIngreso> {
  static const _opcionesTipo = <_Opcion>[
    _Opcion('venta_miel', 'Venta de miel', 'kg'),
    _Opcion('venta_polen', 'Venta de polen', 'kg'),
    _Opcion('venta_cera', 'Venta de cera', 'kg'),
    _Opcion('venta_propoleo', 'Venta de propóleo', 'kg'),
    _Opcion('venta_jalea', 'Venta de jalea real', 'kg'),
    _Opcion('alquiler_polinizacion', 'Alquiler colmenas (polinización)', 'colmenas'),
    _Opcion('ayuda_pac', 'Ayuda PAC', ''),
    _Opcion('subvencion_autonomica', 'Subvención autonómica', ''),
    _Opcion('otro', 'Otro ingreso', ''),
  ];

  final _claveFormulario = GlobalKey<FormState>();
  final _concepto = TextEditingController();
  final _importeBase = TextEditingController();
  final _ivaRepercutido = TextEditingController();
  final _compensacionReagp = TextEditingController();
  final _cantidad = TextEditingController();
  final _numeroFactura = TextEditingController();
  final _notas = TextEditingController();

  String _tipoIngreso = 'venta_miel';
  DateTime _fecha = DateTime.now();
  int? _terceroId;
  int? _apiarioId;
  String _rutaFoto = '';

  ConfiguracionFiscal _configFiscal = ConfiguracionFiscal();
  List<Tercero> _clientes = const [];
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
    final clientes = await db.listarTerceros(tipo: 'cliente');
    final apiarios = await db.listarApiarios();
    if (!mounted) return;

    final e = widget.existente;
    if (e != null) {
      _tipoIngreso = e.tipoIngreso;
      _fecha = DateTime.fromMillisecondsSinceEpoch(e.fechaMs);
      _concepto.text = e.concepto;
      _importeBase.text = _formatearCentimos(e.importeBaseCentimos);
      _ivaRepercutido.text = _formatearCentimos(e.ivaRepercutidoCentimos);
      _compensacionReagp.text = _formatearCentimos(e.compensacionReagpCentimos);
      _cantidad.text = e.cantidad?.toString() ?? '';
      _terceroId = e.terceroId;
      _apiarioId = e.apiarioId;
      _rutaFoto = e.rutaFotoFactura;
      _numeroFactura.text = e.numeroFactura;
      _notas.text = e.notas;
      _autocalcular = false; // edición: respetar valores guardados
    }

    setState(() {
      _configFiscal = cf;
      _clientes = clientes;
      _apiarios = apiarios;
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
    return (centimos / 100).toStringAsFixed(2);
  }

  /// Vacío o ilegible cuenta 0 (para el autocálculo); al guardar, el
  /// validador del campo ya ha avisado si no se entendía.
  int _parsearCentimos(String texto) => centimosDesdeTexto(texto) ?? 0;

  _Opcion get _tipoActual =>
      _opcionesTipo.firstWhere((o) => o.codigo == _tipoIngreso,
          orElse: () => _opcionesTipo.last);

  bool get _esAyuda =>
      _tipoIngreso == 'ayuda_pac' || _tipoIngreso == 'subvencion_autonomica';

  bool get _esPolinizacion => _tipoIngreso == 'alquiler_polinizacion';

  void _recalcular() {
    if (!_autocalcular || _esAyuda) return;
    final base = _parsearCentimos(_importeBase.text);
    if (_configFiscal.regimenIva == 'reagp' && !_esPolinizacion) {
      // Compensación 12%, no se repercute IVA en REAGP.
      _compensacionReagp.text = _formatearCentimos((base * 0.12).round());
      _ivaRepercutido.text = '';
    } else {
      // Régimen general (4% miel) o polinización (21% siempre).
      final tipo = _esPolinizacion
          ? _configFiscal.tipoIvaPolinizacion
          : _configFiscal.tipoIvaVentaProducto;
      _ivaRepercutido.text = _formatearCentimos((base * tipo).round());
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
      apiarioId: _apiarioId,
      rutaFotoFactura: _rutaFoto,
      numeroFactura: _numeroFactura.text.trim(),
      notas: _notas.text.trim(),
    );
    final db = BaseDatosSoleraApicola.instancia;
    if (apunte.id == null) {
      await db.guardarApunteIngreso(apunte);
    } else {
      await db.actualizarApunteIngreso(apunte.id!, apunte.toMap()..remove('id'));
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
        title: Text(widget.existente == null ? 'Nuevo ingreso' : 'Editar ingreso'),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipoIngreso,
              decoration: InputDecoration(
                labelText: 'Tipo de ingreso',
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
                hintText: 'Ej: 30 kg miel mil flores',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Concepto obligatorio' : null,
            ),
            SizedBox(height: 12),
            if (_tipoActual.unidad.isNotEmpty)
              TextFormField(
                controller: _cantidad,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Cantidad (${_tipoActual.unidad})',
                  border: OutlineInputBorder(),
                ),
                validator: validarCantidadOpcional,
              ),
            if (_tipoActual.unidad.isNotEmpty) SizedBox(height: 12),
            TextFormField(
              controller: _importeBase,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Importe base (€) *',
                hintText: 'Sin IVA ni compensación',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'Importe obligatorio';
                if (centimosDesdeTexto(v!) == null) return textoNumeroNoValido;
                if (_parsearCentimos(v) <= 0) return 'Mayor que cero';
                return null;
              },
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
                title: Text('Autocalcular IVA / compensación'),
                subtitle: Text(_textoAutocalculo()),
                onChanged: (v) {
                  setState(() => _autocalcular = v);
                  if (v) _recalcular();
                  setState(() {});
                },
              ),
              if (_configFiscal.regimenIva == 'reagp' && !_esPolinizacion)
                TextFormField(
                  controller: _compensacionReagp,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_autocalcular,
                  decoration: InputDecoration(
                    labelText: 'Compensación REAGP (€)',
                    border: OutlineInputBorder(),
                  ),
                  validator: validarImporteOpcional,
                ),
              if (_configFiscal.regimenIva == 'general' || _esPolinizacion)
                TextFormField(
                  controller: _ivaRepercutido,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  enabled: !_autocalcular,
                  decoration: InputDecoration(
                    labelText: 'IVA repercutido (€)',
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
                    'Configura el régimen de IVA en Ajustes → Configuración fiscal '
                    'para que la app calcule la compensación o el IVA repercutido.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
            SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _terceroId,
              decoration: InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text('(sin asociar)')),
                ..._clientes.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.nombre +
                          (t.tieneNif ? ' · ${t.nif}' : ' · sin NIF')),
                    )),
              ],
              onChanged: (v) => setState(() => _terceroId = v),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _apiarioId,
              decoration: InputDecoration(
                labelText: 'Imputar al colmenar (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text('(general)')),
                ..._apiarios.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.nombre),
                    )),
              ],
              onChanged: (v) => setState(() => _apiarioId = v),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _numeroFactura,
              decoration: InputDecoration(
                labelText: 'Nº de factura',
                border: OutlineInputBorder(),
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
    if (_configFiscal.regimenIva == 'reagp' && !_esPolinizacion) {
      return 'REAGP: 12% sobre la base como compensación al apicultor';
    }
    if (_esPolinizacion) {
      return 'Polinización: 21% IVA general (servicio agrícola complementario)';
    }
    if (_configFiscal.regimenIva == 'general') {
      return 'Régimen general: 4% IVA en venta de productos apícolas';
    }
    return 'Configura régimen de IVA en Ajustes';
  }
}

class _Opcion {
  final String codigo;
  final String titulo;
  final String unidad;
  const _Opcion(this.codigo, this.titulo, this.unidad);
}
