import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/dominio/capa_historica.dart';
import 'package:las_versiones/sonido/catalogo_sonidos_archivo.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

void main() {
  test('hay un fragmento de música por capa histórica, sin bucle', () {
    for (final capa in CapaHistorica.values) {
      final sonido = CatalogoSonidosArchivo.obtener(
          CatalogoSonidosArchivo.fragmentoDeCapa(capa.codigo));
      expect(sonido, isNotNull, reason: capa.codigo);
      expect(sonido!.capa, CapaAudio.musica);
      expect(sonido.enBucle, isFalse, reason: 'doc 12: nada de música en bucle');
    }
  });

  test('sólo el ambiente va en bucle', () {
    for (final sonido in CatalogoSonidosArchivo.todos) {
      expect(sonido.enBucle, sonido.capa == CapaAudio.ambient,
          reason: sonido.identificador);
    }
  });
}
