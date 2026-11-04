import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/finca.dart';
import 'pantalla_editar_sigpac.dart';

class PantallaFincas extends StatefulWidget {
  PantallaFincas({super.key});

  @override
  State<PantallaFincas> createState() => _PantallaFincasState();
}

class _PantallaFincasState extends State<PantallaFincas> {
  List<Finca> _fincas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final fincas = await BaseDatosAgro.instancia.listarFincas();
    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _cargando = false;
    });
  }

  Future<void> _alAnadir() async {
    final nombre = await _pedirNombre(context: context, titulo: 'Nueva finca');
    if (nombre == null || nombre.trim().isEmpty) return;
    await BaseDatosAgro.instancia.guardarFinca(Finca(
      nombre: nombre.trim(),
      colorEntero: 0xFF5E7D3A,
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    _cargar();
  }

  Future<void> _alRenombrar(Finca finca) async {
    final nuevoNombre = await _pedirNombre(
      context: context,
      titulo: 'Renombrar finca',
      valorInicial: finca.nombre,
    );
    if (nuevoNombre == null || nuevoNombre.trim().isEmpty) return;
    await BaseDatosAgro.instancia.actualizarFinca(finca.id!, {'nombre': nuevoNombre.trim()});
    _cargar();
  }

  Future<void> _alBorrar(Finca finca) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('¿Borrar la finca «${finca.nombre}»?'),
        content: Text('Las plantas de la finca se conservarán como puntos sueltos. Su historia (cosechas, observaciones, etc.) no se perderá.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Borrar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;
    await BaseDatosAgro.instancia.borrarFinca(finca.id!);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fincas')),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : _fincas.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aún no has creado ninguna finca.\nPuedes registrar plantas como puntos sueltos\no crear una finca primero.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _fincas.length,
                  itemBuilder: (_, i) {
                    final f = _fincas[i];
                    final subtitulos = <String>[];
                    if (f.referenciaSigpac.isNotEmpty) {
                      subtitulos.add('SIGPAC ${f.referenciaSigpac}');
                    }
                    if (f.superficieHectareas != null) {
                      subtitulos.add('${f.superficieHectareas!.toStringAsFixed(2)} ha');
                    }
                    if (f.notas.isNotEmpty) subtitulos.add(f.notas);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(f.colorEntero),
                        child: Icon(Icons.agriculture, color: Colors.white),
                      ),
                      title: Text(f.nombre),
                      subtitle: subtitulos.isEmpty
                          ? null
                          : Text(subtitulos.join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: PopupMenuButton<String>(
                        onSelected: (op) async {
                          if (op == 'renombrar') _alRenombrar(f);
                          if (op == 'sigpac') {
                            final cambio = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => PantallaEditarSigpac(finca: f)),
                            );
                            if (cambio == true) _cargar();
                          }
                          if (op == 'borrar') _alBorrar(f);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'renombrar', child: Text('Renombrar')),
                          const PopupMenuItem(value: 'sigpac', child: Text('Datos SIGPAC y superficie')),
                          PopupMenuItem(value: 'borrar', child: Text(SoleraL10n.t('borrar'))),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _alAnadir,
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<String?> _pedirNombre({
  required BuildContext context,
  required String titulo,
  String valorInicial = '',
}) async {
  final controlador = TextEditingController(text: valorInicial);
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titulo),
      content: TextField(
        controller: controlador,
        autofocus: true,
        decoration: InputDecoration(labelText: 'Nombre'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(SoleraL10n.t('cancelar'))),
        FilledButton(onPressed: () => Navigator.pop(context, controlador.text), child: Text('OK')),
      ],
    ),
  );
}
