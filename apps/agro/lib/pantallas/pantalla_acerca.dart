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
const versionVisibleAgro = '0.3.4';

/// Pantalla «Acerca de»: qué es Solera, sus compromisos legales, el estado
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
                  'Solera',
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
          const Text(
            'Solera es un gestor de fincas agrícolas: frutales, trufas, '
            'olivar, pistacho y dehesa. Cada planta tiene su ficha con GPS '
            'e historial de cosechas, observaciones, incidencias y '
            'tratamientos; recorridos de inspección, identificación de '
            'plagas por foto con IA, cuaderno de explotación MAPA en PDF, '
            'facturas y libro económico.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Compromisos legales'),
          const _Vineta(
            'Solera no recomienda productos fitosanitarios comerciales. '
            'Consulta siempre a tu técnico, cooperativa o asesor antes '
            'de aplicar.',
          ),
          const _Vineta(
            'El formato del cuaderno de explotación (RD 1311/2012) cambia '
            'periódicamente. Verifica el formato vigente del MAPA antes de '
            'presentar el documento en una inspección.',
          ),
          const _Vineta(
            'La configuración fiscal y el libro económico son PROVISIONALES '
            'hasta que los revise un asesor fiscal.',
          ),
          const _Vineta(
            'Tu clave Anthropic (si la configuras para IA) se guarda sólo '
            'en tu dispositivo. Las fotos se envían directamente a '
            'Anthropic, sin pasar por servidores intermedios.',
          ),
          const SizedBox(height: 24),
          const _Seccion('Catálogos'),
          const _TarjetaCatalogos(),
          const SizedBox(height: 24),
          const _Seccion('Familia Solera'),
          const Text(
            'Solera forma parte de la suite Solera de la Colección Nuevo '
            'Ser, con apps hermanas especializadas: Solera Viticultura, '
            'Solera Apícola, Solera Arbolado Urbano, Solera Quesera y '
            'Solera Aceitera.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _Seccion('Enlaces'),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.public),
            title: SelectableText('https://coleccion-nuevo-ser.com/'),
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
                  'PROVISIONALES — sin validar todavía',
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
            '${catalogoCultivos.length} cultivos, '
            '${catalogoPlagas.length} plagas y enfermedades, '
            '${catalogoFitosanitarios.length} productos fitosanitarios '
            'de referencia y calendario fenológico de '
            '${calendarioFenologico.length} cultivos.',
            style: TextStyle(
                fontSize: 13, height: 1.5, color: colorAviso.shade900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Semilla curada a partir de fuentes públicas (MAPA y otras). '
            'Antes de pasar a producción comercial deben revisarla un '
            'agrónomo y un técnico; los números de registro de los '
            'productos son de ejemplo: comprueba siempre el del envase.',
            style: TextStyle(fontSize: 12, height: 1.5),
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
