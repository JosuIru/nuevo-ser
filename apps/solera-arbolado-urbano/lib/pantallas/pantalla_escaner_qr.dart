import 'package:flutter/material.dart';
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
        title: const Text('Escanear chapa QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Linterna',
            onPressed: () => _controlador.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Cambiar cámara',
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
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Apunta al QR de la chapa municipal del árbol. La cámara lo detecta automáticamente.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
