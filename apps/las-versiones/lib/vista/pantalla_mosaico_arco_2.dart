import 'package:flutter/material.dart';

import '../datos/repositorio_mosaico.dart';
import '../dominio/mosaico_arco_2.dart';
import '../nucleo/paleta_archivo.dart';
import 'pantalla_mosaico_arco_1.dart' show colorParaNivel, etiquetaParaNivel;

/// Pantalla del Mosaico del Arco 2 (doc 08 §M2, F2-11).
///
/// Audio-guía de aproximadamente noventa segundos compuesta por 8
/// fragmentos pre-escritos. Cada fragmento tiene un texto leído y un
/// selector de **código de confianza** (Sólido / Probable / Disputado)
/// con código de color heredado del Mosaico del Arco 1: azul claro
/// para Sólido, ámbar para Probable, rojo claro para Disputado. Al
/// tap sobre un fragmento se abre un modal de selección. Al pulsar
/// otra vez sobre el mismo fragmento se desmarca.
///
/// La pantalla **no evalúa la cualidad estética** ni la corrección
/// de los códigos. Sólo respeta el mínimo de fragmentos marcados
/// para permitir entregar
/// (`MosaicoArco2.minimoFragmentosMarcadosParaEntregar`). Tras la
/// entrega, la cinemática `M2.entrega` se reproduce (Andrés con
/// auriculares, ático del Archivo) y, encadenadas, las dos del
/// cierre del Arco 2 (2.Z.1 + 2.Z.2) — esa cadena la maneja el
/// orquestador en `main.dart`, no la pantalla.
class PantallaMosaicoArco2 extends StatefulWidget {
  /// Callback al que llamar cuando la Cronista entrega el Mosaico.
  /// El orquestador activa el flag de entregado y encadena con la
  /// cinemática post-entrega.
  final Future<void> Function() alEntregar;

  /// Repositorio de persistencia. Inyectable para tests. Genérico
  /// por `idArco` — el mismo `RepositorioMosaico` del M1 sirve para
  /// el M2 sin cambios; sólo cambia el `idArco` que se le pasa.
  final RepositorioMosaico repoMosaico;

  /// Callback opcional para abrir el Menú principal mientras la
  /// Cronista trabaja la audio-guía.
  final VoidCallback? alAbrirMenu;

  const PantallaMosaicoArco2({
    super.key,
    required this.alEntregar,
    required this.repoMosaico,
    this.alAbrirMenu,
  });

  @override
  State<PantallaMosaicoArco2> createState() => _PantallaMosaicoArco2State();
}

class _PantallaMosaicoArco2State extends State<PantallaMosaicoArco2> {
  Map<String, NivelConfianza> _marcas = const {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMarcasPersistidas();
  }

  Future<void> _cargarMarcasPersistidas() async {
    final mapa = await widget.repoMosaico.cargar(MosaicoArco2.idArco);
    if (!mounted) return;
    setState(() {
      _marcas = Map.of(mapa);
      _cargando = false;
    });
  }

  Future<void> _alSeleccionarFragmento(FragmentoAudioGuia fragmento) async {
    final nivelSeleccionado = await showModalBottomSheet<_OpcionMarcaM2?>(
      context: context,
      backgroundColor: PaletaArchivo.fondoMedio,
      barrierColor: Colors.black.withOpacity(0.6),
      // Con la barra de navegación de Android (edge-to-edge, Android 15+)
      // el selector no cabía en el alto por defecto de la hoja y lo último
      // quedaba cortado: la hoja crece lo que necesite (sin pasar de la
      // barra de estado) y, si aún no cabe, se desplaza.
      isScrollControlled: true,
      useSafeArea: true,
      builder: (contexto) => _SelectorConfianzaM2(
        fragmento: fragmento,
        nivelActual: _marcas[fragmento.id],
      ),
    );
    if (!mounted || nivelSeleccionado == null) return;
    setState(() {
      _marcas = Map.of(_marcas);
      if (nivelSeleccionado.borrar) {
        _marcas.remove(fragmento.id);
      } else {
        _marcas[fragmento.id] = nivelSeleccionado.nivel!;
      }
    });
    await widget.repoMosaico.guardar(MosaicoArco2.idArco, _marcas);
  }

  Future<void> _alPulsarEntregar() async {
    if (_marcas.length <
        MosaicoArco2.minimoFragmentosMarcadosParaEntregar) {
      return;
    }
    await widget.repoMosaico.guardar(MosaicoArco2.idArco, _marcas);
    await widget.alEntregar();
  }

