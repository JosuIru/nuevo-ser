import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../documentos/convocatoria_pdf.dart';
import '../dominio/sesion.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';
import 'ficha_asunto.dart';
import 'formulario_sesion.dart';
import 'textos_dominio.dart';

/// Una asamblea: cuándo y dónde, el orden del día (con lo hablado en cada
/// punto) y quién vino. La mesa cambia o anula la convocatoria antes de
/// empezar y, desde ese día, apunta la asistencia y las notas.
class FichaSesion extends StatelessWidget {
  const FichaSesion({super.key, required this.estado, required this.sesionUid});

  final EstadoConcejo estado;
  final String sesionUid;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final sesion = estado.sesion(sesionUid);
        final ahora = estado.ahora;
        final colores = Theme.of(context).colorScheme;
        final puedeCambiar =
            estado.soyMesa && !sesion.anulada && !sesion.empezadaEn(ahora);
        final apuntaMesa = estado.soyMesa && sesion.admiteAsistenciaEn(ahora);
        return Scaffold(
          appBar: AppBar(
            title: Text(sesion.titulo),
            actions: [
              IconButton(
                tooltip: textos.pdfConvocatoria,
                icon: const Icon(Icons.print_outlined),
                onPressed: () => _descargarConvocatoria(context, sesion),
              ),
              if (puedeCambiar)
                PopupMenuButton<String>(
                  onSelected: (opcion) => opcion == 'cambiar'
                      ? Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              FormularioSesion(estado: estado, sesion: sesion),
                        ))
                      : _anular(context, sesion),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'cambiar',
                        child: Text(textos.cambiarConvocatoria)),
                    PopupMenuItem(
                        value: 'anular', child: Text(textos.anularAsamblea)),
                  ],
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (sesion.anulada)
                Card(
                  color: colores.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(textos.asambleaAnulada(sesion.motivoAnulacion),
                        style: TextStyle(color: colores.onErrorContainer)),
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(textos.fechaYHora(sesion.inicio)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined),
                title: Text(sesion.lugar),
              ),
              const SizedBox(height: 8),
              Text(textos.ordenDelDia,
                  style: Theme.of(context).textTheme.titleMedium),
              for (final (indice, punto) in sesion.puntos.indexed)
                _Punto(
                  estado: estado,
                  sesion: sesion,
                  numero: indice + 1,
                  punto: punto,
                  puedeApuntar: apuntaMesa,
                ),
              if (!sesion.anulada) ...[
                const SizedBox(height: 16),
                Text(textos.asistencia,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                if (sesion.admiteAsistenciaEn(ahora))
                  Text(textos.asistentesResumen(sesion.asistentes,
                      sesion.asistentesUids.length, sesion.asistentesSinApp))
                else
                  Text(textos.asistenciaDesdeElDia,
                      style: Theme.of(context).textTheme.bodySmall),
                if (apuntaMesa) _Asistencia(estado: estado, sesion: sesion),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _descargarConvocatoria(
      BuildContext context, Sesion sesion) async {
    final textos = AppLocalizations.of(context);
    final bytes = await convocatoriaDeLaSesion(
      nombreEspacio: estado.nombreEspacio,
      sesion: sesion,
      buscarAsunto: estado.buscarAsunto,
      textos: textos,
    );
    await Printing.sharePdf(
        bytes: bytes, filename: 'convocatoria-${sesion.uid}.pdf');
  }

  Future<void> _anular(BuildContext context, Sesion sesion) async {
    final textos = AppLocalizations.of(context);
    final motivo = await pedirTexto(context,
        titulo: textos.anularAsamblea,
        etiqueta: textos.motivoAnulacion,
        confirmar: textos.anularAsamblea);
    if (motivo != null) estado.anularSesion(sesion.uid, motivo);
  }
}

class _Punto extends StatelessWidget {
  const _Punto({
    required this.estado,
    required this.sesion,
    required this.numero,
    required this.punto,
    required this.puedeApuntar,
  });

  final EstadoConcejo estado;
  final Sesion sesion;
  final int numero;
  final PuntoOrdenDia punto;
  final bool puedeApuntar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final asuntoUid = punto.asuntoUid;
    final asunto = asuntoUid == null ? null : estado.buscarAsunto(asuntoUid);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$numero. ${punto.texto}',
                style: Theme.of(context).textTheme.titleSmall),
            if (punto.notas.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(textos.notasDelPunto,
                  style: Theme.of(context).textTheme.labelMedium),
              Text(punto.notas),
            ],
            Wrap(spacing: 8, children: [
              if (asunto != null)
                TextButton.icon(
                  icon: const Icon(Icons.forum_outlined),
                  label: Text(textos.verAsunto),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          FichaAsunto(estado: estado, asuntoUid: asunto.uid))),
                ),
              if (puedeApuntar)
                TextButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: Text(textos.apuntarNotas),
                  onPressed: () async {
                    final notas = await pedirTexto(context,
                        titulo: punto.texto,
                        etiqueta: textos.notasDelPunto,
                        confirmar: textos.guardar,
                        inicial: punto.notas);
                    if (notas != null) {
                      estado.anotarNotasPunto(sesion.uid, punto.uid, notas);
                    }
                  },
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// La mesa marca quién vino (con cuenta) y cuánta gente sin app.
class _Asistencia extends StatelessWidget {
  const _Asistencia({required this.estado, required this.sesion});

  final EstadoConcejo estado;
  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Column(
      children: [
        for (final persona in estado.personas)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(persona.nombre),
            value: sesion.asistentesUids.contains(persona.uid),
            onChanged: (presente) => estado.anotarAsistencia(
                sesion.uid, persona.uid,
                presente: presente ?? false),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(textos.asistentesSinApp),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: sesion.asistentesSinApp == 0
                  ? null
                  : () => estado.anotarAsistentesSinApp(
                      sesion.uid, sesion.asistentesSinApp - 1),
            ),
            Text('${sesion.asistentesSinApp}',
                style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => estado.anotarAsistentesSinApp(
                  sesion.uid, sesion.asistentesSinApp + 1),
            ),
          ]),
        ),
      ],
    );
  }
}
