import 'dart:convert';

import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/dominio/urna.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:concejo/servidor/almacen_local.dart';
import 'package:concejo/servidor/cliente_concejo.dart';
import 'package:concejo/servidor/sincronizador.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _hoy = DateTime(2026, 11, 10, 12);

/// Un servidor de mentira que aplica las acciones con las reglas de la app
/// (el test de paridad garantiza que son las del plugin).
class _ServidorDePrueba {
  final EstadoConcejo verdad = estadoDeEjemplo(hoy: _hoy);
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

void main() {
  late _ServidorDePrueba servidor;
  late AlmacenEnMemoria almacen;
  late ClienteConcejo cliente;

  setUp(() {
    servidor = _ServidorDePrueba();
    almacen = AlmacenEnMemoria();
    cliente = ClienteConcejo(
      api: direccionApi('concejo.ejemplo.eus'),
      codigo: servidor.codigoValido,
      cliente: servidor.cliente(),
    );
  });

  test('la dirección del pueblo se completa', () {
    expect(direccionApi('concejo.ejemplo.eus').toString(),
        'https://concejo.ejemplo.eus/wp-json/concejo/v1/');
    expect(direccionApi('http://localhost:8080/').toString(),
        'http://localhost:8080/wp-json/concejo/v1/');
  });

  test('sin red se vota igual, la cola se guarda y sale al volver la red',
      () async {
    final sincronizador = await Sincronizador.entrar(
        cliente: cliente, almacen: almacen, reloj: () => _hoy);
    expect(sincronizador.estado.personaActual.uid, 'maite');

    servidor.conRed = false;
    sincronizador.estado.votar('fiestas', {votoSi});
    expect(sincronizador.estado.heVotado('fiestas'), isTrue);
    expect(sincronizador.pendientes, 1);
    await sincronizador.sincronizar();
    expect(sincronizador.sinConexion, isTrue);
    expect(sincronizador.pendientes, 1);

    // Se cierra la app y se vuelve a abrir, aún sin red.
    final reabierto = Sincronizador.abrir(
        cliente: cliente, almacen: almacen, reloj: () => _hoy)!;
    expect(reabierto.pendientes, 1);
    expect(reabierto.estado.heVotado('fiestas'), isTrue);

    servidor.conRed = true;
    await reabierto.sincronizar();
    expect(reabierto.sinConexion, isFalse);
    expect(reabierto.pendientes, 0);
    expect(servidor.verdad.urna('fiestas').haParticipado('maite'), isTrue);
    expect(reabierto.estado.heVotado('fiestas'), isTrue);
    expect(reabierto.rechazadas, isEmpty);
  });

  test('si el servidor la rechaza, se quita y se avisa', () async {
    final sincronizador = await Sincronizador.entrar(
        cliente: cliente, almacen: almacen, reloj: () => _hoy);
    // Maite ya votó en papel y la mesa la anotó desde otro teléfono.
    servidor.verdad
      ..verComo('ane')
      ..anotarVotoPresencial('fiestas', 'maite');
    servidor.conRed = false;
    sincronizador.estado.votar('fiestas', {votoNo});
    servidor.conRed = true;
    await sincronizador.sincronizar();
    expect(sincronizador.pendientes, 0);
    expect(sincronizador.rechazadas.single.accion.tipo, TipoAccion.votar);
    expect(sincronizador.estado.urna('fiestas').participaciones.single.canal,
        CanalParticipacion.presencial);
  });

  test('si nada ha cambiado, no se vuelve a bajar todo', () async {
    final sincronizador = await Sincronizador.entrar(
        cliente: cliente, almacen: almacen, reloj: () => _hoy);
    final antes = almacen.leer(Sincronizador.claveVista);
    await sincronizador.sincronizar();
    expect(almacen.leer(Sincronizador.claveVista), antes);
    expect(servidor.peticionesEstado, 2);
  });

  test('un código que ya no vale se dice', () async {
    final sincronizador = await Sincronizador.entrar(
        cliente: cliente, almacen: almacen, reloj: () => _hoy);
    servidor.codigoValido = 'OTRO';
    await sincronizador.sincronizar();
    expect(sincronizador.codigoIncorrecto, isTrue);
    await expectLater(
      Sincronizador.entrar(
          cliente: cliente, almacen: AlmacenEnMemoria(), reloj: () => _hoy),
      throwsA(isA<CodigoIncorrecto>()),
    );
  });
}
