import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/catalogos.dart';
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

/// Código de secano/regadío del modelo andaluz v8 (apartado 2.1): SEC,
/// ASP (aspersión), LOC (goteo o localizado), GRA (gravedad).
String codigoRiegoModelo(Parcela parcela) => !parcela.regadio
    ? 'SEC'
    : switch (parcela.sistemaRiego) {
        'aspersion' => 'ASP',
        'superficie' => 'GRA',
        _ => 'LOC',
      };

/// Tipo de aplicación del registro de fertilización del modelo andaluz v8
/// (apartado 6): F fertirrigación, AF abonado de fondo, AC cobertera. La
/// foliar no tiene código en el modelo: se escribe entera.
String codigoAbonadoModelo(String metodo) => switch (metodo) {
      'fertirrigacion' => 'F',
      'fondo' => 'AF',
      'cobertera' => 'AC',
      _ => nombreMetodoAbonado(metodo),
    };

/// Kilos de nitrógeno por hectárea a partir de la riqueza «N-P-K» (el
/// primer número, en %) y la cantidad de abono; null si no se entiende.
double? nitrogenoKgPorHa(String riquezaNpk, double cantidadKgPorHa) {
  final primero = RegExp(r'^\s*(\d+(?:[.,]\d+)?)').firstMatch(riquezaNpk);
  if (primero == null || cantidadKgPorHa <= 0) return null;
  return cantidadKgPorHa *
      double.parse(primero.group(1)!.replaceAll(',', '.')) /
      100;
}

/// Las tablas del cuaderno, en el orden del modelo andaluz v8: personas
/// (1.2), equipos (1.3), parcelas (2.1), actuaciones fitosanitarias (3.1),
/// fertilización (6), riego (8) y cosecha comercializada (5, al final para
/// cerrar la campaña). Función pura para poder probarla.
List<TablaInforme> tablasCuadernoExplotacion(DatosCuadernoExplotacion datos) {
  final orden = numerosDeOrden(datos.parcelas);
  final porId = {for (final parcela in datos.parcelas) parcela.id!: parcela};
  String parcela(int id) =>
      '${orden[id] ?? '?'} · ${porId[id]?.nombre ?? '#$id'}'
      ' (${nombreEspecie(porId[id]?.especieId ?? '')})';
  final personas = <(String, String)>{
    for (final tratamiento in datos.tratamientos)
      if (tratamiento.aplicadorNombre.trim().isNotEmpty)
        (
          tratamiento.aplicadorNombre.trim(),
          tratamiento.carnetAplicador.trim()
        ),
  }.toList();
  final equipos = <String>{
    for (final tratamiento in datos.tratamientos)
      if (tratamiento.equipoAplicacion.trim().isNotEmpty)
        tratamiento.equipoAplicacion.trim(),
  }.toList();
  final acumuladoPorParcela = <int, double>{};
  String sustancia(String id) => _o(datos.nombreSustancia?.call(id) ?? id);
  String plaga(String id) => _o(datos.nombrePlaga?.call(id) ?? id);
  List<T> ordenadas<T>(List<T> lista, int Function(T) fecha) =>
      [...lista]..sort((a, b) => fecha(a).compareTo(fecha(b)));
  return [
    TablaInforme(
      titulo: SoleraL10n.t('frut.pdf_personas'),
      headers: [
        SoleraL10n.t('frut.pdf_orden'),
        SoleraL10n.t('frut.aplicador'),
        SoleraL10n.t('frut.carnet_aplicador'),
      ],
      filas: [
        for (final (indice, (nombre, carne)) in personas.indexed)
          ['${indice + 1}', nombre, _o(carne)],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('frut.pdf_equipos'),
      headers: [
        SoleraL10n.t('frut.pdf_orden'),
        SoleraL10n.t('frut.equipo_aplicacion'),
      ],
      filas: [
        for (final (indice, equipo) in equipos.indexed)
          ['${indice + 1}', equipo],
      ],
    ),
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
            _o(nombreVariedad(item.variedadPrincipalId)),
            _numero(item.superficieHa),
            codigoRiegoModelo(item),
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
        SoleraL10n.t('frut.observaciones'),
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
            _o(item.observaciones),
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
        SoleraL10n.t('frut.pdf_nitrogeno'),
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
            _numero(nitrogenoKgPorHa(item.riquezaNpk, item.cantidadKgPorHa),
                decimales: 1),
            codigoAbonadoModelo(item.metodo),
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
        SoleraL10n.t('frut.pdf_sistema'),
        SoleraL10n.t('frut.volumen_m3'),
        SoleraL10n.t('frut.pdf_m3_ha'),
        SoleraL10n.t('frut.pdf_m3_ha_acumulado'),
        SoleraL10n.t('frut.horas'),
        SoleraL10n.t('frut.origen_agua'),
      ],
      filas: [
        for (final item in ordenadas(datos.riegos, (r) => r.fechaMs))
          [
            formatearFecha(item.fechaMs),
            parcela(item.parcelaId),
            nombreSistemaRiego(porId[item.parcelaId]?.sistemaRiego ?? ''),
            _numero(item.volumenM3, decimales: 1),
            ...() {
              final superficie = porId[item.parcelaId]?.superficieHa ?? 0;
              if (superficie <= 0) return ['—', '—'];
              final porHectarea = item.volumenM3 / superficie;
              final acumulado = acumuladoPorParcela.update(
                  item.parcelaId, (valor) => valor + porHectarea,
                  ifAbsent: () => porHectarea);
              return [
                _numero(porHectarea, decimales: 1),
                _numero(acumulado, decimales: 1)
              ];
            }(),
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
        SoleraL10n.t('frut.pdf_producto'),
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.pdf_kg'),
        SoleraL10n.t('frut.destino'),
        SoleraL10n.t('frut.numero_albaran'),
      ],
      filas: [
        for (final item in ordenadas(datos.cosechas, (c) => c.fechaMs))
          [
            formatearFecha(item.fechaMs),
            nombreEspecie(porId[item.parcelaId]?.especieId ?? ''),
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
      SoleraL10n.t('frut.aviso_registro_electronico'),
      SoleraL10n.t('frut.aviso_documento_provisional'),
    ],
    tablas: tablasCuadernoExplotacion(datos),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
