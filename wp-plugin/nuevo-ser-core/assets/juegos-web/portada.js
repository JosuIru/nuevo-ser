/*
 * Portadas web de los juegos: botón de pantalla completa sobre la consola.
 * Donde el navegador no deja poner un div a pantalla completa (Safari de
 * iPhone), abre el juego solo en la misma pestaña.
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
} )();
