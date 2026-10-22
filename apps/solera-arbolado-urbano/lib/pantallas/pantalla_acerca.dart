import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../datos/catalogos_generados/catalogo_calendario_arbolado.dart';
import '../datos/catalogos_generados/catalogo_especies_arboreas.dart';
import '../datos/catalogos_generados/catalogo_plagas_urbanas.dart';
import '../datos/catalogos_generados/catalogo_sustratos_alcorque.dart';
import '../datos/catalogos_generados/catalogo_tipos_poda.dart';
import '../datos/catalogos_generados/flag_revision.dart';

/// Pantalla "Acerca de" — versión, créditos, enlaces, compromisos
/// legales explícitos sobre privacidad ciudadana, declaración
/// obligatoria y formato municipal.
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
                    'assets/icono-logo-arbol-hurbano.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Solera Arbolado Urbano',
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
            'Solera Arbolado Urbano es un gestor para ayuntamientos pequeños y '
            'medianos + empresas de jardinería que cuidan el arbolado público: '
            'inventario por chapa QR, ficha individual de cada árbol con timeline, '
            'partes de poda con fotos antes/después, identificación de plagas con '
            'IA y exportación de informes municipales en PDF.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Compromisos legales'),
          const _Bullet(
            'Solera no recomienda productos fitosanitarios comerciales. '
            'Los tratamientos requieren carnet de aplicador y se registran '
            'con sustancia activa, dosis, lote y factura para auditoría '
            'municipal.',
          ),
          const _Bullet(
            'Las plagas de declaración obligatoria (picudo rojo, fuego '
            'bacteriano, escarabajo de las colmenas) deben notificarse a '
            'los Servicios Fitosanitarios oficiales de la CCAA.',
          ),
          const _Bullet(
            'Las plagas con riesgo sanitario público (procesionaria del '
            'pino, lagarta peluda) se priorizan en zonas escolares y '
            'paseos peatonales.',
          ),
          const _Bullet(
            'El riesgo VTA (Visual Tree Assessment) es responsabilidad '
            'del técnico cualificado. La app facilita el registro pero NO '
            'emite dictámenes — la decisión de talar es siempre humana y '
            'firmada.',
          ),
          const _Bullet(
            'Privacidad ciudadana: las fotos pueden capturar transeúntes. '
            'Encuadra al árbol; las imágenes sólo se envían a Anthropic '
            'cuando usas el botón de IA y por elección explícita del operario.',
          ),
          const _Bullet(
            'El formato del informe municipal varía entre ayuntamientos. '
            'Verifica el pliego técnico antes de presentar.',
          ),
          const SizedBox(height: 24),
          const _Seccion('Catálogos curados'),
          _TarjetaCatalogos(),
          const SizedBox(height: 24),
          const _Seccion('Familia Solera'),
          const Text(
            'Solera Arbolado Urbano es parte de la suite Solera del monorepo '
            'Colección Nuevo Ser. Otras apps hermanas: Solera Viticultura '
            '(libro PAC en bodegas), Solera Apícola (libro REGA en '
            'apicultura), Solera (general — frutales, trufa, olivar).',
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
    final totalFilas = catalogoEspeciesArboreas.length +
        catalogoPlagasUrbanas.length +
        catalogoTiposPoda.length +
        catalogoSustratosAlcorque.length +
        calendarioArbolado.length;
    final color = catalogosCompletamenteRevisados ? Colors.green : Colors.amber;
    final icono = catalogosCompletamenteRevisados ? Icons.verified : Icons.fact_check;
    final etiqueta = catalogosCompletamenteRevisados
        ? 'Validados por ingeniero técnico forestal'
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
            '${catalogoEspeciesArboreas.length} especies, '
            '${catalogoPlagasUrbanas.length} plagas/patologías, '
            '${catalogoTiposPoda.length} tipos de poda, '
            '${catalogoSustratosAlcorque.length} sustratos, '
            '${calendarioArbolado.length} tareas de calendario.',
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          if (!catalogosCompletamenteRevisados) ...[
            const SizedBox(height: 8),
            const Text(
              'Pre-rellenados a partir de fuentes públicas (manuales de '
              'jardinería urbana, pliegos de ayuntamientos, boletines '
              'fitosanitarios autonómicos). Antes de pasar a producción '
              'comercial deben ser validados por un ingeniero técnico '
              'forestal o de jardinería con experiencia urbana.',
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
