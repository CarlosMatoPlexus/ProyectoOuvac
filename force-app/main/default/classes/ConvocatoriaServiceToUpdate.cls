public class ConvocatoriaServiceToUpdate {
    public static void updateConvocatoria(List<String> detallesJson) {
        // Listas para almacenar los objetos de Knowledge a actualizar
        List<Knowledge__kav> knowledgeToUpdate = new List<Knowledge__kav>();
        List<Knowledge__kav> knowledgeToPublish = new List<Knowledge__kav>();
        for (String jsonDetalle : detallesJson) {
            try {
                // Deserializar el JSON en un objeto Convocatoria
                Convocatoria convocatoria = (Convocatoria) JSON.deserialize(jsonDetalle, Convocatoria.class);
                if (convocatoria != null) {
                    // Query para obtener los registros de Knowledge en ambos idiomas (es y es_MX)
                    List<Knowledge__kav> knowledges = [
                        SELECT Id, Title, Descripcion__c, Importe_total__c, fondo_ue__c, Activo__c,
                               NombreDocumentoCastellano__c, NombreDocumentoOtraLengua__c,
                               URLEspBR__c, URLengBR__c, InicioSolicitud__c, FechaFinSolicitud__c,
                               NombreJustificacion__c, FechaJustificacion__c, CodigoImpactoGenero__c,
                               NombreImpactoGenero__c, TituloExtractoCastellano__c, ExtractoCastellano__c,
                               TituloExtractoOtraLengua__c, ExtractoOtraLengua__c, DescripcionOtro__c,
                               NombreOtrosDocumentos__c, fecha_modificacion__c, Language, PublishStatus, KnowledgeArticleId
                        FROM Knowledge__kav
                        WHERE code_bdns__c = :convocatoria.code_bdns
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
                    if (knowCastellano != null && knowOtraLengua != null) {
                        // Asegurarse de que ambos artículos estén en borrador antes de actualizar
                        retractIfPublished(knowCastellano);
                        retractIfPublished(knowOtraLengua);
                        System.debug('Verificando el estado después de retractar...');
                        knowCastellano = [SELECT PublishStatus FROM Knowledge__kav WHERE Id = :knowCastellano.Id];
                        knowOtraLengua = [SELECT PublishStatus FROM Knowledge__kav WHERE Id = :knowOtraLengua.Id];
                        // Si ambos artículos están en borrador, proceder con la actualización
                        if (knowCastellano.PublishStatus == 'Draft' && knowOtraLengua.PublishStatus == 'Draft') {
                            updateKnowledgeFields(knowCastellano, convocatoria);
                            updateKnowledgeFields(knowOtraLengua, convocatoria);
                            // Añadir los artículos a las listas para actualización y publicación
                            knowledgeToUpdate.add(knowCastellano);
                            knowledgeToUpdate.add(knowOtraLengua);
                        } else {
                            System.debug('No se pudo retractar a borrador uno de los artículos.');
                        }
                    } else {
                        System.debug('No se encontró Knowledge para el código BDNS: ' + convocatoria.code_bdns);
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
    // Método auxiliar para retractar artículos si están publicados
    private static void retractIfPublished(Knowledge__kav knowledge) {
        if (knowledge.PublishStatus == 'Online') {
            KbManagement.PublishingService.editOnlineArticle(knowledge.KnowledgeArticleId, false);
            // Asegurarse de que el estado se ha cambiado a Draft
            System.debug('Retractando artículo con Id: ' + knowledge.Id);
        }
    }
    // Método auxiliar para actualizar los campos de cada artículo de Knowledge
    private static void updateKnowledgeFields(Knowledge__kav knowledge, Convocatoria convocatoria) {
        // Campos que no deben ser actualizados
        Set<String> camposNoActualizables = new Set<String>{'code_bdns__c', 'RecordTypeId', 'Entidades__c', 'Ambitos__c', 'UrlName', 'Language', 'URL_documentacion_convocatoria__c'};
        // Solo actualizar si los campos no están en la lista de no actualizables
        if (!camposNoActualizables.contains('Descripcion__c')) {
            knowledge.Descripcion__c = convocatoria.descripcion;
        }
        if (!camposNoActualizables.contains('Importe_total__c')) {
            knowledge.Importe_total__c = convocatoria.importe_total;
        }
        if (!camposNoActualizables.contains('fondo_ue__c')) {
            knowledge.fondo_ue__c = convocatoria.fondo_ue;
        }
        if (!camposNoActualizables.contains('Activo__c')) {
            knowledge.Activo__c = convocatoria.activo;
        }
        // Actualizar información de documentos, justificación, impacto de género, etc.
        if (convocatoria.data_json != null) {
            knowledge.NombreDocumentoCastellano__c = convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Nombre;
            knowledge.NombreDocumentoOtraLengua__c = convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Nombre;
            knowledge.URLEspBR__c = convocatoria.data_json.DatosBaseReguladora.URLEspBR;
            knowledge.URLengBR__c = convocatoria.data_json.DatosBaseReguladora.URLengBR;
            // Solicitud y justificación
            if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.InicioSolicitud != null) {
                knowledge.InicioSolicitud__c = convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.InicioSolicitud;
            }
            if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.FechaFinSolicitud != null) {
                knowledge.FechaFinSolicitud__c = Date.valueOf(convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.FechaFinSolicitud);
            }
            if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion.nombre != null) {
                knowledge.NombreJustificacion__c = convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion.nombre;
            }
            if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.FechaJustificacion != null) {
                knowledge.FechaJustificacion__c = Date.valueOf(convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.FechaJustificacion);
            }
            // Impacto de género
            knowledge.CodigoImpactoGenero__c = convocatoria.data_json.OtrosDatos.ImpactoGenero.codigo;
            knowledge.NombreImpactoGenero__c = convocatoria.data_json.OtrosDatos.ImpactoGenero.nombre;
            // **Iterar sobre los extractos**
            if (convocatoria.data_json.Extractos != null && !convocatoria.data_json.Extractos.isEmpty()) {
                for (Convocatoria.Extracto extracto : convocatoria.data_json.Extractos) {
                    knowledge.TituloExtractoCastellano__c = extracto.ExtractoCastellano.TituloExtracto;
                    knowledge.ExtractoCastellano__c = String.join(extracto.ExtractoCastellano.TextoExtractoCastellano.p, ' ');
                    knowledge.TituloExtractoOtraLengua__c = extracto.ExtractoOtraLengua.TituloExtracto;
                    knowledge.ExtractoOtraLengua__c = String.join(extracto.ExtractoOtraLengua.TextoExtractoOtraLengua.p, ' ');
                    if(extracto.FechaEnvio != null){
                        knowledge.Fecha_envio_Convocatoria__c = Date.valueOf(extracto.FechaEnvio);
                    }
                    if (extracto.Publicacion != null && extracto.Publicacion.IdExtractoDiarioOficial != null){
                        knowledge.Id_extracto_diario_oficial_Convocatoria__c = extracto.Publicacion.IdExtractoDiarioOficial;
                    }
                    if (extracto.Publicacion != null && extracto.Publicacion.EstadoPublicacion != null && extracto.Publicacion.EstadoPublicacion.Publicado != null) {
                        if(extracto.Publicacion.EstadoPublicacion.Publicado.FechaPublicacion != null){
                            knowledge.Fecha_publicacion_Convocatoria__c = Date.valueOf(extracto.Publicacion.EstadoPublicacion.Publicado.FechaPublicacion);
                        }
                        if(extracto.Publicacion.EstadoPublicacion.Publicado.URL != null) {
                            knowledge.URL_publicacion_Convocatoria__c = extracto.Publicacion.EstadoPublicacion.Publicado.URL;
                        }
                    }
                    
                }
            }
            // Otros documentos
            if (convocatoria.data_json.OtrosDocumentos != null && !convocatoria.data_json.OtrosDocumentos.isEmpty()) {
                knowledge.DescripcionOtro__c = convocatoria.data_json.OtrosDocumentos[0].DescripcionOtro;
                knowledge.NombreOtrosDocumentos__c = convocatoria.data_json.OtrosDocumentos[0].Nombre;
            }
        }
        // Actualizar la fecha de modificación
        String fecha_modificacion = convocatoria.fecha_modificacion;
        String fechaSinOffset = fecha_modificacion.substring(0, 19);
        String offSet = fecha_modificacion.substring(19, 22);
        Integer horasOffset = Integer.valueOf(offSet);
        fechaSinOffset = fechaSinOffset.replace('T', ' ');
        DateTime fechaModificacion = DateTime.valueOf(fechaSinOffset);
        fechaModificacion = fechaModificacion.addHours(horasOffset);
        knowledge.fecha_modificacion__c = fechaModificacion;
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