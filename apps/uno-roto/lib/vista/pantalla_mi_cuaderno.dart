import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../datos/catalogo_habilidades.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/cuaderno.dart';
import '../dominio/distrito.dart';
import '../dominio/estado_cuaderno.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../dominio/seleccionador_avatar.dart';
import '../l10n/app_localizations.dart';
import '../l10n/textos_enums.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'pantalla_atlas_distrito.dart';
import 'pantalla_panel_tutor.dart';
import 'pestana_bestiario.dart';
import 'pestana_taller.dart';
import 'widgets/avatar_jugador.dart';
import 'widgets/indicador_ventana.dart';

/// "Mi cuaderno" — pantalla unificada con tres pestañas:
///   - **Habilidades**: las 66 habilidades agrupadas por distrito,
///     con indicador "ventana iluminada" sin números (versión niño).
///     Tap en distrito → [PantallaAtlasDistrito]. Permite saltar a
///     [PantallaPanelTutor] desde el icono de escudo.
///   - **Diario**: las entradas narrativas del antiguo Cuaderno de
///     Irune, agrupadas por categoría, marcadas como leídas al abrir.
///   - **Bestiario**: las familias de Fragmentos como fichas con
///     identidad y lore por tramos (doc 16, eje C).
///
/// Reemplaza a `PantallaAtlas` + `PantallaCuaderno` (versión 0.5).
class PantallaMiCuaderno extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PantallaMiCuaderno({super.key, required this.repositorio});

  @override
  State<PantallaMiCuaderno> createState() => _PantallaMiCuadernoState();
}

