import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/finca.dart';
import '../servicios/servicio_meteo.dart';
import 'widgets/relleno_seguro.dart';

/// Previsión meteorológica de 7 días sobre las fincas (Open-Meteo). Útil en
/// extensivo: heladas, lluvia y viento para el manejo, traslados y puerto.
class PantallaMeteo extends StatefulWidget {
  const PantallaMeteo({super.key});

  @override
  State<PantallaMeteo> createState() => _PantallaMeteoState();
}

class _PantallaMeteoState extends State<PantallaMeteo> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _servicio = ServicioMeteo();
  // Centro aproximado de Zunbeltz como fallback si la finca no tiene coords.
  static const _latFallback = 42.793;
  static const _lonFallback = -1.958;

  List<Finca> _fincas = const [];
  int? _fincaId;
  PrevisionMeteo? _prevision;
  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _arrancar();
  }

  Future<void> _arrancar() async {
    var fincas = <Finca>[];
    try {
      fincas = await _bd.listarFincas();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _fincaId = fincas.isNotEmpty ? fincas.first.id : null;
    });
    await _cargarPrevision();
  }

  Finca? get _fincaActiva {
    for (final f in _fincas) {
      if (f.id == _fincaId) return f;
    }
    return _fincas.isNotEmpty ? _fincas.first : null;
  }

  Future<void> _cargarPrevision() async {
    setState(() {
      _cargando = true;
      _error = false;
    });
    final finca = _fincaActiva;
    final lat = finca?.latitud ?? _latFallback;
    final lon = finca?.longitud ?? _lonFallback;
    try {
      final prevision = await _servicio.obtener(latitud: lat, longitud: lon);
      if (!mounted) return;
      setState(() {
        _prevision = prevision;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.meteoTitulo),
        actions: [
          if (_fincas.length > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButton<int?>(
                value: _fincaId,
                underline: const SizedBox.shrink(),
                items: [
                  for (final f in _fincas)
                    DropdownMenuItem(value: f.id, child: Text(f.nombre)),
                ],
                onChanged: (v) {
                  setState(() => _fincaId = v);
                  _cargarPrevision();
                },
              ),
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? _Error(textos: textos, onReintentar: _cargarPrevision)
              : _Contenido(prevision: _prevision, textos: textos),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.textos, required this.onReintentar});

  final AppLocalizations textos;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(textos.meteoSinConexion, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
                onPressed: onReintentar, child: Text(textos.meteoReintentar)),
          ],
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.prevision, required this.textos});

  final PrevisionMeteo? prevision;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final dias = prevision?.dias ?? const [];
    final idioma = Localizations.localeOf(context).languageCode;
    if (dias.isEmpty) {
      return Center(child: Text(textos.meteoSinConexion));
    }
    return ListView(
      padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(12)),
      children: [
        for (var i = 0; i < dias.length; i++)
          _TarjetaDia(dia: dias[i], idioma: idioma, esHoy: i == 0, textos: textos),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Text(textos.meteoOrientativo,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _TarjetaDia extends StatelessWidget {
  const _TarjetaDia({
    required this.dia,
    required this.idioma,
    required this.esHoy,
    required this.textos,
  });

  final DiaMeteo dia;
  final String idioma;
  final bool esHoy;
  final AppLocalizations textos;

  String _num(double? v, String sufijo) =>
      v == null ? '—' : '${v.round()}$sufijo';

  @override
  Widget build(BuildContext context) {
    final etiquetaDia = esHoy
        ? textos.meteoHoy
        : toBeginningOfSentenceCase(
            DateFormat('EEEE', idioma).format(dia.fecha));
    final avisos = <_Aviso>[
      if (dia.riesgoHelada)
        _Aviso(textos.avisoHelada, const Color(0xFF6C8AA0)),
      if (dia.lluviaRelevante) _Aviso(textos.avisoLluvia, const Color(0xFF4E7A9B)),
      if (dia.vientoFuerte) _Aviso(textos.avisoViento, const Color(0xFFC99A3B)),
      if (dia.calorIntenso) _Aviso(textos.avisoCalor, const Color(0xFFB05E3B)),
      if (dia.buenDiaManejo)
        _Aviso(textos.avisoBuenManejo, const Color(0xFF5E7D3A)),
    ];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$etiquetaDia · ${DateFormat('dd/MM', idioma).format(dia.fecha)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${_num(dia.tempMax, '°')} / ${_num(dia.tempMin, '°')}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 16),
                const SizedBox(width: 4),
                Text(_num(dia.lluviaMm, ' mm')),
                const SizedBox(width: 16),
                const Icon(Icons.air, size: 16),
                const SizedBox(width: 4),
                Text(_num(dia.rachaMaxKmh, ' km/h')),
              ],
            ),
            if (avisos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [for (final a in avisos) a.build(context)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Aviso {
  _Aviso(this.texto, this.color);
  final String texto;
  final Color color;

  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(texto,
            style: const TextStyle(
                color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
      );
}
