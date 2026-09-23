import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../../datos/registro_maestria_minijuego.dart';
import '../../datos/repositorio_progreso.dart';
import '../../dominio/minijuegos/catalogo_minijuegos.dart';
import '../../l10n/traducciones_narrativa.dart';
import '../../nucleo/paleta.dart';
import 'pantalla_canales.dart';
import 'pantalla_encaje.dart';
import 'pantalla_minas.dart';
import 'pantalla_parejas.dart';
import 'pantalla_puentes.dart';

/// Pantalla de la máquina [id]. Con [registro] nulo no se registra
/// maestría (modo dios: pruebas del operador).
Widget pantallaDeMaquina(
  IdMinijuego id, {
  required RegistroMaestriaMinijuego? registro,
  required int dificultad,
  required List<String> habilidades,
}) {
  switch (id) {
    case IdMinijuego.puentes:
      return PantallaPuentes(
          registro: registro,
          dificultad: dificultad,
          habilidadesPracticadas: habilidades);
    case IdMinijuego.encaje:
      return PantallaEncaje(dificultad: dificultad);
    case IdMinijuego.canales:
      return PantallaCanales(
          registro: registro,
          dificultad: dificultad,
          habilidadesPracticadas: habilidades);
    case IdMinijuego.parejas:
      return PantallaParejas(
          registro: registro,
          dificultad: dificultad,
          habilidadesPracticadas: habilidades);
    case IdMinijuego.minas:
      return PantallaMinas(
          registro: registro,
          dificultad: dificultad,
          habilidadesPracticadas: habilidades);
  }
}

/// Las máquinas de Rexán: recreativas viejas que repasan matemáticas ya
/// vistas. Cada máquina aparece encendida cuando el niño ha practicado
/// alguna de sus habilidades; si no, Rexán todavía la está arreglando
/// (y dice qué hace falta, sin prisa).
class PantallaMaquinas extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PantallaMaquinas({super.key, required this.repositorio});

  @override
  State<PantallaMaquinas> createState() => _PantallaMaquinasState();
}

class _PantallaMaquinasState extends State<PantallaMaquinas> {
  Map<IdMinijuego, DisponibilidadMinijuego> _disponibilidad = const {};
  bool _cargado = false;

  /// En modo dios todas las máquinas están encendidas, se elige la
  /// dificultad y no se registra maestría.
  bool _modoDios = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final modoDios = await widget.repositorio.cargarModoDiosActivo();
    final estados = <String, EstadoHabilidad?>{};
    for (final definicion in CatalogoMinijuegos.todos) {
      for (final id in definicion.habilidades) {
        estados[id] ??= await widget.repositorio.cargarEstadoHabilidad(id);
      }
    }
    if (!mounted) return;
    setState(() {
      _modoDios = modoDios;
      _disponibilidad = {
        for (final definicion in CatalogoMinijuegos.todos)
          definicion.id: disponibilidadMinijuego(definicion, estados),
      };
      _cargado = true;
    });
  }

  /// Máquinas ya construidas. Las que falten aparecen "en reparación"
  /// aunque el niño tenga las habilidades.
  static const _construidas = {
    IdMinijuego.puentes,
    IdMinijuego.encaje,
    IdMinijuego.canales,
    IdMinijuego.parejas,
    IdMinijuego.minas,
  };

  Widget _pantallaDe(
      DefinicionMinijuego definicion, DisponibilidadMinijuego disponibilidad) {
    final registro = RegistroMaestriaMinijuego(widget.repositorio);
    registro.preparar();
    return pantallaDeMaquina(
      definicion.id,
      registro: registro,
      dificultad: disponibilidad.dificultad,
      habilidades: disponibilidad.habilidadesPracticadas,
    );
  }

  Future<void> _abrirEnModoDios(
      DefinicionMinijuego definicion, int dificultad) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => pantallaDeMaquina(
        definicion.id,
        registro: null,
        dificultad: dificultad,
        habilidades: definicion.habilidades,
      ),
    ));
  }

  Future<void> _abrir(DefinicionMinijuego definicion) async {
    final disponibilidad = _disponibilidad[definicion.id];
    if (disponibilidad == null || !disponibilidad.disponible) return;
    final pantalla = _pantallaDe(definicion, disponibilidad);
    HapticFeedback.selectionClick();
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    await _cargar();
  }

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      body: SafeArea(
        child: !_cargado
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(8, 10, 20, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: PaletaNeon.textoTenue, size: 20),
                        onPressed: () => Navigator.of(contexto).pop(),
                      ),
                      // Se encoge si no cabe: en euskera y catalán el
                      // rótulo es aún más largo.
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            traducirNarrativa('Las máquinas de Rexán', locale)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: PaletaNeon.textoPrincipal,
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 0, 16),
                    child: Text(
                      '“${traducirNarrativa('Las saqué de los recreativos del Puerto. Funcionan con cabeza, no con monedas.', locale)}”\n— Rexán',
                      style: TextStyle(
                        color: PaletaNeon.textoTenue.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  for (final definicion in CatalogoMinijuegos.todos)
                    _FichaMaquina(
                      definicion: definicion,
                      encendida: _modoDios ||
                          ((_disponibilidad[definicion.id]?.disponible ??
                                  false) &&
                              _construidas.contains(definicion.id)),
                      alTocar: () => _abrir(definicion),
                      alElegirDificultad: _modoDios
                          ? (dificultad) =>
                              _abrirEnModoDios(definicion, dificultad)
                          : null,
                    ),
                ],
              ),
      ),
    );
  }
}

class _FichaMaquina extends StatelessWidget {
  final DefinicionMinijuego definicion;
  final bool encendida;
  final VoidCallback alTocar;

  /// Sólo en modo dios: abrir la máquina con la dificultad elegida.
  final ValueChanged<int>? alElegirDificultad;

  const _FichaMaquina({
    required this.definicion,
    required this.encendida,
    required this.alTocar,
    this.alElegirDificultad,
  });

  @override
  Widget build(BuildContext contexto) {
    final locale = Localizations.localeOf(contexto);
    final color = encendida ? PaletaNeon.ambarCanales : PaletaNeon.grisMetal;
    return GestureDetector(
      onTap: encendida && alElegirDificultad == null ? alTocar : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 0, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PaletaNeon.fondoMedio.withOpacity(encendida ? 0.8 : 0.4),
          border: Border.all(color: color.withOpacity(encendida ? 0.6 : 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/maquinas/${definicion.id.name}_${encendida ? 'on' : 'off'}.png',
                width: 84,
                height: 111,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(width: 84),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    traducirNarrativa(definicion.nombre, locale).toUpperCase(),
                    style: TextStyle(
                      color: encendida
                          ? PaletaNeon.textoPrincipal
                          : PaletaNeon.textoTenue.withOpacity(0.6),
                      fontSize: 14,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    encendida
                        ? traducirNarrativa(definicion.descripcion, locale)
                        : traducirNarrativa(
                            'Rexán todavía la está arreglando. Sigue cazando Fragmentos.',
                            locale),
                    style: TextStyle(
                      color: PaletaNeon.textoTenue
                          .withOpacity(encendida ? 0.9 : 0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (alElegirDificultad != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final dificultad in const [1, 2, 3])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              key: ValueKey(
                                  'dios-${definicion.id.name}-$dificultad'),
                              onTap: () => alElegirDificultad!(dificultad),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: PaletaNeon.violetaNeon),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'D$dificultad',
                                  style: const TextStyle(
                                    color: PaletaNeon.violetaNeon,
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
