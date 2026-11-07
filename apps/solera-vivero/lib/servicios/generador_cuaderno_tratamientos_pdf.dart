import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../modelos/inspeccion_plagas.dart';
import '../modelos/partida_planta.dart';
import '../modelos/tratamiento.dart';
import '../modelos/vivero.dart';
import '../modelos/zona_cultivo.dart';
import '../utiles/textos_vivero.dart';

/// Sello hasta que un asesor GIP valide el formato frente al modelo de la
/// comunidad autónoma. Lo vigila test/sello_provisional_test.dart.
const String selloCuadernoTratamientos = 'PROVISIONAL';

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

/// Datos del cuaderno de tratamientos de un año.
class DatosCuadernoTratamientos {
  const DatosCuadernoTratamientos({
    required this.anyo,
    required this.vivero,
    required this.zonas,
    required this.partidas,
    required this.tratamientos,
    required this.inspecciones,
    this.nombreEspecie = _identidad,
    this.nombreSustancia = _identidad,
    this.nombrePlaga = _identidad,
  });

  final int anyo;
  final Vivero vivero;
  final List<ZonaCultivo> zonas;
  final List<PartidaPlanta> partidas;
  final List<Tratamiento> tratamientos;
  final List<InspeccionPlagas> inspecciones;
  final String Function(String) nombreEspecie;
  final String Function(String) nombreSustancia;
  final String Function(String) nombrePlaga;
}

String _identidad(String texto) => texto;

