public class ConvocatoriaService {
    public static void procesarConvocatoria(List<String> detallesJson) {
        for (String jsonDetalle : detallesJson){
            try {
                //Declaracion de variables
                Knowledge__kav knowCastellano = new Knowledge__kav();
                Knowledge__kav knowOtraLengua = new Knowledge__kav();
                String code_bdns;
                String descripcion;
                Decimal importe_total;
                Boolean fondo_ue;
                Boolean activo;
                String documentoCastellanoNombre;
                String documentoCastellanoFichero;
                String documentoOtraLenguaNombre;
                String documentoOtraLenguaFichero;
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
                String otroDocFichero;
                String fecha_modificacion;
                
                // Deserializa el JSON en un objeto de Convocatoria
                Convocatoria convocatoria = (Convocatoria) JSON.deserialize(jsonDetalle, Convocatoria.class);
                System.debug('code_bdns: '+ convocatoria.code_bdns);
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
                        if(convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Fichero != null){
                            Integer maxSize = 131071;
                            if(convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Fichero.length() > maxSize){
                                convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Fichero = convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Fichero.substring(0, maxSize);
                            }
                            documentoCastellanoFichero = convocatoria.data_json.DatosGeneralesCov.DocumentoCastellano.Fichero;
                        }
                        
                        // Procesar DatosGeneralesCov.DocumentoOtraLengua
                        if(convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua != null){
                            if(convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Nombre != null){
                                documentoOtraLenguaNombre = convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Nombre;
                            }
                            if(convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Fichero != null){
                                Integer maxSize = 131071;
                                if(convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Fichero.length() > maxSize){
                                    convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Fichero = convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Fichero.substring(0, maxSize);
                                }
                                documentoOtraLenguaFichero = convocatoria.data_json.DatosGeneralesCov.DocumentoOtraLengua.Fichero;
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
                            //System.debug('Procesando OtrosDatos...');
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
                        if (convocatoria.data_json.Extractos != null && convocatoria.data_json.Extractos.Extracto != null) {
                            for (Convocatoria.Extracto extracto : convocatoria.data_json.Extractos.Extracto) {
                                if (extracto.ExtractoCastellano != null) {
                                    if(extracto.ExtractoCastellano.TituloExtracto != null){
                                        extractoCastellanoTituloExtracto = extracto.ExtractoCastellano.TituloExtracto;
                                    }
                                    
                                    if (extracto.ExtractoCastellano.TextoExtractoCastellano != null) {
                                        textoExtractoCastellano = extracto.ExtractoCastellano.TextoExtractoCastellano.p + '  \n ';
                                    }
                                    if (extracto.ExtractoCastellano.PieFirmaExtracto != null) {
                                        textoExtractoCastellano += extracto.ExtractoCastellano.PieFirmaExtracto.LugarFirma + '  \n ' + extracto.ExtractoCastellano.PieFirmaExtracto.FechaFirma + '  \n ' + extracto.ExtractoCastellano.PieFirmaExtracto.Firmante;
                                        //knowCastellano.ExtractoCastellano__c += extracto.ExtractoCastellano.PieFirmaExtracto.LugarFirma + '  \n ' + extracto.ExtractoCastellano.PieFirmaExtracto.FechaFirma + '  \n ' + extracto.ExtractoCastellano.PieFirmaExtracto.Firmante;
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
                                        //knowOtraLengua.ExtractoOtraLengua__c += extracto.ExtractoOtraLengua.PieFirmaExtracto.LugarFirma + '  \n ' + extracto.ExtractoOtraLengua.PieFirmaExtracto.FechaFirma + '  \n ' + extracto.ExtractoOtraLengua.PieFirmaExtracto.Firmante;
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
                                if(otroDoc.Fichero != null){
                                    Integer maxSize = 131071;
                                    if(otroDoc.Fichero.length() > maxSize){
                                        otroDoc.Fichero = otroDoc.Fichero.substring(0, maxSize);
                                    }
                                    otroDocFichero = otroDoc.Fichero;
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
                    knowCastellano.FicheroDocumentoCastellano__c = documentoCastellanoFichero;
                    knowOtraLengua.NombreDocumentoOtraLengua__c = documentoOtraLenguaNombre;
                    knowOtraLengua.FicheroDocumentoOtraLengua__c = documentoOtraLenguaFichero;
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
                    if(otroDocFichero != null){
                        knowCastellano.FicheroOtrosDocumentos__c = otroDocFichero;
                        knowOtraLengua.FicheroOtrosDocumentos__c = otroDocFichero;
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
                    
                    knowCastellano.ValidationStatus = 'Validated';
                    //knowCastellano.PublishStatus = 'Online';
                    knowCastellano.Entidades__c = 'Deputación';
                    knowCastellano.Ambitos__c = 'Contratación';
                    knowCastellano.UrlName = knowCastellano.code_bdns__c;
                    knowCastellano.Language = 'es';
                    if(fechaModificacion != null){
                        knowCastellano.fecha_modificacion__c = fechaModificacion;
                    }
                    
                    knowOtraLengua.RecordTypeId = convocatoriaRecordTypeID;
                    
                    knowOtraLengua.ValidationStatus = 'Validated';
                    knowOtraLengua.Entidades__c = 'Deputación';
                    knowOtraLengua.Ambitos__c = 'Contratación';
                    knowOtraLengua.UrlName = knowCastellano.code_bdns__c;
                    knowOtraLengua.Language = 'es_MX';
                    knowOtraLengua.fecha_modificacion__c = fechaModificacion;
                    
                    List<Knowledge__kav> lstKnowledge = new List<Knowledge__kav>();
                    lstKnowledge.add(knowCastellano);
                    lstKnowledge.add(knowOtraLengua);
                    
                    insert lstKnowledge;
                    
                    List<KnowledgeArticleVersion> lstKnowPublish = new List<KnowledgeArticleVersion>();
                    lstKnowPublish = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft'];
                    for(KnowledgeArticleVersion know : lstKnowPublish){
                        KbManagement.PublishingService.publishArticle(know.KnowledgeArticleId, true);
                    }
                    system.debug('lstKnowPublish: '+lstKnowPublish);
                }
            } catch (Exception ex) {
                System.debug('Ocurrió un error al procesar la convocatoria: ' + ex.getMessage());
            }
        }
    }
}