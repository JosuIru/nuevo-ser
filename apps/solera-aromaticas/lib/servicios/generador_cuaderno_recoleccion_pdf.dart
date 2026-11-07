import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/catalogos.dart';
import '../dominio/recoleccion.dart';
import '../modelos/cosecha.dart';
import '../modelos/parcela.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona_recoleccion.dart';
import '../utiles/textos_aromaticas.dart';

/// Sello hasta que el técnico de medio natural (recolección) y el asesor
/// GIP (tratamientos) validen el formato. Lo vigila
/// test/sello_provisional_test.dart.
const String selloCuadernoRecoleccion = 'PROVISIONAL';

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

String _numero(num? valor, {int? decimales}) =>
    valor == null ? '—' : formatearNumero(valor, decimales: decimales);

String _especieConCientifico(String especieId) {
  final cientifico = nombreCientificoEspecie(especieId);
  return cientifico.isEmpty
      ? nombreEspecie(especieId)
      : '${nombreEspecie(especieId)} ($cientifico)';
}

/// Lo que entra en el cuaderno de un año natural.
class DatosCuadernoRecoleccion {
  DatosCuadernoRecoleccion({
    required this.anyo,
    required this.titular,
    this.parcelas = const [],
    this.zonas = const [],
    this.cosechas = const [],
    this.tratamientos = const [],
  });

  final int anyo;
  final Titular titular;
  final List<Parcela> parcelas;
  final List<ZonaRecoleccion> zonas;

  /// Cosechas del año (de parcelas y de zonas).
  final List<Cosecha> cosechas;
  final List<Tratamiento> tratamientos;
}

