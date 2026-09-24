import 'package:flutter/material.dart';

import '../datos/repositorio_preguntas_brecha.dart';
import '../dominio/brecha.dart';
import '../dominio/evaluador_preguntas.dart';
import '../nucleo/paleta_archivo.dart';

/// Pantalla jugable de la Fase 1 de una Brecha — formulación de
/// preguntas por la Cronista (PR.01, PR.04 del doc 02). Sustituye
/// al placeholder genérico de `PantallaBrecha` para esta fase.
///
/// El validador es algorítmico (`EvaluadorPreguntas`), no usa LLM,
/// y NO afirma nada sobre contenido histórico — sólo sobre forma:
/// longitud, signo interrogativo, partícula. La política de cierre
/// (`PoliticaCierreFormulacion`) exige mínimo 3 preguntas válidas
/// **de al menos dos categorías distintas**, para que la Cronista
/// practique variedad y no repita la misma estructura.
class FaseFormulacionPreguntas extends StatefulWidget {
  /// Brecha cuya Fase 1 se está jugando. La pantalla persiste las
  /// preguntas bajo `nuevoser.lasversiones.brecha.<id>.preguntas`.
  final Brecha brecha;

  /// Callback al que llamar cuando la Cronista considera la Fase 1
  /// terminada y la política de cierre dice que sí. El orquestador
  /// avanza la fase persistida y reabre la pantalla en Recolección.
  final VoidCallback alAvanzarFase;

  /// Repositorio de persistencia. Se inyecta para que los tests
  /// puedan usar `SharedPreferences.setMockInitialValues`.
  final RepositorioPreguntasBrecha repoPreguntas;

  /// Evaluador puro inyectado para tests. La instancia por defecto
  /// no necesita configuración.
  final EvaluadorPreguntas evaluador;

  /// Política de cierre — separable del evaluador porque puede
  /// querer endurecerse o relajarse por Brecha en el futuro.
  final PoliticaCierreFormulacion politicaCierre;

  const FaseFormulacionPreguntas({
    super.key,
    required this.brecha,
    required this.alAvanzarFase,
    required this.repoPreguntas,
    this.evaluador = const EvaluadorPreguntas(),
    this.politicaCierre = const PoliticaCierreFormulacion(),
  });

  @override
  State<FaseFormulacionPreguntas> createState() =>
      _FaseFormulacionPreguntasState();
}

class _FaseFormulacionPreguntasState extends State<FaseFormulacionPreguntas> {
  final TextEditingController _controlador = TextEditingController();
  final FocusNode _focoEntrada = FocusNode();
  List<EvaluacionPregunta> _evaluaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPreguntasPersistidas();
  }

  /// Pone el arranque elegido en la caja y deja el cursor al final para
  /// completar la pregunta. Sustituye lo que hubiera: el arranque es el
  /// principio de una pregunta nueva.
  void _empezarCon(String arranque) {
    _controlador.value = TextEditingValue(
      text: arranque,
      selection: TextSelection.collapsed(offset: arranque.length),
    );
    _focoEntrada.requestFocus();
  }

  @override
  void dispose() {
    _controlador.dispose();
    _focoEntrada.dispose();
    super.dispose();
  }

  Future<void> _cargarPreguntasPersistidas() async {
    final crudas = await widget.repoPreguntas.cargar(widget.brecha.id);
    if (!mounted) return;
    setState(() {
      _evaluaciones = crudas
          .map(widget.evaluador.evaluar)
          .toList(growable: true);
      _cargando = false;
    });
  }

  Future<void> _persistir() async {
    final textos = _evaluaciones
        .map((e) => e.textoNormalizado)
        .toList(growable: false);
    await widget.repoPreguntas.guardar(widget.brecha.id, textos);
  }

  void _alAnadir() {
    final crudo = _controlador.text;
    if (crudo.trim().isEmpty) return;
    final evaluacion = widget.evaluador.evaluar(crudo);
    setState(() {
      _evaluaciones = [..._evaluaciones, evaluacion];
      _controlador.clear();
    });
    _persistir();
    _focoEntrada.requestFocus();
  }

  void _alEliminar(int indice) {
    setState(() {
      final copia = [..._evaluaciones];
      copia.removeAt(indice);
      _evaluaciones = copia;
    });
    _persistir();
  }

  Future<void> _abrirAyudaTipos(BuildContext contexto) async {
    await showDialog<void>(
      context: contexto,
      builder: (_) => const _DialogoAyudaTipos(),
    );
  }

  @override
  Widget build(BuildContext contexto) {
    if (_cargando) {
      return const SizedBox.expand();
    }
    final razonBloqueo =
        widget.politicaCierre.razonParaNoAvanzar(_evaluaciones);
    final puedeAvanzar = razonBloqueo == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IntroFase1(alAbrirAyuda: () => _abrirAyudaTipos(contexto)),
        const SizedBox(height: 16),
        _CajaEntrada(
          controlador: _controlador,
          foco: _focoEntrada,
          alEnviar: _alAnadir,
        ),
        const SizedBox(height: 8),
        _ArranquesDePregunta(alElegir: _empezarCon),
        const SizedBox(height: 14),
        Expanded(
          child: _evaluaciones.isEmpty
              ? const _ListaPreguntasVacia()
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: _evaluaciones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, indice) => _TarjetaPregunta(
                    indice: indice,
                    evaluacion: _evaluaciones[indice],
                    alEliminar: () => _alEliminar(indice),
                  ),
                ),
        ),
        if (razonBloqueo != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              razonBloqueo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: PaletaArchivo.textoTenue.withOpacity(0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: puedeAvanzar ? widget.alAvanzarFase : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: PaletaArchivo.textoPrincipal,
              // Sin esto el texto desactivado sale casi negro sobre el fondo
              // oscuro y el botón parece vacío.
              disabledForegroundColor: PaletaArchivo.textoTenue,
              backgroundColor:
                  PaletaArchivo.fondoMedio.withOpacity(puedeAvanzar ? 0.6 : 0.3),
              side: BorderSide(
                color: PaletaArchivo.ambarLacre.withOpacity(
                  puedeAvanzar ? 0.7 : 0.3,
                ),
              ),
            ),
            child: const Text(
              'IR A LA RECOLECCIÓN',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroFase1 extends StatelessWidget {
  final VoidCallback alAbrirAyuda;

  const _IntroFase1({required this.alAbrirAyuda});

  @override
  Widget build(BuildContext contexto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Antes de tocar nada, hazte preguntas. Mínimo 3, y de 2 '
              'tipos distintos. Toca el "?" para ver los tipos.',
              style: TextStyle(
                fontSize: 14,
                color: PaletaArchivo.textoPrincipal.withOpacity(0.95),
                height: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Tipos de pregunta',
          icon: const Icon(
            Icons.help_outline,
            color: PaletaArchivo.ambarLacre,
            size: 22,
          ),
          onPressed: alAbrirAyuda,
        ),
      ],
    );
  }
}

