import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show temaPdfSolera;
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../datos/catalogo_fitosanitarios.dart';
import '../datos/catalogo_plagas.dart';
import '../modelos/finca.dart';
import '../modelos/incidencia.dart';
import '../modelos/planta.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';

/// Resultado de validar los datos antes de generar el cuaderno. Si
/// `errores` está vacío el PDF puede emitirse; si no, hay que mostrar
/// los problemas al usuario porque el cuaderno no sería válido para
/// inspección.
class ValidacionCuadernoMapa {
  final List<String> errores;
  final List<String> avisos;

  ValidacionCuadernoMapa({this.errores = const [], this.avisos = const []});

  bool get esValido => errores.isEmpty;
}

/// Valida que los datos mínimos están presentes para emitir un
/// Cuaderno de Explotación válido. Reglas v1:
///
/// - El titular debe tener al menos NIF y nombre.
/// - La finca debe tener referencia SIGPAC completa.
/// - Cada tratamiento fitosanitario del periodo debe tener producto +
///   número de registro fitosanitario.
/// - Aviso (no bloqueante) cuando el producto figura en el catálogo
///   curado pero el cultivo de la planta tratada no está entre los
///   autorizados de su registro — caso típico de uso fuera de
///   etiqueta. Requiere atención del agricultor.
ValidacionCuadernoMapa validarDatosCuaderno({
  required Titular titular,
  required Finca? finca,
  required List<Tratamiento> tratamientos,
  Map<int, String> cultivoIdPorPlantaId = const {},
}) {
  final errores = <String>[];
  final avisos = <String>[];

  if (titular.nif.isEmpty || titular.nombre.isEmpty) {
    errores.add('Faltan datos del titular (NIF y nombre son obligatorios). '
        'Configúralos en Ajustes → Datos del titular.');
  }
  if (finca == null) {
    avisos.add('Cuaderno generado sobre puntos sueltos (sin finca). '
        'En inspección puede pedirse la referencia SIGPAC de cada parcela tratada.');
  } else if (finca.referenciaSigpac.isEmpty) {
    errores.add('La finca "${finca.nombre}" no tiene referencia SIGPAC. '
        'Edítala en Ajustes → Fincas y rellena provincia/municipio/polígono/parcela/recinto.');
  }

  final fitosanitariosSinRegistro = <int>[];
  final usosNoAutorizados = <String>[];
  for (final t in tratamientos) {
    if (t.tipo != 'fitosanitario') continue;
    if (t.numeroRegistroFitosanitario.trim().isEmpty || t.producto.trim().isEmpty) {
      if (t.id != null) fitosanitariosSinRegistro.add(t.id!);
      continue;
    }
    final productoCatalogo = _localizarProductoEnCatalogo(t);
    final cultivoId = cultivoIdPorPlantaId[t.plantaId];
    if (productoCatalogo != null &&
        cultivoId != null &&
        !productoCatalogo.autorizadoParaCultivo(cultivoId)) {
      usosNoAutorizados.add(
        '${productoCatalogo.nombreComercialEjemplo} aplicado a '
        '${cultivoPorId(cultivoId).nombreVisible} '
        '(no figura entre los cultivos autorizados de su registro)',
      );
    }
  }
  if (fitosanitariosSinRegistro.isNotEmpty) {
    errores.add('${fitosanitariosSinRegistro.length} tratamiento(s) fitosanitario(s) '
        'sin producto o sin número de registro MAPA. Edítalos antes de generar el cuaderno.');
  }
  for (final aviso in usosNoAutorizados) {
    avisos.add('Posible uso fuera de etiqueta: $aviso. Verifica con la BBDD oficial MAPA.');
  }

  return ValidacionCuadernoMapa(errores: errores, avisos: avisos);
}

/// Localiza un producto del catálogo curado a partir de un
/// tratamiento real. Busca primero por número de registro exacto y,
/// si falla, por nombre comercial (contains, case-insensitive).
ProductoFitosanitario? _localizarProductoEnCatalogo(Tratamiento t) {
  final porRegistro = fitosanitarioPorRegistro(t.numeroRegistroFitosanitario);
  if (porRegistro != null) return porRegistro;
  final nombre = t.producto.trim().toLowerCase();
  if (nombre.isEmpty) return null;
  for (final p in catalogoFitosanitarios) {
    if (p.nombreComercialEjemplo.toLowerCase() == nombre) return p;
  }
  return null;
}

