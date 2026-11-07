import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../documentos/guia_pdf.dart';
import '../l10n/app_localizations.dart';

/// Un apartado de la guía: título y pasos (uno por línea en el ARB).
typedef ApartadoGuia = ({String titulo, List<String> pasos});

List<ApartadoGuia> _apartado(String titulo, String texto) =>
    [(titulo: titulo, pasos: texto.split('\n'))];

/// Lo que necesita saber cualquiera.
List<ApartadoGuia> guiaParaTodos(AppLocalizations textos) => [
      ..._apartado(textos.guiaEntrarTitulo, textos.guiaEntrar),
      ..._apartado(textos.guiaDecidirTitulo, textos.guiaDecidir),
      ..._apartado(textos.guiaEspacioTitulo, textos.guiaEspacio),
      ..._apartado(textos.guiaSinRedTitulo, textos.guiaSinRed),
    ];

/// Lo que hace la mesa, en el orden en que suele hacerlo.
List<ApartadoGuia> guiaParaLaMesa(AppLocalizations textos) => [
      ..._apartado(textos.guiaMesaEmpezarTitulo, textos.guiaMesaEmpezar),
      ..._apartado(textos.guiaMesaAsuntoTitulo, textos.guiaMesaAsunto),
      ..._apartado(textos.guiaMesaAsambleaTitulo, textos.guiaMesaAsamblea),
      ..._apartado(textos.guiaMesaTareasTitulo, textos.guiaMesaTareas),
      ..._apartado(textos.guiaMesaModerarTitulo, textos.guiaMesaModerar),
    ];

/// La guía dentro de la app. A la mesa le sale primero su parte; se puede
/// imprimir entera para repartirla.
class PantallaGuia extends StatelessWidget {
  const PantallaGuia(
      {super.key, required this.nombreEspacio, required this.soyMesa});

  final String nombreEspacio;
  final bool soyMesa;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final partes = [
      (textos.guiaParaTodos, guiaParaTodos(textos)),
      (textos.guiaParaLaMesa, guiaParaLaMesa(textos)),
    ];
    final ordenadas = soyMesa ? partes.reversed.toList() : partes;
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.guiaTitulo),
        actions: [
          IconButton(
            tooltip: textos.imprimirGuia,
            icon: const Icon(Icons.print_outlined),
            onPressed: () async {
              final bytes =
                  await guiaEnPdf(nombreEspacio: nombreEspacio, textos: textos);
              await Printing.sharePdf(
                  bytes: bytes, filename: 'guia-concejo.pdf');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (titulo, apartados) in ordenadas) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child:
                  Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final apartado in apartados)
              Card(
                child: ExpansionTile(
                  title: Text(apartado.titulo),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (indice, paso) in apartado.pasos.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 24, child: Text('${indice + 1}.')),
                            Expanded(child: Text(paso)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
