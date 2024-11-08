@isTest
public class TramiteQueueableTest
{
    @isTest
    static void testTramiteQueueable() {
        // Crear una lista de id de tramites simulada
        List<String> idTramiteList = new List<String>{ '514', '525' };
        // Simular un token
        String token = 'mockToken123';
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Ejecutar la clase Queueable
        Test.startTest();
        TramiteQueueable queueableJob = new TramiteQueueable(idTramiteList, token);
        ID jobId = System.enqueueJob(queueableJob);  // Enqueue the job
        Test.stopTest();
        // Verificar que el job fue encolado correctamente
        AsyncApexJob job = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
        System.assertNotEquals(null, job, 'El trabajo Queueable debe haberse encolado.');
        System.assertEquals('Queueable', job.JobType, 'El tipo de trabajo debe ser "Queueable".');
        System.assertEquals('Completed', job.Status, 'El trabajo Queueable debería haberse completado.');
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