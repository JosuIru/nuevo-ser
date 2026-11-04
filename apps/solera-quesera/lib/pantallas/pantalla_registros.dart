import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import 'pantalla_facturas.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_lista_recetas.dart';
import 'pantalla_perfil_do.dart';
import 'pantalla_registro_appcc.dart';
import 'pantalla_simulacion_trazabilidad.dart';
import 'pantalla_trazabilidad.dart';

/// Pestaña «Registros»: los libros y documentos de la quesería
/// (trazabilidad y APPCC, recetas y DO, facturas y libro económico).
/// Lo que antes estaba en la pestaña «Doc» y en Ajustes → Registros.
class PantallaRegistros extends StatefulWidget {
  const PantallaRegistros({super.key});

  @override
  State<PantallaRegistros> createState() => _PantallaRegistrosState();
}

class _PantallaRegistrosState extends State<PantallaRegistros> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  int _numeroRecetas = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final recetas = await _bd.listarRecetas();
    if (mounted) setState(() => _numeroRecetas = recetas.length);
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    await _cargar();
  }

  Widget _entrada({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required Widget pantalla,
  }) =>
      ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _abrir(pantalla),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ques.registros'))),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            CabeceraSeccionAjustes(SoleraL10n.t('ques.trazabilidad_y_appcc')),
            _entrada(
              icono: Icons.description,
              titulo: SoleraL10n.t('libro_de_trazabilidad_appcc'),
              subtitulo: SoleraL10n.t('ques.pdf_inspeccionable_por_periodo'),
              pantalla: const PantallaTrazabilidad(),
            ),
            _entrada(
              icono: Icons.assignment,
              titulo: SoleraL10n.t('registros_appcc'),
              subtitulo: SoleraL10n.t('ques.registros_appcc_ayuda'),
              pantalla: const PantallaRegistroAppcc(),
            ),
            _entrada(
              icono: Icons.analytics,
              titulo: SoleraL10n.t('simulacion_de_trazabilidad'),
              subtitulo: SoleraL10n.t('ques.simulacion_ayuda'),
              pantalla: const PantallaSimulacionTrazabilidad(),
            ),
            CabeceraSeccionAjustes(SoleraL10n.t('ques.elaboracion')),
            _entrada(
              icono: Icons.restaurant_menu,
              titulo: SoleraL10n.t('recetas'),
              subtitulo: SoleraL10n.tf('ques.registradas_n', {'n': _numeroRecetas}),
              pantalla: PantallaListaRecetas(),
            ),
            _entrada(
              icono: Icons.verified,
              titulo: SoleraL10n.t('perfiles_do'),
              subtitulo: SoleraL10n.t('ques.do_activas'),
              pantalla: const PantallaPerfilDo(),
            ),
            CabeceraSeccionAjustes(SoleraL10n.t('ques.economia')),
            _entrada(
              icono: Icons.receipt,
              titulo: SoleraL10n.t('facturas'),
              subtitulo: SoleraL10n.t('emision_pdf_y_envio'),
              pantalla: PantallaFacturas(),
            ),
            _entrada(
              icono: Icons.euro,
              titulo: SoleraL10n.t('libro_economico'),
              subtitulo: SoleraL10n.t('ques.ingresos_gastos_resumen'),
              pantalla: PantallaLibroEconomico(),
            ),
          ],
        ),
      ),
    );
  }
}
