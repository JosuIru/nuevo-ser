import 'package:flutter/material.dart';

import '../branding.dart';
import '../l10n/app_localizations.dart';
import '../servicios/servicio_logos_entidades.dart';
import 'widgets/logos_entidades.dart';
import 'widgets/relleno_seguro.dart';

/// Las entidades que impulsan, apoyan y colaboran con el espacio, sobre el
/// verde de la cabecera y con los logos en claro. La lista y los logos los
/// mantiene coordinación en el panel de WordPress.
class PantallaEntidades extends StatefulWidget {
  const PantallaEntidades({super.key});

  @override
  State<PantallaEntidades> createState() => _PantallaEntidadesState();
}

class _PantallaEntidadesState extends State<PantallaEntidades> {
  final _servicio = ServicioLogosEntidades();

  @override
  void initState() {
    super.initState();
    _servicio.actualizar();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = context.coloresZunbeltz;
    return Scaffold(
      backgroundColor: colores.cabecera,
      appBar: AppBar(
        backgroundColor: colores.cabecera,
        foregroundColor: colores.sobreCabecera,
        iconTheme: IconThemeData(color: colores.sobreCabecera),
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: colores.sobreCabecera),
        title: Text(textos.entidadesTitulo),
      ),
      body: RefreshIndicator(
        onRefresh: () => _servicio.actualizar(forzar: true),
        child: ListView(
          padding: rellenoSobreBarraSistema(
              context, const EdgeInsets.fromLTRB(20, 0, 20, 32)),
          children: [
            Text(textos.entidadesIntro,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colores.sobreCabeceraVariante)),
            LogosEntidadesPorGrupo(
              colorTinta: colores.sobreCabecera.withValues(alpha: 0.85),
              colorRotulo: colores.sobreCabeceraVariante,
            ),
          ],
        ),
      ),
    );
  }
}
