import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../l10n/app_localizations.dart';
import '../../servicios/servicio_fotos_web.dart';
import '../../utiles/fotos_sincronizadas.dart';
import 'fotos_sincronizadas.dart';

/// Selector de fotos de los formularios: como el [SelectorFotos] del core
/// (botón «+» para añadir de la cámara o la galería, cruz para quitar),
/// pero entiende las fotos sincronizadas de otros móviles (`foto:<hash>`),
/// que salen como «Sin descargar» hasta que bajan (ver [MiniaturaFoto]).
///
/// En el navegador no hay ficheros: las fotos se guardan en la BD y se
/// apuntan directamente como `foto:<hash>` (`servicio_fotos_web.dart`).
class SelectorFotosApp extends StatelessWidget {
  final List<String> rutas;
  final ValueChanged<List<String>> alCambiar;
  final double altura;

  const SelectorFotosApp({
    super.key,
    required this.rutas,
    required this.alCambiar,
    this.altura = 96,
  });

  Future<void> _anadir(BuildContext context) async {
    final nuevas = await pedirFotos(context);
    if (nuevas.isEmpty) return;
    alCambiar([...rutas, ...nuevas]);
  }

  void _quitar(int indice) {
    final entrada = rutas[indice];
    // Una foto hecha aquí se borra del móvil, como hace el core; una de
    // otro móvil (referencia o ya bajada) se deja: puede usarla otra ficha.
    if (!esReferenciaFoto(entrada) && !entrada.contains('/fotos_sync/')) {
      GestorFotos.borrarSiExiste(entrada);
    }
    alCambiar([...rutas]..removeAt(indice));
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return SizedBox(
      height: altura,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rutas.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, indice) {
          if (indice == rutas.length) {
            return InkWell(
              onTap: () => _anadir(context),
              child: Container(
                width: altura,
                height: altura,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo, size: 24),
                    const SizedBox(height: 4),
                    Text(textos.fotoAnadir,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
            );
          }
          return MiniaturaFoto(
            entrada: rutas[indice],
            tamano: altura,
            alQuitar: () => _quitar(indice),
          );
        },
      ),
    );
  }
}

/// Pregunta de dónde sacar las fotos (cámara o galería) y las trae. Con
/// [pregunta], la hoja la enseña arriba y ofrece «Ahora no». Lista vacía si
/// se cancela. En el navegador devuelve referencias `foto:<hash>`.
Future<List<String>> pedirFotos(BuildContext context,
    {String? pregunta}) async {
  final textos = AppLocalizations.of(context);
  final fuente = await showModalBottomSheet<FuenteFoto>(
    context: context,
    builder: (contextoHoja) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pregunta != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(pregunta,
                  style: Theme.of(contextoHoja).textTheme.titleMedium),
            ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(textos.fotoDesdeCamara),
            onTap: () => Navigator.pop(contextoHoja, FuenteFoto.camara),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(textos.fotoDesdeGaleria),
            onTap: () => Navigator.pop(contextoHoja, FuenteFoto.galeria),
          ),
          if (pregunta != null)
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(textos.fotoAhoraNo),
              onTap: () => Navigator.pop(contextoHoja),
            ),
        ],
      ),
    ),
  );
  if (fuente == null) return const [];
  if (kIsWeb) return tomarFotosWeb(fuente);
  return GestorFotos.tomarOSeleccionar(fuente: fuente);
}
