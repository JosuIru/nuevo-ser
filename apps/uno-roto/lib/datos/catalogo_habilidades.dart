import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Carga y expone el catálogo de habilidades (106: de 4.º de Primaria a 2.º de ESO) desde
/// `assets/data/skills.json`. Singleton perezoso; las habilidades son
/// inmutables después de cargarse.
class CatalogoHabilidades {
  CatalogoHabilidades._({
    required this.version,
    required this.dominios,
    required this.habilidades,
    required this.reglasDecaimiento,
    required this.rangos,
  });

  /// Constructor expuesto para tests — permite construir un catálogo
  /// sintético sin tocar el asset bundle. Producción siempre debe usar
  /// [cargar] (que es perezoso, idempotente y carga desde JSON).
  @visibleForTesting
  factory CatalogoHabilidades.paraTests({
    String version = 'test',
    Map<String, String> dominios = const {},
    Map<String, Habilidad> habilidades = const {},
    required ReglasDecaimiento reglasDecaimiento,
    List<String> rangos = const [],
  }) =>
      CatalogoHabilidades._(
        version: version,
        dominios: dominios,
        habilidades: habilidades,
        reglasDecaimiento: reglasDecaimiento,
        rangos: rangos,
      );

  static CatalogoHabilidades? _instancia;
  static Future<CatalogoHabilidades>? _cargaEnCurso;

  final String version;
  final Map<String, String> dominios;
  final Map<String, Habilidad> habilidades;
  final ReglasDecaimiento reglasDecaimiento;
  final List<String> rangos;

  static Future<CatalogoHabilidades> cargar() async {
    if (_instancia != null) return _instancia!;
    return _cargaEnCurso ??= _cargarDesdeAsset();
  }

  static Future<CatalogoHabilidades> _cargarDesdeAsset() async {
    final texto = await rootBundle.loadString('assets/data/skills.json');
    final json = jsonDecode(texto) as Map<String, dynamic>;

    final habilidadesPorId = <String, Habilidad>{};
    for (final entrada in (json['skills'] as List)) {
      final h = Habilidad.desdeJson(entrada as Map<String, dynamic>);
      habilidadesPorId[h.identificador] = h;
    }

    final decaimiento = json['decay_rules'] as Map<String, dynamic>;
    final reglas = ReglasDecaimiento(
      diasMaestriaACompetente:
          (decaimiento['mastery_to_competent_days'] as num).toInt(),
      diasCompetenteAEnDesarrollo:
          (decaimiento['competent_to_developing_days'] as num).toInt(),
      nivelSuelo: (decaimiento['floor_level'] as num).toInt(),
    );

    _instancia = CatalogoHabilidades._(
      version: json['version'] as String,
      dominios:
          (json['domains'] as Map<String, dynamic>).cast<String, String>(),
      habilidades: habilidadesPorId,
      reglasDecaimiento: reglas,
      rangos: (json['ranks'] as List).cast<String>(),
    );
    _cargaEnCurso = null;
    return _instancia!;
  }

  Habilidad? porId(String id) => habilidades[id];

  List<Habilidad> delDominio(String dominio, {String? rangoActual}) =>
      habilidades.values
          .where((h) => h.dominio == dominio)
          .where((h) => _rangoAlcanza(rangoActual, h.rangoExigido))
          .toList();

  /// Todas las habilidades que el distrito puede presentar.
  /// Si se proporciona [rangoActual], solo devuelve habilidades cuyo
  /// [rangoExigido] sea alcanzable desde ese rango.
  List<Habilidad> delDistrito(String idDistrito, {String? rangoActual}) =>
      habilidades.values
          .where((h) =>
              h.distritos.contains(idDistrito) ||
              h.distritos.contains('todos'))
          .where((h) => _rangoAlcanza(rangoActual, h.rangoExigido))
          .toList();

  /// True si [rangoActual] es suficiente para acceder a una habilidad
  /// con [rangoExigido]. Los rangos están ordenados en la lista
  /// [rangos] del JSON (índice más alto = más avanzado).
  ///
  /// Si alguno de los dos rangos no aparece en [rangos] (catálogo
  /// corrupto o rango heredado de una versión antigua), devolvemos
  /// `false` en lugar de `true`: preferimos esconder la habilidad
  /// hasta que la inconsistencia se resuelva, antes que abrir acceso
  /// silenciosamente a habilidades que el niño no debería ver aún.
  bool _rangoAlcanza(String? rangoActual, String rangoExigido) {
    if (rangoActual == null) return true;
    final actualIdx = rangos.indexOf(rangoActual);
    final exigidoIdx = rangos.indexOf(rangoExigido);
    if (actualIdx < 0 || exigidoIdx < 0) return false;
    return actualIdx >= exigidoIdx;
  }
}

class ReglasDecaimiento {
  final int diasMaestriaACompetente;
  final int diasCompetenteAEnDesarrollo;
  final int nivelSuelo;

  const ReglasDecaimiento({
    required this.diasMaestriaACompetente,
    required this.diasCompetenteAEnDesarrollo,
    required this.nivelSuelo,
  });
}