/// Genera el PDF del Cuaderno de Explotación Digital para la finca y
/// año indicados. Estructura siguiendo los apartados del RD 1311/2012:
///
/// 1. Datos del titular, asesor (si aplica) y aplicador (si distinto).
/// 2. Listado de parcelas SIGPAC.
/// 3. Listado de tratamientos fitosanitarios del periodo.
/// 4. Listado de incidencias detectadas (justificación de tratamientos).
///
/// El XML SIEX oficial se difiere — la spec varía por campaña y este
/// PDF cubre el requisito de tener el cuaderno disponible para
/// inspección presencial.
Future<File> generarCuadernoMapa({
  required Finca? finca,
  required int ano,
}) async {
  final db = BaseDatosAgro.instancia;
  final titular = await db.obtenerTitular();
  final desdeMs = DateTime(ano, 1, 1).millisecondsSinceEpoch;
  final hastaMs = DateTime(ano + 1, 1, 1).millisecondsSinceEpoch - 1;

  final tratamientos = await db.listarTratamientosPorFincaYRango(
    fincaId: finca?.id,
    desdeMs: desdeMs,
    hastaMs: hastaMs,
  );
  final plantas = await db.listarPlantas(fincaId: finca?.id);
  final mapaPlantas = {for (final p in plantas) p.id!: p};
  // Antes este bloque era un loop secuencial que con 50+ plantas hacía
  // 50 round-trips contra sqflite y bloqueaba el botón "Generar"
  // varios segundos sin feedback (bug reportado en testeo
  // 2026-05-15: "el botón no funciona / tarda mucho"). Ahora todas
  // las consultas vuelan en paralelo con Future.wait.
  final listas = await Future.wait(
    plantas.map((p) => db.listarIncidenciasDePlanta(p.id!)),
  );
  final incidencias = <Incidencia>[
    for (final lista in listas)
      for (final i in lista)
        if (i.fechaMs >= desdeMs && i.fechaMs <= hastaMs) i,
  ];

  // Tema con Archivo incrustada: Helvetica deja «€» y «—» en blanco.
  final pdf = pw.Document(theme: await temaPdfSolera());
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (_) => _cabecera(finca, ano),
      footer: (ctx) => _piePagina(ctx, titular),
      build: (_) => [
        _seccionTitular(titular),
        if (titular.tieneAsesor) _seccionAsesor(titular),
        if (titular.tieneAplicadorDistinto) _seccionAplicador(titular),
        pw.SizedBox(height: 16),
        _seccionParcelas(finca, plantas),
        pw.SizedBox(height: 16),
        _seccionTratamientos(tratamientos, mapaPlantas, titular),
        pw.SizedBox(height: 16),
        _seccionIncidencias(incidencias, mapaPlantas),
        pw.SizedBox(height: 24),
        _bloqueLegal(),
      ],
    ),
  );

  final dir = await getTemporaryDirectory();
  final ahora = DateTime.now();
  final nombreFinca = (finca?.nombre ?? 'puntos_sueltos').replaceAll(RegExp(r'\s+'), '_');
  final nombre = 'cuaderno_mapa-$nombreFinca-$ano-${ahora.millisecondsSinceEpoch}.pdf';
  final fichero = File(path_lib.join(dir.path, nombre));
  await fichero.writeAsBytes(await pdf.save());
  return fichero;
}

pw.Widget _cabecera(Finca? finca, int ano) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1.5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Cuaderno de Explotación',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Campaña $ano',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Finca: ${finca?.nombre ?? 'Puntos sueltos sin agrupación'}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'RD 1311/2012 sobre uso sostenible de productos fitosanitarios',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

pw.Widget _piePagina(pw.Context ctx, Titular titular) => pw.Container(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            titular.nombre.isEmpty ? '' : '${titular.nombre} · NIF ${titular.nif}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
          pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );

pw.Widget _seccionTitular(Titular t) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _tituloSeccion('1. Titular de la explotación'),
        _filaDato('Nombre / razón social', t.nombre),
        _filaDato('NIF / CIF', t.nif),
        if (t.direccion.isNotEmpty) _filaDato('Dirección', t.direccion),
        if (t.numeroRegepa.isNotEmpty) _filaDato('Número REGEPA', t.numeroRegepa),
        if (t.telefono.isNotEmpty || t.email.isNotEmpty)
          _filaDato('Contacto',
              [t.telefono, t.email].where((s) => s.isNotEmpty).join(' · ')),
      ],
    );

pw.Widget _seccionAsesor(Titular t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _tituloSeccion('2. Asesor agronómico'),
          _filaDato('Nombre', t.nombreAsesor),
          if (t.nifAsesor.isNotEmpty) _filaDato('NIF', t.nifAsesor),
          _filaDato('Número de registro', t.numeroRegistroAsesor),
        ],
      ),
    );

pw.Widget _seccionAplicador(Titular t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _tituloSeccion('3. Aplicador'),
          _filaDato('Nombre', t.nombreAplicador),
          _filaDato('NIF', t.nifAplicador),
          _filaDato('Carnet de manipulador', t.carnetAplicador),
          if (t.nivelCarnetAplicador.isNotEmpty)
            _filaDato('Nivel del carnet', t.nivelCarnetAplicador),
        ],
      ),
    );

