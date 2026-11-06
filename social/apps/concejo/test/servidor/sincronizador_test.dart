import 'package:concejo/dominio/urna.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/servidor/almacen_local.dart';
import 'package:concejo/servidor/cliente_concejo.dart';
import 'package:concejo/servidor/sincronizador.dart';
import 'package:flutter_test/flutter_test.dart';

import 'servidor_de_prueba.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  late ServidorDePrueba servidor;
  late AlmacenEnMemoria almacen;
  late ClienteConcejo cliente;

  setUp(() {
    servidor = ServidorDePrueba(hoy: _hoy);
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
