public class TramiteService {
    public static void procesarTramite(List<String> detallesJson){
        for (String jsonDetalle : detallesJson){
            try {
                //Declaracion de variables
                Knowledge__kav knowCastellano = new Knowledge__kav();
                Knowledge__kav knowOtraLengua = new Knowledge__kav();
                List<Knowledge__kav> lstKnowledge = new List<Knowledge__kav>();
                
                Integer tramiteId;
                String fecha_creacion;
                String fecha_modificacion;
                String entidad;
                //Variables data_es_json
                String data_es_json_coleccionNormativas;
                String data_es_json_urlInicioTramitacion;
                String data_es_json_urlDescargaInstancia;
                
                //Variables data_gl_json
                String data_gl_json_coleccionNormativas;
                String data_gl_json_urlInicioTramitacion;
                String data_gl_json_urlDescargaInstancia;
                
                // Deserializa el JSON en un objeto de tramite
                Tramite tramite = (Tramite) JSON.deserialize(jsonDetalle, Tramite.class);
                // Procesar los datos principales del tramite
                if(tramite != null){
                    tramiteId = tramite.id; // parsear a text
                    String stringTramiteId = String.valueOf(tramiteId);
                    knowCastellano.Tramite_id__c = stringTramiteId;
                    knowOtraLengua.Tramite_id__c = stringTramiteId;
                    knowCastellano.UrlName = stringTramiteId;
                    knowOtraLengua.UrlName = stringTramiteId;
                    
                    knowCastellano.Tramite_codigo__c = tramite.codigo;
                    knowOtraLengua.Tramite_codigo__c = tramite.codigo;
                    
                    knowCastellano.Title  = tramite.titulo;
                    knowOtraLengua.Title  = tramite.titulo;
                    
                    knowCastellano.Descripcion__c  = tramite.descripcion;
                    knowOtraLengua.Descripcion__c  = tramite.descripcion;
                    
                    knowCastellano.Ambitos__c = tramite.tema.name;
                    knowOtraLengua.Ambitos__c = tramite.tema.name;
                    
                    entidad = tramite.institucion.name;
                    if(entidad.contains(',')){
                        entidad.replace(',', ' ');
                    }
                    knowCastellano.Entidades__c = entidad;
                    knowOtraLengua.Entidades__c = entidad;
                    
                    knowCastellano.Activo__c = tramite.activo;
                    knowOtraLengua.Activo__c = tramite.activo;
                    
                    fecha_creacion = tramite.fecha_creacion;
                    fecha_modificacion = tramite.fecha_modificacion;
                    // Procesar data_es_json del Tramite
                    if(tramite.data_es_json != null){
                        if(tramite.data_es_json.codigo != null){
                            knowCastellano.Tramite_codigo_espanol__c = tramite.data_es_json.codigo;
                        }
                        if(tramite.data_es_json.titulo != null){
                            knowCastellano.Tramite_titulo_espanol__c = tramite.data_es_json.titulo;
                        }
                        if(tramite.data_es_json.descripcion != null){
                            knowCastellano.Tramite_descripcion_espanol__c = tramite.data_es_json.descripcion;
                        }
                        if(tramite.data_es_json.finalidad != null){
                            knowCastellano.Tramite_finalidad_espanol__c = tramite.data_es_json.finalidad;
                        }
                        if(tramite.data_es_json.requisitos != null){
                            knowCastellano.Tramite_requisitos_espanol__c = tramite.data_es_json.requisitos;
                        }
                        if(tramite.data_es_json.plazoPresentacion != null){
                            knowCastellano.Tramite_plazo_presentacion_espanol__c = tramite.data_es_json.plazoPresentacion;
                        }
                        if(tramite.data_es_json.presentacion != null){
                            knowCastellano.Tramite_presentacion_espanol__c = tramite.data_es_json.presentacion;
                        }
                        if(tramite.data_es_json.presentarPor != null){
                            knowCastellano.Tramite_presentar_por_espanol__c = tramite.data_es_json.presentarPor;
                        }
                        if(tramite.data_es_json.organoGestor != null){
                            knowCastellano.Tramite_organo_gestor_espanol__c = tramite.data_es_json.organoGestor;
                        }
                        if(tramite.data_es_json.plazoResolucion != null){
                            knowCastellano.Tramite_plazo_resolucion_espanol__c = tramite.data_es_json.plazoResolucion;
                        }
                        if(tramite.data_es_json.efectoSilencioAdministrativo != null){
                            knowCastellano.Tramite_efecto_silencio_admin_espanol__c = tramite.data_es_json.efectoSilencioAdministrativo;
                        }
                        if(tramite.data_es_json.recursos != null){
                            knowCastellano.Tramite_recursos_espanol__c = tramite.data_es_json.recursos;
                        }
                        if(tramite.data_es_json.normativaBasica != null){
                            knowCastellano.Tramite_normativa_basica_espanol__c = tramite.data_es_json.normativaBasica;
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
                            knowCastellano.Tramite_coleccion_normativas_espanol__c = data_es_json_coleccionNormativas;
                        }
                        if(tramite.data_es_json.informacionAdicional != null){
                            knowCastellano.Tramite_informacion_adicional_espanol__c = tramite.data_es_json.informacionAdicional;
                        }
                        if(tramite.data_es_json.nivelIdentificacionSolicitante != null){
                            knowCastellano.Tramite_nivel_identificacion_sol_esp__c = tramite.data_es_json.nivelIdentificacionSolicitante;
                        }
                        if(tramite.data_es_json.urlInicioTramitacion != null){
                            knowCastellano.Tramite_url_inicio_tramitacion_espanol__c = tramite.data_es_json.urlInicioTramitacion;
                        }
                        if(tramite.data_es_json.urlInicioTramitacion != null){
                            data_es_json_urlInicioTramitacion = tramite.data_es_json.urlInicioTramitacion;
                            if(tramite.data_es_json.urlDescargaInstancia != null){
                                data_es_json_urlDescargaInstancia = data_es_json_urlInicioTramitacion+tramite.data_es_json.urlDescargaInstancia;
                            }
                        }
                        if(data_es_json_urlDescargaInstancia != null){
                            knowCastellano.Tramite_url_descarga_instancia_espanol__c = data_es_json_urlDescargaInstancia;
                        }
                        if(tramite.data_es_json.urlDetalleTramite != null){
                            knowCastellano.Tramite_url_detalle_tramite_espanol__c = tramite.data_es_json.urlDetalleTramite;
                        }
                    } else{
                        System.debug('data_es_json es nulo o está vacío');
                    }
                    // Procesar data_gl_json del Tramite
                    if(tramite.data_gl_json != null){
                        if(tramite.data_gl_json.codigo != null){
                            knowOtraLengua.Tramite_codigo_galego__c = tramite.data_gl_json.codigo;
                        }
                        if(tramite.data_gl_json.titulo != null){
                            knowOtraLengua.Tramite_titulo_galego__c = tramite.data_gl_json.titulo;
                        }
                        if(tramite.data_gl_json.descripcion != null){
                            knowOtraLengua.Tramite_descripcion_galego__c = tramite.data_gl_json.descripcion;
                        }
                        if(tramite.data_gl_json.finalidad != null){
                            knowOtraLengua.Tramite_finalidad_galego__c = tramite.data_gl_json.finalidad;
                        }
                        if(tramite.data_gl_json.requisitos != null){
                            knowOtraLengua.Tramite_requisitos_galego__c = tramite.data_gl_json.requisitos;
                        }
                        if(tramite.data_gl_json.plazoPresentacion != null){
                            knowOtraLengua.Tramite_plazo_presentacion_galego__c = tramite.data_gl_json.plazoPresentacion;
                        }
                        if(tramite.data_gl_json.presentacion != null){
                            knowOtraLengua.Tramite_presentacion_galego__c = tramite.data_gl_json.presentacion;
                        }
                        if(tramite.data_gl_json.presentarPor != null){
                            knowOtraLengua.Tramite_presentar_por_galego__c = tramite.data_gl_json.presentarPor;
                        }
                        if(tramite.data_gl_json.organoGestor != null){
                            knowOtraLengua.Tramite_organo_gestor_galego__c = tramite.data_gl_json.organoGestor;
                        }
                        if(tramite.data_gl_json.plazoResolucion != null){
                            knowOtraLengua.Tramite_plazo_resolucion_galego__c = tramite.data_gl_json.plazoResolucion;
                        }
                        if(tramite.data_gl_json.efectoSilencioAdministrativo != null){
                            knowOtraLengua.Tramite_efecto_silencio_admin_galego__c = tramite.data_gl_json.efectoSilencioAdministrativo;
                        }
                        if(tramite.data_gl_json.recursos != null){
                            knowOtraLengua.Tramite_recursos_galego__c = tramite.data_gl_json.recursos;
                        }
                        if(tramite.data_gl_json.normativaBasica != null){
                            knowOtraLengua.Tramite_normativa_basica_galego__c = tramite.data_gl_json.normativaBasica;
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
                            knowOtraLengua.Tramite_coleccion_normativas_galego__c = data_gl_json_coleccionNormativas;
                        }
                        if(tramite.data_gl_json.informacionAdicional != null){
                            knowOtraLengua.Tramite_informacion_adicional_galego__c = tramite.data_gl_json.informacionAdicional;
                        }
                        if(tramite.data_gl_json.nivelIdentificacionSolicitante != null){
                            knowOtraLengua.Tramite_nivel_identificacion_sol_esp__c = tramite.data_gl_json.nivelIdentificacionSolicitante;
                        }
                        if(tramite.data_gl_json.urlInicioTramitacion != null){
                            knowOtraLengua.Tramite_url_inicio_tramitacion_galego__c = tramite.data_gl_json.urlInicioTramitacion;
                        }
                        if(tramite.data_gl_json.urlInicioTramitacion != null){
                            data_gl_json_urlInicioTramitacion = tramite.data_gl_json.urlInicioTramitacion;
                            if(tramite.data_gl_json.urlDescargaInstancia != null){
                                data_gl_json_urlDescargaInstancia = data_gl_json_urlInicioTramitacion+tramite.data_gl_json.urlDescargaInstancia;
                            }
                        }
                        if(data_gl_json_urlDescargaInstancia != null){
                            knowOtraLengua.Tramite_url_descarga_instancia_galego__c = data_gl_json_urlDescargaInstancia;
                        }
                        if(tramite.data_gl_json.urlDetalleTramite != null){
                            knowOtraLengua.Tramite_url_detalle_tramite_galego__c = tramite.data_gl_json.urlDetalleTramite;
                        }
                    } else {
                        System.debug('data_gl_json es nulo o está vacío');
                    }
                    //Fecha creacion
                    if(fecha_creacion != null){
                        String fechaCreacionSinOffset = fecha_creacion.substring(0, 19);
                        String offSetCreacion = fecha_creacion.substring(19, 22);
                        Integer horasOffsetCreacion = Integer.valueOf(offSetCreacion);
                        fechaCreacionSinOffset = fechaCreacionSinOffset.replace('T', ' ');
                        DateTime fechaCreacion = DateTime.valueOf(fechaCreacionSinOffset);
                        fechaCreacion = fechaCreacion.addHours(horasOffsetCreacion);
                        knowCastellano.Fecha_de_creacion__c = fechaCreacion;
                        knowOtraLengua.Fecha_de_creacion__c = fechaCreacion;
                        System.debug('Fecha creacion: '+ fechaCreacion);
                    }
                    //Fecha modificacion
                    if(fecha_modificacion != null){
                        String fechaModificacionSinOffset = fecha_modificacion.substring(0, 19);
                        String offSetModificacion = fecha_modificacion.substring(19, 22);
                        Integer horasOffsetModificacion = Integer.valueOf(offSetModificacion);
                        fechaModificacionSinOffset = fechaModificacionSinOffset.replace('T', ' ');
                        DateTime fechaModificacion = DateTime.valueOf(fechaModificacionSinOffset);
                        fechaModificacion = fechaModificacion.addHours(horasOffsetModificacion);
                        knowCastellano.fecha_modificacion__c = fechaModificacion;
                        knowOtraLengua.fecha_modificacion__c = fechaModificacion;
                        System.debug('Fecha modificacion: '+ fechaModificacion);
                    }
                    knowCastellano.ValidationStatus = 'Validated';
                    knowOtraLengua.ValidationStatus = 'Validated';
                    knowCastellano.Language = 'es';
                    knowOtraLengua.Language = 'es_MX';
                    String tramiteRecordTypeID = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Tramite').getRecordTypeId();
                    knowCastellano.RecordTypeId = tramiteRecordTypeID;
                    knowOtraLengua.RecordTypeId = tramiteRecordTypeID;
                    lstKnowledge.add(knowCastellano);
                    lstKnowledge.add(knowOtraLengua);
                    insert lstKnowledge;
                    
                    List<KnowledgeArticleVersion> lstKnowPublish = new List<KnowledgeArticleVersion>();
                    lstKnowPublish = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft'];
                    for(KnowledgeArticleVersion know : lstKnowPublish){
                        KbManagement.PublishingService.publishArticle(know.KnowledgeArticleId, true);
                    }
                    
                } else {
                    System.debug('El objeto tramite es nulo o vacio');
                }
            } catch(Exception ex) {
                System.debug('Ocurrió un error al procesar el tramite: ' + ex.getMessage());
            }
        }
    }
}