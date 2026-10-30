import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:path/path.dart' as path_lib;

// La copia automática se hace cada vez que la app pasa a segundo plano.
// Si un día arranca sin datos, esa BD vacía no puede pisar la copia buena.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dirDocumentos;
  late File ficheroDb;
  var bdVacia = false;

  File copiaAuto() => File(path_lib.join(dirDocumentos.path, 'backup_auto', 'prueba_auto.db'));

  AutoBackup crearAutoBackup() => AutoBackup(
        nombreApp: 'prueba',
        obtenerRutaDb: () async => ficheroDb.path,
        estaVacia: () async => bdVacia,
        reiniciarBd: () async {},
      );

  setUp(() async {
    dirDocumentos = await Directory.systemTemp.createTemp('auto_backup_test');
    ficheroDb = File(path_lib.join(dirDocumentos.path, 'prueba.db'));
    bdVacia = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (llamada) async => dirDocumentos.path,
    );
  });

  tearDown(() => dirDocumentos.delete(recursive: true));

  test('una BD con datos se copia', () async {
    await ficheroDb.writeAsString('con hallazgos');
    await crearAutoBackup().respaldarAhora();
    expect(await copiaAuto().readAsString(), 'con hallazgos');
  });

  test('una BD vacía no pisa la copia buena', () async {
    await ficheroDb.writeAsString('con hallazgos');
    await crearAutoBackup().respaldarAhora();

    await ficheroDb.writeAsString('vacía');
    bdVacia = true;
    await crearAutoBackup().respaldarAhora();
    expect(await copiaAuto().readAsString(), 'con hallazgos');
  });

  test('sin copia previa, una BD vacía sí se copia', () async {
    await ficheroDb.writeAsString('vacía');
    bdVacia = true;
    await crearAutoBackup().respaldarAhora();
    expect(await copiaAuto().exists(), isTrue);
  });

  test('guarda una copia por día y conserva solo las últimas', () async {
    await ficheroDb.writeAsString('con hallazgos');
    final autoBackup = crearAutoBackup();
    for (var dia = 1; dia <= AutoBackup.diasConCopiaFechada + 2; dia++) {
      await autoBackup.respaldarAhora(ahora: DateTime(2026, 10, dia));
    }
    final copiasFechadas = Directory(path_lib.join(dirDocumentos.path, 'backup_auto'))
        .listSync()
        .map((entidad) => path_lib.basename(entidad.path))
        .where((nombre) => nombre.startsWith('prueba_auto_'))
        .toList()
      ..sort();
    expect(copiasFechadas, [
      for (var dia = 3; dia <= AutoBackup.diasConCopiaFechada + 2; dia++)
        'prueba_auto_2026-10-${dia.toString().padLeft(2, '0')}.db',
    ]);
  });
}
