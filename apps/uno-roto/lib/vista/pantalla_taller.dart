import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datos/repositorio_ciudad.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/distrito.dart';
import '../dominio/taller_ciudad.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';

/// El taller de Rexán (doc 16, eje B). El niño gasta esquirlas en
/// piezas concretas de la ciudad — una farola, unas ventanas, una
/// guirnalda — y las ve encendidas al volver a cazar a ese distrito.
///
/// Salvaguardas (doc 16 §6): precios planos y públicos, todo
/// alcanzable, sin escasez. Restaurar no toca las esquirlas GANADAS
/// (rangos y desbloqueos siguen intactos): el gasto se apunta aparte y
/// aquí se muestra el saldo disponible.
class PantallaTaller extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PantallaTaller({super.key, required this.repositorio});

  @override
  State<PantallaTaller> createState() => _PantallaTallerState();
}

class _PantallaTallerState extends State<PantallaTaller> {
  int _esquirlasGanadas = 0;

  /// Las que abren distritos (las reales o el suelo del nivel escolar).
  int _esquirlasAcceso = 0;
  int _esquirlasGastadas = 0;
  Set<String> _restauradas = const {};
  bool _cargado = false;

  /// Línea de Rexán activa (tras restaurar). Se muestra bajo la
  /// cabecera hasta que otra la sustituya.
  String? _lineaRexan;

  int get _disponibles => _esquirlasGanadas - _esquirlasGastadas;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final ganadas = await widget.repositorio.cargarEsquirlas();
    final acceso = await widget.repositorio.cargarEsquirlasParaAcceso();
    final gastadas = await widget.repositorio.ciudad.cargarEsquirlasGastadas();
    final restauradas =
        await widget.repositorio.ciudad.cargarPiezasRestauradas();
    if (!mounted) return;
    setState(() {
      _esquirlasGanadas = ganadas;
      _esquirlasAcceso = acceso;
      _esquirlasGastadas = gastadas;
      _restauradas = restauradas;
      _cargado = true;
    });
  }

  Future<void> _proponerRestaurar(PiezaCiudad pieza) async {
    final locale = Localizations.localeOf(context);
    if (_disponibles < CatalogoTaller.precioPlano) {
      // Voz de Rexán, sin reproche: informa y anima a cazar.
      setState(() {
        _lineaRexan = traducirNarrativa(
          'Te faltan esquirlas. Los Fragmentos de ahí fuera llevan unas cuantas.',
          locale,
        );
      });
      return;
    }
    final pregunta = traducirNarrativa(
      '¿Restaurar {pieza} por {precio} esquirlas?',
      locale,
    )
        .replaceAll('{pieza}', traducirNarrativa(pieza.nombre, locale))
        .replaceAll('{precio}', CatalogoTaller.precioPlano.toString());
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: PaletaNeon.ambarCanales.withOpacity(0.35)),
        ),
        content: Text(
          pregunta,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              traducirNarrativa('CANCELAR', locale),
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.8),
                letterSpacing: 2,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              traducirNarrativa('RESTAURAR', locale),
              style: const TextStyle(
                color: PaletaNeon.ambarCanales,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    final resultado = await widget.repositorio.ciudad.restaurarPieza(
      idPieza: pieza.id,
      precio: CatalogoTaller.precioPlano,
      esquirlasGanadas: _esquirlasGanadas,
    );
    if (!mounted) return;
    if (resultado == ResultadoRestauracion.hecha) {
      HapticFeedback.selectionClick();
      setState(() {
        _lineaRexan = traducirNarrativa(
          CatalogoTaller.lineaRexanAlRestaurar(pieza.tipoVisual),
          Localizations.localeOf(context),
        );
      });
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final distritosAbiertos = CatalogoDistritos.todos
        .where((d) => d.estaDesbloqueado(_esquirlasAcceso))
        .toList();
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      body: SafeArea(
        child: !_cargado
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Cabecera(
                    disponibles: _disponibles,
                    alVolver: () => Navigator.of(contexto).pop(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      '“${_lineaRexan ?? traducirNarrativa('Trae esquirlas. Yo pongo las manos.', locale)}”'
                      '\n— Rexán',
                      style: TextStyle(
                        color: PaletaNeon.textoTenue.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        for (final distrito in distritosAbiertos) ...[
                          _TituloDistrito(distrito: distrito),
                          for (final pieza in CatalogoTaller.delDistrito(
                              distrito.identificador))
                            _FilaPieza(
                              pieza: pieza,
                              restaurada: _restauradas.contains(pieza.id),
                              alcanzable:
                                  _disponibles >= CatalogoTaller.precioPlano,
                              alTocar: () => _proponerRestaurar(pieza),
                            ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final int disponibles;
  final VoidCallback alVolver;

  const _Cabecera({required this.disponibles, required this.alVolver});

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: PaletaNeon.textoTenue, size: 20),
            onPressed: alVolver,
          ),
          Expanded(
            child: Text(
              traducirNarrativa('El taller de Rexán', locale).toUpperCase(),
              style: const TextStyle(
                color: PaletaNeon.textoPrincipal,
                fontSize: 15,
                fontWeight: FontWeight.w300,
                letterSpacing: 3,
              ),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: PaletaNeon.ambarCanales.withOpacity(0.6),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '◆ $disponibles',
              style: const TextStyle(
                color: PaletaNeon.ambarCanales,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloDistrito extends StatelessWidget {
  final Distrito distrito;

  const _TituloDistrito({required this.distrito});

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        traducirNarrativa(distrito.nombre, locale).toUpperCase(),
        style: TextStyle(
          color: distrito.colorAcento.withOpacity(0.9),
          fontSize: 11,
          letterSpacing: 2.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _FilaPieza extends StatelessWidget {
  final PiezaCiudad pieza;
  final bool restaurada;
  final bool alcanzable;
  final VoidCallback alTocar;

  const _FilaPieza({
    required this.pieza,
    required this.restaurada,
    required this.alcanzable,
    required this.alTocar,
  });

  IconData get _icono {
    switch (pieza.tipoVisual) {
      case TipoPiezaVisual.farol:
        return Icons.light_outlined;
      case TipoPiezaVisual.ventanas:
        return Icons.window_outlined;
      case TipoPiezaVisual.guirnalda:
        return Icons.auto_awesome_outlined;
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return GestureDetector(
      onTap: restaurada ? null : alTocar,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(
              _icono,
              size: 18,
              color: restaurada
                  ? PaletaNeon.ambarCanales.withOpacity(0.9)
                  : PaletaNeon.textoTenue.withOpacity(0.55),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                traducirNarrativa(pieza.nombre, locale),
                style: TextStyle(
                  color: restaurada
                      ? PaletaNeon.textoPrincipal.withOpacity(0.85)
                      : PaletaNeon.textoTenue.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (restaurada)
              Icon(
                Icons.check,
                size: 16,
                color: PaletaNeon.ambarCanales.withOpacity(0.85),
              )
            else
              Text(
                '◆ ${CatalogoTaller.precioPlano}',
                style: TextStyle(
                  color: alcanzable
                      ? PaletaNeon.ambarCanales.withOpacity(0.85)
                      : PaletaNeon.textoTenue.withOpacity(0.45),
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
