import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/parcela.dart';
import '../modelos/recoleccion.dart';
import '../modelos/tratamiento.dart';
import 'pantalla_nueva_recoleccion.dart';
import 'pantalla_nuevo_tratamiento.dart';

/// Ficha de una parcela: datos + timeline de recolecciones y
/// tratamientos vinculados. Botón "+" abre un menú con los tipos de
/// evento aplicables.
class PantallaFichaParcela extends StatefulWidget {
  final Parcela parcela;

  const PantallaFichaParcela({super.key, required this.parcela});

  @override
  State<PantallaFichaParcela> createState() => _PantallaFichaParcelaState();
}

class _PantallaFichaParcelaState extends State<PantallaFichaParcela> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  List<Recoleccion> _recolecciones = const [];
  List<Tratamiento> _tratamientos = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final rs =
        await bd.listarRecolecciones().then((rs) =>
            rs.where((r) => r.parcelaId == widget.parcela.id).toList());
    final ts = await bd.listarTratamientos(parcelaId: widget.parcela.id);
    if (!mounted) return;
    setState(() {
      _recolecciones = rs;
      _tratamientos = ts;
    });
  }

  Future<void> _registrarEvento() async {
    final tipo = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.agriculture),
              title: const Text('Recolección'),
              onTap: () => Navigator.of(context).pop('recoleccion'),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Tratamiento'),
              onTap: () => Navigator.of(context).pop('tratamiento'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || tipo == null) return;
    if (tipo == 'recoleccion') {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PantallaNuevaRecoleccion(parcelaId: widget.parcela.id!),
      ));
    } else {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PantallaNuevoTratamiento(parcelaId: widget.parcela.id!),
      ));
    }
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.parcela;
    return Scaffold(
      appBar: AppBar(
          title: Text(p.nombre.isEmpty ? '(parcela sin nombre)' : p.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Superficie: ${p.superficieHa.toStringAsFixed(2)} ha'),
                  Text('Variedad: ${p.variedadMayoritariaId.isEmpty ? "(sin definir)" : p.variedadMayoritariaId}'),
                  Text('Marco: ${p.marcoPlantacion.isEmpty ? "(sin definir)" : p.marcoPlantacion}'),
                  Text('Edad media: ${p.edadMediaAnyos} años'),
                  Text('Riego: ${p.sistemaRiego}'),
                  if (p.codigoSigpac.isNotEmpty)
                    Text('SIGPAC: ${p.codigoSigpac}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Recolecciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (_recolecciones.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin recolecciones registradas todavía.'),
            )
          else
            ..._recolecciones.map((r) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.agriculture,
                        color: Color(0xFF5C6B3A)),
                    title: Text(
                      '${r.kgEstimados.toStringAsFixed(0)} kg · ${r.tipoAceituna}',
                    ),
                    subtitle: Text(
                      '${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(r.fechaMs))} · ${r.metodo}',
                    ),
                  ),
                )),
          const SizedBox(height: 16),
          const Text('Tratamientos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (_tratamientos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin tratamientos registrados todavía.'),
            )
          else
            ..._tratamientos.map((t) => Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.bug_report, color: Color(0xFF5C6B3A)),
                    title: Text(t.sustanciaActivaId.isEmpty
                        ? '(sustancia activa no indicada)'
                        : t.sustanciaActivaId),
                    subtitle: Text(
                      '${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs))}'
                      ' · ${t.dosisLitrosPorHa.toStringAsFixed(2)} L/ha'
                      '${t.plagaObjetivoId.isEmpty ? "" : " · contra ${t.plagaObjetivoId}"}',
                    ),
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrarEvento,
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
    );
  }
}
