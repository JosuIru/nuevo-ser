import 'dart:convert';

import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Un servidor de mentira que aplica las acciones con las reglas de la app
/// (el test de paridad garantiza que son las del plugin).
class ServidorDePrueba {
  ServidorDePrueba({DateTime? hoy}) : verdad = estadoDeEjemplo(hoy: hoy);

  final EstadoConcejo verdad;
  final recibidas = <String, String?>{};
  var conRed = true;
  var codigoValido = 'K7PM-3QXD-9TRA';
  var peticionesEstado = 0;

  String get _huella => '${jsonEncode(instantaneaAJson(verdad)).hashCode}';

  http.Client cliente() => MockClient((peticion) async {
        if (!conRed) throw http.ClientException('sin red');
        if (peticion.headers['Authorization'] != 'Bearer $codigoValido') {
          return http.Response('{}', 401);
        }
        if (peticion.url.path.endsWith('/estado')) {
          peticionesEstado++;
          if (peticion.url.queryParameters['huella'] == _huella) {
            return http.Response(jsonEncode({'sin_cambios': true}), 200);
          }
          return http.Response(
              jsonEncode({
                ...instantaneaAJson(verdad),
                'yo': 'maite',
                'huella': _huella,
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        }
        final cuerpo = jsonDecode(peticion.body) as Map<String, dynamic>;
        final resultados = [];
        for (final json in cuerpo['acciones'] as List) {
          final accion = AccionConcejo.desdeJson(json as Map<String, dynamic>);
          if (!recibidas.containsKey(accion.uid)) {
            try {
              verdad
                ..verComo(accion.autorUid)
                ..rehacer(accion);
              recibidas[accion.uid] = null;
            } catch (error) {
              recibidas[accion.uid] = '$error';
            }
          }
          resultados.add({
            'uid': accion.uid,
            'aceptada': recibidas[accion.uid] == null,
            'motivo': recibidas[accion.uid] ?? '',
          });
        }
        return http.Response(jsonEncode({'resultados': resultados}), 200);
      });
}
