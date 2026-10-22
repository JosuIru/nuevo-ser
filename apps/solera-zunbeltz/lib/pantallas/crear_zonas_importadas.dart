import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' as core
    show buscarLugarEnMapa, TextosBuscadorLugares;

import '../l10n/app_localizations.dart';
import '../servicios/servicio_catastro_navarra.dart';
import '../utiles/geodesia.dart';
import '../utiles/importar_contornos.dart';

/// Un contorno propuesto para crear una zona: viene del catastro o de un
/// fichero, con su nombre de origen y una nota de dónde sale.
class ContornoPropuesto {
  const ContornoPropuesto(
      {required this.nombre, required this.notas, required this.vertices});

  final String nombre;
  final String notas;
  final List<LatLng> vertices;
}

String _hectareas(List<LatLng> vertices) =>
    superficieHectareas(vertices).toStringAsFixed(2).replaceAll('.', ',');

void _avisar(BuildContext context, String texto) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

// ─── Buscador de lugares ───

/// Pide un lugar y devuelve dónde está (null si se cancela). El buscador es
/// el del core; aquí solo se le dan los textos de la app.
Future<LatLng?> buscarLugarEnMapa(BuildContext context) {
  final textos = AppLocalizations.of(context);
  return core.buscarLugarEnMapa(
    context,
    identificacion: 'LarreaZunbeltz (app.zunbeltz.com)',
    textos: core.TextosBuscadorLugares(
      titulo: textos.mapaBuscar,
      ayuda: textos.mapaBuscarAyuda,
      sinResultados: textos.mapaBuscarSinResultados,
      sinConexion: textos.mapaBuscarSinConexion,
      cancelar: textos.comunCancelar,
      buscar: textos.catastroBuscar,
    ),
  );
}

// ─── Catastro ───

List<ContornoPropuesto> _desdeParcelas(
    BuildContext context, List<ParcelaCatastral> parcelas) {
  final textos = AppLocalizations.of(context);
  final idioma = Localizations.localeOf(context).languageCode;
  final hoy = DateFormat('dd/MM/yyyy', idioma).format(DateTime.now());
  return [
    for (final parcela in parcelas)
      for (var i = 0; i < parcela.contornos.length; i++)
        ContornoPropuesto(
          nombre: [
            parcela.subparcela.isEmpty
                ? parcela.nombrePropuesto
                : '${parcela.nombrePropuesto} ${parcela.subparcela}',
            if (parcela.contornos.length > 1) '(${i + 1})',
          ].join(' '),
          notas: textos.catastroNotas(
              parcela.referencia,
              (parcela.superficieM2 / 10000)
                  .toStringAsFixed(2)
                  .replaceAll('.', ','),
              hoy),
          vertices: parcela.contornos[i],
        ),
  ];
}

/// La parcela (y subparcelas) que hay en [punto].
Future<List<ContornoPropuesto>> parcelaCatastralEn(
    BuildContext context, LatLng punto) async {
  final textos = AppLocalizations.of(context);
  try {
    final parcelas = await ServicioCatastroNavarra().enPunto(punto);
    if (!context.mounted) return const [];
    if (parcelas.isEmpty) _avisar(context, textos.catastroNada);
    return _desdeParcelas(context, parcelas);
  } on ErrorCatastro {
    if (context.mounted) _avisar(context, textos.catastroSinConexion);
    return const [];
  }
}

/// Pide municipio, polígono y parcela y la busca.
Future<List<ContornoPropuesto>> parcelaCatastralPorReferencia(
    BuildContext context) async {
  final textos = AppLocalizations.of(context);
  final municipio = TextEditingController();
  final poligono = TextEditingController();
  final parcela = TextEditingController();
  final aceptado = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(textos.zonaDesdeCatastroRef),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
              controller: municipio,
              autofocus: true,
              decoration: InputDecoration(labelText: textos.catastroMunicipio)),
          Row(children: [
            Expanded(
              child: TextField(
                  controller: poligono,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: textos.catastroPoligono)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                  controller: parcela,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: textos.catastroParcela)),
            ),
          ]),
          const SizedBox(height: 12),
          Text(textos.catastroSoloNavarra,
              style: Theme.of(contexto).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(textos.comunCancelar)),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(textos.catastroBuscar)),
      ],
    ),
  );
  final numeroPoligono = int.tryParse(poligono.text.trim());
  final numeroParcela = int.tryParse(parcela.text.trim());
  final nombreMunicipio = municipio.text.trim();
  municipio.dispose();
  poligono.dispose();
  parcela.dispose();
  if (aceptado != true ||
      numeroPoligono == null ||
      numeroParcela == null ||
      nombreMunicipio.isEmpty) {
    return const [];
  }
  try {
    final parcelas = await ServicioCatastroNavarra().porReferencia(
        municipio: nombreMunicipio,
        poligono: numeroPoligono,
        parcela: numeroParcela);
    if (!context.mounted) return const [];
    if (parcelas.isEmpty) _avisar(context, textos.catastroNada);
    return _desdeParcelas(context, parcelas);
  } on ErrorCatastro {
    if (context.mounted) _avisar(context, textos.catastroSinConexion);
    return const [];
  }
}

// ─── Fichero ───

/// Elige un fichero (KML, KMZ, GeoJSON, GPX o Shapefile en zip) y lee sus
/// polígonos.
Future<List<ContornoPropuesto>> contornosDeFichero(BuildContext context) async {
  final textos = AppLocalizations.of(context);
  // FileType.any: en Android las extensiones kml/gpx no tienen tipo MIME
  // fiable y el filtro dejaría el fichero en gris.
  final elegido =
      await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
  final fichero = elegido?.files.singleOrNull;
  final bytes = fichero?.bytes;
  if (fichero == null || bytes == null || !context.mounted) return const [];
  try {
    final leidos = leerContornos(fichero.name, bytes);
    if (leidos.poligonos.isEmpty) {
      _avisar(context, textos.importarNada);
      return const [];
    }
    if (leidos.supuestoUtm30) _avisar(context, textos.importarSupuestoUtm);
    return [
      for (final poligono in leidos.poligonos)
        ContornoPropuesto(
          nombre: poligono.nombre,
          notas: textos.importarNotas(fichero.name),
          vertices: poligono.vertices,
        ),
    ];
  } on FormatoNoSoportado {
    _avisar(context, textos.importarNoSoportado);
  } catch (_) {
    _avisar(context, textos.importarError);
  }
  return const [];
}

// ─── Elegir cuál crear ───

/// Hoja con los contornos propuestos; devuelve el elegido o null.
Future<ContornoPropuesto?> elegirContorno(
    BuildContext context, List<ContornoPropuesto> contornos) {
  final textos = AppLocalizations.of(context);
  return showModalBottomSheet<ContornoPropuesto>(
    context: context,
    isScrollControlled: true,
    builder: (contexto) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(contexto).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(textos.elegirContornoTitulo,
                  style: Theme.of(contexto).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(textos.elegirContornoAyuda,
                  style: Theme.of(contexto).textTheme.bodySmall),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final contorno in contornos)
                    ListTile(
                      leading: const Icon(Icons.pentagon_outlined),
                      title: Text(contorno.nombre.isEmpty
                          ? textos.contornoSinNombre
                          : contorno.nombre),
                      subtitle: Text('${_hectareas(contorno.vertices)} ha'),
                      onTap: () => Navigator.pop(contexto, contorno),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
