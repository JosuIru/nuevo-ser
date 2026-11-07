import 'package:pendientes/pendientes.dart';
import 'package:test/test.dart';

void main() {
  group('leerBloqueos', () {
    test('un ## sin hijos es un bloqueo', () {
      const texto = '''
# Larrea — Bloqueos

Intro que no cuenta.

## F1-7 — Formato del libro oficial PAC

Hay que validarlo con el técnico OCA.
''';
      final bloqueos = leerBloqueos(texto, aplicacion: 'viticultura');
      expect(bloqueos, hasLength(1));
      expect(bloqueos.single.titulo, 'F1-7 — Formato del libro oficial PAC');
      expect(bloqueos.single.grupo, isNull);
      expect(bloqueos.single.aplicacion, 'viticultura');
      expect(bloqueos.single.cuerpo, contains('técnico OCA'));
      expect(bloqueos.single.resuelto, isFalse);
      expect(bloqueos.single.linea, 5);
    });

    test('un ## con ### hijos es un grupo y los ### son los bloqueos', () {
      const texto = '''
## Críticos para corpus

Texto del grupo.

### B4. Comité de asesoría lingüística

Cuatro cooficiales.

### B5. Corpus seminal

Piezas.
''';
      final bloqueos = leerBloqueos(texto, aplicacion: 'el-descifrador');
      expect(bloqueos.map((bloqueo) => bloqueo.titulo),
          ['B4. Comité de asesoría lingüística', 'B5. Corpus seminal']);
      expect(bloqueos.first.grupo, 'Críticos para corpus');
      expect(bloqueos.first.cuerpo, contains('Cuatro cooficiales'));
      expect(bloqueos.first.cuerpo, isNot(contains('Piezas')));
    });

    test('cuenta casillas pendientes y hechas', () {
      const texto = '''
## Catálogos

- [ ] Validar razas
- [x] Validar DO
- [X] Validar defectos
- [ ] Revisar BOE
''';
      final bloqueo = leerBloqueos(texto, aplicacion: 'quesera').single;
      expect(bloqueo.casillasPendientes, 2);
      expect(bloqueo.casillasHechas, 2);
    });

    test('marca resuelto por el título o por el grupo', () {
      const texto = '''
## Resueltos — 2026-05-13

### B0. Nombre del juego

Cerrado.

## F2 — Branding ✅

Hecho.

## F3 — Libro económico (cerrado provisionalmente)

Falta asesor fiscal.

## Cierres provisionales por Claude

Pendiente de validar.
''';
      final bloqueos = leerBloqueos(texto, aplicacion: 'x');
      final resueltos = {
        for (final bloqueo in bloqueos) bloqueo.titulo: bloqueo.resuelto
      };
      expect(resueltos['B0. Nombre del juego'], isTrue);
      expect(resueltos['F2 — Branding ✅'], isTrue);
      // «cerrado provisionalmente» sigue esperando validación humana.
      expect(resueltos['F3 — Libro económico (cerrado provisionalmente)'],
          isFalse);
      expect(resueltos['Cierres provisionales por Claude'], isFalse);
    });

    test('un bloqueo con todas las casillas hechas cuenta como resuelto', () {
      const texto = '''
## Euskera

- [x] Revisar textos
''';
      expect(leerBloqueos(texto, aplicacion: 'x').single.resuelto, isTrue);
    });

    test('ignora encabezados dentro de bloques de código', () {
      const texto = '''
## Real

```
## falso
```
''';
      final bloqueos = leerBloqueos(texto, aplicacion: 'x');
      expect(bloqueos.single.titulo, 'Real');
      expect(bloqueos.single.cuerpo, contains('## falso'));
    });
  });
}
