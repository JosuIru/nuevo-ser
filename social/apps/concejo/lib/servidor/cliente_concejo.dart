/// Habla con el servidor del pueblo (`social/wp-plugin/concejo`,
/// `includes/api.php`). La persona se identifica con su código en papel.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../datos/json_dominio.dart';
import '../estado/accion.dart';

/// No hay red o el servidor no contesta: se sigue con lo guardado.
class SinConexion implements Exception {
  const SinConexion(this.detalle);
  final String detalle;
  @override
  String toString() => 'SinConexion($detalle)';
}

/// El código no vale (mal tecleado o la persona está de baja).
class CodigoIncorrecto implements Exception {
  const CodigoIncorrecto();
}

class ErrorServidor implements Exception {
  const ErrorServidor(this.estado, this.cuerpo);
  final int estado;
  final String cuerpo;
  @override
  String toString() => 'ErrorServidor($estado)';
}

/// Lo que teclea la persona («concejo.mipueblo.eus») a la dirección de la
/// API («https://concejo.mipueblo.eus/wp-json/concejo/v1/»).
Uri direccionApi(String texto) {
  var limpio = texto.trim();
  if (!limpio.contains('://')) limpio = 'https://$limpio';
  if (!limpio.contains('/wp-json/')) {
    limpio = '${limpio.replaceAll(RegExp(r'/+$'), '')}/wp-json/concejo/v1';
  }
  return Uri.parse(limpio.endsWith('/') ? limpio : '$limpio/');
}

class ClienteConcejo {
  ClienteConcejo({
    required this.api,
    required this.codigo,
    http.Client? cliente,
    this.espera = const Duration(seconds: 20),
  }) : _http = cliente ?? http.Client();

  final Uri api;
  final String codigo;
  final Duration espera;
  final http.Client _http;

  Map<String, String> get _cabeceras => {
        'Authorization': 'Bearer $codigo',
        'Content-Type': 'application/json',
      };

  Future<http.Response> _pedir(
      Future<http.Response> Function() peticion) async {
    final http.Response respuesta;
    try {
      respuesta = await peticion().timeout(espera);
    } on TimeoutException {
      throw const SinConexion('tiempo de espera');
    } on http.ClientException catch (error) {
      throw SinConexion(error.message);
    }
    if (respuesta.statusCode == 401) throw const CodigoIncorrecto();
    if (respuesta.statusCode == 503) {
      throw const SinConexion('servidor ocupado');
    }
    if (respuesta.statusCode != 200) {
      throw ErrorServidor(respuesta.statusCode, respuesta.body);
    }
    return respuesta;
  }

  /// Lo que ve la persona, o `null` si no ha cambiado desde [huella].
  Future<Json?> estado({String? huella}) async {
    final respuesta = await _pedir(() => _http.get(
          api.resolve('estado').replace(
              queryParameters: huella == null ? null : {'huella': huella}),
          headers: _cabeceras,
        ));
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Json;
    return json['sin_cambios'] == true ? null : json;
  }

  /// Aplica la cola en el servidor. Devuelve, por uid de acción, `null` si
  /// se aceptó o el motivo del rechazo.
  Future<Map<String, String?>> enviarAcciones(
      List<AccionConcejo> acciones) async {
    final respuesta = await _pedir(() => _http.post(
          api.resolve('acciones'),
          headers: _cabeceras,
          body: jsonEncode({
            'acciones': [for (final accion in acciones) accion.aJson()],
          }),
        ));
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes)) as Json;
    return {
      for (final resultado in json['resultados'] as List)
        (resultado as Json)['uid'] as String: resultado['aceptada'] == true
            ? null
            : (resultado['motivo'] as String? ?? ''),
    };
  }

  /// La mesa saca un código nuevo para una persona (anula el anterior).
  Future<String> nuevoCodigo(String personaUid) async {
    final respuesta = await _pedir(() => _http.post(
          api.resolve('personas/${Uri.encodeComponent(personaUid)}/codigo'),
          headers: _cabeceras,
        ));
    return (jsonDecode(respuesta.body) as Json)['codigo'] as String;
  }
}
