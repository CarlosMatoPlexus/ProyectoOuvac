@isTest
public class BopedictoUpdateBatchableTest {
    @isTest
    static void testBopedictoUpdateBatchableTest() {
        // Crear una lista de idBopedicto simulada
        List<String> idBopecictos = new List<String>{ '60881', '60882' };
        // Simular un token
        String token = 'mockToken123';
        // Insertar datos de Knowledge__kav simulados para la prueba
        Knowledge__kav knowledge1 = new Knowledge__kav(
            Bopedicto_Id__c = '60881',
        Title = 'Bopedicto Test 1',
        UrlName = 'Bopedicto-test-1'
            );
        Knowledge__kav knowledge2 = new Knowledge__kav(
            Tramite_id__c = '60882',
        Title = 'Bopedicto Test 2',
        UrlName = 'Bopedicto-test-2'
            );
        insert new List<Knowledge__kav>{ knowledge1, knowledge2 };
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Ejecutar el batch
        Test.startTest();
        BopedictoUpdateBatchable batchJob = new BopedictoUpdateBatchable(idBopecictos, token);
        ID batchJobId = Database.executeBatch(batchJob, 2);
        Test.stopTest();
        // Verificar que el trabajo Batchable se ejecutó correctamente
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                           FROM AsyncApexJob WHERE Id = :batchJobId LIMIT 1];
        System.assertEquals('Completed', job.Status, 'El trabajo Batch debe estar completado.');
        System.assertEquals(1, job.TotalJobItems, 'El número total de items debe ser 1.');
        System.assertEquals(1, job.JobItemsProcessed, 'El número de items procesados debe ser 1.');
        System.assertEquals(0, job.NumberOfErrors, 'No debería haber errores en el procesamiento del batch.');
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
            // Simulación de la respuesta JSON de la API para obtener detalles de los bopedictos
            else if (req.getEndpoint().contains('/bop_edictos')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('['+
                    '{'+
                    '        "id": 60881,'+
                    '        "id_bop_edicto_externo": 661,'+
                    '        "bop": {'+
                    '            "id": 7901,'+
                    '            "id_bop_externo": 241'+
                    '        },'+
                    '        "sumario": "Exposición pública de la iniciación del expediente para investigar la titularidad de un terreno",'+
                    '        "institucion": {'+
                    '            "code": "001",'+
                    '            "name": "Allariz"'+
                    '        },'+
                    '        "tema": {'+
                    '            "code": "012",'+
                    '            "name": "Otras"'+
                    '        },'+
                    '        "activo": true,'+
                    '        "fecha_creacion": "2024-11-29T13:30:22+01:00",'+
                    '        "fecha_modificacion": "' + fechaActual + '"' +
                    '        "ambito": {'+
                    '            "code": "001",'+
                    '            "name": "Allariz"'+
                    '        }'+
                    ']');
            }
            return res;
        }
    }
}