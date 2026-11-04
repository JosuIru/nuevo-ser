import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../servicios/cliente_anthropic.dart';
import 'pantalla_acerca.dart';
import 'pantalla_backup.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_fincas.dart';
import 'pantalla_terceros.dart';
import 'pantalla_titular.dart';

/// Ajustes ordenados por secciones, en el mismo orden que el resto de la
/// suite Larrea: explotación, inteligencia artificial, preferencias,
/// datos y aplicación. Los documentos y libros están en la pestaña
/// Registros (`PantallaRegistros`).
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    void abrir(Widget Function() constructorPantalla) =>
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => constructorPantalla()),
        );

    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_explotacion')),
          _EntradaAjustes(
            icono: Icons.person_outline,
            titulo: SoleraL10n.t('agro.datos_del_titular'),
            subtitulo: SoleraL10n.t('agro.datos_del_titular_sub'),
            alPulsar: () => abrir(() => PantallaTitular()),
          ),
          _EntradaAjustes(
            icono: Icons.agriculture,
            titulo: SoleraL10n.t('agro.fincas'),
            subtitulo: SoleraL10n.t('agro.fincas_sub'),
            alPulsar: () => abrir(() => PantallaFincas()),
          ),
          _EntradaAjustes(
            icono: Icons.account_balance,
            titulo: SoleraL10n.t('configuracion_fiscal'),
            subtitulo: SoleraL10n.t('agro.configuracion_fiscal_sub'),
            alPulsar: () => abrir(() => PantallaConfiguracionFiscal()),
          ),
          _EntradaAjustes(
            icono: Icons.contacts,
            titulo: SoleraL10n.t('agro.clientes_y_proveedores'),
            subtitulo: SoleraL10n.t('agro.clientes_y_proveedores_sub'),
            alPulsar: () => abrir(() => PantallaTerceros()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          _EntradaAjustes(
            icono: Icons.psychology,
            titulo: SoleraL10n.t('identificacion_con_ia'),
            subtitulo: SoleraL10n.t('agro.clave_anthropic_sub'),
            alPulsar: () => abrir(
              () => PantallaClaveAnthropic(
                estado: estadoClaveAnthropicAgro,
                nombreApp: 'Larrea',
                titulo: SoleraL10n.t('identificacion_con_ia'),
                queIdentifica: SoleraL10n.t('agro.identifica_plagas_por_foto'),
                descripcion: SoleraL10n.t('agro.clave_anthropic_descripcion'),
                probarClave: probarClaveAnthropic,
              ),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SelectorIdioma(),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          _EntradaAjustes(
            icono: Icons.archive,
            titulo: SoleraL10n.t('copia_de_seguridad'),
            subtitulo: SoleraL10n.t('agro.copia_de_seguridad_sub'),
            alPulsar: () => abrir(() => PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          _EntradaAjustes(
            icono: Icons.system_update,
            titulo: SoleraL10n.t('comprobar_actualizaciones'),
            subtitulo: SoleraL10n.t('agro.version_instalada_y_ultima'),
            alPulsar: () => abrir(
              () => PantallaEstadoActualizaciones(
                config: configActualizacionesMonorepo('agro'),
                nombreApp: 'Larrea',
              ),
            ),
          ),
          _EntradaAjustes(
            icono: Icons.info_outline,
            titulo: SoleraL10n.t('acerca_de'),
            alPulsar: () => abrir(() => const PantallaAcerca()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EntradaAjustes extends StatelessWidget {
  const _EntradaAjustes({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    required this.alPulsar,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      subtitle: subtitulo == null ? null : Text(subtitulo!),
      trailing: const Icon(Icons.chevron_right),
      onTap: alPulsar,
    );
  }
}
