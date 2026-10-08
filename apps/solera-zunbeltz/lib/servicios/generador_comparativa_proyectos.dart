import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../l10n/app_localizations.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/rentabilidad_proyecto.dart';
import 'documento_generado.dart';
import 'tema_pdf.dart';

/// Fila de la comparativa: un proyecto con su rentabilidad.
typedef FilaComparativa = ({
  ProyectoTest proyecto,
  RentabilidadProyecto rentabilidad
});

/// Comparativa de rentabilidad entre proyectos de test, en PDF. Es la vista
/// de análisis del coordinador (comparable/extrapolable). Sello PROVISIONAL.
Future<DocumentoGenerado> generarComparativaProyectosPdf({
  required AppLocalizations textos,
  required String idioma,
  required List<FilaComparativa> filas,
  bool definitivo = false,
}) async {
  // Ventas + otros ingresos − gastos = balance: si falta una columna, la
  // fila no cuadra a la vista.
  var totalVentas = 0;
  var totalOtrosIngresos = 0;
  var totalGastos = 0;
  var totalBalance = 0;
  for (final f in filas) {
    totalVentas += f.rentabilidad.ingresosComercializacionCentimos;
    totalOtrosIngresos += f.rentabilidad.ingresosApuntesCentimos;
    totalGastos += f.rentabilidad.gastosCentimos;
    totalBalance += f.rentabilidad.balanceCentimos;
  }

  final bytes = await generarInformePeriodicoPdfBytes(
    tema: await temaPdfZunbeltz(),
    marcaAgua: definitivo ? null : textos.marcaBorrador,
    tituloCabecera: textos.comparativaTitulo,
    subtituloCabecera: textos.parteSubtitulo,
    bulletsResumen: [
      textos.parteProvisional,
      '${textos.comparativaColProyecto}: ${filas.length}',
    ],
    tablas: [
      TablaInforme(
        titulo: textos.comparativaTitulo,
        headers: [
          textos.comparativaColProyecto,
          textos.comparativaColTester,
          textos.rentVentas,
          textos.rentOtrosIngresos,
          textos.rentGastos,
          textos.rentBalance,
          textos.rentMargen,
        ],
        mensajeSiVacia: textos.detSinDatos,
        filas: [
          for (final f in filas)
            [
              f.proyecto.nombre,
              f.proyecto.persona,
              eurosDesdeCentimos(
                  f.rentabilidad.ingresosComercializacionCentimos),
              eurosDesdeCentimos(f.rentabilidad.ingresosApuntesCentimos),
              eurosDesdeCentimos(f.rentabilidad.gastosCentimos),
              eurosDesdeCentimos(f.rentabilidad.balanceCentimos),
              '${f.rentabilidad.margenPorcentaje.toStringAsFixed(0)} %',
            ],
          if (filas.isNotEmpty)
            [
              textos.comparativaTotal,
              '',
              eurosDesdeCentimos(totalVentas),
              eurosDesdeCentimos(totalOtrosIngresos),
              eurosDesdeCentimos(totalGastos),
              eurosDesdeCentimos(totalBalance),
              '',
            ],
        ],
      ),
    ],
  );
  return DocumentoGenerado.pdf('comparativa_proyectos', bytes);
}
