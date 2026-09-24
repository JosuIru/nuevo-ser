import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../dominio/misterio.dart';

/// Ruta del asset que contiene el catálogo seminal v0.1 (los 19
/// Misterios del documento `docs/el-cuaderno/catalogo-seminal-misterios.md`).
/// Mover el catálogo a un asset auditable por el comité científico
/// (decisiones-provisionales.md ítem #6) sin obligar a tocar código
/// Dart fue el motivo del extracto.
const String rutaAssetMisteriosSeminal =
    'assets/data/misterios_seminal_v0_1.json';

/// Carga el catálogo seminal del asset bundleado y lo parsea a la
/// lista canónica de [Misterio] (en el orden del documento). Lanza
/// [FormatException] si el JSON está malformado o si una entrada no
/// cumple las invariantes de dominio (ver [Misterio.fromJson] y el
/// constructor de [Misterio]).
///
/// El catálogo viene del propio repositorio: si está roto, debe
/// reventar al iniciar — paralelo a `cargarBancoEdicionesFaro` de
/// uno-roto.
///
/// Sin caché del bundle (`cache: false`): el catálogo se lee una vez al
/// arrancar, y la caché de `rootBundle` guarda el `Future` en la zona
/// donde se creó. En los tests eso colgaba el segundo `testWidgets` que
/// sembraba datos: esperaba un `Future` de la zona de tiempo simulado
/// del test anterior, que ya nadie avanza.
Future<List<Misterio>> cargarCatalogoSeminal() async {
  final contenidoBruto =
      await rootBundle.loadString(rutaAssetMisteriosSeminal, cache: false);
  return parseCatalogoSeminalDesdeJson(contenidoBruto);
}

/// Variante pura para tests y para escenarios donde el JSON ya está
/// en memoria (descarga futura, fixture). No depende de Flutter.
List<Misterio> parseCatalogoSeminalDesdeJson(String contenidoJson) {
  final dynamic decodificado = jsonDecode(contenidoJson);
  if (decodificado is! Map<String, dynamic>) {
    throw const FormatException(
      'El catálogo seminal debe ser un objeto JSON con clave "misterios"',
    );
  }
  final dynamic listaCruda = decodificado['misterios'];
  if (listaCruda is! List) {
    throw const FormatException(
      'El catálogo seminal no contiene una lista "misterios"',
    );
  }
  return listaCruda
      .map((entrada) {
        if (entrada is! Map<String, dynamic>) {
          throw const FormatException(
            'Cada entrada del catálogo seminal debe ser un objeto JSON',
          );
        }
        return Misterio.fromJson(entrada);
      })
      .toList(growable: false);
}
