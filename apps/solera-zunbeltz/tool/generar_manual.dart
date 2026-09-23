// Generador del manual imprimible a partir de los textos de la ayuda.
//
// Lee los apartados de ayuda de lib/l10n/app_es.arb y app_eu.arb y escribe
// manual/index.html (castellano) y manual/index_eu.html (euskera). Así el
// manual y la pantalla de Ayuda de la app dicen siempre lo mismo: se corrige
// el texto en el ARB (p. ej. tras la revisión nativa del euskera) y se
// ejecuta:
//
//   dart run tool/generar_manual.dart
//
// El orden de grupos y apartados replica el de lib/pantallas/pantalla_ayuda.dart;
// si se añade un apartado allí, hay que añadirlo también aquí.

import 'dart:convert';
import 'dart:io';

/// Grupo → claves base de sus apartados (cada una tiene `<clave>T` título y
/// `<clave>B` cuerpo en el ARB).
const _estructura = <String, List<String>>{
  'ayudaGrupoEmpezar': ['ayudaQueEs', 'ayudaPestanas', 'ayudaIdiomaDatos'],
  'ayudaGrupoFincas': [
    'ayudaFincas',
    'ayudaZonas',
    'ayudaEditarMapa',
    'ayudaTareas',
    'ayudaRecurrentes',
    'ayudaTablero',
  ],
  'ayudaGrupoProyectos': [
    'ayudaProyectos',
    'ayudaApuntar',
    'ayudaNumeros',
    'ayudaInformes',
  ],
  'ayudaGrupoEquipo': ['ayudaSync', 'ayudaRoles'],
  'ayudaGrupoProblemas': ['ayudaProblemas'],
};

/// Textos propios del documento impreso, que no están en la app.
class _TextosManual {
  const _TextosManual({
    required this.idioma,
    required this.fichero,
    required this.tituloPagina,
    required this.titulo,
    required this.version,
    required this.imprimir,
    required this.otroIdioma,
    required this.ficheroOtroIdioma,
    required this.indice,
    required this.avisoTitulo,
    required this.pie,
  });

  final String idioma;
  final String fichero;
  final String tituloPagina;
  final String titulo;
  final String Function(String version) version;
  final String imprimir;
  final String otroIdioma;
  final String ficheroOtroIdioma;
  final String indice;
  final String avisoTitulo;
  final String pie;
}

final _manuales = [
  _TextosManual(
    idioma: 'es',
    fichero: 'index.html',
    tituloPagina: 'Solera Zunbeltz — Manual de uso',
    titulo: 'Manual de uso',
    version: (v) => 'Solera Zunbeltz · versión $v',
    imprimir: 'Imprimir / Guardar PDF',
    otroIdioma: 'Euskaraz',
    ficheroOtroIdioma: 'index_eu.html',
    indice: 'Contenido',
    avisoTitulo: 'Versión preliminar',
    pie: 'Este manual se genera a partir de la ayuda de la propia app, así que '
        'ambos dicen lo mismo. La versión en euskera es un borrador pendiente '
        'de revisión nativa.',
  ),
  _TextosManual(
    idioma: 'eu',
    fichero: 'index_eu.html',
    tituloPagina: 'Solera Zunbeltz — Erabilera-eskuliburua',
    titulo: 'Erabilera-eskuliburua',
    version: (v) => 'Solera Zunbeltz · $v bertsioa',
    imprimir: 'Inprimatu / Gorde PDF gisa',
    otroIdioma: 'En castellano',
    ficheroOtroIdioma: 'index.html',
    indice: 'Edukia',
    avisoTitulo: 'Aurretiazko bertsioa',
    pie: 'Eskuliburu hau app-aren beraren laguntzatik sortzen da, beraz biek '
        'gauza bera diote. ZIRRIBORROA: euskarazko testua berrikuspen '
        'natiboaren zain dago.',
  ),
];

void main() {
  final raiz = Directory.current.path;
  final version = _leerVersion('$raiz/pubspec.yaml');
  for (final manual in _manuales) {
    final arb = jsonDecode(
            File('$raiz/lib/l10n/app_${manual.idioma}.arb').readAsStringSync())
        as Map<String, dynamic>;
    final html = _componer(manual, arb, version);
    File('$raiz/manual/${manual.fichero}').writeAsStringSync(html);
    stdout.writeln('Escrito manual/${manual.fichero}');
  }
}

String _leerVersion(String rutaPubspec) {
  final linea = File(rutaPubspec)
      .readAsLinesSync()
      .firstWhere((l) => l.startsWith('version:'));
  return linea.split(':')[1].trim().split('+').first;
}

String _texto(Map<String, dynamic> arb, String clave) {
  final valor = arb[clave];
  if (valor is! String) {
    throw StateError('Falta la clave "$clave" en el ARB');
  }
  return valor;
}

