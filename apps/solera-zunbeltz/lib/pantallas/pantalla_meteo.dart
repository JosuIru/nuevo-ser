import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/finca.dart';
import '../servicios/servicio_meteo.dart';
import '../utiles/descripcion_tiempo.dart';
import 'widgets/relleno_seguro.dart';

/// Previsión meteorológica sobre las fincas (Open-Meteo). Útil en extensivo:
/// heladas, nieve, tormentas, lluvia y viento para el manejo, los traslados
/// y el puerto; balance de agua para el pasto y las balsas. Sin cobertura
/// muestra la última previsión guardada.
class PantallaMeteo extends StatefulWidget {
  const PantallaMeteo({super.key, this.fincas, this.servicio, this.reloj});

  /// Inyectables para los tests; por defecto, las fincas de la BD,
  /// Open-Meteo y la hora real.
  final List<Finca>? fincas;
  final ServicioMeteo? servicio;
  final DateTime Function()? reloj;

  @override
  State<PantallaMeteo> createState() => _PantallaMeteoState();
}

class _PantallaMeteoState extends State<PantallaMeteo> {
  final _bd = BaseDatosSoleraZunbeltz();
  late final _servicio = widget.servicio ?? ServicioMeteo();
  // Centro aproximado de Zunbeltz como fallback si la finca no tiene coords.
  static const _latFallback = 42.793;
  static const _lonFallback = -1.958;

  List<Finca> _fincas = const [];
  int? _fincaId;
  ResultadoMeteo? _resultado;
  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _arrancar();
  }

  Future<void> _arrancar() async {
    var fincas = widget.fincas ?? <Finca>[];
    if (widget.fincas == null) {
      try {
        fincas = await _bd.listarFincas();
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _fincaId = fincas.isNotEmpty ? fincas.first.id : null;
    });
    await _cargarPrevision();
  }

  Finca? get _fincaActiva {
    for (final finca in _fincas) {
      if (finca.id == _fincaId) return finca;
    }
    return _fincas.isNotEmpty ? _fincas.first : null;
  }

  Future<void> _cargarPrevision() async {
    setState(() {
      _cargando = _resultado == null;
      _error = false;
    });
    final finca = _fincaActiva;
    try {
      final resultado = await _servicio.obtener(
        latitud: finca?.latitud ?? _latFallback,
        longitud: finca?.longitud ?? _lonFallback,
      );
      if (!mounted) return;
      setState(() {
        _resultado = resultado;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _resultado == null;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final resultado = _resultado;
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
                  for (final finca in _fincas)
                    DropdownMenuItem(value: finca.id, child: Text(finca.nombre)),
                ],
                onChanged: (fincaElegida) {
                  setState(() {
                    _fincaId = fincaElegida;
                    _resultado = null;
                  });
                  _cargarPrevision();
                },
              ),
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : (_error || resultado == null)
              ? _Error(textos: textos, onReintentar: _cargarPrevision)
              : RefreshIndicator(
                  onRefresh: _cargarPrevision,
                  child: _Contenido(
                    ahora: (widget.reloj ?? DateTime.now)(),
                    prevision: resultado.prevision,
                    desdeCache: resultado.desdeCache,
                    textos: textos,
                  ),
                ),
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
  const _Contenido({
    required this.ahora,
    required this.prevision,
    required this.desdeCache,
    required this.textos,
  });

  final DateTime ahora;
  final PrevisionMeteo prevision;
  final bool desdeCache;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final idioma = Localizations.localeOf(context).languageCode;
    final dias = prevision.diasDesde(ahora);
    final horas = prevision.proximasHoras(ahora);
    final estilos = Theme.of(context).textTheme;
    final momentoActualizado =
        DateFormat('dd/MM HH:mm', idioma).format(prevision.actualizado);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(12)),
      children: [
        if (desdeCache)
          _Banda(
            icono: Icons.cloud_off_outlined,
            texto: textos.meteoGuardada(momentoActualizado),
          ),
        if (prevision.actual != null && !desdeCache)
          _TarjetaAhora(
            actual: prevision.actual!,
            hoy: dias.isEmpty ? null : dias.first,
            altitudM: prevision.altitudM,
            idioma: idioma,
            textos: textos,
          ),
        if (horas.isNotEmpty) ...[
          _Titulo(textos.meteoProximasHoras),
          _FranjaHoras(horas: horas, idioma: idioma),
        ],
        _TarjetaAgua(prevision: prevision, ahora: ahora, textos: textos),
        if (dias.isNotEmpty) _Titulo(textos.meteoDiasTitulo),
        for (var i = 0; i < dias.length; i++)
          _TarjetaDia(
              dia: dias[i], idioma: idioma, esHoy: i == 0, textos: textos),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Text(
            [
              if (!desdeCache) textos.meteoActualizado(momentoActualizado),
              textos.meteoOrientativo,
              textos.meteoThiNota,
            ].join(' '),
            style: estilos.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 6),
        child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Banda extends StatelessWidget {
  const _Banda({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: colorPapelHundidoZunbeltz,
          border: Border(left: BorderSide(color: colorSenalZunbeltz, width: 3)),
        ),
        child: Row(
          children: [
            Icon(icono, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(texto)),
          ],
        ),
      );
}

IconData _iconoTiempo(int? codigo, {bool deDia = true}) {
  switch (familiaTiempo(codigo)) {
    case FamiliaTiempo.despejado:
      return deDia ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;
    case FamiliaTiempo.pocoNuboso:
      return Icons.wb_cloudy_outlined;
    case FamiliaTiempo.cubierto:
      return Icons.cloud_outlined;
    case FamiliaTiempo.niebla:
      return Icons.foggy;
    case FamiliaTiempo.llovizna:
      return Icons.grain;
    case FamiliaTiempo.lluvia:
      return Icons.umbrella_outlined;
    case FamiliaTiempo.nieve:
      return Icons.ac_unit;
    case FamiliaTiempo.tormenta:
      return Icons.thunderstorm_outlined;
  }
}

String _num(double? valor, String sufijo) =>
    valor == null ? '—' : '${valor.round()}$sufijo';

String _decimal(double? valor, String sufijo) =>
    valor == null ? '—' : '${valor.toStringAsFixed(1).replaceAll('.', ',')}$sufijo';

/// Flecha que apunta hacia donde va el viento, más el punto cardinal desde
/// el que sopla.
class _Viento extends StatelessWidget {
  const _Viento({
    required this.grados,
    required this.texto,
    required this.idioma,
  });

  final double? grados;
  final String texto;
  final String idioma;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (grados != null)
          Transform.rotate(
            angle: (grados! + 180) * 3.141592653589793 / 180,
            child: const Icon(Icons.navigation_outlined, size: 15),
          )
        else
          const Icon(Icons.air, size: 15),
        const SizedBox(width: 3),
        Text([direccionViento(grados, idioma), texto]
            .where((parte) => parte.isNotEmpty)
            .join(' ')),
      ],
    );
  }
}

