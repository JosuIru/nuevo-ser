import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final config = configActualizacionesMonorepo('uno-roto');

  http.Client cliente(List<Map<String, Object?>> releases, {int codigo = 200}) =>
      MockClient((_) async => http.Response(jsonEncode(releases), codigo));

  Map<String, Object?> release(String tag, List<String> assets, {bool draft = false}) => {
        'tag_name': tag,
        'draft': draft,
        'prerelease': false,
        'body': 'Notas de $tag',
        'published_at': '2026-09-20T10:00:00Z',
        'assets': [for (final a in assets) {'name': a, 'browser_download_url': 'https://x/$a'}],
      };

  test('elige la release de la app aunque haya otras más nuevas del repo', () async {
    final estado = await consultarEstadoActualizaciones(
      config,
      clienteHttp: cliente([
        release('las-versiones-0.2.0', ['las-versiones-0.2.0.apk']),
        release('uno-roto-1.0.1+30', ['uno-roto-1.0.1+30.apk'], draft: true),
        release('uno-roto-1.0.0+25', ['uno-roto-1.0.0+25.apk']),
      ]),
      obtenerVersionInstalada: () async => '1.0.0+19',
    );
    expect(estado.versionPublicada, '1.0.0+25');
    expect(estado.urlAsset, 'https://x/uno-roto-1.0.0+25.apk');
    expect(estado.hayNueva, isTrue);
    expect(estado.notas, 'Notas de uno-roto-1.0.0+25');
  });

  test('al día: no hay nueva pero sí se dice cuál es la última', () async {
    final estado = await consultarEstadoActualizaciones(
      config,
      clienteHttp: cliente([release('uno-roto-1.0.0+19', ['uno-roto-1.0.0+19.apk'])]),
      obtenerVersionInstalada: () async => '1.0.0+19',
    );
    expect(estado.versionPublicada, '1.0.0+19');
    expect(estado.hayNueva, isFalse);
    expect(estado.sinConexion, isFalse);
  });

  test('sin red o con la API caída: sinConexion', () async {
    final caida = await consultarEstadoActualizaciones(config,
        clienteHttp: cliente(const [], codigo: 403), obtenerVersionInstalada: () async => '1.0.0');
    expect(caida.sinConexion, isTrue);
    final sinRed = await consultarEstadoActualizaciones(config,
        clienteHttp: MockClient((_) => throw const SocketExceptionSimulada()),
        obtenerVersionInstalada: () async => '1.0.0');
    expect(sinRed.sinConexion, isTrue);
  });

  testWidgets('la pantalla enseña la versión nueva y el botón de instalar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      home: PantallaEstadoActualizaciones(
        config: config,
        nombreApp: 'Uno Roto',
        consultar: () async => const EstadoActualizaciones(
          versionInstalada: '1.0.0+19',
          versionPublicada: '1.0.0+25',
          urlAsset: 'https://x/uno-roto-1.0.0+25.apk',
          notas: 'La segunda sala.',
          comprobadoMs: 0,
          publicadoMs: 0,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('1.0.0+19'), findsOneWidget);
    expect(find.text('1.0.0+25'), findsOneWidget);
    expect(find.text('Hay una versión nueva.'), findsOneWidget);
    expect(find.text('La segunda sala.'), findsOneWidget);
    expect(find.byKey(const ValueKey('boton-instalar-actualizacion')), findsOneWidget);
  });

  testWidgets('al día: sin botón de instalar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      home: PantallaEstadoActualizaciones(
        config: config,
        nombreApp: 'Uno Roto',
        traducir: (texto) => texto == 'Tienes la última versión.' ? 'Azken bertsioa duzu.' : texto,
        consultar: () async => const EstadoActualizaciones(
            versionInstalada: '1.0.0+25', versionPublicada: '1.0.0+25', urlAsset: 'https://x/a.apk', comprobadoMs: 0),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Azken bertsioa duzu.'), findsOneWidget);
    expect(find.byKey(const ValueKey('boton-instalar-actualizacion')), findsNothing);
  });
}

class SocketExceptionSimulada implements Exception {
  const SocketExceptionSimulada();
}