/// Diálogo con los cuatro tipos de pregunta del oficio. Muestra
/// nombre claro, una frase corta y dos ejemplos por tipo. La idea es
/// que la Cronista pueda volver aquí cuando dude — el sistema no le
/// dice qué pregunta hacer, le enseña los tipos para que ella elija.
class _DialogoAyudaTipos extends StatelessWidget {
  const _DialogoAyudaTipos();

  @override
  Widget build(BuildContext contexto) {
    return Dialog(
      backgroundColor: PaletaArchivo.fondoProfundo,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'TIPOS DE PREGUNTA',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 4,
                  color: PaletaArchivo.ambarLacre.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'El oficio del cronista usa cuatro tipos de pregunta. '
                'Una buena investigación los combina.',
                style: TextStyle(
                  fontSize: 13,
                  color: PaletaArchivo.textoPrincipal.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              const _BloqueTipo(
                titulo: 'PREGUNTA DE DATO',
                pista: 'qué, cuándo, dónde, quién, cuántos…',
                explicacion:
                    'Pides algo concreto que se puede comprobar. Es un '
                    'buen punto de partida.',
                ejemplos: [
                  '¿Quién construyó este dolmen?',
                  '¿Cuándo se hizo?',
                ],
              ),
              const _BloqueTipo(
                titulo: 'PREGUNTA DE CAUSA',
                pista: 'por qué, a qué se debe, qué provocó…',
                explicacion:
                    'Pides el porqué. Conectas hechos: por qué pasó '
                    'esto y no otra cosa.',
                ejemplos: [
                  '¿Por qué eligieron este sitio y no otro?',
                  '¿Qué provocó que dejaran de usarlo?',
                ],
              ),
              const _BloqueTipo(
                titulo: 'PREGUNTA DE QUIÉN MIRA',
                pista:
                    'desde qué perspectiva, qué intereses, qué se omite…',
                explicacion:
                    'Te fijas en quién cuenta la historia, desde dónde '
                    'la cuenta, o en lo que no aparece. Esto distingue '
                    'al oficio.',
                ejemplos: [
                  '¿Quién escribió esta crónica y para quién?',
                  '¿Qué voces faltan en estos documentos?',
                ],
              ),
              const _BloqueTipo(
                titulo: 'PREGUNTA DE CÓMO LO SABEMOS',
                pista: 'qué evidencia, qué prueba, qué fuente, cómo se sabe…',
                explicacion:
                    'Pones a prueba lo que damos por sabido. Difícil y '
                    'muy valiosa.',
                ejemplos: [
                  '¿Qué prueba hay de que vivieron aquí?',
                  '¿Cómo sabemos la fecha de este resto?',
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(contexto).maybePop(),
                  child: const Text(
                    'CERRAR',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      color: PaletaArchivo.ambarLacre,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BloqueTipo extends StatelessWidget {
  final String titulo;
  final String pista;
  final String explicacion;
  final List<String> ejemplos;

  const _BloqueTipo({
    required this.titulo,
    required this.pista,
    required this.explicacion,
    required this.ejemplos,
  });

  @override
  Widget build(BuildContext contexto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 3,
              color: PaletaArchivo.ambarLacre,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Empieza por: $pista',
            style: TextStyle(
              fontSize: 12,
              color: PaletaArchivo.textoTenue.withOpacity(0.85),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            explicacion,
            style: const TextStyle(
              fontSize: 13,
              color: PaletaArchivo.textoPrincipal,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          for (final ejemplo in ejemplos)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text(
                '· $ejemplo',
                style: TextStyle(
                  fontSize: 13,
                  color: PaletaArchivo.textoPrincipal.withOpacity(0.85),
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Arranques de pregunta para no empezar con la caja en blanco. Uno
/// por tipo que reconoce el evaluador (dato, causa, quién mira, cómo lo
/// sabemos): con dos arranques distintos ya se cumplen los «2 tipos».
/// La pregunta la termina la Cronista; el arranque no cuenta solo
/// (el evaluador exige 12 caracteres).
class _ArranquesDePregunta extends StatelessWidget {
  const _ArranquesDePregunta({required this.alElegir});

  final ValueChanged<String> alElegir;

  static const arranques = [
    '¿Quién ',
    '¿Cuándo ',
    '¿Por qué ',
    '¿Cómo sabemos ',
    '¿Qué falta en ',
  ];

  @override
  Widget build(BuildContext contexto) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final arranque in arranques)
          ActionChip(
            label: Text('${arranque.trim()}…'),
            labelStyle: const TextStyle(fontSize: 13, color: PaletaArchivo.textoPrincipal),
            backgroundColor: PaletaArchivo.fondoMedio,
            side: BorderSide(color: PaletaArchivo.ambarLacre.withValues(alpha: 0.45)),
            onPressed: () => alElegir(arranque),
          ),
      ],
    );
  }
}

class _CajaEntrada extends StatelessWidget {
  final TextEditingController controlador;
  final FocusNode foco;
  final VoidCallback alEnviar;

  const _CajaEntrada({
    required this.controlador,
    required this.foco,
    required this.alEnviar,
  });

  @override
  Widget build(BuildContext contexto) {
    return Container(
      decoration: BoxDecoration(
        color: PaletaArchivo.fondoMedio.withOpacity(0.55),
        border: Border.all(
          color: PaletaArchivo.ambarLacre.withOpacity(0.45),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controlador,
              focusNode: foco,
              maxLines: 3,
              minLines: 1,
              style: TextStyle(
                fontSize: 15,
                color: PaletaArchivo.textoPrincipal.withOpacity(0.95),
                height: 1.4,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Escribe una pregunta…',
                hintStyle: TextStyle(
                  color: PaletaArchivo.textoTenue.withOpacity(0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => alEnviar(),
            ),
          ),
          IconButton(
            tooltip: 'Añadir',
            icon: const Icon(
              Icons.add_circle_outline,
              color: PaletaArchivo.ambarLacre,
            ),
            onPressed: alEnviar,
          ),
        ],
      ),
    );
  }
}

class _TarjetaPregunta extends StatelessWidget {
  final int indice;
  final EvaluacionPregunta evaluacion;
  final VoidCallback alEliminar;

  const _TarjetaPregunta({
    required this.indice,
    required this.evaluacion,
    required this.alEliminar,
  });

  @override
  Widget build(BuildContext contexto) {
    final colorAcento = evaluacion.esValida
        ? PaletaArchivo.ambarLacre
        : PaletaArchivo.tintaTenue.withOpacity(0.55);
    return Container(
      decoration: BoxDecoration(
        color: PaletaArchivo.fondoMedio.withOpacity(0.4),
        border: Border(
          left: BorderSide(color: colorAcento, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${indice + 1}.',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: PaletaArchivo.ambarLacre,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _etiquetaTipo(evaluacion.tipo, evaluacion.esValida)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: colorAcento,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  evaluacion.textoNormalizado,
                  style: TextStyle(
                    fontSize: 15,
                    color: PaletaArchivo.textoPrincipal.withOpacity(0.95),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  evaluacion.mensajePedagogico,
                  style: TextStyle(
                    fontSize: 12,
                    color: PaletaArchivo.textoTenue.withOpacity(0.85),
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: Icon(
              Icons.close,
              size: 18,
              color: PaletaArchivo.textoTenue.withOpacity(0.7),
            ),
            onPressed: alEliminar,
          ),
        ],
      ),
    );
  }

  String _etiquetaTipo(TipoPregunta tipo, bool esValida) {
    if (!esValida) return 'no admitida';
    switch (tipo) {
      case TipoPregunta.factual:
        return 'Dato';
      case TipoPregunta.causal:
        return 'Causa';
      case TipoPregunta.perspectiva:
        return 'Quién mira';
      case TipoPregunta.metodologica:
        return 'Cómo lo sabemos';
      case TipoPregunta.indeterminada:
        return 'Aceptada';
    }
  }
}

class _ListaPreguntasVacia extends StatelessWidget {
  const _ListaPreguntasVacia();

  @override
  Widget build(BuildContext contexto) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Aún no has formulado ninguna pregunta. Empieza por lo que '
          'más te llama la atención: ¿qué quieres saber? ¿quién? '
          '¿por qué?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: PaletaArchivo.textoTenue.withOpacity(0.85),
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
