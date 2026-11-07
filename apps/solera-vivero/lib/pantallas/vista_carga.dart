import 'package:flutter/material.dart';

import '../estado/cambios_datos.dart';

/// Carga datos con [cargar] y los vuelve a cargar cada vez que se guarda
/// algo en la app (`cambiosDatos`). Pinta [construir] con el resultado.
class VistaCarga<T> extends StatefulWidget {
  const VistaCarga({super.key, required this.cargar, required this.construir});

  final Future<T> Function() cargar;
  final Widget Function(BuildContext context, T datos) construir;

  @override
  State<VistaCarga<T>> createState() => _VistaCargaState<T>();
}

class _VistaCargaState<T> extends State<VistaCarga<T>> {
  late Future<T> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = widget.cargar();
    cambiosDatos.addListener(_recargar);
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _futuro = widget.cargar();
    });
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
        future: _futuro,
        builder: (context, instantanea) {
          if (instantanea.hasError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('${instantanea.error}'),
            ));
          }
          if (!instantanea.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return widget.construir(context, instantanea.data as T);
        },
      );
}

/// Texto centrado para una lista vacía.
class ListaVacia extends StatelessWidget {
  const ListaVacia(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(texto, textAlign: TextAlign.center),
        ),
      );
}

/// Título de sección dentro de una lista.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.accion});
  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
        child: Row(children: [
          Expanded(
              child:
                  Text(texto, style: Theme.of(context).textTheme.titleMedium)),
          if (accion != null) accion!,
        ]),
      );
}
