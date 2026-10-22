import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/ganado.dart';
import '../servicios/documento_generado.dart';
import '../servicios/exportar_ganado.dart';
import '../utiles/importar_animales.dart';
import '../utiles/leer_tabla.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Columna de la hoja que corresponde a cada campo de la tabla `animales`
/// (para decir qué cambia al actualizar).
const Map<String, ColumnaAnimal> _columnaDeCampo = {
  'nombre': ColumnaAnimal.nombre,
  'especie': ColumnaAnimal.especie,
  'raza': ColumnaAnimal.raza,
  'sexo': ColumnaAnimal.sexo,
  'fecha_nacimiento_ms': ColumnaAnimal.nacimiento,
  'madre': ColumnaAnimal.madre,
  'lote_id': ColumnaAnimal.rebano,
  'estado': ColumnaAnimal.estado,
  'fecha_baja_ms': ColumnaAnimal.fechaBaja,
  'notas': ColumnaAnimal.notas,
};

/// El texto de un problema de una fila.
String textoProblemaImportacion(
    ProblemaImportacion problema, AppLocalizations textos, String idioma) {
  final columna = problema.columna == null
      ? ''
      : cabeceraColumnaAnimal(problema.columna!, idioma);
  return switch (problema.motivo) {
    MotivoImportacion.crotalVacio => textos.ganImpCrotalVacio,
    MotivoImportacion.crotalNumeroExcel =>
      textos.ganImpCrotalNumeroExcel(problema.valor),
    MotivoImportacion.crotalRepetido => textos.ganImpCrotalRepetido,
    MotivoImportacion.fechaNoValida =>
      textos.ganImpFechaNoValida(columna, problema.valor),
    MotivoImportacion.nacimientoFuturo => textos.ganImpNacimientoFuturo,
    MotivoImportacion.bajaAntesDeNacimiento =>
      textos.ganImpBajaAntesDeNacimiento,
    MotivoImportacion.especieDesconocida =>
      textos.ganImpEspecieDesconocida(problema.valor),
    MotivoImportacion.sexoDesconocido =>
      textos.ganImpSexoDesconocido(problema.valor),
    MotivoImportacion.estadoDesconocido =>
      textos.ganImpEstadoDesconocido(problema.valor),
    MotivoImportacion.rebanoDesconocido =>
      textos.ganImpRebanoDesconocido(problema.valor),
    MotivoImportacion.sinPermisoAlta => textos.ganImpSinPermisoAlta,
    MotivoImportacion.sinPermisoFicha => textos.ganImpSinPermisoFicha,
    MotivoImportacion.avisoCrotalNoOficial => textos.ganImpAvisoCrotalNoOficial,
    MotivoImportacion.avisoCeroRecuperado => textos.ganImpAvisoCeroRecuperado,
  };
}

/// Importar animales desde un CSV o un Excel: elegir el fichero, ver qué
/// pasará con cada fila y guardar. Lo guardado sincroniza como cualquier
/// alta o cambio hecho a mano.
class PantallaImportarAnimales extends StatefulWidget {
  const PantallaImportarAnimales({super.key});

  @override
  State<PantallaImportarAnimales> createState() =>
      _PantallaImportarAnimalesState();
}

class _PantallaImportarAnimalesState extends State<PantallaImportarAnimales> {
  final _bd = BaseDatosSoleraZunbeltz();
  String? _nombreFichero;
  AnalisisImportacion? _analisis;
  String? _error;
  bool _leyendo = false;
  bool _guardando = false;

  Future<void> _elegirFichero() async {
    final textos = AppLocalizations.of(context);
    final elegido =
        await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    final fichero = elegido?.files.singleOrNull;
    final bytes = fichero?.bytes;
    if (fichero == null || bytes == null || !mounted) return;
    setState(() {
      _leyendo = true;
      _error = null;
      _analisis = null;
      _nombreFichero = fichero.name;
    });
    try {
      final tabla = leerTablaDeFichero(fichero.name, bytes);
      final analisis = analizarImportacionAnimales(
        tabla: tabla,
        existentes: await _bd.listarAnimales(),
        lotes: await _bd.listarLotes(),
        politica: politicaEspacioActual,
        hoy: DateTime.now(),
      );
      if (!mounted) return;
      setState(() {
        _analisis = analisis;
        if (!analisis.sinColumnaCrotal && analisis.filas.isEmpty) {
          _error = textos.ganImportarVacio;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _error = textos.ganImportarNoLegible);
    } finally {
      if (mounted) setState(() => _leyendo = false);
    }
  }

  Future<void> _descargarPlantilla() async {
    final idioma = Localizations.localeOf(context).languageCode;
    final plantilla = plantillaImportacionAnimales(idioma);
    try {
      await compartirDocumentos([plantilla]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(plantilla.nombreFichero)));
      }
    }
  }

