/*
 * Portadas web de los juegos: botón de pantalla completa sobre la consola.
 * Donde el navegador no deja poner un div a pantalla completa (Safari de
 * iPhone), abre el juego solo en la misma pestaña.
 *
 * Botón de compartir: el menú de compartir del sistema (móvil) con la
 * página; donde no lo hay (escritorio), copia el enlace y lo dice.
 */
( function () {
	document.querySelectorAll( '[data-ns-ur-pantalla-completa]' ).forEach( function ( boton ) {
		boton.addEventListener( 'click', function () {
			var consola = document.getElementById( boton.getAttribute( 'data-ns-ur-pantalla-completa' ) );
			var destino = boton.getAttribute( 'data-ns-ur-url' );
			if ( consola && consola.requestFullscreen ) {
				consola.requestFullscreen().catch( function () {
					window.location.href = destino;
				} );
			} else if ( consola && consola.webkitRequestFullscreen ) {
				consola.webkitRequestFullscreen();
			} else {
				window.location.href = destino;
			}
		} );
	} );

	document.querySelectorAll( '[data-ns-ur-compartir]' ).forEach( function ( boton ) {
		var etiqueta = boton.querySelector( 'span' );
		var textoOriginal = etiqueta ? etiqueta.textContent : '';
		boton.addEventListener( 'click', function () {
			var url = window.location.href.split( '#' )[ 0 ];
			var datos = {
				title: boton.getAttribute( 'data-titulo' ) || document.title,
				text: boton.getAttribute( 'data-texto' ) || '',
				url: url,
			};
			if ( navigator.share ) {
				navigator.share( datos ).catch( function () {} );
				return;
			}
			var avisar = function () {
				if ( ! etiqueta ) {
					return;
				}
				etiqueta.textContent = boton.getAttribute( 'data-copiado' ) || textoOriginal;
				setTimeout( function () {
					etiqueta.textContent = textoOriginal;
				}, 2200 );
			};
			if ( navigator.clipboard && navigator.clipboard.writeText ) {
				navigator.clipboard.writeText( url ).then( avisar ).catch( function () {
					window.prompt( textoOriginal, url );
				} );
			} else {
				window.prompt( textoOriginal, url );
			}
		} );
	} );
} )();
