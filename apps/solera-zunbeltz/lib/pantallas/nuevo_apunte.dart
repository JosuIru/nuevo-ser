import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/constantes.dart';
import '../branding.dart';
import '../modelos/indicadores_seguimiento.dart'
    show baseDesdeTotalConIva, eurosDesdeCentimos;
import '../utiles/calculo_apunte.dart';
import 'widgets/barra_inferior_formulario.dart';
import 'widgets/campo_partida_gasto.dart';
import 'widgets/cuerpo_responsivo.dart';
import '../utiles/numeros.dart';

/// Alta de un apunte económico (ingreso o gasto) de un proyecto de test.
class NuevoApunte extends StatefulWidget {
  const NuevoApunte({
    super.key,
    required this.proyectoId,
    required this.fincaId,
    this.gastoInicial,
  });

  final int proyectoId;
  final int fincaId;

  /// Llega relleno como gasto (p. ej. desde una tarea de compra con coste).
  final ApunteEconomico? gastoInicial;

  @override
  State<NuevoApunte> createState() => _NuevoApunteState();
}

class _NuevoApunteState extends State<NuevoApunte> {
  /// Un doble toque en Guardar no debe guardar dos veces.
  bool _guardando = false;

  Future<void> _guardarUnaVez() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      await _guardar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  final _bd = BaseDatosSoleraZunbeltz();
  final _concepto = TextEditingController();
  final _partida = TextEditingController();
  final _cantidad = TextEditingController();
  final _precio = TextEditingController();
  final _notas = TextEditingController();

  String _tipo = tipoApuntePorDefecto;
  String _categoria = categoriaGastoPorDefecto;
  String _asumidoPor = asumidoPorDefecto('');
  int _iva = ivaPorDefecto;
  DateTime _fecha = DateTime.now();

  void _cambiarTipo(String? v) {
    if (v == null) return;
    setState(() {
      _tipo = v;
      // Al cambiar gasto/ingreso, la categoría debe ser del catálogo correcto.
      _categoria = categoriasDe(v).first.codigo;
      _partida.clear();
      _asumidoPor = asumidoPorDefecto('');
    });
  }

  /// Nombre del proyecto, bajo el título.
  String _nombreProyecto = '';

  @override
  void initState() {
    super.initState();
    _cantidad.addListener(_recalcular);
    _precio.addListener(_recalcular);
    _bd.obtenerProyecto(widget.proyectoId).then((proyecto) {
      if (mounted && proyecto != null) {
        setState(() => _nombreProyecto = proyecto.nombre);
      }
    });
    final inicial = widget.gastoInicial;
    if (inicial == null) return;
    _tipo = 'gasto';
    _categoria = inicial.categoria;
    _asumidoPor = asumidoPorDefecto(inicial.partida);
    _concepto.text = inicial.concepto;
    if (inicial.importeCentimos > 0) {
      // El importe guardado lleva IVA; aquí se escribe sin él.
      _precio.text = eurosDesdeCentimos(
          baseDesdeTotalConIva(inicial.importeCentimos, _iva));
    }
    if (inicial.fechaMs > 0) {
      _fecha = DateTime.fromMillisecondsSinceEpoch(inicial.fechaMs);
    }
  }

