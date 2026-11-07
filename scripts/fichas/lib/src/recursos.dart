import 'dart:io';

import 'catalogo_habilidades.dart';
import 'maquetador_pdf.dart';

/// Busca la raíz del paquete `scripts/fichas` subiendo desde [desde]
/// (por defecto, el directorio actual). Así el comando funciona tanto
/// desde `scripts/fichas/` como desde la raíz del monorepo.
Directory? localizarRaizPaquete([Directory? desde]) {
  var directorio = (desde ?? Directory.current).absolute;
  while (true) {
    final candidatos = [directorio, Directory('${directorio.path}/scripts/fichas')];
    for (final candidato in candidatos) {
      if (File('${candidato.path}/fuentes/Roboto-Regular.ttf').existsSync() &&
          File('${candidato.path}/pubspec.yaml').existsSync()) {
        return candidato;
      }
    }
    final padre = directorio.parent;
    if (padre.path == directorio.path) return null;
    directorio = padre;
  }
}

/// `skills.json` de Uno Roto, relativo a la raíz del paquete.
File rutaSkillsPorDefecto(Directory raizPaquete) =>
    File('${raizPaquete.path}/../../apps/uno-roto/assets/data/skills.json');

CatalogoHabilidades cargarCatalogo(File ficheroSkills) =>
    CatalogoHabilidades.desdeJson(ficheroSkills.readAsStringSync());

LetrasFicha cargarLetras(Directory raizPaquete) => LetrasFicha.desdeBytes(
      File('${raizPaquete.path}/fuentes/Roboto-Regular.ttf').readAsBytesSync(),
      File('${raizPaquete.path}/fuentes/Roboto-Medium.ttf').readAsBytesSync(),
    );
