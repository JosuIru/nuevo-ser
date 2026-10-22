import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/amortizacion.dart';
import '../modelos/constantes.dart';
import '../modelos/indicadores_seguimiento.dart' show eurosDesdeCentimos;
import '../utiles/numeros.dart';
import 'widgets/confirmar_borrado.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Inventario de bienes amortizables del espacio (instalaciones, material
/// ganadero, adecuaciones de finca), como la hoja «Listado-amortización»
/// de Zunbeltz. Coordinación lo mantiene; el resto lo consulta.
class PantallaInventario extends StatefulWidget {
  const PantallaInventario({super.key});

  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<BienAmortizable> _bienes = const [];
  bool _cargando = true;

  bool get _gestiona => politicaEspacioActual.puedeEditarInventario;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final bienes = await _bd.listarBienes();
      if (!mounted) return;
      setState(() {
        _bienes = bienes;
        _cargando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _editar([BienAmortizable? bien]) async {
    final guardado = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => FormularioBienAmortizable(bien: bien)));
    if (guardado == true) await _cargar();
  }

  Future<void> _borrar(BienAmortizable bien) async {
    if (!await confirmarBorrado(context)) return;
    await _bd.borrarBien(bien.id!);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final grupos = partidasDe(categoriaAmortizacion);
    return Scaffold(
      appBar: AppBar(title: Text(textos.invTitulo)),
      floatingActionButton: _gestiona
          ? FloatingActionButton.extended(
              onPressed: () => _editar(),
              icon: const Icon(Icons.add),
              label: Text(textos.invNuevo),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : CuerpoResponsivo(
              child: ListView(
                padding: rellenoSobreBarraSistema(
                    context, const EdgeInsets.fromLTRB(16, 12, 16, 88)),
                children: [
                  Text(textos.invIntro,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  if (_bienes.isEmpty) Text(textos.invVacio),
                  for (final grupo in [
                    ...grupos.map((opcion) => opcion.codigo),
                    // Por si llega un grupo que esta versión no conoce.
                    ..._bienes
                        .map((bien) => bien.grupo)
                        .where((codigo) => buscarOpcion(grupos, codigo) == null)
                        .toSet(),
                  ])
                    if (_bienes.any((bien) => bien.grupo == grupo)) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                            etiquetaPartida(
                                categoriaAmortizacion, grupo, idioma),
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      for (final bien
                          in _bienes.where((bien) => bien.grupo == grupo))
                        Card(
                          child: ListTile(
                            title: Text(bien.nombre),
                            subtitle: Text([
                              if (bien.especie.isNotEmpty)
                                buscarOpcion(especiesGanado, bien.especie)
                                        ?.etiqueta(idioma) ??
                                    bien.especie,
                              resumenBien(textos, bien),
                            ].join(' · ')),
                            trailing: Text(
                                '${eurosDesdeCentimos(bien.totalCentimos)} €'),
                            onTap: _gestiona ? () => _editar(bien) : null,
                            onLongPress: _gestiona ? () => _borrar(bien) : null,
                          ),
                        ),
                    ],
                ],
              ),
            ),
    );
  }
}

/// «2 × 11.375,42 € · total 27.528,50 € · 382,34 € al mes».
String resumenBien(AppLocalizations textos, BienAmortizable bien) =>
    textos.invResumen(
      numeroLegible(bien.unidades),
      '${eurosDesdeCentimos(bien.precioUnidadCentimos)} €',
      '${eurosDesdeCentimos(bien.totalCentimos)} €',
      '${eurosDesdeCentimos(bien.cuotaMensualCentimos.round())} €',
    );

/// 2 → «2»; 2,5 → «2,5».
String numeroLegible(double numero) => numero == numero.roundToDouble()
    ? numero.toStringAsFixed(0)
    : numero
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll('.', ',');

/// Alta o edición de un bien del inventario.
class FormularioBienAmortizable extends StatefulWidget {
  const FormularioBienAmortizable({super.key, this.bien});

  final BienAmortizable? bien;

