import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../dominio/pregunta_del_nino.dart';
import '../../dominio/repositorio_local.dart';
import '../../nucleo/i18n/generado/textos_app.dart';
import '../tema/colores.dart';
import '../tema/tipografia.dart';

/// Pantalla donde el niño formula una pregunta nueva, paralela al
/// catálogo de Misterios pero suya. Por defecto el campo es **libre**:
/// no se le impone formato. El botón discreto "necesito ideas" abre una
/// hoja con cinco esqueletos opcionales que el niño puede pulsar para
/// arrancar — pero nunca insiste, nunca aparece sin que él lo pida
/// (biblia §2.7 ritmo respetuoso).
///
/// **Lectura/escritura puras**: la pantalla devuelve la nueva
/// [PreguntaDelNino] vía `Navigator.pop` para que el caller refresque
/// listados sin cargas extra.
class PantallaFormularPregunta extends StatefulWidget {
  const PantallaFormularPregunta({
    super.key,
    required this.repositorio,
    DateTime Function()? proveedorAhora,
    String Function()? proveedorIds,
  })  : _proveedorAhora = proveedorAhora ?? DateTime.now,
        _proveedorIds = proveedorIds ?? _generarUuid;

  final RepositorioLocal repositorio;

  final DateTime Function() _proveedorAhora;
  final String Function() _proveedorIds;

  static String _generarUuid() => const Uuid().v4();

  @override
  State<PantallaFormularPregunta> createState() =>
      _EstadoPantallaFormularPregunta();
}

class _EstadoPantallaFormularPregunta
    extends State<PantallaFormularPregunta> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController();
    _controlador.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  bool get _puedeGuardar => _controlador.text.trim().isNotEmpty;

  Future<void> _abrirHojaIdeas(TextosApp textos) async {
    // Lista de esqueletos provisional. Si la asesoría didáctica B1 los
    // valida o sustituye, sólo cambian los strings — la mecánica no.
    final ideas = <String>[
      textos.preguntaIdea1,
      textos.preguntaIdea2,
      textos.preguntaIdea3,
      textos.preguntaIdea4,
      textos.preguntaIdea5,
    ];

    final elegida = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: PaletaCuaderno.papelClaro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // Con la barra de navegación de Android (edge-to-edge, Android 15+)
      // las cinco ideas no cabían en el alto por defecto de la hoja y la
      // última quedaba cortada: la hoja crece lo que necesite (sin pasar
      // de la barra de estado) y, si aún no cabe, se desplaza.
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  textos.preguntaIdeasTitulo,
                  style: TipografiaCuaderno.serif(
                    color: PaletaCuaderno.tinta,
                    tamano: TipografiaCuaderno.tamano17,
                    peso: TipografiaCuaderno.pesoMedio,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  textos.preguntaIdeasIntro,
                  style: TipografiaCuaderno.serif(
                    color: PaletaCuaderno.tintaTenue,
                    tamano: TipografiaCuaderno.tamano13,
                    altoLinea: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                for (final idea in ideas) ...[
                  _BotonIdea(
                    texto: idea,
                    alPulsar: () => Navigator.of(sheetContext).pop(idea),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (elegida == null) return;
    // El esqueleto se inserta como punto de partida. El niño borra y
    // reescribe libremente — no es plantilla obligatoria.
    _controlador.text = elegida;
    _controlador.selection = TextSelection.collapsed(
      offset: _controlador.text.length,
    );
  }

  Future<void> _guardar() async {
    if (!_puedeGuardar) return;
    final pregunta = PreguntaDelNino(
      id: widget._proveedorIds(),
      pregunta: _controlador.text.trim(),
      formuladaEn: widget._proveedorAhora(),
    );
    await widget.repositorio.guardarPreguntaDelNino(pregunta);
    if (!mounted) return;
    Navigator.of(context).pop(pregunta);
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = TextosApp.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(textos.preguntaFormularTitulo)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                textos.preguntaFormularIntro,
                style: TipografiaCuaderno.serif(
                  color: PaletaCuaderno.tintaTenue,
                  tamano: TipografiaCuaderno.tamano13,
                  altoLinea: 1.55,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _controlador,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  maxLength: 500,
                  buildCounter: (_,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) =>
                      null,
                  style: TipografiaCuaderno.serif(
                    color: esquema.onSurface,
                    tamano: TipografiaCuaderno.tamano16,
                    altoLinea: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: textos.preguntaFormularPlaceholder,
                    hintStyle: TipografiaCuaderno.serif(
                      color: PaletaCuaderno.tintaTenue,
                      tamano: TipografiaCuaderno.tamano16,
                    ).copyWith(fontStyle: FontStyle.italic),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: esquema.outline),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _abrirHojaIdeas(textos),
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: Text(textos.preguntaFormularBotonIdeas),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _puedeGuardar ? _guardar : null,
                  child: Text(textos.preguntaFormularBotonGuardar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonIdea extends StatelessWidget {
  const _BotonIdea({required this.texto, required this.alPulsar});

  final String texto;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: alPulsar,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        side: const BorderSide(color: PaletaCuaderno.papelOscuro),
      ),
      child: Text(
        texto,
        style: TipografiaCuaderno.serif(
          color: PaletaCuaderno.tinta,
          tamano: TipografiaCuaderno.tamano14,
          altoLinea: 1.4,
        ),
      ),
    );
  }
}
