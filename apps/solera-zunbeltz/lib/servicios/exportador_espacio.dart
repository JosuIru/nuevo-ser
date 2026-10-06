import '../datos/base_datos.dart';
import 'documento_generado.dart';

/// Exporta el espacio (fincas + puntos de infraestructura) de la BD a dos CSV
/// con **el mismo formato que `content/espacio/`**, para cerrar el bucle de
/// captura: un coordinador marca los puntos en campo con la app, exporta aquí,
/// y esos CSV se vuelcan en `content/espacio/` y se recompilan como seed
/// (`dart run tool/compilar_espacio.dart`). Devuelve los ficheros generados.
Future<List<DocumentoGenerado>> exportarEspacioCsv() async {
  final bd = BaseDatosSoleraZunbeltz();
  final fincas = await bd.listarFincas();
  final puntos = await bd.listarPuntos();
  final nombrePorFinca = {
    for (final f in fincas)
      if (f.id != null) f.id!: f.nombre,
  };

  final fincasLineas = <String>[
    'nombre;latitud;longitud;superficie_ha;recintos_sigpac;notas',
    for (final f in fincas)
      [
        f.nombre,
        f.latitud?.toString() ?? '',
        f.longitud?.toString() ?? '',
        f.superficieHa.toString(),
        f.recintosSigpac,
        f.notas,
      ].map(_campo).join(';'),
  ];

  final puntosLineas = <String>[
    'finca;tipo;nombre;latitud;longitud;estado;notas',
    for (final p in puntos)
      [
        nombrePorFinca[p.fincaId] ?? '',
        p.tipo,
        p.nombre,
        p.latitud?.toString() ?? '',
        p.longitud?.toString() ?? '',
        p.estado,
        p.notas,
      ].map(_campo).join(';'),
  ];

  return [
    DocumentoGenerado.csv('fincas.csv', fincasLineas.join('\r\n')),
    DocumentoGenerado.csv('puntos.csv', puntosLineas.join('\r\n')),
  ];
}

/// Saneado: el seed se compila con un split por `;` simple, así que evitamos
/// `;` y saltos de línea dentro de los campos.
String _campo(String valor) => valor.replaceAll(RegExp(r'[;\r\n]'), ' ').trim();
