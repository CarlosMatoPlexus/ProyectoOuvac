public class NoticiaServiceToUpdate {
    public static void updateNoticia(List<String> detallesJson) {
        for (String jsonDetalle : detallesJson) {
            try {
                Noticia noticia = Noticia.fromJson(jsonDetalle);
                if (noticia == null) continue;
                List<Knowledge__kav> knowledges = [
                    SELECT Id, Language, KnowledgeArticleId
                    FROM Knowledge__kav
                    WHERE Noticia_Id__c = :String.valueOf(noticia.id)
                ];
                for (Knowledge__kav knowledge : knowledges) {
                    Knowledge__kav draftVersion = getOrCreateDraft(knowledge);
                    if (draftVersion != null) {
                        updateKnowledgeFields(draftVersion, noticia);
                        update draftVersion;
                        // Publicar siempre tras la actualización
                        KbManagement.PublishingService.publishArticle(draftVersion.KnowledgeArticleId, true);
                        System.debug('Artículo publicado: ' + draftVersion.Id + ' (Idioma: ' + draftVersion.Language + ')');
                    } else {
                        System.debug('No se encontró o creó draft para: ' + knowledge.Id);
                    }
                }
            } catch (Exception ex) {
                System.debug('🛑 Error al procesar noticia: ' + ex.getMessage());
            }
        }
    }
    private static Knowledge__kav getOrCreateDraft(Knowledge__kav publishedVersion) {
        try {
            // 1. Se verifica si ya existe Knowledge en estado Draft 
            List<Knowledge__kav> drafts = [
                SELECT Id, PublishStatus, KnowledgeArticleId, Language, CreatedDate
                FROM Knowledge__kav
                WHERE KnowledgeArticleId = :publishedVersion.KnowledgeArticleId
                AND PublishStatus = 'Draft'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (!drafts.isEmpty()) {
                System.debug('🔁 Usando Draft ya existente: ' + drafts[0].Id);
                return drafts[0];
            }
            // 2. Si no existe Draft → Se crea
            KbManagement.PublishingService.editOnlineArticle(publishedVersion.KnowledgeArticleId, false);
            System.debug('📄 Se creó nuevo Draft desde versión publicada: ' + publishedVersion.Id);
            // 3. Aqui esperamos que se publique el nuevo Draft (se vuelve a consultar)
            drafts = [
                SELECT Id, PublishStatus, KnowledgeArticleId, Language, CreatedDate
                FROM Knowledge__kav
                WHERE KnowledgeArticleId = :publishedVersion.KnowledgeArticleId
                AND PublishStatus = 'Draft'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (!drafts.isEmpty()) {
                return drafts[0];
            } else {
                System.debug('No se encontró el Draft luego de crear.');
                return null;
            }
        } catch (Exception e) {
            System.debug('Error al crear draft: ' + e.getMessage());
            return null;
        }
    }
    private static void updateKnowledgeFields(Knowledge__kav knowledge, Noticia noticia) {
        knowledge.Descripcion__c = noticia.descripcion;
        knowledge.Title = noticia.titulo;
        knowledge.fecha_modificacion__c = convertFechasJson(noticia.fecha_modificacion);
        knowledge.Activo__c = noticia.activo;
        if (knowledge.Language == 'es' && noticia.data_es_json != null) {
            if(noticia.data_es_json.titulo != null) knowledge.Titulo_noticia_Espanol__c = noticia.data_es_json.titulo;
            if(noticia.data_es_json.url != null) knowledge.Url_noticia_Espanol__c = noticia.data_es_json.url;
            if(noticia.data_es_json.fecha != null) knowledge.Fecha_noticia_Espanol__c = convertFechasJson(noticia.data_es_json.fecha);
            if(noticia.data_es_json.contenido != null) knowledge.Contenido_noticia_Espanol__c = noticia.data_es_json.contenido;
            if(noticia.data_es_json.categorias != null) {
                knowledge.Categorias_noticia_Espanol__c = String.join(noticia.data_es_json.categorias, '\n');
            }
            if(noticia.data_es_json.imagenes != null) {
                String imagenes = '';
                for (Noticia.Imagen img : noticia.data_es_json.imagenes) {
                    imagenes += img.titulo + img.url + '\n';
                }
                knowledge.Imagenes_noticias_Espanol__c = imagenes.removeEnd('\n');
            }
        }
        if (knowledge.Language == 'es_MX' && noticia.data_gl_json != null) {
            if(noticia.data_gl_json.titulo != null) knowledge.Titulo_noticia_Galego__c = noticia.data_gl_json.titulo;
            if(noticia.data_gl_json.url != null) knowledge.Url_noticia_Galego__c = noticia.data_gl_json.url;
            if(noticia.data_gl_json.fecha != null) knowledge.Fecha_noticia_Galego__c = convertFechasJson(noticia.data_gl_json.fecha);
            if(noticia.data_gl_json.contenido != null) knowledge.Contenido_noticia_Galego__c = noticia.data_gl_json.contenido;
            if(noticia.data_gl_json.categorias != null) {
                knowledge.Categorias_noticia_Galego__c = String.join(noticia.data_gl_json.categorias, '\n');
            }
            if(noticia.data_gl_json.imagenes != null) {
                String imagenes = '';
                for (Noticia.Imagen img : noticia.data_gl_json.imagenes) {
                    imagenes += img.titulo + img.url + '\n';
                }
                knowledge.Imagenes_noticias_Galego__c = imagenes.removeEnd('\n');
            }
        }
    }
    private static Datetime convertFechasJson(String fecha) {
        if (fecha == null) return null;
        String fechaSinOffset = fecha.substring(0, 19).replace('T', ' ');
        Integer offsetHoras = Integer.valueOf(fecha.substring(19, 22));
        return DateTime.valueOf(fechaSinOffset).addHours(offsetHoras);
    }
}