String _componer(
    _TextosManual manual, Map<String, dynamic> arb, String version) {
  final indice = StringBuffer();
  final cuerpo = StringBuffer();
  var numeroApartado = 0;
  _estructura.forEach((claveGrupo, apartados) {
    final tituloGrupo = _escapar(_texto(arb, claveGrupo));
    indice.writeln('<li><span class="grupo-indice">$tituloGrupo</span><ol>');
    cuerpo.writeln('<h2>$tituloGrupo</h2>');
    for (final clave in apartados) {
      numeroApartado++;
      final ancla = 'a$numeroApartado';
      final titulo = _escapar(_texto(arb, '${clave}T'));
      indice.writeln('<li><a href="#$ancla">$titulo</a></li>');
      cuerpo
        ..writeln('<section id="$ancla">')
        ..writeln('<h3><span class="n">$numeroApartado</span>$titulo</h3>')
        ..writeln(_cuerpoApartado(
            _texto(arb, '${clave}B'), _texto(arb, 'ayudaConsejo')))
        ..writeln('</section>');
    }
    indice.writeln('</ol></li>');
  });

  return '''<!DOCTYPE html>
<!-- GENERADO por tool/generar_manual.dart desde lib/l10n/app_${manual.idioma}.arb — NO editar a mano. -->
<html lang="${manual.idioma}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${manual.tituloPagina}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wght@500;600;700&family=Spectral:ital,wght@0,400;0,600;1,400&display=swap" rel="stylesheet">
<style>
$_estilos
</style>
</head>
<body>
<div class="barra">
  <a href="${manual.ficheroOtroIdioma}">${manual.otroIdioma} →</a>
  <button onclick="window.print()">${manual.imprimir}</button>
</div>
<main class="hoja">
  <header class="cab">
    <h1>${manual.titulo}</h1>
    <p class="sub">${_escapar(manual.version(version))}</p>
  </header>
  <div class="cuerpo">
    <p class="intro">${_escapar(_texto(arb, 'ayudaIntro').split('.').first)}.</p>
    <nav class="indice">
      <h2>${manual.indice}</h2>
      <ol>
${indice.toString().trimRight()}
      </ol>
    </nav>
${cuerpo.toString().trimRight()}
    <aside class="aviso">
      <b>${manual.avisoTitulo}.</b> ${_escapar(_texto(arb, 'ajustesProvisional'))}
      ${_escapar(_texto(arb, 'meteoOrientativo'))}
    </aside>
    <p class="final">${_escapar(_texto(arb, 'ayudaPie'))}</p>
  </div>
  <footer class="pie">${_escapar(manual.pie)}</footer>
</main>
</body>
</html>
''';
}

/// Mismas marcas que la pantalla de ayuda: `1.` paso, `•` viñeta, `»` nota,
/// resto párrafo. Pasos y viñetas seguidos se agrupan en una sola lista.
String _cuerpoApartado(String cuerpo, String etiquetaNota) {
  final salida = StringBuffer();
  String? listaAbierta;
  void cerrarLista() {
    if (listaAbierta != null) salida.writeln('</$listaAbierta>');
    listaAbierta = null;
  }

  void abrirLista(String etiqueta, [String atributos = '']) {
    if (listaAbierta == etiqueta) return;
    cerrarLista();
    salida.writeln('<$etiqueta$atributos>');
    listaAbierta = etiqueta;
  }

  final patronPaso = RegExp(r'^(\d+)\.\s+(.*)$');
  for (final linea in cuerpo.split('\n')) {
    final texto = linea.trim();
    if (texto.isEmpty) continue;
    final paso = patronPaso.firstMatch(texto);
    if (paso != null) {
      abrirLista('ol', ' class="pasos"');
      salida.writeln('<li>${_conEtiquetas(paso.group(2)!)}</li>');
    } else if (texto.startsWith('•')) {
      abrirLista('ul');
      salida.writeln('<li>${_conEtiquetas(texto.substring(1).trim())}</li>');
    } else if (texto.startsWith('»')) {
      cerrarLista();
      salida.writeln('<p class="nota"><b>${_escapar(etiquetaNota)}.</b> '
          '${_conEtiquetas(texto.substring(1).trim())}</p>');
    } else {
      cerrarLista();
      salida.writeln('<p>${_conEtiquetas(texto)}</p>');
    }
  }
  cerrarLista();
  return salida.toString().trimRight();
}

/// Escapa y resalta lo que va entre «» (nombres de botones de la app).
String _conEtiquetas(String texto) => _escapar(texto).replaceAllMapped(
    RegExp('«([^»]+)»'), (m) => '<span class="ui">${m.group(1)}</span>');

String _escapar(String texto) => texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