class _PantallaMiCuadernoState extends State<PantallaMiCuaderno>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enHabilidades = _tabController.index == 0;
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: const Text(
          'MI CUADERNO',
          style: TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 16,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: PaletaNeon.azulNeon,
          labelColor: PaletaNeon.textoPrincipal,
          unselectedLabelColor: PaletaNeon.textoTenue,
          labelStyle: const TextStyle(
            fontSize: 12,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w400,
          ),
          // Cuatro pestañas: en un móvil estrecho se desplazan.
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'HABILIDADES'),
            Tab(text: 'DIARIO'),
            Tab(text: 'BESTIARIO'),
            Tab(text: 'TALLER'),
          ],
        ),
        actions: [
          if (enHabilidades)
            IconButton(
              tooltip: 'Modo tutor',
              icon: const Icon(Icons.shield_outlined, size: 18),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PantallaPanelTutor(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PaletaNeon.fondoCiudad),
        child: TabBarView(
          controller: _tabController,
          children: [
            _PestanaHabilidades(repositorio: widget.repositorio),
            _PestanaDiario(repositorio: widget.repositorio),
            PestanaBestiario(repositorio: widget.repositorio),
            PestanaTaller(repositorio: widget.repositorio),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Pestaña Habilidades — distritos + ventanas iluminadas
// ════════════════════════════════════════════════════════════════════

class _PestanaHabilidades extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const _PestanaHabilidades({required this.repositorio});

  @override
  State<_PestanaHabilidades> createState() => _PestanaHabilidadesState();
}

class _PestanaHabilidadesState extends State<_PestanaHabilidades> {
  CatalogoHabilidades? _catalogo;
  Map<String, EstadoHabilidad> _estadosPorId = const {};
  String? _rutaAvatar;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final catalogo = await CatalogoHabilidades.cargar();
    final mapa = <String, EstadoHabilidad>{};
    for (final id in catalogo.habilidades.keys) {
      final estado = await widget.repositorio.cargarEstadoHabilidad(id);
      if (estado != null) mapa[id] = estado;
    }
    final ruta = await widget.repositorio.cargarRutaAvatar();
    if (!mounted) return;
    setState(() {
      _catalogo = catalogo;
      _estadosPorId = mapa;
      _rutaAvatar = ruta;
      _cargando = false;
    });
  }

  Future<void> _editarAvatar() async {
    if (kIsWeb) {
      // En el navegador no hay dónde guardar la foto en local: se avisa
      // en vez de fallar en silencio.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(traducirNarrativa(
            'La foto de tu personaje sólo se puede poner en la app del móvil.',
            Localizations.localeOf(context))),
      ));
      return;
    }
    final seleccionador = SeleccionadorAvatar(widget.repositorio);
    final accion = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: PaletaNeon.fondoMedio,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'TU PERSONAJE',
                style: TextStyle(
                  color: PaletaNeon.violetaNeon.withOpacity(0.85),
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dibújalo en papel y haz una foto. O elige una imagen '
                'de la galería. Solo la verás tú — no se sube a ningún '
                'servidor.',
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.85),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _OpcionMenu(
                icono: Icons.camera_alt_outlined,
                etiqueta: 'Hacer foto a mi dibujo',
                alPulsar: () => Navigator.of(ctx).pop('camara'),
              ),
              _OpcionMenu(
                icono: Icons.photo_library_outlined,
                etiqueta: 'Elegir de la galería',
                alPulsar: () => Navigator.of(ctx).pop('galeria'),
              ),
              if (_rutaAvatar != null)
                _OpcionMenu(
                  icono: Icons.delete_outline,
                  etiqueta: 'Quitar el de ahora',
                  destructivo: true,
                  alPulsar: () => Navigator.of(ctx).pop('quitar'),
                ),
              _OpcionMenu(
                icono: Icons.close,
                etiqueta: 'Cancelar',
                alPulsar: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
    if (accion == null || !mounted) return;
    String? nuevaRuta;
    switch (accion) {
      case 'camara':
        nuevaRuta = await seleccionador.hacerFoto();
      case 'galeria':
        nuevaRuta = await seleccionador.elegirDeGaleria();
      case 'quitar':
        await widget.repositorio.borrarRutaAvatar();
        nuevaRuta = null;
    }
    if (!mounted) return;
    setState(() => _rutaAvatar = nuevaRuta);
  }

  Map<EstadoCuaderno, int> _recuentoDistrito(Distrito distrito) {
    final habilidades =
        _catalogo?.delDistrito(distrito.identificador) ?? const [];
    final recuento = <EstadoCuaderno, int>{
      for (final estado in EstadoCuaderno.values) estado: 0,
    };
    for (final hab in habilidades) {
      final estado = _estadosPorId[hab.identificador];
      final clas = estado == null
          ? EstadoCuaderno.latente
          : estadoCuadernoDe(estado);
      recuento[clas] = (recuento[clas] ?? 0) + 1;
    }
    return recuento;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOut,
      child: _cargando
          ? const Center(
              key: ValueKey('cargando'),
              child: CircularProgressIndicator(color: PaletaNeon.azulNeon),
            )
          : ListView.separated(
              key: const ValueKey('lista'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: CatalogoDistritos.todos.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (contexto, indice) {
                if (indice == 0) {
                  return _CabeceraHabilidades(
                    rutaAvatar: _rutaAvatar,
                    alTocarAvatar: _editarAvatar,
                  );
                }
                final distrito = CatalogoDistritos.todos[indice - 1];
                return _TarjetaDistrito(
                  distrito: distrito,
                  recuento: _recuentoDistrito(distrito),
                  alPulsar: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PantallaAtlasDistrito(
                          distrito: distrito,
                          repositorio: widget.repositorio,
                        ),
                      ),
                    );
                    if (mounted) await _cargar();
                  },
                );
              },
            ),
    );
  }
}

class _CabeceraHabilidades extends StatelessWidget {
  final String? rutaAvatar;
  final VoidCallback alTocarAvatar;

