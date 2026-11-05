import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../logos_entidades.dart';
import '../../modelos/entidad_colaboradora.dart';
import '../../servicios/servicio_logos_entidades.dart';

/// Logo de una entidad: el empaquetado si coordinación no ha subido otro
/// (se ve sin cobertura), el del servidor si lo ha subido, y el nombre si
/// no hay ninguno o no carga.
class LogoEntidad extends StatelessWidget {
  const LogoEntidad(this.entidad, {super.key, required this.altura});

  final EntidadColaboradora entidad;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final hayEmpaquetado = clavesLogosEmpaquetados.contains(entidad.clave);
    Widget nombre() => Text(entidad.nombre,
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center);
    Widget empaquetadoONombre() => hayEmpaquetado
        ? Image.asset(rutaLogoEmpaquetado(entidad.clave),
            height: altura, semanticLabel: entidad.nombre)
        : nombre();

    final Widget logo;
    if ((entidad.logoPropio || !hayEmpaquetado) && entidad.logoUrl.isNotEmpty) {
      logo = Image.network(
        entidad.logoUrl,
        height: altura,
        semanticLabel: entidad.nombre,
        // En la web, como <img>: el WordPress no manda cabeceras CORS para
        // la biblioteca de medios.
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (_, __, ___) => empaquetadoONombre(),
      );
    } else {
      logo = empaquetadoONombre();
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: altura * 3.6, minHeight: altura),
      child: Center(widthFactor: 1, child: logo),
    );
  }
}

String tituloGrupoEntidades(AppLocalizations textos, String codigoGrupo) =>
    switch (GrupoEntidades.desdeCodigo(codigoGrupo)) {
      GrupoEntidades.financian => textos.acercaFinancian,
      GrupoEntidades.impulsan => textos.acercaImpulsan,
      GrupoEntidades.colaboran || null => textos.acercaColaboran,
      GrupoEntidades.miembroDe => textos.acercaMiembroDe,
    };

Future<void> _abrirEnlace(String enlace) async {
  final uri = Uri.parse(enlace);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Todas las entidades por grupo, con su rótulo. Tocar un logo abre la web
/// de la entidad si coordinación la ha puesto.
class LogosEntidadesPorGrupo extends StatelessWidget {
  const LogosEntidadesPorGrupo({super.key, this.colorTinta, this.colorRotulo});

  /// Sobre fondo oscuro: logos teñidos de este color y todo centrado.
  final Color? colorTinta;
  final Color? colorRotulo;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tinta = colorTinta;
    final centrado = tinta != null;
    Widget logo(EntidadColaboradora entidad) {
      final imagen = LogoEntidad(entidad, altura: 40);
      return tinta == null
          ? imagen
          : ColorFiltered(colorFilter: filtroLogoClaro(tinta), child: imagen);
    }

    return ValueListenableBuilder<List<EntidadColaboradora>>(
      valueListenable: ServicioLogosEntidades.actuales,
      builder: (contexto, entidades, _) => Column(
        crossAxisAlignment:
            centrado ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: [
          for (final (grupo, delGrupo) in entidadesPorGrupo(entidades)) ...[
            SizedBox(height: centrado ? 24 : 12),
            Text(tituloGrupoEntidades(textos, grupo.codigo),
                textAlign: centrado ? TextAlign.center : null,
                style: centrado
                    ? Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: colorRotulo ?? tinta)
                    : Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              alignment: centrado ? WrapAlignment.center : WrapAlignment.start,
              spacing: 20,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final entidad in delGrupo)
                  Tooltip(
                    message: entidad.nombre,
                    child: entidad.enlace.isEmpty
                        ? logo(entidad)
                        : InkWell(
                            onTap: () => _abrirEnlace(entidad.enlace),
                            child: logo(entidad),
                          ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Pasa un logo oscuro sobre transparente a [tinta] sobre un fondo oscuro
/// conservando su dibujo: lo oscuro queda opaco y lo claro, transparente
/// (un tinte plano convertiría los escudos en manchas).
ColorFilter filtroLogoClaro(Color tinta) {
  final rojo = tinta.r * 255, verde = tinta.g * 255, azul = tinta.b * 255;
  return ColorFilter.matrix([
    0, 0, 0, 0, rojo, //
    0, 0, 0, 0, verde, //
    0, 0, 0, 0, azul, //
    -0.2126, -0.7152, -0.0722, 1, 0,
  ]);
}

/// Franja con todos los logos por grupo, para el final de Hoy. Al tocarla
/// se abre la pantalla de entidades.
///
/// Con [colorTinta] (sobre la franja verde de Hoy), rótulos y logos van en
/// ese color y centrados: los logos se tiñen enteros, también los que son
/// en color.
class FranjaLogosEntidades extends StatelessWidget {
  const FranjaLogosEntidades(
      {super.key, required this.alPulsar, this.colorTinta, this.colorRotulo});

  final VoidCallback alPulsar;
  final Color? colorTinta;
  final Color? colorRotulo;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tinta = colorTinta;
    final centrado = tinta != null;
    return ValueListenableBuilder<List<EntidadColaboradora>>(
      valueListenable: ServicioLogosEntidades.actuales,
      builder: (contexto, entidades, _) {
        if (entidades.isEmpty) return const SizedBox.shrink();
        Widget logo(EntidadColaboradora entidad) {
          final imagen = LogoEntidad(entidad, altura: centrado ? 32 : 28);
          return tinta == null
              ? imagen
              : ColorFiltered(
                  colorFilter: filtroLogoClaro(tinta), child: imagen);
        }

        return InkWell(
          onTap: alPulsar,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: centrado
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                for (final (grupo, delGrupo)
                    in entidadesPorGrupo(entidades)) ...[
                  Padding(
                    padding:
                        EdgeInsets.only(top: centrado ? 14 : 6, bottom: 10),
                    child: Text(tituloGrupoEntidades(textos, grupo.codigo),
                        textAlign: centrado ? TextAlign.center : null,
                        style: centrado
                            ? Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: colorRotulo ?? tinta)
                            : Theme.of(context).textTheme.labelMedium),
                  ),
                  Wrap(
                    alignment:
                        centrado ? WrapAlignment.center : WrapAlignment.start,
                    spacing: centrado ? 22 : 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final entidad in delGrupo) logo(entidad),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
