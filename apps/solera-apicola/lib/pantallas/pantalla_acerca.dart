import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../datos/catalogos_generados/catalogo_calendario_apicola.dart';
import '../datos/catalogos_generados/catalogo_plagas_apicolas.dart';
import '../datos/catalogos_generados/catalogo_razas_abeja.dart';
import '../datos/catalogos_generados/catalogo_sustancias_varroa.dart';
import '../datos/catalogos_generados/catalogo_tipos_colmena.dart';
import '../datos/catalogos_generados/flag_revision.dart';

/// Pantalla "Acerca de" — versión, créditos, enlaces. Pieza de pulido
/// del v0.1: el apicultor puede ver de dónde viene la app y reportar
/// problemas. Cuando llegue v1 con backend, se añade link al soporte.
class PantallaAcerca extends StatelessWidget {
  const PantallaAcerca({super.key});

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acerca_de'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icono-logo-apicultura.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Larrea Apícola',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Text('v0.1', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            SoleraL10n.t('api.acerca_descripcion'),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('api.compromisos_legales')),
          _Bullet(SoleraL10n.t('api.compromiso_1')),
          _Bullet(SoleraL10n.t('api.compromiso_2')),
          _Bullet(SoleraL10n.t('api.compromiso_3')),
          _Bullet(SoleraL10n.t('api.compromiso_4')),
          _Bullet(SoleraL10n.t('api.compromiso_5')),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('api.catalogos_curados')),
          _TarjetaCatalogos(),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('api.familia_larrea')),
          Text(
            SoleraL10n.t('api.familia_larrea_texto'),
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('api.enlaces')),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.public),
            title: const Text('coleccion-nuevo-ser.com'),
            onTap: () => _abrirUrl('https://coleccion-nuevo-ser.com/'),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCatalogos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final totalFilas = catalogoRazasAbeja.length +
        catalogoTiposColmena.length +
        catalogoSustanciasVarroa.length +
        catalogoPlagasApicolas.length +
        calendarioApicola.length;
    final color = catalogosCompletamenteRevisados ? Colors.green : Colors.amber;
    final icono = catalogosCompletamenteRevisados ? Icons.verified : Icons.fact_check;
    final etiqueta = catalogosCompletamenteRevisados
        ? SoleraL10n.t('api.catalogos_validados')
        : SoleraL10n.t('api.catalogos_provisionales');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color.shade800, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  etiqueta,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            SoleraL10n.tf('api.resumen_catalogos', {
              'total': totalFilas,
              'razas': catalogoRazasAbeja.length,
              'tipos': catalogoTiposColmena.length,
              'sustancias': catalogoSustanciasVarroa.length,
              'plagas': catalogoPlagasApicolas.length,
              'tareas': calendarioApicola.length,
            }),
            style: TextStyle(fontSize: 13, height: 1.5, color: color.shade900),
          ),
          if (!catalogosCompletamenteRevisados) ...[
            const SizedBox(height: 8),
            Text(
              SoleraL10n.t('api.catalogos_provisionales_texto'),
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String texto;
  const _Seccion(this.texto);
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

class _Bullet extends StatelessWidget {
  final String texto;
  const _Bullet(this.texto);
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
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}
