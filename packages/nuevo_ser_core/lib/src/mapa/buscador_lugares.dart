import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Buscador de lugares para los mapas de las apps (sacado de
/// solera-zunbeltz) con el geocodificador de CartoCiudad
/// (Instituto Geográfico Nacional): topónimos y parajes, municipios,
/// poblaciones, calles y referencias catastrales de toda España. Gratuito,
/// sin clave y con CORS abierto. Si CartoCiudad no responde (se cae a
/// ratos: corta la conexión), se pregunta a Nominatim (OpenStreetMap).
class LugarEncontrado {
  const LugarEncontrado({
    required this.texto,
    required this.tipo,
    required this.id,
    this.municipio = '',
    this.posicion,
  });

  final String texto;

  /// Tipo de CartoCiudad (`ngbe` paraje, `Municipio`, `poblacion`,
  /// `callejero`, `portal`, `refcatastral`…).
  final String tipo;
  final String id;
  final String municipio;

  /// Null si la lista de candidatos no la trae: hay que pedirla con
  /// [ServicioBuscadorMapa.posicionDe].
  final LatLng? posicion;
}

class ServicioBuscadorMapa {
  /// [identificacion] va como User-Agent a Nominatim, que pide que cada app
  /// se identifique (en web no se puede tocar y basta el Referer).
  ServicioBuscadorMapa(
      {http.Client? cliente, this.identificacion = 'SoleraNuevoSer'})
      : _cliente = cliente ?? http.Client();

  final String identificacion;

  static const _base = 'https://www.cartociudad.es/geocoder/api/geocoder';
  static const _baseNominatim = 'https://nominatim.openstreetmap.org/search';
  final http.Client _cliente;

  /// Busca en CartoCiudad y, si falla o no contesta bien, en Nominatim.
  /// Solo lanza si fallan los dos.
  Future<List<LugarEncontrado>> buscar(String texto, {int limite = 10}) async {
    final consulta = texto.trim();
    if (consulta.length < 2) return const [];
    try {
      final respuesta = await _cliente
          .get(Uri.parse('$_base/candidates')
              .replace(queryParameters: {'q': consulta, 'limit': '$limite'}))
          .timeout(const Duration(seconds: 8));
      if (respuesta.statusCode == 200) {
        return lugaresDesdeCandidatos(utf8.decode(respuesta.bodyBytes));
      }
    } catch (_) {
      // CartoCiudad caído: se prueba con Nominatim.
    }
    return _buscarEnNominatim(consulta, limite);
  }

  Future<List<LugarEncontrado>> _buscarEnNominatim(
      String consulta, int limite) async {
    final respuesta = await _cliente.get(
      Uri.parse(_baseNominatim).replace(queryParameters: {
        'q': consulta,
        'format': 'jsonv2',
        'limit': '$limite',
        'countrycodes': 'es,fr',
        'accept-language': 'es',
      }),
      // Nominatim pide identificarse; el navegador no deja tocar el
      // User-Agent y allí basta el Referer que pone él.
      headers: kIsWeb ? null : {'user-agent': identificacion},
    ).timeout(const Duration(seconds: 15));
    if (respuesta.statusCode != 200) {
      throw http.ClientException('Nominatim ${respuesta.statusCode}');
    }
    return lugaresDesdeNominatim(utf8.decode(respuesta.bodyBytes));
  }

  /// Dónde está un candidato que vino sin coordenadas.
  Future<LatLng?> posicionDe(LugarEncontrado lugar) async {
    if (lugar.posicion != null) return lugar.posicion;
    final respuesta = await _cliente
        .get(Uri.parse('$_base/find').replace(queryParameters: {
          'q': lugar.texto,
          'type': lugar.tipo,
          'id': lugar.id,
        }))
        .timeout(const Duration(seconds: 20));
    if (respuesta.statusCode != 200) return null;
    return posicionDesdeFind(utf8.decode(respuesta.bodyBytes));
  }
}

LatLng? _posicion(Object? lat, Object? lng) {
  if (lat is! num || lng is! num || (lat == 0 && lng == 0)) return null;
  return LatLng(lat.toDouble(), lng.toDouble());
}

/// Lee la lista de candidatos. Pura.
List<LugarEncontrado> lugaresDesdeCandidatos(String texto) {
  final datos = jsonDecode(texto);
  if (datos is! List) return const [];
  return [
    for (final candidato in datos)
      if (candidato is Map && candidato['address'] is String)
        LugarEncontrado(
          texto: candidato['address'] as String,
          tipo: '${candidato['type'] ?? ''}',
          id: '${candidato['id'] ?? ''}',
          municipio: '${candidato['muni'] ?? ''}',
          posicion: _posicion(candidato['lat'], candidato['lng']),
        ),
  ];
}

/// Lee la respuesta de `find`. Pura.
LatLng? posicionDesdeFind(String texto) {
  final datos = jsonDecode(texto);
  return datos is Map ? _posicion(datos['lat'], datos['lng']) : null;
}

/// Lee la respuesta de Nominatim (`format=jsonv2`). Siempre trae la
/// posición. Pura.
List<LugarEncontrado> lugaresDesdeNominatim(String texto) {
  final datos = jsonDecode(texto);
  if (datos is! List) return const [];
  return [
    for (final lugar in datos)
      if (lugar is Map && lugar['display_name'] is String)
        LugarEncontrado(
          texto: lugar['display_name'] as String,
          tipo: 'osm:${lugar['addresstype'] ?? lugar['type'] ?? ''}',
          id: '${lugar['osm_type'] ?? ''}${lugar['osm_id'] ?? ''}',
          posicion: _posicion(
              double.tryParse('${lugar['lat']}'),
              double.tryParse('${lugar['lon']}')),
        ),
  ];
}

/// Textos del diálogo del buscador. Castellano por defecto; cada app pasa
/// los suyos si tiene más idiomas.
class TextosBuscadorLugares {
  const TextosBuscadorLugares({
    this.titulo = 'Buscar un lugar',
    this.ayuda = 'Paraje, pueblo, calle o referencia catastral',
    this.sinResultados = 'No se ha encontrado nada.',
    this.sinConexion =
        'No se ha podido consultar el buscador. Comprueba la conexión o prueba dentro de un rato.',
    this.cancelar = 'Cancelar',
    this.buscar = 'Buscar',
  });

  final String titulo;
  final String ayuda;
  final String sinResultados;
  final String sinConexion;
  final String cancelar;
  final String buscar;
}

/// Pide un lugar y devuelve dónde está (null si se cancela).
Future<LatLng?> buscarLugarEnMapa(
  BuildContext context, {
  TextosBuscadorLugares textos = const TextosBuscadorLugares(),
  String identificacion = 'SoleraNuevoSer',
}) =>
    showDialog<LatLng>(
        context: context,
        builder: (_) =>
            _BuscadorLugar(textos: textos, identificacion: identificacion));

class _BuscadorLugar extends StatefulWidget {
  const _BuscadorLugar({required this.textos, required this.identificacion});

  final TextosBuscadorLugares textos;
  final String identificacion;

  @override
  State<_BuscadorLugar> createState() => _BuscadorLugarState();
}

class _BuscadorLugarState extends State<_BuscadorLugar> {
  late final _servicio =
      ServicioBuscadorMapa(identificacion: widget.identificacion);
  final _texto = TextEditingController();
  List<LugarEncontrado> _lugares = const [];
  bool _buscando = false;
  String _aviso = '';
  int _consulta = 0;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final textos = widget.textos;
    final numero = ++_consulta;
    setState(() {
      _buscando = true;
      _aviso = '';
    });
    try {
      final lugares = await _servicio.buscar(_texto.text);
      if (!mounted || numero != _consulta) return;
      setState(() {
        _lugares = lugares;
        _aviso = lugares.isEmpty ? textos.sinResultados : '';
      });
    } catch (_) {
      if (mounted) setState(() => _aviso = textos.sinConexion);
    } finally {
      if (mounted && numero == _consulta) setState(() => _buscando = false);
    }
  }

  Future<void> _elegir(LugarEncontrado lugar) async {
    final textos = widget.textos;
    try {
      final posicion = await _servicio.posicionDe(lugar);
      if (!mounted) return;
      if (posicion == null) {
        setState(() => _aviso = textos.sinResultados);
        return;
      }
      Navigator.of(context).pop(posicion);
    } catch (_) {
      if (mounted) setState(() => _aviso = textos.sinConexion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = widget.textos;
    return AlertDialog(
      title: Text(textos.titulo),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _texto,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: textos.ayuda,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscando
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)))
                    : null,
              ),
              onSubmitted: (_) => _buscar(),
            ),
            if (_aviso.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_aviso),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final lugar in _lugares)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(lugar.texto),
                      subtitle: lugar.municipio.isEmpty
                          ? null
                          : Text(lugar.municipio),
                      onTap: () => _elegir(lugar),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(textos.cancelar)),
        FilledButton(onPressed: _buscar, child: Text(textos.buscar)),
      ],
    );
  }
}
