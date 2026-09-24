import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../l10n/app_localizations.dart';
import '../utiles/traductor_actualizaciones.dart';
import 'pantalla_ayuda.dart';
import 'tablero_tareas.dart';

/// Pestaña "Hoy": resumen del día. Muestra el número de tareas abiertas y
/// un acceso directo al tablero de tareas.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final _bd = BaseDatosSoleraZunbeltz();
  int _abiertas = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    notificadorDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() => _cargar();

  Future<void> _cargar() async {
    var abiertas = 0;
    try {
      abiertas = await _bd.contarTareasAbiertas();
    } catch (_) {
      // Resumen no crítico: si la BD no está disponible (p. ej. en tests
      // sin plugins), mostramos 0 en vez de romper la pantalla.
    }
    if (!mounted) return;
    setState(() {
      _abiertas = abiertas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.hoyTitulo),
        actions: [
          IconButton(
            tooltip: textos.ayudaTitulo,
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PantallaAyuda()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Aviso de versión nueva: si no la hay, no ocupa sitio.
            AvisoActualizaciones(
              config: configActualizacionesZunbeltz,
              nombreApp: textos.appTitulo,
              traducir: traductorActualizaciones(textos),
              margen: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            Icon(Icons.wb_sunny_outlined,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            if (_cargando)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                textos.hoyResumenTareas(_abiertas),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                textos.hoyVacio,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TableroTareas(),
                    ));
                    if (mounted) await _cargar();
                  },
                  icon: const Icon(Icons.checklist),
                  label: Text(textos.hoyVerTablero),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
