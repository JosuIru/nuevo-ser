import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/composicion_receta.dart';
import '../modelos/receta.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_cuaderno_autocontrol_pdf.dart';
import '../servicios/generador_ficha_tecnica_pdf.dart';

/// Documentos en PDF: cuaderno de autocontrol y cartel de alérgenos.
class PantallaDocumentos extends StatelessWidget {
  const PantallaDocumentos({super.key});

  Future<void> _cuaderno(BuildContext context, DateTime mes) {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'autocontrol_${DateFormat('yyyy_MM').format(mes)}.pdf',
      generar: (tema) async => generarCuadernoAutocontrolPdf(
        mes: mes,
        titular: await baseDatos.obtenerTitular(),
        registros: await baseDatos.listarRegistrosAutocontrol(
            desdeMs: mes.millisecondsSinceEpoch,
            hastaMs:
                DateTime(mes.year, mes.month + 1).millisecondsSinceEpoch - 1),
        tema: tema,
      ),
    );
  }

  Future<void> _cartel(BuildContext context) {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'cartel_alergenos.pdf',
      generar: (tema) async {
        final recetas = {
          for (final receta in await baseDatos.listarRecetas())
            receta.id!: receta
        };
        final lineas = await baseDatos.lineasPorReceta();
        final ingredientes = {
          for (final ingrediente in await baseDatos.listarIngredientes())
            ingrediente.id!: ingrediente
        };
        final productos = <Receta, ComposicionReceta>{};
        for (final receta
            in recetas.values.where((receta) => !receta.esSubreceta)) {
          try {
            productos[receta] = ComposicionReceta.calcular(
                recetaId: receta.id!,
                recetas: recetas,
                lineasPorReceta: lineas,
                ingredientes: ingredientes);
          } on StateError {
            // Una receta con error no sale en el cartel: se ve en su ficha.
          }
        }
        return generarCartelAlergenosPdf(
            productos: productos,
            titular: await baseDatos.obtenerTitular(),
            tema: tema);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final mesActual = DateTime(ahora.year, ahora.month);
    final mesAnterior = DateTime(ahora.year, ahora.month - 1);
    final formatoMes = DateFormat.yMMMM(SoleraL10n.idioma);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.documentos'))),
      body: ListView(
        children: [
          for (final mes in [mesActual, mesAnterior])
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(SoleraL10n.t('obra.cuaderno_autocontrol')),
              subtitle: Text(formatoMes.format(mes)),
              onTap: () => _cuaderno(context, mes),
            ),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: Text(SoleraL10n.t('obra.cartel_alergenos')),
            subtitle: Text(SoleraL10n.t('obra.cartel_alergenos_explicacion')),
            onTap: () => _cartel(context),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('obra.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
