// Guardarraíl del riesgo R1 (auditoría 2026-05-12): todo generador de PDF
// oficial (`lib/servicios/generador_*_pdf.dart`) lleva la palabra
// PROVISIONAL hasta que un asesor humano valide el formato. Quitarla exige
// apuntar el commit y el nombre del asesor en BLOQUEOS-PENDIENTES.md.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final carpeta = Directory('lib/servicios');
  // git no guarda carpetas vacías: sin generadores todavía, no hay nada que vigilar.
  final generadores =
      (carpeta.existsSync() ? carpeta.listSync() : <FileSystemEntity>[])
          .whereType<File>()
          .where((fichero) =>
              RegExp(r'generador_\w+_pdf\.dart$').hasMatch(fichero.path));

  for (final generador in generadores) {
    test('${generador.path} conserva el sello PROVISIONAL', () {
      expect(generador.readAsStringSync(), contains('PROVISIONAL'),
          reason: 'Retirar el sello exige validación humana: ver '
              'BLOQUEOS-PENDIENTES.md y la auditoría 2026-05-12 (R1).');
    });
  }

  test('el guardarraíl se carga',
      () => expect(generadores, isA<Iterable<File>>()));
}
