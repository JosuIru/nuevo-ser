import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_dop_sidra_txakoli.dart';
import '../datos/estado_bodega.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/kupela.dart';
import '../modelos/sagardotegi.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';
import 'pantalla_embotellados.dart';
import 'pantalla_kupela.dart';
import 'pantalla_partidas.dart';
import 'pantalla_prensados.dart';

/// Bodega: las kupelas con lo que tienen dentro, y la entrada de fruta, los
/// prensados y los embotellados.
class PantallaBodega extends StatefulWidget {
  const PantallaBodega({super.key});

  @override
  State<PantallaBodega> createState() => _PantallaBodegaState();
}

class _PantallaBodegaState extends State<PantallaBodega> {
  late Future<EstadoBodega> _estado;

  @override
  void initState() {
    super.initState();
    _estado = EstadoBodega.cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _estado = EstadoBodega.cargar();
    });
  }

  Future<void> _abrir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('sidr.bodega')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('sidr.entradas_fruta'),
            icon: const Icon(Icons.local_shipping_outlined),
            onPressed: () => _abrir(const PantallaPartidas()),
          ),
          IconButton(
            tooltip: SoleraL10n.t('sidr.prensados'),
            icon: const Icon(Icons.compress_outlined),
            onPressed: () => _abrir(const PantallaPrensados()),
          ),
          IconButton(
            tooltip: SoleraL10n.t('sidr.embotellados'),
            icon: const Icon(Icons.liquor_outlined),
            onPressed: () => _abrir(const PantallaEmbotellados()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('sidr.nueva_kupela'),
        onPressed: () => mostrarEditarKupela(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<EstadoBodega>(
        future: _estado,
        builder: (context, instantanea) {
          final estado = instantanea.data;
          if (estado == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (estado.kupelas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('sidr.sin_kupelas'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              ListTile(
                title: Text(SoleraL10n.tf('sidr.litros_en_bodega', {
                  'litros': formatearLitros(
                      estado.saldo.litrosTotales(estado.kupelas))
                })),
              ),
              for (final kupela in estado.kupelas)
                TarjetaKupela(
                  kupela: kupela,
                  litros: estado.saldo.litrosEn(kupela.id!),
                  alPulsar: () => _abrir(PantallaKupela(kupelaId: kupela.id!)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Fila de una kupela con su ocupación.
class TarjetaKupela extends StatelessWidget {
  const TarjetaKupela({
    super.key,
    required this.kupela,
    required this.litros,
    this.alPulsar,
  });

  final Kupela kupela;
  final double litros;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final ocupacion = kupela.capacidadLitros > 0
        ? (litros / kupela.capacidadLitros).clamp(0.0, 1.0)
        : 0.0;
    return ListTile(
      leading: const Icon(Icons.propane_tank_outlined),
      title: Text(kupela.etiqueta),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text([
            '${formatearLitros(litros)} / ${formatearLitros(kupela.capacidadLitros)}',
            nombreValor('producto', kupela.producto),
            if (kupela.calificacion != 'pendiente')
              nombreValor('calificacion', kupela.calificacion),
            if (!kupela.activa) SoleraL10n.t('sidr.retirada'),
          ].join(' · ')),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: ocupacion),
        ],
      ),
      trailing: litros < -0.5 || litros > kupela.capacidadLitros + 0.5
          ? const Icon(Icons.warning_amber_outlined)
          : null,
      onTap: alPulsar,
    );
  }
}

/// Alta o edición de una kupela en una hoja.
Future<void> mostrarEditarKupela(BuildContext context, {Kupela? kupela}) async {
  final sagardotegi = await BaseDatosSoleraSidra.instancia.obtenerSagardotegi();
  if (!context.mounted) return;
  final codigo = TextEditingController(text: kupela?.codigo);
  final nombre = TextEditingController(text: kupela?.nombre);
  final capacidad = TextEditingController(
      text: kupela == null
          ? ''
          : formatearNumero(kupela.capacidadLitros, decimales: 0));
  var material = kupela?.material ?? 'madera';
  var producto = kupela?.producto ??
      (sagardotegi.perfil == 'txakoli' ? 'txakoli' : 'sidra');
  var productoDop = kupela?.productoDopId ?? '';
  var activa = kupela?.activa ?? true;
  String? error;
  final guardado = await mostrarHojaFormulario(
    controladores: [codigo, nombre, capacidad],
    context,
    titulo: SoleraL10n.t(
        kupela == null ? 'sidr.nueva_kupela' : 'sidr.editar_kupela'),
    construir: (refrescar) => [
      campoTexto(codigo, SoleraL10n.t('sidr.codigo_kupela'),
          ayuda: SoleraL10n.t('sidr.codigo_kupela_ayuda')),
      campoTexto(nombre, SoleraL10n.t('sidr.nombre_opcional')),
      campoNumero(capacidad, SoleraL10n.t('sidr.capacidad'), sufijo: 'l'),
      campoDesplegable<String>(
        etiqueta: SoleraL10n.t('sidr.material'),
        valor: material,
        opciones: [
          for (final valor in materialesKupela)
            (valor, nombreValor('material', valor)),
        ],
        alCambiar: (valor) => refrescar(() => material = valor ?? material),
      ),
      campoDesplegable<String>(
        etiqueta: SoleraL10n.t('sidr.producto'),
        valor: producto,
        opciones: [
          for (final valor in productosKupela)
            (valor, nombreValor('producto', valor)),
        ],
        alCambiar: (valor) => refrescar(() => producto = valor ?? producto),
      ),
      campoDesplegable<String>(
        etiqueta: SoleraL10n.t('sidr.producto_dop'),
        valor: productoDop,
        opciones: [
          ('', SoleraL10n.t('sidr.sin_dop')),
          for (final productoCatalogo in _productosParaSagardotegi(sagardotegi))
            (productoCatalogo.id, productoCatalogo.nombre),
        ],
        alCambiar: (valor) => refrescar(() => productoDop = valor ?? ''),
      ),
      if (kupela != null)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: activa,
          title: Text(SoleraL10n.t('sidr.kupela_activa')),
          onChanged: (valor) => refrescar(() => activa = valor),
        ),
      if (error != null)
        Text(error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ],
    guardar: () async {
      final litros = leerNumero(capacidad.text);
      if (codigo.text.trim().isEmpty || litros == null || litros <= 0) {
        return false;
      }
      try {
        await BaseDatosSoleraSidra.instancia.guardarKupela(Kupela(
          id: kupela?.id,
          codigo: codigo.text.trim(),
          nombre: nombre.text.trim(),
          capacidadLitros: litros,
          material: material,
          producto: producto,
          productoDopId: productoDop,
          calificacion: kupela?.calificacion ?? 'pendiente',
          activa: activa,
          notas: kupela?.notas ?? '',
        ));
        return true;
      } catch (_) {
        error = SoleraL10n.t('sidr.codigo_repetido');
        return false;
      }
    },
  );
  if (guardado) avisarCambioDatos();
}

/// Productos DOP que se ofrecen: los de la denominación de la casa primero.
List<ProductoDop> _productosParaSagardotegi(Sagardotegi sagardotegi) => [
      ...productosDeDenominacion(sagardotegi.dopId),
      for (final dop in denominacionesOrigen)
        if (dop != sagardotegi.dopId) ...productosDeDenominacion(dop),
    ];
