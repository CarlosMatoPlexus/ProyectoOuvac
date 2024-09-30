public class ConvocatoriaService {
    public static void procesarConvocatoria(List<String> detallesJson) {
        for (String jsonDetalle : detallesJson){
            try {
                //Declaracion de variables
                Knowledge__kav knowCastellano = new Knowledge__kav();
                Knowledge__kav knowOtraLengua = new Knowledge__kav();
                List<Knowledge__kav> lstKnowledge = new List<Knowledge__kav>();
                String code_bdns;
                String descripcion;
                Decimal importe_total;
                Boolean fondo_ue;
                Boolean activo;
                String documentoCastellanoNombre;
                String documentoOtraLenguaNombre;
                String uRLEspBR;
                String uRLengBR;
                String solicitudInicioSolicitud;
                Date solicitudFechaFinSolicitud;
                String justificacionNombre;
                Date fechaJustificacion;
                String impactoGeneroCodigo;
                String impactoGeneroNombre;
                String extractoCastellanoTituloExtracto;
                String textoExtractoCastellano;
                String extractoOtraLenguaTituloExtracto;
                String textoExtractoOtraLengua;
                String otroDocDescripcionOtro;
                String otroDocNombre;
                String fecha_modificacion;
                Date publicacionFechaPublicacion;
                String publicacionIdExtractoDiarioOficial;
                String publicacionUrlPublicacion;
                Date fechaEnvio;
                
                
                // Deserializa el JSON en un objeto de Convocatoria
                Convocatoria convocatoria = (Convocatoria) JSON.deserialize(jsonDetalle, Convocatoria.class);
                // Procesar los datos principales de la convocatoria
                if (convocatoria != null) {
                    code_bdns = convocatoria.code_bdns;
                    descripcion = convocatoria.descripcion;
                    importe_total = convocatoria.importe_total;
                    fondo_ue = convocatoria.fondo_ue;
                    activo = convocatoria.activo;
                    fecha_modificacion = convocatoria.fecha_modificacion;
                    if (convocatoria.data_json != null) {
                        // Procesar DatosGeneralesCov
                        // Procesar DatosGeneralesCov.DocumentoCastellano
                        documentoCastellanoNombre = convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Nombre;
                        // Procesar DatosGeneralesCov.DocumentoOtraLengua
                        if(convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua != null){
                            if(convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Nombre != null){
                                documentoOtraLenguaNombre = convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Nombre;
                            }
                        }
                        // Procesar DatosBaseReguladora
                        uRLEspBR = convocatoria.data_json.DatosBaseReguladora.URLEspBR;
                        uRLengBR = convocatoria.data_json.DatosBaseReguladora.URLengBR;
                        // Procesar Datos Solicitud Justificacion Financiacion
                        if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.InicioSolicitud != null){
                            solicitudInicioSolicitud = convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.InicioSolicitud;
                        }
                        if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.FechaFinSolicitud != null){
                            solicitudFechaFinSolicitud = Date.valueOf(convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Solicitud.FechaFinSolicitud);
                        }
                        if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion.nombre != null){
                            justificacionNombre = convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.Justificacion.nombre;
                        }
                        
                        if (convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.FechaJustificacion != null){
                            fechaJustificacion = Date.valueOf(convocatoria.data_json.DatosSolicitudJustificacionFinanciacion.FechaJustificacion);
                        }
                        // Procesar OtrosDatos
                        if (convocatoria.data_json.OtrosDatos != null) {
                            // ImpactoGenero
                            if (convocatoria.data_json.OtrosDatos.ImpactoGenero != null) {
                                if(convocatoria.data_json.OtrosDatos.ImpactoGenero.codigo != null){
                                    impactoGeneroCodigo = convocatoria.data_json.OtrosDatos.ImpactoGenero.codigo;
                                }
                                if(convocatoria.data_json.OtrosDatos.ImpactoGenero.nombre != null){
                                    impactoGeneroNombre = convocatoria.data_json.OtrosDatos.ImpactoGenero.nombre;
                                }
                            }
                        } else {
                            System.debug('OtrosDatos es nulo');
                        }
                        // Procesar Extractos
                        if (convocatoria.data_json.Extractos != null && convocatoria.data_json.Extractos != null) {
                            for (Convocatoria.Extracto extracto : convocatoria.data_json.Extractos) {
                                if (extracto.ExtractoCastellano != null) {
                                    if(extracto.ExtractoCastellano.TituloExtracto != null){
                                        extractoCastellanoTituloExtracto = extracto.ExtractoCastellano.TituloExtracto;
                                    }
                                    if (extracto.ExtractoCastellano.TextoExtractoCastellano != null) {
                                        textoExtractoCastellano = extracto.ExtractoCastellano.TextoExtractoCastellano.p + '  \n ';
                                    }
                                    if (extracto.ExtractoCastellano.PieFirmaExtracto != null) {
                                        textoExtractoCastellano += extracto.ExtractoCastellano.PieFirmaExtracto.LugarFirma + '  \n ' + extracto.ExtractoCastellano.PieFirmaExtracto.FechaFirma + '  \n ' + extracto.ExtractoCastellano.PieFirmaExtracto.Firmante;
                                    }
                                }
                                if (extracto.ExtractoOtraLengua != null) {
                                    if(extracto.ExtractoOtraLengua.TituloExtracto != null){
                                        extractoOtraLenguaTituloExtracto = extracto.ExtractoOtraLengua.TituloExtracto;
                                    }
                                    if (extracto.ExtractoOtraLengua.TextoExtractoOtraLengua != null) {
                                        textoExtractoOtraLengua = extracto.ExtractoOtraLengua.TextoExtractoOtraLengua.p + '  \n ';
                                    }
                                    if (extracto.ExtractoOtraLengua.PieFirmaExtracto != null) {
                                        textoExtractoOtraLengua += extracto.ExtractoOtraLengua.PieFirmaExtracto.LugarFirma + '  \n ' + extracto.ExtractoOtraLengua.PieFirmaExtracto.FechaFirma + '  \n ' + extracto.ExtractoOtraLengua.PieFirmaExtracto.Firmante;
                                    }
                                }
                                
                                if(extracto.FechaEnvio !=null ){
                                    fechaEnvio = Date.valueOf(extracto.FechaEnvio);
                                }
                                if (extracto.Publicacion != null && extracto.Publicacion.IdExtractoDiarioOficial != null){
                                    publicacionIdExtractoDiarioOficial = extracto.Publicacion.IdExtractoDiarioOficial;
                                }
                                if (extracto.Publicacion != null && extracto.Publicacion.EstadoPublicacion != null && extracto.Publicacion.EstadoPublicacion.Publicado != null) {
                                    if(extracto.Publicacion.EstadoPublicacion.Publicado.FechaPublicacion != null){
                                        publicacionFechaPublicacion = Date.valueOf(extracto.Publicacion.EstadoPublicacion.Publicado.FechaPublicacion);
                                    }
                                    if(extracto.Publicacion.EstadoPublicacion.Publicado.URL != null) {
                                        publicacionUrlPublicacion = extracto.Publicacion.EstadoPublicacion.Publicado.URL;
                                    }
                                }
                            }
                        } else {
                            System.debug('Extractos es nulo o está vacío');
                        }
                        // Procesar OtrosDocumentos
                        if (convocatoria.data_json != null && convocatoria.data_json.OtrosDocumentos != null) {
                            for (Convocatoria.OtrosDocumentos otroDoc : convocatoria.data_json.OtrosDocumentos) {
                                if(otroDoc.DescripcionOtro != null){
                                    otroDocDescripcionOtro = otroDoc.DescripcionOtro;
                                }
                                if (otroDoc.Nombre != null){
                                    otroDocNombre = otroDoc.Nombre;
                                }
                            }
                        } else {
                            System.debug('OtrosDocumentos es nulo');
                        }
                    }
                    String fechaSinOffset = fecha_modificacion.substring(0, 19);
                    String offSet = fecha_modificacion.substring(19, 22);
                    Integer horasOffset = Integer.valueOf(offSet);
                    fechaSinOffset = fechaSinOffset.replace('T', ' ');
                    DateTime fechaModificacion = DateTime.valueOf(fechaSinOffset);
                    fechaModificacion = fechaModificacion.addHours(horasOffset);
                    
                    knowCastellano.code_bdns__c = code_bdns;
                    knowOtraLengua.code_bdns__c = code_bdns;
                    knowCastellano.Descripcion__c = descripcion;
                    knowOtraLengua.Descripcion__c = descripcion;
                    knowCastellano.Importe_total__c = importe_total;
                    knowOtraLengua.Importe_total__c = importe_total;
                    knowCastellano.fondo_ue__c = fondo_ue;
                    knowOtraLengua.fondo_ue__c = fondo_ue;
                    knowCastellano.Activo__c = activo;
                    knowOtraLengua.Activo__c = activo;
                    knowCastellano.NombreDocumentoCastellano__c = documentoCastellanoNombre;
                    knowOtraLengua.NombreDocumentoOtraLengua__c = documentoOtraLenguaNombre;
                    knowCastellano.URLEspBR__c = uRLEspBR;
                    knowOtraLengua.URLEspBR__c = uRLEspBR;
                    knowCastellano.URLengBR__c = uRLengBR;
                    knowOtraLengua.URLengBR__c = uRLengBR;
                    if(solicitudInicioSolicitud != null ){
                        knowCastellano.InicioSolicitud__c = solicitudInicioSolicitud;
                        knowOtraLengua.InicioSolicitud__c = solicitudInicioSolicitud;
                    }
                    if (solicitudFechaFinSolicitud != null){
                        knowCastellano.FechaFinSolicitud__c = solicitudFechaFinSolicitud;
                        knowOtraLengua.FechaFinSolicitud__c = solicitudFechaFinSolicitud;
                    }
                    if(justificacionNombre != null){
                        knowCastellano.NombreJustificacion__c = justificacionNombre;
                        knowOtraLengua.NombreJustificacion__c = justificacionNombre;
                    }
                    
                    if(fechaJustificacion != null){
                        knowCastellano.FechaJustificacion__c = fechaJustificacion;
                        knowOtraLengua.FechaJustificacion__c = fechaJustificacion;
                    }
                    if(impactoGeneroCodigo != null) {
                        knowCastellano.CodigoImpactoGenero__c = impactoGeneroCodigo;
                        knowOtraLengua.CodigoImpactoGenero__c = impactoGeneroCodigo;
                    }
                    if (impactoGeneroNombre != null){
                        knowCastellano.NombreImpactoGenero__c = impactoGeneroNombre;
                        knowOtraLengua.NombreImpactoGenero__c = impactoGeneroNombre;
                    }
                    if (extractoCastellanoTituloExtracto != null){
                        knowCastellano.TituloExtractoCastellano__c = extractoCastellanoTituloExtracto;
                    }
                    if (textoExtractoCastellano != null){
                        knowCastellano.ExtractoCastellano__c = textoExtractoCastellano;
                    }
                    if (extractoOtraLenguaTituloExtracto != null){
                        knowOtraLengua.TituloExtractoOtraLengua__c = extractoOtraLenguaTituloExtracto;
                    }
                    if(textoExtractoOtraLengua != null){
                        knowOtraLengua.ExtractoOtraLengua__c = textoExtractoOtraLengua;
                    }
                    if(otroDocDescripcionOtro != null){
                        knowCastellano.DescripcionOtro__c = otroDocDescripcionOtro;
                        knowOtraLengua.DescripcionOtro__c = otroDocDescripcionOtro;
                    }
                    if(otroDocNombre != null){
                        knowCastellano.NombreOtrosDocumentos__c = otroDocNombre;
                        knowOtraLengua.NombreOtrosDocumentos__c = otroDocNombre;
                    }
                    String convocatoriaRecordTypeID = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Convocatoria').getRecordTypeId();
                    knowCastellano.RecordTypeId = convocatoriaRecordTypeID;
                    if(extractoCastellanoTituloExtracto != null){
                        Integer maxSize = 255;
                        if(extractoCastellanoTituloExtracto.length() > maxSize ){
                            extractoCastellanoTituloExtracto = extractoCastellanoTituloExtracto.substring(0, maxSize);
                        }
                        knowCastellano.Title = extractoCastellanoTituloExtracto ;
                    }else{
                        Integer maxSize = 255;
                        if(descripcion.length() > maxSize ){
                            descripcion = descripcion.substring(0, maxSize);
                        }
                        knowCastellano.Title = descripcion;
                    }
                    if(extractoOtraLenguaTituloExtracto != null){
                        Integer maxSize = 255;
                        if(extractoOtraLenguaTituloExtracto.length() > maxSize ){
                            extractoOtraLenguaTituloExtracto = extractoOtraLenguaTituloExtracto.substring(0, maxSize);
                        }
                        knowOtraLengua.Title = extractoOtraLenguaTituloExtracto;
                    }else {
                        Integer maxSize = 255;
                        if(descripcion.length() > maxSize ){
                            descripcion = descripcion.substring(0, maxSize);
                        }
                        knowOtraLengua.Title = descripcion;
                    }

                    if(fechaEnvio != null){
                        knowCastellano.Fecha_envio_Convocatoria__c = fechaEnvio;
                        knowOtraLengua.Fecha_envio_Convocatoria__c = fechaEnvio;
                    }
                    if(publicacionUrlPublicacion != null){
                        knowCastellano.URL_publicacion_Convocatoria__c = publicacionUrlPublicacion;
                        knowOtraLengua.URL_publicacion_Convocatoria__c = publicacionUrlPublicacion;
                    }
                    if(publicacionIdExtractoDiarioOficial != null){
                        knowCastellano.Id_extracto_diario_oficial_Convocatoria__c = publicacionIdExtractoDiarioOficial;
                        knowOtraLengua.Id_extracto_diario_oficial_Convocatoria__c= publicacionIdExtractoDiarioOficial;
                    }
                    if(publicacionFechaPublicacion != null){
                        knowCastellano.Fecha_publicacion_Convocatoria__c = publicacionFechaPublicacion;
                        knowOtraLengua.Fecha_publicacion_Convocatoria__c = publicacionFechaPublicacion;
                    }
                    knowCastellano.ValidationStatus = 'Validated';
                    knowCastellano.Entidades__c = 'Deputación';
                    knowCastellano.Ambitos__c = 'Transparencia';
                    knowCastellano.UrlName = knowCastellano.code_bdns__c;
                    knowCastellano.Language = 'es';
                    if(fechaModificacion != null){
                        knowCastellano.fecha_modificacion__c = fechaModificacion;
                    }
                    knowOtraLengua.RecordTypeId = convocatoriaRecordTypeID;
                    knowOtraLengua.ValidationStatus = 'Validated';
                    knowOtraLengua.Entidades__c = 'Deputación';
                    knowOtraLengua.Ambitos__c = 'Transparencia';
                    knowOtraLengua.UrlName = knowCastellano.code_bdns__c;
                    knowOtraLengua.Language = 'es_MX';
                    if(fechaModificacion != null){
                        knowOtraLengua.fecha_modificacion__c = fechaModificacion;
                    }
                    if(code_bdns != null){
                        knowCastellano.URL_documentacion_convocatoria__c = 'https://www.pap.hacienda.gob.es/bdnstrans/GE/es/convocatorias/'+code_bdns;
                        knowOtraLengua.URL_documentacion_convocatoria__c = 'https://www.pap.hacienda.gob.es/bdnstrans/GE/es/convocatorias/'+code_bdns;
                    }
                    lstKnowledge.add(knowCastellano);
                    lstKnowledge.add(knowOtraLengua);
                    
                    insert lstKnowledge;
                    
                    List<KnowledgeArticleVersion> lstKnowPublish = new List<KnowledgeArticleVersion>();
                    lstKnowPublish = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft'];
                    for(KnowledgeArticleVersion know : lstKnowPublish){
                        KbManagement.PublishingService.publishArticle(know.KnowledgeArticleId, true);
                    }
                }
            } catch (Exception ex) {
                System.debug('Ocurrió un error al procesar la convocatoria: ' + ex.getMessage());
            }
        }
    }
}