import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/parcela.dart';
import '../modelos/zona_recoleccion.dart';
import '../utiles/textos_aromaticas.dart';
import 'campo_catalogo.dart';
import 'hoja_formulario.dart';

Future<void> abrirEdicionParcela(BuildContext context,
    {Parcela? parcela}) async {
  final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => PantallaEditarParcela(parcela: parcela)));
  if (guardado == true) avisarCambioDatos();
}

Future<void> abrirEdicionZona(BuildContext context,
    {ZonaRecoleccion? zona}) async {
  final guardado = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => PantallaEditarZona(zona: zona)));
  if (guardado == true) avisarCambioDatos();
}

/// Paquete de la app, para identificarse ante OpenStreetMap.
const String paqueteAppAromaticas = 'com.coleccionnuevoser.solera_aromaticas';

/// Si hay área y no punto, el punto es el centro del área (el mapa y Hoy
/// usan el punto).
(double?, double?) puntoOCentroDelArea(
    double? latitud, double? longitud, List<LatLng> area) {
  if (latitud != null && longitud != null) return (latitud, longitud);
  final centro = centroide(area);
  return (centro?.latitude, centro?.longitude);
}

/// Alta o edición de una parcela de cultivo.
class PantallaEditarParcela extends StatefulWidget {
  const PantallaEditarParcela({super.key, this.parcela});

  final Parcela? parcela;

  @override
  State<PantallaEditarParcela> createState() => _PantallaEditarParcelaState();
}

