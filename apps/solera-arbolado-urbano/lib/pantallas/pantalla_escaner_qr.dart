import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Pantalla de escaneo QR para identificar la chapa municipal del
/// árbol. Devuelve el primer payload no vacío que detecta vía
/// `Navigator.pop(payload)`.
///
/// El operario apunta al QR, la cámara lo decodifica y volvemos al
/// llamador con el string. La pantalla NO consulta la BD — quien la
/// abrió decide si abre la ficha existente, da de alta un árbol nuevo
/// con ese payload, etc.
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
      final raw = codigo.rawValue?.trim();
      if (raw != null && raw.isNotEmpty) {
        _yaDevuelto = true;
        Navigator.of(context).pop<String>(raw);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('arb.escanear_chapa_qr')),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: SoleraL10n.t('arb.linterna'),
            onPressed: () => _controlador.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: SoleraL10n.t('arb.cambiar_camara'),
            onPressed: () => _controlador.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controlador,
            onDetect: _alDetectar,
          ),
          Positioned(
            bottom: 24 + MediaQuery.paddingOf(context).bottom,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                SoleraL10n.t('arb.apunta_qr_chapa'),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
