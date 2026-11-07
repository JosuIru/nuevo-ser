import 'clasificador_responsables.dart';
import 'lector_bloqueos.dart';
import 'recolector.dart';

String escaparHtml(String texto) => texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// Página HTML autocontenida con filtro por responsable y por app.
String informeHtml(Inventario inventario) {
  final abiertos = inventario.bloqueosAbiertos;
  final porResponsable = inventario.abiertosPorResponsable;
  final aplicaciones = {for (final bloqueo in abiertos) bloqueo.aplicacion}
      .toList()
    ..sort();

  final botonesResponsable = StringBuffer();
  for (final entrada in porResponsable.entries) {
    botonesResponsable.write('<button class="filtro" data-tipo="responsable" '
        'data-valor="${entrada.key.name}">'
        '${escaparHtml(entrada.key.nombreVisible)} '
        '<span class="cuenta">${entrada.value.length}</span></button>');
  }
  final botonesApp = StringBuffer();
  for (final aplicacion in aplicaciones) {
    final cuenta = abiertos
        .where((bloqueo) => bloqueo.aplicacion == aplicacion)
        .length;
    botonesApp.write('<button class="filtro" data-tipo="app" '
        'data-valor="${escaparHtml(aplicacion)}">${escaparHtml(aplicacion)} '
        '<span class="cuenta">$cuenta</span></button>');
  }

  final filasBloqueos = StringBuffer();
  for (final bloqueo in abiertos) {
    filasBloqueos.write(_tarjetaBloqueo(bloqueo));
  }

  final filasSellos = StringBuffer();
  for (final sello in inventario.sellos) {
    filasSellos.write('<tr><td>${escaparHtml(sello.aplicacion)}</td>'
        '<td><code>${escaparHtml(sello.ruta)}</code></td>'
        '<td>${sello.protegidoPorTest ? 'sí' : '<strong class="aviso">no</strong>'}</td></tr>');
  }

  final filasCatalogos = StringBuffer();
  for (final catalogo in inventario.catalogos
      .where((catalogo) => catalogo.tieneColumnaRevision)) {
    final porcentajePersona = catalogo.filas == 0
        ? 0
        : (100 * catalogo.revisadasPorPersona / catalogo.filas).round();
    filasCatalogos.write('<tr><td>${escaparHtml(catalogo.vertical)}</td>'
        '<td><code>${escaparHtml(catalogo.nombreArchivo)}</code></td>'
        '<td class="num">${catalogo.filas}</td>'
        '<td class="num">${catalogo.revisadasPorPersona}</td>'
        '<td class="num">${catalogo.revisadasPorIa}</td>'
        '<td class="num">${catalogo.revisadasPorFuentePublica}</td>'
        '<td class="num">${catalogo.sinRevisar}</td>'
        '<td><span class="barra"><span style="width:$porcentajePersona%"></span></span></td></tr>');
  }
  final filasFlags = StringBuffer();
  for (final flag in inventario.flags) {
    filasFlags.write('<li><code>${escaparHtml(flag.aplicacion)}</code>: '
        'catalogosCompletamenteRevisados = '
        '<strong>${flag.revisados}</strong></li>');
  }

  final fecha = inventario.generadoEn.toIso8601String().substring(0, 16);
  return '''<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Pendientes del monorepo</title>
<style>
:root {
  --fondo: #faf8f3; --superficie: #ffffff; --texto: #1f1d1a; --suave: #6b665d;
  --borde: #e4dfd4; --acento: #5b6b2e; --acento-suave: #e9edd9; --aviso: #a3401f;
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --fondo: #171614; --superficie: #211f1c; --texto: #ece8df; --suave: #a39d91;
    --borde: #36332e; --acento: #b5c77a; --acento-suave: #2c3220; --aviso: #e58a66;
  }
}
:root[data-theme="dark"] {
  --fondo: #171614; --superficie: #211f1c; --texto: #ece8df; --suave: #a39d91;
  --borde: #36332e; --acento: #b5c77a; --acento-suave: #2c3220; --aviso: #e58a66;
}
* { box-sizing: border-box; }
body { margin: 0; background: var(--fondo); color: var(--texto);
  font: 15px/1.5 system-ui, -apple-system, "Segoe UI", sans-serif; }
main { max-width: 1100px; margin: 0 auto; padding: 24px 16px 64px; }
h1 { font-size: 1.6rem; margin: 0 0 4px; }
h2 { font-size: 1.15rem; margin: 40px 0 12px; }
.sub { color: var(--suave); margin: 0 0 20px; }
.resumen { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
.dato { background: var(--superficie); border: 1px solid var(--borde); border-radius: 10px; padding: 12px 14px; }
.dato b { display: block; font-size: 1.6rem; font-variant-numeric: tabular-nums; }
.dato span { color: var(--suave); font-size: .9rem; }
.filtros { display: flex; flex-wrap: wrap; gap: 6px; margin: 8px 0; }
.filtro { font: inherit; font-size: .88rem; border: 1px solid var(--borde); background: var(--superficie);
  color: var(--texto); border-radius: 999px; padding: 4px 10px; cursor: pointer; }
.filtro[aria-pressed="true"] { background: var(--acento); border-color: var(--acento); color: var(--fondo); }
.cuenta { opacity: .7; font-variant-numeric: tabular-nums; }
.tarjeta { background: var(--superficie); border: 1px solid var(--borde); border-radius: 10px;
  padding: 10px 14px; margin: 8px 0; }
.tarjeta summary { cursor: pointer; display: flex; flex-wrap: wrap; gap: 6px 10px; align-items: baseline; }
.tarjeta .titulo { font-weight: 600; }
.etiqueta { font-size: .78rem; padding: 1px 8px; border-radius: 999px; background: var(--acento-suave); color: var(--texto); }
.app { font-size: .8rem; color: var(--suave); }
.tarjeta pre { white-space: pre-wrap; font: .85rem/1.45 ui-monospace, monospace; color: var(--suave);
  max-height: 360px; overflow: auto; margin: 10px 0 0; }
.ruta { font-size: .8rem; color: var(--suave); }
.tabla { overflow-x: auto; }
table { border-collapse: collapse; width: 100%; background: var(--superficie); border: 1px solid var(--borde); border-radius: 10px; }
th, td { text-align: left; padding: 6px 10px; border-bottom: 1px solid var(--borde); font-size: .9rem; }
th { color: var(--suave); font-weight: 500; }
td.num { text-align: right; font-variant-numeric: tabular-nums; }
code { font: .85rem ui-monospace, monospace; }
.aviso { color: var(--aviso); }
.barra { display: inline-block; width: 80px; height: 8px; border-radius: 4px; background: var(--borde); overflow: hidden; }
.barra span { display: block; height: 100%; background: var(--acento); }
.oculto { display: none; }
</style>
</head>
<body>
<main>
<h1>Pendientes del monorepo</h1>
<p class="sub">Generado el $fecha a partir de los <code>BLOQUEOS-PENDIENTES.md</code>, los sellos PROVISIONAL del código y los catálogos de <code>content/</code>. La clasificación por responsable es automática (palabras clave): orienta, no manda.</p>

<div class="resumen">
  <div class="dato"><b>${abiertos.length}</b><span>bloqueos abiertos de ${inventario.bloqueos.length}</span></div>
  <div class="dato"><b>${inventario.sellos.length}</b><span>sellos PROVISIONAL en código</span></div>
  <div class="dato"><b>${inventario.catalogos.where((c) => c.pendienteDePersona).length}</b><span>catálogos sin firma de persona experta</span></div>
  <div class="dato"><b>${porResponsable.length}</b><span>responsables distintos</span></div>
</div>

<h2>Bloqueos abiertos</h2>
<div class="filtros" aria-label="A quién se espera">$botonesResponsable</div>
<div class="filtros" aria-label="Aplicación">$botonesApp</div>
<div id="bloqueos">$filasBloqueos</div>

<h2>Sellos PROVISIONAL en código</h2>
<p class="sub">Archivos de <code>lib/</code> con el literal <code>'PROVISIONAL</code>. «Test» indica si un <code>sello_provisional_test.dart</code> impide quitarlo sin validación.</p>
<div class="tabla"><table><thead><tr><th>App</th><th>Archivo</th><th>Test</th></tr></thead><tbody>$filasSellos</tbody></table></div>

<h2>Catálogos</h2>
<p class="sub">Filas firmadas por una persona, contrastadas solo con fuente pública y sin revisar. La barra muestra la parte firmada por una persona.</p>
<div class="tabla"><table><thead><tr><th>Vertical</th><th>Archivo</th><th>Filas</th><th>Persona</th><th>Revisión IA</th><th>Fuente pública</th><th>Sin revisar</th><th></th></tr></thead><tbody>$filasCatalogos</tbody></table></div>
<ul>$filasFlags</ul>
</main>
<script>
(function () {
  var activos = { responsable: null, app: null };
  var botones = document.querySelectorAll('.filtro');
  function aplicar() {
    document.querySelectorAll('#bloqueos .tarjeta').forEach(function (tarjeta) {
      var responsables = tarjeta.dataset.responsables.split(' ');
      var visible = (!activos.responsable || responsables.indexOf(activos.responsable) >= 0) &&
        (!activos.app || tarjeta.dataset.app === activos.app);
      tarjeta.classList.toggle('oculto', !visible);
    });
    botones.forEach(function (boton) {
      boton.setAttribute('aria-pressed', activos[boton.dataset.tipo] === boton.dataset.valor ? 'true' : 'false');
    });
  }
  botones.forEach(function (boton) {
    boton.addEventListener('click', function () {
      var tipo = boton.dataset.tipo;
      activos[tipo] = activos[tipo] === boton.dataset.valor ? null : boton.dataset.valor;
      aplicar();
    });
  });
  aplicar();
})();
</script>
</body>
</html>
''';
}

String _tarjetaBloqueo(Bloqueo bloqueo) {
  final etiquetas = bloqueo.responsables
      .map((responsable) =>
          '<span class="etiqueta">${escaparHtml(responsable.nombreVisible)}</span>')
      .join();
  final casillas = bloqueo.casillasPendientes > 0
      ? '<span class="app">${bloqueo.casillasPendientes} casillas abiertas</span>'
      : '';
  final grupo = bloqueo.grupo == null
      ? ''
      : '<span class="app">${escaparHtml(bloqueo.grupo!)}</span>';
  final nombresResponsables =
      bloqueo.responsables.map((Responsable r) => r.name).join(' ');
  return '<details class="tarjeta" data-app="${escaparHtml(bloqueo.aplicacion)}" '
      'data-responsables="$nombresResponsables"><summary>'
      '<span class="app">${escaparHtml(bloqueo.aplicacion)}</span>'
      '<span class="titulo">${escaparHtml(bloqueo.titulo)}</span>'
      '$etiquetas$casillas$grupo</summary>'
      '<div class="ruta">BLOQUEOS-PENDIENTES.md:${bloqueo.linea}</div>'
      '<pre>${escaparHtml(bloqueo.cuerpo)}</pre></details>';
}
