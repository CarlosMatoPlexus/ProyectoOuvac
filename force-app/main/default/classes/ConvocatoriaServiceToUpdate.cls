public class ConvocatoriaServiceToUpdate {
    public static void updateConvocatoria(List<String> detallesJson) {
        for (String jsonDetalle : detallesJson) {
            try {
                // Deserialize the JSON into the Convocatoria object
                Convocatoria convocatoria = (Convocatoria) JSON.deserialize(jsonDetalle, Convocatoria.class);
                if (convocatoria != null) {
                    String code_bdns = convocatoria.code_bdns;
                    // Query for existing knowledge articles in both languages (es and es_MX)
                    List<Knowledge__kav> knowledges = [
                        SELECT Id, Title, Descripcion__c, Importe_total__c, fondo_ue__c, Activo__c,
                               NombreDocumentoCastellano__c, FicheroDocumentoCastellano__c,
                               NombreDocumentoOtraLengua__c, FicheroDocumentoOtraLengua__c,
                               URLEspBR__c, URLengBR__c, InicioSolicitud__c, FechaFinSolicitud__c,
                               NombreJustificacion__c, FechaJustificacion__c, CodigoImpactoGenero__c,
                               NombreImpactoGenero__c, TituloExtractoCastellano__c, ExtractoCastellano__c,
                               TituloExtractoOtraLengua__c, ExtractoOtraLengua__c, DescripcionOtro__c,
                               NombreOtrosDocumentos__c, FicheroOtrosDocumentos__c, fecha_modificacion__c, Language
                        FROM Knowledge__kav
                        WHERE code_bdns__c = :code_bdns
                    ];
                    // Separate knowledge articles into es and es_MX for updates
                    Knowledge__kav knowCastellano;
                    Knowledge__kav knowOtraLengua;
                    for (Knowledge__kav knowledge : knowledges) {
                        if (knowledge.Language == 'es') {
                            knowCastellano = knowledge;
                        } else if (knowledge.Language == 'es_MX') {
                            knowOtraLengua = knowledge;
                        }
                    }
                    if (knowCastellano != null && knowOtraLengua != null) {
                        // Ensure both knowledge articles are in draft mode before updating
                        retractIfPublished(knowCastellano);
                        retractIfPublished(knowOtraLengua);
                        // Process the main Convocatoria data and update fields
                        String descripcion = convocatoria.descripcion;
                        Decimal importe_total = convocatoria.importe_total;
                        Boolean fondo_ue = convocatoria.fondo_ue;
                        Boolean activo = convocatoria.activo;
                        DateTime fechaModificacion = DateTime.parse(convocatoria.fecha_modificacion);
                        // Update the fields for both languages
                        updateKnowledgeFields(knowCastellano, convocatoria, 'es');
                        updateKnowledgeFields(knowOtraLengua, convocatoria, 'es_MX');
                        // Add articles back to lists for publishing
                        List<Knowledge__kav> knowledgeToUpdate = new List<Knowledge__kav>();
                        knowledgeToUpdate.add(knowCastellano);
                        knowledgeToUpdate.add(knowOtraLengua);
                        // Perform update
                        update knowledgeToUpdate;
                        // Republish the articles after the update
                        publishKnowledgeArticles(knowledgeToUpdate);
                    } else {
                        System.debug('No Knowledge found for code_bdns: ' + code_bdns);
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing convocatoria: ' + ex.getMessage());
            }
        }
    }
    // Helper method to retract articles if they are published
    private static void retractIfPublished(Knowledge__kav knowledge) {
        if (knowledge.PublishStatus == 'Online') {
           KbManagement.PublishingService.editOnlineArticle(knowledge.Id, false);
        }
    }
    // Helper method to update fields for each Knowledge article
    private static void updateKnowledgeFields(Knowledge__kav knowledge, Convocatoria convocatoria, String language) {
        knowledge.Descripcion__c = convocatoria.descripcion;
        knowledge.Importe_total__c = convocatoria.importe_total;
        knowledge.fondo_ue__c = convocatoria.fondo_ue;
        knowledge.Activo__c = convocatoria.activo;
        // Process Data JSON if available
        if (convocatoria.data_json != null) {
            knowledge.NombreDocumentoCastellano__c = convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Nombre;
            knowledge.NombreDocumentoOtraLengua__c = convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Nombre;
            knowledge.URLEspBR__c = convocatoria.data_json.DatosBaseReguladora.URLEspBR;
            knowledge.URLengBR__c = convocatoria.data_json.DatosBaseReguladora.URLengBR;
            // Update specific fields related to "Solicitud"
            if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.InicioSolicitud != null) {
                knowledge.InicioSolicitud__c = convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.InicioSolicitud;
            }
            if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.FechaFinSolicitud != null) {
                knowledge.FechaFinSolicitud__c = Date.valueOf(convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.FechaFinSolicitud);
            }
            // Update fields related to Justification and ImpactoGenero
            knowledge.NombreJustificacion__c = convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion.nombre;
            knowledge.FechaJustificacion__c = Date.valueOf(convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.FechaJustificacion);
            knowledge.CodigoImpactoGenero__c = convocatoria.data_json.OtrosDatos.ImpactoGenero.codigo;
            knowledge.NombreImpactoGenero__c = convocatoria.data_json.OtrosDatos.ImpactoGenero.nombre;
            // Update Extractos fields
            List<String> textoExtractoCastellano = convocatoria.data_json.Extractos.Extracto[0].ExtractoCastellano.TextoExtractoCastellano.p;
            knowledge.ExtractoCastellano__c = String.join(textoExtractoCastellano, ' ');
            List<String> textoExtractoOtraLengua = convocatoria.data_json.Extractos.Extracto[0].ExtractoOtraLengua.TextoExtractoOtraLengua.p;
            knowledge.ExtractoOtraLengua__c = String.join(textoExtractoOtraLengua, ' ');
            knowledge.TituloExtractoCastellano__c = convocatoria.data_json.Extractos.Extracto[0].ExtractoCastellano.TituloExtracto;
            knowledge.TituloExtractoOtraLengua__c = convocatoria.data_json.Extractos.Extracto[0].ExtractoOtraLengua.TituloExtracto;
            // Update OtrosDocumentos fields
            knowledge.DescripcionOtro__c = convocatoria.data_json.OtrosDocumentos[0].DescripcionOtro;
            knowledge.NombreOtrosDocumentos__c = convocatoria.data_json.OtrosDocumentos[0].Nombre;
        }
        // Finally, update the modification date
        knowledge.fecha_modificacion__c = DateTime.parse(convocatoria.fecha_modificacion);
    }
    // Helper method to publish knowledge articles
    private static void publishKnowledgeArticles(List<Knowledge__kav> knowledgeArticles) {
        for (Knowledge__kav knowledge : knowledgeArticles) {
            KbManagement.PublishingService.publishArticle(knowledge.Id, true);
        }
    }
 }