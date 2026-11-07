import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../modelos/abonado.dart';
import '../modelos/cosecha.dart';
import '../modelos/parcela.dart';
import '../modelos/riego.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_frutal.dart';

/// Sello hasta que un asesor de gestión integrada de plagas y la
/// administración autonómica validen el formato. Lo vigila
/// test/sello_provisional_test.dart.
const String selloCuadernoExplotacion = 'PROVISIONAL';

/// Todo lo que entra en el cuaderno de un año.
class DatosCuadernoExplotacion {
  DatosCuadernoExplotacion({
    required this.anyo,
    required this.titular,
    required this.parcelas,
    this.tratamientos = const [],
    this.abonados = const [],
    this.riegos = const [],
    this.cosechas = const [],
    this.nombreSustancia,
    this.nombrePlaga,
  });

  final int anyo;
  final Titular titular;
  final List<Parcela> parcelas;
  final List<Tratamiento> tratamientos;
  final List<Abonado> abonados;
  final List<Riego> riegos;
  final List<Cosecha> cosechas;

  /// Traduce un id de catálogo a su nombre (bloque 6); sin él, el id.
  final String Function(String id)? nombreSustancia;
  final String Function(String id)? nombrePlaga;
}

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

String _numero(num? valor, {int decimales = 2}) => valor == null || valor == 0
    ? '—'
    : formatearNumero(valor, decimales: decimales);

/// Número de orden de cada parcela (1, 2, 3… por nombre), como en el
/// modelo de cuaderno: las demás hojas citan la parcela por ese número.
Map<int, int> numerosDeOrden(List<Parcela> parcelas) => {
      for (final (indice, parcela) in parcelas.indexed) parcela.id!: indice + 1,
    };

