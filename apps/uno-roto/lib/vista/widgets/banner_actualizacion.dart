import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/repositorio_progreso.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';

/// Releases de Uno Roto en GitHub: tag `uno-roto-<versión>`.
final configActualizacionesUnoRoto = configActualizacionesMonorepo('uno-roto');

/// Abre la pantalla de actualizaciones del core con los textos en el
/// idioma de la app.
Future<void> abrirActualizacionesUnoRoto(BuildContext contexto) {
  final locale = Localizations.localeOf(contexto);
  return Navigator.of(contexto).push(MaterialPageRoute(
    builder: (_) => PantallaEstadoActualizaciones(
      config: configActualizacionesUnoRoto,
      nombreApp: 'Uno Roto',
      traducir: (texto) => traducirNarrativa(texto, locale),
    ),
  ));
}

/// Banner discreto que aparece bajo el header del mapa cuando hay una
/// versión más reciente publicada en GitHub Releases (sólo las de Uno
/// Roto: tag `uno-roto-…`). "ACTUALIZAR" abre la pantalla de
/// actualizaciones, que descarga e instala sin salir del juego; "AHORA
/// NO" oculta el banner para esa versión. La siguiente vuelve a avisar.
///
/// El widget hace la comprobación en `initState` con un timeout de 8s
/// y nunca bloquea la UI: si falla la red o el parseo, simplemente no
/// se muestra el banner. El banner no se reconstruye al volver al
/// mapa desde otras pantallas (no observa el repo) — la comprobación
/// es una vez por arranque de la app.
class BannerActualizacion extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const BannerActualizacion({super.key, required this.repositorio});

  @override
  State<BannerActualizacion> createState() => _BannerActualizacionState();
}

class _BannerActualizacionState extends State<BannerActualizacion> {
  ActualizacionDisponible? _disponible;
  bool _ocultoEstaSesion = false;

  @override
  void initState() {
    super.initState();
    _comprobar();
  }

  Future<void> _comprobar() async {
    ActualizacionDisponible? disponible;
    try {
      disponible = await comprobarActualizacionDisponible(configActualizacionesUnoRoto);
    } catch (_) {
      return; // sin plugins o sin red: no hay aviso
    }
    if (disponible == null || !mounted) return;
    final ultimaAvisada =
        await widget.repositorio.cargarUltimaVersionAvisada();
    if (ultimaAvisada == disponible.versionDisponible) {
      // Ya avisamos de esta versión y el usuario la rechazó. No
      // volvemos a molestar hasta que haya una más nueva.
      return;
    }
    if (!mounted) return;
    setState(() => _disponible = disponible);
  }

  Future<void> _actualizar() async {
    final disponible = _disponible;
    if (disponible == null) return;
    await abrirActualizacionesUnoRoto(context);
    if (!mounted) return;
    setState(() => _ocultoEstaSesion = true);
  }

  Future<void> _ahoraNo() async {
    final disponible = _disponible;
    if (disponible == null) return;
    await widget.repositorio
        .guardarUltimaVersionAvisada(disponible.versionDisponible);
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
                    '${traducirNarrativa('NUEVA VERSIÓN', Localizations.localeOf(context))}: ${disponible.versionDisponible}',
                    style: const TextStyle(
                      color: PaletaNeon.textoPrincipal,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    traducirNarrativa('Se descarga e instala sin salir del juego.', Localizations.localeOf(context)),
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
              child: Text(
                traducirNarrativa('AHORA NO', Localizations.localeOf(context)),
                style: TextStyle(fontSize: 11, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            FilledButton.tonal(
              onPressed: _actualizar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                minimumSize: const Size(0, 36),
                backgroundColor: PaletaNeon.violetaNeon.withOpacity(0.4),
                foregroundColor: PaletaNeon.textoPrincipal,
              ),
              child: Text(
                traducirNarrativa('ACTUALIZAR', Localizations.localeOf(context)),
                style: TextStyle(fontSize: 11, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
