import 'package:flutter/material.dart';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/config_api.dart';
import '../l10n/app_localizations.dart';
import '../nucleo/paleta.dart';

/// Formulario "He olvidado mi contraseña". Pide email y dispara
/// `POST /auth/solicitar-reset`. El servidor envía un email con enlace
/// — la nueva contraseña se mete en una página HTML del backend, no
/// en la propia app (v1 sin deep link).
///
/// Por anti-enumeración, mostramos siempre el mismo mensaje de éxito
/// — aunque el email no esté registrado. El usuario que se equivoque
/// de email no recibirá nada y ya está.
class PantallaSolicitarReset extends StatefulWidget {
  const PantallaSolicitarReset({super.key});

  @override
  State<PantallaSolicitarReset> createState() =>
      _PantallaSolicitarResetState();
}

class _PantallaSolicitarResetState extends State<PantallaSolicitarReset> {
  final _ctrlEmail = TextEditingController();
  bool _enviando = false;
  bool _enviado = false;
  String? _error;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final textos = AppLocalizations.of(context);
    final email = _ctrlEmail.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = textos.cuentaResetEmailInvalido);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    final api = ClienteApi(
      urlBase: ConfigApi.urlBase,
      hostOverride: ConfigApi.hostOverride,
      userAgent: 'UnoRoto/1.0 (Android)',
    );
    try {
      await api.solicitarResetPassword(email: email);
      if (!mounted) return;
      setState(() => _enviado = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = textos.cuentaResetErrorRed);
    } finally {
      api.cerrar();
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          textos.cuentaResetTitulo,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PaletaNeon.fondoCiudad),
        child: Center(
          child: SingleChildScrollView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(24, 24, 24, 32)),
            child: _enviado ? _confirmacion(textos) : _formulario(textos),
          ),
        ),
      ),
    );
  }

  Widget _formulario(AppLocalizations textos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          textos.cuentaResetTagline,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontStyle: FontStyle.italic,
            fontSize: 24,
            color: PaletaNeon.textoPrincipal.withOpacity(0.92),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          textos.cuentaResetIntro,
          style: TextStyle(
            fontSize: 13,
            color: PaletaNeon.textoTenue.withOpacity(0.85),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _ctrlEmail,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(color: PaletaNeon.textoPrincipal),
          cursorColor: PaletaNeon.violetaNeon,
          decoration: InputDecoration(
            labelText: textos.cuentaResetCampoEmail,
            labelStyle: const TextStyle(color: PaletaNeon.textoTenue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: PaletaNeon.violetaBase.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: PaletaNeon.violetaNeon),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _enviando ? null : _enviar,
          child: _enviando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: PaletaNeon.textoPrincipal,
                  ),
                )
              : Text(textos.cuentaResetBoton),
        ),
        if (_error != null) ...[
          const SizedBox(height: 18),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PaletaNeon.rosaAcento,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _confirmacion(AppLocalizations textos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: PaletaNeon.exitoSuave.withOpacity(0.85),
        ),
        const SizedBox(height: 18),
        Text(
          textos.cuentaResetEnviadoCuerpo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: PaletaNeon.textoPrincipal.withOpacity(0.95),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          textos.cuentaResetEnviadoSpam,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: PaletaNeon.textoTenue.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            textos.cuentaResetBotonVolver,
            style: const TextStyle(
              color: PaletaNeon.textoPrincipal,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
