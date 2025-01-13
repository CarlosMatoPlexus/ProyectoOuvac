@isTest
public class BopedictoBatchableTest {
    @isTest
    static void testBopedictoBatchable() {
        // Crear una lista de idBopedicto simulada
        List<String> idBopecictos = new List<String>{ '60881', '60882' };
        // Simular un token
        String token = 'mockToken123';
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Ejecutar el batch
        Test.startTest();
        BopedictoBatchable batchJob = new BopedictoBatchable(idBopecictos, token);
        ID batchJobId = Database.executeBatch(batchJob, 2);
        Test.stopTest();
        // Verificar que el trabajo Batchable se ejecutó correctamente
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id = :batchJobId LIMIT 1];
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
            // Simulación de la respuesta JSON de la API para obtener detalles de bopedictos
            if (req.getEndpoint().contains('/bop_edictos')) {
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
                    '        "fecha_modificacion": "2024-11-29T13:30:22+01:00",'+
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