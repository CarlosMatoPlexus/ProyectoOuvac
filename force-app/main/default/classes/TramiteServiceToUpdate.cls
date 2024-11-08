public class TramiteServiceToUpdate {
    public static void updateTramite(List<String> detallesJson){
        // Listas para almacenar los objetos de Knowledge a actualizar
        List<Knowledge__kav> knowledgeToUpdate = new List<Knowledge__kav>();
        List<Knowledge__kav> knowledgeToPublish = new List<Knowledge__kav>();
        for (String jsonDetalle : detallesJson){
            try {
                Tramite tramite = (Tramite) JSON.deserialize(jsonDetalle, Tramite.class);
                if(tramite != null){
                    // Query para obtener los registros de Knowledge en ambos idiomas (es y es_MX)
                    List<Knowledge__kav> knowledges = [
                        SELECT Id, Language, PublishStatus, KnowledgeArticleId, Tramite_id__c, Title,
                        Descripcion__c, Activo__c, fecha_modificacion__c, Tramite_codigo_espanol__c, Tramite_titulo_espanol__c, Tramite_descripcion_espanol__c, Tramite_finalidad_espanol__c,
                        Tramite_requisitos_espanol__c, Tramite_plazo_presentacion_espanol__c, Tramite_presentacion_espanol__c, 
                        Tramite_presentar_por_espanol__c, Tramite_organo_gestor_espanol__c, Tramite_plazo_resolucion_espanol__c, 
                        Tramite_efecto_silencio_admin_espanol__c, Tramite_recursos_espanol__c, Tramite_normativa_basica_espanol__c,
                        Tramite_coleccion_normativas_espanol__c, Tramite_informacion_adicional_espanol__c,
                        Tramite_nivel_identificacion_sol_esp__c, Tramite_url_inicio_tramitacion_espanol__c, 
                        Tramite_url_descarga_instancia_espanol__c, Tramite_url_detalle_tramite_espanol__c,
                        Tramite_codigo_galego__c, Tramite_titulo_galego__c, Tramite_descripcion_galego__c, Tramite_finalidad_galego__c, Tramite_requisitos_galego__c,
                        Tramite_plazo_presentacion_galego__c, Tramite_presentacion_galego__c, Tramite_presentar_por_galego__c, Tramite_organo_gestor_galego__c,
                        Tramite_plazo_resolucion_galego__c, Tramite_efecto_silencio_admin_galego__c, Tramite_recursos_galego__c, Tramite_normativa_basica_galego__c,
                        Tramite_coleccion_normativas_galego__c, Tramite_informacion_adicional_galego__c, Tramite_nivel_identificacion_sol_gal__c, 
                        Tramite_url_inicio_tramitacion_galego__c, Tramite_url_descarga_instancia_galego__c, Tramite_url_detalle_tramite_galego__c
                        FROM Knowledge__kav
                        WHERE Tramite_id__c =: String.valueOf(tramite.id)
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
                        // Si ambos artículos están en borrador, proceder con la actualización
                        if (knowCastellano.PublishStatus == 'Draft' && knowOtraLengua.PublishStatus == 'Draft') {
                            updateKnowledgeFields(knowCastellano, tramite);
                            updateKnowledgeFields(knowOtraLengua, tramite);
                            // Añadir los artículos a las listas para actualización y publicación
                            knowledgeToUpdate.add(knowCastellano);
                            knowledgeToUpdate.add(knowOtraLengua);
                        } else {
                            System.debug('No se pudo retractar a borrador uno de los artículos.');
                        }
                    } else {
                        System.debug('No se encontró Knowledge para el id de trámite: ' + tramite.id);
                    }
                }
            } catch (Exception ex) {
                System.debug('Error al procesar el trámite: ' + ex.getMessage());
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
    
    // Método auxiliar para actualizar los campos de cada artículo de Knowledge
    private static void updateKnowledgeFields(Knowledge__kav knowledge, Tramite tramite) {
        
        String fecha_modificacion;
        //Variables data_es_json
        String data_es_json_coleccionNormativas;
        String data_es_json_urlInicioTramitacion;
        String data_es_json_urlDescargaInstancia;
        
        //Variables data_gl_json
        String data_gl_json_coleccionNormativas;
        String data_gl_json_urlInicioTramitacion;
        String data_gl_json_urlDescargaInstancia;
        
        // Procesar los datos principales del tramite
        if(tramite != null){
            knowledge.Title  = tramite.titulo;
            knowledge.Descripcion__c  = tramite.descripcion;
            Knowledge.Activo__c = tramite.activo;
            fecha_modificacion = tramite.fecha_modificacion;

            if(fecha_modificacion != null){
                String fechaModificacionSinOffset = fecha_modificacion.substring(0, 19);
                String offSetModificacion = fecha_modificacion.substring(19, 22);
                Integer horasOffsetModificacion = Integer.valueOf(offSetModificacion);
                fechaModificacionSinOffset = fechaModificacionSinOffset.replace('T', ' ');
                DateTime fechaModificacion = DateTime.valueOf(fechaModificacionSinOffset);
                fechaModificacion = fechaModificacion.addHours(horasOffsetModificacion);
                knowledge.fecha_modificacion__c = fechaModificacion;
                System.debug('Fecha modificacion: '+ fechaModificacion);
            }
            // Procesar data_es_json del Tramite
            if(knowledge.Language == 'es'){
                if(tramite.data_es_json != null){
                    if(tramite.data_es_json.codigo != null){
                        knowledge.Tramite_codigo_espanol__c = tramite.data_es_json.codigo;
                    }
                    if(tramite.data_es_json.titulo != null){
                        knowledge.Tramite_titulo_espanol__c = tramite.data_es_json.titulo;
                    }
                    if(tramite.data_es_json.descripcion != null){
                        knowledge.Tramite_descripcion_espanol__c = tramite.data_es_json.descripcion;
                    }
                    if(tramite.data_es_json.finalidad != null){
                        knowledge.Tramite_finalidad_espanol__c = tramite.data_es_json.finalidad;
                    }
                    if(tramite.data_es_json.requisitos != null){
                        knowledge.Tramite_requisitos_espanol__c = tramite.data_es_json.requisitos;
                    }
                    if(tramite.data_es_json.plazoPresentacion != null){
                        knowledge.Tramite_plazo_presentacion_espanol__c = tramite.data_es_json.plazoPresentacion;
                    }
                    if(tramite.data_es_json.presentacion != null){
                        knowledge.Tramite_presentacion_espanol__c = tramite.data_es_json.presentacion;
                    }
                    if(tramite.data_es_json.presentarPor != null){
                        knowledge.Tramite_presentar_por_espanol__c = tramite.data_es_json.presentarPor;
                    }
                    if(tramite.data_es_json.organoGestor != null){
                        knowledge.Tramite_organo_gestor_espanol__c = tramite.data_es_json.organoGestor;
                    }
                    if(tramite.data_es_json.plazoResolucion != null){
                        knowledge.Tramite_plazo_resolucion_espanol__c = tramite.data_es_json.plazoResolucion;
                    }
                    if(tramite.data_es_json.efectoSilencioAdministrativo != null){
                        knowledge.Tramite_efecto_silencio_admin_espanol__c = tramite.data_es_json.efectoSilencioAdministrativo;
                    }
                    if(tramite.data_es_json.recursos != null){
                        knowledge.Tramite_recursos_espanol__c = tramite.data_es_json.recursos;
                    }
                    if(tramite.data_es_json.normativaBasica != null){
                        knowledge.Tramite_normativa_basica_espanol__c = tramite.data_es_json.normativaBasica;
                    }
                    if(tramite.data_es_json.coleccionNormativas != null){
                        data_es_json_coleccionNormativas = '';
                        for(Tramite.cls_coleccionNormativas coleccionNormativas : tramite.data_es_json.coleccionNormativas){
                            if(coleccionNormativas.titulo != null){
                                data_es_json_coleccionNormativas += 'Titulo: '+' '+ coleccionNormativas.titulo + '  \n ';
                            }
                            if(coleccionNormativas.url != null){
                                data_es_json_coleccionNormativas += 'Url: ' +' '+ coleccionNormativas.url;
                                data_es_json_coleccionNormativas += '  \n ';
                            }
                        }
                    }
                    if(data_es_json_coleccionNormativas!= null){
                        knowledge.Tramite_coleccion_normativas_espanol__c = data_es_json_coleccionNormativas;
                    }
                    if(tramite.data_es_json.informacionAdicional != null){
                        knowledge.Tramite_informacion_adicional_espanol__c = tramite.data_es_json.informacionAdicional;
                    }
                    if(tramite.data_es_json.nivelIdentificacionSolicitante != null){
                        knowledge.Tramite_nivel_identificacion_sol_esp__c = tramite.data_es_json.nivelIdentificacionSolicitante;
                    }
                    if(tramite.data_es_json.urlInicioTramitacion != null){
                        knowledge.Tramite_url_inicio_tramitacion_espanol__c = tramite.data_es_json.urlInicioTramitacion;
                    }
                    if(tramite.data_es_json.urlInicioTramitacion != null){
                        data_es_json_urlInicioTramitacion = tramite.data_es_json.urlInicioTramitacion;
                        if(tramite.data_es_json.urlDescargaInstancia != null){
                            data_es_json_urlDescargaInstancia = data_es_json_urlInicioTramitacion+tramite.data_es_json.urlDescargaInstancia;
                        }
                    }
                    if(data_es_json_urlDescargaInstancia != null){
                        knowledge.Tramite_url_descarga_instancia_espanol__c = data_es_json_urlDescargaInstancia;
                    }
                    if(tramite.data_es_json.urlDetalleTramite != null){
                        knowledge.Tramite_url_detalle_tramite_espanol__c = tramite.data_es_json.urlDetalleTramite;
                    }
                }
            } else if(knowledge.Language == 'es_MX'){
                if(tramite.data_gl_json != null){
                    if(tramite.data_gl_json.codigo != null){
                        knowledge.Tramite_codigo_galego__c = tramite.data_gl_json.codigo;
                    }
                    if(tramite.data_gl_json.titulo != null){
                        knowledge.Tramite_titulo_galego__c = tramite.data_gl_json.titulo;
                    }
                    if(tramite.data_gl_json.descripcion != null){
                        knowledge.Tramite_descripcion_galego__c = tramite.data_gl_json.descripcion;
                    }
                    if(tramite.data_gl_json.finalidad != null){
                        knowledge.Tramite_finalidad_galego__c = tramite.data_gl_json.finalidad;
                    }
                    if(tramite.data_gl_json.requisitos != null){
                        knowledge.Tramite_requisitos_galego__c = tramite.data_gl_json.requisitos;
                    }
                    if(tramite.data_gl_json.plazoPresentacion != null){
                        knowledge.Tramite_plazo_presentacion_galego__c = tramite.data_gl_json.plazoPresentacion;
                    }
                    if(tramite.data_gl_json.presentacion != null){
                        knowledge.Tramite_presentacion_galego__c = tramite.data_gl_json.presentacion;
                    }
                    if(tramite.data_gl_json.presentarPor != null){
                        knowledge.Tramite_presentar_por_galego__c = tramite.data_gl_json.presentarPor;
                    }
                    if(tramite.data_gl_json.organoGestor != null){
                        knowledge.Tramite_organo_gestor_galego__c = tramite.data_gl_json.organoGestor;
                    }
                    if(tramite.data_gl_json.plazoResolucion != null){
                        knowledge.Tramite_plazo_resolucion_galego__c = tramite.data_gl_json.plazoResolucion;
                    }
                    if(tramite.data_gl_json.efectoSilencioAdministrativo != null){
                        knowledge.Tramite_efecto_silencio_admin_galego__c = tramite.data_gl_json.efectoSilencioAdministrativo;
                    }
                    if(tramite.data_gl_json.recursos != null){
                        knowledge.Tramite_recursos_galego__c = tramite.data_gl_json.recursos;
                    }
                    if(tramite.data_gl_json.normativaBasica != null){
                        knowledge.Tramite_normativa_basica_galego__c = tramite.data_gl_json.normativaBasica;
                    }
                    if(tramite.data_gl_json.coleccionNormativas != null){
                        data_gl_json_coleccionNormativas = '';
                        for(Tramite.cls_coleccionNormativas coleccionNormativas : tramite.data_gl_json.coleccionNormativas){
                            if(coleccionNormativas.titulo != null){
                                data_gl_json_coleccionNormativas += 'Titulo: '+' '+ coleccionNormativas.titulo + '  \n ';
                            }
                            if(coleccionNormativas.url != null){
                                data_gl_json_coleccionNormativas += 'Url: ' +' '+ coleccionNormativas.url;
                                data_gl_json_coleccionNormativas += '  \n ';
                            }
                        }
                    }
                    if(data_gl_json_coleccionNormativas!= null){
                        knowledge.Tramite_coleccion_normativas_galego__c = data_gl_json_coleccionNormativas;
                    }
                    if(tramite.data_gl_json.informacionAdicional != null){
                        knowledge.Tramite_informacion_adicional_galego__c = tramite.data_gl_json.informacionAdicional;
                    }
                    if(tramite.data_gl_json.nivelIdentificacionSolicitante != null){
                        knowledge.Tramite_nivel_identificacion_sol_esp__c = tramite.data_gl_json.nivelIdentificacionSolicitante;
                    }
                    if(tramite.data_gl_json.urlInicioTramitacion != null){
                        knowledge.Tramite_url_inicio_tramitacion_galego__c = tramite.data_gl_json.urlInicioTramitacion;
                    }
                    if(tramite.data_gl_json.urlInicioTramitacion != null){
                        data_gl_json_urlInicioTramitacion = tramite.data_gl_json.urlInicioTramitacion;
                        if(tramite.data_gl_json.urlDescargaInstancia != null){
                            data_gl_json_urlDescargaInstancia = data_gl_json_urlInicioTramitacion+tramite.data_gl_json.urlDescargaInstancia;
                        }
                    }
                    if(data_gl_json_urlDescargaInstancia != null){
                        knowledge.Tramite_url_descarga_instancia_galego__c = data_gl_json_urlDescargaInstancia;
                    }
                    if(tramite.data_gl_json.urlDetalleTramite != null){
                        knowledge.Tramite_url_detalle_tramite_galego__c = tramite.data_gl_json.urlDetalleTramite;
                    }
                }else {
                    System.debug('data_gl_json es nulo o está vacío');
                }
            }
        }else {
            System.debug('El tramite es nulo');
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