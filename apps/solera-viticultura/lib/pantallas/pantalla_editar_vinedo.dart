import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../modelos/vinedo.dart';

/// Paquete de la app, para identificarse ante OpenStreetMap.
const String paqueteAppViticultura = 'com.coleccionnuevoser.solera_viticultura';

/// Color de un viñedo nuevo (burdeos de la marca).
const int colorVinedoPorDefecto = 0xFF7D2A2A;

/// Si hay área y no punto, el punto (centroide del viñedo) es el centro
/// del área: el mapa lo usa para centrarse al elegir el viñedo.
(double?, double?) puntoOCentroDelArea(
    double? latitud, double? longitud, List<LatLng> area) {
  if (latitud != null && longitud != null) return (latitud, longitud);
  final centro = centroide(area);
  return (centro?.latitude, centro?.longitude);
}

/// Alta o edición de un viñedo: nombre, SIGPAC y superficie (libro PAC),
/// su punto y su área en el mapa. Devuelve `true` al guardar.
class PantallaEditarVinedo extends StatefulWidget {
  const PantallaEditarVinedo({super.key, this.vinedo});

  /// null = viñedo nuevo.
  final Vinedo? vinedo;

  @override
  State<PantallaEditarVinedo> createState() => _PantallaEditarVinedoState();
}

class _PantallaEditarVinedoState extends State<PantallaEditarVinedo> {
  late final _controladorNombre =
      TextEditingController(text: widget.vinedo?.nombre ?? '');
  late final _controladorProvincia =
      TextEditingController(text: widget.vinedo?.sigpacProvincia ?? '');
  late final _controladorMunicipio =
      TextEditingController(text: widget.vinedo?.sigpacMunicipio ?? '');
  late final _controladorPoligono =
      TextEditingController(text: widget.vinedo?.sigpacPoligono ?? '');
  late final _controladorParcela =
      TextEditingController(text: widget.vinedo?.sigpacParcela ?? '');
  late final _controladorRecinto =
      TextEditingController(text: widget.vinedo?.sigpacRecinto ?? '');
  late final _controladorSuperficie = TextEditingController(
      text: widget.vinedo?.superficieHectareas == null
          ? ''
          : numeroParaEditar(widget.vinedo!.superficieHectareas!));
  late final _controladorNotas =
      TextEditingController(text: widget.vinedo?.notas ?? '');
  late double? _latitud = widget.vinedo?.latitudCentroide;
  late double? _longitud = widget.vinedo?.longitudCentroide;
  late List<LatLng> _area = widget.vinedo?.vertices ?? const [];
  bool _guardando = false;