// Dirección visual de la presentación y la app (ver CLAUDE.md): papel de plano
// catastral, verde monte, un solo acento rojo de marcaje, Archivo en titulares
// y Spectral en el cuerpo, radio único de 4 px y sin sombras.
const _estilos = '''
:root{
  --papel:#E9EBE2; --papel-hundido:#DFE2D6; --monte:#1B2320; --senal:#B8402A;
  --pasto:#5E7D3A; --tinta:#171D19; --tinta-apagada:#6C7870; --linea:rgba(27,35,32,.17);
  --titular:"Archivo",system-ui,sans-serif; --texto:"Spectral",Georgia,serif;
}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--texto);font-size:17px;line-height:1.6;color:var(--tinta);background:#D3D7CB;padding:20px 16px 40px}
.barra{max-width:780px;margin:0 auto 12px;display:flex;justify-content:space-between;align-items:center;gap:12px;font-family:var(--titular);font-size:14px}
.barra a{color:var(--monte);font-weight:600}
.barra button{font:600 14px var(--titular);background:var(--monte);color:var(--papel);border:0;border-radius:4px;padding:9px 16px;cursor:pointer}
.hoja{max-width:780px;margin:0 auto;background:var(--papel);border:1px solid var(--linea);border-radius:4px;overflow:hidden}
.cab{background:var(--monte);color:var(--papel);padding:32px 40px 26px}
.cab h1{font:700 2rem/1.1 var(--titular);letter-spacing:-.02em;display:inline-block;padding-bottom:6px;border-bottom:3px solid var(--senal)}
.cab .sub{font-family:var(--titular);font-size:14px;opacity:.75;margin-top:10px}
.cuerpo{padding:28px 40px 12px}
.intro{font-size:1.08rem;color:var(--tinta)}
h2{font:700 1.3rem/1.2 var(--titular);letter-spacing:-.01em;color:var(--monte);margin:34px 0 4px;padding-bottom:6px;border-bottom:1px solid var(--linea)}
h3{font:600 1.08rem/1.3 var(--titular);color:var(--monte);margin:22px 0 4px;display:flex;align-items:baseline;gap:10px}
h3 .n{font-size:.85rem;color:var(--senal);min-width:1.4em}
section p{margin:6px 0}
section ul,section ol{margin:6px 0 6px 0;padding-left:1.4em}
section li{margin:5px 0}
ol.pasos{list-style:none;padding-left:0;counter-reset:paso}
ol.pasos li{counter-increment:paso;position:relative;padding-left:34px}
ol.pasos li::before{content:counter(paso);position:absolute;left:0;top:2px;width:22px;height:22px;display:grid;place-items:center;background:var(--monte);color:var(--papel);font:700 12px var(--titular);border-radius:4px}
section ul li::marker{color:var(--pasto)}
.ui{font-family:var(--titular);font-weight:600;font-size:.92em;white-space:nowrap;background:var(--papel-hundido);border:1px solid var(--linea);border-radius:4px;padding:0 5px}
.nota{background:var(--papel-hundido);border-left:3px solid var(--senal);padding:10px 14px;margin:10px 0!important;font-size:.95rem}
.nota b{font-family:var(--titular);color:var(--senal)}
.indice{margin-top:10px}
.indice>ol{list-style:none;columns:2;column-gap:32px;margin-top:10px}
.indice>ol>li{break-inside:avoid;margin-bottom:12px}
.grupo-indice{font:600 .95rem var(--titular);color:var(--monte)}
.indice ol ol{list-style:none;padding-left:0;margin-top:2px}
.indice ol ol li{font-size:.95rem;margin:1px 0}
.indice a{color:var(--tinta);text-decoration:none;border-bottom:1px solid var(--linea)}
.indice a:hover{color:var(--senal)}
.aviso{margin:36px 0 8px;padding:14px 16px;border:1px solid var(--linea);border-radius:4px;font-size:.93rem;color:var(--tinta-apagada)}
.aviso b{font-family:var(--titular);color:var(--monte)}
.final{margin:14px 0 18px;font-style:italic}
.pie{background:var(--monte);color:rgba(233,235,226,.72);font:13px/1.55 var(--titular);padding:16px 40px}
@media(max-width:640px){
  body{padding:12px 0 24px;font-size:16px}
  .barra{padding:0 16px}
  .hoja{border-left:0;border-right:0;border-radius:0}
  .cab,.cuerpo,.pie{padding-left:16px;padding-right:16px}
  .indice>ol{columns:1}
  .ui{white-space:normal}
}
@media print{
  body{background:#fff;padding:0;font-size:11pt}
  .barra{display:none}
  .hoja{border:0;max-width:none}
  .cab,.nota,ol.pasos li::before,.pie{-webkit-print-color-adjust:exact;print-color-adjust:exact}
  section{break-inside:avoid}
  h2{break-after:avoid}
  @page{margin:14mm}
}
''';