  @override
  State<FormularioBienAmortizable> createState() =>
      _FormularioBienAmortizableState();
}

class _FormularioBienAmortizableState extends State<FormularioBienAmortizable> {
  final _bd = BaseDatosSoleraZunbeltz();
  late final _nombre = TextEditingController(text: widget.bien?.nombre ?? '');
  late final _precio = TextEditingController(
      text: widget.bien == null
          ? ''
          : eurosDesdeCentimos(widget.bien!.precioUnidadCentimos));
  late final _unidades =
      TextEditingController(text: numeroLegible(widget.bien?.unidades ?? 1));
  late final _vidaUtil =
      TextEditingController(text: '${widget.bien?.vidaUtilMeses ?? 72}');
  late final _notas = TextEditingController(text: widget.bien?.notas ?? '');
  late String _grupo = widget.bien?.grupo ?? grupoBienPorDefecto;
  late String _especie = widget.bien?.especie ?? '';
  late int _iva = widget.bien?.ivaPorcentaje ?? 21;
  bool _guardando = false;

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _precio,
      _unidades,
      _vidaUtil,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  /// El bien tal como está escrito (para la vista previa y para guardar).
  BienAmortizable get _bienEscrito => BienAmortizable(
        id: widget.bien?.id,
        nombre: _nombre.text.trim(),
        grupo: _grupo,
        especie: _especie,
        precioUnidadCentimos: centimosDesdeTexto(_precio.text) ?? 0,
        unidades: leerNumero(_unidades.text) ?? 1,
        ivaPorcentaje: _iva,
        vidaUtilMeses: int.tryParse(_vidaUtil.text.trim()) ?? 0,
        notas: _notas.text.trim(),
      );

  void _avisar(String mensaje) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(mensaje)));

  Future<void> _guardar() async {
    if (_guardando) return;
    final textos = AppLocalizations.of(context);
    final bien = _bienEscrito;
    if (bien.nombre.isEmpty) return _avisar(textos.invNombreObligatorio);
    final precio = centimosDesdeTexto(_precio.text);
    if (precio == null || precio <= 0) {
      return _avisar(textos.apuImporteObligatorio);
    }
    if (bien.vidaUtilMeses < 1) return _avisar(textos.invVidaUtilObligatoria);
    setState(() => _guardando = true);
    try {
      if (bien.id == null) {
        await _bd.guardarBien(bien);
      } else {
        await _bd.actualizarBien(bien);
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final vistaPrevia = _bienEscrito;
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.bien == null ? textos.invNuevo : textos.invEditar)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: textos.invNombre),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue:
                  buscarOpcion(partidasDe(categoriaAmortizacion), _grupo) ==
                          null
                      ? grupoBienPorDefecto
                      : _grupo,
              decoration: InputDecoration(labelText: textos.invGrupo),
              items: [
                for (final opcion in partidasDe(categoriaAmortizacion))
                  DropdownMenuItem(
                      value: opcion.codigo,
                      child: Text(opcion.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _grupo = valor ?? _grupo),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: buscarOpcion(especiesGanado, _especie) == null
                  ? ''
                  : _especie,
              decoration: InputDecoration(labelText: textos.invEspecie),
              items: [
                DropdownMenuItem(
                    value: '', child: Text(textos.invEspecieComun)),
                for (final especie in especiesGanado)
                  DropdownMenuItem(
                      value: especie.codigo,
                      child: Text(especie.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _especie = valor ?? ''),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _precio,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: textos.invPrecioUnidad, suffixText: '€'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _unidades,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: textos.invUnidades),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: tiposIva.contains(_iva) ? _iva : 21,
                  decoration: InputDecoration(labelText: textos.apuIva),
                  items: [
                    for (final tipo in tiposIva)
                      DropdownMenuItem(value: tipo, child: Text('$tipo %')),
                  ],
                  onChanged: (valor) => setState(() => _iva = valor ?? _iva),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _vidaUtil,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: textos.invVidaUtil),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Text(textos.invTotal)),
                    Text('${eurosDesdeCentimos(vistaPrevia.totalCentimos)} €'),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: Text(textos.invCuotaMensual)),
                    Text(
                        '${eurosDesdeCentimos(vistaPrevia.cuotaMensualCentimos.round())} €',
                        style: Theme.of(context).textTheme.titleMedium),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notas,
              maxLines: 2,
              decoration: InputDecoration(labelText: textos.apuNotas),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