class _TarjetaAhora extends StatelessWidget {
  const _TarjetaAhora({
    required this.actual,
    required this.hoy,
    required this.altitudM,
    required this.idioma,
    required this.textos,
  });

  final CondicionActual actual;
  final DiaMeteo? hoy;
  final double? altitudM;
  final String idioma;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    final formatoHora = DateFormat('HH:mm', idioma);
    final luz = hoy?.horasDeLuz;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textos.meteoAhora, style: estilos.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(_iconoTiempo(actual.codigoTiempo, deDia: actual.esDeDia),
                    size: 44, color: colorMonteZunbeltz),
                const SizedBox(width: 12),
                Text(_num(actual.temperatura, '°'),
                    style: estilos.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(descripcionTiempo(actual.codigoTiempo, idioma),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          '${textos.meteoSensacion} ${_num(actual.sensacion, '°')}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 6,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.water_drop_outlined, size: 15),
                  const SizedBox(width: 3),
                  Text('${textos.meteoHumedad} ${_num(actual.humedad, ' %')}'),
                ]),
                _Viento(
                  grados: actual.direccionVientoGrados,
                  texto:
                      '${_num(actual.vientoKmh, '')} km/h · ${textos.meteoRachas} ${_num(actual.rachaKmh, '')}',
                  idioma: idioma,
                ),
              ],
            ),
            if (hoy?.amanecer != null && hoy?.anochecer != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.wb_twilight, size: 15),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text([
                      '${textos.meteoAmanecer} ${formatoHora.format(hoy!.amanecer!)}',
                      '${textos.meteoAnochecer} ${formatoHora.format(hoy!.anochecer!)}',
                      if (luz != null)
                        textos.meteoLuz(luz.inHours, luz.inMinutes % 60),
                    ].join(' · ')),
                  ),
                ],
              ),
            ],
            if (altitudM != null) ...[
              const SizedBox(height: 8),
              Text(textos.meteoAltitud(altitudM!.round()),
                  style: estilos.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _FranjaHoras extends StatelessWidget {
  const _FranjaHoras({required this.horas, required this.idioma});

  final List<HoraMeteo> horas;
  final String idioma;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          itemCount: horas.length,
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (context, indice) {
            final hora = horas[indice];
            final deDia = hora.hora.hour >= 7 && hora.hora.hour <= 20;
            final probLluvia = hora.probLluvia ?? 0;
            return SizedBox(
              width: 52,
              child: Column(
                children: [
                  Text(DateFormat('HH', idioma).format(hora.hora),
                      style: estilos.labelMedium),
                  const SizedBox(height: 4),
                  Icon(_iconoTiempo(hora.codigoTiempo, deDia: deDia),
                      size: 22),
                  const SizedBox(height: 4),
                  Text(_num(hora.temperatura, '°'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    probLluvia >= 10 ? '${probLluvia.round()} %' : '',
                    style: estilos.labelSmall
                        ?.copyWith(color: const Color(0xFF4E7A9B)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.air, size: 11),
                      const SizedBox(width: 2),
                      Text(_num(hora.rachaKmh, ''), style: estilos.labelSmall),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TarjetaAgua extends StatelessWidget {
  const _TarjetaAgua({
    required this.prevision,
    required this.ahora,
    required this.textos,
  });

  final PrevisionMeteo prevision;
  final DateTime ahora;
  final AppLocalizations textos;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    final lluviaPasada = prevision.lluviaDiasAnteriores(ahora);
    final lluviaPrevista = prevision.lluviaPrevista(ahora);
    final evapotranspiracion = prevision.evapotranspiracionPrevista(ahora);
    final balanceSeco = evapotranspiracion > lluviaPrevista;

    Widget fila(String etiqueta, String valor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(etiqueta)),
              const SizedBox(width: 12),
              Text(valor, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Titulo(textos.meteoAgua),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lluviaPasada != null)
                  fila(textos.meteoLluviaPasada, _decimal(lluviaPasada, ' mm')),
                fila(textos.meteoLluviaPrevista,
                    _decimal(lluviaPrevista, ' mm')),
                fila(textos.meteoEvapotranspiracion,
                    _decimal(evapotranspiracion, ' mm')),
                const SizedBox(height: 8),
                Text(
                  balanceSeco
                      ? textos.meteoBalanceSeco
                      : textos.meteoBalanceHumedo,
                  style: estilos.bodyMedium?.copyWith(
                      color: balanceSeco
                          ? colorSenalZunbeltz
                          : colorPastoZunbeltz),
                ),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    final etiquetaDia = esHoy
        ? textos.meteoHoy
        : toBeginningOfSentenceCase(
            DateFormat('EEEE', idioma).format(dia.fecha));
    final formatoHora = DateFormat('HH:mm', idioma);
    final avisos = <_Aviso>[
      if (dia.tormenta)
        _Aviso(textos.avisoTormenta, const Color(0xFF5A4A7A)),
      if (dia.nieve) _Aviso(textos.avisoNieve, const Color(0xFF6C8AA0)),
      if (dia.riesgoHelada)
        _Aviso(textos.avisoHelada, const Color(0xFF6C8AA0)),
      if (dia.lluviaRelevante)
        _Aviso(textos.avisoLluvia, const Color(0xFF4E7A9B)),
      if (dia.vientoFuerte) _Aviso(textos.avisoViento, const Color(0xFF9A7A2E)),
      if (dia.calorIntenso) _Aviso(textos.avisoCalor, colorEstadoBloqueada),
      if (dia.estresCalor && !dia.calorIntenso)
        _Aviso(textos.avisoEstresCalor, colorEstadoBloqueada),
      if (dia.buenDiaManejo)
        _Aviso(textos.avisoBuenManejo, colorPastoZunbeltz),
    ];

    Widget detalle(String etiqueta, String valor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(etiqueta, style: estilos.bodyMedium)),
              const SizedBox(width: 12),
              Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Icon(_iconoTiempo(dia.codigoTiempo),
            size: 30, color: colorMonteZunbeltz),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '$etiquetaDia · ${DateFormat('dd/MM', idioma).format(dia.fecha)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${_num(dia.tempMax, '°')} / ${_num(dia.tempMin, '°')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(descripcionTiempo(dia.codigoTiempo, idioma)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.water_drop_outlined, size: 15),
                  const SizedBox(width: 3),
                  Text([
                    _decimal(dia.lluviaMm, ' mm'),
                    if ((dia.probLluviaMax ?? 0) > 0)
                      _num(dia.probLluviaMax, ' %'),
                  ].join(' · ')),
                ]),
                _Viento(
                  grados: dia.direccionVientoGrados,
                  texto: '${_num(dia.rachaMaxKmh, '')} km/h',
                  idioma: idioma,
                ),
              ],
            ),
            if (avisos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [for (final aviso in avisos) aviso.build(context)],
              ),
            ],
          ],
        ),
        children: [
          detalle(textos.meteoSensacionMin, _num(dia.sensacionMin, '°')),
          detalle(textos.meteoHorasLluvia, _num(dia.horasLluvia, ' h')),
          if (dia.nieve) detalle(textos.meteoNieve, _decimal(dia.nieveCm, ' cm')),
          detalle(textos.meteoViento,
              '${_num(dia.vientoMaxKmh, '')} km/h · ${textos.meteoRachas} ${_num(dia.rachaMaxKmh, '')}'),
          detalle(textos.meteoUv, _num(dia.uvMax, '')),
          detalle(textos.meteoEvapotranspiracionDia,
              _decimal(dia.evapotranspiracionMm, ' mm')),
          detalle(textos.meteoThi, _num(dia.thiMax, '')),
          if (dia.amanecer != null && dia.anochecer != null)
            detalle(
              '${textos.meteoAmanecer} / ${textos.meteoAnochecer}',
              '${formatoHora.format(dia.amanecer!)} / ${formatoHora.format(dia.anochecer!)}',
            ),
        ],
      ),
    );
  }
}

class _Aviso {
  _Aviso(this.texto, this.color);
  final String texto;
  final Color color;

  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(texto,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600)),
      );
}