/// Las tablas del cuaderno, en el orden del modelo de referencia
/// (identificación de parcelas, tratamientos, fertilización, riegos y
/// cosecha comercializada). Función pura para poder probarla.
List<TablaInforme> tablasCuadernoExplotacion(DatosCuadernoExplotacion datos) {
  final orden = numerosDeOrden(datos.parcelas);
  final porId = {for (final parcela in datos.parcelas) parcela.id!: parcela};
  String parcela(int id) =>
      '${orden[id] ?? '?'} · ${porId[id]?.nombre ?? '#$id'}';
  String sustancia(String id) => _o(datos.nombreSustancia?.call(id) ?? id);
  String plaga(String id) => _o(datos.nombrePlaga?.call(id) ?? id);
  List<T> ordenadas<T>(List<T> lista, int Function(T) fecha) =>
      [...lista]..sort((a, b) => fecha(a).compareTo(fecha(b)));
  return [
    TablaInforme(
      titulo: SoleraL10n.t('frut.pdf_identificacion_parcelas'),
      headers: [
        SoleraL10n.t('frut.pdf_orden'),
        SoleraL10n.t('frut.codigo_sigpac'),
        SoleraL10n.t('frut.nombre'),
        SoleraL10n.t('frut.especie'),
        SoleraL10n.t('frut.variedad'),
        SoleraL10n.t('frut.superficie_ha'),
        SoleraL10n.t('frut.pdf_secano_regadio'),
      ],
      filas: [
        for (final item in datos.parcelas)
          [
            '${orden[item.id]}',
            _o(item.codigoSigpac),
            item.nombre,
            nombreEspecie(item.especieId),
            _o(item.variedadPrincipalId),
            _numero(item.superficieHa),
            item.regadio
                ? '${SoleraL10n.t('frut.regadio')} (${nombreSistemaRiego(item.sistemaRiego)})'
                : SoleraL10n.t('frut.secano'),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('frut.sin_parcelas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('frut.pdf_tratamientos'),
      headers: [
        SoleraL10n.t('frut.fecha'),
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.pdf_superficie_tratada'),
        SoleraL10n.t('frut.pdf_problema'),
        SoleraL10n.t('frut.sustancia_activa'),
        SoleraL10n.t('frut.pdf_producto_registro'),
        SoleraL10n.t('frut.pdf_dosis'),
        SoleraL10n.t('frut.pdf_aplicador_carnet'),
        SoleraL10n.t('frut.pdf_equipo'),
        SoleraL10n.t('frut.eficacia'),
      ],
      filas: [
        for (final item in ordenadas(datos.tratamientos, (t) => t.fechaMs))
          [
            formatearFecha(item.fechaMs),
            parcela(item.parcelaId),
            _numero(item.superficieTratadaHa),
            plaga(item.problemaFitosanitario),
            sustancia(item.sustanciaActivaId),
            '${_o(item.nombreProducto)} / ${_o(item.numeroRegistroProducto)}',
            _o(item.dosisAplicada),
            '${_o(item.aplicadorNombre)} / ${_o(item.carnetAplicador)}',
            _o(item.equipoAplicacion),
            item.eficacia.isEmpty ? '—' : nombreEficacia(item.eficacia),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('frut.sin_registros'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('frut.pdf_fertilizacion'),
      headers: [
        SoleraL10n.t('frut.fecha'),
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.tipo_abono'),
        SoleraL10n.t('frut.riqueza_npk'),
        SoleraL10n.t('frut.cantidad_kg_ha'),
        SoleraL10n.t('frut.pdf_metodo'),
        SoleraL10n.t('frut.superficie_ha'),
      ],
      filas: [
        for (final item in ordenadas(datos.abonados, (a) => a.fechaMs))
          [
            formatearFecha(item.fechaMs),
            parcela(item.parcelaId),
            item.tipoAbono,
            _o(item.riquezaNpk),
            _numero(item.cantidadKgPorHa, decimales: 0),
            nombreMetodoAbonado(item.metodo),
            _numero(item.superficieHa),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('frut.sin_registros'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('frut.riegos'),
      headers: [
        SoleraL10n.t('frut.fecha'),
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.volumen_m3'),
        SoleraL10n.t('frut.horas'),
        SoleraL10n.t('frut.origen_agua'),
      ],
      filas: [
        for (final item in ordenadas(datos.riegos, (r) => r.fechaMs))
          [
            formatearFecha(item.fechaMs),
            parcela(item.parcelaId),
            _numero(item.volumenM3, decimales: 1),
            _numero(item.horas, decimales: 1),
            _o(item.origenAgua),
          ],
      ],
      // Sin riegos (secano) la sección no aparece.
    ),
    TablaInforme(
      titulo: SoleraL10n.t('frut.pdf_cosecha_comercializada'),
      headers: [
        SoleraL10n.t('frut.fecha'),
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.pdf_kg'),
        SoleraL10n.t('frut.destino'),
        SoleraL10n.t('frut.numero_albaran'),
      ],
      filas: [
        for (final item in ordenadas(datos.cosechas, (c) => c.fechaMs))
          [
            formatearFecha(item.fechaMs),
            parcela(item.parcelaId),
            _numero(item.kgCascara, decimales: 0),
            _o(item.destino),
            _o(item.numeroAlbaran),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('frut.sin_registros'),
    ),
  ];
}

/// Cuaderno de explotación de un año en PDF.
Future<Uint8List> generarCuadernoExplotacionPdf(DatosCuadernoExplotacion datos,
    {pw.ThemeData? tema}) {
  final titular = datos.titular;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('frut.cuaderno_explotacion')} · ${datos.anyo}',
    subtituloCabecera: '${_o(titular.nombre)}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'} · $selloCuadernoExplotacion',
    bulletsResumen: [
      '${SoleraL10n.t('frut.registro_explotacion')}: ${_o(titular.registroExplotacion)}',
      '${SoleraL10n.t('frut.municipio')}: ${_o(titular.municipio)}',
      '${SoleraL10n.t('frut.asesor')}: ${_o(titular.asesorNombre)}'
          ' · ROPO ${_o(titular.asesorNumeroRopo)}',
      SoleraL10n.t('frut.aviso_documento_provisional'),
    ],
    tablas: tablasCuadernoExplotacion(datos),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
