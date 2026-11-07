import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/sorteo_lena.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_acta_sorteo_pdf.dart';
import '../servicios/generador_estado_plan_pdf.dart';
import '../servicios/generador_parte_aprovechamientos_pdf.dart';
import '../servicios/generador_revision_incendios_pdf.dart';

BaseDatosSoleraMonte get _bd => BaseDatosSoleraMonte.instancia;

Future<DatosParteAprovechamientos> cargarDatosParte(int campanya) async {
  final sorteos = await _bd.listarSorteos(campanya: campanya);
  return DatosParteAprovechamientos(
    campanya: campanya,
    monte: await _bd.obtenerMonte(),
    rodales: await _bd.listarRodales(),
    aprovechamientos: await _bd.listarAprovechamientos(campanya: campanya),
    sorteos: sorteos,
    lotes: [
      for (final sorteo in sorteos)
        ...await _bd.listarLotes(sorteoId: sorteo.id)
    ],
  );
}

Future<DatosEstadoPlan> cargarDatosEstadoPlan() async => DatosEstadoPlan(
      anyoActual: DateTime.now().year,
      monte: await _bd.obtenerMonte(),
      rodales: await _bd.listarRodales(),
      actuaciones: await _bd.listarActuaciones(),
      ejecuciones: await _bd.listarEjecuciones(),
      aprovechamientos: await _bd.listarAprovechamientos(),
    );

Future<DatosRevisionIncendios> cargarDatosRevisionIncendios(int anyo) async =>
    DatosRevisionIncendios(
      anyo: anyo,
      monte: await _bd.obtenerMonte(),
      infraestructuras: await _bd.listarInfraestructuras(),
      revisiones: await _bd.listarRevisiones(),
    );

/// Acta de un sorteo (desde su pantalla).
Future<void> compartirActaSorteo(BuildContext context, SorteoLena sorteo) {
  return compartirDocumentoPdf(
    context,
    nombreFichero: 'acta_sorteo_lena_${sorteo.campanya}_${sorteo.id}.pdf',
    generar: (tema) async => generarActaSorteoPdf(
      monte: await _bd.obtenerMonte(),
      sorteo: sorteo,
      lotes: await _bd.listarLotes(sorteoId: sorteo.id),
      rodales: await _bd.listarRodales(),
      tema: tema,
    ),
  );
}

/// Documentos en PDF: parte de aprovechamientos de la campaña, estado del
/// plan de gestión y hoja de revisión de incendios. Todos PROVISIONALES.
class PantallaDocumentos extends StatelessWidget {
  const PantallaDocumentos({super.key});

  @override
  Widget build(BuildContext context) {
    final anyoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('mont.documentos'))),
      body: ListView(
        children: [
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.carpenter_outlined),
              title: Text(SoleraL10n.t('mont.parte_aprovechamientos')),
              subtitle: Text('$anyo'),
              onTap: () => compartirDocumentoPdf(
                context,
                nombreFichero: 'parte_aprovechamientos_$anyo.pdf',
                generar: (tema) async => generarParteAprovechamientosPdf(
                    await cargarDatosParte(anyo),
                    tema: tema),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: Text(SoleraL10n.t('mont.estado_plan')),
            subtitle: Text(SoleraL10n.t('mont.estado_plan_ayuda')),
            onTap: () => compartirDocumentoPdf(
              context,
              nombreFichero: 'estado_plan_gestion_$anyoActual.pdf',
              generar: (tema) async => generarEstadoPlanPdf(
                  await cargarDatosEstadoPlan(),
                  tema: tema),
            ),
          ),
          for (final anyo in [anyoActual, anyoActual - 1])
            ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: Text(SoleraL10n.t('mont.hoja_revision_incendios')),
              subtitle: Text('$anyo'),
              onTap: () => compartirDocumentoPdf(
                context,
                nombreFichero: 'revision_incendios_$anyo.pdf',
                generar: (tema) async => generarRevisionIncendiosPdf(
                    await cargarDatosRevisionIncendios(anyo),
                    tema: tema),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('mont.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
