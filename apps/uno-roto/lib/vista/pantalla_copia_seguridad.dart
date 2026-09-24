import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/dibujos_taller.dart';
import '../datos/exportador_progreso.dart';
import '../datos/repositorio_progreso.dart';
import '../nucleo/paleta.dart';

/// Pantalla de copia de seguridad del progreso del perfil activo.
/// Permite exportar a JSON (para guardar fuera de la app) e importar
/// desde JSON (para restaurar tras una reinstalación o cambio de
/// dispositivo). Sin dependencias externas: el JSON viaja por el
/// portapapeles del sistema — el adulto lo pega en notas, mail o
/// Drive y luego lo trae de vuelta a la app.
///
/// Se introdujo el 2026-05-19 tras el incidente de instalación que
/// dejó al tester sin progresos. Sin sync activa al backend, era la
/// única forma de no perderlos. Cuando la sync esté cableada para
/// cuentas familiares completas, esta pantalla seguirá siendo útil
/// para backups manuales antes de cambios mayores.
class PantallaCopiaSeguridad extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PantallaCopiaSeguridad({super.key, required this.repositorio});

  @override
  State<PantallaCopiaSeguridad> createState() => _PantallaCopiaSeguridadState();
}

class _PantallaCopiaSeguridadState extends State<PantallaCopiaSeguridad> {
  final TextEditingController _controladorImport = TextEditingController();
  String? _jsonExportado;
  bool _trabajando = false;
  String? _idPerfil;

  @override
  void initState() {
    super.initState();
    _cargarIdPerfil();
  }

  Future<void> _cargarIdPerfil() async {
    final id = await widget.repositorio.idPerfilActivo();
    if (!mounted) return;
    setState(() => _idPerfil = id);
  }

  @override
  void dispose() {
    _controladorImport.dispose();
    super.dispose();
  }

  Future<void> _exportar() async {
    setState(() => _trabajando = true);
    try {
      final exportador = ExportadorProgreso(widget.repositorio);
      final json = await exportador.exportarPerfilActivoComoJson();
      if (!mounted) return;
      setState(() => _jsonExportado = json);
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _copiarAlPortapapeles() async {
    final json = _jsonExportado;
    if (json == null) return;
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PaletaNeon.fondoMedio,
        duration: const Duration(seconds: 3),
        content: const Text(
          'JSON copiado al portapapeles. Pégalo en notas, mail o '
          'Drive para guardarlo fuera del dispositivo.',
          style: TextStyle(color: PaletaNeon.textoPrincipal),
        ),
      ),
    );
  }

