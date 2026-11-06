import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../documentos/acta_pdf.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';

/// El acta del asunto: cualquiera la descarga (con la marca BORRADOR hasta
/// que la firmen dos personas de la mesa); la mesa la firma o retira su
/// firma mientras falte la otra.
class SeccionActa extends StatelessWidget {
  const SeccionActa({super.key, required this.estado, required this.asuntoUid});

  final EstadoConcejo estado;
  final String asuntoUid;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estilos = Theme.of(context).textTheme;
    final acta = estado.acta(asuntoUid);
    final lista = estado.actaLista(asuntoUid);
    final yo = estado.personaActual.uid;
    final situacion = !lista
        ? textos.actaNoLista
        : acta.definitiva
            ? textos.actaDefinitiva(estado.nombreDe(acta.firmas[0].personaUid),
                estado.nombreDe(acta.firmas[1].personaUid))
            : textos.actaBorrador(acta.firmas.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(textos.seccionActa, style: estilos.titleMedium),
        const SizedBox(height: 4),
        Row(children: [
          Icon(acta.definitiva ? Icons.verified_outlined : Icons.edit_note,
              size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(situacion)),
        ]),
        if (estado.soyMesa && acta.tieneFirmas && !acta.definitiva)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(textos.actaConFirmasAviso, style: estilos.bodySmall),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final bytes = await actaDelAsunto(
                    estado: estado, asuntoUid: asuntoUid, textos: textos);
                await Printing.sharePdf(
                  bytes: bytes,
                  filename: '${textos.pdfActa.toLowerCase()}-$asuntoUid.pdf',
                );
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(textos.descargarActa),
            ),
            if (estado.soyMesa &&
                lista &&
                !acta.definitiva &&
                !acta.firmadaPor(yo))
              FilledButton.icon(
                onPressed: () async {
                  final seguro = await confirmar(
                    context,
                    mensaje: textos.confirmarFirmarActa,
                    accion: textos.firmar,
                  );
                  if (seguro) estado.firmarActa(asuntoUid);
                },
                icon: const Icon(Icons.draw_outlined),
                label: Text(textos.firmarActa),
              ),
            if (estado.soyMesa && !acta.definitiva && acta.firmadaPor(yo))
              TextButton(
                onPressed: () => estado.retirarFirmaActa(asuntoUid),
                child: Text(textos.retirarFirma),
              ),
          ],
        ),
      ],
    );
  }
}