  @override
  void dispose() {
    for (final controlador in [
      _controladorNombre,
      _controladorProvincia,
      _controladorMunicipio,
      _controladorPoligono,
      _controladorParcela,
      _controladorRecinto,
      _controladorSuperficie,
      _controladorNotas,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _guardar() async {
    final nombre = _controladorNombre.text.trim();
    if (nombre.isEmpty) {
      _avisar(SoleraL10n.tf(
          'viti.campo_obligatorio', {'campo': SoleraL10n.t('viti.nombre')}));
      return;
    }
    // Superficie: vacía vale; si hay texto, número no negativo (nunca se
    // borra en silencio un valor mal escrito).
    final textoSuperficie = _controladorSuperficie.text.trim();
    double? superficie;
    if (textoSuperficie.isNotEmpty) {
      superficie = leerNumero(textoSuperficie);
      if (superficie == null) {
        _avisar(SoleraL10n.tf(
            'agro.superficie_no_valida_texto', {'texto': textoSuperficie}));
        return;
      }
      if (superficie < 0) {
        _avisar(SoleraL10n.t('agro.superficie_no_puede_ser_negativa'));
        return;
      }
    }
    setState(() => _guardando = true);
    final (latitud, longitud) = puntoOCentroDelArea(_latitud, _longitud, _area);
    final original = widget.vinedo;
    final vinedo = Vinedo(
      id: original?.id,
      nombre: nombre,
      latitudCentroide: latitud,
      longitudCentroide: longitud,
      colorEntero: original?.colorEntero ?? colorVinedoPorDefecto,
      notas: _controladorNotas.text.trim(),
      fechaCreacionMs:
          original?.fechaCreacionMs ?? DateTime.now().millisecondsSinceEpoch,
      sigpacProvincia: _controladorProvincia.text.trim(),
      sigpacMunicipio: _controladorMunicipio.text.trim(),
      sigpacPoligono: _controladorPoligono.text.trim(),
      sigpacParcela: _controladorParcela.text.trim(),
      sigpacRecinto: _controladorRecinto.text.trim(),
      superficieHectareas: superficie,
      contorno: codificarContorno(_area),
    );
    final baseDatos = BaseDatosSoleraViticultura.instancia;
    if (original?.id == null) {
      await baseDatos.guardarVinedo(vinedo);
    } else {
      await baseDatos.actualizarVinedo(
          original!.id!, vinedo.toMap()..remove('id'));
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  /// Borra el viñedo; sus cepas quedan como puntos sueltos con su historia.
  Future<void> _borrar() async {
    final id = widget.vinedo?.id;
    if (id == null) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: Text(SoleraL10n.t('viti.borrar_vinedo')),
        content: Text(SoleraL10n.tf('viti.borrar_vinedo_aviso',
            {'nombre': widget.vinedo!.nombre})),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contextoDialogo, false),
              child: Text(SoleraL10n.t('cancelar'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(contextoDialogo, true),
            child: Text(SoleraL10n.t('viti.eliminar')),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    await BaseDatosSoleraViticultura.instancia.borrarVinedo(id);
    if (mounted) Navigator.of(context).pop(true);
  }

  Widget _campoTexto(TextEditingController controlador, String etiqueta,
          {String? ayuda, TextInputType? teclado, int lineas = 1}) =>
      TextField(
        controller: controlador,
        keyboardType: teclado,
        maxLines: lineas,
        decoration: InputDecoration(
          labelText: etiqueta,
          hintText: ayuda,
          border: const OutlineInputBorder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final codigoIne = SoleraL10n.t('agro.codigo_ine_abreviado');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vinedo?.nombre ?? SoleraL10n.t('viti.nuevo_vinedo')),
        actions: [
          if (widget.vinedo?.id != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: SoleraL10n.t('viti.borrar_vinedo'),
              onPressed: _guardando ? null : _borrar,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _campoTexto(_controladorNombre, '${SoleraL10n.t('viti.nombre')} *'),
          const SizedBox(height: 16),
          Text(
            SoleraL10n.t('agro.sigpac_explicacion'),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _campoTexto(
                      _controladorProvincia, SoleraL10n.t('agro.provincia'),
                      ayuda: codigoIne)),
              const SizedBox(width: 8),
              Expanded(
                  child: _campoTexto(
                      _controladorMunicipio, SoleraL10n.t('agro.municipio'),
                      ayuda: codigoIne)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _campoTexto(
                      _controladorPoligono, SoleraL10n.t('agro.poligono'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _campoTexto(
                      _controladorParcela, SoleraL10n.t('agro.parcela'))),
              const SizedBox(width: 8),
              Expanded(
                  child: _campoTexto(
                      _controladorRecinto, SoleraL10n.t('agro.recinto'))),
            ],
          ),
          const SizedBox(height: 16),
          _campoTexto(
              _controladorSuperficie, SoleraL10n.t('agro.superficie_hectareas'),
              ayuda: SoleraL10n.t('agro.ejemplo_superficie'),
              teclado: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          CampoPunto(
            latitud: _latitud,
            longitud: _longitud,
            centro: centroide(_area),
            areasDeFondo: [
              (nombre: _controladorNombre.text.trim(), vertices: _area)
            ],
            paqueteApp: paqueteAppViticultura,
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
            paqueteApp: paqueteAppViticultura,
            alCambiar: (vertices) => setState(() => _area = vertices),
            // La superficie oficial manda: solo se copia si se pide.
            alUsarSuperficie: (hectareas) => setState(() =>
                _controladorSuperficie.text =
                    numeroParaEditar((hectareas * 100).round() / 100)),
          ),
          const SizedBox(height: 16),
          _campoTexto(_controladorNotas, SoleraL10n.t('viti.notas'), lineas: 3),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            onPressed: _guardando ? null : _guardar,
            label: Text(SoleraL10n.t('guardar')),
          ),
        ],
      ),
    );
  }
}
