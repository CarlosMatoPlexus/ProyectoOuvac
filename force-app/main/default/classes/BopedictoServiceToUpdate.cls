public class BopedictoServiceToUpdate {
    public static void updateBopedicto(List<String> detallesJson) {
        // Listas para almacenar los objetos de Knowledge a actualizar
        List<Knowledge__kav> knowledgeToUpdate = new List<Knowledge__kav>();
        List<Knowledge__kav> knowledgeToPublish = new List<Knowledge__kav>();
        for (String jsonDetalle : detallesJson) {
            try {
                // Deserializa el JSON en un objeto de Bopedicto
                Bopedicto bopedicto = Bopedicto.fromJson(jsonDetalle);
                if (bopedicto != null) {
                    // Query para obtener los registros de Knowledge en ambos idiomas (es y es_MX)
                    List<Knowledge__kav> knowledges = [
                        SELECT Id, Language, PublishStatus, KnowledgeArticleId, Bopedicto_Id__c,
                               Title, Descripcion__c, Activo__c, Fecha_de_creacion__c, fecha_modificacion__c,
                               Ambitos__c, Entidades__c, UrlName, Bopedicto_Id_bop_edicto_externo__c, Sumario__c,
                               Bopedicto_Bop_Id__c, Bopedicto_bop_id_bop_externo__c, Bopedicto_Id_bop_edicto_externo_Esp__c,
                               Bopedicto_fecha_entrada_Esp__c, Bopedicto_numero_pagina_Esp__c, Bopedicto_entidad_nombre_Esp__c,
                               Bopedicto_entidad_nif_Esp__c, Bopedicto_sumario_Esp__c, Bopedicto_texto_Esp__c, Bopedicto_Url_texto_Esp__c,
                               Bopedicto_Url_pdf_Esp__c, Bopedicto_Url_html_Esp__c, Bopedicto_Url_epub_Esp__c,
                               Bopedicto_Id_bop_edicto_externo_Gal__c, Bopedicto_fecha_entrada_Gal__c, Bopedicto_numero_pagina_Gal__c,
                               Bopedicto_entidad_nombre_Gal__c, Bopedicto_entidad_nif_Gal__c, Bopedicto_sumario_Gal__c, Bopedicto_texto_Gal__c,
                               Bopedicto_Url_texto_Gal__c, Bopedicto_Url_pdf_Gal__c, Bopedicto_Url_html_Gal__c, Bopedicto_Url_epub_Gal__c,
                               IdiomaFormula__c
                        FROM Knowledge__kav
                        WHERE Bopedicto_Id__c = :String.valueOf(bopedicto.id)
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
                        // Asegurarse de que ambos bopedictos estén en borrador antes de actualizar
                        retractIfPublished(knowCastellano);
                        System.debug('Verificando el estado después de retractar...');
                        // Si ambos bopedictos están en borrador, proceder con la actualización
                        if (knowCastellano.PublishStatus == 'Draft') {
                            updateKnowledgeFields(knowCastellano, bopedicto);
                            // Añadir los bopedictos a las listas para actualización y publicación
                            knowledgeToUpdate.add(knowCastellano);
                        } else {
                            //retractIfPublished(knowCastellano);
                            System.debug('No se pudo retractar a borrador el bopedicto en español'+' '+knowCastellano.Bopedicto_Id__c+'.');
                        }
                    } else {
                        System.debug('No se encontró Knowledge español para el id de bopedictos: ' + bopedicto.id);
                    }
                    if (knowOtraLengua != null) {
                        // Asegurarse de que ambos bopedictos estén en borrador antes de actualizar
                        retractIfPublished(knowOtraLengua);
                        System.debug('Verificando el estado después de retractar...');
                        // Si ambos bopedictos están en borrador, proceder con la actualización
                        if(knowOtraLengua.PublishStatus == 'Draft'){
                            updateKnowledgeFields(knowOtraLengua, bopedicto);
                            // Añadir los bopedictos a las listas para actualización y publicación
                            knowledgeToUpdate.add(knowOtraLengua);
                        }else {
                            //retractIfPublished(knowOtraLengua);
                            System.debug('No se pudo retractar a borrador el bopedicto en galego'+' '+knowOtraLengua.Bopedicto_Id__c+'.');
                        }
                    } else {
                        System.debug('No se encontró Knowledge galego para el id de bopedictos: ' + bopedicto.id);
                    }
                }
            } catch (Exception ex) {
                System.debug('Error al procesar el bopedicto: ' + ex.getMessage());
            }
        }
        if (!knowledgeToUpdate.isEmpty()) {
            // Actualizar los registros de Knowledge
            update knowledgeToUpdate;
            
            // Publicar los bopedictos después de la actualización
            for (Knowledge__kav knowledge : knowledgeToUpdate) {
                knowledgeToPublish.add(knowledge);
            }
            publishKnowledgeArticles(knowledgeToPublish);
        }
    }
    // Método auxiliar para retractar bopedictos si están publicados
    private static void retractIfPublished(Knowledge__kav knowledge) {
        if (knowledge.PublishStatus == 'Online') {
            KbManagement.PublishingService.editOnlineArticle(knowledge.KnowledgeArticleId, false);
            // Asegurarse de que el estado se ha cambiado a Draft
            System.debug('Retractando bopedicto con Id: ' + knowledge.Bopedicto_Id__c +'-'+knowledge.IdiomaFormula__c);
            Long startTime = DateTime.now().getTime();
            Long finishTime = DateTime.now().getTime();
            while ((finishTime - startTime) < 100) {
                //sleep for 0,1s
                finishTime = DateTime.now().getTime();
            }
        }
    }
    
    private static void updateKnowledgeFields(Knowledge__kav knowledge, Bopedicto bopedicto) {
        // Campos que no deben ser actualizados
        Set<String> camposNoActualizables = new Set<String>{'Bopedicto_Id__c', 'RecordTypeId', 'Entidades__c', 'Ambitos__c', 'UrlName', 'Language', 'Fecha_de_creacion__c, Bopedicto_Bop_Id__c, Bopedicto_bop_id_bop_externo__c, Bopedicto_Id_bop_edicto_externo_Esp__c, Bopedicto_Id_bop_edicto_externo_Gal__c'};
        // Solo actualizar si los campos no están en la lista de no actualizables
        if(knowledge.Language == 'es' && bopedicto.data_es_json != null){
            if (!camposNoActualizables.contains('Sumario__c')) {
                knowledge.Sumario__c = bopedicto.sumario;
            }
            if (!camposNoActualizables.contains('Activo__c')) {
                knowledge.Activo__c = bopedicto.activo;
            }
            if (!camposNoActualizables.contains('fecha_modificacion__c')) {
                knowledge.fecha_modificacion__c = convertFechasJson(bopedicto.fecha_modificacion);
            }
            if(bopedicto.data_es_json.fecha_entrada != null){
                knowledge.Bopedicto_fecha_entrada_Esp__c = convertFechasJson(bopedicto.data_es_json.fecha_entrada);
            }
            if(bopedicto.data_es_json.numero_pagina != null){
                knowledge.Bopedicto_numero_pagina_Esp__c = bopedicto.data_es_json.numero_pagina;
            }
            
            if(bopedicto.data_es_json.entidad_nombre != null){
                knowledge.Bopedicto_entidad_nombre_Esp__c = bopedicto.data_es_json.entidad_nombre;
            }
            if(bopedicto.data_es_json.entidad_nif != null){
                knowledge.Bopedicto_entidad_nif_Esp__c = bopedicto.data_es_json.entidad_nif;
            }
            if(bopedicto.data_es_json.sumario != null){
                knowledge.Bopedicto_sumario_Esp__c = bopedicto.data_es_json.sumario;
                knowledge.Title = bopedicto.data_es_json.sumario;
                knowledge.Descripcion__c = bopedicto.data_es_json.sumario;
            }else {
                knowledge.Title = bopedicto.sumario;
                knowledge.Descripcion__c = bopedicto.sumario;
            }
            if(bopedicto.data_es_json.texto != null){
                knowledge.Bopedicto_texto_Esp__c = bopedicto.data_es_json.texto;
            }
            if(bopedicto.data_es_json.url_texto != null){
                knowledge.Bopedicto_Url_texto_Esp__c = bopedicto.data_es_json.url_texto;
            }
            if(bopedicto.data_es_json.url_pdf != null){
                knowledge.Bopedicto_Url_pdf_Esp__c = bopedicto.data_es_json.url_pdf;
            }
            if(bopedicto.data_es_json.url_html != null){
                knowledge.Bopedicto_Url_html_Esp__c = bopedicto.data_es_json.url_html;
            }
            if(bopedicto.data_es_json.url_epub != null){
                knowledge.Bopedicto_Url_epub_Esp__c = bopedicto.data_es_json.url_epub;
            }
        }else if (knowledge.Language == 'es_MX' && bopedicto.data_gl_json != null){
            if (!camposNoActualizables.contains('Sumario__c')) {
                knowledge.Sumario__c = bopedicto.sumario;
            }
            if (!camposNoActualizables.contains('Activo__c')) {
                knowledge.Activo__c = bopedicto.activo;
            }
            if (!camposNoActualizables.contains('fecha_modificacion__c')) {
                knowledge.fecha_modificacion__c = convertFechasJson(bopedicto.fecha_modificacion);
            }
            if(bopedicto.data_gl_json.fecha_entrada != null){
                knowledge.Bopedicto_fecha_entrada_Gal__c = convertFechasJson(bopedicto.data_gl_json.fecha_entrada);
            }
            if(bopedicto.data_gl_json.numero_pagina != null){
                knowledge.Bopedicto_numero_pagina_Gal__c = bopedicto.data_gl_json.numero_pagina;
            }
            if(bopedicto.data_gl_json.entidad_nombre != null){
                knowledge.Bopedicto_entidad_nombre_Gal__c = bopedicto.data_gl_json.entidad_nombre;
            }
            if(bopedicto.data_gl_json.entidad_nif != null){
                knowledge.Bopedicto_entidad_nif_Gal__c = bopedicto.data_gl_json.entidad_nif;
            }
            if(bopedicto.data_gl_json.sumario != null){
                knowledge.Bopedicto_sumario_Gal__c = bopedicto.data_gl_json.sumario;
                knowledge.Title = bopedicto.data_gl_json.sumario;
                knowledge.Descripcion__c = bopedicto.data_es_json.sumario;
            }else{
                knowledge.Title = bopedicto.sumario;
                knowledge.Descripcion__c = bopedicto.sumario;
            }
            if(bopedicto.data_gl_json.texto != null){
                knowledge.Bopedicto_texto_Gal__c = bopedicto.data_gl_json.texto;
            }
            if(bopedicto.data_gl_json.url_texto != null){
                knowledge.Bopedicto_Url_texto_Gal__c = bopedicto.data_gl_json.url_texto;
            }
            if(bopedicto.data_gl_json.url_pdf != null){
                knowledge.Bopedicto_Url_pdf_Gal__c = bopedicto.data_gl_json.url_pdf;
            }
            if(bopedicto.data_gl_json.url_html != null){
                knowledge.Bopedicto_Url_html_Gal__c = bopedicto.data_gl_json.url_html;
            }
            if(bopedicto.data_gl_json.url_epub != null){
                knowledge.Bopedicto_Url_epub_Gal__c = bopedicto.data_gl_json.url_epub;
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
            System.debug('Knowledge UrlName'+' '+knowledge.UrlName);
            knowId.add(knowledge.Id);
        }
        List<KnowledgeArticleVersion> lstKnowPublish = new List<KnowledgeArticleVersion>();
        lstKnowPublish = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft' AND Id IN: knowId];
        for(KnowledgeArticleVersion know : lstKnowPublish){
            KbManagement.PublishingService.publishArticle(know.KnowledgeArticleId, true);
        }
    }
}