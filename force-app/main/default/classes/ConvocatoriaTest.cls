@isTest
public class ConvocatoriaTest {
    @isTest
    static void testConvocatoriaInitialization() {
        // Crear una instancia de la clase Convocatoria
        Convocatoria convocatoria = new Convocatoria();
        convocatoria.code_bdns = '123456';
        convocatoria.descripcion = 'Descripción de la convocatoria de prueba';
        convocatoria.importe_total = 100000;
        convocatoria.fondo_ue = true;
        convocatoria.version_json = '1.0';
        convocatoria.activo = true;
        convocatoria.fecha_modificacion = '2024-09-17T15:50:28+02:00';
        // Inicializar data_json
        convocatoria.data_json = new Convocatoria.DataJson();
        // DatosGeneralesCov
        convocatoria.data_json.DatosGeneralesCov = new Convocatoria.DatosGeneralesCov();
        convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano = new Convocatoria.DocumentoCastellano();
        convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Nombre = 'Documento en Castellano.pdf';
        convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua = new Convocatoria.DocumentoOtraLengua();
        convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Nombre = 'Documento en Otra Lengua.pdf';
        // DatosBaseReguladora
        convocatoria.data_json.DatosBaseReguladora = new Convocatoria.DatosBaseReguladora();
        convocatoria.data_json.DatosBaseReguladora.URLEspBR = 'http://example.com/esp';
        convocatoria.data_json.DatosBaseReguladora.URLengBR = 'http://example.com/eng';
        // DatosSolicitudJustificacionFinanciacion
        convocatoria.data_json.DatosSolicitudJustificacionFinanciacion = new Convocatoria.DatosSolicitudJustificacionFinanciacion();
        convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud = new Convocatoria.Solicitud();
        convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.InicioSolicitud = '2024-01-01';
        convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.FechaFinSolicitud = '2024-02-01';
        convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion = new Convocatoria.Justificacion();
        convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion.nombre = 'Justificación Final';
        convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.FechaJustificacion = '2024-03-01';
        // OtrosDatos e ImpactoGenero
        convocatoria.data_json.OtrosDatos = new Convocatoria.OtrosDatos();
        convocatoria.data_json.OtrosDatos.ImpactoGenero = new Convocatoria.ImpactoGenero();
        convocatoria.data_json.OtrosDatos.ImpactoGenero.codigo = '2';
        convocatoria.data_json.OtrosDatos.ImpactoGenero.nombre = 'Nulo';
        // Extractos y Publicacion
        Convocatoria.Extracto extracto = new Convocatoria.Extracto();
        extracto.DiarioOficial = 'BOE';
        extracto.ExtractoCastellano = new Convocatoria.ExtractoCastellano();
        extracto.ExtractoCastellano.TituloExtracto = 'Extracto del documento en Castellano';
        extracto.ExtractoCastellano.TextoExtractoCastellano = new Convocatoria.TextoExtractoCastellano();
        extracto.ExtractoCastellano.TextoExtractoCastellano.p = new List<String>{'Primera parte', 'Segunda parte'};
        extracto.ExtractoCastellano.PieFirmaExtracto = new Convocatoria.PieFirmaExtracto();
        extracto.ExtractoCastellano.PieFirmaExtracto.Firmante = 'Funcionario';
        extracto.ExtractoCastellano.PieFirmaExtracto.FechaFirma = '2024-04-01';
        extracto.ExtractoCastellano.PieFirmaExtracto.LugarFirma = 'Madrid';
        extracto.Publicacion = new Convocatoria.Publicacion();
        extracto.Publicacion.EstadoPublicacion = new Convocatoria.EstadoPublicacion();
        extracto.Publicacion.EstadoPublicacion.Publicado = new Convocatoria.Publicado();
        extracto.Publicacion.EstadoPublicacion.Publicado.FechaPublicacion = '2024-04-02';
        extracto.Publicacion.EstadoPublicacion.Publicado.URL = 'http://example.com/publicacion';
        convocatoria.data_json.Extractos = new List<Convocatoria.Extracto>{extracto};
        // Verificaciones de aserciones
        System.assertEquals('123456', convocatoria.code_bdns, 'El código BDNS debe ser 123456');
        System.assertEquals('Descripción de la convocatoria de prueba', convocatoria.descripcion, 'La descripción debe ser correcta');
        System.assertEquals(100000, convocatoria.importe_total, 'El importe debe ser 100000');
        System.assert(convocatoria.fondo_ue, 'El fondo de la UE debe ser verdadero');
        System.assertEquals('2024-09-17T15:50:28+02:00', convocatoria.fecha_modificacion, 'La fecha de modificación debe coincidir');
        System.assertEquals('Documento en Castellano.pdf', convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Nombre, 'El nombre del documento en castellano debe coincidir');
        System.assertEquals('http://example.com/esp', convocatoria.data_json.DatosBaseReguladora.URLEspBR, 'La URL en español debe coincidir');
        System.assertEquals('Justificación Final', convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion.nombre, 'El nombre de la justificación debe ser correcto');
        System.assertEquals('Nulo', convocatoria.data_json.OtrosDatos.ImpactoGenero.nombre, 'El impacto de género debe ser "Nulo"');
        System.assertEquals('Extracto del documento en Castellano', extracto.ExtractoCastellano.TituloExtracto, 'El título del extracto en castellano debe coincidir');
    }
}