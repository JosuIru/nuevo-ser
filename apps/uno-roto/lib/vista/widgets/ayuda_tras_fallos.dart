import 'package:flutter/material.dart';

import '../../dominio/ayuda_puzzle.dart';
import '../../dominio/contador_intentos_puzzle.dart';
import '../../dominio/fragmento_en_tejado.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import '../estado_pista_puzzle.dart';

/// Comprueba si el niño ha fallado demasiadas veces y muestra ayuda.
/// Se llama desde cada pantalla de puzzle tras un fallo.
/// Si supera 5 fallos, muestra un dialog con la explicación del puzzle
/// y ofrece volver al mapa. Devuelve true si mostró el dialog.
Future<bool> comprobarYAyudarSiProcede(
  BuildContext context,
  EstadoPistaPuzzle pista,
  TipoFragmentoEnTejado tipo, {
  String? idHabilidadEso,
}) async {
  if (pista.fallosConsecutivos < 5) return false;

  // Reset para no encadenar diálogos. Reseteamos también el contador de
  // intentos del puzzle: si el niño decide SEGUIR tras leer la ayuda
  // recibe una "segunda oportunidad limpia". Sin esto, [_intentosPuzzleActual]
  // queda alto y el siguiente acierto cae en la regla del descarte y le
  // entrega 0 esquirlas pese a haber leído la explicación.
  pista.registrarAcierto();
  reiniciarIntentosPuzzle();

  if (!context.mounted) return false;

  final result = AyudaPuzzle.paraTipo(tipo, idHabilidadEso: idHabilidadEso);
  final locale = Localizations.localeOf(context);
  final titulo = traducirNarrativa(result.$1, locale);
  final texto = traducirNarrativa(result.$2, locale);
  final transferencia = traducirNarrativa(result.$3, locale);
  final tituloDialog = traducirNarrativa('¿Necesitas ayuda?', locale);
  final etiquetaSeguir = traducirNarrativa('SEGUIR', locale);
  final etiquetaVolver = traducirNarrativa('VOLVER', locale);
  final quiereSalir = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) => AlertDialog(
      backgroundColor: PaletaNeon.fondoMedio,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: PaletaNeon.textoTenue.withOpacity(0.2),
        ),
      ),
      title: Text(
        tituloDialog,
        style: const TextStyle(
          color: PaletaNeon.textoPrincipal,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: PaletaNeon.violetaNeon,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              texto,
              style: const TextStyle(
                color: PaletaNeon.textoTenue,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            if (transferencia.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PaletaNeon.fondoProfundo.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 ', style: const TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        transferencia,
                        style: const TextStyle(
                          color: PaletaNeon.textoPrincipal,
                          fontSize: 13,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            etiquetaSeguir,
            style: const TextStyle(
              color: PaletaNeon.textoPrincipal,
              letterSpacing: 1.5,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            etiquetaVolver,
            style: const TextStyle(
              color: PaletaNeon.rosaAcento,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  if (quiereSalir == true && context.mounted) {
    // VOLVER al mapa NO es captura. Si saliéramos con pop(true) el
    // cazadero registraría acierto en el motor de maestría y soltaría
    // el SnackBar "+0 (de X posibles)" — coherente con la regla del
    // descarte pero engañoso para el niño, que abandonó porque no
    // entendía el puzzle.
    Navigator.of(context).pop(false);
  }
  return true;
}
