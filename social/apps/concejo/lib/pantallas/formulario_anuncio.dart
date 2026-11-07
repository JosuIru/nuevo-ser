import 'package:flutter/material.dart';

import '../dominio/anuncio.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'textos_dominio.dart';

/// Publicar un anuncio en el tablón: título, texto si hace falta y, si
/// caduca (un corte de agua, un taller), el último día que se ve.
class FormularioAnuncio extends StatefulWidget {
  const FormularioAnuncio({super.key, required this.estado});

  final EstadoConcejo estado;

  @override
  State<FormularioAnuncio> createState() => _FormularioAnuncioState();
}

class _FormularioAnuncioState extends State<FormularioAnuncio> {
  final _titulo = TextEditingController();
  final _texto = TextEditingController();
  DateTime? _hasta;
  List<ProblemaAnuncio> _problemas = const [];

  @override
  void dispose() {
    _titulo.dispose();
    _texto.dispose();
    super.dispose();
  }

  void _publicar() {
    final estado = widget.estado;
    final anuncio = Anuncio(
      uid: estado.nuevoUidAnuncio(),
      titulo: _titulo.text,
      texto: _texto.text,
      autorUid: estado.personaActual.uid,
      publicado: estado.ahora,
      hasta: _hasta,
    );
    final problemas = anuncio.problemas(estado.ahora);
    if (problemas.isNotEmpty) {
      setState(() => _problemas = problemas);
      return;
    }
    estado.publicarAnuncio(anuncio);
    Navigator.of(context).pop();
  }

  Future<void> _elegirHasta() async {
    final ahora = widget.estado.ahora;
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final elegido = await showDatePicker(
      context: context,
      initialDate: _hasta ?? hoy.add(const Duration(days: 7)),
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      helpText: AppLocalizations.of(context).ponerFechaFin,
    );
    if (elegido != null) setState(() => _hasta = elegido);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    final hasta = _hasta;
    return Scaffold(
      appBar: AppBar(title: Text(textos.publicarAnuncio)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titulo,
            maxLength: Anuncio.largoMaximoTitulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: textos.campoTitulo,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _texto,
            minLines: 3,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: textos.campoTextoAnuncio,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(hasta == null
                ? textos.anuncioSinFin
                : textos.anuncioHasta(textos.fecha(hasta))),
            trailing: hasta == null
                ? TextButton(
                    onPressed: _elegirHasta, child: Text(textos.ponerFechaFin))
                : TextButton(
                    onPressed: () => setState(() => _hasta = null),
                    child: Text(textos.quitarFechaFin)),
          ),
          Text(textos.ayudaTablon,
              style: Theme.of(context).textTheme.bodySmall),
          if (_problemas.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final problema in _problemas)
              Text(textos.problemaAnuncio(problema),
                  style: TextStyle(color: colores.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _publicar, child: Text(textos.publicar)),
        ],
      ),
    );
  }
}
