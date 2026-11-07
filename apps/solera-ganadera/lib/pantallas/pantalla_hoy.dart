import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

class PantallaHoy extends StatelessWidget {
  const PantallaHoy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Larrea Ganadera')),
      body: Center(child: Text(SoleraL10n.t('gana.bienvenida'))),
    );
  }
}
