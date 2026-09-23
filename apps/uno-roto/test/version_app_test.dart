import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/version_app.dart';

void main() {
  group('VersionApp.parse', () {
    test('formato X.Y.Z+N', () {
      final v = VersionApp.parse('1.0.0+17');
      expect(v, isNotNull);
      expect(v!.mayor, 1);
      expect(v.menor, 0);
      expect(v.parche, 0);
      expect(v.build, 17);
    });

    test('formato con prefijo uno-roto-', () {
      final v = VersionApp.parse('uno-roto-1.0.0+17');
      expect(v?.build, 17);
    });

    test('sin build number → build = 0', () {
      final v = VersionApp.parse('1.2.3');
      expect(v?.build, 0);
    });

    test('basura → null sin lanzar', () {
      expect(VersionApp.parse('vaya pifia'), isNull);
      expect(VersionApp.parse(''), isNull);
      expect(VersionApp.parse('1.2'), isNull);
      expect(VersionApp.parse('1.2.3.4+5'), isNull);
    });

    test('trim de espacios y saltos de línea', () {
      expect(VersionApp.parse('  1.0.0+5\n')?.build, 5);
    });
  });

  group('VersionApp.deStrings', () {
    test('desde PackageInfo (version + buildNumber por separado)', () {
      final v = VersionApp.deStrings(version: '1.0.0', buildNumber: '17');
      expect(v.build, 17);
    });

    test('buildNumber no numérico → 0', () {
      final v = VersionApp.deStrings(version: '1.0.0', buildNumber: 'pre');
      expect(v.build, 0);
    });

    test('version sin 3 partes → lanza', () {
      expect(
        () => VersionApp.deStrings(version: '1.0', buildNumber: '1'),
        throwsFormatException,
      );
    });
  });

  group('VersionApp comparable', () {
    test('build menor → versión menor', () {
      final a = VersionApp.parse('1.0.0+10')!;
      final b = VersionApp.parse('1.0.0+17')!;
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a == a, isTrue);
    });

    test('parche manda sobre build', () {
      final a = VersionApp.parse('1.0.1+0')!;
      final b = VersionApp.parse('1.0.0+99')!;
      expect(a > b, isTrue);
    });

    test('mayor manda sobre menor + parche', () {
      final a = VersionApp.parse('2.0.0+0')!;
      final b = VersionApp.parse('1.99.99+99')!;
      expect(a > b, isTrue);
    });

    test('toString canónico X.Y.Z+N', () {
      expect(VersionApp.parse('1.0.0+17').toString(), '1.0.0+17');
    });
  });
}