/// Tablas del cuaderno: datos generales, zonas de cultivo, tratamientos
/// fitosanitarios e inspecciones de plagas reguladas (autocontrol).
/// Columnas cotejadas el 2026-11-07 con el RD 1311/2012, anexo III, parte I
/// (texto consolidado, https://www.boe.es/buscar/act.php?id=BOE-A-2012-11605):
/// A.1 datos generales (falta la relación de equipos con su inspección),
/// A.2 parcelas (nº de orden, SIGPAC, superficie en ha, aire libre o
/// protegido) y B a-k de los tratamientos (fecha, parcela, plaga, aplicador,
/// cultivo con variedad, ha, producto y nº de registro, equipo, kg o l de
/// producto, eficacia y observaciones). El modelo de cada comunidad puede
/// pedir más: **por cotejar** con el asesor.
List<TablaInforme> tablasCuadernoTratamientos(DatosCuadernoTratamientos datos) {
  final zonas = {for (final zona in datos.zonas) zona.id!: zona};
  final partidas = {for (final partida in datos.partidas) partida.id!: partida};
  final numeroOrden = {
    for (final (indice, zona) in datos.zonas.indexed) zona.id!: indice + 1
  };
  String donde(int? partidaId, int? zonaId) => [
        if (zonaId != null)
          '${numeroOrden[zonaId] ?? '?'}. ${zonas[zonaId]?.nombre ?? ''}',
        if (partidaId != null) partidas[partidaId]?.codigo ?? '#$partidaId',
      ].join(' · ');
  String especie(int? partidaId) {
    final partida = partidas[partidaId];
    if (partida == null) return '—';
    return _o([
      datos.nombreEspecie(partida.especieId),
      partida.variedad,
    ].where((parte) => parte.isNotEmpty).join(' · '));
  }

  String hectareas(double? metrosCuadrados) => metrosCuadrados == null
      ? '—'
      : formatearNumero(metrosCuadrados / 10000, decimales: 4);
  final vivero = datos.vivero;
  final tratamientos = [...datos.tratamientos]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final inspecciones = [...datos.inspecciones]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  return [
    TablaInforme(
      titulo: SoleraL10n.t('vive.pdf_datos_generales'),
      headers: [SoleraL10n.t('vive.pdf_dato'), SoleraL10n.t('vive.pdf_valor')],
      filas: [
        [SoleraL10n.t('vive.nombre_vivero'), _o(vivero.nombre)],
        ['NIF', _o(vivero.nif)],
        [
          SoleraL10n.t('vive.codigo_ropveg'),
          _o(vivero.codigoRopvegNormalizado)
        ],
        [
          SoleraL10n.t('vive.registro_explotacion'),
          _o(vivero.registroExplotacion)
        ],
        [SoleraL10n.t('vive.municipio'), _o(vivero.municipio)],
        [SoleraL10n.t('vive.comunidad_autonoma'), _o(vivero.comunidadAutonoma)],
        [SoleraL10n.t('vive.asesor'), _o(vivero.asesorNombre)],
        [SoleraL10n.t('vive.asesor_ropo'), _o(vivero.asesorNumeroRopo)],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('vive.pdf_zonas'),
      headers: [
        SoleraL10n.t('vive.pdf_numero_orden'),
        SoleraL10n.t('vive.nombre'),
        SoleraL10n.t('vive.tipo_zona'),
        SoleraL10n.t('vive.pdf_sistema_cultivo'),
        'ha',
        SoleraL10n.t('vive.codigo_sigpac'),
      ],
      filas: [
        for (final zona in datos.zonas)
          [
            '${numeroOrden[zona.id]}',
            zona.nombre,
            nombreTipoZona(zona.tipo),
            SoleraL10n.t(zona.tipo == 'invernadero' || zona.tipo == 'umbraculo'
                ? 'vive.pdf_protegido'
                : 'vive.pdf_aire_libre'),
            hectareas(zona.superficieM2),
            _o(zona.codigoSigpac),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('vive.sin_zonas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('vive.tratamientos'),
      headers: [
        SoleraL10n.t('vive.fecha'),
        SoleraL10n.t('vive.pdf_donde'),
        SoleraL10n.t('vive.especie'),
        SoleraL10n.t('vive.problema_fitosanitario'),
        SoleraL10n.t('vive.sustancia_activa'),
        SoleraL10n.t('vive.nombre_producto'),
        SoleraL10n.t('vive.pdf_numero_registro'),
        SoleraL10n.t('vive.dosis_aplicada'),
        SoleraL10n.t('vive.pdf_cantidad_producto'),
        'ha',
        SoleraL10n.t('vive.pdf_plazo'),
        SoleraL10n.t('vive.pdf_aplicador'),
        SoleraL10n.t('vive.pdf_equipo'),
        SoleraL10n.t('vive.eficacia'),
        SoleraL10n.t('vive.observaciones'),
      ],
      filas: [
        for (final tratamiento in tratamientos)
          [
            formatearFecha(tratamiento.fechaMs),
            _o(donde(tratamiento.partidaId, tratamiento.zonaId)),
            especie(tratamiento.partidaId),
            _o(datos.nombrePlaga(tratamiento.problemaFitosanitario)),
            _o(datos.nombreSustancia(tratamiento.sustanciaActivaId)),
            _o(tratamiento.nombreProducto),
            _o(tratamiento.numeroRegistroProducto),
            _o(tratamiento.dosisAplicada),
            _o(tratamiento.cantidadProductoUtilizado),
            hectareas(tratamiento.superficieTratadaM2),
            tratamiento.plazoSeguridadDias == null
                ? '—'
                : '${tratamiento.plazoSeguridadDias}',
            _o([
              tratamiento.aplicadorNombre,
              tratamiento.carnetAplicador,
            ].where((parte) => parte.isNotEmpty).join(' · ')),
            _o(tratamiento.equipoAplicacion),
            tratamiento.eficacia.isEmpty
                ? '—'
                : nombreEficacia(tratamiento.eficacia),
            _o(tratamiento.observaciones),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('vive.sin_tratamientos'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('vive.inspecciones'),
      headers: [
        SoleraL10n.t('vive.fecha'),
        SoleraL10n.t('vive.pdf_donde'),
        SoleraL10n.t('vive.plaga_regulada'),
        SoleraL10n.t('vive.tipo_inspeccion'),
        SoleraL10n.t('vive.inspector'),
        SoleraL10n.t('vive.resultado'),
        SoleraL10n.t('vive.muestra_tomada'),
        SoleraL10n.t('vive.notificada_autoridad'),
      ],
      filas: [
        for (final inspeccion in inspecciones)
          [
            formatearFecha(inspeccion.fechaMs),
            _o(donde(inspeccion.partidaId, inspeccion.zonaId)),
            _o(datos.nombrePlaga(inspeccion.plagaId)),
            nombreTipoInspeccion(inspeccion.tipo),
            _o(inspeccion.inspectorNombre),
            nombreResultadoInspeccion(inspeccion.resultado),
            SoleraL10n.t(inspeccion.muestraTomada ? 'vive.si' : 'vive.no'),
            SoleraL10n.t(
                inspeccion.notificadaAutoridad ? 'vive.si' : 'vive.no'),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('vive.sin_inspecciones'),
    ),
  ];
}

/// Cuaderno de tratamientos del año en PDF, con sello PROVISIONAL.
Future<Uint8List> generarCuadernoTratamientosPdf(
    DatosCuadernoTratamientos datos,
    {pw.ThemeData? tema}) {
  final vivero = datos.vivero;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('vive.cuaderno_tratamientos')} · ${datos.anyo}',
    subtituloCabecera: '${_o(vivero.nombre)}'
        '${vivero.codigoRopveg.isEmpty ? '' : ' · ${vivero.codigoRopvegNormalizado}'}'
        ' · $selloCuadernoTratamientos',
    bulletsResumen: [
      '${SoleraL10n.t('vive.tratamientos')}: ${datos.tratamientos.length}',
      '${SoleraL10n.t('vive.inspecciones')}: ${datos.inspecciones.length}',
      SoleraL10n.t('vive.aviso_registro_electronico'),
      SoleraL10n.t('vive.aviso_documento_provisional'),
    ],
    tablas: tablasCuadernoTratamientos(datos),
    operador: vivero.nombre.isEmpty ? null : vivero.nombre,
    tema: tema,
  );
}
