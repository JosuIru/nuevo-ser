import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/finca.dart';
import '../modelos/tercero.dart';
import '../utiles/numeros_formulario.dart';

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
    _Opcion('venta_cosecha', 'Venta de cosecha', 'kg'),
    _Opcion('venta_lena_madera', 'Venta de leña / madera', 'm3'),
    _Opcion('alquiler_terreno', 'Alquiler de terreno', 'ha'),
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
        const SnackBar(
          content: Text(
            'Faltan datos obligatorios — revisa los campos marcados en rojo.',
          ),
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
          content: Text(apunte.id == null ? 'Ingreso guardado.' : 'Ingreso actualizado.'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error guardando ingreso: $e'),
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
                hintText: 'Ej: 2.500 kg aceituna picual',
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
                validator: (v) => validarNumeroOpcional(v, nullSiAmbiguo: true),
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
                title: Text('Autocalcular IVA / compensación'),
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
                    labelText: 'Compensación REAGP (€)',
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
              initialValue: _fincaId,
              decoration: InputDecoration(
                labelText: 'Imputar a parcela (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: null, child: Text('(general)')),
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
                labelText: 'Imputar a cultivo (opcional)',
                hintText: 'Para ver rentabilidad por cultivo',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text('(sin cultivo)')),
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
    if (_esAlquilerTerreno) {
      return 'Alquiler agrícola exento de IVA (cambia a 21% si es uso no agrícola)';
    }
    if (_configFiscal.regimenIva == 'reagp' && _esCosechaOLena) {
      return 'REAGP: 12% sobre la base como compensación al agricultor';
    }
    if (_tipoIngreso == 'venta_lena_madera') {
      return 'Madera: 21% IVA general';
    }
    if (_configFiscal.regimenIva == 'general' && _tipoIngreso == 'venta_cosecha') {
      return 'Régimen general: 4% IVA en venta de cosecha (alimento 1ª necesidad)';
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
