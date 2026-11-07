// Tests de los catálogos generados a partir de `content/aceitera/*.csv`.
//
// Cubren propiedades estructurales que el compilador no garantiza por sí
// solo: integridad referencial entre CSVs (un fitosanitario apunta a una
// plaga que existe; una DOP apunta a variedades que existen), unicidad
// de IDs y búsqueda fuzzy mínima.
//
// Si añades una fila a un CSV y este test falla, regenera los .dart con
// `dart run tool/compilar_catalogos.dart` antes de correr `flutter test`.

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aceitera/datos/catalogos_generados/catalogo_calendario_olivar.dart';
import 'package:solera_aceitera/datos/catalogos_generados/catalogo_dop_aceite.dart';
import 'package:solera_aceitera/datos/catalogos_generados/catalogo_fitosanitarios_olivar.dart';
import 'package:solera_aceitera/datos/catalogos_generados/catalogo_plagas_olivo.dart';
import 'package:solera_aceitera/datos/catalogos_generados/catalogo_variedades_olivo.dart';
import 'package:solera_aceitera/datos/catalogos_generados/flag_revision.dart';

void main() {
  group('Variedades de olivo', () {
    test('Catálogo tiene al menos 30 variedades', () {
      expect(catalogoVariedadesOlivo.length, greaterThanOrEqualTo(30));
    });

    test('IDs únicos', () {
      final ids = catalogoVariedadesOlivo.map((v) => v.id).toSet();
      expect(ids.length, equals(catalogoVariedadesOlivo.length));
    });

    test('Picual existe y es de almazara', () {
      final picual = variedadOlivoPorId('picual');
      expect(picual, isNotNull);
      expect(picual!.uso, equals(UsoOlivar.almazara));
    });

    test('Búsqueda fuzzy encuentra hojiblanca por nombre y por sinónimo', () {
      expect(
        buscarVariedadesOlivo('hojiblanca').map((v) => v.id),
        contains('hojiblanca'),
      );
      expect(
        buscarVariedadesOlivo('lucentina').map((v) => v.id),
        contains('hojiblanca'),
      );
    });
  });

  group('Plagas y enfermedades del olivar', () {
    test('Catálogo tiene al menos 20 patologías', () {
      expect(catalogoPlagasOlivo.length, greaterThanOrEqualTo(20));
    });

    test('IDs únicos', () {
      final ids = catalogoPlagasOlivo.map((p) => p.id).toSet();
      expect(ids.length, equals(catalogoPlagasOlivo.length));
    });

    test('Mosca del olivo y repilo existen', () {
      expect(plagaOlivoPorId('mosca_olivo'), isNotNull);
      expect(plagaOlivoPorId('repilo'), isNotNull);
    });

    test('Xylella y verticilosis marcadas como declaración obligatoria', () {
      final declaracionObligatoria =
          patologiasDeclaracionObligatoria().map((p) => p.id).toSet();
      expect(declaracionObligatoria, contains('xylella'));
      expect(declaracionObligatoria, contains('verticilosis'));
    });
  });

  group('Fitosanitarios (sustancias activas)', () {
    test('Catálogo tiene al menos 15 sustancias', () {
      expect(catalogoFitosanitariosOlivar.length, greaterThanOrEqualTo(15));
    });

    test('IDs únicos', () {
      final ids = catalogoFitosanitariosOlivar.map((f) => f.id).toSet();
      expect(ids.length, equals(catalogoFitosanitariosOlivar.length));
    });

    test('Integridad referencial: cada plagaObjetivo existe en plagas', () {
      final idsPlagasValidas =
          catalogoPlagasOlivo.map((p) => p.id).toSet();
      for (final fito in catalogoFitosanitariosOlivar) {
        for (final idPlaga in fito.plagasObjetivo) {
          expect(
            idsPlagasValidas,
            contains(idPlaga),
            reason:
                'Fitosanitario ${fito.id} apunta a plaga inexistente: $idPlaga',
          );
        }
      }
    });

    // Registro MAPA 06/11/2026: el spinosad en olivo solo está autorizado
    // en cebo contra la mosca; contra el prays no hay uso autorizado.
    test('Filtro por plaga: spinosad solo para mosca; Bt para prays', () {
      final paraMosca =
          fitosanitariosParaPlaga('mosca_olivo').map((f) => f.id).toSet();
      expect(paraMosca, contains('spinosad'));
      final paraPrays =
          fitosanitariosParaPlaga('prays_olivo').map((f) => f.id).toSet();
      expect(paraPrays, contains('bacillus_thuringiensis'));
      expect(paraPrays, isNot(contains('spinosad')));
    });

    test('Sustancias no aprobadas o sin uso en olivar no están', () {
      final ids = catalogoFitosanitariosOlivar.map((f) => f.id).toSet();
      expect(ids, isNot(contains('mancozeb')));
      expect(ids, isNot(contains('azadiractina')));
    });
  });

  group('DOPs aceite', () {
    test('Catálogo tiene al menos 25 DOPs', () {
      expect(catalogoDopAceite.length, greaterThanOrEqualTo(25));
    });

    test('IDs únicos', () {
      final ids = catalogoDopAceite.map((d) => d.id).toSet();
      expect(ids.length, equals(catalogoDopAceite.length));
    });

    test('Sierra de Cazorla y Priego de Córdoba existen con sus picuales', () {
      final cazorla = dopAceitePorId('dop_sierra_de_cazorla');
      expect(cazorla, isNotNull);
      expect(cazorla!.variedadesPrincipales, contains('picual'));
      final priego = dopAceitePorId('dop_priego_de_cordoba');
      expect(priego, isNotNull);
      expect(priego!.acidezMax, lessThanOrEqualTo(0.5));
    });
  });

  group('Calendario olivar', () {
    test('Tiene eventos para Andalucía oriental y occidental', () {
      expect(
        calendarioDeZona(ZonaOlivar.andaluciaOriental),
        isNotEmpty,
      );
      expect(
        calendarioDeZona(ZonaOlivar.andaluciaOccidental),
        isNotEmpty,
      );
    });

    test('Recolección principal en noviembre activa en Andalucía occidental',
        () {
      final activos = eventosActivosEn(
        zona: ZonaOlivar.andaluciaOccidental,
        mes: 11,
      ).map((e) => e.evento).toSet();
      expect(activos, contains('recoleccion_principal'));
    });

    test('Recolección principal que cruza el año (nov→ene) se detecta en enero',
        () {
      final activos = eventosActivosEn(
        zona: ZonaOlivar.andaluciaOccidental,
        mes: 1,
      ).map((e) => e.evento).toSet();
      expect(activos, contains('recoleccion_principal'));
    });
  });

  group('Flag de revisión global', () {
    test(
        'Tras F1-A10 las 5 CSV están marcadas como revisadas contra fuente pública: el flag es true',
        () {
      // Si quitas filas o añades nuevas sin `revisado_por`, este test
      // se rompe a propósito — recompila con `dart run
      // tool/compilar_catalogos.dart` antes de mergear. La auditoría
      // humana definitiva sigue pendiente (asesor agrónomo olivarero
      // sustituye `fuente_publica` por su nombre + colegiación).
      expect(catalogosCompletamenteRevisados, isTrue);
    });
  });
}
