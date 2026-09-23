import 'package:flutter/material.dart';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/repositorio_progreso.dart';
import '../dominio/catalogo_escenas.dart';
import '../dominio/minijuegos/catalogo_minijuegos.dart';
import '../dominio/rango_narrativo.dart';
import '../nucleo/paleta.dart';
import 'kai_presencia.dart';
import 'minijuegos/pantalla_maquinas.dart' show pantallaDeMaquina;
import 'oryn_presencia.dart';
import 'pantalla_cinematica.dart';
import 'sora_presencia.dart';

/// Pantalla del modo dios — solo accesible tras 7 toques rápidos sobre
/// el rótulo "UNO ROTO" del mapa. Tres secciones:
///   1. Galería de personajes con avatar real.
///   2. Lista completa de cinemáticas, lanzables sin importar flags.
///   3. Botones de utilidad: desbloquear todo, reiniciar perfil,
///      desactivar modo dios.
///
/// No persiste nada de la cinemática que se lanza desde aquí — al
/// terminar vuelve a esta misma pantalla. El catálogo se recorre
/// `CatalogoEscenas.todas` (66 escenas a fecha 2026-05-20).
class PantallaModoDios extends StatefulWidget {
  final RepositorioProgreso repositorio;
  final String nombreJugador;

  /// Callback invocado cuando el operador desactiva el modo dios. El
  /// caller (PantallaMapa) lo usa para refrescar su estado interno y
  /// dejar de mostrar el atajo en próximos toques sin desactivar el
  /// resto del progreso.
  final VoidCallback alDesactivar;

  const PantallaModoDios({
    super.key,
    required this.repositorio,
    required this.nombreJugador,
    required this.alDesactivar,
  });

  @override
  State<PantallaModoDios> createState() => _PantallaModoDiosState();
}

