import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogo_cultivos.dart';
import '../datos/catalogo_fitosanitarios.dart';
import '../datos/catalogo_plagas.dart';
import '../datos/fenologia.dart';

/// Versión que se enseña en «Acerca de». Agro no depende de
/// `package_info_plus`, así que va escrita aquí, como en las hermanas:
/// hay que subirla a la vez que la de `pubspec.yaml`. La versión que de
/// verdad está instalada se ve en «Comprobar actualizaciones».
const versionVisibleAgro = '0.3.7';

/// Pantalla «Acerca de»: qué es Larrea, sus compromisos legales, el estado
/// de los catálogos y de dónde viene la app.
class PantallaAcerca extends StatelessWidget {
  const PantallaAcerca({super.key});

  @override
  Widget build(BuildContext context) {
    final esquemaColores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acerca_de'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: esquemaColores.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.agriculture,
                    size: 56,
                    color: esquemaColores.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Larrea',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Text('v$versionVisibleAgro',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            SoleraL10n.t('agro.acerca_descripcion'),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('agro.compromisos_legales')),
          _Vineta(SoleraL10n.t('agro.compromiso_fitosanitarios')),
          _Vineta(SoleraL10n.t('agro.compromiso_formato_cuaderno')),
          _Vineta(SoleraL10n.t('agro.compromiso_fiscal_provisional')),
          _Vineta(SoleraL10n.t('agro.compromiso_clave_anthropic')),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('agro.catalogos')),
          const _TarjetaCatalogos(),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('agro.familia_larrea')),
          Text(
            SoleraL10n.t('agro.familia_larrea_texto'),
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCatalogos extends StatelessWidget {
  const _TarjetaCatalogos();

  @override
  Widget build(BuildContext context) {
    const colorAviso = Colors.amber;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorAviso.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorAviso.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check, color: colorAviso.shade800, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  SoleraL10n.t('agro.catalogos_provisionales_sin_validar'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorAviso.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            SoleraL10n.tf('agro.catalogos_resumen', {
              'cultivos': catalogoCultivos.length,
              'plagas': catalogoPlagas.length,
              'productos': catalogoFitosanitarios.length,
              'calendario': calendarioFenologico.length,
            }),
            style: TextStyle(
                fontSize: 13, height: 1.5, color: colorAviso.shade900),
          ),
          const SizedBox(height: 8),
          Text(
            SoleraL10n.t('agro.catalogos_semilla_aviso'),
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class _Vineta extends StatelessWidget {
  const _Vineta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
