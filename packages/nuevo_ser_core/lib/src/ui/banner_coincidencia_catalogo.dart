import 'package:flutter/material.dart';

/// Estado de coincidencia de un diagnóstico (de IA o entrada libre)
/// contra un catálogo curado del juego/app.
///
/// - **validado**: coincide con un item del catálogo y el catálogo
///   está completamente revisado por asesor humano.
/// - **provisional**: coincide con un item del catálogo, pero el
///   catálogo aún está sin validar — el banner avisa que es borrador.
/// - **libre**: no coincide con ningún item del catálogo — diagnóstico
///   "libre" del usuario o de la IA, requiere criterio humano.
enum CoincidenciaCatalogo { validado, provisional, libre }

/// Banner reutilizable que indica si el diagnóstico de la IA o el
/// texto del usuario coincide con el catálogo curado del juego/app.
///
/// Tres estados:
///  - **Verde**: coincide y catálogo completamente revisado.
///  - **Verde-amarillo**: coincide pero catálogo aún provisional.
///  - **Naranja**: no coincide ("diagnóstico libre"), revisar con
///    criterio.
///
/// La pantalla anfitriona decide el estado vía `coincidencia` y pasa
/// el `nombreCatalogo` (p. ej. "Larrea Viticultura") y opcionalmente
/// el nombre del item coincidente para mostrarlo en el banner.
///
/// Los textos están parametrizados por `mensajeLibre`, `mensajeProvisional`
/// y `mensajeValidado` para que cada app pueda ajustar el "asesor" que
/// menciona ("agrónomo asesor", "veterinario apícola", "ingeniero
/// técnico forestal"…).
class BannerCoincidenciaCatalogo extends StatelessWidget {
  final CoincidenciaCatalogo coincidencia;
  final String? nombreItemCoincidente;
  final String mensajeLibre;
  final String mensajeProvisional;
  final String mensajeValidado;

  const BannerCoincidenciaCatalogo({
    super.key,
    required this.coincidencia,
    this.nombreItemCoincidente,
    this.mensajeLibre =
        'Diagnóstico libre — no coincide con el catálogo curado. Revisa con criterio antes de aceptar.',
    this.mensajeProvisional =
        'Coincide con catálogo provisional. El catálogo aún no ha sido validado por el asesor — usa criterio.',
    this.mensajeValidado = 'Diagnóstico coincide con catálogo validado.',
  });

  @override
  Widget build(BuildContext context) {
    switch (coincidencia) {
      case CoincidenciaCatalogo.libre:
        return _Tarjeta(
          color: Colors.orange.shade50,
          borde: Colors.orange.shade300,
          icono: Icons.warning_amber,
          colorIcono: Colors.orange,
          texto: mensajeLibre,
        );
      case CoincidenciaCatalogo.validado:
        return _Tarjeta(
          color: Colors.green.shade50,
          borde: Colors.green.shade300,
          icono: Icons.verified,
          colorIcono: Colors.green,
          texto: nombreItemCoincidente == null
              ? mensajeValidado
              : '$mensajeValidado · $nombreItemCoincidente',
        );
      case CoincidenciaCatalogo.provisional:
        return _Tarjeta(
          color: const Color(0xFFFFF8E1),
          borde: Colors.amber.shade400,
          icono: Icons.fact_check,
          colorIcono: const Color(0xFFA67C00),
          texto: nombreItemCoincidente == null
              ? mensajeProvisional
              : 'Coincide con catálogo provisional: $nombreItemCoincidente. ${_quitarPrefijoCoincide(mensajeProvisional)}',
        );
    }
  }

  /// Si el `mensajeProvisional` empieza con "Coincide con catálogo
  /// provisional" lo recortamos al añadir el nombre del item — evita
  /// duplicar texto. Helper interno.
  String _quitarPrefijoCoincide(String mensaje) {
    const prefijo = 'Coincide con catálogo provisional. ';
    if (mensaje.startsWith(prefijo)) return mensaje.substring(prefijo.length);
    return mensaje;
  }
}

/// Banner rojo destacado para enfermedades/plagas de declaración
/// obligatoria al servicio fitosanitario o veterinario oficial.
/// Genérico — cada app le pasa el texto que aplica a su dominio.
class BannerDeclaracionObligatoria extends StatelessWidget {
  final String texto;

  const BannerDeclaracionObligatoria({
    super.key,
    this.texto =
        'PATOLOGÍA DE DECLARACIÓN OBLIGATORIA. Si confirmas el diagnóstico, debes notificarlo a los Servicios oficiales de tu CCAA.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade400, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.report, color: Colors.red, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner naranja para riesgo sanitario público — plagas con pelos
/// urticantes (procesionaria del pino, lagarta peluda) que requieren
/// vigilancia priorizada en zonas escolares y peatonales.
class BannerRiesgoSanitarioPublico extends StatelessWidget {
  final String texto;

  const BannerRiesgoSanitarioPublico({
    super.key,
    this.texto =
        'RIESGO SANITARIO PÚBLICO. Plaga con pelos urticantes o similares. Prioriza la actuación si está cerca de zonas escolares o paseos peatonales.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade400, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety, color: Colors.orange, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final Color color;
  final Color borde;
  final IconData icono;
  final Color colorIcono;
  final String texto;

  const _Tarjeta({
    required this.color,
    required this.borde,
    required this.icono,
    required this.colorIcono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borde),
      ),
      child: Row(
        children: [
          Icon(icono, color: colorIcono, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
