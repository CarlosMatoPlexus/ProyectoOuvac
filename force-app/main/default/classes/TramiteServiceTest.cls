@isTest
public class TramiteServiceTest {
    @isTest
    static void testProcesarTramite() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Ejecutar el método
        Test.startTest();
        List<String> detallesJson = new List<String>();
        List<String>  idTramites = new List<String>();
        idTramites.add('580');
        String token = 'mockToken123';
        detallesJson = APIGetTramites.obtenerDetallesTramites(idTramites, token);
        TramiteService.procesarTramite(detallesJson);
        Test.stopTest();
        // Verificar si se insertaron 2 registros de Knowledge__kav
        List<Knowledge__kav> knowledgeList = [SELECT Id, Tramite_id__c , Descripcion__c, RecordTypeId, Language FROM Knowledge__kav WHERE Tramite_id__c = '580'];
        System.assertEquals(2, knowledgeList.size(), 'Se deben haber insertado 2 registros de Knowledge__kav');
        // Verificar si uno de los registros está en español y otro en español mexicano
        Knowledge__kav knowCastellano = null;
        Knowledge__kav knowOtraLengua = null;
        for (Knowledge__kav know : knowledgeList) {
            if (know.RecordTypeId == Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Tramite').getRecordTypeId()) {
                if (know.Language == 'es') {
                    knowCastellano = know;
                } else if (know.Language == 'es_MX') {
                    knowOtraLengua = know;
                }
            }
        }
        System.assertEquals('es', knowCastellano.Language, 'El registro en español debe existir en Salesforce.');
        System.assertEquals('es_MX', knowOtraLengua.Language, 'El registro en galego debe existir en Salesforce.');
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
            else if (req.getEndpoint().contains('/tramites/580')) {
                // Usar DateTime.now() para simular la fecha actual y asegurar la actualización
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('{'+
                    '    "id": 580,'+
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
                    '    "fecha_modificacion": "2024-08-21T20:57:16+02:00",'+
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
            // Simulación de la respuesta JSON de la API para obtener detalles de los tramites
            else if (req.getEndpoint().contains('/tramites')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('[' +
                    ' {' +
                    '  "id": 514,' +
                    '  "codigo": "001/2666943",' +
                    '  "titulo": "Abastecimiento de Aguas (Baja)",' +
                    '  "descripcion": "Permite tramitar expedientes relativos a la baja en el servicio público de abastecimiento y saneamiento de agua.",' +
                    '  "institucion": {' +
                    '      "code": "001",' +
                    '      "name": "Allariz"' +
                    '  },' +
                    '  "tema": "/api/temas/011",' +
                    '  "activo": true,' +
                    '  "fecha_creacion": "2024-08-06T12:52:19+02:00",' +
                    '  "fecha_modificacion": "' + fechaActual + '"' +
                    ' }' +
                    ']');
            }
            return res;
        }
    }
}