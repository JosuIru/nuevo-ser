import 'dart:math';

final _random = Random.secure();

/// Identificador estable de sincronización: 16 bytes aleatorios en hex
/// (128 bits, colisión despreciable para el volumen de un espacio test).
/// Se genera en el dispositivo al crear la fila y viaja con ella al
/// sincronizar, a diferencia del `id` autoincrement de sqflite, que es
/// local a cada dispositivo y no sirve como clave entre dispositivos.
String generarUid() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
