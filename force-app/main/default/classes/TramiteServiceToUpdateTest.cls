@isTest
public class TramiteServiceToUpdateTest {
    @isTest
    static void testTramiteServiceToUpdateTest() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Simular algunos datos existentes de Knowledge en Salesforce
        Knowledge__kav knowledgeEsp = new Knowledge__kav(
            Tramite_id__c = '514',
            fecha_modificacion__c = DateTime.now().addDays(-2), // Fecha anterior para forzar actualización
            Title = 'knowledgeEsp',
            UrlName = 'knowledgeEsp',
            Language = 'es'
        );
        insert knowledgeEsp;
        Knowledge__kav knowledgeGal = new Knowledge__kav(
            Tramite_id__c = '514',
        fecha_modificacion__c = DateTime.now().addDays(-2), // Fecha anterior para forzar actualización
        Title = 'knowledgeGal',
        UrlName = 'knowledgeGal',
        Language = 'es_MX'
            );
        insert knowledgeGal;
        // Ejecutar los métodos
        Test.startTest();
        List<String> detallesJson = new List<String>();
        List<String>  idTramites = new List<String>();
        idTramites.add('514');
        String token = 'mockToken123';
        detallesJson = APIGetTramites.obtenerDetallesTramites(idTramites, token);
        TramiteServiceToUpdate.updateTramite(detallesJson);
        
        Test.stopTest();
        Knowledge__kav assignKnowEsp;
        Knowledge__kav assignKnowGal;
        List<Knowledge__kav> knowLst = [SELECT Id, fecha_modificacion__c, Language, Tramite_id__c FROM Knowledge__kav WHERE Tramite_id__c = '514'];
        
