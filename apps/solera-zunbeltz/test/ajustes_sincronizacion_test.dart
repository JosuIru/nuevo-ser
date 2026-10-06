import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/estado/ajustes_sincronizacion.dart';
import 'package:solera_zunbeltz/estado/idioma_app.dart';

void main() {
  test('la app web servida por el plugin deduce la dirección del WordPress', () {
    expect(urlServidorDesdeAppWeb(Uri.parse('http://zunbeltz-app.local/app/')),
        'http://zunbeltz-app.local');
    expect(urlServidorDesdeAppWeb(Uri.parse('https://app.zunbeltz.com/app/#/')),
        'https://app.zunbeltz.com');
    expect(urlServidorDesdeAppWeb(Uri.parse('https://zunbeltz.com/espacio/app/index.html')),
        'https://zunbeltz.com/espacio');
    expect(urlServidorDesdeAppWeb(Uri.parse('http://localhost:8080/')), isNull,
        reason: 'fuera de /app/ (p. ej. la demo) no se adivina nada');
  });

  test('la app web abre en el idioma que pide la portada (?lang=eu)', () {
    expect(idiomaDesdeDireccion(Uri.parse('http://zunbeltz-app.local/app/?lang=eu')), 'eu');
    expect(idiomaDesdeDireccion(Uri.parse('http://zunbeltz-app.local/app/?lang=fr')), isNull);
    expect(idiomaDesdeDireccion(Uri.parse('http://zunbeltz-app.local/app/')), isNull);
  });
}
