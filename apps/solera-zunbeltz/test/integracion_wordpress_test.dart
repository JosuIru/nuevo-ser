// Integración de la app contra un WordPress real con el plugin
// solera-zunbeltz-sync (el de `wp-plugin/solera-zunbeltz-sync/dev`). Se salta
// si no hay servidor configurado:
//
//   cd wp-plugin/solera-zunbeltz-sync/dev && docker compose up -d && ./preparar.sh
//   source wp-plugin/solera-zunbeltz-sync/dev/.tokens
//   SZS_URL=http://localhost:8790 SZS_COORDINACION=$COORDINACION SZS_TESTER=$TESTER \
//     flutter test test/integracion_wordpress_test.dart
//
// Dos móviles simulados (dos BD en memoria): coordinación y una tester.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';
import 'package:solera_zunbeltz/modelos/punto_infraestructura.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

import 'bd_en_memoria.dart';

void main() {
  final url = Platform.environment['SZS_URL'] ?? '';
  final tokenCoordinacion = Platform.environment['SZS_COORDINACION'] ?? '';
  final tokenTester = Platform.environment['SZS_TESTER'] ?? '';
  final sinServidor = url.isEmpty || tokenCoordinacion.isEmpty || tokenTester.isEmpty;

  test('coordinación y tester comparten el espacio a través de WordPress',
      () async {
    final coordinacion = ClienteSyncZunbeltz(urlBase: url, token: tokenCoordinacion);
    final tester = ClienteSyncZunbeltz(urlBase: url, token: tokenTester);
    final bdCoordinacion = await abrirBdEnMemoria();
    final bdTester = await abrirBdEnMemoria();
    final sufijo = DateTime.now().microsecondsSinceEpoch;
    final uidTester = (await tester.obtenerSesion()).sesion.persona.uid;

    // Coordinación da de alta una finca, un corral móvil, el proyecto de la
    // tester y una tarea para ella anclada al corral.
    final fincaId = await bdCoordinacion.guardarFinca(Finca(nombre: 'Zufía $sufijo'));
    final puntoId = await bdCoordinacion.guardarPunto(PuntoInfraestructura(
        fincaId: fincaId, tipo: 'corral_movil', nombre: 'Corral $sufijo',
        latitud: 42.78, longitud: -1.94));
    final proyectoId =
        await bdCoordinacion.guardarProyecto(ProyectoTest(nombre: 'Quesería $sufijo'));
    await bdCoordinacion.actualizarProyecto(proyectoId, {'persona_uid': uidTester});
    await bdCoordinacion.guardarTarea(TareaMantenimiento(
        fincaId: fincaId, puntoId: puntoId, titulo: 'Mover corral $sufijo',
        responsableUid: uidTester));
    final resultadoCoordinacion = await coordinacion.sincronizar(bdCoordinacion);
    expect(resultadoCoordinacion.rechazadasPorPermisos, 0);

    // La tester lo recibe todo, con la tarea anclada a su corral.
    await tester.sincronizar(bdTester);
    final fincaEnTester = (await bdTester.listarFincas())
        .firstWhere((finca) => finca.nombre == 'Zufía $sufijo');
    final corralEnTester = (await bdTester.listarPuntos())
        .firstWhere((punto) => punto.nombre == 'Corral $sufijo');
    expect(corralEnTester.fincaId, fincaEnTester.id);
    final tareaEnTester = (await bdTester.listarTareas())
        .firstWhere((tarea) => tarea.titulo == 'Mover corral $sufijo');
    expect(tareaEnTester.puntoId, corralEnTester.id);
    final proyectoEnTester = (await bdTester.listarProyectos())
        .firstWhere((proyecto) => proyecto.nombre == 'Quesería $sufijo');

    // La tester mueve el corral, apunta un gasto e intenta crear una finca.
    await bdTester.actualizarPuntoCoords(corralEnTester.id!, 42.79, -1.95);
    await bdTester.guardarApunte(ApunteEconomico(
        fincaId: fincaEnTester.id!, proyectoId: proyectoEnTester.id,
        tipo: 'gasto', concepto: 'Cencerro $sufijo', importeCentimos: 1500));
    await bdTester.guardarFinca(Finca(nombre: 'Inventada $sufijo'));
    final resultadoTester = await tester.sincronizar(bdTester);
    expect(resultadoTester.rechazadasPorPermisos, 1,
        reason: 'solo se rechaza la finca');
    expect((await bdTester.listarFincas()).map((finca) => finca.nombre),
        isNot(contains('Inventada $sufijo')));

    // Coordinación ve el corral movido, el gasto y la huella.
    final resultado = await coordinacion.sincronizar(bdCoordinacion);
    final corral = (await bdCoordinacion.obtenerPunto(puntoId))!;
    expect(corral.latitud, 42.79);
    final apuntes = await bdCoordinacion.listarApuntes(proyectoId: proyectoId);
    expect(apuntes.map((apunte) => apunte.concepto), contains('Cencerro $sufijo'));
    expect(
      resultado.actividadNueva.where((entrada) =>
          entrada.accion == 'mover' && entrada.etiqueta == 'Corral $sufijo'),
      isNotEmpty,
    );
  }, skip: sinServidor ? 'Sin WordPress de pruebas (SZS_URL)' : false);
}
