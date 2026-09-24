import 'dart:io';
import 'dart:ui' as ui;

import 'package:el_cuaderno/datos/almacenador_medios.dart';
import 'package:el_cuaderno/dominio/nivel_confianza.dart';
import 'package:el_cuaderno/dominio/observacion.dart';
import 'package:el_cuaderno/dominio/sit_spot.dart';
import 'package:el_cuaderno/infraestructura/memoria/repositorio_memoria.dart';
import 'package:el_cuaderno/nucleo/i18n/generado/textos_app.dart';
import 'package:el_cuaderno/vista/pantalla_sit_spot/bloque_paleta_del_lugar.dart';
import 'package:el_cuaderno/vista/pantalla_sit_spot/pantalla_pagina_sit_spot.dart';
import 'package:el_cuaderno/vista/tema/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// «Los colores de este sitio» en la página del sit spot. El extractor
/// se sustituye por uno que asigna un color por foto, así el test no
/// decodifica imágenes.
void main() {
  late RepositorioMemoria repositorio;
  late Directory directorio;
  final sitSpot = SitSpot(
    id: 'ss-1',
    nombre: 'El Roble Grande',
    dondeNombre: 'parque',
    creadoEn: DateTime(2026, 3, 1),
  );

  setUp(() async {
    repositorio = RepositorioMemoria();
    directorio = await Directory.systemTemp.createTemp('paleta_');
    await repositorio.establecerSitSpot(sitSpot);
  });

  tearDown(() async => directorio.delete(recursive: true));

  Future<void> sembrar(String id, DateTime fecha, {String? foto}) =>
      repositorio.guardarObservacion(Observacion(
        id: id,
        cuandoCreada: fecha,
        cuandoOcurrio: fecha,
        dondeNombre: 'parque',
        queVio: 'hojas',
        confianza: NivelConfianza.hipotesisActiva,
        sitSpotId: 'ss-1',
        fotoRutaLocal: foto,
      ));

  Future<void> bombear(WidgetTester tester, {AlmacenadorMedios? almacenador}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    await tester.pumpWidget(MaterialApp(
      theme: TemaCuaderno.claro(),
      localizationsDelegates: TextosApp.localizationsDelegates,
      supportedLocales: TextosApp.supportedLocales,
      locale: const Locale('es'),
      home: PantallaPaginaSitSpot(
        repositorio: repositorio,
        sitSpot: sitSpot,
        almacenadorMedios: almacenador,
        extractorColores: (ruta) async =>
            ruta.endsWith('verde.jpg') ? [0xFF3A7A3A] : [0xFFB0702A],
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('una franja por estación con fotos', (tester) async {
    await sembrar('a', DateTime(2026, 4, 10), foto: 'medios/verde.jpg');
    await sembrar('b', DateTime(2026, 5, 2), foto: 'medios/verde.jpg');
    await sembrar('c', DateTime(2026, 10, 20), foto: 'medios/ocre.jpg');
    await sembrar('d', DateTime(2026, 7, 1)); // sin foto: no cuenta
    await bombear(tester,
        almacenador: AlmacenadorMedios(proveedorDirRaiz: () async => directorio));

    expect(find.text('Los colores de este sitio'), findsOneWidget);
    expect(find.text('primavera · 2 fotos'), findsOneWidget);
    expect(find.text('otoño · 1 foto'), findsOneWidget);
    expect(find.textContaining('verano'), findsNothing,
        reason: 'una estación sin fotos no aparece: nada que rellenar');
  });

  testWidgets('sin fotos, el bloque no aparece', (tester) async {
    await sembrar('a', DateTime(2026, 4, 10));
    await bombear(tester,
        almacenador: AlmacenadorMedios(proveedorDirRaiz: () async => directorio));
    expect(find.text('Los colores de este sitio'), findsNothing);
  });

  testWidgets('sin almacenador, el bloque no aparece', (tester) async {
    await sembrar('a', DateTime(2026, 4, 10), foto: 'medios/verde.jpg');
    await bombear(tester);
    expect(find.text('Los colores de este sitio'), findsNothing);
  });

  testWidgets('el extractor real lee un PNG del disco', (tester) async {
    await tester.runAsync(() async {
      final grabadora = ui.PictureRecorder();
      final lienzo = Canvas(grabadora);
      lienzo.drawRect(const Rect.fromLTWH(0, 0, 64, 64), Paint()..color = const Color(0xFF3A7A3A));
      lienzo.drawRect(const Rect.fromLTWH(0, 48, 64, 16), Paint()..color = const Color(0xFFD8C8A0));
      final imagen = await grabadora.endRecording().toImage(64, 64);
      final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
      final fichero = File('${directorio.path}/prueba.png');
      await fichero.writeAsBytes(png!.buffer.asUint8List());

      final colores = await extraerColoresDeFoto(fichero.path);
      expect(colores.first, 0xFF3A7A3A, reason: 'el verde ocupa tres cuartos');
      expect(colores, contains(0xFFD8C8A0));
    });
  });
}
