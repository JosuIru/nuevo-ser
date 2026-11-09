import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

const _centro = LatLng(42.8226, -2.0315);

/// GPS simulado: cada lectura avanza unos metros hacia el este o el norte.
Future<LecturaGps?> Function() _gpsQueCamina(List<LatLng> recorrido) {
  var paso = 0;
  return () async =>
      (posicion: recorrido[paso++ % recorrido.length], precisionMetros: 4.0);
}

Future<List<LatLng>?> _abrirEditor(WidgetTester tester,
    {List<LatLng> inicial = const [],
    Future<LecturaGps?> Function()? gps}) async {
  List<LatLng>? devuelto;
  var cerrado = false;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (contexto) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              devuelto = await Navigator.of(contexto)
                  .push<List<LatLng>>(MaterialPageRoute(
                      builder: (_) => PantallaEditorArea(
                            inicial: inicial,
                            centro: _centro,
                            conTeselas: false,
                            leerGps: gps ?? () async => null,
                          )));
              cerrado = true;
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return cerrado ? devuelto : null;
}

void main() {
  testWidgets('caminando: tres esquinas con el GPS y se guarda el área',
      (tester) async {
    List<LatLng>? resultado;
    final recorrido = [
      _centro,
      const LatLng(42.8226, -2.0305),
      const LatLng(42.8236, -2.0305),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (contexto) => ElevatedButton(
          onPressed: () async => resultado = await Navigator.of(contexto)
              .push<List<LatLng>>(MaterialPageRoute(
                  builder: (_) => PantallaEditorArea(
                      centro: _centro,
                      conTeselas: false,
                      leerGps: _gpsQueCamina(recorrido)))),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final miPosicion = find.text(SoleraL10n.t('mapa.area_mi_posicion'));
    for (var vez = 0; vez < 3; vez++) {
      await tester.tap(miPosicion);
      await tester.pumpAndSettle();
    }
    final resumen =
        tester.widget<Text>(find.byKey(const ValueKey('mapa.resumen'))).data!;
    expect(resumen, contains('3'));
    expect(resumen, contains('ha'));

    await tester.tap(find.text(SoleraL10n.t('mapa.area_guardar')));
    await tester.pumpAndSettle();
    expect(resultado, recorrido);
  });

  testWidgets('tocar el mapa añade esquinas; elegir una y quitarla',
      (tester) async {
    await _abrirEditor(tester, inicial: [
      _centro,
      const LatLng(42.8226, -2.0305),
      const LatLng(42.8236, -2.0305),
      const LatLng(42.8236, -2.0315),
    ]);
    // Cuatro esquinas y cuatro «+».
    expect(find.byKey(const ValueKey('mapa.esquina.3')), findsOneWidget);
    expect(find.byKey(const ValueKey('mapa.lado.3')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mapa.esquina.0')));
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('mapa.area_ayuda_elegida')), findsOneWidget);
    await tester.tap(find.text(SoleraL10n.t('mapa.area_quitar_esquina')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('mapa.esquina.3')), findsNothing);

    await tester.tap(find.text(SoleraL10n.t('mapa.area_deshacer')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('mapa.esquina.3')), findsOneWidget);
  });

  testWidgets('tocar el mapa vacío pone una esquina', (tester) async {
    await _abrirEditor(tester);
    expect(find.text(SoleraL10n.t('mapa.area_ayuda_vacia')), findsOneWidget);
    await tester.tapAt(const Offset(200, 300));
    // flutter_map espera a descartar el doble toque.
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('mapa.esquina.0')), findsOneWidget);
  });

  testWidgets('marcar punto: devuelve el centro y avisa sin GPS',
      (tester) async {
    PuntoMarcado? resultado;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (contexto) => ElevatedButton(
          onPressed: () async => resultado = await Navigator.of(contexto)
              .push<PuntoMarcado>(MaterialPageRoute(
                  builder: (_) => PantallaMarcarPunto(
                      inicial: _centro,
                      conTeselas: false,
                      leerGps: () async => null))),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.my_location));
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('mapa.sin_gps')), findsOneWidget);
    await tester.tap(find.text(SoleraL10n.t('mapa.punto_usar')));
    await tester.pumpAndSettle();
    expect(resultado!.punto!.latitude, closeTo(_centro.latitude, 1e-9));
  });

  testWidgets('campo de área: superficie y «usar la superficie calculada»',
      (tester) async {
    double? copiada;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CampoArea(
          vertices: const [
            _centro,
            LatLng(42.8226, -2.0305),
            LatLng(42.8236, -2.0305),
            LatLng(42.8236, -2.0315),
          ],
          alCambiar: (_) {},
          alUsarSuperficie: (hectareas) => copiada = hectareas,
        ),
      ),
    ));
    expect(find.textContaining('ha'), findsWidgets);
    await tester.tap(find.textContaining(
        SoleraL10n.t('mapa.usar_superficie').split('(').first.trim()));
    // ~82 m × 111 m ≈ 0,91 ha.
    expect(copiada, closeTo(0.91, 0.05));
  });

  testWidgets('campo de área vacío invita a marcarla', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: CampoArea(
              vertices: const [], alCambiar: (_) {}, alUsarSuperficie: (_) {})),
    ));
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_area')), findsOneWidget);
    expect(find.textContaining('ha)'), findsNothing);
  });
}