  Future<void> _importar() async {
    final json = _controladorImport.text.trim();
    if (json.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: PaletaNeon.fondoMedio,
          content: Text(
            'Pega primero un JSON de copia de seguridad.',
            style: TextStyle(color: PaletaNeon.textoPrincipal),
          ),
        ),
      );
      return;
    }
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        title: const Text(
          '¿Importar copia de seguridad?',
          style: TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 16),
        ),
        content: Text(
          'Esto reemplazará TODO el progreso del perfil activo'
          '${_idPerfil != null ? " ($_idPerfil)" : ""}. Los datos '
          'actuales se perderán. Los demás perfiles no se tocan.',
          style: const TextStyle(color: PaletaNeon.textoTenue, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: PaletaNeon.textoTenue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'IMPORTAR',
              style: TextStyle(color: PaletaNeon.violetaNeon),
            ),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _trabajando = true);
    try {
      final exportador = ExportadorProgreso(widget.repositorio);
      final cuantas = await exportador.importarPerfilActivoDesdeJson(json);
      if (!mounted) return;
      _controladorImport.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PaletaNeon.fondoMedio,
          duration: const Duration(seconds: 5),
          content: Text(
            'Restauradas $cuantas entradas. Reinicia la app para que '
            'todos los cambios se apliquen.',
            style: const TextStyle(color: PaletaNeon.textoPrincipal),
          ),
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PaletaNeon.fondoMedio,
          duration: const Duration(seconds: 6),
          content: Text(
            'No se pudo importar: ${e.message}',
            style: const TextStyle(color: PaletaNeon.textoPrincipal),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoProfundo,
        title: const Text(
          'COPIA DE SEGURIDAD',
          style: TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 16,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Perfil activo: ${_idPerfil ?? "…"}',
              style: const TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            _seccionExportar(),
            const SizedBox(height: 36),
            _separador(),
            const SizedBox(height: 36),
            _seccionImportar(),
            if (ColeccionDibujos.disponible) ...[
              const SizedBox(height: 36),
              _separador(),
              const SizedBox(height: 36),
              _SeccionDibujos(repositorio: widget.repositorio),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _seccionExportar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'EXPORTAR',
          style: TextStyle(
            color: PaletaNeon.violetaNeon,
            fontSize: 14,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Genera un JSON con el progreso del perfil activo '
          '(esquirlas, cinemáticas vistas, niveles de cada habilidad, '
          'ajustes). Cópialo al portapapeles y pégalo en notas, mail '
          'o Drive — desde ahí lo podrás traer de vuelta a la app.',
          style: TextStyle(
            color: PaletaNeon.textoTenue,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _trabajando ? null : _exportar,
          style: ElevatedButton.styleFrom(
            backgroundColor: PaletaNeon.violetaNeon.withOpacity(0.2),
            foregroundColor: PaletaNeon.textoPrincipal,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'GENERAR JSON',
            style: TextStyle(letterSpacing: 2),
          ),
        ),
        if (_jsonExportado != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PaletaNeon.fondoMedio,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: PaletaNeon.textoTenue.withOpacity(0.2),
              ),
            ),
            child: SelectableText(
              _jsonExportado!,
              style: const TextStyle(
                color: PaletaNeon.textoPrincipal,
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.4,
              ),
              maxLines: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _copiarAlPortapapeles,
            icon: const Icon(Icons.copy, size: 18,
                color: PaletaNeon.azulNeon),
            label: const Text(
              'COPIAR AL PORTAPAPELES',
              style: TextStyle(
                color: PaletaNeon.azulNeon,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _seccionImportar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'IMPORTAR',
          style: TextStyle(
            color: PaletaNeon.violetaNeon,
            fontSize: 14,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pega aquí un JSON exportado previamente y pulsa IMPORTAR. '
          'Reemplazará TODO el progreso del perfil activo.',
          style: TextStyle(
            color: PaletaNeon.textoTenue,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: PaletaNeon.fondoMedio,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: PaletaNeon.textoTenue.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _controladorImport,
            maxLines: 8,
            style: const TextStyle(
              color: PaletaNeon.textoPrincipal,
              fontSize: 11,
              fontFamily: 'monospace',
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText: 'Pega aquí el JSON…',
              hintStyle: TextStyle(color: PaletaNeon.textoTenue),
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _trabajando ? null : _importar,
          style: ElevatedButton.styleFrom(
            backgroundColor: PaletaNeon.violetaNeon.withOpacity(0.2),
            foregroundColor: PaletaNeon.textoPrincipal,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'IMPORTAR',
            style: TextStyle(letterSpacing: 2),
          ),
        ),
      ],
    );
  }

  Widget _separador() {
    return Container(
      height: 1,
      color: PaletaNeon.textoTenue.withOpacity(0.15),
    );
  }
}

/// Los dibujos del taller, para el adulto: cuántos hay y un botón para
/// sacarlos del aparato con el menú de compartir del sistema (guardar,
/// imprimir, mandarlos a la familia). Los dibujos son del niño: no salen
/// si el adulto no lo decide aquí.
class _SeccionDibujos extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const _SeccionDibujos({required this.repositorio});

  @override
  State<_SeccionDibujos> createState() => _SeccionDibujosState();
}

class _SeccionDibujosState extends State<_SeccionDibujos> {
  List<String> _rutas = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    await cargarDibujosDelTaller(widget.repositorio);
    if (!mounted) return;
    setState(() => _rutas = [
          for (final coleccion in coleccionesDelTaller) ...coleccion.rutas.value.values,
        ]);
  }

  Future<void> _compartir() async {
    await Share.shareXFiles(
      [for (final ruta in _rutas) XFile(ruta, mimeType: 'image/png')],
      text: 'Dibujos de Uno Roto',
    );
  }

  @override
  Widget build(BuildContext contexto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'DIBUJOS DEL TALLER',
          style: TextStyle(color: PaletaNeon.textoPrincipal, fontSize: 13, letterSpacing: 2.5),
        ),
        const SizedBox(height: 8),
        Text(
          _rutas.isEmpty
              ? 'Todavía no hay dibujos. Se hacen en el bestiario y en Mi cuaderno › Taller.'
              : 'Hay ${_rutas.length} ${_rutas.length == 1 ? 'dibujo' : 'dibujos'} en este perfil. '
                  'Sólo están en este aparato: con este botón puedes guardarlos, imprimirlos o '
                  'mandarlos a la familia. Son del niño: compártelos si él quiere.',
          style: TextStyle(color: PaletaNeon.textoTenue.withOpacity(0.9), fontSize: 13, height: 1.45),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey('compartir-dibujos'),
          onPressed: _rutas.isEmpty ? null : _compartir,
          icon: const Icon(Icons.ios_share, size: 18),
          label: const Text('COMPARTIR LOS DIBUJOS', style: TextStyle(letterSpacing: 1.5)),
        ),
      ],
    );
  }
}
