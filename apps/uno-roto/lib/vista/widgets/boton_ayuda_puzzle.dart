import 'package:flutter/material.dart';

import '../../dominio/ayuda_puzzle.dart';
import '../../dominio/fragmento_en_tejado.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';

/// Botón "?" que abre una explicación pedagógica del puzzle actual.
/// Se coloca en la esquina superior derecha de cada pantalla de puzzle.
/// Si [destacar] es true, pulsa lentamente para llamar la atención del
/// niño cuando lleva varios fallos seguidos.
class BotonAyudaPuzzle extends StatefulWidget {
  final TipoFragmentoEnTejado tipo;
  final bool destacar;

  /// Para los puzzles de ESO: de qué habilidad es la ayuda.
  final String? idHabilidadEso;

  const BotonAyudaPuzzle({
    super.key,
    required this.tipo,
    this.idHabilidadEso,
    this.destacar = false,
  });

  @override
  State<BotonAyudaPuzzle> createState() => _BotonAyudaPuzzleState();
}

class _BotonAyudaPuzzleState extends State<BotonAyudaPuzzle>
    with SingleTickerProviderStateMixin {
  AnimationController? _controlador;

  @override
  void initState() {
    super.initState();
    if (widget.destacar) _iniciarPulso();
  }

  @override
  void didUpdateWidget(BotonAyudaPuzzle old) {
    super.didUpdateWidget(old);
    if (widget.destacar && !old.destacar) {
      _iniciarPulso();
    } else if (!widget.destacar && old.destacar) {
      _controlador?.stop();
      _controlador?.reset();
    }
  }

  void _iniciarPulso() {
    _controlador?.dispose();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _controlador!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controlador?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacidadBase = widget.destacar ? 0.6 : 0.2;
    final borderOpacidad = widget.destacar ? 0.9 : 0.4;
    final colorBase = widget.destacar
        ? PaletaNeon.violetaNeon
        : PaletaNeon.textoTenue;

    Widget boton = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: widget.destacar
            ? PaletaNeon.violetaNeon.withOpacity(0.25)
            : PaletaNeon.textoTenue.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorBase.withOpacity(borderOpacidad),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: widget.destacar
                ? PaletaNeon.violetaNeon
                : PaletaNeon.textoTenue,
            fontSize: 18,
            fontWeight: widget.destacar ? FontWeight.w600 : FontWeight.w300,
          ),
        ),
      ),
    );

    if (_controlador != null && _controlador!.isAnimating) {
      boton = FadeTransition(
        opacity: Tween<double>(
          begin: opacidadBase,
          end: (opacidadBase + 0.4).clamp(0.0, 1.0),
        ).animate(CurvedAnimation(
          parent: _controlador!,
          curve: Curves.easeInOut,
        )),
        child: boton,
      );
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, right: 8),
          child: GestureDetector(
            onTap: () => _mostrarAyuda(context),
            child: boton,
          ),
        ),
      ),
    );
  }

  void _mostrarAyuda(BuildContext context) {
    final (tituloEs, textoEs, transferenciaEs) =
        AyudaPuzzle.paraTipo(widget.tipo, idHabilidadEso: widget.idHabilidadEso);
    final locale = Localizations.localeOf(context);
    final titulo = traducirNarrativa(tituloEs, locale);
    final texto = traducirNarrativa(textoEs, locale);
    final transferencia = traducirNarrativa(transferenciaEs, locale);
    final etiquetaEntendido = traducirNarrativa('ENTENDIDO', locale);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: PaletaNeon.textoTenue.withOpacity(0.2),
          ),
        ),
        title: Text(
          titulo,
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
                      Text(
                        '💡 ',
                        style: const TextStyle(fontSize: 14),
                      ),
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              etiquetaEntendido,
              style: const TextStyle(
                color: PaletaNeon.violetaNeon,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
