import 'package:flutter/material.dart';

import '../dominio/compromiso.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'tarjeta_compromiso.dart';

/// Todos los compromisos que han salido de los acuerdos y su estado. Es la
/// página que da confianza: que la participación no sea teatro.
class PantallaSeHaHecho extends StatelessWidget {
  const PantallaSeHaHecho({super.key, required this.estado});

  final EstadoConcejo estado;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final balance = BalanceCompromisos(estado.compromisos, estado.ahora);
    // Primero lo que está fuera de plazo, luego lo abierto y al final lo cerrado.
    int peso(Compromiso c) =>
        c.vencidoEn(estado.ahora) ? 0 : (c.cerrado ? 2 : 1);
    final ordenados = [...estado.compromisos]..sort((a, b) {
        final porPeso = peso(a).compareTo(peso(b));
        return porPeso != 0 ? porPeso : a.fechaLimite.compareTo(b.fechaLimite);
      });
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
            textos.balanceCompromisos(
                balance.hechos, balance.total, balance.vencidos),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (ordenados.isEmpty) Text(textos.sinCompromisos),
        for (final compromiso in ordenados)
          TarjetaCompromiso(
              estado: estado, compromiso: compromiso, mostrarAsunto: true),
      ],
    );
  }
}
