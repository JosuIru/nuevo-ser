import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/finca.dart';

/// Edita la referencia SIGPAC y la superficie de una finca, datos
/// requeridos por el Cuaderno de Explotación digital. La finca se
/// crea con nombre desde la pantalla de listado; aquí sólo se
/// completan los campos necesarios para inspección MAPA.
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

  @override
  void initState() {
    super.initState();
    _controladorProvincia.text = widget.finca.sigpacProvincia;
    _controladorMunicipio.text = widget.finca.sigpacMunicipio;
    _controladorPoligono.text = widget.finca.sigpacPoligono;
    _controladorParcela.text = widget.finca.sigpacParcela;
    _controladorRecinto.text = widget.finca.sigpacRecinto;
    if (widget.finca.superficieHectareas != null) {
      _controladorSuperficie.text = widget.finca.superficieHectareas!.toString();
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
              'Superficie no válida: "$textoSup". Usa solo números (p. ej. 4,7).',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }
      if (superficie < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La superficie no puede ser negativa.')),
        );
        return;
      }
    }
    await BaseDatosAgro.instancia.actualizarFinca(widget.finca.id!, {
      'sigpac_provincia': _controladorProvincia.text.trim(),
      'sigpac_municipio': _controladorMunicipio.text.trim(),
      'sigpac_poligono': _controladorPoligono.text.trim(),
      'sigpac_parcela': _controladorParcela.text.trim(),
      'sigpac_recinto': _controladorRecinto.text.trim(),
      'superficie_hectareas': superficie,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos SIGPAC guardados.')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SIGPAC — ${widget.finca.nombre}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Identificación oficial de la parcela según el SIGPAC. Si tienes la '
            'referencia completa la app la presentará bien formada en el cuaderno '
            'MAPA con el formato Provincia:Municipio:Polígono:Parcela:Recinto.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controladorProvincia,
                  decoration: InputDecoration(
                    labelText: 'Provincia',
                    hintText: 'Cód. INE',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controladorMunicipio,
                  decoration: InputDecoration(
                    labelText: 'Municipio',
                    hintText: 'Cód. INE',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controladorPoligono,
                  decoration: InputDecoration(
                    labelText: 'Polígono',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controladorParcela,
                  decoration: InputDecoration(
                    labelText: 'Parcela',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controladorRecinto,
                  decoration: InputDecoration(
                    labelText: 'Recinto',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _controladorSuperficie,
            decoration: InputDecoration(
              labelText: 'Superficie (hectáreas)',
              hintText: 'Ej: 4.7',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16),
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
