import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../dominio/pista_campo.dart';

/// Ruta del asset que contiene el catálogo seminal v0.1 de pistas de
/// campo (las 25 invitaciones abiertas redactadas el 2026-05-20). Su
/// función es garantizar que el home siempre tenga algo que proponer
/// aunque el catálogo de Misterios filtrado por estación + región
/// quede vacío.
const String rutaAssetPistasCampoSeminal =
    'assets/data/pistas_campo_v0_1.json';

/// Carga el catálogo de pistas del asset bundleado. Misma convención
/// que [cargarCatalogoSeminal]: si el JSON está malformado, debe
/// reventar al iniciar — son datos del propio repositorio.
/// Sin caché del bundle, por lo mismo que [cargarCatalogoSeminal]: la
/// caché guarda el `Future` en la zona donde se creó y colgaba los
/// tests que cargan el home más de una vez.
Future<List<PistaCampo>> cargarCatalogoPistasCampo() async {
  final contenidoBruto =
      await rootBundle.loadString(rutaAssetPistasCampoSeminal, cache: false);
  return parsePistasCampoDesdeJson(contenidoBruto);
}

/// Variante pura para tests y para escenarios donde el JSON ya está
/// en memoria. No depende de Flutter.
List<PistaCampo> parsePistasCampoDesdeJson(String contenidoJson) {
  final dynamic decodificado = jsonDecode(contenidoJson);
  if (decodificado is! Map<String, dynamic>) {
    throw const FormatException(
      'El catálogo de pistas de campo debe ser un objeto JSON con clave "pistas"',
    );
  }
  final dynamic listaCruda = decodificado['pistas'];
  if (listaCruda is! List) {
    throw const FormatException(
      'El catálogo de pistas de campo no contiene una lista "pistas"',
    );
  }
  return listaCruda
      .map((entrada) {
        if (entrada is! Map<String, dynamic>) {
          throw const FormatException(
            'Cada entrada del catálogo de pistas debe ser un objeto JSON',
          );
        }
        return PistaCampo.fromJson(entrada);
      })
      .toList(growable: false);
}
