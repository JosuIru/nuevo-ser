import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../documentos/documentos_papel.dart';
import '../dominio/persona.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import '../servidor/sincronizador.dart';
import 'dialogos.dart';

/// La mesa da de alta a la gente y le saca su código en papel.
class PantallaPersonas extends StatelessWidget {
  const PantallaPersonas({super.key, required this.estado, this.sincronizador});

  final EstadoConcejo estado;

  /// `null` en el pueblo de ejemplo: no hay servidor que dé códigos.
  final Sincronizador? sincronizador;

  Future<void> _sacarCodigo(BuildContext context, Persona persona) async {
    final textos = AppLocalizations.of(context);
    final mensajero = ScaffoldMessenger.of(context);
    final seguro = await confirmar(context,
        mensaje: textos.confirmarSacarCodigo(persona.nombre),
        accion: textos.sacarCodigo);
    if (!seguro || !context.mounted) return;
    final String codigo;
    try {
      codigo = await sincronizador!.nuevoCodigo(persona.uid);
    } catch (_) {
      mensajero.showSnackBar(SnackBar(content: Text(textos.errorConexion)));
      return;
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(textos.codigoDe(persona.nombre)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(codigo,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(textos.codigoUnaVez),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final bytes = await hojaDeCodigo(
                nombreEspacio: estado.nombreEspacio,
                nombrePersona: persona.nombre,
                direccion: sincronizador!.direccionPueblo,
                codigo: codigo,
                textos: textos,
              );
              await Printing.layoutPdf(onLayout: (_) async => bytes);
            },
            child: Text(textos.imprimirHoja),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(textos.entendido),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final personas = [...estado.personas]..sort(
            (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
        return Scaffold(
          appBar: AppBar(title: Text(textos.personas)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final nombre = await pedirTexto(context,
                  titulo: textos.darDeAltaPersona,
                  etiqueta: textos.nombreNuevaPersona,
                  confirmar: textos.guardar);
              if (nombre == null || !context.mounted) return;
              final nueva = estado.darDeAlta(nombre);
              if (sincronizador != null && context.mounted) {
                await _sacarCodigo(context, nueva);
              }
            },
            icon: const Icon(Icons.person_add_alt),
            label: Text(textos.darDeAltaPersona),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (sincronizador == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(textos.soloConServidor),
                ),
              for (final persona in personas)
                ListTile(
                  title: Text(persona.nombre),
                  subtitle: Text(persona.esMesaEn(estado.ahora)
                      ? textos.rolMesa
                      : textos.rolVecina),
                  trailing: sincronizador == null
                      ? null
                      : TextButton(
                          onPressed: () => _sacarCodigo(context, persona),
                          child: Text(textos.sacarCodigo),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}
