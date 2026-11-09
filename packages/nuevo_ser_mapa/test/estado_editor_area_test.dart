import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

void main() {
  const a = LatLng(42.0, -1.0);
  const b = LatLng(42.0, -0.999);
  const c = LatLng(42.001, -0.999);
  const d = LatLng(42.001, -1.0);

  test('tocar el mapa añade esquinas y el área sale al tener tres', () {
    final editor = EstadoEditorArea();
    editor
      ..tocarMapa(a)
      ..tocarMapa(b);
    expect(editor.esArea, isFalse);
    expect(editor.hectareas, 0);
    editor.tocarMapa(c);
    expect(editor.esArea, isTrue);
    expect(editor.hectareas, greaterThan(0));
    expect(editor.esquinas, [a, b, c]);
  });

  test('con una esquina elegida, tocar la mueve y la suelta', () {
    final editor = EstadoEditorArea([a, b, c]);
    editor.elegir(1);
    expect(editor.elegida, 1);
    editor.tocarMapa(d);
    expect(editor.esquinas, [a, d, c]);
    expect(editor.elegida, isNull);
    // Elegir dos veces la misma la suelta.
    editor
      ..elegir(0)
      ..elegir(0);
    expect(editor.elegida, isNull);
  });

  test('la posición del GPS va siempre al final, aunque haya elegida', () {
    final editor = EstadoEditorArea([a, b, c])..elegir(0);
    editor.anadirPosicion(d);
    expect(editor.esquinas, [a, b, c, d]);
    expect(editor.elegida, isNull);
  });

  test('«+» en un lado inserta su punto medio ya elegido', () {
    final editor = EstadoEditorArea([a, b, c]);
    editor.insertarEnLado(0);
    expect(editor.esquinas, hasLength(4));
    expect(editor.elegida, 1);
    expect(editor.esquinas[1].latitude, closeTo(42.0, 1e-9));
    expect(editor.esquinas[1].longitude, closeTo(-0.9995, 1e-9));
  });

  test('quitar: libre al trazar, mínimo tres después', () {
    final trazando = EstadoEditorArea([a, b])..elegir(0);
    trazando.quitarElegida();
    expect(trazando.esquinas, [b]);

    final area = EstadoEditorArea([a, b, c])..elegir(1);
    // Con tres, quitar dejaría de ser área: el estado lo permite al trazar,
    // pero la pantalla solo ofrece quitar si puedeQuitarElegida.
    expect(area.puedeQuitarElegida, isFalse);
    final cuatro = EstadoEditorArea([a, b, c, d])..elegir(3);
    expect(cuatro.puedeQuitarElegida, isTrue);
    cuatro.quitarElegida();
    expect(cuatro.esquinas, [a, b, c]);
  });

  test('deshacer recorre todo el historial, también importar y borrar', () {
    final editor = EstadoEditorArea([a]);
    editor
      ..tocarMapa(b)
      ..reemplazar([c, d, a])
      ..borrarTodo();
    expect(editor.esquinas, isEmpty);
    editor.deshacer();
    expect(editor.esquinas, [c, d, a]);
    editor.deshacer();
    expect(editor.esquinas, [a, b]);
    editor.deshacer();
    expect(editor.esquinas, [a]);
    expect(editor.puedeDeshacer, isFalse);
    editor.deshacer();
    expect(editor.esquinas, [a]);
  });

  test('perímetro: lo andado y, siendo área, cerrado', () {
    final editor = EstadoEditorArea([a, b]);
    final lado = distanciaMetros(a, b);
    expect(editor.perimetro, closeTo(lado, 1e-6));
    editor.tocarMapa(c);
    expect(editor.perimetro,
        closeTo(lado + distanciaMetros(b, c) + distanciaMetros(c, a), 1e-6));
  });
}
