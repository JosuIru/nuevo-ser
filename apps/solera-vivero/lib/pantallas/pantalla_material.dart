import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/bandeja.dart';
import '../modelos/lote_material.dart';
import '../modelos/siembra.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';
import 'formularios.dart';
import 'vista_carga.dart';

/// Pestaña Material: lotes de semilla, esquejes, planta madre y plantones.
class PantallaMaterial extends StatelessWidget {
  const PantallaMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('vive.material'))),
      body: VistaCarga<List<LoteMaterial>>(
        cargar: BaseDatosSoleraVivero.instancia.listarLotesMaterial,
        construir: (context, lotes) => lotes.isEmpty
            ? ListaVacia(SoleraL10n.t('vive.sin_lotes'))
            : ListView(
                children: [
                  for (final lote in lotes)
                    ListTile(
                      leading: const Icon(Icons.grain_outlined),
                      title: Text(
                          '${lote.codigo} · ${nombreEspecieVisible(lote.especieId)}'),
                      subtitle: Text([
                        nombreTipoMaterial(lote.tipo),
                        if (lote.variedad.isNotEmpty) lote.variedad,
                        formatearFecha(lote.fechaEntradaMs),
                        lote.esPropio
                            ? SoleraL10n.t('vive.propio')
                            : lote.proveedorNombre,
                      ].where((parte) => parte.isNotEmpty).join(' · ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PantallaFichaLote(loteId: lote.id!))),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_nuevo_lote',
        tooltip: SoleraL10n.t('vive.nuevo_lote'),
        onPressed: () => mostrarFormularioLote(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Ficha del lote: sus datos y en qué bandejas se sembró.
class PantallaFichaLote extends StatelessWidget {
  const PantallaFichaLote({super.key, required this.loteId});
  final int loteId;

  Future<(LoteMaterial?, List<Siembra>, Map<int, Bandeja>)> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final lote = await bd.obtenerLoteMaterial(loteId);
    final siembras = await bd.listarSiembras(loteMaterialId: loteId);
    final bandejas = {
      for (final bandeja in await bd.listarBandejas()) bandeja.id!: bandeja
    };
    return (lote, siembras, bandejas);
  }

  @override
  Widget build(BuildContext context) {
    return VistaCarga<(LoteMaterial?, List<Siembra>, Map<int, Bandeja>)>(
      cargar: _cargar,
      construir: (context, datos) {
        final (lote, siembras, bandejas) = datos;
        if (lote == null) return const Scaffold();
        final filas = <(String, String)>[
          (SoleraL10n.t('vive.tipo_material'), nombreTipoMaterial(lote.tipo)),
          (SoleraL10n.t('vive.especie'), nombreEspecieVisible(lote.especieId)),
          (SoleraL10n.t('vive.nombre_botanico'), lote.nombreBotanico),
          (SoleraL10n.t('vive.variedad'), lote.variedad),
          (
            SoleraL10n.t('vive.fecha_entrada'),
            formatearFecha(lote.fechaEntradaMs)
          ),
          (
            SoleraL10n.t('vive.cantidad'),
            '${formatearNumero(lote.cantidad)} ${lote.unidad}'
          ),
          (
            SoleraL10n.t('vive.proveedor'),
            lote.esPropio ? SoleraL10n.t('vive.propio') : lote.proveedorNombre
          ),
          (SoleraL10n.t('vive.proveedor_ropveg'), lote.proveedorCodigoRopveg),
          (SoleraL10n.t('vive.pasaporte_recibido'), lote.pasaporteRecibido),
          (SoleraL10n.t('vive.pais_origen'), lote.paisOrigen),
          if (lote.esForestal) ...[
            (
              SoleraL10n.t('vive.categoria_forestal'),
              nombreCategoriaForestal(lote.categoriaForestal)
            ),
            (SoleraL10n.t('vive.region_procedencia'), lote.regionProcedencia),
            (SoleraL10n.t('vive.certificado_patron'), lote.certificadoPatron),
          ],
          (SoleraL10n.t('vive.notas'), lote.notas),
        ].where((fila) => fila.$2.isNotEmpty);
        return Scaffold(
          appBar: AppBar(
            title: Text(lote.codigo),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('editar'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    mostrarFormularioLote(context, existente: lote),
              ),
            ],
          ),
          body: ListView(
            children: [
              for (final (etiqueta, valor) in filas)
                ListTile(
                    dense: true, title: Text(etiqueta), subtitle: Text(valor)),
              TituloSeccion(SoleraL10n.t('vive.siembras'),
                  accion: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(SoleraL10n.t('vive.sembrar')),
                    onPressed: () =>
                        mostrarFormularioSiembra(context, loteId: lote.id),
                  )),
              if (siembras.isEmpty)
                ListaVacia(SoleraL10n.t('vive.sin_siembras')),
              for (final siembra in siembras)
                ListTile(
                  leading: const Icon(Icons.grid_on_outlined),
                  title: Text(bandejas[siembra.bandejaId]?.codigoQr ?? '—'),
                  subtitle: Text(
                      '${nombreMetodoSiembra(siembra.metodo)} · ${formatearFecha(siembra.fechaMs)} · '
                      '${SoleraL10n.tf('vive.alveolos_n', {
                        'n': siembra.alveolosOcupados
                      })}'),
                ),
            ],
          ),
        );
      },
    );
  }
}
