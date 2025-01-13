@isTest
public class BopedictoServiceTest {
    @isTest
    static void testProcesarBopedicto() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Ejecutar el método
        Test.startTest();
        List<String> detallesJson = new List<String>();
        List<String>  scope = new List<String>();
        scope.add('60000');
        String token = 'mockToken123';
        detallesJson = APIGetBopedictos.obtenerDetallesBopedictos(scope, token);
        BopedictoService.procesarBopedicto(detallesJson);
        Test.stopTest();
        // Verificar si se insertaro 1 registro de Knowledge__kav
        List<Knowledge__kav> knowledgeList = [SELECT Id, Bopedicto_Id__c, Descripcion__c, RecordTypeId, Language FROM Knowledge__kav WHERE Bopedicto_Id__c = '60000'];
        System.assertEquals(2, knowledgeList.size(), 'Se debe haber insertado 2 registros de Knowledge__kav');
        // Verificar si uno de los registros está en español y otro en español mexicano
        Knowledge__kav knowCastellano = null;
        Knowledge__kav knowOtraLengua = null;
        for (Knowledge__kav know : knowledgeList) {
            if (know.RecordTypeId == Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Bopedicto').getRecordTypeId()) {
                if (know.Language == 'es') {
                    knowCastellano = know;
                } else if (know.Language == 'es_MX') {
                    knowOtraLengua = know;
                }
            }
        }
        System.assertEquals('es_MX', knowOtraLengua.Language, 'El registro en galego debe existir en Salesforce.');
        System.assertEquals('es', knowCastellano.Language, 'El registro en espalñol debe existir en Salesforce.');
    }
    
    // Mock class para simular las respuestas de las llamadas HTTP
    private class APIBopedictosMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta de login
            if (req.getEndpoint().contains('/login_check')) {
                res.setBody('{"token": "mockToken123", "refresh_token": "mockRefreshToken123", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API para bopedictos
            else if (req.getEndpoint().contains('/bop_edictos/60000')) {
                // Usar DateTime.now() para simular la fecha actual y asegurar la actualización
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('{' +                    
                    '    "id": 60000,'+
                    '    "id_bop_edicto_externo": 3141,'+
                    '    "bop": {'+
                    '        "id": 7918,'+
                    '        "id_bop_externo": 581'+
                    '    },'+
                    '    "sumario": "Exposición pública del padrón anual del impuesto de bienes inmuebles de naturaleza urbana del ejercicio de 2009.",'+
                    '    "institucion": {'+
                    '        "code": "036",'+
                    '        "name": "Laza"'+
                    '    },'+
                    '    "tema": {'+
                    '        "code": "012",'+
                    '        "name": "Otras"'+
                    '    },'+
                    '    "activo": true,'+
                    '    "fecha_creacion": "2024-11-29T13:31:44+01:00",'+
                    '    "fecha_modificacion": "2024-11-29T13:31:44+01:00",'+
                    '    "ambito": {'+
                    '        "code": "036",'+
                    '        "name": "Laza"'+
                    '    },'+
                    '    "data_es_json": {'+
                    '        "id_bop_edicto_externo": 3141,'+
                    '        "fecha_entrada": "2009-04-23T00:00:00+02:00",'+
                    '        "numero_pagina": 23,'+
                    '        "tema": "Otras",'+
                    '        "entidad_nombre": "CONCELLO DE LAZA",'+
                    '        "entidad_nif": "P3204000H",'+
                    '        "sumario": "Exposición pública del padrón anual del impuesto de bienes inmuebles de naturaleza urbana del ejercicio de 2009.",'+
                    '        "texto": "ex.publica padron IBI urbana-09",'+
                    '        "url_texto": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
                    '        "url_pdf": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
                    '        "url_html": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
                    '        "url_epub": "https://bop.depourense.es/portal/consulta?fecha=20090429"'+
                    '    },'+
                    '    "data_gl_json": {'+
                    '        "id_bop_edicto_externo": 3141,'+
                    '        "fecha_entrada": "2009-04-23T00:00:00+02:00",'+
                    '        "numero_pagina": 23,'+
                    '        "tema": "Otras",'+
                    '        "entidad_nombre": "CONCELLO DE LAZA",'+
                    '        "entidad_nif": "P3204000H",'+
                    '        "sumario": "Exposición pública do padrón anual do imposto de bens inmobles de natureza urbana do exercicio de 2009.",'+
                    '        "texto": "ex.publica padron IBI urbana-09",'+
                    '        "url_texto": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
                    '        "url_pdf": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
                    '        "url_html": "https://bop.depourense.es/portal/consulta?fecha=20090429",'+
                    '        "url_epub": "https://bop.depourense.es/portal/consulta?fecha=20090429"'+
                    '    }'+
                    '}');
            }
            // Simulación de la respuesta JSON de la API para obtener detalles de las bopedictos
            else if (req.getEndpoint().contains('/bop_edictos')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('['+
                    '{'+
                    '       "id": 60000,'+
                    '       "id_bop_edicto_externo": 661,'+
                    '       "bop": {'+
                    '           "id": 7901,'+
                    '           "id_bop_externo": 241'+
                    '       },'+
                    '       "sumario": "Exposición pública de la iniciación del expediente para investigar la titularidad de un terreno",'+
                    '       "institucion": {'+
                    '           "code": "001",'+
                    '           "name": "Allariz"'+
                    '       },'+
                    '       "tema": {'+
                    '           "code": "012",'+
                    '           "name": "Otras"'+
                    '       },'+
                    '       "activo": true,'+
                    '       "fecha_creacion": "2024-11-29T13:30:22+01:00",'+
                    '       "fecha_modificacion": "' + fechaActual + '",'+
                    '       "ambito": {'+
                    '           "id": 202,'+
                    '           "name": "Local"'+
                    '       }'+
                    '}'+
                    ']');
            }
            return res;
        }
    }
}