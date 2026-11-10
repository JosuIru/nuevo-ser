import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_avisos/nuevo_ser_avisos.dart';

void main() {
  group('idDeClave', () {
    test('es estable y positivo de 31 bits', () {
      expect(idDeClave('plan.1.amasado'), idDeClave('plan.1.amasado'));
      for (final clave in [
        '',
        'a',
        'plan.1.amasado',
        'masa_madre.3',
        'ñandú €'
      ]) {
        final id = idDeClave(clave);
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThanOrEqualTo(0x7fffffff));
      }
    });

    test('valor conocido (FNV-1a): no cambia entre versiones', () {
      // FNV-1a 32 de «a» = 0xe40c292c, recortado a 31 bits.
      expect(idDeClave('a'), 0xe40c292c & 0x7fffffff);
      expect(idDeClave(''), 0x811c9dc5 & 0x7fffffff);
    });

    test('claves parecidas dan ids distintos', () {
      final ids = {
        for (var plan = 0; plan < 50; plan++)
          for (final fase in ['refresco', 'amasado', 'formado', 'horno'])
            idDeClave('plan.$plan.$fase'),
      };
      expect(ids.length, 200);
    });
  });

  group('ServicioAvisosEnMemoria', () {
    final ahora = DateTime(2026, 11, 10, 20);
    late ServicioAvisosEnMemoria avisos;

    setUp(() => avisos = ServicioAvisosEnMemoria(reloj: () => ahora));

    test('programa, sustituye por clave y ordena por hora', () async {
      expect(
          await avisos.programar(
              clave: 'plan.1.horno',
              cuando: ahora.add(const Duration(hours: 9)),
              titulo: 'Horno'),
          isTrue);
      await avisos.programar(
          clave: 'plan.1.amasado',
          cuando: ahora.add(const Duration(hours: 1)),
          titulo: 'Amasar');
      await avisos.programar(
          clave: 'plan.1.amasado',
          cuando: ahora.add(const Duration(hours: 2)),
          titulo: 'Amasar ya');
      final pendientes = await avisos.pendientes();
      expect(pendientes.map((aviso) => aviso.clave),
          ['plan.1.amasado', 'plan.1.horno']);
      expect(pendientes.first.titulo, 'Amasar ya');
    });

    test('no programa en el pasado', () async {
      expect(
          await avisos.programar(
              clave: 'x',
              cuando: ahora.subtract(const Duration(minutes: 1)),
              titulo: 'x'),
          isFalse);
      expect(await avisos.pendientes(), isEmpty);
    });

    test('cancelar y cancelarGrupo', () async {
      for (final clave in ['plan.1.a', 'plan.1.b', 'plan.12.a', 'masa.1']) {
        await avisos.programar(
            clave: clave,
            cuando: ahora.add(const Duration(hours: 1)),
            titulo: clave);
      }
      await avisos.cancelar('masa.1');
      await avisos.cancelarGrupo('plan.1.');
      expect((await avisos.pendientes()).map((aviso) => aviso.clave),
          ['plan.12.a']);
    });

    test('permiso denegado: no programa y no lanza', () async {
      avisos.permisoConcedido = false;
      expect(await avisos.pedirPermiso(), isFalse);
      expect(
          await avisos.programar(
              clave: 'x',
              cuando: ahora.add(const Duration(hours: 1)),
              titulo: 'x'),
          isFalse);
    });

    test('los vencidos dejan de estar pendientes', () async {
      var reloj = ahora;
      avisos.reloj = () => reloj;
      await avisos.programar(
          clave: 'x', cuando: ahora.add(const Duration(hours: 1)), titulo: 'x');
      reloj = ahora.add(const Duration(hours: 2));
      expect(await avisos.pendientes(), isEmpty);
    });
  });

  group('ServicioAvisosLocales sin plataforma', () {
    // En los tests no hay plugin nativo: nada debe lanzar.
    final avisos = ServicioAvisosLocales(
        const ConfiguracionAvisos(idCanal: 'prueba', nombreCanal: 'Prueba'));

    test('ningún método lanza', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await avisos.inicializar();
      expect(await avisos.pedirPermiso(), isA<bool>());
      expect(
          await avisos.programar(
              clave: 'x',
              cuando: DateTime.now().add(const Duration(hours: 1)),
              titulo: 'x'),
          isA<bool>());
      await avisos.cancelar('x');
      await avisos.cancelarGrupo('x');
      expect(await avisos.pendientes(), isA<List<AvisoPendiente>>());
    });

    test('en el pasado devuelve false sin tocar el plugin', () async {
      expect(
          await avisos.programar(
              clave: 'x',
              cuando: DateTime.now().subtract(const Duration(seconds: 1)),
              titulo: 'x'),
          isFalse);
    });
  });
}
