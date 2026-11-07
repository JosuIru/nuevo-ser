import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../estado/datos_huerta.dart';
import '../estado/semana_cestas.dart';
import '../provisional_core/venta_directa/semanas.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_cuaderno_ecologico_pdf.dart';
import '../servicios/generador_hoja_cestas_pdf.dart';
import '../utiles/textos_huerta.dart';

/// Documentos en PDF: cuaderno de campo para el certificador (año en curso
/// y anterior) y hoja de cestas (esta semana y la siguiente). Todos con el
/// sello PROVISIONAL.
class PantallaDocumentos extends StatelessWidget {
  const PantallaDocumentos({super.key});

  Future<void> _cuaderno(BuildContext context, int anyo) {
    final bd = BaseDatosSoleraHuerta.instancia;
    final (desde, hasta) = intervaloAnyo(anyo);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'cuaderno_ecologico_$anyo.pdf',
      generar: (tema) async => generarCuadernoEcologicoPdf(
        DatosCuadernoEcologico(
          anyo: anyo,
          titular: await bd.obtenerTitular(),
          datos: await DatosHuerta.cargar(),
          cosechas: await bd.listarCosechas(desdeMs: desde, hastaMs: hasta),
          aplicaciones:
              await bd.listarTratamientos(desdeMs: desde, hastaMs: hasta),
          observaciones:
              await bd.listarObservacionesPlaga(desdeMs: desde, hastaMs: hasta),
        ),
        tema: tema,
      ),
    );
  }

  Future<void> _hojaCestas(BuildContext context, DateTime lunes) {
    return compartirDocumentoPdf(
      context,
      nombreFichero:
          'cestas_${lunes.year}_semana_${numeroSemanaIso(lunes)}.pdf',
      generar: (tema) async => generarHojaCestasPdf(
        semana: await SemanaCestas.cargar(lunes),
        titular: await BaseDatosSoleraHuerta.instancia.obtenerTitular(),
        tema: tema,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anyoActual = DateTime.now().year;
    final estaSemana = lunesDeSemana(DateTime.now());
    final siguiente =
        DateTime(estaSemana.year, estaSemana.month, estaSemana.day + 7);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('huer.documentos'))),
      body: ListView(
        children: [
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(SoleraL10n.t('huer.cuaderno_ecologico')),
              subtitle: Text('$anyo'),
              onTap: () => _cuaderno(context, anyo),
            ),
          for (final lunes in [estaSemana, siguiente])
            ListTile(
              leading: const Icon(Icons.shopping_basket_outlined),
              title: Text(SoleraL10n.t('huer.hoja_cestas')),
              subtitle: Text(SoleraL10n.tf('huer.semana_de', {
                'n': numeroSemanaIso(lunes),
                'fecha': formatearFechaDia(lunes),
              })),
              onTap: () => _hojaCestas(context, lunes),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('huer.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
