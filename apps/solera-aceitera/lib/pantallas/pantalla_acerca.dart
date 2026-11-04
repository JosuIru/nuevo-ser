import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../datos/catalogos_generados/catalogo_calendario_olivar.dart';
import '../datos/catalogos_generados/catalogo_dop_aceite.dart';
import '../datos/catalogos_generados/catalogo_fitosanitarios_olivar.dart';
import '../datos/catalogos_generados/catalogo_plagas_olivo.dart';
import '../datos/catalogos_generados/catalogo_variedades_olivo.dart';
import '../datos/catalogos_generados/flag_revision.dart';

/// Pantalla "Acerca de": qué es la app, compromisos legales, estado de
/// los catálogos y enlaces. La versión instalada está en «Comprobar
/// actualizaciones» (Ajustes), que la lee del paquete.
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
                    'assets/icono-logo-aceitera.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Larrea Aceitera',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            SoleraL10n.t('acei.acerca_intro'),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('acei.compromisos_legales')),
          _Bullet(SoleraL10n.t('acei.compromiso_fitosanitarios')),
          _Bullet(SoleraL10n.t('acei.compromiso_formato_pdf')),
          _Bullet(SoleraL10n.t('acei.compromiso_clave_anthropic')),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('acei.catalogos')),
          const _TarjetaCatalogos(),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('acei.familia_larrea')),
          Text(
            SoleraL10n.t('acei.familia_larrea_texto'),
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('acei.enlaces')),
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
  const _TarjetaCatalogos();

  @override
  Widget build(BuildContext context) {
    final totalFilas = catalogoVariedadesOlivo.length +
        catalogoPlagasOlivo.length +
        catalogoFitosanitariosOlivar.length +
        catalogoDopAceite.length +
        calendarioOlivar.length;
    final color = catalogosCompletamenteRevisados ? Colors.green : Colors.amber;
    final icono =
        catalogosCompletamenteRevisados ? Icons.verified : Icons.fact_check;
    // «Revisados» aquí es revisión documental contra fuente pública, no
    // firma de un asesor agrónomo colegiado (ver CLAUDE.md, F1-A10).
    final etiqueta = catalogosCompletamenteRevisados
        ? SoleraL10n.t('acei.catalogos_revisados')
        : SoleraL10n.t('acei.catalogos_provisionales_sin_revisar');
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
            SoleraL10n.tf('acei.catalogos_resumen', {
              'total': totalFilas,
              'variedades': catalogoVariedadesOlivo.length,
              'plagas': catalogoPlagasOlivo.length,
              'sustancias': catalogoFitosanitariosOlivar.length,
              'dop': catalogoDopAceite.length,
              'labores': calendarioOlivar.length,
            }),
            style: TextStyle(fontSize: 13, height: 1.5, color: color.shade900),
          ),
          const SizedBox(height: 8),
          Text(
            SoleraL10n.t('acei.catalogos_fuentes'),
            style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
          ),
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
          Expanded(
            child: Text(texto,
                style: const TextStyle(fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
