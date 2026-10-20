import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import '../utiles/crotal.dart';

/// Si en esta plataforma hay cámara que escanee códigos: Android, iOS,
/// macOS y navegador. En Linux y Windows no (mobile_scanner no los cubre).
bool get escanerCrotalDisponible =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

/// Abre el escáner y devuelve la identificación leída, o null si se cierra
/// sin leer nada.
Future<String?> escanearCrotal(BuildContext context) =>
    Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const PantallaEscanerCrotal(),
        fullscreenDialog: true,
      ),
    );

/// Lee el código de barras del DIB (o cualquier código con el crotal) con
/// la cámara. Si lo leído tiene forma de crotal oficial se devuelve al
/// momento; si no, se enseña lo leído y se pide confirmar, por si el código
/// era otra cosa (un enlace, un lote…).
class PantallaEscanerCrotal extends StatefulWidget {
  const PantallaEscanerCrotal({super.key});

  @override
  State<PantallaEscanerCrotal> createState() => _PantallaEscanerCrotalState();
}

class _PantallaEscanerCrotalState extends State<PantallaEscanerCrotal> {
  final _controlador = MobileScannerController(
    formats: const [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.itf14,
      BarcodeFormat.qrCode,
      BarcodeFormat.dataMatrix,
    ],
  );
  bool _resuelto = false;
  LecturaCrotal? _sinReconocer;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alDetectar(BarcodeCapture captura) {
    if (_resuelto || _sinReconocer != null) return;
    for (final codigo in captura.barcodes) {
      final bruto = codigo.rawValue;
      if (bruto == null || bruto.trim().isEmpty) continue;
      final lectura = interpretarCodigoCrotal(bruto);
      if (lectura.identificacion.isEmpty) continue;
      if (lectura.reconocido) {
        _devolver(lectura.identificacion);
      } else {
        setState(() => _sinReconocer = lectura);
      }
      return;
    }
  }

  /// Lee el código de una foto de la galería (un DIB fotografiado o
  /// recibido por mensaje). No existe en web.
  Future<void> _leerDeFoto() async {
    final foto = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (foto == null || !mounted) return;
    final captura = await _controlador.analyzeImage(foto.path);
    if (!mounted) return;
    if (captura == null || captura.barcodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).ganEscanerFotoSinCodigo)));
      return;
    }
    _alDetectar(captura);
  }

  void _devolver(String identificacion) {
    _resuelto = true;
    _controlador.stop();
    Navigator.of(context).pop(identificacion);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final sinReconocer = _sinReconocer;
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.ganEscanearCrotal),
        actions: [
          IconButton(
            tooltip: textos.ganEscanerLinterna,
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: kIsWeb ? null : () => _controlador.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controlador,
              onDetect: _alDetectar,
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    error.errorCode == MobileScannerErrorCode.permissionDenied
                        ? textos.ganEscanerSinPermiso
                        : textos.ganEscanerError,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: sinReconocer == null
                ? Column(
                    children: [
                      Text(textos.ganEscanerApuntar,
                          textAlign: TextAlign.center),
                      if (!kIsWeb) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _leerDeFoto,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(textos.ganEscanerDesdeFoto),
                        ),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(textos.ganEscanerNoReconocido,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      SelectableText(sinReconocer.identificacion,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _sinReconocer = null),
                              child: Text(textos.ganEscanerOtraVez),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  _devolver(sinReconocer.identificacion),
                              child: Text(textos.ganEscanerUsarIgual),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
