import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/backup_servicio.dart';

/// Texto para la persona según el motivo del error. Solo dice que los
/// datos no se han tocado cuando es verdad ([ErrorCopiaSeguridad.datosIntactos]).
String textoErrorCopiaSeguridad(ErrorCopiaSeguridad error, {bool alRestaurar = true}) {
  final String causa;
  switch (error.motivo) {
    case MotivoErrorCopiaSeguridad.ficheroNoExiste:
      causa = 'El fichero elegido no existe.';
    case MotivoErrorCopiaSeguridad.noEsZip:
      causa = 'El fichero no es un zip legible o está dañado.';
    case MotivoErrorCopiaSeguridad.manifiestoNoValido:
      causa = 'El backup está incompleto o dañado.';
    case MotivoErrorCopiaSeguridad.formatoMasNuevo:
    case MotivoErrorCopiaSeguridad.esquemaMasNuevo:
      causa = 'El backup es de una versión más nueva de Larrea. Actualiza la app y vuelve a intentarlo.';
    case MotivoErrorCopiaSeguridad.deOtraApp:
      causa = 'El backup es de otra aplicación, no de Larrea.';
    case MotivoErrorCopiaSeguridad.sinBaseDatos:
      causa = 'El zip no contiene la base de datos de Larrea (agro.db).';
    case MotivoErrorCopiaSeguridad.baseDatosNoValida:
    case MotivoErrorCopiaSeguridad.integridadFallida:
      causa = 'La base de datos del backup está dañada.';
    case MotivoErrorCopiaSeguridad.rutaPeligrosa:
      causa = 'El zip contiene rutas no permitidas.';
    case MotivoErrorCopiaSeguridad.respaldoPrevioFallido:
      causa = 'No se pudo guardar antes una copia del estado actual (¿falta espacio?).';
    case MotivoErrorCopiaSeguridad.sinDatosQueCopiar:
      causa = 'Todavía no hay datos que copiar.';
    case MotivoErrorCopiaSeguridad.restauracionRevertida:
      causa = 'La restauración falló a mitad y se ha vuelto al estado anterior.';
    case MotivoErrorCopiaSeguridad.reversionFallida:
      final respaldo = error.respaldoPrevio;
      return 'La restauración falló y no se pudo volver atrás del todo. '
          '${respaldo != null ? 'Tu estado anterior está en ${respaldo.path}. ' : ''}'
          'No borres la app y escríbenos. Detalle: ${error.mensaje}';
  }
  if (!alRestaurar) return 'No se pudo crear el backup. $causa';
  return error.datosIntactos ? '$causa Tus datos no se han tocado.' : causa;
}

/// Pantalla de backup/restore. Operaciones lentas (segundos) y
/// destructivas — UI explícita con confirmaciones para que el usuario
/// nunca pierda datos por accidente.
class PantallaBackup extends StatefulWidget {
  PantallaBackup({super.key});

  @override
  State<PantallaBackup> createState() => _PantallaBackupState();
}

class _PantallaBackupState extends State<PantallaBackup> {
  bool _trabajando = false;
  DateTime? _ultimoBackup;

  @override
  void initState() {
    super.initState();
    _cargarUltimoBackup();
  }

  Future<void> _cargarUltimoBackup() async {
    final ultimaCopia = await servicioCopiaSeguridadAgro.ultimaCopia();
    if (mounted) setState(() => _ultimoBackup = ultimaCopia);
  }

