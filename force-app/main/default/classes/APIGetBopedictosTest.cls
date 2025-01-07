@isTest
public class APIGetBopedictosTest {
    @isTest
    static void testObtenerBopedictos() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        Test.startTest();
        APIGetBopedictos.obtenerBopedictos();
        Test.stopTest();
        // Verificar que se programaron batch jobs para procesar registros
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' LIMIT 10];
        System.assert(!jobs.isEmpty(), 'Debe haber al menos un batch job programado.');
        System.assertEquals('Completed', jobs[0].Status, 'El primer batch job debería estar completado.');
    }
    
    @isTest
    static void testObtenerBopedictosCompareDate() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Simular algunos datos existentes de Knowledge en Salesforce
        Knowledge__kav knowledgeExisting = new Knowledge__kav(
            Bopedicto_Id__c = '60000',
        fecha_modificacion__c = DateTime.now().addDays(-2), // Fecha anterior para forzar actualización
        Title = 'knowledgeExisting',
        UrlName = 'knowledgeExisting'
            );
        insert knowledgeExisting;
        // Ejecutar el método a probar
        Test.startTest();
        APIGetBopedictos.obtenerBopedictos();
        Test.stopTest();
        // Verificar que se programaron batch jobs para procesar registros
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' LIMIT 10];
        System.assert(!jobs.isEmpty(), 'Debe haber al menos un batch job programado.');
        System.assertEquals('Completed', jobs[0].Status, 'El primer batch job debería estar completado.');
    }
    
    @isTest
    static void testObtenerBopedictosNew() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Ejecutar el método a probar
        Test.startTest();
        List<String> idBopedictos = new List<String>();
        idBopedictos.add('60000');
        String token = 'mockToken123';
        List<String> detallesJson = APIGetBopedictos.obtenerDetallesBopedictos(idBopedictos, token);
        BopedictoService.procesarBopedicto(detallesJson);
        Test.stopTest();
        //Verificar si el registro de Knowledge fue insertado correctamente
        Knowledge__kav newKnowledge = [SELECT Id, Bopedicto_Id__c FROM Knowledge__kav WHERE Bopedicto_Id__c = '60000' LIMIT 1];
        System.Assert(newKnowledge != null, 'El nuevo registro de Knowledge deberia haber sido insertado.');
        System.assertEquals('60000', newKnowledge.Bopedicto_Id__c, 'El id de la bopedicto del nuevo Knowledge deberia ser "60000"');
    }
    
    @isTest
    static void testObtenerDetallesBopedicto() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Simular algunos id de bopedictos para la prueba
        List<String> idBopedictos = new List<String>{ '60000' };
        String token = 'mockToken123';
        // Ejecutar el método que obtiene los detalles de las bopedictos.
        Test.startTest();
        List<String> detalles = APIGetBopedictos.obtenerDetallesBopedictos(idBopedictos, token);
        Test.stopTest();
        // Verificar que los detalles se obtuvieron correctamente
        System.assert(!detalles.isEmpty(), 'Debe haberse recuperado al menos un detalle de los bopedictos.');
        System.assert(detalles[0].contains('"id": 60000'), 'El detalle debe contener la bopedictos con id "60000".');
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