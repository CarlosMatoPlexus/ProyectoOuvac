public class NoticiaService {
    public static void procesarNoticia(List<String> detallesJson) {
        for (String jsonDetalle : detallesJson){
            try {
                //Declaracion de variables
                Knowledge__kav knowCastellano = new Knowledge__kav();
                Knowledge__kav knowOtraLengua = new Knowledge__kav();
                List<Knowledge__kav> lstKnowledge = new List<Knowledge__kav>();
                String noticia_Id;
                String titulo;
                String descripcion;
                Boolean activo;
                String fecha_creacion;
                Datetime fechaCreacion;
                String fecha_modificacion;
                Datetime fechaModificacion;
                String ambito;
                String entidad;
                
                //Variables data_es_json
                
                String titulo_espanol;
                String url_espanol;
                String fecha_espanol;
                Datetime fechaEspanol;
                String contenido_espanol;
                String categorias_espanol = '';
                String imagenes_espanol = '';
                
                //Variables data_gl_json
                
                String titulo_galego;
                String url_galego;
                String fecha_galego;
                Datetime fechaGalego;
                String contenido_galego;
                String categorias_galego = '';
                String imagenes_galego = '';
                
                //Variable recordType
                String noticiaRecordTypeID = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Noticias').getRecordTypeId();
                
                // Deserializa el JSON en un objeto de Noticia
                Noticia noticia = Noticia.fromJson(jsonDetalle);
                // Procesar los datos principales de la noticia
                if(noticia !=null){
                    noticia_Id = String.valueOf(noticia.id);
                    titulo = noticia.titulo;
                    descripcion = noticia.descripcion;
                    activo = noticia.activo;
                    fecha_creacion = noticia.fecha_creacion;
                    fecha_modificacion = noticia.fecha_modificacion;
                    if(noticia.tema != null){
                        ambito = noticia.tema.name;
                    }else{
                        ambito = 'Transparencia';
                    }
                    if(noticia.ambito != null){
                        entidad = noticia.ambito.name;
                    }else {
                        entidad = 'Deputación';
                    }
                    if(entidad.contains('Diputación')){
                        entidad = 'Deputación';
                    }
                    if(entidad.contains(',')){
                        entidad = entidad.replace(',', '');
                    }
                    
                    if(noticia.data_es_json != null){
                        if(noticia.data_es_json.titulo != null){
                            titulo_espanol = noticia.data_es_json.titulo;
                        }
                        if(noticia.data_es_json.url != null){
                            url_espanol = noticia.data_es_json.url;
                        }
                        if(noticia.data_es_json.fecha != null){
                            fecha_espanol = noticia.data_es_json.fecha;
                            fechaEspanol = convertFechasJson(fecha_espanol);
                            System.debug('fechaEspanol:'+ fechaEspanol);
                        }
                        if(noticia.data_es_json.contenido != null){
                            contenido_espanol = noticia.data_es_json.contenido;
                        }
                        if(noticia.data_es_json.categorias != null){
                            for(String catEsp : noticia.data_es_json.categorias){
                                String cat = '';
                                if(catEsp != null){
                                    cat += catEsp;
                                    cat += '\n';
                                    categorias_espanol += cat;
                                }
                            }
                            categorias_espanol = categorias_espanol.removeEnd('\n');
                        }
                        if(noticia.data_es_json.imagenes != null){
                            for(Noticia.Imagen imgEsp : noticia.data_es_json.imagenes){
                                imagenes_espanol = imgEsp.titulo;
                                imagenes_espanol += imgEsp.url;
                                imagenes_espanol += '\n';
                            }
                            imagenes_espanol = imagenes_espanol.removeEnd('\n');
                        }
                        System.debug(imagenes_espanol);
                    }else {
                        System.debug('No hay datos en data_es_json');
                    }
                    if(noticia.data_gl_json != null){
                        if(noticia.data_gl_json.titulo != null){
                            titulo_galego = noticia.data_gl_json.titulo;
                        }
                        if(noticia.data_gl_json.url != null){
                            url_galego = noticia.data_gl_json.url;
                        }
                        if(noticia.data_gl_json.fecha != null){
                            fecha_galego = noticia.data_gl_json.fecha;
                            fechaGalego = convertFechasJson(fecha_galego);
                            System.debug('fechaGalego: '+ fechaGalego);
                        }
                        if(noticia.data_gl_json.contenido != null){
                            contenido_galego = noticia.data_gl_json.contenido;
                        }
                        if(noticia.data_gl_json.categorias != null){
                            for(String catGal : noticia.data_gl_json.categorias){
                                String cat = '';
                                if(catGal != null){
                                    cat += catGal;
                                    cat += '\n';
                                    categorias_galego += cat;
                                }
                            }
                            categorias_galego = categorias_galego.removeEnd('\n');
                        }
                        if(noticia.data_gl_json.imagenes != null){
                            for(Noticia.Imagen imgGal : noticia.data_gl_json.imagenes){
                                String img = '';
                                if(imgGal.titulo != ''){
                                    img = imgGal.titulo;
                                    img += '\n';
                                }
                                img += imgGal.url;
                                img += '\n';
                                
                                imagenes_galego +=img;
                            }
                            imagenes_galego = imagenes_galego.removeEnd('\n');
                        }
                        System.debug(imagenes_galego);
                        System.debug(categorias_galego);
                    }else {
                        System.debug('No hay datos en data_gl_json');
                    }
                    if(fecha_modificacion != null){
                        fechaModificacion = convertFechasJson(fecha_modificacion);
                        System.debug('fechaModificacion: '+fechaModificacion);
                    }else{
                        System.debug('fecha_modificacion es null');
                    }
                    if(fecha_creacion != null){
                        fechaCreacion = convertFechasJson(fecha_creacion);
                        System.debug('fechaCreacion: '+fechaCreacion);
                    }else{
                        System.debug('fecha_creacion es null');
                    }
                    if(noticia.data_es_json != null){
                        if(noticia_Id != null){
                            knowCastellano.Noticia_Id__c = noticia_Id;
                            knowCastellano.UrlName = noticia_Id+'-'+'Esp';
                        }
                        if(titulo != null){
                            knowCastellano.Title = titulo;
                        }
                        if(descripcion != null){
                            knowCastellano.Descripcion__c = descripcion;
                        }
                        if(activo != null){
                            knowCastellano.Activo__c = activo;
                        }
                        if(fechaCreacion != null){
                            knowCastellano.Fecha_de_creacion__c = fechaCreacion;
                        }
                        if(fechaModificacion != null){
                            knowCastellano.fecha_modificacion__c = fechaModificacion;
                        }
                        if(ambito != null){
                            knowCastellano.Ambitos__c = ambito;
                        }
                        if(entidad != null){
                            knowCastellano.Entidades__c = entidad;
                        }
                        if(titulo_espanol != null){
                            knowCastellano.Titulo_noticia_Espanol__c = titulo_espanol;
                        }
                        if(url_espanol != null){
                            knowCastellano.Url_noticia_Espanol__c = url_espanol;
                        }
                        if(fechaEspanol != null){
                            knowCastellano.Fecha_noticia_Espanol__c = fechaEspanol;
                        }
                        if(contenido_espanol != null){
                            knowCastellano.Contenido_noticia_Espanol__c = contenido_espanol;
                        }
                        if(categorias_espanol != ''){
                            knowCastellano.Categorias_noticia_Espanol__c = categorias_espanol;
                        }
                        if(imagenes_espanol != ''){
                            knowCastellano.Imagenes_noticias_Espanol__c = imagenes_espanol;
                        }
                        knowCastellano.ValidationStatus = 'Validated';
                        knowCastellano.RecordTypeId = noticiaRecordTypeID;
                        knowCastellano.Language = 'es';
                        lstKnowledge.add(knowCastellano);
                    }
                    if(noticia.data_gl_json != null){
                        if(noticia_Id != null){
                            knowOtraLengua.Noticia_Id__c = noticia_Id;
                            knowOtraLengua.UrlName = noticia_Id+'-'+'Gal';
                        }
                        if(titulo != null){
                            knowOtraLengua.Title = titulo;
                        }
                        if(descripcion != null){
                            knowOtraLengua.Descripcion__c = descripcion;
                        }
                        if(activo != null){
                            knowOtraLengua.Activo__c = activo;
                        }
                        if(fechaCreacion != null){
                            knowOtraLengua.Fecha_de_creacion__c = fechaCreacion;
                        }
                        if(fechaModificacion != null){
                            knowOtraLengua.fecha_modificacion__c = fechaModificacion;
                        }
                        if(ambito != null){
                            knowOtraLengua.Ambitos__c = ambito;
                        }
                        if(entidad != null){
                            knowOtraLengua.Entidades__c = entidad;
                        }
                        if(titulo_galego != null){
                            knowOtraLengua.Titulo_noticia_Galego__c= titulo_galego;
                        }
                        if(url_galego != null){
                            knowOtraLengua.Url_noticia_Galego__c = url_galego;
                        }
                        if(fechaGalego != null){
                            knowOtraLengua.Fecha_noticia_Galego__c = fechaGalego;
                        }
                        if(contenido_galego != null){
                            knowOtraLengua.Contenido_noticia_Galego__c = contenido_galego;
                        }
                        if(categorias_galego != ''){
                            knowOtraLengua.Categorias_noticia_Galego__c = categorias_galego;
                        }
                        if(imagenes_galego != ''){
                            knowOtraLengua.Imagenes_noticias_Galego__c = imagenes_galego;
                        }
                        knowOtraLengua.ValidationStatus = 'Validated';
                        knowOtraLengua.RecordTypeId = noticiaRecordTypeID;
                        knowOtraLengua.Language = 'es_MX';
                        lstKnowledge.add(knowOtraLengua);
                    }
                    if(lstKnowledge.size()>0){
                        insert lstKnowledge ;
                        List<KnowledgeArticleVersion> lstKnowPublish = new List<KnowledgeArticleVersion>();
                        lstKnowPublish = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft'];
                        for(KnowledgeArticleVersion know : lstKnowPublish){
                            KbManagement.PublishingService.publishArticle(know.KnowledgeArticleId, true);
                        }
                    }
                }
            } catch (Exception ex) {
                System.debug('Ocurrió un error al procesar la noticia: ' + ex.getMessage());
            }
        }
    }
    private static Datetime convertFechasJson (String fecha) {
        Datetime fechaModificada = null;
        if(fecha != null){
            String fechaModificacionSinOffset = fecha.substring(0, 19);
            String offSetModificacion = fecha.substring(19, 22);
            Integer horasOffsetModificacion = Integer.valueOf(offSetModificacion);
            fechaModificacionSinOffset = fechaModificacionSinOffset.replace('T', ' ');
            fechaModificada = DateTime.valueOf(fechaModificacionSinOffset);
            fechaModificada = fechaModificada.addHours(horasOffsetModificacion);
        }
        return fechaModificada;
    }
}