pw.Widget _seccionParcelas(Finca? finca, List<Planta> plantas) {
  // Agrupa plantas por cultivo para resumir contenido de la parcela.
  final cultivosCount = <String, int>{};
  for (final p in plantas) {
    cultivosCount[p.cultivoId] = (cultivosCount[p.cultivoId] ?? 0) + 1;
  }
  final resumenCultivos = cultivosCount.entries
      .map((e) => '${cultivoPorId(e.key).nombreVisible} (${e.value})')
      .join(', ');
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSeccion('4. Parcelas'),
      pw.TableHelper.fromTextArray(
        headers: const [
          'Finca',
          'Referencia SIGPAC',
          'Superficie (ha)',
          'Cultivos / nº plantas',
        ],
        data: [
          [
            finca?.nombre ?? 'Puntos sueltos',
            finca?.referenciaSigpac ?? '—',
            finca?.superficieHectareas?.toStringAsFixed(2) ?? '—',
            resumenCultivos.isEmpty ? '—' : resumenCultivos,
          ],
        ],
        cellStyle: const pw.TextStyle(fontSize: 10),
        headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      ),
    ],
  );
}

pw.Widget _seccionTratamientos(
  List<Tratamiento> tratamientos,
  Map<int, Planta> mapaPlantas,
  Titular titular,
) {
  final fitosanitarios = tratamientos.where((t) => t.tipo == 'fitosanitario').toList();
  final otros = tratamientos.where((t) => t.tipo != 'fitosanitario').toList();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSeccion('5. Tratamientos fitosanitarios'),
      if (fitosanitarios.isEmpty)
        pw.Text('Sin tratamientos fitosanitarios registrados en el periodo.',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700))
      else
        pw.TableHelper.fromTextArray(
          headers: const [
            'Fecha',
            'Producto',
            'Nº registro MAPA',
            'Dosis',
            'Plaga / motivo',
            'Sup. ha',
            'Aplicador',
            'Plazo seg.',
          ],
          data: [
            for (final t in fitosanitarios)
              [
                DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs)),
                t.producto,
                t.numeroRegistroFitosanitario,
                t.dosis,
                t.motivo,
                t.superficieTratadaHectareas?.toStringAsFixed(2) ?? '—',
                t.nifAplicador.isEmpty ? titular.nif : t.nifAplicador,
                t.plazoSeguridadDias != null ? '${t.plazoSeguridadDias} d' : '—',
              ],
          ],
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.4),
            1: pw.FlexColumnWidth(2.0),
            2: pw.FlexColumnWidth(1.4),
            3: pw.FlexColumnWidth(1.3),
            4: pw.FlexColumnWidth(2.0),
            5: pw.FlexColumnWidth(0.8),
            6: pw.FlexColumnWidth(1.4),
            7: pw.FlexColumnWidth(0.9),
          },
        ),
      pw.SizedBox(height: 12),
      _tituloSeccion('6. Otros tratamientos (abonado, riego, poda…)'),
      if (otros.isEmpty)
        pw.Text('Sin otros tratamientos registrados en el periodo.',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700))
      else
        pw.TableHelper.fromTextArray(
          headers: const ['Fecha', 'Tipo', 'Producto', 'Dosis', 'Motivo'],
          data: [
            for (final t in otros)
              [
                DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs)),
                t.tipo,
                t.producto,
                t.dosis,
                t.motivo,
              ],
          ],
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        ),
    ],
  );
}

pw.Widget _seccionIncidencias(
  List<Incidencia> incidencias,
  Map<int, Planta> mapaPlantas,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSeccion('7. Incidencias detectadas (justificación de tratamientos)'),
      if (incidencias.isEmpty)
        pw.Text('Sin incidencias registradas en el periodo.',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700))
      else
        pw.TableHelper.fromTextArray(
          headers: const ['Fecha', 'Tipo', 'Diagnóstico', 'Severidad', 'Estado'],
          data: [
            for (final i in incidencias)
              [
                DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(i.fechaMs)),
                i.tipo,
                _diagnosticoConCatalogo(i.diagnostico),
                i.severidad?.toString() ?? '—',
                i.resuelta ? 'Resuelta' : 'Abierta',
              ],
          ],
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        ),
    ],
  );
}

/// Si el diagnóstico de la incidencia coincide con una entrada del
/// catálogo curado de Solera, añade el nombre científico en
/// paréntesis. Esto facilita a la inspección reconocer la plaga sin
/// tener que cruzarlo con la BBDD MAPA.
String _diagnosticoConCatalogo(String diagnosticoLibre) {
  if (diagnosticoLibre.trim().isEmpty) return '—';
  final norm = diagnosticoLibre.toLowerCase();
  for (final p in catalogoPlagas) {
    if (norm.contains(p.nombreComun.toLowerCase())) {
      return '${p.nombreComun} (${p.nombreCientifico})';
    }
  }
  return diagnosticoLibre;
}

pw.Widget _bloqueLegal() => pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5, color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Aviso legal',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(
            'Este documento es una vista del Cuaderno de Explotación generada por la app Solera con los datos '
            'introducidos por el titular en su dispositivo. La responsabilidad sobre la veracidad y completitud de '
            'la información mostrada recae en el titular firmante. La app no envía estos datos a ningún servidor en v1.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );

pw.Widget _tituloSeccion(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
      child: pw.Text(
        texto,
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
    );

pw.Widget _filaDato(String etiqueta, String valor) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(etiqueta,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(valor.isEmpty ? '—' : valor,
                style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
