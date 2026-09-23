import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../datos/buscador_actualizacion.dart';
import '../../datos/repositorio_progreso.dart';
import '../../nucleo/paleta.dart';

/// Banner discreto que aparece bajo el header del mapa cuando hay una
/// versión más reciente publicada en GitHub Releases. El tester pulsa
/// "DESCARGAR" para abrir la URL del APK en el navegador del sistema,
/// o "AHORA NO" para ocultar el banner para esa versión. La siguiente
/// versión vuelve a disparar el aviso.
///
/// El widget hace la comprobación en `initState` con un timeout de 8s
/// y nunca bloquea la UI: si falla la red o el parseo, simplemente no
/// se muestra el banner. El banner no se reconstruye al volver al
/// mapa desde otras pantallas (no observa el repo) — la comprobación
/// es una vez por arranque de la app.
class BannerActualizacion extends StatefulWidget {
  final RepositorioProgreso repositorio;

  /// Inyectable para tests. En runtime el default crea su propio
  /// buscador con `http.get` y `PackageInfo.fromPlatform`.
  final BuscadorActualizacion? buscador;

  const BannerActualizacion({
    super.key,
    required this.repositorio,
    this.buscador,
  });

  @override
  State<BannerActualizacion> createState() => _BannerActualizacionState();
}

class _BannerActualizacionState extends State<BannerActualizacion> {
  NuevaVersionDisponible? _disponible;
  bool _ocultoEstaSesion = false;

  @override
  void initState() {
    super.initState();
    _comprobar();
  }

  Future<void> _comprobar() async {
    final buscador = widget.buscador ?? BuscadorActualizacion();
    final disponible = await buscador.comprobar();
    if (disponible == null || !mounted) return;
    final ultimaAvisada =
        await widget.repositorio.cargarUltimaVersionAvisada();
    if (ultimaAvisada == disponible.versionRemota.toString()) {
      // Ya avisamos de esta versión y el usuario la rechazó. No
      // volvemos a molestar hasta que haya una más nueva.
      return;
    }
    if (!mounted) return;
    setState(() => _disponible = disponible);
  }

  Future<void> _descargar() async {
    final disponible = _disponible;
    if (disponible == null) return;
    await widget.repositorio
        .guardarUltimaVersionAvisada(disponible.versionRemota.toString());
    final url = Uri.parse(disponible.urlPaginaRelease);
    await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    setState(() => _ocultoEstaSesion = true);
  }

  Future<void> _ahoraNo() async {
    final disponible = _disponible;
    if (disponible == null) return;
    await widget.repositorio
        .guardarUltimaVersionAvisada(disponible.versionRemota.toString());
    if (!mounted) return;
    setState(() => _ocultoEstaSesion = true);
  }

  @override
  Widget build(BuildContext context) {
    final disponible = _disponible;
    if (disponible == null || _ocultoEstaSesion) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          color: PaletaNeon.fondoMedio.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: PaletaNeon.violetaNeon.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NUEVA VERSIÓN: ${disponible.versionRemota}',
                    style: const TextStyle(
                      color: PaletaNeon.textoPrincipal,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Toca DESCARGAR para abrir la página del release.',
                    style: TextStyle(
                      color: PaletaNeon.textoTenue.withOpacity(0.8),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _ahoraNo,
              style: TextButton.styleFrom(
                foregroundColor: PaletaNeon.textoTenue,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 36),
              ),
              child: const Text(
                'AHORA NO',
                style: TextStyle(fontSize: 11, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            FilledButton.tonal(
              onPressed: _descargar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                minimumSize: const Size(0, 36),
                backgroundColor: PaletaNeon.violetaNeon.withOpacity(0.4),
                foregroundColor: PaletaNeon.textoPrincipal,
              ),
              child: const Text(
                'DESCARGAR',
                style: TextStyle(fontSize: 11, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
