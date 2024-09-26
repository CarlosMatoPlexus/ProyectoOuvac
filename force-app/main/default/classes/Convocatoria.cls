public class Convocatoria {
    public String code_bdns;
    public String descripcion;
    public Decimal importe_total;
    public Boolean fondo_ue;
    public String version_json;
    public Boolean activo;
    public String fecha_modificacion;
    public DataJson data_json;
    
    public class DataJson {
        public DatosGeneralesCov DatosGeneralesCov;
        public DatosBaseReguladora DatosBaseReguladora;
        public DatosSolicitudJustificacionFinanciacion DatosSolicitudJustificacionFinanciacion;
        public OtrosDatos OtrosDatos;
        public List<Extracto> Extractos;
        public List<OtrosDocumentos> OtrosDocumentos;
    }
    public class DatosGeneralesCov {
        public DocumentoCastellano DocumentoCastellano;
        public DocumentoOtraLengua DocumentoOtraLengua;
    }
    public class DocumentoCastellano{
        public String Nombre;
    }
    public class DocumentoOtraLengua{
        public String Nombre;
    }
    public class DatosBaseReguladora {
        public String URLEspBR;
        public String URLengBR;
    }
    public class DatosSolicitudJustificacionFinanciacion {
        public Solicitud Solicitud;
        public Justificacion Justificacion;
        public String FechaJustificacion;
    }
    public class Solicitud {
        public String InicioSolicitud;
        public String FechaFinSolicitud;
    }
    public class Justificacion {
        public String nombre;
    }
    public class OtrosDatos {
        public ImpactoGenero ImpactoGenero;
    }
    public class ImpactoGenero {
        public String codigo;
        public String nombre;
    }
    public class Extracto {
        public String DiarioOficial;
        public ExtractoCastellano ExtractoCastellano;
        public ExtractoOtraLengua ExtractoOtraLengua;
        public String FechaEnvio;
        public Publicacion Publicacion;
    }
    public class ExtractoCastellano {
        public String TituloExtracto;
        public TextoExtractoCastellano TextoExtractoCastellano;
        public PieFirmaExtracto PieFirmaExtracto;
    }
    public class ExtractoOtraLengua {
        public String TituloExtracto;
        public TextoExtractoOtraLengua TextoExtractoOtraLengua;
        public PieFirmaExtracto PieFirmaExtracto;
    }
    public class TextoExtractoCastellano {
        public List<String> p;
    }
    public class TextoExtractoOtraLengua {
        public List<String> p;
    }
    public class PieFirmaExtracto {
        public String FechaFirma;
        public String LugarFirma;
        public String Firmante;
    }
    public class OtrosDocumentos {
        public String DescripcionOtro;
        public String Nombre;
    }
    public class Publicacion {
        public String IdExtractoDiarioOficial;
        public EstadoPublicacion EstadoPublicacion;
    }
    public class EstadoPublicacion {
        public Publicado Publicado;
    }
    public class Publicado {
        public String FechaPublicacion;
        public String URL;
    }
}