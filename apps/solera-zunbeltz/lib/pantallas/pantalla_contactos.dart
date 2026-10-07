import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/agenda.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

String etiquetaTipoContacto(String tipo, AppLocalizations textos) =>
    switch (tipo) {
      'matadero' => textos.tipoContactoMatadero,
      'veterinaria' => textos.tipoContactoVeterinaria,
      'experto' => textos.tipoContactoExperto,
      'comprador' => textos.tipoContactoComprador,
      'proveedor' => textos.tipoContactoProveedor,
      'administracion' => textos.tipoContactoAdministracion,
      _ => textos.tipoContactoOtro,
    };

IconData iconoTipoContacto(String tipo) => switch (tipo) {
      'matadero' => Icons.factory_outlined,
      'veterinaria' => Icons.medical_services_outlined,
      'experto' => Icons.school_outlined,
      'comprador' => Icons.storefront_outlined,
      'proveedor' => Icons.local_shipping_outlined,
      'administracion' => Icons.account_balance_outlined,
      _ => Icons.person_outline,
    };

/// Agenda compartida del espacio: mataderos, veterinaria, personas
/// expertas… La ve todo el equipo; también se gestiona desde el WordPress.
class PantallaContactos extends StatefulWidget {
  const PantallaContactos({super.key});

  @override
  State<PantallaContactos> createState() => _PantallaContactosState();
}

class _PantallaContactosState extends State<PantallaContactos> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<Contacto> _contactos = const [];
  String? _tipo;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    notificadorDatos.addListener(_cargar);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    final contactos = await _bd.listarContactos(tipo: _tipo);
    if (!mounted) return;
    setState(() {
      _contactos = contactos;
      _cargando = false;
    });
  }

  Future<void> _abrirFormulario([Contacto? contacto]) async {
    final guardado = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => FormularioContacto(contacto: contacto)));
    if (guardado == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  Future<void> _abrirEnlace(Uri enlace) async {
    try {
      await launchUrl(enlace);
    } catch (_) {
      // Sin aplicación para llamar o escribir: no hay nada más que hacer.
    }
  }

  Future<void> _mostrarFicha(Contacto contacto) async {
    final textos = AppLocalizations.of(context);
    final puedeEditar =
        politicaEspacioActual.puedeEditarContacto(contacto.autorUid);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (contexto) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contacto.nombre,
                  style: Theme.of(contexto).textTheme.titleLarge),
              Text([
                etiquetaTipoContacto(contacto.tipo, textos),
                if (contacto.localidad.isNotEmpty) contacto.localidad,
              ].join(' · ')),
              if (contacto.notas.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(contacto.notas),
              ],
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (contacto.telefono.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () => _abrirEnlace(
                        Uri(scheme: 'tel', path: contacto.telefono)),
                    icon: const Icon(Icons.call_outlined),
                    label:
                        Text('${textos.contactoLlamar} · ${contacto.telefono}'),
                  ),
                if (contacto.correo.isNotEmpty)
                  FilledButton.tonalIcon(
                    onPressed: () => _abrirEnlace(
                        Uri(scheme: 'mailto', path: contacto.correo)),
                    icon: const Icon(Icons.mail_outline),
                    label: Text(textos.contactoEscribir),
                  ),
                if (puedeEditar) ...[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(contexto);
                      _abrirFormulario(contacto);
                    },
                    child: Text(textos.contactoEditar),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(contexto);
                      if (contacto.id == null) return;
                      await _bd.borrarContacto(contacto.id!);
                      avisarCambioDatos();
                      await _cargar();
                    },
                    child: Text(textos.contactoBorrar),
                  ),
                ],
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(textos.contactosTitulo)),
      floatingActionButton: politicaEspacioActual.puedeCrearContactos
          ? FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.person_add_alt_outlined),
              label: Text(textos.contactoNuevo),
            )
          : null,
      body: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(textos.contactosTodos),
                selected: _tipo == null,
                onSelected: (_) {
                  setState(() => _tipo = null);
                  _cargar();
                },
              ),
            ),
            for (final tipo in tiposContacto)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: Icon(iconoTipoContacto(tipo), size: 18),
                  label: Text(etiquetaTipoContacto(tipo, textos)),
                  selected: _tipo == tipo,
                  onSelected: (_) {
                    setState(() => _tipo = tipo);
                    _cargar();
                  },
                ),
              ),
          ]),
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _contactos.isEmpty
                  ? Center(child: Text(textos.contactosVacio))
                  : ListView(
                      padding: rellenoSobreBarraSistema(
                          context, const EdgeInsets.only(bottom: 88)),
                      children: [
                        for (final contacto in _contactos)
                          ListTile(
                            leading: Icon(iconoTipoContacto(contacto.tipo)),
                            title: Text(contacto.nombre),
                            subtitle: Text([
                              etiquetaTipoContacto(contacto.tipo, textos),
                              if (contacto.telefono.isNotEmpty)
                                contacto.telefono,
                              if (contacto.localidad.isNotEmpty)
                                contacto.localidad,
                            ].join(' · ')),
                            onTap: () => _mostrarFicha(contacto),
                          ),
                      ],
                    ),
        ),
      ]),
    );
  }
}

