import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../l10n/app_localizations.dart';
import '../modelos/balance_convenio.dart';
import '../modelos/constantes.dart';
import '../modelos/convenio.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/registro_actividad.dart';
import '../modelos/registro_comercializacion.dart';
import '../modelos/rentabilidad_proyecto.dart';
import '../modelos/validacion_producto.dart';
import 'documento_generado.dart';

/// Informe de un proyecto de test en PDF: análisis de resultados
/// (rentabilidad) + comercialización + producción + validación y, si se
/// pasan, las cuentas del convenio (balance del test y del proyecto,
/// reparto, previsto frente a real, fianza, indicadores del anexo IV e
/// incidencias). Reutiliza el informe periódico del core. Sello
/// PROVISIONAL y, salvo [definitivo], marca de agua BORRADOR.
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
  BalanceConvenio? balance,
  EstadoFianza? fianza,
  IndicadoresAcompanamiento? indicadores,
  List<IncidenciaCumplimiento> incidencias = const [],
  bool definitivo = false,
}) async {
  final formatoFecha = DateFormat('dd/MM/yyyy', idioma);
  String fecha(int ms) => ms == 0
      ? '—'
      : formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(ms));
  String etiqueta(List<OpcionCatalogo> cat, String cod) =>
      buscarOpcion(cat, cod)?.etiqueta(idioma) ?? cod;
  String euros(int c) => '${eurosDesdeCentimos(c)} €';

  final bytes = await generarInformePeriodicoPdfBytes(
    tituloCabecera: textos.infProyTitulo,
    subtituloCabecera: textos.parteSubtitulo,
    marcaAgua: definitivo ? null : textos.marcaBorrador,
    bulletsResumen: [
      textos.parteProvisional,
      if (!definitivo) textos.informeBorradorAviso,
      textos.infProyResumen(proyecto.nombre, proyecto.persona),
      '${textos.rentVentas}: ${euros(rentabilidad.ingresosComercializacionCentimos)}',
      '${textos.rentOtrosIngresos}: ${euros(rentabilidad.ingresosApuntesCentimos)}',
      '${textos.rentGastos}: ${euros(rentabilidad.gastosCentimos)}',
      '${textos.rentBalance}: ${euros(rentabilidad.balanceCentimos)} (${textos.rentMargen} ${rentabilidad.margenPorcentaje.toStringAsFixed(0)} %)',
      if (ivaSoportadoCentimos != 0 || ivaRepercutidoCentimos != 0) ...[
        '${textos.detIvaSoportado}: ${euros(ivaSoportadoCentimos)} · ${textos.detIvaRepercutido}: ${euros(ivaRepercutidoCentimos)}',
        textos.ivaNoFiscal,
      ],
      if (balance != null) ...[
        '${textos.balanceTest}: ${euros(balance.balanceTestCentimos)} · ${textos.balanceProyecto}: ${euros(balance.balanceProyectoCentimos)}',
        '${textos.balanceAsumeTester}: ${euros(balance.gastosAsumidosTesterCentimos)} · ${textos.balanceAsumeZunbeltz}: ${euros(balance.gastosAsumidosZunbeltzCentimos)}',
        '${textos.balanceReparto} (${balance.hayBeneficio ? textos.balanceBeneficio : textos.balancePerdida}): ${textos.balanceParteZunbeltz} ${euros(balance.parteZunbeltzCentimos)} · ${textos.balanceParteTester} ${euros(balance.parteTesterCentimos)}',
        textos.convenioProvisional,
      ],
      if (fianza != null)
        '${textos.convenioFianza}: ${textos.fianzaDepositado} ${euros(fianza.depositadoCentimos)} · ${textos.fianzaRetenido} ${euros(fianza.retenidoCentimos)} · ${textos.fianzaPendiente} ${euros(fianza.pendienteCentimos)}',
    ],
    tablas: [
      if (balance != null && balance.categoriasComparadas.isNotEmpty)
        TablaInforme(
          titulo: textos.balancePrevistoReal,
          headers: [
            textos.apuCategoria,
            textos.balancePrevisto,
            textos.balanceReal
          ],
          filas: [
            for (final categoria in balance.categoriasComparadas)
              [
                etiqueta(categoriasGasto, categoria),
                eurosDesdeCentimos(
                    balance.previstoPorCategoria[categoria] ?? 0),
                eurosDesdeCentimos(balance.realPorCategoria[categoria] ?? 0),
              ],
          ],
        ),
      if (indicadores != null)
        TablaInforme(
          titulo: textos.acompanamientoIndicadores(indicadores.meses),
          headers: [textos.convenioTipo, textos.acompanamientoAsistencia],
          filas: [
            for (final tipo in tiposAcompanamiento)
              if (indicadores.propuestasDe(tipo.codigo) > 0)
                [
                  tipo.etiqueta(idioma),
                  textos.acompanamientoAsistidas(
                      indicadores.asistidasDe(tipo.codigo),
                      indicadores.propuestasDe(tipo.codigo)),
                ],
          ],
        ),
      if (incidencias.isNotEmpty)
        TablaInforme(
          titulo: textos.convenioIncidencias,
          headers: [
            textos.incidenciaNivel,
            textos.convenioDescripcion,
            textos.incidenciaRetencion,
            textos.comunFecha,
          ],
          filas: [
            for (final incidencia in incidencias)
              [
                etiqueta(nivelesIncidencia, incidencia.nivel),
                incidencia.descripcion,
                eurosDesdeCentimos(incidencia.retencionCentimos),
                fecha(incidencia.fechaMs),
              ],
          ],
        ),
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
