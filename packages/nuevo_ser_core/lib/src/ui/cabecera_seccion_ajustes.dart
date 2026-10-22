import 'package:flutter/material.dart';

/// Título de una sección de la pantalla de Ajustes (Explotación, Registros,
/// Preferencias, Datos, Aplicación…). Común a la suite para que todas las
/// apps ordenen sus ajustes igual y con el mismo aspecto.
class CabeceraSeccionAjustes extends StatelessWidget {
  const CabeceraSeccionAjustes(this.titulo, {super.key});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        titulo,
        style: tema.textTheme.titleSmall?.copyWith(
          color: tema.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
