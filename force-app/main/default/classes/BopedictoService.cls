public class BopedictoService {
    public static void procesarBopedicto(List<String> detallesJson){
        for (String jsonDetalle : detallesJson){
            try {
                //Declaracion de variables
                Knowledge__kav knowCastellano = new Knowledge__kav();
                Knowledge__kav knowOtraLengua = new Knowledge__kav();
                List<Knowledge__kav> lstKnowledge = new List<Knowledge__kav>();
                String fecha_creacion;
                Datetime fechaCreacion;
                String fecha_modificacion;
                Datetime fechaModificacion;
                String ambito; //tema_name
                String entidad; // ambito_name
                Datetime fechaEntradaEspanol;
                Datetime fechaEntradaGalego;
                
                //Variable recordType
                String bopedictoRecordTypeID = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Bopedicto').getRecordTypeId();
                
                // Deserializa el JSON en un objeto de Bopedicto
                Bopedicto bopedicto = Bopedicto.fromJson(jsonDetalle);
                // Procesar los datos principales del bopedicto
                if(bopedicto != null){
                    fecha_creacion = bopedicto.fecha_creacion;
                    fecha_modificacion = bopedicto.fecha_modificacion;
                    if(fecha_modificacion != null){
                        fechaModificacion = convertFechasJson(fecha_modificacion);
                    }else{
                        System.debug('fecha_modificacion es null');
                    }
                    if(fecha_creacion != null){
                        fechaCreacion = convertFechasJson(fecha_creacion);
                    }else{
                        System.debug('fecha_creacion es null');
                    }
                    if(bopedicto.tema != null){
                        ambito = bopedicto.tema.name;
                    }else{
                        ambito = 'Otras';
                    }
                    if(bopedicto.ambito != null){
                        entidad = bopedicto.ambito.name;
                    }else {
                        entidad = 'Deputación';
                    }
                    if(entidad.contains('Diputación')){
                        entidad = 'Deputación';
                    }
                    if(entidad.contains(',')){
                        entidad = entidad.replace(',', '');
                    }
                    if(bopedicto.data_es_json != null){
                        knowCastellano.Bopedicto_Id__c = String.valueOf(bopedicto.id);
                        knowCastellano.UrlName = String.valueOf(bopedicto.id)+'-'+'Esp';
                        knowCastellano.Bopedicto_Id_bop_edicto_externo__c = String.valueOf(bopedicto.id_bop_edicto_externo);
                        knowCastellano.Sumario__c = bopedicto.sumario;
                        knowCastellano.Activo__c = bopedicto.activo;
                        knowCastellano.Bopedicto_Bop_Id__c = String.valueOf(bopedicto.bop.Id); //Convert to String
                        knowCastellano.Bopedicto_bop_id_bop_externo__c = String.valueOf(bopedicto.bop.id_bop_externo); //Convert to String
                        knowCastellano.Ambitos__c = ambito;
                        knowCastellano.Entidades__c = entidad;
                        if(fecha_creacion != null){
                            knowCastellano.Fecha_de_creacion__c = fechaCreacion;
                        }
                        if(fecha_modificacion != null){
                            knowCastellano.fecha_modificacion__c = fechaModificacion;
                        }
                        
                        if(bopedicto.data_es_json.id_bop_edicto_externo != null){
                            knowCastellano.Bopedicto_Id_bop_edicto_externo_Esp__c = String.valueOf(bopedicto.data_es_json.id_bop_edicto_externo);//Convert to String
                        }
                        if(bopedicto.data_es_json.fecha_entrada != null){
                            fechaEntradaEspanol = convertFechasJson(bopedicto.data_es_json.fecha_entrada);
                            knowCastellano.Bopedicto_fecha_entrada_Esp__c = fechaEntradaEspanol;
                        }
                        if(bopedicto.data_es_json.numero_pagina != null){
                            knowCastellano.Bopedicto_numero_pagina_Esp__c = bopedicto.data_es_json.numero_pagina;
                        }
                        if(bopedicto.data_es_json.entidad_nombre != null){
                            knowCastellano.Bopedicto_entidad_nombre_Esp__c = bopedicto.data_es_json.entidad_nombre;
                        }
                        if(bopedicto.data_es_json.entidad_nif != null){
                            knowCastellano.Bopedicto_entidad_nif_Esp__c = bopedicto.data_es_json.entidad_nif;
                        }
                        if(bopedicto.data_es_json.sumario != null){
                            knowCastellano.Bopedicto_sumario_Esp__c = bopedicto.data_es_json.sumario;
                            knowCastellano.Title = bopedicto.data_es_json.sumario;
                            knowCastellano.Descripcion__c = bopedicto.data_es_json.sumario;
                        }else {
                            knowCastellano.Title = bopedicto.sumario;
                            knowCastellano.Descripcion__c = bopedicto.sumario;
                        }
                        if(bopedicto.data_es_json.texto != null){
                            knowCastellano.Bopedicto_texto_Esp__c = bopedicto.data_es_json.texto;
                        }
                        if(bopedicto.data_es_json.url_texto != null){
                            knowCastellano.Bopedicto_Url_texto_Esp__c = bopedicto.data_es_json.url_texto;
                        }
                        if(bopedicto.data_es_json.url_pdf != null){
                            knowCastellano.Bopedicto_Url_pdf_Esp__c = bopedicto.data_es_json.url_pdf;
                        }
                        if(bopedicto.data_es_json.url_html != null){
                            knowCastellano.Bopedicto_Url_html_Esp__c = bopedicto.data_es_json.url_html;
                        }
                        if(bopedicto.data_es_json.url_epub != null){
                            knowCastellano.Bopedicto_Url_epub_Esp__c = bopedicto.data_es_json.url_epub;
                        }
                        knowCastellano.ValidationStatus = 'Validated';
                        knowCastellano.RecordTypeId = bopedictoRecordTypeID;
                        knowCastellano.Language = 'es';
                        lstKnowledge.add(knowCastellano);
                    }else {
                        System.debug('No hay datos en data_es_json');
                    }
                    if(bopedicto.data_gl_json != null){
                        knowOtraLengua.Bopedicto_Id__c = String.valueOf(bopedicto.id);
                        knowOtraLengua.UrlName = String.valueOf(bopedicto.id)+'-'+'Gal';
                        knowOtraLengua.Bopedicto_Id_bop_edicto_externo__c = String.valueOf(bopedicto.id_bop_edicto_externo);
                        knowOtraLengua.Sumario__c = bopedicto.sumario;
                        knowOtraLengua.Activo__c = bopedicto.activo;
                        knowOtraLengua.Bopedicto_Bop_Id__c = String.valueOf(bopedicto.bop.Id); //Convert to String
                        knowOtraLengua.Bopedicto_bop_id_bop_externo__c = String.valueOf(bopedicto.bop.id_bop_externo); //Convert to String
                        knowOtraLengua.Ambitos__c = ambito;
                        knowOtraLengua.Entidades__c = entidad;
                        if(fecha_creacion != null){
                            knowOtraLengua.Fecha_de_creacion__c = fechaCreacion;
                        }
                        if(fecha_modificacion != null){
                            knowOtraLengua.fecha_modificacion__c = fechaModificacion;
                        }
                        if(bopedicto.data_gl_json.id_bop_edicto_externo != null){
                            knowOtraLengua.Bopedicto_Id_bop_edicto_externo_Gal__c = String.valueOf(bopedicto.data_gl_json.id_bop_edicto_externo);//Convert to String
                        }
                        if(bopedicto.data_gl_json.fecha_entrada != null){
                            fechaEntradaGalego = convertFechasJson(bopedicto.data_gl_json.fecha_entrada);
                            knowOtraLengua.Bopedicto_fecha_entrada_Gal__c = fechaEntradaGalego;
                        }
                        if(bopedicto.data_gl_json.numero_pagina != null){
                            knowOtraLengua.Bopedicto_numero_pagina_Gal__c = bopedicto.data_gl_json.numero_pagina;
                        }
                        if(bopedicto.data_gl_json.entidad_nombre != null){
                            knowOtraLengua.Bopedicto_entidad_nombre_Gal__c = bopedicto.data_gl_json.entidad_nombre;
                        }
                        if(bopedicto.data_gl_json.entidad_nif != null){
                            knowOtraLengua.Bopedicto_entidad_nif_Gal__c = bopedicto.data_gl_json.entidad_nif;
                        }
                        if(bopedicto.data_gl_json.sumario != null){
                            knowOtraLengua.Bopedicto_sumario_Gal__c = bopedicto.data_gl_json.sumario;
                            knowOtraLengua.Title = bopedicto.data_gl_json.sumario;
                            knowOtraLengua.Descripcion__c = bopedicto.data_es_json.sumario;
                        }else{
                            knowOtraLengua.Title = bopedicto.sumario;
                            knowOtraLengua.Descripcion__c = bopedicto.sumario;
                        }
                        if(bopedicto.data_gl_json.texto != null){
                            knowOtraLengua.Bopedicto_texto_Gal__c = bopedicto.data_gl_json.texto;
                        }
                        if(bopedicto.data_gl_json.url_texto != null){
                            knowOtraLengua.Bopedicto_Url_texto_Gal__c = bopedicto.data_gl_json.url_texto;
                        }
                        if(bopedicto.data_gl_json.url_pdf != null){
                            knowOtraLengua.Bopedicto_Url_pdf_Gal__c = bopedicto.data_gl_json.url_pdf;
                        }
                        if(bopedicto.data_gl_json.url_html != null){
                            knowOtraLengua.Bopedicto_Url_html_Gal__c = bopedicto.data_gl_json.url_html;
                        }
                        if(bopedicto.data_gl_json.url_epub != null){
                            knowOtraLengua.Bopedicto_Url_epub_Gal__c = bopedicto.data_gl_json.url_epub;
                        }
                        knowOtraLengua.ValidationStatus = 'Validated';
                        knowOtraLengua.RecordTypeId = bopedictoRecordTypeID;
                        knowOtraLengua.Language = 'es_MX';
                        lstKnowledge.add(knowOtraLengua);
                    }else{
                        System.debug('No hay datos en data_gl_json');
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
                System.debug('Ocurrió un error al procesar el bopedicto: ' + ex.getMessage());
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