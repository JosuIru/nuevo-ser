import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/encargo_del_dia.dart';

/// Tests del módulo puro `EncargoDelDia` (doc 16, eje D). Verifican el
/// contrato determinista (mismo día → mismo encargo), que solo se
/// proponen distritos desbloqueados y las reglas de conteo de capturas.
void main() {
  final unaFecha = DateTime(2026, 7, 8, 17, 45);
  final mismaFechaOtraHora = DateTime(2026, 7, 8, 9, 10);

  const soloTejados = ['tejados'];
  const tresDistritos = ['tejados', 'canales', 'mercado'];

  group('GeneradorEncargoDelDia.deHoy — determinismo', () {
    test('mismo día → mismo encargo, ignorando la hora', () {
      final a = GeneradorEncargoDelDia.deHoy(
        ahora: unaFecha,
        idsDistritosDesbloqueados: tresDistritos,
      );
      final b = GeneradorEncargoDelDia.deHoy(
        ahora: mismaFechaOtraHora,
        idsDistritosDesbloqueados: tresDistritos,
      );
      expect(a.idDistrito, b.idDistrito);
      expect(a.objetivo, b.objetivo);
      expect(a.claveFecha, b.claveFecha);
    });

    test('la clave de fecha tiene formato AAAA-MM-DD con relleno', () {
      expect(
        GeneradorEncargoDelDia.claveFechaDe(DateTime(2026, 7, 8)),
        '2026-07-08',
      );
      expect(
        GeneradorEncargoDelDia.claveFechaDe(DateTime(2026, 11, 23)),
        '2026-11-23',
      );
    });

    test('a lo largo de un mes salen encargos de distrito Y libres', () {
      // Con tres distritos desbloqueados, 30 días deben producir las
      // dos formas del encargo (si solo saliera una, la semilla estaría
      // rota o la elección sesgada a un único bucket).
      var vecesLibre = 0;
      var vecesDistrito = 0;
      for (var dia = 1; dia <= 30; dia++) {
        final encargo = GeneradorEncargoDelDia.deHoy(
          ahora: DateTime(2026, 7, dia),
          idsDistritosDesbloqueados: tresDistritos,
        );
        if (encargo.esLibre) {
          vecesLibre++;
        } else {
          vecesDistrito++;
        }
      }
      expect(vecesLibre, greaterThan(0));
      expect(vecesDistrito, greaterThan(0));
    });
  });

  group('GeneradorEncargoDelDia.deHoy — distritos desbloqueados', () {
    test('nunca propone un distrito fuera de la lista desbloqueada', () {
      for (var dia = 1; dia <= 60; dia++) {
        final encargo = GeneradorEncargoDelDia.deHoy(
          ahora: DateTime(2026, 8, 1).add(Duration(days: dia)),
          idsDistritosDesbloqueados: soloTejados,
        );
        if (!encargo.esLibre) {
          expect(encargo.idDistrito, 'tejados');
        }
      }
    });

    test('lista vacía → encargo libre con su objetivo', () {
      final encargo = GeneradorEncargoDelDia.deHoy(
        ahora: unaFecha,
        idsDistritosDesbloqueados: const [],
      );
      expect(encargo.esLibre, isTrue);
      expect(encargo.objetivo, GeneradorEncargoDelDia.objetivoLibre);
    });

    test('el objetivo depende de la forma del encargo', () {
      for (var dia = 1; dia <= 30; dia++) {
        final encargo = GeneradorEncargoDelDia.deHoy(
          ahora: DateTime(2026, 9, dia),
          idsDistritosDesbloqueados: tresDistritos,
        );
        expect(
          encargo.objetivo,
          encargo.esLibre
              ? GeneradorEncargoDelDia.objetivoLibre
              : GeneradorEncargoDelDia.objetivoEnDistrito,
        );
      }
    });
  });

  group('EncargoDelDia.cuentaCaptura', () {
    const encargoCanales = EncargoDelDia(
      claveFecha: '2026-07-08',
      idDistrito: 'canales',
      objetivo: 3,
    );
    const encargoLibre = EncargoDelDia(
      claveFecha: '2026-07-08',
      idDistrito: null,
      objetivo: 4,
    );

    test('encargo de distrito: solo cuentan capturas en ese distrito', () {
      expect(
        encargoCanales.cuentaCaptura(
          idDistritoCaptura: 'canales',
          esEntrenamiento: false,
        ),
        isTrue,
      );
      expect(
        encargoCanales.cuentaCaptura(
          idDistritoCaptura: 'tejados',
          esEntrenamiento: false,
        ),
        isFalse,
      );
    });

    test('encargo de distrito: el entrenamiento no cuenta', () {
      // El modo entrenamiento reutiliza la atmósfera de tejados pero
      // no es "pisar el distrito": un encargo de distrito pide caza
      // ambiental de verdad.
      expect(
        encargoCanales.cuentaCaptura(
          idDistritoCaptura: 'canales',
          esEntrenamiento: true,
        ),
        isFalse,
      );
    });

    test('encargo libre: cuenta en cualquier parte, entrenamiento incluido',
        () {
      expect(
        encargoLibre.cuentaCaptura(
          idDistritoCaptura: 'puerto',
          esEntrenamiento: false,
        ),
        isTrue,
      );
      expect(
        encargoLibre.cuentaCaptura(
          idDistritoCaptura: 'tejados',
          esEntrenamiento: true,
        ),
        isTrue,
      );
    });
  });
}