/// Alta o edición de un contacto.
class FormularioContacto extends StatefulWidget {
  const FormularioContacto({super.key, this.contacto});

  final Contacto? contacto;

  @override
  State<FormularioContacto> createState() => _FormularioContactoState();
}

class _FormularioContactoState extends State<FormularioContacto> {
  final _bd = BaseDatosSoleraZunbeltz();
  late final _nombre = TextEditingController(text: widget.contacto?.nombre);
  late final _telefono = TextEditingController(text: widget.contacto?.telefono);
  late final _correo = TextEditingController(text: widget.contacto?.correo);
  late final _localidad =
      TextEditingController(text: widget.contacto?.localidad);
  late final _notas = TextEditingController(text: widget.contacto?.notas);
  late String _tipo = widget.contacto?.tipo ?? 'otro';

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _telefono,
      _correo,
      _localidad,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final textos = AppLocalizations.of(context);
    if (_nombre.text.trim().isEmpty) return;
    final datos = {
      'nombre': _nombre.text.trim(),
      'tipo': _tipo,
      'telefono': _telefono.text.trim(),
      'correo': _correo.text.trim(),
      'localidad': _localidad.text.trim(),
      'notas': _notas.text.trim(),
    };
    final existente = widget.contacto;
    if (existente?.id != null) {
      await _bd.actualizarContacto(existente!.id!, datos);
    } else {
      await _bd.guardarContacto(Contacto.fromMap({
        ...datos,
        'autor_uid': sesionEspacio.value?.persona.uid ?? '',
      }));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.contactoGuardado)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.contacto == null
              ? textos.contactoNuevo
              : textos.contactoEditar)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
                controller: _nombre,
                autofocus: widget.contacto == null,
                decoration: InputDecoration(labelText: textos.contactoNombre)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _tipo,
              decoration: InputDecoration(labelText: textos.contactoTipo),
              items: [
                for (final tipo in tiposContacto)
                  DropdownMenuItem(
                      value: tipo,
                      child: Text(etiquetaTipoContacto(tipo, textos))),
              ],
              onChanged: (tipo) => setState(() => _tipo = tipo ?? _tipo),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                decoration:
                    InputDecoration(labelText: textos.contactoTelefono)),
            const SizedBox(height: 12),
            TextField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: textos.contactoCorreo)),
            const SizedBox(height: 12),
            TextField(
                controller: _localidad,
                decoration:
                    InputDecoration(labelText: textos.contactoLocalidad)),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 3,
                decoration: InputDecoration(labelText: textos.contactoNotas)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
