// El buscador de lugares (CartoCiudad con Nominatim de respaldo) vive ahora
// en el core para que lo usen todas las apps con mapa; se reexporta aquí
// para no tocar los imports de la app.
export 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        LugarEncontrado,
        ServicioBuscadorMapa,
        lugaresDesdeCandidatos,
        posicionDesdeFind,
        lugaresDesdeNominatim;
