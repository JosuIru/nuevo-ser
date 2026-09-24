import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../l10n/app_localizations.dart';

/// Configuración de actualizaciones de esta app: releases del monorepo con
/// tag `solera-zunbeltz-<versión>`.
final ConfigActualizaciones configActualizacionesZunbeltz =
    configActualizacionesMonorepo('solera-zunbeltz');

/// Traduce los textos del sistema de actualizaciones del core (que vienen
/// en castellano) al idioma activo de la app, vía las claves
/// `actualizaciones*` del ARB. Lo que no reconoce lo devuelve tal cual.
///
/// El euskera de estas claves es borrador pendiente de revisión nativa.
TraductorActualizaciones traductorActualizaciones(AppLocalizations textos) =>
    (String textoEs) => switch (textoEs) {
          'Actualizaciones' => textos.actualizacionesTitulo,
          'Versión instalada' => textos.actualizacionesVersionInstalada,
          'Última publicada' => textos.actualizacionesUltimaPublicada,
          'sin conexión' => textos.actualizacionesSinConexion,
          'ninguna todavía' => textos.actualizacionesNingunaTodavia,
          'Publicada el' => textos.actualizacionesPublicadaEl,
          'Comprobado el' => textos.actualizacionesComprobadoEl,
          'Hay una versión nueva.' => textos.actualizacionesHayVersionNueva,
          'Tienes la última versión.' => textos.actualizacionesTienesLaUltima,
          'Qué trae' => textos.actualizacionesQueTrae,
          'Descargando…' => textos.actualizacionesDescargando,
          'Descargar e instalar' => textos.actualizacionesDescargarEInstalar,
          'Buscar ahora' => textos.actualizacionesBuscarAhora,
          'Versión disponible' => textos.actualizacionesVersionDisponible,
          'Tienes instalada la' => textos.actualizacionesTienesInstalada,
          'Toca para actualizar.' => textos.actualizacionesTocaParaActualizar,
          'Actualizar' => textos.actualizacionesActualizar,
          'Descartar por ahora' => textos.actualizacionesDescartar,
          'Se ha abierto el instalador. Confirma la actualización y vuelve a abrir la app.' =>
            textos.actualizacionesInstaladorAbierto,
          'Se ha abierto la descarga en el navegador.' =>
            textos.actualizacionesDescargaEnNavegador,
          'No se ha podido descargar. Comprueba la conexión y vuelve a probar.' =>
            textos.actualizacionesErrorDescarga,
          'Descargada, pero Android no ha dejado abrir el instalador. Permite «instalar apps desconocidas» para esta app en los ajustes del móvil.' =>
            textos.actualizacionesErrorInstalador,
          _ => textoEs,
        };