/// Tablas del cuaderno de cosechas y recolección: zonas con su permiso y lo
/// recolectado en cada una; recolecciones silvestres; parcelas con número de
/// orden; cosechas de cultivo y tratamientos (RD 1311/2012). Funciones puras.
List<TablaInforme> tablasCuadernoRecoleccion(DatosCuadernoRecoleccion datos) {
  final ordenParcela = {
    for (final (indice, parcela) in datos.parcelas.indexed)
      parcela.id: indice + 1
  };
  final parcelaPorId = {for (final p in datos.parcelas) p.id: p};
  final zonaPorId = {for (final z in datos.zonas) z.id: z};
  String nombreParcela(int? id) =>
      '${ordenParcela[id] ?? '?'} · ${parcelaPorId[id]?.nombre ?? '#$id'}';
  final porFecha = [...datos.cosechas]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final silvestres = porFecha.where((cosecha) => cosecha.esSilvestre).toList();
  final cultivadas = porFecha.where((cosecha) => !cosecha.esSilvestre).toList();
  final tratamientos = [...datos.tratamientos]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  return [
    TablaInforme(
      titulo: SoleraL10n.t('arom.pdf_zonas_permisos'),
      headers: [
        SoleraL10n.t('arom.zona'),
        SoleraL10n.t('arom.comunidad_autonoma'),
        SoleraL10n.t('arom.tipo_terreno'),
        SoleraL10n.t('arom.numero_permiso'),
        SoleraL10n.t('arom.organismo_permiso'),
        SoleraL10n.t('arom.pdf_vigencia'),
        SoleraL10n.t('arom.especies_permitidas'),
        SoleraL10n.t('arom.pdf_limite_kg'),
        SoleraL10n.t('arom.pdf_kg_vigencia'),
      ],
      filas: [
        for (final zona in datos.zonas)
          [
            '${zona.nombre}${zona.municipio.isEmpty ? '' : ' (${zona.municipio})'}',
            _o(zona.comunidadAutonoma),
            nombreTipoTerreno(zona.tipoTerreno),
            zona.tienePermiso
                ? zona.numeroPermiso
                : SoleraL10n.t('arom.sin_permiso_apuntado'),
            _o(zona.organismoPermiso),
            '${zona.inicioVigenciaMs == null ? '—' : formatearFecha(zona.inicioVigenciaMs!)}'
                ' – ${zona.finVigenciaMs == null ? '—' : formatearFecha(zona.finVigenciaMs!)}',
            zona.especiesPermitidas.isEmpty
                ? '—'
                : zona.especiesPermitidas.map(nombreEspecie).join(', '),
            _numero(zona.limiteKg, decimales: 0),
            _numero(kgRecolectadosEnVigencia(zona, datos.cosechas)),
          ],
      ],
      mensajeSiVacia: datos.zonas.isEmpty && datos.parcelas.isNotEmpty
          ? null
          : SoleraL10n.t('arom.sin_zonas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('arom.pdf_recolecciones'),
      headers: [
        SoleraL10n.t('arom.fecha'),
        SoleraL10n.t('arom.zona'),
        SoleraL10n.t('arom.permiso'),
        SoleraL10n.t('arom.especie'),
        SoleraL10n.t('arom.kg_frescos'),
        SoleraL10n.t('arom.estado_fenologico'),
        SoleraL10n.t('arom.parte_recolectada'),
        SoleraL10n.t('arom.recolector'),
        SoleraL10n.t('arom.pdf_avisos'),
      ],
      filas: [
        for (final cosecha in silvestres)
          () {
            final zona = zonaPorId[cosecha.zonaRecoleccionId];
            final avisos = zona == null
                ? const <AvisoRecoleccion>[]
                : comprobarRecoleccion(
                    zona: zona,
                    especieId: cosecha.especieId,
                    fecha: DateTime.fromMillisecondsSinceEpoch(cosecha.fechaMs),
                    kgNuevos: 0,
                    previas: const [],
                    especieConProteccion:
                        especieConProteccion(cosecha.especieId));
            return [
              formatearFecha(cosecha.fechaMs),
              zona?.nombre ?? '#${cosecha.zonaRecoleccionId}',
              zona != null && zona.tienePermiso ? zona.numeroPermiso : '—',
              _especieConCientifico(cosecha.especieId),
              _numero(cosecha.kgFrescos),
              cosecha.estadoFenologico.isEmpty
                  ? '—'
                  : nombreEstadoFenologico(cosecha.estadoFenologico),
              _o(cosecha.parteRecolectada),
              _o(cosecha.recolector),
              avisos.isEmpty
                  ? '—'
                  : avisos.map(textoAvisoRecoleccion).join(' '),
            ];
          }(),
      ],
      mensajeSiVacia:
          datos.zonas.isEmpty ? null : SoleraL10n.t('arom.sin_cosechas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('arom.pdf_parcelas'),
      headers: [
        SoleraL10n.t('arom.pdf_orden'),
        SoleraL10n.t('arom.codigo_sigpac'),
        SoleraL10n.t('arom.nombre'),
        SoleraL10n.t('arom.especie'),
        'ha',
        SoleraL10n.t('arom.ecologico'),
      ],
      filas: [
        for (final parcela in datos.parcelas)
          [
            '${ordenParcela[parcela.id]}',
            _o(parcela.codigoSigpac),
            parcela.nombre,
            _especieConCientifico(parcela.especieId),
            _numero(parcela.superficieHa, decimales: 2),
            SoleraL10n.t(parcela.ecologico ? 'arom.si' : 'arom.no'),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('arom.pdf_cosechas_cultivo'),
      headers: [
        SoleraL10n.t('arom.fecha'),
        SoleraL10n.t('arom.parcela'),
        SoleraL10n.t('arom.especie'),
        SoleraL10n.t('arom.kg_frescos'),
        SoleraL10n.t('arom.estado_fenologico'),
        SoleraL10n.t('arom.parte_recolectada'),
      ],
      filas: [
        for (final cosecha in cultivadas)
          [
            formatearFecha(cosecha.fechaMs),
            nombreParcela(cosecha.parcelaId),
            _especieConCientifico(cosecha.especieId),
            _numero(cosecha.kgFrescos),
            cosecha.estadoFenologico.isEmpty
                ? '—'
                : nombreEstadoFenologico(cosecha.estadoFenologico),
            _o(cosecha.parteRecolectada),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('arom.pdf_tratamientos'),
      headers: [
        SoleraL10n.t('arom.fecha'),
        SoleraL10n.t('arom.parcela'),
        SoleraL10n.t('arom.problema_fitosanitario'),
        SoleraL10n.t('arom.sustancia_activa'),
        SoleraL10n.t('arom.pdf_producto_registro'),
        SoleraL10n.t('arom.dosis_aplicada'),
        'ha',
        SoleraL10n.t('arom.pdf_aplicador_carnet'),
        SoleraL10n.t('arom.eficacia'),
      ],
      filas: [
        for (final tratamiento in tratamientos)
          [
            formatearFecha(tratamiento.fechaMs),
            nombreParcela(tratamiento.parcelaId),
            tratamiento.problemaFitosanitario.isEmpty
                ? '—'
                : nombrePlaga(tratamiento.problemaFitosanitario),
            _o(tratamiento.sustanciaActivaId),
            '${_o(tratamiento.nombreProducto)} / ${_o(tratamiento.numeroRegistroProducto)}',
            _o(tratamiento.dosisAplicada),
            _numero(tratamiento.superficieTratadaHa, decimales: 2),
            '${_o(tratamiento.aplicadorNombre)} / ${_o(tratamiento.carnetAplicador)}',
            tratamiento.eficacia.isEmpty
                ? '—'
                : nombreEficacia(tratamiento.eficacia),
          ],
      ],
      // Sin parcelas de cultivo la sección no sale.
      mensajeSiVacia:
          datos.parcelas.isEmpty ? null : SoleraL10n.t('arom.sin_tratamientos'),
    ),
  ];
}

/// Cuaderno de cosechas y recolección de un año en PDF.
Future<Uint8List> generarCuadernoRecoleccionPdf(DatosCuadernoRecoleccion datos,
    {pw.ThemeData? tema}) {
  final kgSilvestres = datos.cosechas
      .where((cosecha) => cosecha.esSilvestre)
      .fold<double>(0, (suma, cosecha) => suma + cosecha.kgFrescos);
  final kgCultivo = datos.cosechas
      .where((cosecha) => !cosecha.esSilvestre)
      .fold<double>(0, (suma, cosecha) => suma + cosecha.kgFrescos);
  final titular = datos.titular;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('arom.cuaderno_recoleccion')} · ${datos.anyo}',
    subtituloCabecera: '${_o(titular.nombre)}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'}'
        '${titular.registroExplotacion.isEmpty ? '' : ' · ${titular.registroExplotacion}'}'
        ' · $selloCuadernoRecoleccion',
    bulletsResumen: [
      SoleraL10n.tf(
          'arom.pdf_total_silvestre', {'kg': formatearNumero(kgSilvestres)}),
      SoleraL10n.tf(
          'arom.pdf_total_cultivo', {'kg': formatearNumero(kgCultivo)}),
      if (titular.asesorNombre.isNotEmpty)
        '${SoleraL10n.t('arom.asesor')}: ${titular.asesorNombre}'
            '${titular.asesorNumeroRopo.isEmpty ? '' : ' (ROPO ${titular.asesorNumeroRopo})'}',
      SoleraL10n.t('arom.pdf_aviso_recoleccion'),
      SoleraL10n.t('arom.pdf_aviso_registro_electronico'),
      SoleraL10n.t('arom.aviso_documento_provisional'),
    ],
    tablas: tablasCuadernoRecoleccion(datos),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
