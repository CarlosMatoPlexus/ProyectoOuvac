@isTest
public class TramiteBatchableTest {
    @isTest
    static void testTramiteBatchable() {
        // Crear una lista de id de Trámites simulada
        List<String> idTramiteList = new List<String>{ '514', '525' };
        // Simular un token
        String token = 'mockToken123';
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Ejecutar el batch
        Test.startTest();
        TramiteBatchable batchJob = new TramiteBatchable(idTramiteList, token);
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
    private class APIGetTramiteMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta JSON de la API para obtener detalles de los trámites
            if (req.getEndpoint().contains('/tramites')) {
                res.setBody('['+
                    ' {'+
                    '  "id": 514,'+
                    '        "codigo": "001/2666943",'+
                    '        "titulo": "Abastecimiento de Aguas (Baja)",'+
                    '        "descripcion": "Permite tramitar expedientes relativos a la baja en el servicio público de abastecimiento y saneamiento de agua.",'+
                    '        "institucion": {'+
                    '            "code": "001",'+
                    '            "name": "Allariz"'+
                    '        },'+
                    '        "tema": "/api/temas/011",'+
                    '        "activo": true,'+
                    '        "fecha_creacion": "2024-08-06T12:52:19+02:00",'+
                    '        "fecha_modificacion": "2024-08-21T20:57:16+02:00"'+
                    ' }'+
                    ']');
            }
            return res;
        }
    }
}