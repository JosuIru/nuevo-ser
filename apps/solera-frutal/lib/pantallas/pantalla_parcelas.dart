import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/parcela.dart';
import '../utiles/permisos_gps.dart';
import '../utiles/textos_frutal.dart';
import 'pantalla_mapa.dart';
import 'pantalla_ficha_parcela.dart';

/// Lista de parcelas con su especie, variedad y superficie.
class PantallaParcelas extends StatefulWidget {
  const PantallaParcelas({super.key});

  @override
  State<PantallaParcelas> createState() => _PantallaParcelasState();
}

class _PantallaParcelasState extends State<PantallaParcelas> {
  late Future<List<Parcela>> _parcelas;

  @override
  void initState() {
    super.initState();
    _parcelas = BaseDatosSoleraFrutal.instancia.listarParcelas();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _parcelas = BaseDatosSoleraFrutal.instancia.listarParcelas();
    });
  }

  Future<void> _nueva() async {
    final guardado = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => const PantallaEditarParcela()));
    if (guardado == true) avisarCambioDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('frut.parcelas')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('frut.mapa'),
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaMapa())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('frut.nueva_parcela'),
        onPressed: _nueva,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Parcela>>(
        future: _parcelas,
        builder: (context, instantanea) {
          final parcelas = instantanea.data ?? const <Parcela>[];
          if (instantanea.connectionState == ConnectionState.done &&
              parcelas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('frut.sin_parcelas'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          final totalHectareas = parcelas.fold<double>(
              0, (suma, parcela) => suma + parcela.superficieHa);
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              ListTile(
                title: Text(SoleraL10n.tf('frut.parcelas_total', {
                  'n': parcelas.length,
                  'ha': formatearNumero(totalHectareas, decimales: 2),
                })),
              ),
              for (final parcela in parcelas)
                ListTile(
                  leading: const Icon(Icons.park_outlined),
                  title: Text(parcela.nombre),
                  subtitle: Text([
                    nombreEspecie(parcela.especieId),
                    if (parcela.variedadPrincipalId.isNotEmpty)
                      parcela.variedadPrincipalId,
                    SoleraL10n.t(
                        parcela.regadio ? 'frut.regadio' : 'frut.secano'),
                  ].join(' · ')),
                  trailing: Text(
                      '${formatearNumero(parcela.superficieHa, decimales: 2)} ha'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PantallaFichaParcela(parcelaId: parcela.id!))),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Alta o edición de una parcela.
class PantallaEditarParcela extends StatefulWidget {
  const PantallaEditarParcela({super.key, this.parcela});

  final Parcela? parcela;

  @override
  State<PantallaEditarParcela> createState() => _PantallaEditarParcelaState();
}

class _PantallaEditarParcelaState extends State<PantallaEditarParcela> {
  late final _nombre = TextEditingController(text: widget.parcela?.nombre);
  late final _variedad =
      TextEditingController(text: widget.parcela?.variedadPrincipalId);
  late final _sigpac =
      TextEditingController(text: widget.parcela?.codigoSigpac);
  late final _superficie = TextEditingController(
      text: widget.parcela == null || widget.parcela!.superficieHa == 0
          ? ''
          : formatearNumero(widget.parcela!.superficieHa, decimales: 2));
  late final _marco =
      TextEditingController(text: widget.parcela?.marcoPlantacion);
  late final _anyo = TextEditingController(
      text: widget.parcela?.anyoPlantacion?.toString() ?? '');
  late final _notas = TextEditingController(text: widget.parcela?.notas);
  late String _especie = widget.parcela?.especieId ?? especiesFrutal.first;
  late bool _regadio = widget.parcela?.regadio ?? false;
  late String _sistemaRiego = widget.parcela?.sistemaRiego.isNotEmpty == true
      ? widget.parcela!.sistemaRiego
      : sistemasRiego.first;
  bool _guardando = false;
  bool _localizando = false;
  late double? _latitud = widget.parcela?.latitud;
  late double? _longitud = widget.parcela?.longitud;

  /// Guarda la posición actual como ubicación de la parcela. Si no hay
  /// permiso o el GPS no responde, avisa y la parcela queda sin ubicación.
  Future<void> _usarMiUbicacion() async {
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _localizando = true);
    try {
      if (!await asegurarPermisoUbicacion()) {
        mensajero.showSnackBar(
            SnackBar(content: Text(SoleraL10n.t('frut.gps_sin_permiso'))));
        return;
      }
      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      if (!mounted) return;
      setState(() {
        _latitud = posicion.latitude;
        _longitud = posicion.longitude;
      });
    } catch (error) {
      debugPrint('GPS: $error');
      mensajero.showSnackBar(
          SnackBar(content: Text(SoleraL10n.t('frut.gps_error'))));
    } finally {
      if (mounted) setState(() => _localizando = false);
    }
  }

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _variedad,
      _sigpac,
      _superficie,
      _marco,
      _anyo,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || _nombre.text.trim().isEmpty) return;
    setState(() {
      _guardando = true;
    });
    final original = widget.parcela;
    await BaseDatosSoleraFrutal.instancia.guardarParcela(Parcela(
      id: original?.id,
      nombre: _nombre.text.trim(),
      especieId: _especie,
      variedadPrincipalId: _variedad.text.trim(),
      codigoSigpac: _sigpac.text.trim(),
      superficieHa: leerNumero(_superficie.text) ?? 0,
      marcoPlantacion: _marco.text.trim(),
      anyoPlantacion: leerEntero(_anyo.text),
      regadio: _regadio,
      sistemaRiego: _sistemaRiego,
      latitud: _latitud,
      longitud: _longitud,
      notas: _notas.text.trim(),
      fechaCreacionMs:
          original?.fechaCreacionMs ?? DateTime.now().millisecondsSinceEpoch,
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final arbolesPorHa = arbolesPorHectareaDesdeMarco(_marco.text);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.parcela == null
              ? SoleraL10n.t('frut.nueva_parcela')
              : widget.parcela!.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombre,
            decoration: InputDecoration(labelText: SoleraL10n.t('frut.nombre')),
          ),
          DropdownButtonFormField<String>(
            initialValue: _especie,
            decoration:
                InputDecoration(labelText: SoleraL10n.t('frut.especie')),
            items: [
              for (final especie in especiesFrutal)
                DropdownMenuItem(
                    value: especie, child: Text(nombreEspecie(especie))),
            ],
            onChanged: (valor) => setState(() => _especie = valor ?? _especie),
          ),
          TextField(
            controller: _variedad,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('frut.variedad_principal')),
          ),
          TextField(
            controller: _superficie,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                InputDecoration(labelText: SoleraL10n.t('frut.superficie_ha')),
          ),
          TextField(
            controller: _marco,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: SoleraL10n.t('frut.marco_plantacion'),
              helperText: arbolesPorHa == null
                  ? SoleraL10n.t('frut.marco_ayuda')
                  : SoleraL10n.tf('frut.arboles_por_ha',
                      {'n': formatearNumero(arbolesPorHa, decimales: 0)}),
            ),
          ),
          TextField(
            controller: _anyo,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('frut.anyo_plantacion')),
          ),
          TextField(
            controller: _sigpac,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('frut.codigo_sigpac'),
                helperText: SoleraL10n.t('frut.sigpac_ayuda')),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(SoleraL10n.t('frut.regadio')),
            value: _regadio,
            onChanged: (valor) => setState(() => _regadio = valor),
          ),
          if (_regadio)
            Wrap(
              spacing: 6,
              children: [
                for (final sistema in sistemasRiego)
                  ChoiceChip(
                    label: Text(nombreSistemaRiego(sistema)),
                    selected: _sistemaRiego == sistema,
                    onSelected: (_) => setState(() => _sistemaRiego = sistema),
                  ),
              ],
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.my_location_outlined),
            title: Text(SoleraL10n.t('frut.ubicacion')),
            subtitle: Text(_latitud == null || _longitud == null
                ? SoleraL10n.t('frut.sin_ubicacion')
                : '${_latitud!.toStringAsFixed(5)}, ${_longitud!.toStringAsFixed(5)}'),
            trailing: _localizando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton(
                    onPressed: _usarMiUbicacion,
                    child: Text(SoleraL10n.t('frut.usar_mi_ubicacion'))),
          ),
          TextField(
            controller: _notas,
            maxLines: 3,
            decoration: InputDecoration(labelText: SoleraL10n.t('frut.notas')),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(SoleraL10n.t('guardar')),
          ),
        ],
      ),
    );
  }
}
