import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogo_habilidades.dart';
import '../datos/repositorio_progreso.dart';
import '../dominio/distrito.dart';
import '../l10n/app_localizations.dart';
import '../nucleo/paleta.dart';

/// Pantalla que muestra el progreso del niño en todas las habilidades
/// de un distrito. Cada habilidad aparece con su nivel actual
/// (sin tocar → maestría) y su precisión.
class PantallaProgresoDistrito extends StatefulWidget {
  final Distrito distrito;
  final RepositorioProgreso repositorio;

  const PantallaProgresoDistrito({
    super.key,
    required this.distrito,
    required this.repositorio,
  });

  @override
  State<PantallaProgresoDistrito> createState() =>
      _PantallaProgresoDistritoState();
}

class _PantallaProgresoDistritoState extends State<PantallaProgresoDistrito> {
  List<_SkillConNivel> _skills = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final catalogo = await CatalogoHabilidades.cargar();
    final habilidades = catalogo.delDistrito(widget.distrito.identificador);

    final estados = <_SkillConNivel>[];
    for (final h in habilidades) {
      final estado = await widget.repositorio.cargarEstadoHabilidad(h.identificador);
      estados.add(_SkillConNivel(
        id: h.identificador,
        nombre: h.nombre,
        nivel: estado?.nivel ?? NivelMaestria.inexplorada,
        precision: estado?.precision ?? 0,
      ));
    }
    // Ordenar: primero las no practicadas, luego por nivel descendente
    estados.sort((a, b) {
      if (a.nivel != b.nivel) return b.nivel.index.compareTo(a.nivel.index);
      return a.id.compareTo(b.id);
    });
    if (!mounted) return;
    setState(() {
      _skills = estados;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          widget.distrito.nombre,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PaletaNeon.fondoCiudad),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _skills.isEmpty
                ? const Center(child: Text('Sin habilidades'))
                : ListView.builder(
                    padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
                    itemCount: _skills.length,
                    itemBuilder: (_, i) => _FilaSkill(
                      skill: _skills[i],
                      colorAcento: widget.distrito.colorAcento,
                    ),
                  ),
      ),
    );
  }
}

class _SkillConNivel {
  final String id;
  final String nombre;
  final NivelMaestria nivel;
  final double precision;

  const _SkillConNivel({
    required this.id,
    required this.nombre,
    required this.nivel,
    required this.precision,
  });
}

class _FilaSkill extends StatelessWidget {
  final _SkillConNivel skill;
  final Color colorAcento;

  const _FilaSkill({
    required this.skill,
    required this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _colorNivel(withOpacity: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.nombre,
                    style: const TextStyle(
                      color: PaletaNeon.textoPrincipal,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    skill.id,
                    style: TextStyle(
                      color: PaletaNeon.textoTenue.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _EtiquetaNivel(
              nivel: skill.nivel,
              precision: skill.precision,
            ),
          ],
        ),
      ),
    );
  }

  Color _colorNivel({double withOpacity = 1.0}) {
    return switch (skill.nivel) {
      NivelMaestria.inexplorada => PaletaNeon.textoTenue.withOpacity(withOpacity * 0.5),
      NivelMaestria.introducida => PaletaNeon.azulNeon.withOpacity(withOpacity),
      NivelMaestria.enDesarrollo => PaletaNeon.ambarCanales.withOpacity(withOpacity),
      NivelMaestria.competente => PaletaNeon.exitoSuave.withOpacity(withOpacity),
      NivelMaestria.maestria => PaletaNeon.violetaNeon.withOpacity(withOpacity),
    };
  }
}

class _EtiquetaNivel extends StatelessWidget {
  final NivelMaestria nivel;
  final double precision;

  const _EtiquetaNivel({required this.nivel, required this.precision});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final (etiqueta, color) = switch (nivel) {
      NivelMaestria.inexplorada => (textos.habNivelInexplorada, PaletaNeon.textoTenue),
      NivelMaestria.introducida => (textos.habNivelIntroducida, PaletaNeon.azulNeon),
      NivelMaestria.enDesarrollo => (textos.habNivelEnDesarrollo, PaletaNeon.ambarCanales),
      NivelMaestria.competente => (textos.habNivelCompetente, PaletaNeon.exitoSuave),
      NivelMaestria.maestria => (textos.habNivelMaestria, PaletaNeon.violetaNeon),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            color: color,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        if (precision > 0) ...[
          const SizedBox(width: 8),
          Text(
            '${(precision * 100).toInt()}%',
            style: TextStyle(
              color: PaletaNeon.textoTenue.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