  Future<void> _guardar() async {
    final analisis = _analisis;
    if (analisis == null || _guardando) return;
    final textos = AppLocalizations.of(context);
    setState(() => _guardando = true);
    var guardados = 0;
    try {
      for (final fila in analisis.aCrear) {
        await _bd.guardarAnimal(Animal.fromMap(fila.datos));
        guardados++;
      }
      for (final fila in analisis.aActualizar) {
        await _bd.actualizarAnimal(fila.existente!.id!, fila.datos);
        guardados++;
      }
    } finally {
      if (guardados > 0) avisarCambioDatos();
      if (mounted) setState(() => _guardando = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.ganImportarGuardado(guardados))));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final analisis = _analisis;
    final aGuardar = analisis == null
        ? 0
        : analisis.aCrear.length + analisis.aActualizar.length;
    return Scaffold(
      appBar: AppBar(title: Text(textos.ganImportar)),
      body: CuerpoResponsivo(
        maxAncho: 720,
        child: ListView(
          padding: rellenoSobreBarraSistema(
              context, const EdgeInsets.fromLTRB(16, 12, 16, 96)),
          children: [
            Text(textos.ganImportarIntro),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                onPressed: _leyendo || _guardando ? null : _elegirFichero,
                icon: const Icon(Icons.upload_file),
                label: Text(textos.ganImportarElegir),
              ),
              OutlinedButton.icon(
                onPressed: _descargarPlantilla,
                icon: const Icon(Icons.download_outlined),
                label: Text(textos.ganImportarPlantilla),
              ),
            ]),
            if (_nombreFichero != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(textos.ganImportarFichero(_nombreFichero!),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            if (_leyendo)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null) _avisoError(_error!),
            if (analisis != null && analisis.sinColumnaCrotal)
              _avisoError(textos.ganImportarSinCrotal),
            if (analisis != null && analisis.columnasIgnoradas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                    textos.ganImportarIgnoradas(
                        analisis.columnasIgnoradas.join(', ')),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            if (analisis != null && !analisis.sinColumnaCrotal) ...[
              _seccion(textos.ganImportarSeccionErrores(analisis.conErrores.length),
                  analisis.conErrores, Icons.error_outline, textos, idioma,
                  abierta: true, error: true),
              _seccion(textos.ganImportarSeccionCrear(analisis.aCrear.length),
                  analisis.aCrear, Icons.add_circle_outline, textos, idioma,
                  abierta: analisis.conErrores.isEmpty),
              _seccion(
                  textos.ganImportarSeccionActualizar(
                      analisis.aActualizar.length),
                  analisis.aActualizar,
                  Icons.edit_outlined,
                  textos,
                  idioma),
              _seccion(
                  textos.ganImportarSeccionIguales(analisis.sinCambios.length),
                  analisis.sinCambios,
                  Icons.check_circle_outline,
                  textos,
                  idioma),
            ],
          ],
        ),
      ),
      floatingActionButton: aGuardar == 0
          ? null
          : FloatingActionButton.extended(
              heroTag: 'importar_animales',
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(textos.ganImportarGuardar(aGuardar)),
            ),
    );
  }

  Widget _avisoError(String texto) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      color: esquema.errorContainer,
      child: ListTile(
        iconColor: esquema.onErrorContainer,
        textColor: esquema.onErrorContainer,
        leading: const Icon(Icons.warning_amber_outlined),
        title: Text(texto),
      ),
    );
  }

  Widget _seccion(String titulo, List<FilaImportacion> filas, IconData icono,
      AppLocalizations textos, String idioma,
      {bool abierta = false, bool error = false}) {
    if (filas.isEmpty) return const SizedBox.shrink();
    final esquema = Theme.of(context).colorScheme;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: abierta,
      leading: Icon(icono, color: error ? esquema.error : null),
      title: Text(titulo),
      children: [
        for (final fila in filas.take(500))
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 8),
            title: Text([
              textos.ganImportarFila(fila.numeroFila),
              if (fila.identificacion.isNotEmpty) fila.identificacion,
              if (fila.existente?.nombre.isNotEmpty ?? false)
                fila.existente!.nombre
              else if ((fila.datos['nombre'] as String?)?.isNotEmpty ?? false)
                fila.datos['nombre'] as String,
            ].join(' · ')),
            subtitle: _detalleFila(fila, textos, idioma),
          ),
      ],
    );
  }

  Widget? _detalleFila(
      FilaImportacion fila, AppLocalizations textos, String idioma) {
    final lineas = [
      for (final problema in fila.errores)
        textoProblemaImportacion(problema, textos, idioma),
      if (fila.accion == AccionImportacion.actualizar)
        textos.ganImportarCambia({
          for (final campo in fila.datos.keys)
            if (_columnaDeCampo[campo] case final columna?)
              cabeceraColumnaAnimal(columna, idioma),
        }.join(', ')),
      for (final aviso in fila.avisos)
        textoProblemaImportacion(aviso, textos, idioma),
    ];
    if (lineas.isEmpty) return null;
    return Text(lineas.join('\n'),
        style: fila.accion == AccionImportacion.error
            ? TextStyle(color: Theme.of(context).colorScheme.error)
            : null);
  }
}
