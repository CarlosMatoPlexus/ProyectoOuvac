public class NoticiaServiceToUpdate {
    public static void updateNoticia(List<String> detallesJson) {
        // Listas para almacenar los objetos de Knowledge a actualizar
        List<Knowledge__kav> knowledgeToUpdate = new List<Knowledge__kav>();
        List<Knowledge__kav> knowledgeToPublish = new List<Knowledge__kav>();
        for (String jsonDetalle : detallesJson) {
            try {
                // Deserializa el JSON en un objeto de Noticia
                Noticia noticia = Noticia.fromJson(jsonDetalle);
                if (noticia != null) {
                    // Query para obtener los registros de Knowledge en ambos idiomas (es y es_MX)
                    List<Knowledge__kav> knowledges = [
                        SELECT Id, Language, PublishStatus, KnowledgeArticleId, Noticia_Id__c,
                               Title, Descripcion__c, Activo__c, Fecha_de_creacion__c, fecha_modificacion__c,
                               Ambitos__c, Entidades__c, Titulo_noticia_Galego__c, Url_noticia_Galego__c,
                               Fecha_noticia_Galego__c, Contenido_noticia_Galego__c, Categorias_noticia_Galego__c,
                               Imagenes_noticias_Galego__c, Titulo_noticia_Espanol__c, Url_noticia_Espanol__c,
                               Fecha_noticia_Espanol__c, Contenido_noticia_Espanol__c, Categorias_noticia_Espanol__c,
                               Imagenes_noticias_Espanol__c, UrlName
                        FROM Knowledge__kav
                        WHERE Noticia_Id__c = :String.valueOf(noticia.id)
                    ];
                    // Variables para almacenar Knowledge en español y Galego
                    Knowledge__kav knowCastellano;
                    Knowledge__kav knowOtraLengua;
                    // Separar los registros por idioma
                    for (Knowledge__kav knowledge : knowledges) {
                        if (knowledge.Language == 'es') {
                            knowCastellano = knowledge;
                        } else if (knowledge.Language == 'es_MX') {
                            knowOtraLengua = knowledge;
                        }
                    }
                    if (knowCastellano != null) {
                        // Asegurarse de que ambos artículos estén en borrador antes de actualizar
                        retractIfPublished(knowCastellano);
                        System.debug('Verificando el estado después de retractar...');
                        // Si ambos artículos están en borrador, proceder con la actualización
                        if (knowCastellano.PublishStatus == 'Draft') {
                            updateKnowledgeFields(knowCastellano, noticia);
                            // Añadir los artículos a las listas para actualización y publicación
                            knowledgeToUpdate.add(knowCastellano);
                        } else {
                            System.debug('No se pudo retractar a borrador la noticia en español.');
                        }
                    } else {
                        System.debug('No se encontró Knowledge español para el id de noticia: ' + noticia.id);
                    }
                    if (knowOtraLengua != null) {
                        // Asegurarse de que ambos artículos estén en borrador antes de actualizar
                        retractIfPublished(knowOtraLengua);
                        System.debug('Verificando el estado después de retractar...');
                        // Si ambos artículos están en borrador, proceder con la actualización
                        if (knowOtraLengua.PublishStatus == 'Draft') {
                            updateKnowledgeFields(knowOtraLengua, noticia);
                            // Añadir los artículos a las listas para actualización y publicación
                            knowledgeToUpdate.add(knowOtraLengua);
                        } else {
                            System.debug('No se pudo retractar a borrador la noticia en galego.');
                        }
                    } else {
                        System.debug('No se encontró Knowledge galego para el id de noticia: ' + noticia.id);
                    }
                }
            } catch (Exception ex) {
                System.debug('Error al procesar la convocatoria: ' + ex.getMessage());
            }
        }
        if (!knowledgeToUpdate.isEmpty()) {
            // Actualizar los registros de Knowledge
            update knowledgeToUpdate;
            
            // Publicar los artículos después de la actualización
            for (Knowledge__kav knowledge : knowledgeToUpdate) {
                knowledgeToPublish.add(knowledge);
            }
            publishKnowledgeArticles(knowledgeToPublish);
        }
    }
    // // Método auxiliar para retractar artículos si están publicados
    // private static void retractIfPublished(Knowledge__kav knowledge) {
    //     if (knowledge.PublishStatus == 'Online') {
    //         KbManagement.PublishingService.editOnlineArticle(knowledge.KnowledgeArticleId, false);
    //         // Asegurarse de que el estado se ha cambiado a Draft
    //         System.debug('Retractando artículo con Id: ' + knowledge.Id);
    //     }
    // }

    private static void retractIfPublished(Knowledge__kav knowledge) {
        try {
            if (knowledge.PublishStatus == 'Online') {
                KbManagement.PublishingService.editOnlineArticle(knowledge.KnowledgeArticleId, false);
                System.debug('Retractando artículo con Id: ' + knowledge.Id);
                // Consulta nuevamente el artículo para verificar el cambio
                knowledge = [SELECT Id, PublishStatus FROM Knowledge__kav WHERE Id = :knowledge.Id];
                System.debug('Estado actual del artículo después de retractarlo: ' + knowledge.PublishStatus);
                if (knowledge.PublishStatus != 'Draft') {
                    System.debug('Advertencia: El artículo no se pudo mover a estado "Draft".');
                }
            }
        } catch (Exception e) {
            System.debug('Error al intentar retractar el artículo: ' + e.getMessage());
        }
     }
    
    private static void updateKnowledgeFields(Knowledge__kav knowledge, Noticia noticia) {
        // Campos que no deben ser actualizados
        Set<String> camposNoActualizables = new Set<String>{'Noticia_Id__c', 'RecordTypeId', 'Entidades__c', 'Ambitos__c', 'UrlName', 'Language', 'Fecha_de_creacion__c'};
        // Solo actualizar si los campos no están en la lista de no actualizables
        if(knowledge.Language == 'es' && noticia.data_es_json != null){
            if (!camposNoActualizables.contains('Descripcion__c')) {
                knowledge.Descripcion__c = noticia.descripcion;
            }
            if (!camposNoActualizables.contains('Title')) {
                knowledge.Title = noticia.titulo;
            }
            if (!camposNoActualizables.contains('fecha_modificacion__c')) {
                knowledge.fecha_modificacion__c = convertFechasJson(noticia.fecha_modificacion);
            }
            if (!camposNoActualizables.contains('Activo__c')) {
                knowledge.Activo__c = noticia.activo;
            }
            if(noticia.data_es_json.titulo !=null){
                knowledge.Titulo_noticia_Espanol__c = noticia.data_es_json.titulo;
            }
            if(noticia.data_es_json.url !=null){
                knowledge.Url_noticia_Espanol__c = noticia.data_es_json.url;
            }
            if(noticia.data_es_json.fecha != null){
                String fecha_espanol = noticia.data_es_json.fecha;
                knowledge.Fecha_noticia_Espanol__c = convertFechasJson(fecha_espanol);
            }
            if(noticia.data_es_json.contenido != null){
                knowledge.Contenido_noticia_Espanol__c = noticia.data_es_json.contenido;
            }
            if(noticia.data_es_json.categorias != null){
                String categorias_espanol = '' ;
                for(String catEsp : noticia.data_es_json.categorias){
                    String cat = '';
                    if(catEsp != null){
                        cat += catEsp;
                        cat += '\n';
                        categorias_espanol += cat;
                    }
                }
                categorias_espanol = categorias_espanol.removeEnd('\n');
                knowledge.Categorias_noticia_Espanol__c = categorias_espanol;
            }
            if(noticia.data_es_json.imagenes != null){
                String imagenes_espanol = '';
                for(Noticia.Imagen imgEsp : noticia.data_es_json.imagenes){
                    imagenes_espanol = imgEsp.titulo;
                    imagenes_espanol += imgEsp.url;
                    imagenes_espanol += '\n';
                }
                imagenes_espanol = imagenes_espanol.removeEnd('\n');
                knowledge.Imagenes_noticias_Espanol__c = imagenes_espanol;
            }
        }else if (knowledge.Language == 'es_MX' && noticia.data_gl_json != null){
            if (!camposNoActualizables.contains('Descripcion__c')) {
                knowledge.Descripcion__c = noticia.descripcion;
            }
            if (!camposNoActualizables.contains('Title')) {
                knowledge.Title = noticia.titulo;
            }
            if (!camposNoActualizables.contains('fecha_modificacion__c')) {
                knowledge.fecha_modificacion__c = convertFechasJson(noticia.fecha_modificacion);
            }
            if (!camposNoActualizables.contains('Activo__c')) {
                knowledge.Activo__c = noticia.activo;
            }
            if(noticia.data_gl_json.titulo !=null){
                knowledge.Titulo_noticia_Galego__c = noticia.data_gl_json.titulo;
            }
            if(noticia.data_gl_json.url !=null){
                knowledge.Url_noticia_Galego__c = noticia.data_gl_json.url;
            }
            if(noticia.data_gl_json.fecha != null){
                String fecha_galego = noticia.data_gl_json.fecha;
                knowledge.Fecha_noticia_Galego__c = convertFechasJson(fecha_galego);
            }
            if(noticia.data_gl_json.contenido != null){
                knowledge.Contenido_noticia_Galego__c = noticia.data_gl_json.contenido;
            }
            if(noticia.data_gl_json.categorias != null){
                String categorias_galego = '' ;
                for(String catGal : noticia.data_gl_json.categorias){
                    String cat = '';
                    if(catGal != null){
                        cat += catGal;
                        cat += '\n';
                        categorias_galego += cat;
                    }
                }
                categorias_galego = categorias_galego.removeEnd('\n');
                knowledge.Categorias_noticia_Galego__c = categorias_galego;
            }
            if(noticia.data_gl_json.imagenes != null){
                String imagenes_galego = '';
                for(Noticia.Imagen imgEsp : noticia.data_gl_json.imagenes){
                    imagenes_galego = imgEsp.titulo;
                    imagenes_galego += imgEsp.url;
                    imagenes_galego += '\n';
                }
                imagenes_galego = imagenes_galego.removeEnd('\n');
                knowledge.Imagenes_noticias_Galego__c = imagenes_galego;
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
    
    // Método auxiliar para publicar los artículos de Knowledge
    private static void publishKnowledgeArticles(List<Knowledge__kav> knowledgeArticles) {
        Set<Id> knowId = new Set<Id>();
        for (Knowledge__kav knowledge : knowledgeArticles){
            knowId.add(knowledge.Id);
        }
        List<KnowledgeArticleVersion> lstKnowPublish = new List<KnowledgeArticleVersion>();
        lstKnowPublish = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft' AND Id IN: knowId];
        for(KnowledgeArticleVersion know : lstKnowPublish){
            KbManagement.PublishingService.publishArticle(know.KnowledgeArticleId, true);
        }
    }
}