import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// El aviso de «versión disponible» se cachea 3 h. Si entretanto se instala
// la versión nueva, la caché no puede seguir diciendo «tienes la vieja».
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = ConfigActualizaciones(
    repoOwner: 'JosuIru',
    repoName: 'cuadernos-de-campo',
    prefijoTag: 'fosiles-v',
    sufijoAsset: 'fosiles-',
  );

  void instalada(String version, String build) => PackageInfo.setMockInitialValues(
        appName: 'Fósiles',
        packageName: 'com.josu.fosiles',
        version: version,
        buildNumber: build,
        buildSignature: '',
      );

  final clienteConRelease = MockClient((_) async => http.Response(
        jsonEncode([
          {
            'tag_name': 'fosiles-v1.0.21',
            'draft': false,
            'prerelease': false,
            'body': 'Notas',
            'published_at': '2026-10-22T21:57:11Z',
            'assets': [
              {'name': 'fosiles-v1.0.21.apk', 'browser_download_url': 'https://x/fosiles-v1.0.21.apk'},
            ],
          },
        ]),
        200,
      ));

  final clienteSinRed = MockClient((_) async => throw Exception('sin red'));
  final clienteCuotaAgotada = MockClient((_) async => http.Response('{}', 403));

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('con la 1.0.18 instalada avisa de la 1.0.21', () async {
    instalada('1.0.18', '19');
    final aviso = await comprobarActualizacionDisponible(config, clienteHttp: clienteConRelease);
    expect(aviso?.versionInstalada, '1.0.18+19');
    expect(aviso?.versionDisponible, '1.0.21');
  });

  test('tras instalar la 1.0.21, la caché de 3 h ya no avisa', () async {
    instalada('1.0.18', '19');
    await comprobarActualizacionDisponible(config, clienteHttp: clienteConRelease);

    instalada('1.0.21', '22');
    final aviso = await comprobarActualizacionDisponible(config, clienteHttp: clienteSinRed);
    expect(aviso, isNull);
  });

  test('tras instalar la 1.0.21, sin red tampoco devuelve el aviso viejo', () async {
    instalada('1.0.18', '19');
    await comprobarActualizacionDisponible(config, clienteHttp: clienteConRelease);

    instalada('1.0.21', '22');
    final aviso = await comprobarActualizacionDisponible(config,
        forzarRefresco: true, clienteHttp: clienteSinRed);
    expect(aviso, isNull);
  });

  test('tras instalar la 1.0.21, con la cuota de GitHub agotada tampoco', () async {
    instalada('1.0.18', '19');
    await comprobarActualizacionDisponible(config, clienteHttp: clienteConRelease);

    instalada('1.0.21', '22');
    final aviso = await comprobarActualizacionDisponible(config,
        forzarRefresco: true, clienteHttp: clienteCuotaAgotada);
    expect(aviso, isNull);
  });

  test('si se instala una intermedia, el aviso cacheado dice la que hay ahora', () async {
    instalada('1.0.18', '19');
    await comprobarActualizacionDisponible(config, clienteHttp: clienteConRelease);

    instalada('1.0.20', '21');
    final aviso = await comprobarActualizacionDisponible(config, clienteHttp: clienteSinRed);
    expect(aviso?.versionInstalada, '1.0.20+21');
    expect(aviso?.versionDisponible, '1.0.21');
  });
}
