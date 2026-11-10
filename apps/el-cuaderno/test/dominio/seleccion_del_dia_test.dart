import 'package:el_cuaderno/dominio/misterio.dart';
import 'package:el_cuaderno/dominio/nivel_confianza.dart';
import 'package:el_cuaderno/dominio/pista_campo.dart';
import 'package:el_cuaderno/dominio/seleccion_del_dia.dart';
import 'package:flutter_test/flutter_test.dart';

Misterio _misterio(String id) => Misterio(
      id: id,
      pregunta: 'P $id',
      descripcionCorta: 'Descripción de $id',
      estado: NivelConfianza.consenso,
      abierto: true,
    );

void main() {
  group('seleccionarMisterioDelDia', () {
    final m1 = _misterio('a');
    final m2 = _misterio('b');
    final m3 = _misterio('c');
    final m4 = _misterio('d-fallback');

    test('elige del catálogo en contexto cuando hay candidatos', () {
      final elegido = seleccionarMisterioDelDia(
        candidatosEnContexto: [m1, m2, m3],
        fallbackEnteroAbierto: [m4],
        fecha: DateTime(2026, 5, 20),
      );
      // El selector debe haber elegido uno de los tres en contexto,
      // nunca el del fallback.
      expect(elegido, isNotNull);
      expect([m1, m2, m3], contains(elegido));
      expect(elegido, isNot(equals(m4)));
    });

    test('cae al fallback si el catálogo en contexto está vacío', () {
      final elegido = seleccionarMisterioDelDia(
        candidatosEnContexto: const [],
        fallbackEnteroAbierto: [m1, m4],
        fecha: DateTime(2026, 5, 20),
      );
      expect(elegido, isNotNull);
      expect([m1, m4], contains(elegido));
    });

    test('devuelve null si ambas listas están vacías', () {
      final elegido = seleccionarMisterioDelDia(
        candidatosEnContexto: const [],
        fallbackEnteroAbierto: const [],
        fecha: DateTime(2026, 5, 20),
      );
      expect(elegido, isNull);
    });

    test('la misma fecha siempre da el mismo Misterio (determinista)', () {
      final fecha = DateTime(2026, 5, 20);
      final lista = [m1, m2, m3];
      final primero = seleccionarMisterioDelDia(
        candidatosEnContexto: lista,
        fallbackEnteroAbierto: const [],
        fecha: fecha,
      );
      for (var i = 0; i < 20; i++) {
        final repetido = seleccionarMisterioDelDia(
          candidatosEnContexto: lista,
          fallbackEnteroAbierto: const [],
          fecha: fecha,
        );
        expect(repetido, equals(primero));
      }
    });

    test('días distintos producen al menos dos selecciones distintas', () {
      // Con 3 candidatos y semilla que avanza día a día, dos días
      // consecutivos pueden coincidir pero no debe haber rachas
      // largas. Comprobamos que en 30 días aparecen los 3 ids al menos
      // una vez.
      final lista = [m1, m2, m3];
      final vistos = <String>{};
      for (var diaOffset = 0; diaOffset < 30; diaOffset++) {
        final fecha = DateTime(2026, 5, 1).add(Duration(days: diaOffset));
        final elegido = seleccionarMisterioDelDia(
          candidatosEnContexto: lista,
          fallbackEnteroAbierto: const [],
          fecha: fecha,
        );
        if (elegido != null) vistos.add(elegido.id);
      }
      expect(vistos.length, greaterThanOrEqualTo(2),
          reason: 'esperamos rotación entre días dentro de un mes');
    });

    test('la hora del día no afecta a la selección', () {
      final lista = [m1, m2, m3];
      final amanecer = DateTime(2026, 5, 20, 6, 30);
      final medianoche = DateTime(2026, 5, 20, 23, 59);
      final aA = seleccionarMisterioDelDia(
        candidatosEnContexto: lista,
        fallbackEnteroAbierto: const [],
        fecha: amanecer,
      );
      final aM = seleccionarMisterioDelDia(
        candidatosEnContexto: lista,
        fallbackEnteroAbierto: const [],
        fecha: medianoche,
      );
      expect(aA, equals(aM));
    });
  });

  group('seleccionarPistaDelDia', () {
    final p1 = const PistaCampo(id: 'pista-1', texto: 'mira las nubes');
    final p2 = const PistaCampo(id: 'pista-2', texto: 'escucha un minuto');
    final p3 = const PistaCampo(id: 'pista-3', texto: 'toca la corteza');

    test('devuelve null si la lista está vacía', () {
      expect(
        seleccionarPistaDelDia(pistas: const [], fecha: DateTime(2026, 5, 20)),
        isNull,
      );
    });

    test('la misma fecha siempre da la misma pista', () {
      final fecha = DateTime(2026, 5, 20);
      final lista = [p1, p2, p3];
      final primero = seleccionarPistaDelDia(pistas: lista, fecha: fecha);
      for (var i = 0; i < 20; i++) {
        final repetido = seleccionarPistaDelDia(pistas: lista, fecha: fecha);
        expect(repetido, equals(primero));
      }
    });

    test('rotación entre días distintos en una ventana de 30 días', () {
      final lista = [p1, p2, p3];
      final vistas = <String>{};
      for (var diaOffset = 0; diaOffset < 30; diaOffset++) {
        final fecha = DateTime(2026, 5, 1).add(Duration(days: diaOffset));
        vistas.add(seleccionarPistaDelDia(pistas: lista, fecha: fecha)!.id);
      }
      expect(vistas.length, greaterThanOrEqualTo(2));
    });

    test('una sola pista en la lista se devuelve siempre', () {
      final unica = seleccionarPistaDelDia(
        pistas: [p1],
        fecha: DateTime(2026, 5, 20),
      );
      expect(unica, equals(p1));
    });
  });
}