        for(Knowledge__kav k : knowLst){
            if(k.Language =='es'){
                assignKnowEsp = k;
            }else if (k.Language == 'es_MX') {
                assignKnowGal = k;
            }
        }
        //System.assertEquals(Datetime.now().date(), assignKnowEsp.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en esapñol debe ser igual que'+' '+ Datetime.now().date());
        System.assertEquals(Datetime.now().date(), assignKnowGal.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en galego debe ser igual que'+' '+ Datetime.now().date());
        System.assert(assignKnowEsp.fecha_modificacion__c.date() > knowledgeEsp.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en esapñol debe ser mayor.');
        System.assert(assignKnowGal.fecha_modificacion__c.date() > knowledgeGal.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en galego debe ser mayor.');
    }
    
    
    // Mock class para simular las respuestas de las llamadas HTTP
    private class APIGetTramiteMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta de login
            if (req.getEndpoint().contains('/login_check')) {
                res.setBody('{"token": "mockToken123", "refresh_token": "mockRefreshToken123", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API para tramite
            else if (req.getEndpoint().contains('/tramites/514')) {
                // Usar DateTime.now() para simular la fecha actual y asegurar la actualización
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('{'+
                    '    "id": 514,'+
                    '    "codigo": "001/2666943",'+
                    '    "titulo": "Abastecimiento de Aguas (Baja)",'+
                    '    "descripcion": "Permite tramitar expedientes relativos a la baja en el servicio público de abastecimiento y saneamiento de agua.",'+
                    '    "institucion": {'+
                    '        "code": "001",'+
                    '        "name": "Allariz"'+
                    '    },'+
                    '    "tema": {'+
                    '        "code": "011",'+
                    '        "name": "Tramitación electrónica"'+
                    '    },'+
                    '    "activo": true,'+
                    '    "fecha_creacion": "2024-08-06T12:52:19+02:00",'+
                    '    "fecha_modificacion": "' + fechaActual + '",' +
                    '    "data_es_json": {'+
                    '        "codigo": "2666943",'+
                    '        "titulo": "Abastecimiento de Aguas (Baja)",'+
                    '        "descripcion": "Permite tramitar expedientes relativos a la baja en el servicio público de abastecimiento y saneamiento de agua.",'+
                    '        "finalidad": "",'+
                    '        "requisitos": "Según la normativa aplicable la iniciación de este procedimiento podrá ser tanto de oficio como a instancia de parte.",'+
                    '        "plazoPresentacion": "Continuo",'+
                    '        "presentacion": "",'+
                    '        "presentarPor": "",'+
                    '        "organoGestor": "",'+
                    '        "plazoResolucion": "Según normativa aplicable",'+
                    '        "efectoSilencioAdministrativo": "Según normativa aplicable",'+
                    '        "recursos": "",'+
                    '        "normativaBasica": "",'+
                    '        "coleccionNormativas": ['+
                    '            {'+
                    '                "titulo": "Ley 39/2015, de 1 de octubre, del Procedimiento Administrativo Común de las Administraciones Públicas.",'+
                    '                "url": "https://www.boe.es/legislacion"'+
                    '            },'+
                    '            {'+
                    '                "titulo": "Ley 7/1985, de 2 de abril, reguladora de las Bases del Régimen Local.",'+
                    '                "url": "https://www.boe.es/legislacion"'+
                    '            }'+
                    '        ],'+
                    '        "informacionAdicional": "",'+
                    '        "nivelIdentificacionSolicitante": "",'+
                    '        "coleccionDocumentos": [],'+
                    '        "urlInicioTramitacion": "https://allariz.sedelectronica.gal/catalog/tw/27666b59-7238-4f55-9968-d45406f433f9",'+
                    '        "urlDescargaInstancia": "?x=ezozc-EQNg7eJccPZ9FOYjFy9U4CxBq6Hoa0ysvF18RF2jpGNmnzfG4-TZyuKEEtQX2r1qgcSemr0xdsTTjchw",'+
                    '        "urlDetalleTramite": ""'+
                    '    },'+
                    '    "data_gl_json": {'+
                    '        "codigo": "2666943",'+
                    '        "titulo": "Abastecemento de Augas (Baixa)",'+
                    '        "descripcion": "Permite tramitar expedientes relativos á baixa no servizo público de abastecemento e saneamento de auga.",'+
                    '        "finalidad": "",'+
                    '        "requisitos": "Segundo a normativa aplicable a iniciación deste procedemento poderá ser tanto de oficio como a instancia de parte.",'+
                    '        "plazoPresentacion": "Continuo",'+
                    '        "presentacion": "",'+
                    '        "presentarPor": "",'+
                    '        "organoGestor": "",'+
                    '        "plazoResolucion": "Segundo normativa aplicable",'+
                    '        "efectoSilencioAdministrativo": "Segundo normativa aplicable",'+
                    '        "recursos": "",'+
                    '        "normativaBasica": "",'+
                    '        "coleccionNormativas": ['+
                    '            {'+
                    '                "titulo": "Ley 39/2015, de 1 de octubre, del Procedimiento Administrativo Común de las Administraciones Públicas.",'+
                    '                "url": "https://www.boe.es/legislacion"'+
                    '            },'+
                    '            {'+
                    '                "titulo": "Ley 7/1985, de 2 de abril, reguladora de las Bases del Régimen Local.",'+
                    '                "url": "https://www.boe.es/legislacion"'+
                    '            }'+
                    '        ],'+
                    '        "informacionAdicional": "",'+
                    '        "nivelIdentificacionSolicitante": "",'+
                    '        "coleccionDocumentos": [],'+
                    '        "urlInicioTramitacion": "https://allariz.sedelectronica.gal/catalog/tw/27666b59-7238-4f55-9968-d45406f433f9",'+
                    '        "urlDescargaInstancia": "?x=ezozc-EQNg7eJccPZ9FOYjFy9U4CxBq6Hoa0ysvF18RF2jpGNmnzfKxGq45DXbG2tG*ZPeBfuLw-8P8UCHX1nQ",'+
                    '        "urlDetalleTramite": ""'+
                    '    }'+
                    '}');
            }
            
            return res;
        }
    }
}