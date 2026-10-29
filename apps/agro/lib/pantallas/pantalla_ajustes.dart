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
            titulo: 'Datos del titular',
            subtitulo: 'NIF, REGEPA, asesor, aplicador (para cuaderno MAPA)',
            alPulsar: () => abrir(() => PantallaTitular()),
          ),
          _EntradaAjustes(
            icono: Icons.agriculture,
            titulo: 'Fincas',
            subtitulo: 'Crear, renombrar y borrar fincas',
            alPulsar: () => abrir(() => PantallaFincas()),
          ),
          _EntradaAjustes(
            icono: Icons.account_balance,
            titulo: SoleraL10n.t('configuracion_fiscal'),
            subtitulo: 'Régimen IRPF + IVA · provisional',
            alPulsar: () => abrir(() => PantallaConfiguracionFiscal()),
          ),
          _EntradaAjustes(
            icono: Icons.contacts,
            titulo: 'Clientes y proveedores',
            subtitulo: 'Terceros con NIF · alimentan el modelo 347',
            alPulsar: () => abrir(() => PantallaTerceros()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          _EntradaAjustes(
            icono: Icons.psychology,
            titulo: SoleraL10n.t('identificacion_con_ia'),
            subtitulo: 'Configurar clave Anthropic para identificar plagas '
                'y enfermedades por foto',
            alPulsar: () => abrir(
              () => PantallaClaveAnthropic(
                estado: estadoClaveAnthropicAgro,
                nombreApp: 'Larrea',
                titulo: SoleraL10n.t('identificacion_con_ia'),
                queIdentifica: 'Identifica plagas y enfermedades por foto',
                descripcion: 'Larrea puede usar Claude AI de Anthropic para analizar la foto '
                    'que adjuntas a una incidencia y proponer un diagnóstico, severidad y '
                    'recomendaciones de manejo cultural.',
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
            titulo: 'Backup y restauración',
            subtitulo: 'Empaquetar BD + fotos en zip o restaurar desde zip',
            alPulsar: () => abrir(() => PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          _EntradaAjustes(
            icono: Icons.system_update,
            titulo: SoleraL10n.t('comprobar_actualizaciones'),
            subtitulo: 'Versión instalada y última publicada',
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
