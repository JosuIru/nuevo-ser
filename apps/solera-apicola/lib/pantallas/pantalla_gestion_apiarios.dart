import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/apiario.dart';
import 'pantalla_nueva_colmena.dart';
import 'pantalla_nuevo_apiario.dart';

class PantallaGestionApiarios extends StatefulWidget {
  const PantallaGestionApiarios({super.key});

  @override
  State<PantallaGestionApiarios> createState() =>
      _PantallaGestionApiariosState();
}

class _PantallaGestionApiariosState extends State<PantallaGestionApiarios> {
  List<Apiario> _apiarios = [];
  Map<int, int> _conteoColmenas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraApicola.instancia;
    final apiarios = await db.listarApiarios();
    final colmenas = await db.listarColmenas();
    final conteo = <int, int>{};
    for (final c in colmenas) {
      final id = c.apiarioId;
      if (id != null) {
        conteo[id] = (conteo[id] ?? 0) + 1;
      }
    }
    if (!mounted) return;
    setState(() {
      _apiarios = apiarios;
      _conteoColmenas = conteo;
      _cargando = false;
    });
  }

  Future<void> _abrirNuevoApiario() async {
    final cambiado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PantallaNuevoApiario()),
    );
    if (cambiado == true) _cargar();
  }

  Future<void> _editar(Apiario apiario) async {
    final cambiado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoApiario(apiarioExistente: apiario),
      ),
    );
    if (cambiado == true) _cargar();
  }

  Future<void> _nuevaColmena(Apiario apiario) async {
    final cambiado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevaColmena(apiarioIdInicial: apiario.id),
      ),
    );
    if (cambiado == true) _cargar();
  }

  Future<void> _borrar(Apiario apiario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(SoleraL10n.t('api.borrar_apiario')),
        content: Text(
          SoleraL10n.tf('api.borrar_apiario_aviso', {'nombre': apiario.nombre}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(SoleraL10n.t('cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(SoleraL10n.t('borrar')),
          ),
        ],
      ),
    );
    if (confirmar != true || apiario.id == null) return;
    await BaseDatosSoleraApicola.instancia.borrarApiario(apiario.id!);
    if (!mounted) return;
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('api.apiarios'))),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : _apiarios.isEmpty
              ? Center(
                  child: Text(
                    SoleraL10n.t('api.todavia_no_hay_apiarios'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _apiarios.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final apiario = _apiarios[index];
                    final color = Color(apiario.colorEntero);
                    final totalColmenas = _conteoColmenas[apiario.id] ?? 0;
                    return Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surface,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Icon(Icons.hub, color: Colors.white),
                        ),
                        title: Text(apiario.nombre),
                        subtitle: Text([
                          if (apiario.codigoSitran.isNotEmpty)
                            apiario.codigoSitran,
                          if (apiario.superficieHectareas != null)
                            '${apiario.superficieHectareas!.toStringAsFixed(2)} ha',
                          SoleraL10n.tf('api.n_colmenas', {'n': totalColmenas}),
                          if (apiario.latitudCentroide != null &&
                              apiario.longitudCentroide != null)
                            '${apiario.latitudCentroide!.toStringAsFixed(5)}, ${apiario.longitudCentroide!.toStringAsFixed(5)}',
                        ].join(' · ')),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: SoleraL10n.t('api.anadir_colmena'),
                              icon: Icon(Icons.add_location_alt),
                              onPressed: () => _nuevaColmena(apiario),
                            ),
                            IconButton(
                              tooltip: SoleraL10n.t('editar'),
                              icon: Icon(Icons.edit),
                              onPressed: () => _editar(apiario),
                            ),
                            IconButton(
                              tooltip: SoleraL10n.t('borrar'),
                              icon: Icon(Icons.delete_outline),
                              onPressed: () => _borrar(apiario),
                            ),
                          ],
                        ),
                        onTap: () => _editar(apiario),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevoApiario,
        icon: Icon(Icons.add_business),
        label: Text(SoleraL10n.t('api.nuevo_apiario')),
      ),
    );
  }
}