  bool _partidaInicialPuesta = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // La etiqueta de la partida depende del idioma, que no se puede leer
    // en initState.
    final inicial = widget.gastoInicial;
    if (_partidaInicialPuesta || inicial == null) return;
    _partidaInicialPuesta = true;
    _partida.text = etiquetaPartida(inicial.categoria, inicial.partida,
        Localizations.localeOf(context).languageCode);
  }

  @override
  void dispose() {
    _concepto.dispose();
    _partida.dispose();
    _cantidad.dispose();
    _precio.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _recalcular() => setState(() {});

  /// Cantidad escrita; null si está vacía o no se entiende.
  double? get _cantidadLeida => _cantidad.text.trim().isEmpty
      ? null
      : leerNumero(_cantidad.text, nullSiAmbiguo: true);

  ({int base, int cuota, int total})? get _cuentas {
    final precio = leerNumero(_precio.text, nullSiAmbiguo: true);
    if (precio == null) return null;
    if (_cantidad.text.trim().isNotEmpty && _cantidadLeida == null) return null;
    return cuentasApunte(
        cantidad: _cantidadLeida, precioSinIva: precio, ivaPorcentaje: _iva);
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(_fecha.year - 2),
      lastDate: DateTime(_fecha.year + 1),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    final cuentas = _cuentas;
    if (cuentas == null || cuentas.total <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.apuImporteObligatorio)));
      return;
    }
    // La cantidad no tiene columna propia: queda en las notas.
    final detalle = _cantidadLeida == null
        ? ''
        : textos.apuCantidadPorPrecio(
            _cantidad.text.trim(), '${_precio.text.trim()} €');
    final notas = [
      if (detalle.isNotEmpty) detalle,
      if (_notas.text.trim().isNotEmpty) _notas.text.trim(),
    ].join('\n');
    await _bd.guardarApunte(ApunteEconomico(
      fincaId: widget.fincaId,
      proyectoId: widget.proyectoId,
      tipo: _tipo,
      categoria: _categoria,
      partida: _tipo == 'gasto' ? codigoPartida(_categoria, _partida.text) : '',
      concepto: _concepto.text.trim(),
      importeCentimos: cuentas.total,
      ivaPorcentaje: _iva,
      fechaMs: _fecha.millisecondsSinceEpoch,
      notas: notas,
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
      asumidoPor: _tipo == 'gasto' ? _asumidoPor : asumidoPorTester,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.apuGuardado)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final esGasto = _tipo == 'gasto';
    final cuentas = _cuentas;
    final euros = NumberFormat.currency(
        locale: 'es',
        symbol: '€',
        decimalDigits: 2,
        customPattern: '#,##0.00 ¤');
    String importe(int centimos) => euros.format(centimos / 100);
    final cantidadEscrita = _cantidad.text.trim();
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(textos.apuApuntar),
          if (_nombreProyecto.isNotEmpty)
            Text(_nombreProyecto,
                style: estilos.bodyMedium
                    ?.copyWith(color: esquema.onSurfaceVariant)),
        ]),
      ),
      bottomNavigationBar: BarraInferiorFormulario(botones: [
        FilledButton.icon(
          onPressed: _guardando ? null : _guardarUnaVez,
          icon: const Icon(Icons.check),
          label:
              Text(esGasto ? textos.apuGuardarGasto : textos.apuGuardarIngreso),
        ),
      ]),
      body: CuerpoResponsivo(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'gasto',
                    label: Text(
                        buscarOpcion(tiposApunte, 'gasto')!.etiqueta(idioma))),
                ButtonSegment(
                    value: 'ingreso',
                    icon: const Icon(Icons.trending_up),
                    label: Text(buscarOpcion(tiposApunte, 'ingreso')!
                        .etiqueta(idioma))),
              ],
              selected: {_tipo},
              onSelectionChanged: (elegidos) => _cambiarTipo(elegidos.first),
            ),
            const SizedBox(height: 24),
            // El importe en grande (sin IVA) y de dónde sale.
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(importe(cuentas?.base ?? 0),
                    style: estilos.displayMedium?.copyWith(
                        fontFamily: familiaTitularZunbeltz,
                        fontWeight: FontWeight.w700,
                        color: cuentas == null
                            ? esquema.onSurfaceVariant
                            : esquema.onSurface)),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                cantidadEscrita.isEmpty || _precio.text.trim().isEmpty
                    ? textos.apuSinIva
                    : textos.apuCantidadPorPrecio(
                        cantidadEscrita, '${_precio.text.trim()} €'),
                textAlign: TextAlign.center,
                style: estilos.bodyLarge
                    ?.copyWith(color: esquema.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 24),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: TextField(
                  controller: _cantidad,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: textos.apuCantidad,
                      helperText: textos.apuCantidadAyuda,
                      helperMaxLines: 3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _precio,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: cantidadEscrita.isEmpty
                          ? textos.apuImporteSinIva
                          : textos.apuPrecioUnitario,
                      suffixText: '€'),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              isExpanded: true,
              key: ValueKey(_tipo),
              initialValue: _categoria,
              decoration: InputDecoration(
                labelText: esGasto ? textos.apuBloque : textos.apuCategoria,
                helperText: _categoria == categoriaAmortizacion
                    ? textos.apuAmortizacionDetalle
                    : null,
              ),
              items: [
                for (final c in categoriasDe(_tipo))
                  DropdownMenuItem(
                      value: c.codigo, child: Text(c.etiqueta(idioma))),
              ],
              onChanged: (v) => setState(() {
                if (v == null || v == _categoria) return;
                _categoria = v;
                _partida.clear();
                _asumidoPor = asumidoPorDefecto('');
              }),
            ),
            if (esGasto) ...[
              const SizedBox(height: 16),
              CampoPartidaGasto(
                key: ValueKey(_categoria),
                bloque: _categoria,
                controlador: _partida,
                idioma: idioma,
                etiqueta: textos.apuPartida,
                alElegirDelCatalogo: (codigo) =>
                    setState(() => _asumidoPor = asumidoPorDefecto(codigo)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(textos.apuPartidasAnexo,
                    style: estilos.bodySmall
                        ?.copyWith(color: esquema.onSurfaceVariant)),
              ),
            ],
            const SizedBox(height: 20),
            // Cuota y total con IVA; el tipo se cambia tocando la cuota.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              decoration: BoxDecoration(
                color: esquema.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
              ),
              child: Row(children: [
                Expanded(
                  child: PopupMenuButton<int>(
                    tooltip: textos.apuCambiarIva,
                    initialValue: _iva,
                    onSelected: (valor) => setState(() => _iva = valor),
                    itemBuilder: (_) => [
                      for (final valor in tiposIva)
                        PopupMenuItem(value: valor, child: Text('$valor %')),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(
                              child: Text(textos.apuCuotaIva('$_iva'),
                                  style: estilos.bodyMedium?.copyWith(
                                      color: esquema.onSurfaceVariant)),
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: esquema.onSurfaceVariant),
                          ]),
                          Text(importe(cuentas?.cuota ?? 0),
                              style: estilos.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(textos.apuTotalConIva,
                              style: estilos.bodyMedium
                                  ?.copyWith(color: esquema.onSurfaceVariant)),
                        ),
                        Text(importe(cuentas?.total ?? 0),
                            style: estilos.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            if (esGasto) ...[
              const SizedBox(height: 20),
              Text(textos.apuAsumidoPor,
                  style: estilos.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  for (final opcion in asumidoPorOpciones)
                    ButtonSegment(
                        value: opcion.codigo,
                        label: Text(opcion.etiqueta(idioma))),
                ],
                selected: {_asumidoPor},
                onSelectionChanged: (seleccion) =>
                    setState(() => _asumidoPor = seleccion.first),
              ),
            ],
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: InkWell(
                  onTap: _elegirFecha,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: textos.comunFecha,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(_textoFecha(textos, idioma),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                    controller: _concepto,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: textos.apuConcepto)),
              ),
            ]),
            const SizedBox(height: 16),
            TextField(
                controller: _notas,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: textos.apuNotas)),
          ],
        ),
      ),
    );
  }

  String _textoFecha(AppLocalizations textos, String idioma) {
    final hoy = DateTime.now();
    if (_fecha.year == hoy.year &&
        _fecha.month == hoy.month &&
        _fecha.day == hoy.day) {
      return textos.ganFechaHoy(DateFormat('d MMM', idioma).format(_fecha));
    }
    return DateFormat('d MMM yyyy', idioma).format(_fecha);
  }
}
