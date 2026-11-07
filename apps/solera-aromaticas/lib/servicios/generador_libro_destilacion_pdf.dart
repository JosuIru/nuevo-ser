import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/catalogos.dart';
import '../dominio/rendimientos.dart';
import '../dominio/trazabilidad.dart';
import '../modelos/cosecha.dart';
import '../modelos/destilacion.dart';
import '../modelos/lote_producto.dart';
import '../modelos/parcela.dart';
import '../modelos/secado.dart';
import '../modelos/titular.dart';
import '../modelos/zona_recoleccion.dart';
import '../utiles/textos_aromaticas.dart';

/// Sello hasta que el asesor de regulación de aceites esenciales valide el
/// formato y el régimen de cada destino. Lo vigila
/// test/sello_provisional_test.dart.
const String selloLibroDestilacion = 'PROVISIONAL';

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

String _numero(num? valor, {int? decimales}) =>
    valor == null ? '—' : formatearNumero(valor, decimales: decimales);

String _intervalo(double? minimo, double? maximo) =>
    minimo == null || maximo == null
        ? '—'
        : minimo == maximo
            ? formatearNumero(minimo)
            : '${formatearNumero(minimo)}-${formatearNumero(maximo)}';

/// Lo que entra en el libro de un año natural.
class DatosLibroDestilacion {
  DatosLibroDestilacion({
    required this.anyo,
    required this.titular,
    this.destilaciones = const [],
    this.secados = const [],
    this.lotes = const [],
    this.cosechas = const [],
    this.parcelas = const [],
    this.zonas = const [],
  });

  final int anyo;
  final Titular titular;

  /// Procesos y lotes del año.
  final List<Destilacion> destilaciones;
  final List<Secado> secados;
  final List<LoteProducto> lotes;

  /// Todas las cosechas, parcelas y zonas (para la trazabilidad).
  final List<Cosecha> cosechas;
  final List<Parcela> parcelas;
  final List<ZonaRecoleccion> zonas;
}

