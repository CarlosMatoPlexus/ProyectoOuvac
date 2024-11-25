public class Noticia {
    public Integer id;
    public String titulo;
    public String descripcion;
    public Institucion institucion;
    public Tema tema;
    public Boolean activo;
    public String fecha_creacion;
    public String fecha_modificacion;
    public Ambito ambito;
    public Data_es_json data_es_json;
    public Data_gl_json data_gl_json;
    public class Tema {
        public String name;
        public String code;
    }
    public class Institucion {
        public String name;
        public String code;
    }
    public class Ambito {
        public String code;
        public String name;
    }
    public class Imagen {
        public String url;
        public String titulo;
    }
    public class Data_gl_json {
        public String titulo;
        public String contenido;
        public List<String> categorias;
        public String fecha;
        public List<Imagen> imagenes;
        public String url;
    }
    public class Data_es_json {
        public String titulo;
        public String contenido;
        public List<String> categorias;
        public String fecha;
        public List<Imagen> imagenes;
        public String url;
    }
    // Método para deserializar el JSON y mapear la clave 'date' a 'fecha'
    public static Noticia fromJson(String jsonString) {
        // Convertimos el JSON a un mapa de objetos
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        // Verificamos si la clave 'data_gl_json.date' existe y la renombramos a 'fecha'
        if (jsonMap.containsKey('data_gl_json')) {
            Map<String, Object> dataGlJsonMap = (Map<String, Object>) jsonMap.get('data_gl_json');
            if (dataGlJsonMap != null && dataGlJsonMap.containsKey('date')) {
                dataGlJsonMap.put('fecha', dataGlJsonMap.remove('date'));
            }
        }
        // Verificamos si la clave 'data_es_json.date' existe y la renombramos a 'fecha'
        if (jsonMap.containsKey('data_es_json')) {
            Map<String, Object> dataEsJsonMap = (Map<String, Object>) jsonMap.get('data_es_json');
            if (dataEsJsonMap != null && dataEsJsonMap.containsKey('date')) {
                dataEsJsonMap.put('fecha', dataEsJsonMap.remove('date'));
            }
        }
        // Convertimos el mapa modificado a la clase Noticia
        return (Noticia) JSON.deserialize(JSON.serialize(jsonMap), Noticia.class);
    }
}