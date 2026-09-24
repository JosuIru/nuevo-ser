import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:las_versiones/datos/registro_maestria_archivo.dart';
import 'package:las_versiones/dominio/atico/oficios_atico.dart';
import 'package:las_versiones/dominio/atico/partida_documento_roto.dart';
import 'package:las_versiones/dominio/atico/voz_andres_atico.dart';
import 'package:las_versiones/dominio/catalogo_brechas.dart';
import 'package:las_versiones/vista/atico/pantalla_atico.dart';
import 'package:las_versiones/vista/atico/pantalla_documento_roto.dart';

void main() {
  final flags = {
    CatalogoBrechas.brecha11.flagDeCompletado,
    CatalogoBrechas.brecha21.flagDeCompletado,
  };

  setUp(() {
    final vista = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    vista.physicalSize = const Size(1000, 3200);
    vista.devicePixelRatio = 1.0;
  });

  Future<void> tocarTiraYDocumento(WidgetTester tester, Tira tira, DocumentoEnMesa documento) async {
    await tester.tap(find.text(tira.texto).last);
    await tester.pump();
    await tester.tap(find.text(documento.fuente.tipoVisible));
    await tester.pump();
  }

  testWidgets('se completa tocando tira y documento, y termina con Andrés', (tester) async {
    final partida = PartidaDocumentoRoto.montar(brechasCerradas(flags), semilla: 1)!;
    await tester.pumpWidget(MaterialApp(home: PantallaDocumentoRoto(partida: partida)));

    for (var indice = 0; indice < partida.rondas.length; indice++) {
      final ronda = partida.rondas[indice];
      for (final tira in ronda.tirasQueSeColocan) {
        final destino = ronda.documentos.firstWhere(tira.encajaEn);
        await tocarTiraYDocumento(tester, tira, destino);
        expect(partida.documentoDe(tira), isNotNull, reason: tira.id);
      }
      await tester.tap(find.text(indice == partida.rondas.length - 1
          ? 'Cerrar la caja'
          : 'Siguiente mesa'));
      await tester.pumpAndSettle();
    }
    expect(find.text(VozAndresAtico.cierreDocumentoRoto(null)), findsOneWidget);
    expect(find.text('Volver al ático'), findsOneWidget);
  });

  testWidgets('si no encaja, Andrés da el criterio y la tira sigue suelta', (tester) async {
    final partida = PartidaDocumentoRoto.montar(brechasCerradas(flags), semilla: 1)!;
    await tester.pumpWidget(MaterialApp(home: PantallaDocumentoRoto(partida: partida)));
    final ronda = partida.rondaActual;
    final tira = ronda.tirasQueSeColocan.first;
    final equivocado = ronda.documentos.firstWhere((d) => !tira.encajaEn(d));

    await tocarTiraYDocumento(tester, tira, equivocado);
    expect(find.text(VozAndresAtico.pistaNoEncaja(tira.tipo)), findsOneWidget);
    expect(partida.tirasSueltas, contains(tira));
  });

  testWidgets('el ático abre El documento roto', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PantallaAtico(flagsActivos: flags)));
    await tester.tap(find.text('El documento roto'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaDocumentoRoto), findsOneWidget);
  });

  testWidgets('apunta sólo el primer intento de cada tira', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repositorio = RepositorioHabilidades(
      gestor: GestorPerfiles(
        namespace: 'nuevoser.lasversiones',
        sufijoNombreVisible: 'nombre_jugador',
      ),
    );
    final partida = PartidaDocumentoRoto.montar(brechasCerradas(flags), semilla: 1)!;
    await tester.pumpWidget(MaterialApp(
      home: PantallaDocumentoRoto(
        partida: partida,
        registro: RegistroMaestriaArchivo(repositorio: repositorio),
      ),
    ));
    final ronda = partida.rondaActual;
    final tira = ronda.tirasQueSeColocan.first;
    final equivocado = ronda.documentos.firstWhere((d) => !tira.encajaEn(d));
    final bueno = ronda.documentos.firstWhere(tira.encajaEn);

    await tocarTiraYDocumento(tester, tira, equivocado);
    await tocarTiraYDocumento(tester, tira, bueno);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    final estado = await tester.runAsync(() => repositorio.cargar('HF.02'));
    expect(estado!.totalExposiciones, 1, reason: 'el segundo intento no cuenta');
    expect(estado.intentosRecientes.single.acierto, isFalse);
  });
}