  const _CabeceraHabilidades({
    required this.rutaAvatar,
    required this.alTocarAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarJugador(
                rutaImagen: rutaAvatar,
                tamano: 64,
                alPulsar: alTocarAvatar,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lo que ya sabes hacer.',
                      style: TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontStyle: FontStyle.italic,
                        fontSize: 22,
                        color: PaletaNeon.textoPrincipal.withOpacity(0.92),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Y lo que aún no.',
                      style: TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: PaletaNeon.textoTenue.withOpacity(0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rutaAvatar == null) ...[
            const SizedBox(height: 10),
            Text(
              'Toca el círculo para subir tu personaje. '
              'Dibújalo en papel y haz una foto.',
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.7),
                fontSize: 11,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Aviso sutil para el adulto sobre el modo tutor. El icono
          // de escudo del AppBar es discreto a propósito; este chip
          // se ve sólo aquí, dentro del cuaderno, donde el adulto va
          // a curiosear el progreso.
          const _BotonModoTutor(),
        ],
      ),
    );
  }
}

class _OpcionMenu extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback alPulsar;
  final bool destructivo;

  const _OpcionMenu({
    required this.icono,
    required this.etiqueta,
    required this.alPulsar,
    this.destructivo = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructivo
        ? PaletaNeon.rosaAcento.withOpacity(0.85)
        : PaletaNeon.textoPrincipal;
    return InkWell(
      onTap: alPulsar,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icono,
              size: 20,
              color: color.withOpacity(0.85),
            ),
            const SizedBox(width: 16),
            Text(
              etiqueta,
              style: TextStyle(
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonModoTutor extends StatelessWidget {
  const _BotonModoTutor();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PantallaPanelTutor(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: PaletaNeon.fondoMedio.withOpacity(0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: PaletaNeon.violetaBase.withOpacity(0.55),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.shield_outlined,
              size: 18,
              color: PaletaNeon.violetaNeon.withOpacity(0.85),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MODO TUTOR',
                    style: TextStyle(
                      color: PaletaNeon.violetaNeon.withOpacity(0.9),
                      fontSize: 11,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Para adultos · ver progreso por habilidad',
                    style: TextStyle(
                      color: PaletaNeon.textoTenue.withOpacity(0.75),
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: PaletaNeon.textoTenue.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaDistrito extends StatelessWidget {
  final Distrito distrito;
  final Map<EstadoCuaderno, int> recuento;
  final VoidCallback alPulsar;

  const _TarjetaDistrito({
    required this.distrito,
    required this.recuento,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final total = recuento.values.fold<int>(0, (a, b) => a + b);
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PaletaNeon.fondoMedio.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: distrito.colorAcento.withOpacity(0.45),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 28,
                  decoration: BoxDecoration(
                    color: distrito.colorAcento,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    traducirNarrativa(
                      distrito.nombre,
                      Localizations.localeOf(context),
                    ),
                    style: const TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 22,
                      color: PaletaNeon.textoPrincipal,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Text(
                traducirNarrativa(
                  distrito.descripcionCorta,
                  Localizations.localeOf(context),
                ),
                style: TextStyle(
                  color: PaletaNeon.textoTenue.withOpacity(0.9),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _BarraVentanas(
              recuento: recuento,
              total: total,
              colorAcento: distrito.colorAcento,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraVentanas extends StatelessWidget {
  final Map<EstadoCuaderno, int> recuento;
  final int total;
  final Color colorAcento;

  const _BarraVentanas({
    required this.recuento,
    required this.total,
    required this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    const orden = [
      EstadoCuaderno.dominada,
      EstadoCuaderno.firme,
      EstadoCuaderno.practica,
      EstadoCuaderno.vista,
      EstadoCuaderno.latente,
    ];
    final ventanas = <Widget>[];
    for (final estado in orden) {
      final cuantas = recuento[estado] ?? 0;
      for (var i = 0; i < cuantas; i++) {
        ventanas.add(IndicadorVentana(
          estado: estado,
          colorAcento: colorAcento,
          tamano: 18,
        ));
      }
    }
    return Wrap(spacing: 4, runSpacing: 4, children: ventanas);
  }
}

// ════════════════════════════════════════════════════════════════════
// Pestaña Diario — entradas narrativas del Cuaderno de Irune
// ════════════════════════════════════════════════════════════════════

class _PestanaDiario extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const _PestanaDiario({required this.repositorio});

  @override
  State<_PestanaDiario> createState() => _PestanaDiarioState();
}

class _PestanaDiarioState extends State<_PestanaDiario> {
  List<EntradaCuaderno> _disponibles = [];
  Set<String> _leidas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final disponibles = await CatalogoCuaderno.disponibles(
      widget.repositorio.flagNarrativoActivo,
    );
    final leidas = <String>{};
    for (final entrada in disponibles) {
      if (await widget.repositorio.entradaCuadernoLeida(entrada.id)) {
        leidas.add(entrada.id);
      }
    }
    if (!mounted) return;
    setState(() {
      _disponibles = disponibles;
      _leidas = leidas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: PaletaNeon.azulNeon),
      );
    }
    if (_disponibles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            AppLocalizations.of(context).cuadernoVacio,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PaletaNeon.textoTenue.withOpacity(0.7),
              fontSize: 14,
              letterSpacing: 0.5,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    final porCategoria = <CategoriaCuaderno, List<EntradaCuaderno>>{};
    for (final e in _disponibles) {
      porCategoria.putIfAbsent(e.categoria, () => []).add(e);
    }
    final categorias = CategoriaCuaderno.values
        .where((c) => porCategoria.containsKey(c))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: categorias.length + 1,
      itemBuilder: (_, indice) {
        if (indice == 0) return _resumenLeidas();
        final categoria = categorias[indice - 1];
        return _seccionCategoria(categoria, porCategoria[categoria]!);
      },
    );
  }

  Widget _resumenLeidas() {
    final leidas = _leidas.length;
    final total = _disponibles.length;
    final totalPosible = CatalogoCuaderno.totalEntradas;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 20),
      child: Text(
        AppLocalizations.of(context)
            .cuadernoResumen(leidas, total, totalPosible),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 2,
          color: PaletaNeon.textoTenue.withOpacity(0.65),
        ),
      ),
    );
  }

  Widget _seccionCategoria(
    CategoriaCuaderno categoria,
    List<EntradaCuaderno> entradas,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10, left: 4),
          child: Text(
            categoria
                .nombreLocalizado(AppLocalizations.of(context))
                .toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 4,
              color: PaletaNeon.violetaNeon.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        for (final entrada in entradas) _tarjetaEntrada(entrada),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _tarjetaEntrada(EntradaCuaderno entrada) {
    final leida = _leidas.contains(entrada.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _abrirEntrada(entrada),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PaletaNeon.fondoMedio.withOpacity(0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (leida ? PaletaNeon.textoTenue : PaletaNeon.azulNeon)
                  .withOpacity(0.28),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: leida
                      ? PaletaNeon.textoTenue.withOpacity(0.35)
                      : PaletaNeon.azulNeon,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entrada.titulo,
                  style: TextStyle(
                    fontSize: 14,
                    color: leida
                        ? PaletaNeon.textoTenue
                        : PaletaNeon.textoPrincipal,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: PaletaNeon.textoTenue.withOpacity(0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirEntrada(EntradaCuaderno entrada) async {
    await widget.repositorio.marcarEntradaCuadernoLeida(entrada.id);
    if (!mounted) return;
    setState(() => _leidas.add(entrada.id));
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LecturaEntrada(entrada: entrada),
      ),
    );
  }
}

class _LecturaEntrada extends StatelessWidget {
  final EntradaCuaderno entrada;

  const _LecturaEntrada({required this.entrada});

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          entrada.categoria
              .nombreLocalizado(AppLocalizations.of(contexto))
              .toLowerCase(),
          style: const TextStyle(
            color: PaletaNeon.textoTenue,
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entrada.titulo,
              style: const TextStyle(
                fontSize: 26,
                color: PaletaNeon.textoPrincipal,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              entrada.texto,
              style: const TextStyle(
                fontSize: 16,
                color: PaletaNeon.textoPrincipal,
                letterSpacing: 0.2,
                height: 1.6,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