/// Tablas del libro de destilación y lotes: destilaciones con rendimiento,
/// secados, rendimiento por especie y lotes con su origen. Funciones puras.
List<TablaInforme> tablasLibroDestilacion(DatosLibroDestilacion datos) {
  final lotePorId = {for (final lote in datos.lotes) lote.id: lote};
  String codigo(int? id) => id == null ? '—' : lotePorId[id]?.codigo ?? '#$id';
  final destilaciones = [...datos.destilaciones]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final secados = [...datos.secados]
    ..sort((a, b) => a.fechaInicioMs.compareTo(b.fechaInicioMs));
  final lotes = [...datos.lotes]..sort((a, b) => a.codigo.compareTo(b.codigo));
  final resumen = resumirDestilaciones(destilaciones);
  return [
    TablaInforme(
      titulo: SoleraL10n.t('arom.destilaciones'),
      headers: [
        SoleraL10n.t('arom.fecha'),
        SoleraL10n.t('arom.especie'),
        SoleraL10n.t('arom.pdf_planta'),
        SoleraL10n.t('arom.kg_planta'),
        SoleraL10n.t('arom.tipo_alambique'),
        'h',
        SoleraL10n.t('arom.pdf_ml_aceite'),
        'ml/kg',
        SoleraL10n.t('arom.pdf_orientativo_gkg'),
        SoleraL10n.t('arom.pdf_l_hidrolato'),
        SoleraL10n.t('arom.lotes'),
      ],
      filas: [
        for (final destilacion in destilaciones)
          () {
            final orientativo = rendimientoOrientativo(destilacion.especieId,
                producto: 'aceite_esencial',
                estadoPlanta:
                    destilacion.estadoPlanta == 'seca' ? 'seca' : 'fresca');
            return [
              formatearFecha(destilacion.fechaMs),
              nombreEspecie(destilacion.especieId),
              nombreEstadoPlanta(destilacion.estadoPlanta),
              _numero(destilacion.kgPlanta),
              nombreTipoAlambique(destilacion.tipoAlambique),
              _numero(destilacion.horas),
              _numero(destilacion.mlAceiteEsencial, decimales: 0),
              _numero(destilacion.rendimientoAceite, decimales: 2),
              _intervalo(orientativo?.minimo, orientativo?.maximo),
              _numero(destilacion.litrosHidrolato),
              [
                codigo(destilacion.loteAceiteId),
                codigo(destilacion.loteHidrolatoId)
              ].where((texto) => texto != '—').join(', ').ifEmpty('—'),
            ];
          }(),
      ],
      mensajeSiVacia: SoleraL10n.t('arom.pdf_sin_destilaciones'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('arom.rendimiento_por_especie'),
      headers: [
        SoleraL10n.t('arom.especie'),
        SoleraL10n.t('arom.pdf_planta'),
        'n',
        SoleraL10n.t('arom.kg_planta'),
        SoleraL10n.t('arom.pdf_ml_aceite'),
        'ml/kg',
        SoleraL10n.t('arom.pdf_l_hidrolato'),
        'l/kg',
      ],
      filas: [
        for (final MapEntry(key: clave, value: total) in resumen.entries)
          [
            nombreEspecie(total.especieId),
            nombreEstadoPlanta(clave.split('|').last),
            '${total.numeroDestilaciones}',
            _numero(total.kgPlanta),
            _numero(total.mlAceite, decimales: 0),
            _numero(total.rendimientoAceiteMedio, decimales: 2),
            _numero(total.litrosHidrolato),
            _numero(total.hidrolatoMedioPorKg, decimales: 2),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('arom.secados'),
      headers: [
        SoleraL10n.t('arom.fecha_inicio'),
        SoleraL10n.t('arom.especie'),
        SoleraL10n.t('arom.metodo_secado'),
        SoleraL10n.t('arom.pdf_dias'),
        SoleraL10n.t('arom.kg_frescos'),
        SoleraL10n.t('arom.kg_secos'),
        SoleraL10n.t('arom.pdf_kg_100'),
        SoleraL10n.t('arom.pdf_orientativo'),
        SoleraL10n.t('arom.pdf_lote'),
      ],
      filas: [
        for (final secado in secados)
          () {
            final orientativo = rendimientoOrientativo(secado.especieId,
                producto: 'planta_seca');
            return [
              formatearFecha(secado.fechaInicioMs),
              nombreEspecie(secado.especieId),
              nombreMetodoSecado(secado.metodo),
              _numero(secado.dias),
              _numero(secado.kgFrescos),
              _numero(secado.kgSecos),
              _numero(secado.rendimientoPorcentaje),
              _intervalo(orientativo?.minimo, orientativo?.maximo),
              codigo(secado.loteProductoId),
            ];
          }(),
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('arom.lotes'),
      headers: [
        SoleraL10n.t('arom.codigo_lote'),
        SoleraL10n.t('arom.pdf_producto'),
        SoleraL10n.t('arom.especie'),
        SoleraL10n.t('arom.fecha'),
        SoleraL10n.t('arom.pdf_cantidad'),
        SoleraL10n.t('arom.pdf_queda'),
        SoleraL10n.t('arom.destino'),
        SoleraL10n.t('arom.trazabilidad'),
      ],
      filas: [
        for (final lote in lotes)
          [
            lote.codigo,
            nombreTipoLote(lote.tipo),
            nombreEspecie(lote.especieId),
            formatearFecha(lote.fechaMs),
            '${_numero(lote.cantidad)} ${lote.unidad}',
            '${_numero(lote.disponible)} ${lote.unidad}',
            nombreDestinoLote(lote.destino),
            textoOrigenLote(origenDeLote(lote,
                secados: datos.secados,
                destilaciones: datos.destilaciones,
                cosechas: datos.cosechas,
                parcelas: datos.parcelas,
                zonas: datos.zonas)),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('arom.sin_lotes'),
    ),
  ];
}

/// Una línea con el origen de un lote: parcelas y zonas (con permiso).
String textoOrigenLote(OrigenLote origen) {
  if (!origen.tieneProceso) return SoleraL10n.t('arom.pdf_lote_a_mano');
  final partes = [
    for (final parcela in origen.parcelas) parcela.nombre,
    for (final zona in origen.zonas)
      zona.tienePermiso
          ? '${zona.nombre} (${zona.numeroPermiso})'
          : '${zona.nombre} (${SoleraL10n.t('arom.sin_permiso_apuntado')})',
  ];
  return partes.isEmpty
      ? SoleraL10n.t('arom.pdf_sin_cosechas_enlazadas')
      : partes.join(', ');
}

extension on String {
  String ifEmpty(String alternativa) => isEmpty ? alternativa : this;
}

/// Libro de destilación y lotes de un año en PDF.
Future<Uint8List> generarLibroDestilacionPdf(DatosLibroDestilacion datos,
    {pw.ThemeData? tema}) {
  final mlAceite = datos.destilaciones.fold<double>(
      0, (suma, destilacion) => suma + destilacion.mlAceiteEsencial);
  final kgPlanta = datos.destilaciones
      .fold<double>(0, (suma, destilacion) => suma + destilacion.kgPlanta);
  final titular = datos.titular;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('arom.libro_destilacion')} · ${datos.anyo}',
    subtituloCabecera: '${_o(titular.nombre)}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'}'
        '${titular.registroSanitario.isEmpty ? '' : ' · ${titular.registroSanitario}'}'
        ' · $selloLibroDestilacion',
    bulletsResumen: [
      SoleraL10n.tf('arom.pdf_total_destilado', {
        'kg': formatearNumero(kgPlanta),
        'ml': formatearNumero(mlAceite, decimales: 0),
      }),
      SoleraL10n.t('arom.pdf_aviso_unidades'),
      SoleraL10n.t('arom.destino_por_verificar'),
      SoleraL10n.t('arom.aviso_documento_provisional'),
    ],
    tablas: tablasLibroDestilacion(datos),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
