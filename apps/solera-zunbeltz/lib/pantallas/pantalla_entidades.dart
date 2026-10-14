import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../servicios/servicio_logos_entidades.dart';
import 'widgets/logos_entidades.dart';
import 'widgets/relleno_seguro.dart';

/// Las entidades que impulsan, apoyan y colaboran con el espacio. La lista
/// y los logos los mantiene coordinación en el panel de WordPress.
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
    return Scaffold(
      appBar: AppBar(title: Text(textos.entidadesTitulo)),
      body: RefreshIndicator(
        onRefresh: () => _servicio.actualizar(forzar: true),
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            Text(textos.entidadesIntro,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            const LogosEntidadesPorGrupo(),
          ],
        ),
      ),
    );
  }
}
