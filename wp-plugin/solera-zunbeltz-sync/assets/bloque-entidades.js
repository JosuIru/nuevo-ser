// Bloque «Entidades y logos» en el editor: lo pinta el servidor
// (includes/logos-entidades.php), igual que en la web.
( function ( bloques, elemento, renderServidor ) {
	bloques.registerBlockType( 'solera-zunbeltz/entidades', {
		edit: function () {
			return elemento.createElement( renderServidor, { block: 'solera-zunbeltz/entidades' } );
		},
		save: function () {
			return null;
		},
	} );
} )( window.wp.blocks, window.wp.element, window.wp.serverSideRender );