class _PantallaEditarParcelaState extends State<PantallaEditarParcela> {
  late final _nombre = TextEditingController(text: widget.parcela?.nombre);
  late final _especie = TextEditingController(
      text: nombreEspecie(widget.parcela?.especieId ?? ''));
  late final _sigpac =
      TextEditingController(text: widget.parcela?.codigoSigpac);
  late final _superficie = TextEditingController(
      text: numeroParaCampo(widget.parcela?.superficieHa, decimales: 2));
  late final _anyo = TextEditingController(
      text: widget.parcela?.anyoPlantacion?.toString() ?? '');
  late final _notas = TextEditingController(text: widget.parcela?.notas);
  late bool _ecologico = widget.parcela?.ecologico ?? false;
  late bool _regadio = widget.parcela?.regadio ?? false;
  late double? _latitud = widget.parcela?.latitud;
  late double? _longitud = widget.parcela?.longitud;
  late List<LatLng> _area = widget.parcela?.vertices ?? const [];
  bool _guardando = false;

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _especie,
      _sigpac,
      _superficie,
      _anyo,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando ||
        _nombre.text.trim().isEmpty ||
        _especie.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _guardando = true;
    });
    final original = widget.parcela;
    final (latitud, longitud) = puntoOCentroDelArea(_latitud, _longitud, _area);
    await BaseDatosSoleraAromaticas.instancia.guardarParcela(Parcela(
      id: original?.id,
      nombre: _nombre.text.trim(),
      especieId: idDesdeTexto(_especie.text, opcionesEspecies()),
      codigoSigpac: _sigpac.text.trim(),
      superficieHa: leerNumero(_superficie.text) ?? 0,
      anyoPlantacion: leerEntero(_anyo.text),
      ecologico: _ecologico,
      regadio: _regadio,
      latitud: latitud,
      longitud: longitud,
      contorno: codificarContorno(_area),
      notas: _notas.text.trim(),
      fechaCreacionMs:
          original?.fechaCreacionMs ?? DateTime.now().millisecondsSinceEpoch,
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.parcela == null
              ? SoleraL10n.t('arom.nueva_parcela')
              : widget.parcela!.nombre)),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          campoTexto(_nombre, SoleraL10n.t('arom.nombre')),
          CampoCatalogo(
            controlador: _especie,
            opciones: opcionesEspecies(),
            etiqueta: SoleraL10n.t('arom.especie'),
          ),
          campoNumero(_superficie, SoleraL10n.t('arom.superficie_ha')),
          campoNumero(_anyo, SoleraL10n.t('arom.anyo_plantacion'),
              decimales: false),
          campoTexto(_sigpac, SoleraL10n.t('arom.codigo_sigpac'),
              ayuda: SoleraL10n.t('arom.sigpac_ayuda')),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(SoleraL10n.t('arom.ecologico')),
            value: _ecologico,
            onChanged: (valor) => setState(() => _ecologico = valor),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(SoleraL10n.t('arom.regadio')),
            value: _regadio,
            onChanged: (valor) => setState(() => _regadio = valor),
          ),
          CampoPunto(
            latitud: _latitud,
            longitud: _longitud,
            titulo: SoleraL10n.t('arom.ubicacion'),
            centro: centroide(_area),
            areasDeFondo: [(nombre: '', vertices: _area)],
            paqueteApp: paqueteAppAromaticas,
            alCambiar: (latitud, longitud) => setState(() {
              _latitud = latitud;
              _longitud = longitud;
            }),
          ),
          const SizedBox(height: 8),
          CampoArea(
            vertices: _area,
            centro: _latitud == null || _longitud == null
                ? null
                : LatLng(_latitud!, _longitud!),
            paqueteApp: paqueteAppAromaticas,
            alCambiar: (vertices) => setState(() => _area = vertices),
            alUsarSuperficie: (hectareas) => setState(() =>
                _superficie.text = numeroParaCampo(hectareas, decimales: 2)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notas,
            maxLines: 3,
            decoration: InputDecoration(labelText: SoleraL10n.t('arom.notas')),
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

/// Alta o edición de una zona de recolección silvestre con su permiso.
class PantallaEditarZona extends StatefulWidget {
  const PantallaEditarZona({super.key, this.zona});

  final ZonaRecoleccion? zona;

  @override
  State<PantallaEditarZona> createState() => _PantallaEditarZonaState();
}

class _PantallaEditarZonaState extends State<PantallaEditarZona> {
  late final _nombre = TextEditingController(text: widget.zona?.nombre);
  late final _comunidad =
      TextEditingController(text: widget.zona?.comunidadAutonoma);
  late final _municipio = TextEditingController(text: widget.zona?.municipio);
  late final _titularTerreno =
      TextEditingController(text: widget.zona?.titularTerreno);
  late final _permiso = TextEditingController(text: widget.zona?.numeroPermiso);
  late final _organismo =
      TextEditingController(text: widget.zona?.organismoPermiso);
  late final _limite = TextEditingController(
      text: numeroParaCampo(widget.zona?.limiteKg, decimales: 0));
  late final _especieNueva = TextEditingController();
  late final _notas = TextEditingController(text: widget.zona?.notas);
  late String _tipoTerreno = widget.zona?.tipoTerreno ?? 'monte_publico';
  late final List<String> _especies = [...?widget.zona?.especiesPermitidas];
  late DateTime? _inicio = widget.zona?.inicioVigenciaMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(widget.zona!.inicioVigenciaMs!);
  late DateTime? _fin = widget.zona?.finVigenciaMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(widget.zona!.finVigenciaMs!);
  late double? _latitud = widget.zona?.latitud;
  late double? _longitud = widget.zona?.longitud;
  late List<LatLng> _area = widget.zona?.vertices ?? const [];
  bool _guardando = false;

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _comunidad,
      _municipio,
      _titularTerreno,
      _permiso,
      _organismo,
      _limite,
      _especieNueva,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  void _anadirEspecie() {
    final id = idDesdeTexto(
        _especieNueva.text, opcionesEspecies(soloSilvestres: true));
    if (id.isEmpty || _especies.contains(id)) return;
    setState(() {
      _especies.add(id);
      _especieNueva.clear();
    });
  }

  Future<void> _elegirFecha({required bool esInicio}) async {
    final actual = (esInicio ? _inicio : _fin) ?? DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (elegida == null) return;
    setState(() {
      if (esInicio) {
        _inicio = elegida;
      } else {
        _fin = elegida;
      }
    });
  }

  Future<void> _guardar() async {
    if (_guardando || _nombre.text.trim().isEmpty) return;
    setState(() {
      _guardando = true;
    });
    final (latitud, longitud) = puntoOCentroDelArea(_latitud, _longitud, _area);
    await BaseDatosSoleraAromaticas.instancia
        .guardarZonaRecoleccion(ZonaRecoleccion(
      id: widget.zona?.id,
      nombre: _nombre.text.trim(),
      comunidadAutonoma: _comunidad.text.trim(),
      municipio: _municipio.text.trim(),
      tipoTerreno: _tipoTerreno,
      titularTerreno: _titularTerreno.text.trim(),
      numeroPermiso: _permiso.text.trim(),
      organismoPermiso: _organismo.text.trim(),
      inicioVigenciaMs: _inicio?.millisecondsSinceEpoch,
      finVigenciaMs: _fin?.millisecondsSinceEpoch,
      especiesPermitidas: _especies,
      limiteKg: leerNumero(_limite.text),
      latitud: latitud,
      longitud: longitud,
      contorno: codificarContorno(_area),
      notas: _notas.text.trim(),
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.zona == null
              ? SoleraL10n.t('arom.nueva_zona')
              : widget.zona!.nombre)),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(SoleraL10n.t('arom.zona_aviso_normativa')),
            ),
          ),
          campoTexto(_nombre, SoleraL10n.t('arom.nombre')),
          campoTexto(_comunidad, SoleraL10n.t('arom.comunidad_autonoma')),
          campoTexto(_municipio, SoleraL10n.t('arom.municipio')),
          etiquetaGrupo(context, SoleraL10n.t('arom.tipo_terreno')),
          selectorChips(
              opciones: tiposTerrenoRecoleccion,
              valor: _tipoTerreno,
              nombre: nombreTipoTerreno,
              alCambiar: (valor) => setState(() => _tipoTerreno = valor)),
          campoTexto(_titularTerreno, SoleraL10n.t('arom.titular_terreno')),
          const SizedBox(height: 16),
          Text(SoleraL10n.t('arom.permiso'),
              style: Theme.of(context).textTheme.titleMedium),
          campoTexto(_permiso, SoleraL10n.t('arom.numero_permiso'),
              ayuda: SoleraL10n.t('arom.numero_permiso_ayuda')),
          campoTexto(_organismo, SoleraL10n.t('arom.organismo_permiso')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(SoleraL10n.t('arom.inicio_vigencia')),
            subtitle: Text(_inicio == null
                ? '—'
                : formatearFecha(_inicio!.millisecondsSinceEpoch)),
            onTap: () => _elegirFecha(esInicio: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(SoleraL10n.t('arom.fin_vigencia')),
            subtitle: Text(_fin == null
                ? '—'
                : formatearFecha(_fin!.millisecondsSinceEpoch)),
            onTap: () => _elegirFecha(esInicio: false),
          ),
          campoNumero(_limite, SoleraL10n.t('arom.limite_kg'),
              ayuda: SoleraL10n.t('arom.limite_kg_ayuda')),
          etiquetaGrupo(context, SoleraL10n.t('arom.especies_permitidas')),
          Wrap(
            spacing: 6,
            children: [
              for (final especie in _especies)
                InputChip(
                  label: Text(nombreEspecie(especie)),
                  onDeleted: () => setState(() => _especies.remove(especie)),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CampoCatalogo(
                  controlador: _especieNueva,
                  opciones: opcionesEspecies(soloSilvestres: true),
                  etiqueta: SoleraL10n.t('arom.anadir_especie'),
                  alElegir: (_) => _anadirEspecie(),
                ),
              ),
              IconButton(
                tooltip: SoleraL10n.t('arom.anadir_especie'),
                onPressed: _anadirEspecie,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          for (final especie in _especies)
            if (especieConProteccion(especie))
              textoAviso(
                  context,
                  SoleraL10n.tf('arom.especie_protegida_en_permiso',
                      {'especie': nombreEspecie(especie)})),
          CampoPunto(
            latitud: _latitud,
            longitud: _longitud,
            titulo: SoleraL10n.t('arom.ubicacion'),
            centro: centroide(_area),
            areasDeFondo: [(nombre: '', vertices: _area)],
            paqueteApp: paqueteAppAromaticas,
            alCambiar: (latitud, longitud) => setState(() {
              _latitud = latitud;
              _longitud = longitud;
            }),
          ),
          const SizedBox(height: 8),
          CampoArea(
            vertices: _area,
            centro: _latitud == null || _longitud == null
                ? null
                : LatLng(_latitud!, _longitud!),
            paqueteApp: paqueteAppAromaticas,
            alCambiar: (vertices) => setState(() => _area = vertices),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notas,
            maxLines: 3,
            decoration: InputDecoration(labelText: SoleraL10n.t('arom.notas')),
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
