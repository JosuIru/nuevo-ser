import 'package:flutter/material.dart';

import '../datos/repositorio_recoleccion_fuentes.dart';
import '../dominio/brecha.dart';
import '../nucleo/paleta_archivo.dart';

/// Pantalla jugable de la Fase 2 de una Brecha — Recolección.
/// La Cronista recorre el lugar y "recoge" fuentes hasta tenerlas
/// todas en su Mesa de Trabajo. Aquí no se evalúa nada todavía:
/// sólo se decide qué entra en el corpus de la investigación.
///
/// Decisión de diseño: el catálogo `Brecha.fuentes` declara el
/// conjunto **completo** y la Cronista ha de recogerlas todas para
/// avanzar. En esta v0.1 no hay desafío de localización (no se le
/// pide "buscar" la fuente en una escena interactiva); el oficio de
/// la Fase 2 es leer cada fuente, decidir conscientemente que la
/// incorpora, y pasar a evaluarla. La capa de exploración espacial
/// (que sí está en el guion 1.1.4) llega en una fase visual más
/// rica cuando se introduzca CustomPainter / Flame.
class FaseRecoleccion extends StatefulWidget {
  /// Brecha cuya Fase 2 se está jugando.
  final Brecha brecha;

  /// Callback al que llamar cuando la Cronista pulsa "IR A LA MESA"
  /// y todas las fuentes están recogidas.
  final VoidCallback alAvanzarFase;

  /// Repositorio de persistencia. Inyectable para tests.
  final RepositorioRecoleccionFuentes repoRecoleccion;

  const FaseRecoleccion({
    super.key,
    required this.brecha,
    required this.alAvanzarFase,
    required this.repoRecoleccion,
  });

  @override
  State<FaseRecoleccion> createState() => _FaseRecoleccionState();
}

class _FaseRecoleccionState extends State<FaseRecoleccion> {
  Set<String> _idsRecogidas = const {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRecoleccionPersistida();
  }

  Future<void> _cargarRecoleccionPersistida() async {
    final ids = await widget.repoRecoleccion.idsFuentesRecogidas(
      widget.brecha.id,
    );
    if (!mounted) return;
    setState(() {
      _idsRecogidas = ids;
      _cargando = false;
    });
  }

  Future<void> _alRecoger(Fuente fuente) async {
    await widget.repoRecoleccion.registrarFuente(
      widget.brecha.id,
      fuente.id,
    );
    if (!mounted) return;
    setState(() {
      _idsRecogidas = {..._idsRecogidas, fuente.id};
    });
  }

  @override
  Widget build(BuildContext contexto) {
    if (_cargando) {
      return const SizedBox.expand();
    }
    final fuentes = widget.brecha.fuentes;
    final totalRecogidas = fuentes
        .where((fuente) => _idsRecogidas.contains(fuente.id))
        .length;
    final puedeAvanzar = totalRecogidas == fuentes.length && fuentes.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _IntroFase2(),
        const SizedBox(height: 6),
        _ContadorRecoleccion(
          recogidas: totalRecogidas,
          total: fuentes.length,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int indice = 0; indice < fuentes.length; indice++) ...[
                  if (indice > 0) const SizedBox(height: 12),
                  _TarjetaFuente(
                    fuente: fuentes[indice],
                    yaRecogida: _idsRecogidas.contains(fuentes[indice].id),
                    alRecoger: () => _alRecoger(fuentes[indice]),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: puedeAvanzar ? widget.alAvanzarFase : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: PaletaArchivo.textoPrincipal,
              // Sin esto el texto desactivado sale casi negro sobre el fondo
              // oscuro y el botón parece vacío.
              disabledForegroundColor: PaletaArchivo.textoTenue,
              backgroundColor:
                  PaletaArchivo.fondoMedio.withOpacity(puedeAvanzar ? 0.6 : 0.3),
              side: BorderSide(
                color: PaletaArchivo.ambarLacre.withOpacity(
                  puedeAvanzar ? 0.7 : 0.3,
                ),
              ),
            ),
            child: const Text(
              'IR A LA MESA DE TRABAJO',
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
}

class _IntroFase2 extends StatelessWidget {
  const _IntroFase2();

  @override
  Widget build(BuildContext contexto) {
    return Text(
      'Recoge cada fuente que encuentres en este lugar. Aún no toca '
      'evaluarlas — sólo incorporarlas conscientemente a tu Mesa de '
      'Trabajo. Léelas; en la fase siguiente las cuestionarás una a una.',
      style: TextStyle(
        fontSize: 14,
        color: PaletaArchivo.textoPrincipal.withOpacity(0.9),
        height: 1.55,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

class _ContadorRecoleccion extends StatelessWidget {
  final int recogidas;
  final int total;

  const _ContadorRecoleccion({
    required this.recogidas,
    required this.total,
  });

  @override
  Widget build(BuildContext contexto) {
    return Text(
      'Recogidas: $recogidas / $total',
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 3,
        color: PaletaArchivo.ambarLacre,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _TarjetaFuente extends StatelessWidget {
  final Fuente fuente;
  final bool yaRecogida;
  final VoidCallback alRecoger;

  const _TarjetaFuente({
    required this.fuente,
    required this.yaRecogida,
    required this.alRecoger,
  });

  @override
  Widget build(BuildContext contexto) {
    final colorAcento = yaRecogida
        ? PaletaArchivo.ambarLacre
        : PaletaArchivo.tintaTenue.withOpacity(0.4);
    return Container(
      decoration: BoxDecoration(
        color: PaletaArchivo.fondoMedio.withOpacity(0.4),
        border: Border(
          left: BorderSide(color: colorAcento, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fuente.tipoVisible.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 3,
              color: PaletaArchivo.ambarLacre,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fuente.descripcion,
            style: TextStyle(
              fontSize: 14,
              color: PaletaArchivo.textoPrincipal.withOpacity(0.92),
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: yaRecogida
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: PaletaArchivo.ambarLacre,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'EN LA MESA',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 3,
                          color: PaletaArchivo.ambarLacre,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : TextButton(
                    onPressed: alRecoger,
                    style: TextButton.styleFrom(
                      foregroundColor: PaletaArchivo.textoPrincipal,
                      // Sin esto el texto desactivado sale casi negro sobre el fondo
                      // oscuro y el botón parece vacío.
                      disabledForegroundColor: PaletaArchivo.textoTenue,
                      backgroundColor:
                          PaletaArchivo.fondoMedio.withOpacity(0.55),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      side: BorderSide(
                        color: PaletaArchivo.ambarLacre.withOpacity(0.6),
                      ),
                    ),
                    child: const Text(
                      'AÑADIR A LA MESA',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
