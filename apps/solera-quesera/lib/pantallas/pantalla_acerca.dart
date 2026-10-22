import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../datos/catalogos_generados/defectos_queso.dart';
import '../datos/catalogos_generados/do_quesos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../datos/catalogos_generados/parametros_analitica.dart';
import '../datos/catalogos_generados/razas_lecheras.dart';
import '../datos/catalogos_generados/tipos_queso.dart';

/// Versión visible de la app. Se sube a mano junto con la de `pubspec.yaml`.
const versionSoleraQuesera = '0.1.5';

/// Pantalla «Acerca de»: versión, qué hace la app, compromisos legales,
/// estado de los catálogos y enlaces. Sustituye al `showAboutDialog`.
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
                    'assets/icono-logo-quesera.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Solera Quesera',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Text('v$versionSoleraQuesera',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Solera Quesera es un gestor para queserías artesanas: '
            'recepción de leche por proveedor, lotes de producción, '
            'afinado pieza a pieza en la cava, controles APPCC, perfiles '
            'de Denominación de Origen, identificación de defectos por '
            'foto con IA y libro de trazabilidad en PDF.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Compromisos legales'),
          const _Bullet(
            'Solera no recomienda fermentos, cuajos ni aditivos '
            'comerciales por marca: el catálogo recoge tipos, no '
            'productos. Consulta a tu técnico o proveedor.',
          ),
          const _Bullet(
            'El libro de trazabilidad debe ajustarse al RGSEAA, al '
            'Reglamento (CE) 853/2004 y a la normativa de tu comunidad '
            'autónoma. Verifica el formato con tu inspección antes de '
            'presentarlo.',
          ),
          const _Bullet(
            'Los requisitos de cada DO salen de su pliego de condiciones. '
            'El etiquetado que genera la app no es vinculante: revísalo '
            'antes de imprimir.',
          ),
          const _Bullet(
            'Tu clave Anthropic (si la configuras para IA) se guarda '
            'sólo en tu dispositivo. Las fotos se envían directamente '
            'a Anthropic, sin pasar por servidores intermedios.',
          ),
          const SizedBox(height: 24),
          const _Seccion('Catálogos'),
          const _TarjetaCatalogos(),
          const SizedBox(height: 24),
          const _Seccion('Familia Solera'),
          const Text(
            'Solera Quesera es parte de la suite Solera de la Colección '
            'Nuevo Ser. Apps hermanas: Solera (fincas agrícolas), Solera '
            'Viticultura, Solera Apícola, Solera Arbolado Urbano y '
            'Solera Aceitera.',
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
    final totalFilas = todosTipoQuesos.length +
        todosRazaLecheras.length +
        todosDoQuesos.length +
        todosDefectoQuesos.length +
        todosParametroAnaliticas.length;
    final color = catalogosCompletamenteRevisados ? Colors.green : Colors.amber;
    final icono =
        catalogosCompletamenteRevisados ? Icons.verified : Icons.fact_check;
    final etiqueta = catalogosCompletamenteRevisados
        ? 'Validados por asesoría quesera'
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
            '${todosTipoQuesos.length} tipos de queso, '
            '${todosRazaLecheras.length} razas lecheras, '
            '${todosDoQuesos.length} denominaciones de origen, '
            '${todosDefectoQuesos.length} defectos, '
            '${todosParametroAnaliticas.length} parámetros de analítica.',
            style: TextStyle(fontSize: 13, height: 1.5, color: color.shade900),
          ),
          if (!catalogosCompletamenteRevisados) ...[
            const SizedBox(height: 8),
            const Text(
              'Pre-rellenados a partir de fuentes públicas. Antes de pasar a '
              'producción comercial deben validarlos una asesoría quesera '
              'y los consejos reguladores. Las propuestas de la IA que '
              'coincidan con el catálogo se marcan como provisionales.',
              style:
                  TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
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
          Expanded(
              child: Text(texto,
                  style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}
