// La app contra un WordPress con el plugin de verdad. Solo corre si se le
// dice dónde está y con qué códigos (una persona de la mesa y una vecina):
//
//   CONCEJO_SERVIDOR=http://localhost:8765 \
//   CONCEJO_CODIGO_MESA=… CONCEJO_CODIGO_VECINA=… \
//   flutter test test/servidor/servidor_real_test.dart
//
// Escribe en ese servidor: úsese con uno de pruebas.
import 'dart:io';

import 'package:concejo/dominio/debate.dart';
import 'package:concejo/servidor/almacen_local.dart';
import 'package:concejo/servidor/cliente_concejo.dart';
import 'package:concejo/servidor/sincronizador.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final entorno = Platform.environment;
  final servidor = entorno['CONCEJO_SERVIDOR'];
  final saltar = servidor == null
      ? 'Sin CONCEJO_SERVIDOR: no hay servidor de pruebas'
      : false;

  Future<Sincronizador> entrar(String codigo) => Sincronizador.entrar(
        cliente: ClienteConcejo(api: direccionApi(servidor!), codigo: codigo),
        almacen: AlmacenEnMemoria(),
      );

  test('una vecina aporta sin nombre y la mesa lo modera', () async {
    final vecina = await entrar(entorno['CONCEJO_CODIGO_VECINA']!);
    final mesa = await entrar(entorno['CONCEJO_CODIGO_MESA']!);
    expect(mesa.estado.soyMesa, isTrue);
    expect(vecina.estado.soyMesa, isFalse);

    final abierto = vecina.estado.asuntos.firstWhere((a) =>
        vecina.estado.debate(a.uid).asuntoUid == a.uid &&
        (a.faseEn(vecina.estado.ahora).name == 'debate' ||
            a.faseEn(vecina.estado.ahora).name == 'decision'));
    final texto = 'Prueba sin nombre ${DateTime.now().microsecondsSinceEpoch}';
    vecina.estado
        .aportar(abierto.uid, TipoAportacion.duda, texto, anonima: true);
    await vecina.sincronizar();
    expect(vecina.pendientes, 0);
    expect(vecina.rechazadas, isEmpty);

    await mesa.sincronizar();
    final recibida = mesa.estado
        .debate(abierto.uid)
        .aportaciones
        .firstWhere((a) => a.texto == texto);
    expect(recibida.autorUid, '', reason: 'la mesa no ve quién la escribió');
    mesa.estado.moderar(abierto.uid, recibida.uid, EstadoModeracion.visible);
    await mesa.sincronizar();
    expect(mesa.rechazadas, isEmpty);

    await vecina.sincronizar();
    final suya = vecina.estado
        .debate(abierto.uid)
        .aportaciones
        .firstWhere((a) => a.texto == texto);
    expect(suya.estado, EstadoModeracion.visible);
    expect(suya.autorUid, vecina.estado.personaActual.uid,
        reason: 'quien la escribió la sigue viendo como suya');

    // Lo que no le toca, el servidor lo rechaza aunque la app lo deje.
    final ajena = mesa.estado.asuntos.first.uid;
    vecina.estado.alHacerAccion = null;
    expect(
        () => vecina.estado.moderar(
            ajena, recibida.uid, EstadoModeracion.retirada,
            motivo: 'x'),
        throwsStateError);
  }, skip: saltar);
}
