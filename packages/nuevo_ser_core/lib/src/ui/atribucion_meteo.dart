// Atribución de los datos del tiempo. Open-Meteo los da con licencia
// CC BY 4.0, que pide citar la fuente allí donde se muestran.

import 'package:flutter/material.dart';

import '../i18n/solera_l10n.dart';

class AtribucionMeteo extends StatelessWidget {
  const AtribucionMeteo({super.key, this.alineacion = TextAlign.end});

  final TextAlign alineacion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        SoleraL10n.t('core.meteo.fuente'),
        textAlign: alineacion,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
