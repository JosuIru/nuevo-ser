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
          const Text(
            'Larrea Aceitera es un gestor para almazaras pequeñas y '
            'medianas: parcelas de olivar con GPS, recolecciones y '
            'tratamientos, recepción de partidas, molturación y lotes de '
            'aceite, libro de movimientos del aceite, cuaderno PAC del '
            'olivar en PDF, libro económico e identificación de plagas y '
            'variedades por foto con IA.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Compromisos legales'),
          const _Bullet(
            'Larrea no recomienda productos fitosanitarios comerciales por '
            'marca: el catálogo recoge sustancias activas. Consulta siempre '
            'a tu técnico de OCA o asesor agrónomo antes de aplicar.',
          ),
          const _Bullet(
            'El formato del cuaderno de explotación PAC (RD 1311/2012) y del '
            'libro de movimientos del aceite (RD 760/2021) cambia '
            'periódicamente. Los PDF llevan sello PROVISIONAL hasta su '
            'revisión profesional: verifica el formato vigente antes de '
            'presentarlos.',
          ),
          const _Bullet(
            'Tu clave Anthropic (si la configuras para IA) se guarda sólo en '
            'tu dispositivo. Las fotos se envían directamente a Anthropic, '
            'sin pasar por servidores intermedios.',
          ),
          const SizedBox(height: 24),
          const _Seccion('Catálogos'),
          const _TarjetaCatalogos(),
          const SizedBox(height: 24),
          const _Seccion('Familia Larrea'),
          const Text(
            'Larrea Aceitera es parte de la suite Larrea de la Colección '
            'Nuevo Ser. Apps hermanas: Larrea (general — frutales, trufa, '
            'olivar), Larrea Viticultura, Larrea Apícola, Larrea Arbolado '
            'Urbano y Larrea Quesera.',
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Enlaces'),
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
        ? 'Revisados contra fuente pública'
        : 'PROVISIONALES — sin revisar todavía';
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
            '$totalFilas filas en 5 catálogos: '
            '${catalogoVariedadesOlivo.length} variedades de olivo, '
            '${catalogoPlagasOlivo.length} plagas y enfermedades, '
            '${catalogoFitosanitariosOlivar.length} sustancias activas, '
            '${catalogoDopAceite.length} denominaciones de origen, '
            '${calendarioOlivar.length} labores del calendario.',
            style: TextStyle(fontSize: 13, height: 1.5, color: color.shade900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fuentes: Registro de Variedades del MAPA e IFAPA, estaciones de '
            'aviso fitosanitario, Registro de Productos Fitosanitarios del '
            'MAPA (sólo sustancias activas), BOE y reglamentos UE de las DOP. '
            'Falta la firma de un asesor agrónomo olivarero; las propuestas '
            'de la IA que coinciden con el catálogo no sustituyen a su '
            'criterio.',
            style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
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
