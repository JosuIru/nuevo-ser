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
          const Text(
            'Larrea Apícola es un gestor para apicultores profesionales y semi-profesionales: '
            'censo de colmenas con matrícula y GPS, registro de revisiones, cosechas, '
            'tratamientos sanitarios e incidencias, gestión de trashumancia, '
            'identificación de patologías por foto con IA y libro oficial REGA en PDF '
            'firmable.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Compromisos legales'),
          const _Bullet(
            'Larrea no recomienda medicamentos zoosanitarios comerciales '
            '(Apivar, ApiBioxal, Polyvar…). Sólo lista sustancias activas '
            'autorizadas. Cualquier tratamiento sanitario requiere receta '
            'del veterinario asesor.',
          ),
          const _Bullet(
            'Las patologías de declaración obligatoria (loque americana, '
            'escarabajo de las colmenas, vespa velutina) deben notificarse '
            'a los Servicios Veterinarios oficiales de la CCAA.',
          ),
          const _Bullet(
            'El formato del libro oficial REGA / SITRAN-AP cambia '
            'periódicamente y tiene desarrollos autonómicos (Andalucía, '
            'Galicia, Castilla-La Mancha). Verifica el formato vigente '
            'antes de presentar el documento en inspección.',
          ),
          const _Bullet(
            'Tu clave Anthropic (si la configuras para IA) se guarda sólo '
            'en tu dispositivo. Las fotos se envían directamente a '
            'Anthropic, sin pasar por servidores intermedios.',
          ),
          const _Bullet(
            'El libro económico (ingresos, gastos, modelo 347, extracto '
            'anual) es PROVISIONAL hasta que un asesor fiscal valide el '
            'formato. Es una herramienta de apoyo para tu gestoría — un '
            'error en el extracto fiscal cuesta dinero con Hacienda. '
            'Contrasta cada apunte con tu asesor antes de presentar nada.',
          ),
          const SizedBox(height: 24),
          const _Seccion('Catálogos curados'),
          _TarjetaCatalogos(),
          const SizedBox(height: 24),
          const _Seccion('Familia Larrea'),
          const Text(
            'Larrea Apícola es parte de la suite Larrea del monorepo '
            'Colección Nuevo Ser. Otras apps hermanas: Larrea Viticultura '
            '(libro PAC en bodegas), Larrea (general — frutales, trufa, '
            'olivar), Larrea Arbolado Urbano (B2B municipal — en desarrollo).',
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
    final totalFilas = catalogoRazasAbeja.length +
        catalogoTiposColmena.length +
        catalogoSustanciasVarroa.length +
        catalogoPlagasApicolas.length +
        calendarioApicola.length;
    final color = catalogosCompletamenteRevisados ? Colors.green : Colors.amber;
    final icono = catalogosCompletamenteRevisados ? Icons.verified : Icons.fact_check;
    final etiqueta = catalogosCompletamenteRevisados
        ? 'Validados por veterinario apícola y apicultor asesor'
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
            '${catalogoRazasAbeja.length} razas, '
            '${catalogoTiposColmena.length} tipos de colmena, '
            '${catalogoSustanciasVarroa.length} sustancias varroa, '
            '${catalogoPlagasApicolas.length} plagas/patologías, '
            '${calendarioApicola.length} tareas de calendario.',
            style: TextStyle(fontSize: 13, height: 1.5, color: color.shade900),
          ),
          if (!catalogosCompletamenteRevisados) ...[
            const SizedBox(height: 8),
            const Text(
              'Pre-rellenados a partir de fuentes públicas (textos sanitarios '
              'apícolas, MAPA, manuales de apicultura ibérica). Antes de pasar '
              'a producción comercial deben ser validados por un veterinario '
              'apícola + un apicultor experimentado. Las propuestas de la IA '
              'que coincidan con el catálogo se marcan como "provisionales", '
              'no como validadas.',
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
