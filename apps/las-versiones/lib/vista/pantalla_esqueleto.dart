import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../nucleo/actualizaciones_las_versiones.dart';
import '../nucleo/paleta_archivo.dart';

/// Pantalla provisional para mientras el juego está en construcción.
///
/// Se muestra cuando la configuración inicial ya está hecha (idioma
/// elegido) pero todavía no hay Brechas pendientes ni cinemáticas
/// activas. Su única función es indicarle a quien abra la app antes
/// de tiempo que la cosa avanza, y exponer un único engranaje a la
/// derecha que abre la `PantallaMenu` con todas las acciones
/// (Cuaderno, Avances, Resúmenes, Cuenta, Idioma, Instrucciones,
/// Créditos, Resetear y Salir).
///
/// Esta pantalla desaparece en cuanto haya un primer flujo jugable
/// permanente — típicamente cuando todas las Brechas implementadas
/// estén abiertas y el orquestador despliegue otro tipo de superficie
/// principal.
class PantallaEsqueleto extends StatelessWidget {
  /// Callback obligatorio para abrir el Menú principal — la única
  /// superficie de meta-navegación del esqueleto. Si es `null`
  /// el botón no se muestra (caso de tests aislados).
  final VoidCallback? alAbrirMenu;

  const PantallaEsqueleto({
    super.key,
    this.alAbrirMenu,
  });

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      backgroundColor: PaletaArchivo.fondoProfundo,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/marca/las_versiones_logo.png',
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'El Archivo abre sus puertas pronto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PaletaArchivo.textoTenue.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Estamos preparando las primeras Brechas — fragmentos '
                    'de historia donde el registro se rompe y donde tu '
                    'oficio comenzará. Vuelve pronto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: PaletaArchivo.textoTenue,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            // Aviso de versión nueva arriba, dejando libre el engranaje
            // del menú. Si no hay versión nueva no ocupa sitio.
            Positioned(
              top: 0,
              left: 0,
              right: 52,
              child: AvisoActualizaciones(
                config: configActualizacionesLasVersiones,
                nombreApp: nombreAppLasVersiones,
              ),
            ),
            if (alAbrirMenu != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  tooltip: 'Menú',
                  iconSize: 26,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: PaletaArchivo.ambarLacre,
                  ),
                  onPressed: alAbrirMenu,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
