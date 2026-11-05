import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/defectos_queso.dart';
import '../datos/catalogos_generados/do_quesos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../datos/catalogos_generados/parametros_analitica.dart';
import '../datos/catalogos_generados/razas_lecheras.dart';
import '../datos/catalogos_generados/tipos_queso.dart';

/// Versión visible de la app. Se sube a mano junto con la de `pubspec.yaml`.
const versionSoleraQuesera = '0.1.9';

/// Pantalla «Acerca de»: versión, qué hace la app, compromisos legales,
/// estado de los catálogos y enlaces. Sustituye al `showAboutDialog`.
class PantallaAcerca extends StatelessWidget {
  const PantallaAcerca({super.key});


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
                  'Larrea Quesera',
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
          Text(
            SoleraL10n.t('ques.acerca_descripcion'),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('ques.compromisos_legales')),
          _Bullet(SoleraL10n.t('ques.compromiso_sin_marcas')),
          _Bullet(SoleraL10n.t('ques.compromiso_libro_trazabilidad')),
          _Bullet(SoleraL10n.t('ques.compromiso_do_etiquetado')),
          _Bullet(SoleraL10n.t('ques.compromiso_clave_anthropic')),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('ques.catalogos')),
          const _TarjetaCatalogos(),
          const SizedBox(height: 24),
          _Seccion(SoleraL10n.t('ques.familia_larrea')),
          Text(
            SoleraL10n.t('ques.familia_larrea_texto'),
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
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
        ? SoleraL10n.t('ques.catalogos_validados')
        : SoleraL10n.t('ques.catalogos_provisionales');
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
            SoleraL10n.tf('ques.catalogos_resumen', {
              'total': totalFilas,
              'tipos': todosTipoQuesos.length,
              'razas': todosRazaLecheras.length,
              'do': todosDoQuesos.length,
              'defectos': todosDefectoQuesos.length,
              'parametros': todosParametroAnaliticas.length,
            }),
            style: TextStyle(fontSize: 13, height: 1.5, color: color.shade900),
          ),
          if (!catalogosCompletamenteRevisados) ...[
            const SizedBox(height: 8),
            Text(
              SoleraL10n.t('ques.catalogos_aviso_provisional'),
              style: const TextStyle(
                  fontSize: 12, color: Colors.black87, height: 1.5),
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
