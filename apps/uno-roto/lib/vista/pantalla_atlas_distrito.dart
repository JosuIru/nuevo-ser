import 'package:flutter/material.dart';

import '../datos/catalogo_habilidades.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/distrito.dart';
import '../dominio/estado_cuaderno.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'widgets/indicador_ventana.dart';

/// Página interior del cuaderno: una habilidad por línea, con su
/// indicador de ventana. Tap en una habilidad → diálogo con frase
/// adaptada al estado (Sora) y la descripción del puzzle.
///
/// El nombre del distrito y su saludo se renderizan en Cormorant
/// Garamond, igual que la portada del cuaderno.
class PantallaAtlasDistrito extends StatefulWidget {
  final Distrito distrito;
  final RepositorioProgreso repositorio;

  const PantallaAtlasDistrito({
    super.key,
    required this.distrito,
    required this.repositorio,
  });

  @override
  State<PantallaAtlasDistrito> createState() => _PantallaAtlasDistritoState();
}

class _PantallaAtlasDistritoState extends State<PantallaAtlasDistrito> {
  CatalogoHabilidades? _catalogo;
  Map<String, EstadoHabilidad> _estados = const {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final catalogo = await CatalogoHabilidades.cargar();
    final habilidades = catalogo.delDistrito(widget.distrito.identificador);
    final mapa = <String, EstadoHabilidad>{};
    for (final h in habilidades) {
      final estado = await widget.repositorio.cargarEstadoHabilidad(
        h.identificador,
      );
      if (estado != null) mapa[h.identificador] = estado;
    }
    if (!mounted) return;
    setState(() {
      _catalogo = catalogo;
      _estados = mapa;
      _cargando = false;
    });
  }

  EstadoCuaderno _estadoDe(String idHabilidad) {
    final est = _estados[idHabilidad];
    return est == null ? EstadoCuaderno.latente : estadoCuadernoDe(est);
  }

  @override
  Widget build(BuildContext context) {
    final distrito = widget.distrito;
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          traducirNarrativa(distrito.nombre, Localizations.localeOf(context)),
          style: const TextStyle(
            fontFamily: 'CormorantGaramond',
            color: PaletaNeon.textoPrincipal,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PaletaNeon.fondoCiudad),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOut,
          child: _cargando
              ? const Center(
                  key: ValueKey('cargando'),
                  child: CircularProgressIndicator(
                    color: PaletaNeon.azulNeon,
                  ),
                )
              : _construirLista(distrito),
        ),
      ),
    );
  }

  Widget _construirLista(Distrito distrito) {
    final habilidades = _catalogo?.delDistrito(distrito.identificador) ?? [];
    // Ordenamos: dominadas y firmes arriba, latentes abajo. Dentro de
    // cada estado, por id ascendente para reproducibilidad.
    habilidades.sort((a, b) {
      final ea = _estadoDe(a.identificador);
      final eb = _estadoDe(b.identificador);
      // Estados de mayor maestría primero (índices más altos del enum).
      final cmp = eb.index.compareTo(ea.index);
      if (cmp != 0) return cmp;
      return a.identificador.compareTo(b.identificador);
    });
    return ListView.separated(
      key: const ValueKey('lista'),
      padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 16, 16, 32)),
      itemCount: habilidades.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (contexto, indice) {
        if (indice == 0) {
          return _Saludo(distrito: distrito);
        }
        final hab = habilidades[indice - 1];
        return _LineaHabilidad(
          habilidad: hab,
          estado: _estadoDe(hab.identificador),
          colorAcento: distrito.colorAcento,
          alPulsar: () => _abrirDetalle(hab, _estadoDe(hab.identificador)),
        );
      },
    );
  }

  void _abrirDetalle(Habilidad hab, EstadoCuaderno estado) {
    showDialog<void>(
      context: context,
      builder: (_) => _DetalleHabilidad(
        habilidad: hab,
        estado: estado,
        colorAcento: widget.distrito.colorAcento,
      ),
    );
  }
}

class _Saludo extends StatelessWidget {
  final Distrito distrito;

  const _Saludo({required this.distrito});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 14),
      child: Text(
        traducirNarrativa(
          distrito.saludoPrimeraVisita,
          Localizations.localeOf(context),
        ),
        style: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontStyle: FontStyle.italic,
          fontSize: 17,
          color: PaletaNeon.textoTenue.withOpacity(0.9),
          height: 1.4,
        ),
      ),
    );
  }
}

class _LineaHabilidad extends StatelessWidget {
  final Habilidad habilidad;
  final EstadoCuaderno estado;
  final Color colorAcento;
  final VoidCallback alPulsar;

  const _LineaHabilidad({
    required this.habilidad,
    required this.estado,
    required this.colorAcento,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = estado == EstadoCuaderno.latente
        ? PaletaNeon.textoTenue.withOpacity(0.65)
        : PaletaNeon.textoPrincipal;
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PaletaNeon.fondoMedio.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorAcento.withOpacity(0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            IndicadorVentana(
              estado: estado,
              colorAcento: colorAcento,
              tamano: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                traducirNarrativa(
                  habilidad.nombre,
                  Localizations.localeOf(context),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: colorTexto,
                  height: 1.3,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: PaletaNeon.textoTenue.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo con voz de Sora adaptada al estado, más una pista del
/// puzzle (toma del campo `name` del catálogo). Sin números crudos —
/// el modo tutor los añadirá en una sesión posterior.
class _DetalleHabilidad extends StatelessWidget {
  final Habilidad habilidad;
  final EstadoCuaderno estado;
  final Color colorAcento;

  const _DetalleHabilidad({
    required this.habilidad,
    required this.estado,
    required this.colorAcento,
  });

  String _fraseSora(EstadoCuaderno estado) {
    switch (estado) {
      case EstadoCuaderno.latente:
        return 'Esto aún no lo has visto.';
      case EstadoCuaderno.vista:
        return 'Lo has tocado. Vuelve cuando puedas.';
      case EstadoCuaderno.practica:
        return 'Estás aprendiéndolo. Tranquila, sin prisa.';
      case EstadoCuaderno.firme:
        return 'Esto ya te sale.';
      case EstadoCuaderno.dominada:
        return 'Esto lo dominas.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PaletaNeon.fondoMedio,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorAcento.withOpacity(0.45),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IndicadorVentana(
                  estado: estado,
                  colorAcento: colorAcento,
                  tamano: 44,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    traducirNarrativa(
                      habilidad.nombre,
                      Localizations.localeOf(context),
                    ),
                    style: const TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 20,
                      color: PaletaNeon.textoPrincipal,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              traducirNarrativa(
                _fraseSora(estado),
                Localizations.localeOf(context),
              ),
              style: const TextStyle(
                fontFamily: 'CormorantGaramond',
                fontStyle: FontStyle.italic,
                fontSize: 18,
                color: PaletaNeon.textoTenue,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              traducirNarrativa(
                estado.nombreCorto,
                Localizations.localeOf(context),
              ),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 3,
                color: colorAcento.withOpacity(0.85),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  traducirNarrativa(
                    'CERRAR',
                    Localizations.localeOf(context),
                  ),
                  style: const TextStyle(
                    color: PaletaNeon.textoPrincipal,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
