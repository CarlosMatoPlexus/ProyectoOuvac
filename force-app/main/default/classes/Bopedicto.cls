public class Bopedicto {
    public Integer id;	
	public Integer id_bop_edicto_externo;
	public Bop bop;
	public String sumario;	
	public Institucion institucion;
	public Tema tema;
	public boolean activo;
	public String fecha_creacion;	
	public String fecha_modificacion;
	public Ambito ambito;
	public Data_es_json data_es_json;
	public Data_gl_json data_gl_json;
	public class Bop {
		public Integer id;	
		public Integer id_bop_externo;	
	}
	public class Institucion {
		public String code;	
		public String name;	
	}
	public class Tema {
		public String code;	
		public String name;	
	}
	public class Ambito {
		public String code;	
		public String name;	
	}
	public class Data_es_json {
		public Integer id_bop_edicto_externo;	
		public String fecha_entrada;	
		public Integer numero_pagina;	
		public String tema;	
		public String entidad_nombre;
		public String entidad_nif;	
		public String sumario;	
		public String texto;	
		public String url_texto;
		public String url_pdf;	
		public String url_html;	
		public String url_epub;	
	}
	public class Data_gl_json {
		public Integer id_bop_edicto_externo;	
		public String fecha_entrada;	
		public Integer numero_pagina;	
		public String tema;	
		public String entidad_nombre;
		public String entidad_nif;	
		public String sumario;	
		public String texto;	
		public String url_texto;
		public String url_pdf;	
		public String url_html;	
		public String url_epub;
	}

    // Método para deserializar el JSON
    public static Bopedicto fromJson(String jsonString) {
        // Convertimos el JSON a un mapa de objetos
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        // Convertimos el mapa a la clase Bopedicto
        return (Bopedicto) JSON.deserialize(JSON.serialize(jsonMap), Bopedicto.class);
    }
}