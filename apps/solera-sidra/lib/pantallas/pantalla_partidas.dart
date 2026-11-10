import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/partida_manzana.dart';
import '../modelos/pomarada.dart';
import '../modelos/sagardotegi.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';

/// Entradas de fruta: el «registro de entrada en elaboración» del pliego.
class PantallaPartidas extends StatefulWidget {
  const PantallaPartidas({super.key});

  @override
  State<PantallaPartidas> createState() => _PantallaPartidasState();
}

class _DatosPartidas {
  _DatosPartidas(this.partidas, this.pomaradas, this.prensadas);

  final List<PartidaManzana> partidas;
  final Map<int, Pomarada> pomaradas;
  final Set<int> prensadas;
}

class _PantallaPartidasState extends State<PantallaPartidas> {
  late Future<_DatosPartidas> _datos = _cargar();

  Future<_DatosPartidas> _cargar() async {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    return _DatosPartidas(
      await baseDatos.listarPartidas(),
      {
        for (final pomarada in await baseDatos.listarPomaradas())
          pomarada.id!: pomarada
      },
      await baseDatos.partidasPrensadas(),
    );
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    setState(() {
      _datos = _cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('sidr.entradas_fruta'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('sidr.nueva_entrada'),
        onPressed: () => _abrir(const PantallaEditarPartida()),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_DatosPartidas>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (datos.partidas.isEmpty) {
            return Center(child: Text(SoleraL10n.t('sidr.sin_entradas')));
          }
          return ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 88)),
            children: [
              for (final partida in datos.partidas)
                ListTile(
                  leading: Icon(partida.propia
                      ? Icons.home_outlined
                      : Icons.local_shipping_outlined),
                  title: Text(
                      '${formatearNumero(partida.kilos, decimales: 0)} kg · '
                      '${partida.propia ? (datos.pomaradas[partida.pomaradaId]?.nombre ?? SoleraL10n.t('sidr.propia')) : partida.proveedor}'),
                  subtitle: Text([
                    formatearFecha(partida.fechaEntregaMs),
                    nombreValor('fruta', partida.fruta),
                    if (partida.variedades.isNotEmpty)
                      partida.variedades.map(nombreVariedad).join(', '),
                    datos.prensadas.contains(partida.id)
                        ? SoleraL10n.t('sidr.prensada')
                        : SoleraL10n.t('sidr.sin_prensar'),
                  ].join(' · ')),
                  onTap: () => _abrir(PantallaEditarPartida(partida: partida)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Alta o edición de una entrada de fruta.
class PantallaEditarPartida extends StatefulWidget {
  const PantallaEditarPartida({super.key, this.partida});

  final PartidaManzana? partida;

  @override
  State<PantallaEditarPartida> createState() => _PantallaEditarPartidaState();
}

class _PantallaEditarPartidaState extends State<PantallaEditarPartida> {
  late final PartidaManzana? _original = widget.partida;
  late int _fechaEntregaMs =
      _original?.fechaEntregaMs ?? DateTime.now().millisecondsSinceEpoch;
  late int? _fechaRecoleccionMs = _original?.fechaRecoleccionMs;
  late String _fruta = _original?.fruta ?? 'manzana';
  late bool _propia = _original?.propia ?? true;
  late int? _pomaradaId = _original?.pomaradaId;
  late bool _proveedorRegistrado = _original?.proveedorRegistradoDop ?? false;
  late String _estadoFruta = _original?.estadoFruta ?? 'sana';
  late Set<String> _variedades = {...?_original?.variedades};
  late final _kilos = TextEditingController(
      text: _original == null
          ? ''
          : formatearNumero(_original.kilos, decimales: 0));
  late final _proveedor = TextEditingController(text: _original?.proveedor);
  late final _procedencia = TextEditingController(text: _original?.procedencia);
  late final _documento =
      TextEditingController(text: _original?.documentoTransporte);
  late final _precio = TextEditingController(
      text: (_original?.precioCentimosKg ?? 0) > 0
          ? formatearNumero(_original!.precioCentimosKg / 100, decimales: 2)
          : '');
  late final _notas = TextEditingController(text: _original?.notas);
  List<Pomarada> _pomaradas = const [];
  Sagardotegi _sagardotegi = Sagardotegi();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    final pomaradas = await baseDatos.listarPomaradas();
    final sagardotegi = await baseDatos.obtenerSagardotegi();
    if (!mounted) return;
    setState(() {
      _pomaradas = pomaradas;
      _sagardotegi = sagardotegi;
      if (_original == null && sagardotegi.perfil == 'txakoli') _fruta = 'uva';
    });
  }

  @override
  void dispose() {
    for (final controlador in [
      _kilos,
      _proveedor,
      _procedencia,
      _documento,
      _precio,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Pomarada? get _pomaradaElegida {
    for (final pomarada in _pomaradas) {
      if (pomarada.id == _pomaradaId) return pomarada;
    }
    return null;
  }

  Future<void> _guardar() async {
    final kilos = leerNumero(_kilos.text);
    final faltaOrigen =
        _propia ? _pomaradaId == null : _proveedor.text.trim().isEmpty;
    if (kilos == null || kilos <= 0 || faltaOrigen) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SoleraL10n.t('sidr.falta_kilos_origen'))));
      return;
    }
    await BaseDatosSoleraSidra.instancia.guardarPartida(PartidaManzana(
      id: _original?.id,
      fechaEntregaMs: _fechaEntregaMs,
      kilos: kilos,
      fruta: _fruta,
      propia: _propia,
      pomaradaId: _propia ? _pomaradaId : null,
      proveedor: _propia ? '' : _proveedor.text.trim(),
      proveedorRegistradoDop: !_propia && _proveedorRegistrado,
      procedencia: _procedencia.text.trim(),
      variedades: _variedades,
      fechaRecoleccionMs: _fechaRecoleccionMs,
      estadoFruta: _estadoFruta,
      documentoTransporte: _documento.text.trim(),
      precioCentimosKg: ((leerNumero(_precio.text) ?? 0) * 100).round(),
      notas: _notas.text.trim(),
    ));
    avisarCambioDatos();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final noRegistrada = _sagardotegi.dopId.isNotEmpty &&
        !(_propia
            ? (_pomaradaElegida?.registradaDop ?? false)
            : _proveedorRegistrado);
    final fueraDelPliego =
        variedadesFueraDelPliego(_variedades, _sagardotegi.dopId);
    return Scaffold(
      appBar: AppBar(
          title: Text(SoleraL10n.t(_original == null
              ? 'sidr.nueva_entrada'
              : 'sidr.editar_entrada'))),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          SelectorFecha(
            etiqueta: SoleraL10n.t('sidr.fecha_entrega'),
            fechaMs: _fechaEntregaMs,
            alCambiar: (fecha) =>
                setState(() => _fechaEntregaMs = fecha ?? _fechaEntregaMs),
          ),
          SelectorFecha(
            etiqueta: SoleraL10n.t('sidr.fecha_recoleccion'),
            fechaMs: _fechaRecoleccionMs,
            permitirVacia: true,
            alCambiar: (fecha) => setState(() => _fechaRecoleccionMs = fecha),
          ),
          SegmentedButton<String>(
            segments: [
              for (final fruta in ['manzana', 'uva'])
                ButtonSegment(
                    value: fruta, label: Text(nombreValor('fruta', fruta))),
            ],
            selected: {_fruta},
            onSelectionChanged: (valor) => setState(() => _fruta = valor.first),
          ),
          campoNumero(_kilos, SoleraL10n.t('sidr.kilos'), sufijo: 'kg'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _propia,
            title: Text(SoleraL10n.t('sidr.fruta_propia')),
            onChanged: (valor) => setState(() => _propia = valor),
          ),
          if (_propia)
            campoDesplegable<int?>(
              etiqueta: SoleraL10n.t('sidr.pomarada'),
              valor: _pomaradaId,
              opciones: [
                for (final pomarada in _pomaradas)
                  (pomarada.id, pomarada.nombre),
              ],
              alCambiar: (valor) => setState(() {
                _pomaradaId = valor;
                final pomarada = _pomaradaElegida;
                if (pomarada != null && _variedades.isEmpty) {
                  _variedades = {...pomarada.variedades};
                }
              }),
            )
          else ...[
            campoTexto(_proveedor, SoleraL10n.t('sidr.proveedor')),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _proveedorRegistrado,
              title: Text(SoleraL10n.t('sidr.proveedor_registrado')),
              subtitle: Text(SoleraL10n.t('sidr.registrada_dop_ayuda')),
              onChanged: (valor) =>
                  setState(() => _proveedorRegistrado = valor),
            ),
            campoNumero(_precio, SoleraL10n.t('sidr.precio_kg'),
                sufijo: '€/kg'),
          ],
          if (noRegistrada)
            TarjetaAviso(SoleraL10n.t('sidr.aviso_procedencia_no_registrada'),
                icono: Icons.warning_amber_outlined),
          campoTexto(_procedencia, SoleraL10n.t('sidr.procedencia')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.eco_outlined),
            title: Text(SoleraL10n.t('sidr.variedades')),
            subtitle: Text(_variedades.isEmpty
                ? '—'
                : _variedades.map(nombreVariedad).join(', ')),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () async {
              final elegidas = await elegirVarios(context,
                  titulo: SoleraL10n.t('sidr.variedades'),
                  opciones: variedadesParaCultivo(
                      _fruta == 'uva' ? 'vid' : 'manzano',
                      dop: _sagardotegi.dopId),
                  elegidos: _variedades);
              if (elegidas != null) setState(() => _variedades = elegidas);
            },
          ),
          if (fueraDelPliego.isNotEmpty)
            TarjetaAviso(SoleraL10n.tf('sidr.variedades_fuera_pliego',
                {'variedades': fueraDelPliego.map(nombreVariedad).join(', ')})),
          campoDesplegable<String>(
            etiqueta: SoleraL10n.t('sidr.estado_fruta'),
            valor: _estadoFruta,
            opciones: [
              for (final estado in estadosFruta)
                (estado, nombreValor('estado_fruta', estado)),
            ],
            alCambiar: (valor) =>
                setState(() => _estadoFruta = valor ?? _estadoFruta),
          ),
          campoTexto(_documento, SoleraL10n.t('sidr.documento_transporte')),
          campoTexto(_notas, SoleraL10n.t('sidr.notas')),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
