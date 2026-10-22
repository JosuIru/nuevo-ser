import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../datos/catalogos_generados/catalogo_bbch.dart';
import '../datos/catalogos_generados/catalogo_materias_activas.dart';
import '../datos/catalogos_generados/catalogo_plagas_vid.dart';
import '../datos/catalogos_generados/catalogo_portainjertos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../datos/catalogos_generados/flag_revision.dart';

/// Pantalla "Acerca de" — versión, créditos, enlaces. Pieza de
/// pulido del v0.1: el viticultor puede ver de dónde viene la app y
/// reportar problemas. Cuando llegue v1 con backend, se añade
/// link al soporte.
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
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icono-log-viticultura.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Solera Viticultura',
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
          const Text(
            'Solera Viticultura es un gestor para bodegas pequeñas y '
            'medianas: censo de cepas con GPS, anotación de cosechas, '
            'observaciones, incidencias y tratamientos, identificación '
            'de plagas por foto con IA y libro oficial PAC en PDF '
            'firmable.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Compromisos legales'),
          const _Bullet(
            'Solera no recomienda productos fitosanitarios comerciales. '
            'Consulta siempre a tu técnico de cooperativa, ATRIA o '
            'asesor enológico antes de aplicar.',
          ),
          const _Bullet(
            'El formato del libro oficial PAC (RD 1311/2012) cambia '
            'periódicamente. Verifica el formato vigente del MAPA '
            'antes de presentar el documento en inspección.',
          ),
          const _Bullet(
            'Tu clave Anthropic (si la configuras para IA) se guarda '
            'sólo en tu dispositivo. Las fotos se envían directamente '
            'a Anthropic, sin pasar por servidores intermedios.',
          ),
          const SizedBox(height: 24),
          const _Seccion('Catálogos curados'),
          _TarjetaCatalogos(),
          const SizedBox(height: 24),
          const _Seccion('Familia Solera'),
          const Text(
            'Solera Viticultura es parte de la suite Solera del monorepo '
            'Colección Nuevo Ser. Otras apps hermanas en desarrollo: '
            'Solera (general — frutales, trufa, olivar), Solera Apícola '
            '(libro REGA), Solera Arbolado Urbano (B2B municipal).',
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
  @override
  Widget build(BuildContext context) {
    final totalFilas = catalogoVariedades.length +
        catalogoPortainjertos.length +
        catalogoPlagasVid.length +
        catalogoMateriasActivas.length +
        calendarioFenologicoBbch.length;
    final color = catalogosCompletamenteRevisados ? Colors.green : Colors.amber;
    final icono = catalogosCompletamenteRevisados ? Icons.verified : Icons.fact_check;
    final etiqueta = catalogosCompletamenteRevisados
        ? 'Validados agronómica y enológicamente'
        : 'PROVISIONALES — sin validar todavía';
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
            '${catalogoVariedades.length} variedades, '
            '${catalogoPortainjertos.length} portainjertos, '
            '${catalogoPlagasVid.length} plagas/enfermedades, '
            '${catalogoMateriasActivas.length} materias activas, '
            '${calendarioFenologicoBbch.length} estados BBCH.',
            style: TextStyle(fontSize: 13, height: 1.5, color: color.shade900),
          ),
          if (!catalogosCompletamenteRevisados) ...[
            const SizedBox(height: 8),
            const Text(
              'Pre-rellenados a partir de fuentes públicas (MAPA, OIVE, '
              'FAO BBCH). Antes de pasar a producción comercial deben ser '
              'validados por un enólogo + un agrónomo. Las propuestas de '
              'la IA que coincidan con el catálogo se marcan como '
              '"provisionales", no como validadas.',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
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
