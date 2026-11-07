import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import 'formularios.dart';
import 'hoja_formulario.dart';
import 'pantalla_bandejas.dart';

/// Escáner del QR de las bandejas. Copiado del patrón de Arbolado urbano
/// (`apps/solera-arbolado-urbano/lib/pantallas/pantalla_escaner_qr.dart`):
/// devuelve el primer contenido no vacío con `Navigator.pop` y no consulta
/// la BD; quien la abre decide qué hacer con él.
class PantallaEscanerQr extends StatefulWidget {
  const PantallaEscanerQr({super.key});

  @override
  State<PantallaEscanerQr> createState() => _PantallaEscanerQrState();
}

class _PantallaEscanerQrState extends State<PantallaEscanerQr> {
  final _controlador = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _yaDevuelto = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alDetectar(BarcodeCapture captura) {
    if (_yaDevuelto) return;
    for (final codigo in captura.barcodes) {
      final contenido = codigo.rawValue?.trim();
      if (contenido != null && contenido.isNotEmpty) {
        _yaDevuelto = true;
        Navigator.of(context).pop<String>(contenido);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('vive.escanear_bandeja')),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: SoleraL10n.t('vive.linterna'),
            onPressed: () => _controlador.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: SoleraL10n.t('vive.cambiar_camara'),
            onPressed: () => _controlador.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controlador, onDetect: _alDetectar),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                SoleraL10n.t('vive.apunta_qr_bandeja'),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Escanea un QR y abre la ficha de su bandeja; si no existe, ofrece darla
/// de alta con ese código (una etiqueta ya impresa o de otro sistema).
Future<void> abrirBandejaPorQr(BuildContext context) async {
  final contenido = await Navigator.push<String>(
      context, MaterialPageRoute(builder: (_) => const PantallaEscanerQr()));
  if (contenido == null || !context.mounted) return;
  final bandeja =
      await BaseDatosSoleraVivero.instancia.obtenerBandejaPorQr(contenido);
  if (!context.mounted) return;
  if (bandeja != null) {
    await abrirFichaBandeja(context, bandeja.id!);
    return;
  }
  if (await confirmar(
      context, SoleraL10n.tf('vive.qr_desconocido', {'codigo': contenido}))) {
    if (!context.mounted) return;
    await mostrarFormularioBandeja(context, codigoInicial: contenido);
  }
}
