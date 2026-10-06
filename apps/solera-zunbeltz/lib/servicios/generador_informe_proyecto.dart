import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/registro_actividad.dart';
import '../modelos/registro_comercializacion.dart';
import '../modelos/rentabilidad_proyecto.dart';
import '../modelos/validacion_producto.dart';
import 'documento_generado.dart';

/// Informe de un proyecto de test en PDF: análisis de resultados
/// (rentabilidad) + comercialización + producción + validación. Reutiliza el
/// informe periódico del core. Sello PROVISIONAL.
Future<DocumentoGenerado> generarInformeProyectoPdf({
  required AppLocalizations textos,
  required String idioma,
  required ProyectoTest proyecto,
  required RentabilidadProyecto rentabilidad,
  required List<RegistroComercializacion> comercializacion,
  required List<ValidacionProducto> validaciones,
  required List<RegistroActividad> actividades,
  Map<String, int> desgloseGastos = const {},
  int ivaSoportadoCentimos = 0,
  int ivaRepercutidoCentimos = 0,
}) async {
  final formatoFecha = DateFormat('dd/MM/yyyy', idioma);
  String fecha(int ms) =>
      ms == 0 ? '—' : formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(ms));
  String etiqueta(List<OpcionCatalogo> cat, String cod) =>
      buscarOpcion(cat, cod)?.etiqueta(idioma) ?? cod;
  String euros(int c) => '${eurosDesdeCentimos(c)} €';

  final bytes = await generarInformePeriodicoPdfBytes(
    tituloCabecera: textos.infProyTitulo,
    subtituloCabecera: textos.parteSubtitulo,
    bulletsResumen: [
      textos.parteProvisional,
      textos.infProyResumen(proyecto.nombre, proyecto.persona),
      '${textos.rentVentas}: ${euros(rentabilidad.ingresosComercializacionCentimos)}',
      '${textos.rentOtrosIngresos}: ${euros(rentabilidad.ingresosApuntesCentimos)}',
      '${textos.rentGastos}: ${euros(rentabilidad.gastosCentimos)}',
      '${textos.rentBalance}: ${euros(rentabilidad.balanceCentimos)} (${textos.rentMargen} ${rentabilidad.margenPorcentaje.toStringAsFixed(0)} %)',
      if (ivaSoportadoCentimos != 0 || ivaRepercutidoCentimos != 0) ...[
        '${textos.detIvaSoportado}: ${euros(ivaSoportadoCentimos)} · ${textos.detIvaRepercutido}: ${euros(ivaRepercutidoCentimos)}',
        textos.ivaNoFiscal,
      ],
    ],
    tablas: [
      TablaInforme(
        titulo: textos.detDesgloseGastos,
        headers: [textos.apuCategoria, textos.rentGastos],
        filas: [
          for (final e in desgloseGastos.entries)
            [
              buscarOpcion(categoriasGasto, e.key)?.etiqueta(idioma) ??
                  (e.key.isEmpty ? '—' : e.key),
              eurosDesdeCentimos(e.value),
            ],
        ],
      ),
      TablaInforme(
        titulo: textos.detComercial,
        headers: [
          textos.comProducto,
          textos.comCanal,
          textos.comCantidad,
          textos.comIngreso,
          textos.comunFecha,
        ],
        mensajeSiVacia: textos.detSinDatos,
        filas: [
          for (final c in comercializacion)
            [
              c.producto,
              etiqueta(canalesComercializacion, c.canal),
              '${cantidadBonita(c.cantidad)} ${c.unidad}',
              eurosDesdeCentimos(c.ingresoCentimos),
              fecha(c.fechaMs),
            ],
        ],
      ),
      TablaInforme(
        titulo: textos.detProduccion,
        headers: [
          textos.actTipo,
          textos.actCantidad,
          textos.comunFecha,
        ],
        mensajeSiVacia: textos.detSinDatos,
        filas: [
          for (final a in actividades)
            [
              etiqueta(tiposActividad, a.tipo),
              '${cantidadBonita(a.cantidad)} ${unidadActividad(a.tipo, idioma)}',
              fecha(a.fechaMs),
            ],
        ],
      ),
      TablaInforme(
        titulo: textos.detValidacion,
        headers: [
          textos.valDescripcion,
          textos.valResultado,
          textos.valValoracion,
          textos.comunFecha,
        ],
        mensajeSiVacia: textos.detSinDatos,
        filas: [
          for (final v in validaciones)
            [
              v.descripcion,
              etiqueta(resultadosValidacion, v.resultado),
              v.valoracion == 0 ? '—' : '${v.valoracion}/5',
              fecha(v.fechaMs),
            ],
        ],
      ),
    ],
  );
  return DocumentoGenerado.pdf('informe_proyecto', bytes);
}
