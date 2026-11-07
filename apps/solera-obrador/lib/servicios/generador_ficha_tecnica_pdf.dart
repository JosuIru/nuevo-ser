import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/composicion_receta.dart';
import '../modelos/ingrediente.dart';
import '../modelos/receta.dart';
import '../modelos/titular.dart';
import '../utiles/textos_obrador.dart';

/// Sello de la ficha técnica y del cartel de alérgenos hasta la validación
/// humana. Lo vigila test/sello_provisional_test.dart.
const String selloFichaTecnica = 'PROVISIONAL';

/// Lista de ingredientes para la etiqueta: de más a menos peso, con los que
/// contienen alérgenos en MAYÚSCULAS (el reglamento pide destacarlos; la
/// tabla del PDF no admite negrita).
String listaIngredientesEtiqueta(
    ComposicionReceta composicion, Map<int, Ingrediente> ingredientes) {
  return composicion.ingredientesPorPeso.map((id) {
    final ingrediente = ingredientes[id]!;
    return ingrediente.alergenos.isEmpty
        ? ingrediente.nombre
        : ingrediente.nombre.toUpperCase();
  }).join(', ');
}

/// Tablas de la ficha técnica de una receta.
List<TablaInforme> tablasFichaTecnica(
    ComposicionReceta composicion, Map<int, Ingrediente> ingredientes) {
  final masa = composicion.gramosMasa;
  return [
    TablaInforme(
      titulo: SoleraL10n.t('obra.ingredientes_por_peso'),
      headers: [
        SoleraL10n.t('obra.ingrediente'),
        '%',
        SoleraL10n.t('obra.alergenos')
      ],
      filas: [
        for (final id in composicion.ingredientesPorPeso)
          [
            ingredientes[id]!.nombre,
            masa == 0
                ? ''
                : formatearNumero(
                    composicion.gramosPorIngrediente[id]! / masa * 100),
            ingredientes[id]!.alergenos.map(nombreAlergeno).join(', '),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('obra.datos_producto'),
      headers: [SoleraL10n.t('obra.dato'), SoleraL10n.t('obra.valor')],
      filas: [
        [
          SoleraL10n.t('obra.peso_pieza'),
          '${formatearNumero(composicion.gramosPorPieza, decimales: 0)} g'
        ],
        [
          SoleraL10n.t('obra.sal_estimada'),
          '${formatearNumero(composicion.salEstimadaGramosPor100g, decimales: 2)} g / 100 g'
        ],
      ],
    ),
  ];
}

/// Ficha técnica de una receta en PDF.
Future<Uint8List> generarFichaTecnicaPdf({
  required Receta receta,
  required ComposicionReceta composicion,
  required Map<int, Ingrediente> ingredientes,
  required Titular titular,
  pw.ThemeData? tema,
}) {
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('obra.ficha_tecnica')} · ${receta.nombre}',
    subtituloCabecera: '${titular.nombre} · $selloFichaTecnica',
    bulletsResumen: [
      '${SoleraL10n.t('obra.ingredientes')}: ${listaIngredientesEtiqueta(composicion, ingredientes)}',
      '${SoleraL10n.t('obra.alergenos')}: ${composicion.alergenos.isEmpty ? SoleraL10n.t('obra.sin_alergenos') : composicion.alergenos.map(nombreAlergeno).join(', ')}',
      if (composicion.trazas.isNotEmpty)
        '${SoleraL10n.t('obra.trazas')}: ${composicion.trazas.map(nombreAlergeno).join(', ')}',
      SoleraL10n.t('obra.aviso_estimacion'),
      SoleraL10n.t('obra.aviso_documento_provisional'),
    ],
    tablas: tablasFichaTecnica(composicion, ingredientes),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}

/// Filas del cartel de alérgenos del mostrador: producto, contiene, puede contener.
List<List<String>> filasCartelAlergenos(
        Map<Receta, ComposicionReceta> productos) =>
    [
      for (final MapEntry(key: receta, value: composicion) in productos.entries)
        [
          receta.nombre,
          composicion.alergenos.isEmpty
              ? '—'
              : composicion.alergenos.map(nombreAlergeno).join(', '),
          composicion.trazas.isEmpty
              ? ''
              : composicion.trazas.map(nombreAlergeno).join(', '),
        ],
    ];

/// Cartel de alérgenos de todos los productos a la venta.
Future<Uint8List> generarCartelAlergenosPdf({
  required Map<Receta, ComposicionReceta> productos,
  required Titular titular,
  pw.ThemeData? tema,
}) {
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: SoleraL10n.t('obra.cartel_alergenos'),
    subtituloCabecera: '${titular.nombre} · $selloFichaTecnica',
    bulletsResumen: [
      SoleraL10n.t('obra.cartel_alergenos_explicacion'),
      SoleraL10n.t('obra.aviso_estimacion'),
    ],
    tablas: [
      TablaInforme(
        titulo: SoleraL10n.t('obra.productos'),
        headers: [
          SoleraL10n.t('obra.producto'),
          SoleraL10n.t('obra.contiene'),
          SoleraL10n.t('obra.trazas'),
        ],
        filas: filasCartelAlergenos(productos),
        mensajeSiVacia: SoleraL10n.t('obra.sin_recetas'),
      ),
    ],
    tema: tema,
  );
}
