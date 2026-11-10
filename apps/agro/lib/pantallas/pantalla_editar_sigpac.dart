import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../estado/cambios_fincas.dart';
import '../modelos/finca.dart';

/// Paquete de la app, para identificarse ante OpenStreetMap (el mismo
/// que usa el mapa de plantas).
const String paqueteAppAgro = 'com.josu.agro';

/// Si hay área y no punto, el punto (centroide de la finca) es el centro
/// del área: el mapa lo usa para centrarse al elegir la finca.
(double?, double?) puntoOCentroDelArea(
  double? latitud,
  double? longitud,
  List<LatLng> area,
) {
  if (latitud != null && longitud != null) return (latitud, longitud);
  final centro = centroide(area);
  return (centro?.latitude, centro?.longitude);
}

/// Edita la referencia SIGPAC, la superficie, el punto y el área de una
/// finca, datos requeridos por el Cuaderno de Explotación digital. La
/// finca se crea con nombre desde la pantalla de listado; aquí se
/// completan los campos necesarios para inspección MAPA y su sitio en el
/// mapa.
class PantallaEditarSigpac extends StatefulWidget {
  final Finca finca;
  PantallaEditarSigpac({super.key, required this.finca});

  @override
  State<PantallaEditarSigpac> createState() => _PantallaEditarSigpacState();
}

class _PantallaEditarSigpacState extends State<PantallaEditarSigpac> {
  final _controladorProvincia = TextEditingController();
  final _controladorMunicipio = TextEditingController();
  final _controladorPoligono = TextEditingController();
  final _controladorParcela = TextEditingController();
  final _controladorRecinto = TextEditingController();
  final _controladorSuperficie = TextEditingController();
  late double? _latitud = widget.finca.latitudCentroide;
  late double? _longitud = widget.finca.longitudCentroide;
  late List<LatLng> _area = widget.finca.vertices;

  @override
  void initState() {
    super.initState();
    _controladorProvincia.text = widget.finca.sigpacProvincia;
    _controladorMunicipio.text = widget.finca.sigpacMunicipio;
    _controladorPoligono.text = widget.finca.sigpacPoligono;
    _controladorParcela.text = widget.finca.sigpacParcela;
    _controladorRecinto.text = widget.finca.sigpacRecinto;
    if (widget.finca.superficieHectareas != null) {
      _controladorSuperficie.text = numeroParaEditar(
        widget.finca.superficieHectareas!,
      );
    }
  }

  @override
  void dispose() {
    _controladorProvincia.dispose();
    _controladorMunicipio.dispose();
    _controladorPoligono.dispose();
    _controladorParcela.dispose();
    _controladorRecinto.dispose();
    _controladorSuperficie.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    // Antes parseábamos la superficie con `double.tryParse` y si fallaba
    // se guardaba `null` en silencio: el tester veía cómo el campo se
    // borraba al guardar sin entender por qué (bug reportado en
    // testeo 2026-05-15). Ahora validamos primero y avisamos.
    final textoSup = _controladorSuperficie.text.trim();
    double? superficie;
    if (textoSup.isNotEmpty) {
      superficie = leerNumero(textoSup);
      if (superficie == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              SoleraL10n.tf('agro.superficie_no_valida_texto', {
                'texto': textoSup,
              }),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }
      if (superficie < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              SoleraL10n.t('agro.superficie_no_puede_ser_negativa'),
            ),
          ),
        );
        return;
      }
    }
    final (latitud, longitud) = puntoOCentroDelArea(_latitud, _longitud, _area);
    await BaseDatosAgro.instancia.actualizarFinca(widget.finca.id!, {
      'sigpac_provincia': _controladorProvincia.text.trim(),
      'sigpac_municipio': _controladorMunicipio.text.trim(),
      'sigpac_poligono': _controladorPoligono.text.trim(),
      'sigpac_parcela': _controladorParcela.text.trim(),
      'sigpac_recinto': _controladorRecinto.text.trim(),
      'superficie_hectareas': superficie,
      'latitud_centroide': latitud,
      'longitud_centroide': longitud,
      'contorno': codificarContorno(_area),
    });
    avisarCambioFincas();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(SoleraL10n.t('agro.datos_sigpac_guardados'))),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SIGPAC — ${widget.finca.nombre}')),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
        children: [
          Text(
            SoleraL10n.t('agro.sigpac_explicacion'),
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controladorProvincia,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.provincia'),
                    hintText: SoleraL10n.t('agro.codigo_ine_abreviado'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controladorMunicipio,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.municipio'),
                    hintText: SoleraL10n.t('agro.codigo_ine_abreviado'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: separacionCamposSolera),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controladorPoligono,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.poligono'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controladorParcela,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.parcela'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controladorRecinto,
                  decoration: InputDecoration(
                    labelText: SoleraL10n.t('agro.recinto'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: separacionCamposSolera),
          TextField(
            controller: _controladorSuperficie,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('agro.superficie_hectareas'),
              hintText: SoleraL10n.t('agro.ejemplo_superficie'),
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16),
          CampoPunto(
            latitud: _latitud,
            longitud: _longitud,
            titulo: SoleraL10n.t('agro.posicion'),
            centro: centroide(_area),
            areasDeFondo: [(nombre: widget.finca.nombre, vertices: _area)],
            paqueteApp: paqueteAppAgro,
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
            paqueteApp: paqueteAppAgro,
            alCambiar: (vertices) => setState(() => _area = vertices),
            // La superficie oficial manda: solo se copia si se pide.
            alUsarSuperficie: (hectareas) => setState(
              () => _controladorSuperficie.text = numeroParaEditar(
                (hectareas * 100).round() / 100,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: Icon(Icons.save),
            onPressed: _guardar,
            label: Text(SoleraL10n.t('guardar')),
          ),
        ],
      ),
    );
  }
}