  @override
  Widget build(BuildContext contexto) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: PaletaArchivo.fondoProfundo,
        body: SizedBox.expand(),
      );
    }
    final puedeEntregar = _marcas.length >=
        MosaicoArco2.minimoFragmentosMarcadosParaEntregar;
    return Scaffold(
      backgroundColor: PaletaArchivo.fondoProfundo,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: _construirCuerpoMosaico(puedeEntregar),
            ),
            if (widget.alAbrirMenu != null)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: 'Menú',
                  iconSize: 22,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: PaletaArchivo.ambarLacre,
                  ),
                  onPressed: widget.alAbrirMenu,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirCuerpoMosaico(bool puedeEntregar) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                MosaicoArco2.titulo.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  letterSpacing: 4,
                  color: PaletaArchivo.ambarLacre,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                MosaicoArco2.preguntaAbiertaDelArco,
                style: TextStyle(
                  fontSize: 14,
                  color: PaletaArchivo.textoPrincipal.withOpacity(0.95),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                MosaicoArco2.glosa,
                style: TextStyle(
                  fontSize: 12,
                  color: PaletaArchivo.textoPrincipal.withOpacity(0.75),
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: MosaicoArco2.fragmentos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (contexto, indice) {
                    final fragmento = MosaicoArco2.fragmentos[indice];
                    return _CartaFragmento(
                      fragmento: fragmento,
                      indice: indice + 1,
                      nivelActual: _marcas[fragmento.id],
                      alPulsar: () => _alSeleccionarFragmento(fragmento),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _textoContador(_marcas.length),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: PaletaArchivo.textoTenue.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: puedeEntregar ? _alPulsarEntregar : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: PaletaArchivo.textoPrincipal,
                    backgroundColor: PaletaArchivo.fondoMedio
                        .withOpacity(puedeEntregar ? 0.6 : 0.3),
                    side: BorderSide(
                      color: PaletaArchivo.ambarLacre.withOpacity(
                        puedeEntregar ? 0.7 : 0.3,
                      ),
                    ),
                  ),
                  child: const Text(
                    'ENTREGAR LA AUDIO-GUÍA',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  String _textoContador(int cantidadMarcadas) {
    final total = MosaicoArco2.fragmentos.length;
    const minimo = MosaicoArco2.minimoFragmentosMarcadosParaEntregar;
    if (cantidadMarcadas < minimo) {
      final faltan = minimo - cantidadMarcadas;
      return '$cantidadMarcadas de $total marcados — faltan $faltan para '
          'entregar';
    }
    return '$cantidadMarcadas de $total marcados';
  }
}

class _CartaFragmento extends StatelessWidget {
  final FragmentoAudioGuia fragmento;
  final int indice;
  final NivelConfianza? nivelActual;
  final VoidCallback alPulsar;

  const _CartaFragmento({
    required this.fragmento,
    required this.indice,
    required this.nivelActual,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext contexto) {
    final color =
        nivelActual != null ? colorParaNivel(nivelActual!) : null;
    final etiqueta =
        nivelActual != null ? etiquetaParaNivel(nivelActual!) : null;
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: PaletaArchivo.fondoMedio.withOpacity(0.55),
          border: Border.all(
            color: color ?? PaletaArchivo.ambarLacre.withOpacity(0.4),
            width: color != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'PISTA ${indice.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.5,
                    color: PaletaArchivo.textoTenue.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (etiqueta != null && color != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: color.withOpacity(0.7)),
                    ),
                    child: Text(
                      etiqueta.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.6,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              fragmento.textoLeido,
              style: TextStyle(
                fontSize: 13,
                color: PaletaArchivo.textoPrincipal.withOpacity(0.92),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorConfianzaM2 extends StatelessWidget {
  final FragmentoAudioGuia fragmento;
  final NivelConfianza? nivelActual;

  const _SelectorConfianzaM2({
    required this.fragmento,
    required this.nivelActual,
  });

  @override
  Widget build(BuildContext contexto) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              fragmento.textoLeido,
              style: TextStyle(
                fontSize: 13,
                color: PaletaArchivo.textoPrincipal.withOpacity(0.92),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '¿CON QUÉ CONFIANZA SOSTIENES ESTE FRAGMENTO?',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2,
                color: PaletaArchivo.ambarLacre,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            for (final nivel in NivelConfianza.values) ...[
              _BotonNivelM2(
                nivel: nivel,
                seleccionado: nivelActual == nivel,
                alPulsar: () => Navigator.of(contexto)
                    .pop(_OpcionMarcaM2(nivel: nivel, borrar: false)),
              ),
              const SizedBox(height: 6),
            ],
            if (nivelActual != null) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(contexto)
                    .pop(const _OpcionMarcaM2(nivel: null, borrar: true)),
                style: TextButton.styleFrom(
                  foregroundColor: PaletaArchivo.textoTenue,
                ),
                child: const Text(
                  'DESMARCAR',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BotonNivelM2 extends StatelessWidget {
  final NivelConfianza nivel;
  final bool seleccionado;
  final VoidCallback alPulsar;

  const _BotonNivelM2({
    required this.nivel,
    required this.seleccionado,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext contexto) {
    final color = colorParaNivel(nivel);
    final etiqueta = etiquetaParaNivel(nivel);
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(seleccionado ? 0.22 : 0.08),
          border: Border.all(
            color: color.withOpacity(seleccionado ? 0.9 : 0.45),
            width: seleccionado ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              etiqueta.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2.4,
                color: PaletaArchivo.textoPrincipal,
                fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionMarcaM2 {
  final NivelConfianza? nivel;
  final bool borrar;

  const _OpcionMarcaM2({required this.nivel, required this.borrar});
}
