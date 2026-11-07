import 'package:flutter_test/flutter_test.dart';
import 'package:solera_apicola/datos/catalogos_generados/catalogo_calendario_apicola.dart';
import 'package:solera_apicola/datos/catalogos_generados/catalogo_plagas_apicolas.dart';
import 'package:solera_apicola/datos/catalogos_generados/catalogo_razas_abeja.dart';
import 'package:solera_apicola/datos/catalogos_generados/catalogo_sustancias_varroa.dart';
import 'package:solera_apicola/datos/catalogos_generados/catalogo_tipos_colmena.dart';
import 'package:solera_apicola/datos/catalogos_generados/flag_revision.dart';

void main() {
  group('Razas de abeja', () {
    test('catálogo no vacío y trae las subespecies clave', () {
      expect(catalogoRazasAbeja.isNotEmpty, isTrue);
      final ids = catalogoRazasAbeja.map((r) => r.id).toSet();
      expect(ids, contains('iberica'));
      expect(ids, contains('carnica'));
      expect(ids, contains('buckfast'));
    });

    test('búsqueda por id exacto y por sinonimia', () {
      expect(razaAbejaPorId('iberica')?.nombreCanonico, 'Abeja ibérica');
      expect(razaAbejaPorId('inexistente'), isNull);
      final porSinonimia = buscarRazasAbeja('amarilla');
      expect(porSinonimia.map((r) => r.id), contains('ligustica'));
    });

    test('búsqueda fuzzy normaliza tildes', () {
      final resultados = buscarRazasAbeja('iberica');
      expect(resultados.map((r) => r.id), contains('iberica'));
      final resultadosTildes = buscarRazasAbeja('Ibérica');
      expect(resultadosTildes.map((r) => r.id), contains('iberica'));
    });
  });

  group('Tipos de colmena', () {
    test('catálogo trae los modelos canónicos', () {
      final ids = catalogoTiposColmena.map((t) => t.id).toSet();
      expect(ids, containsAll(['layens', 'dadant', 'langstroth', 'warre']));
    });

    test('Layens es horizontal sin alzas, Langstroth vertical apilable', () {
      final layens = tipoColmenaPorId('layens')!;
      expect(layens.formato, FormatoColmena.fijaHorizontal);
      expect(layens.apilableAlzas, isFalse);
      final langstroth = tipoColmenaPorId('langstroth')!;
      expect(langstroth.formato, FormatoColmena.verticalAlza);
      expect(langstroth.apilableAlzas, isTrue);
    });
  });

  group('Sustancias para varroa', () {
    test('catálogo no vacío y diferencia ecológicas vs sintéticas', () {
      expect(catalogoSustanciasVarroa.isNotEmpty, isTrue);
      final ecologicas = sustanciasEcologico();
      expect(ecologicas.map((s) => s.id), contains('acido_oxalico'));
      final amitraz = sustanciaVarroaPorId('amitraz');
      expect(amitraz?.autorizadaEcologico, isFalse);
      expect(amitraz?.familia, FamiliaSustanciaVarroa.sintetica);
    });

    test('filtro por ventana de aplicación', () {
      final paraInvernada = sustanciasParaVentana(VentanaAplicacionVarroa.sinPostura);
      expect(paraInvernada.map((s) => s.id), contains('acido_oxalico'));
      final paraOtono = sustanciasParaVentana(VentanaAplicacionVarroa.otono);
      expect(paraOtono.map((s) => s.id), contains('amitraz'));
    });

    test('plazo de seguridad: orgánicas a 0 días, sintéticas con plazo', () {
      expect(sustanciaVarroaPorId('acido_oxalico')!.plazoSeguridadDias, 0);
      expect(sustanciaVarroaPorId('amitraz')!.plazoSeguridadDias, greaterThan(0));
    });
  });

  group('Plagas apícolas', () {
    test('catálogo trae las patologías clave', () {
      final ids = catalogoPlagasApicolas.map((p) => p.id).toSet();
      expect(ids, containsAll([
        'varroosis',
        'nosemosis_apis',
        'nosemosis_ceranae',
        'loque_americana',
        'vespa_velutina',
      ]));
    });

    test('loque americana, escarabajo y vespa son declaración obligatoria', () {
      final declarables = patologiasDeclaracionObligatoria();
      final idsDeclarables = declarables.map((p) => p.id).toSet();
      expect(idsDeclarables, contains('loque_americana'));
      expect(idsDeclarables, contains('escarabajo_colmenas'));
      expect(idsDeclarables, contains('vespa_velutina'));
      // Varroosis NO es de declaración obligatoria — es ubicua.
      expect(idsDeclarables, isNot(contains('varroosis')));
    });

    test('búsqueda fuzzy por nombre científico vs nombre común', () {
      final porCientifico = plagaApicolaPorBusquedaFuzzy('', 'Varroa destructor');
      expect(porCientifico?.id, 'varroosis');
      final porComun = plagaApicolaPorBusquedaFuzzy('vespa velutina', '');
      expect(porComun?.id, 'vespa_velutina');
    });

    test('mapeo a tipo de incidencia BD respeta los ids especiales', () {
      expect(
        tipoIncidenciaParaBd(plagaApicolaPorId('varroosis')!),
        'sanitario',
      );
      expect(
        tipoIncidenciaParaBd(plagaApicolaPorId('polilla_cera')!),
        'polilla_cera',
      );
      expect(
        tipoIncidenciaParaBd(plagaApicolaPorId('vespa_velutina')!),
        'vespa_velutina',
      );
      expect(
        tipoIncidenciaParaBd(plagaApicolaPorId('robo')!),
        'robo',
      );
      // El escarabajo no tiene id especial — cae en 'otro'.
      expect(
        tipoIncidenciaParaBd(plagaApicolaPorId('escarabajo_colmenas')!),
        'otro',
      );
      // Los abióticos como hambre invernal → 'otro'.
      expect(
        tipoIncidenciaParaBd(plagaApicolaPorId('hambre_invernal')!),
        'otro',
      );
    });
  });

  group('Calendario apícola', () {
    test('cubre las 3 zonas climáticas', () {
      final zonas = calendarioApicola.map((t) => t.zona).toSet();
      expect(zonas, containsAll([
        ZonaClimaticaApicola.norte,
        ZonaClimaticaApicola.centro,
        ZonaClimaticaApicola.sur,
      ]));
    });

    test('tareas de zona devuelven ordenado por mes/década', () {
      final tareasNorte = tareasDeZona(ZonaClimaticaApicola.norte);
      expect(tareasNorte, isNotEmpty);
      // Verificar orden: la primera tarea es la más temprana del año.
      for (var i = 1; i < tareasNorte.length; i++) {
        final prev = tareasNorte[i - 1].mes * 10 + tareasNorte[i - 1].decada;
        final cur = tareasNorte[i].mes * 10 + tareasNorte[i].decada;
        expect(cur >= prev, isTrue);
      }
    });

    test('tareas próximas no devuelve más de `limite`', () {
      final fecha = DateTime(2026, 4, 5);
      final proximas = tareasProximas(
        zona: ZonaClimaticaApicola.norte,
        fecha: fecha,
        limite: 3,
      );
      expect(proximas.length, lessThanOrEqualTo(3));
    });

    test('tareas próximas wrap-around al final del año', () {
      // Fin de año: las tareas futuras directas son pocas, el resto debe
      // venir del año siguiente para alcanzar el límite.
      final fecha = DateTime(2026, 12, 31);
      final proximas = tareasProximas(
        zona: ZonaClimaticaApicola.sur,
        fecha: fecha,
        limite: 3,
      );
      expect(proximas.length, 3);
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
