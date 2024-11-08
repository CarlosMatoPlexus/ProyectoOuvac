@isTest
public class APIGetTramitesQueueableTest {
    @isTest
    static void testQueueableExecution() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Ejecutar el trabajo Queueable
        Test.startTest();
        System.enqueueJob(new APIGetTramitesQueueable());
        Test.stopTest();
        // Verificar que no hubo errores en la ejecución del job.
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        System.assertEquals('Completed', jobs[0].Status, 'El trabajo Queueable debe haberse completado.');
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