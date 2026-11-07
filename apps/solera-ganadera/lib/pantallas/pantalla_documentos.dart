import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_parametros_ecoregimen.dart';
import '../datos/catalogos_generados/catalogo_tabla_ugm.dart';
import '../dominio/informe_ecoregimen.dart';
import '../estado/datos_ganado.dart';
import '../modelos/carga_ganadera.dart';
import '../modelos/ganado.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_documento_movimiento_pdf.dart';
import '../servicios/generador_informe_ecoregimen_pdf.dart';
import '../servicios/generador_libro_registro_pdf.dart';

/// Documentos en PDF: libro de registro e informe del eco-régimen. El
/// documento de cada movimiento sale desde la ficha del rebaño.
class PantallaDocumentos extends StatefulWidget {
  const PantallaDocumentos({super.key});

  @override
  State<PantallaDocumentos> createState() => _PantallaDocumentosState();
}

class _PantallaDocumentosState extends State<PantallaDocumentos> {
  String _tramite = tramitePac;

  Future<void> _libro(int anio) {
    final baseDatos = BaseDatosSoleraGanadera.instancia;
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'libro_registro_$anio.pdf',
      generar: (tema) async => generarLibroRegistroPdf(
        titular: await baseDatos.obtenerTitular(),
        explotacion: await baseDatos.obtenerExplotacion(),
        datos: await DatosGanado.cargar(),
        visitas: await baseDatos.listarVisitas(),
        desde: DateTime(anio),
        hasta: DateTime(anio + 1),
        tema: tema,
      ),
    );
  }

  Future<void> _ecoregimen(int anio) {
    final baseDatos = BaseDatosSoleraGanadera.instancia;
    final ahora = DateTime.now();
    final finCampana = DateTime(anio, 12, 31);
    return compartirDocumentoPdf(
      context,
      nombreFichero: 'ecoregimen_pastoreo_$anio.pdf',
      generar: (tema) async {
        final datos = await DatosGanado.cargar();
        return generarInformeEcoregimenPdf(
          campana: anio,
          nombreTramite: nombreTramiteUgm(_tramite),
          informes: calcularInformeEcoregimen(
            piezas: datos.piezas,
            lotes: datos.lotes,
            animales: datos.animales,
            movimientos: datos.movimientos,
            tabla: tablaDeTramite(catalogoCoeficientesUgm, _tramite),
            parametros: catalogoParametrosEcoregimen,
            desde: DateTime(anio),
            hasta: finCampana.isAfter(ahora) ? ahora : finCampana,
            ahora: ahora,
          ),
          titular: await baseDatos.obtenerTitular(),
          explotacion: await baseDatos.obtenerExplotacion(),
          tema: tema,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final anio = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('gana.documentos'))),
      body: ListView(
        children: [
          for (final cual in [anio, anio - 1])
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(SoleraL10n.t('gana.libro_registro')),
              subtitle: Text('$cual'),
              onTap: () => _libro(cual),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: _tramite,
              decoration:
                  InputDecoration(labelText: SoleraL10n.t('gana.tabla_ugm')),
              items: [
                for (final tramite in [tramitePac, tramiteAndalucia])
                  DropdownMenuItem(
                      value: tramite, child: Text(nombreTramiteUgm(tramite))),
              ],
              onChanged: (valor) =>
                  setState(() => _tramite = valor ?? _tramite),
            ),
          ),
          for (final cual in [anio, anio - 1])
            ListTile(
              leading: const Icon(Icons.grass_outlined),
              title: Text(SoleraL10n.t('gana.informe_ecoregimen')),
              subtitle: Text('$cual'),
              onTap: () => _ecoregimen(cual),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(SoleraL10n.t('gana.aviso_documento_provisional'),
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

String nombreTramiteUgm(String tramite) => SoleraL10n.t(
    tramite == tramitePac ? 'gana.tramite_pac' : 'gana.tramite_andalucia');

/// Comparte el documento de un movimiento con explotación externa.
Future<void> compartirDocumentoMovimiento(
    BuildContext context,
    MovimientoGanado movimiento,
    LoteGanado lote,
    List<Animal> animalesDelLote) {
  final baseDatos = BaseDatosSoleraGanadera.instancia;
  return compartirDocumentoPdf(
    context,
    nombreFichero: 'movimiento_${movimiento.id ?? 0}.pdf',
    generar: (tema) async => generarDocumentoMovimientoPdf(
      movimiento: movimiento,
      lote: lote,
      animalesDelLote: animalesDelLote,
      titular: await baseDatos.obtenerTitular(),
      explotacion: await baseDatos.obtenerExplotacion(),
      tema: tema,
    ),
  );
}