class _PantallaModoDiosState extends State<PantallaModoDios> {
  bool _trabajando = false;

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        foregroundColor: PaletaNeon.textoPrincipal,
        title: const Text(
          'MODO DIOS',
          style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w400),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
        children: [
          _Seccion(titulo: 'PERSONAJES', hijos: const [_GaleriaPersonajes()]),
          const SizedBox(height: 24),
          _Seccion(
            titulo: 'CINEMÁTICAS (${CatalogoEscenas.todas.length})',
            hijos: [
              for (final escena in CatalogoEscenas.todas)
                _BotonEscena(
                  escena: escena,
                  nombreJugador: widget.nombreJugador,
                ),
            ],
          ),
          const SizedBox(height: 24),
          _Seccion(
            titulo: 'MÁQUINAS DE REXÁN',
            hijos: [
              for (final definicion in CatalogoMinijuegos.todos)
                _BotonUtilidad(
                  etiqueta: definicion.nombre,
                  descripcion: 'Todas sus habilidades, sin registrar '
                      'maestría. Toca para dificultad 1; mantén para '
                      'elegir.',
                  onTap: () => _abrirMaquina(definicion, 1),
                  alMantener: () => _elegirDificultad(definicion),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _Seccion(
            titulo: 'UTILIDADES',
            hijos: [
              _BotonUtilidad(
                etiqueta: 'Desbloquear todo (perfil activo)',
                descripcion: 'Activa todos los flags narrativos, sube al rango '
                    'máximo y deja 999 esquirlas en el perfil activo.',
                onTap: _trabajando ? null : _desbloquearTodo,
              ),
              _BotonUtilidad(
                etiqueta: 'Reiniciar progreso (perfil activo)',
                descripcion: 'Borra TODO el progreso del perfil activo. '
                    'Conserva el nombre del jugador.',
                onTap: _trabajando ? null : _reiniciarPerfil,
                destructivo: true,
              ),
              const SizedBox(height: 12),
              _BotonUtilidad(
                etiqueta: 'Desactivar modo dios',
                descripcion: 'Vuelve a ocultar este menú. Se reactiva con '
                    '7 toques rápidos sobre el rótulo "UNO ROTO".',
                onTap: _trabajando ? null : _desactivar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _abrirMaquina(DefinicionMinijuego definicion, int dificultad) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => pantallaDeMaquina(
          definicion.id,
          registro: null,
          dificultad: dificultad,
          habilidades: definicion.habilidades,
        ),
      ));

  Future<void> _elegirDificultad(DefinicionMinijuego definicion) async {
    final dificultad = await showDialog<int>(
      context: context,
      builder: (contexto) => SimpleDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        title: Text('${definicion.nombre} — dificultad',
            style: const TextStyle(color: PaletaNeon.textoPrincipal)),
        children: [
          for (final valor in const [1, 2, 3])
            SimpleDialogOption(
              onPressed: () => Navigator.of(contexto).pop(valor),
              child: Text('Dificultad $valor',
                  style: const TextStyle(color: PaletaNeon.textoPrincipal)),
            ),
        ],
      ),
    );
    if (dificultad != null && mounted)
      await _abrirMaquina(definicion, dificultad);
  }

  Future<void> _desbloquearTodo() async {
    setState(() => _trabajando = true);
    try {
      // 1. Activar todos los flagDeSalida del catálogo.
      for (final escena in CatalogoEscenas.todas) {
        await widget.repositorio.activarFlagNarrativo(escena.flagDeSalida);
      }
      // 2. Forzar máximo rango — esto además activa los flags de rango
      //    intermedios (Aprendiz I/II/III, Iniciado).
      await widget.repositorio.forzarRangoMinimo(RangoNarrativo.iniciado);
      // 3. Esquirlas suficientes para ver el último distrito.
      await widget.repositorio.guardarEsquirlas(999);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Desbloqueado: 66 flags + rango Iniciado + 999 esquirlas'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _reiniciarPerfil() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        title: const Text('Reiniciar perfil activo',
            style: TextStyle(color: PaletaNeon.textoPrincipal)),
        content: const Text(
          'Esto borra TODO el progreso del perfil actualmente activo '
          '(escenas, habilidades, esquirlas, rango, ajustes de audio). '
          'No afecta a otros perfiles. ¿Seguro?',
          style: TextStyle(color: PaletaNeon.textoTenue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Reiniciar',
                style: TextStyle(color: PaletaNeon.rojoOxidado)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    setState(() => _trabajando = true);
    try {
      await widget.repositorio.reiniciar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil reiniciado.')),
      );
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _desactivar() async {
    await widget.repositorio.guardarModoDiosActivo(false);
    widget.alDesactivar();
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final List<Widget> hijos;

  const _Seccion({required this.titulo, required this.hijos});

  @override
  Widget build(BuildContext contexto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            titulo,
            style: const TextStyle(
              color: PaletaNeon.violetaNeon,
              letterSpacing: 3,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...hijos,
      ],
    );
  }
}

class _GaleriaPersonajes extends StatelessWidget {
  const _GaleriaPersonajes();

  @override
  Widget build(BuildContext contexto) {
    return Container(
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 230,
            // Scroll horizontal — 3 retratos de 170 px + paddings no
            // caben en pantalla estrecha (Redmi Note 8: 392 dp). El
            // scroll deja a Sora siempre visible y permite acceder a
            // Kai/Oryn deslizando.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  _RetratoPersonaje(
                    nombre: 'SORA',
                    color: PaletaNeon.azulNeon,
                    hijo: SoraPresencia(textoActivo: null),
                  ),
                  SizedBox(width: 16),
                  _RetratoPersonaje(
                    nombre: 'KAI',
                    color: PaletaNeon.rosaAcento,
                    hijo: KaiPresencia(textoActivo: null),
                  ),
                  SizedBox(width: 16),
                  _RetratoPersonaje(
                    nombre: 'ORYN',
                    color: PaletaNeon.exitoSuave,
                    hijo: OrynPresencia(textoActivo: null),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Resto del elenco (Irune, Rexán, Ari, Vadic, Naini, Brina, '
              'Niko, Fragmentos): sin avatar todavía — pendiente de '
              'concept-art.',
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.7),
                fontSize: 11,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetratoPersonaje extends StatelessWidget {
  final String nombre;
  final Color color;
  final Widget hijo;

  const _RetratoPersonaje({
    required this.nombre,
    required this.color,
    required this.hijo,
  });

  @override
  Widget build(BuildContext contexto) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          nombre,
          style: TextStyle(
            color: color,
            letterSpacing: 3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(width: 170, child: hijo),
      ],
    );
  }
}

class _BotonEscena extends StatelessWidget {
  final EscenaCinematica escena;
  final String nombreJugador;

  const _BotonEscena({required this.escena, required this.nombreJugador});

  @override
  Widget build(BuildContext contexto) {
    final voces = _vocesDistintas(escena);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _abrirEscena(contexto),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: PaletaNeon.fondoMedio.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: PaletaNeon.violetaNeon.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  escena.id,
                  style: const TextStyle(
                    color: PaletaNeon.violetaNeon,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      escena.titulo,
                      style: const TextStyle(
                        color: PaletaNeon.textoPrincipal,
                        fontSize: 14,
                      ),
                    ),
                    if (voces.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          voces,
                          style: TextStyle(
                            color: PaletaNeon.textoTenue.withOpacity(0.65),
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_arrow,
                color: PaletaNeon.textoTenue,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _vocesDistintas(EscenaCinematica escena) {
    final nombres = <String>{};
    for (final plano in escena.planos) {
      if (plano is PlanoDialogo) {
        final n = plano.voz.nombreVisible;
        if (n.isNotEmpty) nombres.add(n);
      } else if (plano is PlanoEleccion) {
        final n = plano.voz.nombreVisible;
        if (n.isNotEmpty) nombres.add(n);
      }
    }
    return nombres.join(' · ');
  }

  void _abrirEscena(BuildContext contexto) {
    Navigator.of(contexto).push(
      MaterialPageRoute(
        builder: (_) => PantallaCinematica(
          escena: escena,
          nombreJugador: nombreJugador,
          alTerminar: () => Navigator.of(contexto).pop(),
          // alEstablecerFlag null: el modo dios no debe persistir
          // flags al hacer "probar escena". Si el operador quiere que
          // se persistan, debe usar "Desbloquear todo".
          alEstablecerFlag: null,
        ),
      ),
    );
  }
}

class _BotonUtilidad extends StatelessWidget {
  final String etiqueta;
  final String descripcion;
  final VoidCallback? onTap;
  final VoidCallback? alMantener;
  final bool destructivo;

  const _BotonUtilidad({
    required this.etiqueta,
    required this.descripcion,
    required this.onTap,
    this.alMantener,
    this.destructivo = false,
  });

  @override
  Widget build(BuildContext contexto) {
    final color = destructivo ? PaletaNeon.rojoOxidado : PaletaNeon.violetaNeon;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: alMantener,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PaletaNeon.fondoMedio.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: TextStyle(
                  color: onTap == null
                      ? PaletaNeon.textoTenue
                      : PaletaNeon.textoPrincipal,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.75),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
