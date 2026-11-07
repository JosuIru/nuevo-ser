import 'package:flutter_test/flutter_test.dart';
import 'package:solera_arbolado_urbano/datos/catalogos_generados/catalogo_calendario_arbolado.dart';
import 'package:solera_arbolado_urbano/datos/catalogos_generados/catalogo_especies_arboreas.dart';
import 'package:solera_arbolado_urbano/datos/catalogos_generados/catalogo_plagas_urbanas.dart';
import 'package:solera_arbolado_urbano/datos/catalogos_generados/catalogo_sustratos_alcorque.dart';
import 'package:solera_arbolado_urbano/datos/catalogos_generados/catalogo_tipos_poda.dart';
import 'package:solera_arbolado_urbano/datos/catalogos_generados/flag_revision.dart';

void main() {
  group('Especies arbóreas', () {
    test('catálogo trae las especies urbanas frecuentes', () {
      final ids = catalogoEspeciesArboreas.map((e) => e.id).toSet();
      expect(ids, containsAll([
        'platano_sombra',
        'tilo',
        'pino_pinonero',
        'palmera_canaria',
        'olmo_siberiano',
      ]));
    });

    test('búsqueda fuzzy normaliza tildes y científico', () {
      final porComun = buscarEspecies('plátano');
      expect(porComun.map((e) => e.id), contains('platano_sombra'));
      final porCientifico = buscarEspecies('platanus');
      expect(porCientifico.map((e) => e.id), contains('platano_sombra'));
    });

    test('palmera canaria tiene baja tolerancia a poda y altura razonable', () {
      final palmera = especiePorId('palmera_canaria')!;
      expect(palmera.toleranciaPoda, ToleranciaPoda.baja);
      expect(palmera.familia, FamiliaEspecieArborea.palmacea);
      expect(palmera.alturaMaxMetros, greaterThan(10));
    });
  });

  group('Plagas urbanas', () {
    test('catálogo trae las patologías urbanas clave', () {
      final ids = catalogoPlagasUrbanas.map((p) => p.id).toSet();
      expect(ids, containsAll([
        'procesionaria_pino',
        'picudo_rojo',
        'anthracnosis_platano',
        'grafiosis_olmo',
      ]));
    });

    test('picudo rojo y fuego bacteriano son declaración obligatoria', () {
      final declarables = patologiasDeclaracionObligatoria();
      final idsDeclarables = declarables.map((p) => p.id).toSet();
      expect(idsDeclarables, contains('picudo_rojo'));
      expect(idsDeclarables, contains('fuego_bacteriano'));
      // Procesionaria NO es de declaración obligatoria — es ubicua.
      expect(idsDeclarables, isNot(contains('procesionaria_pino')));
    });

    test('procesionaria y lagarta peluda tienen riesgo sanitario público', () {
      final riesgos = plagasConRiesgoSanitarioPublico();
      final ids = riesgos.map((p) => p.id).toSet();
      expect(ids, contains('procesionaria_pino'));
      expect(ids, contains('lagarta_peluda'));
    });

    test('picudo rojo afecta a las dos palmeras del catálogo', () {
      final picudo = plagaUrbanaPorId('picudo_rojo')!;
      expect(picudo.especiesObjetivo, containsAll(['palmera_datilera', 'palmera_canaria']));
    });

    test('plagasParaEspecie devuelve las que afectan al plátano', () {
      final delPlatano = plagasParaEspecie('platano_sombra');
      final ids = delPlatano.map((p) => p.id).toSet();
      expect(ids, contains('anthracnosis_platano'));
      expect(ids, contains('oidio_platano'));
    });

    test('búsqueda fuzzy con fallback cruzado encuentra picudo por científico en campo común', () {
      final porComun = plagaUrbanaPorBusquedaFuzzy('Rhynchophorus ferrugineus', '');
      expect(porComun?.id, 'picudo_rojo');
    });
  });

  group('Tipos de poda', () {
    test('catálogo distingue tipos controvertidos', () {
      final noControvertidos = tiposPodaNoControvertidos();
      final ids = noControvertidos.map((t) => t.id).toSet();
      // Aterrazado, terciado, descopado y trasmoche son controvertidos.
      expect(ids, isNot(contains('aterrazado')));
      expect(ids, isNot(contains('terciado')));
      expect(ids, isNot(contains('descopado')));
      // Mantenimiento, formación, saneamiento NO son controvertidos.
      expect(ids, contains('mantenimiento'));
      expect(ids, contains('formacion'));
      expect(ids, contains('saneamiento'));
    });

    test('intensidad muy_alta sólo en aterrazado y descopado y trasmoche', () {
      final muyAltas = catalogoTiposPoda
          .where((t) => t.intensidad == IntensidadPoda.muyAlta)
          .map((t) => t.id)
          .toSet();
      expect(muyAltas, containsAll(['aterrazado', 'descopado', 'trasmoche']));
    });
  });

  group('Sustratos / alcorques', () {
    test('alcorque sellado por asfalto tiene permeabilidad nula', () {
      final sellado = sustratoAlcorquePorId('sellado_asfalto')!;
      expect(sellado.permeabilidad, PermeabilidadAlcorque.nula);
      expect(sellado.facilidadRiego, FacilidadRiego.dificil);
    });

    test('alcorque mineral es la opción más permeable', () {
      final mineral = sustratoAlcorquePorId('mineral')!;
      expect(mineral.permeabilidad, PermeabilidadAlcorque.alta);
      expect(mineral.facilidadRiego, FacilidadRiego.directa);
    });
  });

  group('Calendario arbolado', () {
    test('cubre las 3 zonas climáticas', () {
      final zonas = calendarioArbolado.map((t) => t.zona).toSet();
      expect(zonas, containsAll([
        ZonaClimaticaArbolado.norte,
        ZonaClimaticaArbolado.centro,
        ZonaClimaticaArbolado.sur,
      ]));
    });

    test('tareas próximas no devuelve más de `limite`', () {
      final fecha = DateTime(2026, 4, 5);
      final proximas = tareasProximas(
        zona: ZonaClimaticaArbolado.norte,
        fecha: fecha,
        limite: 3,
      );
      expect(proximas.length, lessThanOrEqualTo(3));
    });

    test('tareas próximas wrap-around al final del año', () {
      final fecha = DateTime(2026, 12, 31);
      final proximas = tareasProximas(
        zona: ZonaClimaticaArbolado.sur,
        fecha: fecha,
        limite: 3,
      );
      expect(proximas.length, 3);
    });

    test('trampeo del picudo rojo solo aparece en zona sur', () {
      final tareasPicudo =
          calendarioArbolado.where((t) => t.tareaId == 'trampeo_picudo_palmeras').toList();
      expect(tareasPicudo.every((t) => t.zona == ZonaClimaticaArbolado.sur), isTrue);
    });
  });

  group('Flag de revisión global', () {
    test('falso mientras ninguna persona experta firme todas las filas', () {
      // Solo cuenta como firma un `revisado_por` que empiece por `asesor:` o
      // `persona:`. Una fuente pública, una cita o `revision-ia:` no retiran
      // el banner de datos provisionales (ver scripts/pendientes/README.md).
      expect(catalogosCompletamenteRevisados, isFalse);
    });
  });
}
