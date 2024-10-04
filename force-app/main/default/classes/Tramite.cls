public class Tramite{
	public Integer id;	
	public String codigo;	
	public String titulo;	
	public String descripcion;
	public cls_institucion institucion;
	public cls_tema tema;
	public boolean activo;
	public String fecha_creacion;	
	public String fecha_modificacion;
	public cls_data_es_json data_es_json;
	public cls_data_gl_json data_gl_json;
    
	public class cls_institucion {
		public String code;	
		public String name;	
	}
	public class cls_tema {
		public String code;	
		public String name;	
	}
	public class cls_data_es_json {
		public String codigo;	
		public String titulo;	
		public String descripcion;
		public String finalidad;
		public String requisitos;
		public String plazoPresentacion;
		public String presentacion;	
		public String presentarPor;	
		public String organoGestor;	
		public String plazoResolucion;
		public String efectoSilencioAdministrativo;
		public String recursos;	
		public String normativaBasica;
		public List<cls_coleccionNormativas> coleccionNormativas;
		public String informacionAdicional;
		public String nivelIdentificacionSolicitante;
		//public cls_coleccionDocumentos[] coleccionDocumentos;
		public String urlInicioTramitacion;	
		public String urlDescargaInstancia;	
		public String urlDetalleTramite;	
	}
	public class cls_coleccionNormativas {
		public String titulo;	
		public String url;	
	}
	// public class cls_coleccionDocumentos {
	// }
	public class cls_data_gl_json {
		public String codigo;	
		public String titulo;	
		public String descripcion;
		public String finalidad;
		public String requisitos;
		public String plazoPresentacion;
		public String presentacion;	
		public String presentarPor;	
		public String organoGestor;	
		public String plazoResolucion;
		public String efectoSilencioAdministrativo;
		public String recursos;	
		public String normativaBasica;
		public cls_coleccionNormativas[] coleccionNormativas;
		public String informacionAdicional;
		public String nivelIdentificacionSolicitante;
		//public cls_coleccionDocumentos[] coleccionDocumentos;
		public String urlInicioTramitacion;	
		public String urlDescargaInstancia;	
		public String urlDetalleTramite;	
	}
}