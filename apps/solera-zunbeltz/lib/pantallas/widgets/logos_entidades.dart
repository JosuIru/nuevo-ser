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
  const LogosEntidadesPorGrupo({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ValueListenableBuilder<List<EntidadColaboradora>>(
      valueListenable: ServicioLogosEntidades.actuales,
      builder: (contexto, entidades, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (grupo, delGrupo) in entidadesPorGrupo(entidades)) ...[
            const SizedBox(height: 12),
            Text(tituloGrupoEntidades(textos, grupo.codigo),
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final entidad in delGrupo)
                  Tooltip(
                    message: entidad.nombre,
                    child: entidad.enlace.isEmpty
                        ? LogoEntidad(entidad, altura: 40)
                        : InkWell(
                            onTap: () => _abrirEnlace(entidad.enlace),
                            child: LogoEntidad(entidad, altura: 40),
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

/// Franja discreta con todos los logos por grupo, para el final de Hoy. Al tocarla
/// se abre la pantalla de entidades.
class FranjaLogosEntidades extends StatelessWidget {
  const FranjaLogosEntidades({super.key, required this.alPulsar});

  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ValueListenableBuilder<List<EntidadColaboradora>>(
      valueListenable: ServicioLogosEntidades.actuales,
      builder: (contexto, entidades, _) {
        if (entidades.isEmpty) return const SizedBox.shrink();
        return InkWell(
          onTap: alPulsar,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (grupo, delGrupo)
                    in entidadesPorGrupo(entidades)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text(tituloGrupoEntidades(textos, grupo.codigo),
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final entidad in delGrupo)
                        LogoEntidad(entidad, altura: 28),
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