  void _avisar(String mensaje, {int segundos = 6}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: Duration(seconds: segundos), content: Text(mensaje)),
    );
  }

  Future<void> _crearYCompartir() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await servicioCopiaSeguridadAgro.crearCopia();
      await _cargarUltimoBackup();
      if (!mounted) return;
      await Share.shareXFiles([XFile(fichero.path)], subject: 'Backup Larrea');
    } on ErrorCopiaSeguridad catch (error) {
      if (!mounted) return;
      _avisar(textoErrorCopiaSeguridad(error, alRestaurar: false), segundos: 8);
    } catch (error) {
      if (!mounted) return;
      _avisar('No se pudo crear el backup: $error', segundos: 8);
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _restaurar() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (resultado == null || resultado.files.isEmpty) return;
    final ruta = resultado.files.first.path;
    if (ruta == null) return;
    final copia = File(ruta);

    // Primero se comprueba la copia sin tocar nada, para enseñar de
    // cuándo es antes de pedir confirmación.
    setState(() => _trabajando = true);
    final InformeCopiaSeguridad informe;
    try {
      informe = await servicioCopiaSeguridadAgro.validarCopia(copia);
    } on ErrorCopiaSeguridad catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar(textoErrorCopiaSeguridad(error), segundos: 8);
      }
      return;
    } catch (error) {
      if (mounted) {
        setState(() => _trabajando = false);
        _avisar('No se pudo leer el backup: $error. No se ha tocado nada.', segundos: 8);
      }
      return;
    }
    if (!mounted) return;
    setState(() => _trabajando = false);

    final fechaCopia = informe.fechaCreacion;
    final descripcionCopia = fechaCopia != null
        ? 'Backup del ${DateFormat("d 'de' MMMM 'de' yyyy 'a las' HH:mm", 'es_ES').format(fechaCopia)}'
        : 'Backup sin fecha (hecho con una versión anterior de Larrea; '
            'fecha del fichero: ${DateFormat('d/M/yyyy HH:mm', 'es_ES').format(copia.lastModifiedSync())})';
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Restaurar desde un backup',
      mensaje: '$descripcionCopia, con ${informe.numeroFicherosExtra} fotos.\n\n'
          'Se sustituirán la base de datos y las fotos actuales por las del backup. '
          'Antes se guarda automáticamente una copia del estado actual en el dispositivo.',
      textoConfirmar: 'Restaurar',
      textoCancelar: 'Cancelar',
      icono: Icons.restore,
    );
    if (confirmado != true || !mounted) return;

    setState(() => _trabajando = true);
    try {
      await servicioCopiaSeguridadAgro.restaurarCopia(copia);
      if (!mounted) return;
      _avisar(
        'Backup restaurado. El estado anterior queda guardado como copia automática en el dispositivo.',
        segundos: 8,
      );
    } on ErrorCopiaSeguridad catch (error) {
      if (!mounted) return;
      _avisar(textoErrorCopiaSeguridad(error), segundos: 10);
    } catch (error) {
      if (!mounted) return;
      _avisar('Error restaurando: $error', segundos: 10);
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _ultimoBackup;
    final hace = ultimo == null ? null : DateTime.now().difference(ultimo);
    return Scaffold(
      appBar: AppBar(title: Text('Backup y restauración')),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      ultimo == null ? Icons.warning_amber : (hace != null && hace.inDays > 7 ? Icons.error_outline : Icons.check_circle),
                      color: ultimo == null ? Colors.orange : (hace != null && hace.inDays > 7 ? Colors.red : Colors.green),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Último backup', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimo == null
                                ? 'Nunca — recomendado hacer uno antes de salir al campo.'
                                : DateFormat("d 'de' MMMM 'de' yyyy 'a las' HH:mm", 'es_ES').format(ultimo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('Crear backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Empaqueta la base de datos y todas las fotos en un zip que puedes compartir por WhatsApp, Drive, correo o copiar al PC. Si reinstalas la app o cambias de móvil podrás restaurar desde aquí.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            FilledButton.icon(
              icon: Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? 'Empaquetando…' : 'Crear backup y compartir'),
            ),
            Divider(height: 32),
            Text('Restaurar desde backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Sustituye la base de datos y fotos actuales por las del zip. Antes se comprueba que el zip es un backup válido de Larrea y se guarda una copia automática del estado actual.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text('Restaurar zip'),
            ),
          ],
        ),
      ),
    );
  }
}
